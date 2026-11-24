/* g1 engine (experiment g001-e02): DFS of the trailing-ternary-digit tree of verify/CERT.md.
 * Written independently of verify/ (no shared source).
 *
 * Usage: engine <N decimal> <i> <m> [--ref-sat]
 * Prints: "d0 <d0>", "nl <limbs>", "counts c1 c2 ...", one "E <r>" per exception, "events <n> <sumhex> <xorhex>".
 * Exit 3 on any exceeded limit (depth, precision, exception buffer); exit 2 on bad input.
 *
 * Representation: v = 2^r mod 3^L, L = 19*NL trits, NL base-3^19 limbs (each < 2^31, products < 2^61, so up to
 * 8 products plus a carry accumulate in one uint64). NL is chosen from N so that L exceeds the last branching level
 * by >= 45 trits; chains that go deeper than L recompute 2^r mod 3^266 in a slow path (depth limit 265).
 *
 * --ref-sat: hash N events with P_k saturated at 2^125 (the convention of verify/tree_ref.c, which differs from the
 * literal CERT.md formula only for N events at levels k >= 80). Default is the literal CERT.md formula (r mod 2^128). */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

typedef unsigned __int128 u128;
#define B19 1162261467ULL          /* 3^19 */
#define NLMAX 8
#define FBN 14                     /* fallback limbs: 266 trits */
#define MAXD (FBN * 19 - 1)        /* deepest supported level (trit index <= MAXD is readable) */
#define MAXLV (MAXD + 3)
#define MAXEXC 4096
#ifndef MARGIN
#define MARGIN 45                  /* trits of precision beyond the last branching level */
#endif
#ifndef MINNL
#define MINNL 3                    /* (MARGIN/MINNL are lowered only by tests that force the fallback path) */
#endif

static void die(const char *msg) { fprintf(stderr, "engine: %s\n", msg); exit(3); }

static u128 NN;
static int rec;                    /* record events/counts (shard 0 in the prefix phase, always below d0) */
static int stop_level;             /* collect alive nodes reaching this level instead of expanding */
static uint64_t ev_n, ev_sum, ev_xor;
static uint64_t counts[MAXLV];
static u128 Pmod[MAXLV];           /* P_k for hashing (mod 2^128, or saturated with --ref-sat); exact when !Pbig */
static unsigned char Pbig[MAXLV];  /* P_k > N */
static int bitlen3[MAXLV];         /* bit length of 3^k: 3^k > 2^r  <=>  r < bitlen3[k] */
static int ck[MAXLV];              /* trit k of (2^(P_k) - 1), nonzero by lemma 2 */
static int lowlimb[MAXLV];         /* k / 19 */
static uint64_t Ek[2][MAXLV][NLMAX];   /* g_k^j - 1 mod 3^L, j = 1, 2 */
static uint64_t vbuf[MAXLV][NLMAX];
static uint64_t magic[19];         /* ceil(2^63 / 3^s) */
static uint64_t pow3[20];
static u128 exc[MAXEXC];
static int nexc;

static inline uint64_t mix(uint64_t z) {
    z += 0x9E3779B97F4A7C15ULL;
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL;
    return z ^ (z >> 31);
}
static inline void event(int k, u128 r, int code) {
    uint64_t h = mix(mix(mix((uint64_t)r) ^ (uint64_t)(r >> 64)) ^ (uint64_t)(4 * k + code));
    ev_n++; ev_sum += h; ev_xor ^= h;
}
/* exact for x < 3^19, s <= 18: x * 3^s < 2^63 */
static inline int trit_of(const uint64_t *v, int k) {
    uint64_t x = v[k / 19];
    uint64_t q = (uint64_t)(((u128)x * magic[k % 19]) >> 63);
    return (int)(q % 3);
}
/* (k, r) is alive; record it; return 1 if it is a terminal exception node */
static inline int alive_node(int k, u128 r) {
    if (k > MAXD) die("depth limit exceeded");
    int e = r < (u128)bitlen3[k] && (Pbig[k] || r + Pmod[k] > NN);
    if (rec) {
        counts[k]++;
        if (e) { event(k, r, 2); if (nexc == MAXEXC) die("too many exceptions"); exc[nexc++] = r; }
    }
    return e;
}

typedef struct { u128 r; int e; uint64_t v[NLMAX]; } cnode;
static cnode *col; static size_t ncol, capcol;
static void collect(int k, u128 r, const uint64_t *v, int nl, int e) {
    (void)k;
    if (ncol == capcol) { capcol = capcol ? 2 * capcol : 4096; col = realloc(col, capcol * sizeof *col); if (!col) die("oom"); }
    col[ncol].r = r; col[ncol].e = e; memset(col[ncol].v, 0, sizeof col[ncol].v);
    memcpy(col[ncol].v, v, nl * sizeof(uint64_t)); ncol++;
}

