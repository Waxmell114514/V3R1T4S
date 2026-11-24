/* Frozen reference tree search for the Erdős ternary conjecture (see verify/CERT.md).
 * Correctness over speed. Values 2^r mod 3^(40*L) are kept in L base-3^40 limbs.
 * Usage: tree_ref <N decimal> <i> <m>
 * Prints: line "d0 <d0>", line "counts c1 c2 ...", lines "E <r>", line "events <n> <sumhex> <xorhex>".
 * Exit 3 if a node exceeds the supported depth (40*L - 1). */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>

typedef unsigned __int128 u128;
#define L 6
#define MAXK (40 * L - 1)
static const uint64_t B = 12157665459056928801ULL; /* 3^40 */
typedef struct { uint64_t l[L]; } big;

static u128 NN;
static uint64_t ev_count, ev_sum, ev_xor;
static uint64_t counts[MAXK + 2];
static int maxlevel;
static u128 Pk[MAXK + 2];      /* P_k mod 2^128 (exact while PkBig[k] == 0) */
static int PkBig[MAXK + 2];    /* 1 iff the true P_k exceeds 2^120 > N */
static big Gk[MAXK + 2];       /* 2^(P_k) mod 3^(40L) */
static uint64_t pow3[41];

static void mulmod(const big *x, const big *y, big *out) {
    u128 acc[L + 1];
    memset(acc, 0, sizeof acc);
    for (int a = 0; a < L; a++) {
        if (!x->l[a]) continue;
        for (int b = 0; a + b < L; b++) {
            u128 p = (u128)x->l[a] * y->l[b];
            acc[a + b] += (uint64_t)(p % B);
            if (a + b + 1 < L) acc[a + b + 1] += (uint64_t)(p / B);
        }
    }
    u128 carry = 0;
    for (int i = 0; i < L; i++) {
        u128 t = acc[i] + carry;
        out->l[i] = (uint64_t)(t % B);
        carry = t / B;
    }
}

static int trit(const big *v, int idx) { return (int)((v->l[idx / 40] / pow3[idx % 40]) % 3); }

static uint64_t mix(uint64_t z) {
    z += 0x9E3779B97F4A7C15ULL;
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL;
    return z ^ (z >> 31);
}
static void event(int k, u128 r, int code) {
    uint64_t h = mix(mix(mix((uint64_t)r) ^ (uint64_t)(r >> 64)) ^ (uint64_t)(4 * k + code));
    ev_count++; ev_sum += h; ev_xor ^= h;
}
static void print_u128(u128 x) {
    char buf[64]; int n = 0;
    if (!x) { putchar('0'); return; }
    while (x) { buf[n++] = '0' + (int)(x % 10); x /= 10; }
    while (n) putchar(buf[--n]);
}
/* 3^k > 2^r ? (only possible when r < 2k) */
static int fully_known(int k, u128 r) {
    if (r >= (u128)(2 * k)) return 0;
    return (double)k * log2(3.0) > (double)r;
}

typedef struct { int k; u128 r; big v; } node;  /* v = 2^r mod 3^(40L) */

/* classify candidate; returns 1 if alive, sets *isE */
/* gt = 1: the true r is known to exceed N (r itself may be the true value mod 2^128) */
static int classify(int k, u128 r, const big *v, int *isE, int record, int gt) {
    *isE = 0;
    if (gt || r > NN) { if (record) event(k, r, 1); return 0; }
    if (k - 1 > MAXK) { fprintf(stderr, "DEPTH\n"); exit(3); }
    if (trit(v, k - 1) == 2) { if (record) event(k, r, 0); return 0; }
    if (record) { counts[k]++; if (k > maxlevel) maxlevel = k; }
    if (fully_known(k, r) && (PkBig[k] || r + Pk[k] > NN)) {
        *isE = 1;
        if (record) { event(k, r, 2); printf("E "); print_u128(r); printf("\n"); }
    }
    return 1;
}

static node *stack;
static size_t sp, scap;
static void push(node *n) {
    if (sp == scap) { scap = scap ? 2 * scap : 1024; stack = realloc(stack, scap * sizeof(node)); }
    stack[sp++] = *n;
}

/* expand subtree under alive node (k,r,v) with E flag, DFS, recording everything below level k */
static void dfs(node *root, int rootE) {
    size_t base = sp;
    /* stack entries are alive nodes whose children are not yet generated; E flag kept in sign of k */
    node t = *root; if (rootE) t.k = -t.k; push(&t);
    while (sp > base) {
        node cur = stack[--sp];
        int e = cur.k < 0; int k = e ? -cur.k : cur.k;
        if (e) continue; /* terminal exception node */
        if (k + 1 > MAXK + 1) { fprintf(stderr, "DEPTH\n"); exit(3); }
        big v = cur.v;
        for (int j = 0; j < 3; j++) {
            if (j > 0) { big w; mulmod(&v, &Gk[k], &w); v = w; }
            u128 r = cur.r + (u128)j * Pk[k];
            int isE;
            if (classify(k + 1, r, &v, &isE, 1, j > 0 && PkBig[k])) {
                node c; c.k = isE ? -(k + 1) : (k + 1); c.r = r; c.v = v; push(&c);
            }
        }
    }
}