/* generic truncated product mod 3^(19n) (setup and fallback only) */
static void mulmod_n(const uint64_t *a, const uint64_t *b, uint64_t *out, int n) {
    u128 acc[FBN];
    memset(acc, 0, sizeof acc);
    for (int i = 0; i < n; i++) if (a[i]) for (int j = 0; i + j < n; j++) acc[i + j] += (u128)(a[i] * b[j]);
    u128 carry = 0;
    for (int i = 0; i < n; i++) { u128 t = acc[i] + carry; carry = t / B19; out[i] = (uint64_t)(t - carry * B19); }
}
static void pow2_n(u128 r, uint64_t *out, int n) {
    uint64_t res[FBN] = {1}, base[FBN] = {2}, t[FBN] = {0};
    for (; r; r >>= 1) {
        if (r & 1) { mulmod_n(res, base, t, n); memcpy(res, t, sizeof t); }
        mulmod_n(base, base, t, n); memcpy(base, t, sizeof t);
    }
    memcpy(out, res, n * sizeof(uint64_t));
}

/* chain continued beyond the fast precision: (k, r) alive non-terminal, P_k > N, the N events of its children
 * already emitted. */
static void chain_fallback(int k, u128 r) {
    uint64_t big[FBN];
    pow2_n(r, big, FBN);
    for (;;) {
        if (!Pbig[k]) die("branching beyond precision");
        if (k > MAXD) die("depth limit exceeded");
        if (trit_of(big, k) == 2) { if (rec) event(k + 1, r, 0); return; }
        k++;
        if (k == stop_level) die("stop level beyond precision");
        if (alive_node(k, r)) return;
        if (rec) { event(k + 1, r + Pmod[k], 1); event(k + 1, r + 2 * Pmod[k], 1); }
    }
}

#define NL 2
#include "core.inc"
#undef NL
#define NL 3
#include "core.inc"
#undef NL
#define NL 4
#include "core.inc"
#undef NL
#define NL 5
#include "core.inc"
#undef NL
#define NL 6
#include "core.inc"
#undef NL
#define NL 7
#include "core.inc"
#undef NL
#define NL 8
#include "core.inc"
#undef NL
typedef void (*expand_fn)(int, u128, const uint64_t *);
static expand_fn expand_tab[NLMAX + 1] = {0, 0, expand_2, expand_3, expand_4, expand_5, expand_6, expand_7, expand_8};

static void print_u128(u128 x) {
    char b[64]; int n = 0;
    do { b[n++] = '0' + (int)(x % 10); x /= 10; } while (x);
    while (n) putchar(b[--n]);
}
static int cmp_cnode(const void *a, const void *b) {
    u128 x = ((const cnode *)a)->r, y = ((const cnode *)b)->r;
    return x < y ? -1 : x > y;
}
static int cmp_u128(const void *a, const void *b) {
    u128 x = *(const u128 *)a, y = *(const u128 *)b;
    return x < y ? -1 : x > y;
}