static int cmp_node(const void *a, const void *b) {
    const node *x = a, *y = b;
    return x->r < y->r ? -1 : x->r > y->r;
}

static u128 parse_u128(const char *s) {
    u128 x = 0;
    for (; *s; s++) { if (*s < '0' || *s > '9') { fprintf(stderr, "bad N\n"); exit(2); } x = x * 10 + (*s - '0'); }
    return x;
}

int main(int argc, char **argv) {
    if (argc != 4) { fprintf(stderr, "usage: tree_ref N i m\n"); return 2; }
    NN = parse_u128(argv[1]);
    if (NN >= ((u128)1 << 120)) { fprintf(stderr, "N too large\n"); return 2; }
    int si = atoi(argv[2]), m = atoi(argv[3]);
    if (m < 1 || si < 0 || si >= m) { fprintf(stderr, "bad shard\n"); return 2; }
    int d0 = 12; { int c = (int)ceil(log2(16.0 * m)) + 2; if (c > d0) d0 = c; }
    pow3[0] = 1; for (int i = 1; i <= 40; i++) pow3[i] = pow3[i - 1] * 3;
    /* P_k and G_k = 2^(P_k) */
    big two; memset(&two, 0, sizeof two); two.l[0] = 2;
    Pk[1] = 2;
    for (int k = 2; k <= MAXK + 1; k++) {
        Pk[k] = Pk[k - 1] * 3;  /* wraps mod 2^128, as CERT.md hashes r mod 2^128 */
        PkBig[k] = PkBig[k - 1] || Pk[k - 1] > (((u128)1 << 120) / 3);
    }
    mulmod(&two, &two, &Gk[1]); /* 2^2 */
    for (int k = 2; k <= MAXK + 1; k++) { big a, b; mulmod(&Gk[k - 1], &Gk[k - 1], &a); mulmod(&a, &Gk[k - 1], &b); Gk[k] = b; }
    printf("d0 %d\n", d0);
    /* BFS prefix up to level d0; events recorded only by shard 0 */
    int rec0 = (si == 0);
    size_t cap = 1 << 22; node *lvl = malloc(cap * sizeof(node)), *nxt = malloc(cap * sizeof(node));
    size_t nl = 0, nn;
    big one; memset(&one, 0, sizeof one); one.l[0] = 1;
    /* level 1 candidates r=0 (v=1), r=1 (v=2) */
    { int isE; node c;
      c.r = 0; c.v = one; if (classify(1, 0, &one, &isE, rec0, 0)) { c.k = isE ? -1 : 1; lvl[nl++] = c; }
      c.r = 1; c.v = two; if (classify(1, 1, &two, &isE, rec0, 0)) { c.k = isE ? -1 : 1; lvl[nl++] = c; } }
    for (int k = 1; k < d0; k++) {
        nn = 0;
        for (size_t t = 0; t < nl; t++) {
            int e = lvl[t].k < 0; big v = lvl[t].v;
            if (e) continue;
            for (int j = 0; j < 3; j++) {
                if (j > 0) { big w; mulmod(&v, &Gk[k], &w); v = w; }
                u128 r = lvl[t].r + (u128)j * Pk[k];
                int isE;
                if (classify(k + 1, r, &v, &isE, rec0, j > 0 && PkBig[k])) {
                    if (nn == cap) { fprintf(stderr, "prefix too big\n"); return 2; }
                    node c; c.k = isE ? -(k + 1) : (k + 1); c.r = r; c.v = v; nxt[nn++] = c;
                }
            }
        }
        node *tmp = lvl; lvl = nxt; nxt = tmp; nl = nn;
    }
    qsort(lvl, nl, sizeof(node), cmp_node);
    for (size_t t = si; t < nl; t += m) {
        int e = lvl[t].k < 0; node root = lvl[t]; root.k = d0;
        dfs(&root, e);
    }
    printf("counts");
    for (int k = 1; k <= maxlevel; k++) printf(" %llu", (unsigned long long)counts[k]);
    printf("\n");
    printf("events %llu %016llx %016llx\n", (unsigned long long)ev_count,
           (unsigned long long)ev_sum, (unsigned long long)ev_xor);
    return 0;
}