int main(int argc, char **argv) {
    if (argc < 4 || argc > 5) { fprintf(stderr, "usage: engine N i m [--ref-sat]\n"); return 2; }
    int refsat = argc == 5 && !strcmp(argv[4], "--ref-sat");
    if (argc == 5 && !refsat) { fprintf(stderr, "bad option\n"); return 2; }
    const u128 LIM = (u128)1 << 120;
    NN = 0;
    for (const char *s = argv[1]; *s; s++) {
        if (*s < '0' || *s > '9') { fprintf(stderr, "bad N\n"); return 2; }
        NN = NN * 10 + (u128)(*s - '0');
        if (NN >= LIM) { fprintf(stderr, "engine: N >= 2^120 not supported\n"); return 3; }
    }
    if (!argv[1][0]) { fprintf(stderr, "bad N\n"); return 2; }
    char *end;
    long si = strtol(argv[2], &end, 10); if (*end) return 2;
    long m = strtol(argv[3], &end, 10); if (*end) return 2;
    if (m < 1 || m > (1L << 30) || si < 0 || si >= m) { fprintf(stderr, "bad shard\n"); return 2; }
    int d0 = 12; { int b = 0; while (((u128)1 << b) < (u128)16 * (u128)m) b++; if (b + 2 > d0) d0 = b + 2; }

    pow3[0] = 1; for (int i = 1; i < 20; i++) pow3[i] = pow3[i - 1] * 3;
    for (int s = 0; s < 19; s++) magic[s] = (uint64_t)((((u128)1 << 63) + pow3[s] - 1) / pow3[s]);

    /* P_k, Pbig, Pmod */
    { u128 P = 2; int huge = 0; u128 sat = (u128)1 << 125;
      for (int k = 1; k < MAXLV; k++) {
          Pbig[k] = huge || P > NN;
          Pmod[k] = refsat ? ((huge || P > sat) ? sat : P) : P;   /* P is exact mod 2^128 (wrapping) */
          if (!huge && P > ((u128)1 << 126) / 3) huge = 1;
          P *= 3;
      } }
    /* bit lengths of 3^k */
    { uint32_t w[32] = {1}; int nw = 1;
      for (int k = 1; k < MAXLV; k++) {
          uint64_t c = 0;
          for (int i = 0; i < nw; i++) { uint64_t t = (uint64_t)w[i] * 3 + c; w[i] = (uint32_t)t; c = t >> 32; }
          if (c) { if (nw == 32) die("bitlen overflow"); w[nw++] = (uint32_t)c; }
          int bl = 32 * (nw - 1); uint32_t x = w[nw - 1]; while (x) { bl++; x >>= 1; }
          bitlen3[k] = bl;
      } }
    for (int k = 0; k < MAXLV; k++) lowlimb[k] = k / 19;

    int Kb = 0; for (int k = 1; k < MAXLV; k++) if (!Pbig[k]) Kb = k;
    int nl = (Kb + MARGIN + 18) / 19; if (nl < MINNL) nl = MINNL;
    if (nl > NLMAX) die("N too large for limb table");
    if (d0 + 1 >= 19 * nl) die("d0 beyond precision");

    /* g_k = 2^(P_k) mod 3^(19 nl): g_1 = 4, g_{k+1} = g_k^3; E1 = g - 1, E2 = g^2 - 1 */
    { uint64_t g[FBN] = {4}, g2[FBN] = {0}, t[FBN] = {0};
      for (int k = 1; k <= Kb; k++) {
          mulmod_n(g, g, g2, nl);
          memcpy(Ek[0][k], g, nl * 8); memcpy(Ek[1][k], g2, nl * 8);
          for (int j = 0; j < 2; j++) {
              if (Ek[j][k][0] % 3 != 1) die("lemma check: g != 1 mod 3");
              Ek[j][k][0] -= 1;
              for (int n = 0; n < lowlimb[k]; n++) if (Ek[j][k][n]) die("lemma check: low limbs");
              uint64_t x = Ek[j][k][k / 19];
              if ((x % pow3[k % 19]) != 0) die("lemma check: not divisible by 3^k");
          }
          ck[k] = trit_of(Ek[0][k], k);
          if (ck[k] == 0) die("lemma check: c_k divisible by 3");
          if ((ck[k] * 2) % 3 != trit_of(Ek[1][k], k)) die("lemma check: c for g^2");
          mulmod_n(g2, g, t, nl); memcpy(g, t, sizeof t);
      } }

    printf("d0 %d\nnl %d\n", d0, nl);
    expand_fn expand = expand_tab[nl];

    /* phase 1: levels <= d0, recorded by shard 0 only */
    rec = (si == 0); stop_level = d0;
    for (int r = 0; r < 2; r++) {
        uint64_t *v = vbuf[1]; memset(v, 0, sizeof vbuf[1]); v[0] = r ? 2 : 1;
        if ((u128)r > NN) { if (rec) event(1, r, 1); continue; }
        if (trit_of(v, 0) == 2) { if (rec) event(1, r, 0); continue; }
        int e = alive_node(1, r);
        if (!e) expand(1, (u128)r, v);
        /* vbuf[1] is reused by r = 1 only after the r = 0 subtree is done */
    }
    /* phase 2: owned subtrees below d0 */
    qsort(col, ncol, sizeof *col, cmp_cnode);
    rec = 1; stop_level = -1;
    for (size_t t = (size_t)si; t < ncol; t += (size_t)m)
        if (!col[t].e) expand(d0, col[t].r, col[t].v);

    int top = 0; for (int k = 1; k < MAXLV; k++) if (counts[k]) top = k;
    printf("counts");
    for (int k = 1; k <= top; k++) printf(" %llu", (unsigned long long)counts[k]);
    printf("\n");
    qsort(exc, nexc, sizeof exc[0], cmp_u128);
    for (int i = 0; i < nexc; i++) { printf("E "); print_u128(exc[i]); printf("\n"); }
    printf("events %llu %016llx %016llx\n", (unsigned long long)ev_n, (unsigned long long)ev_sum,
           (unsigned long long)ev_xor);
    return 0;
}
