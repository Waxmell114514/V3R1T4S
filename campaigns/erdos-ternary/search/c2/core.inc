/* Hot path of the g1 (c2) engine, instantiated once per limb count NL (see engine.c).
 * v = 2^r mod 3^(19*NL) in NL base-3^19 limbs (least significant first).
 * expand(k, r, v): (k, r) is an alive, non-terminal node at level k whose alive count/events are already recorded.
 * It emits every event of the children and recurses into alive children.
 *
 * Mechanism (hypothesis g001-e02):
 *  - which child dies is decided from trit k of v and r mod 2 alone (lemma 3): child j has trit k equal to
 *    t + j*c_k*(2^r mod 3) mod 3, so no multi-limb work is done for dead or N-pruned children;
 *  - the j = 0 child reuses v unchanged; a j = 1, 2 child gets v + v*(g_k^j - 1) mod 3^L, where g_k^j - 1 is a
 *    multiple of 3^k, so its limbs below k/19 are zero and the product is a short (triangular) product;
 *  - once P_k > N only the j = 0 child can be <= N, so the subtree is a chain on a fixed v: a loop of trit reads. */

#define CAT2(a, b) a##b
#define CAT(a, b) CAT2(a, b)
#define EXPAND CAT(expand_, NL)
#define CHAIN CAT(chain_, NL)
#define MULADD CAT(muladd_, NL)

/* w = v + v*e mod 3^(19*NL), e has zero limbs below lo */
static inline void MULADD(const uint64_t *restrict v, const uint64_t *restrict e, int lo, uint64_t *restrict w) {
    for (int n = 0; n < lo; n++) w[n] = v[n];
    uint64_t carry = 0;
    for (int n = lo; n < NL; n++) {
        uint64_t acc = v[n] + carry;
        for (int j = lo; j <= n; j++) acc += v[n - j] * e[j];
        carry = acc / B19;
        w[n] = acc - carry * B19;
    }
}

/* chain from alive non-terminal node (k, r) with P_k > N: only j = 0 children can be <= N */
static void CHAIN(int k, u128 r, const uint64_t *v) {
    for (;;) {
        if (rec) { event(k + 1, r + Pmod[k], 1); event(k + 1, r + 2 * Pmod[k], 1); }
        if (k >= NL * 19) { chain_fallback(k, r); return; }
        if (trit_of(v, k) == 2) { if (rec) event(k + 1, r, 0); return; }
        k++;
        int e = alive_node(k, r);
        if (k == stop_level) { collect(k, r, v, NL, e); return; }
        if (e) return;
    }
}

static void EXPAND(int k, u128 r, const uint64_t *v) {
    if (Pbig[k]) { CHAIN(k, r, v); return; }
    int t = trit_of(v, k);
    int delta = (ck[k] * (r & 1 ? 2 : 1)) % 3;
    int dead = ((2 - t + 3) * delta) % 3;          /* t + dead*delta == 2 mod 3 (delta^-1 = delta) */
    uint64_t *w = vbuf[k + 1];
    for (int j = 0; j < 3; j++) {
        u128 rj = r + (u128)j * Pmod[k];             /* P_k <= N < 2^120: exact */
        if (rj > NN) { if (rec) event(k + 1, rj, 1); continue; }
        if (j == dead) { if (rec) event(k + 1, rj, 0); continue; }
        int e = alive_node(k + 1, rj);
        const uint64_t *vj = v;
        if (j) {
            if (e && k + 1 != stop_level) continue;   /* terminal exception: no value needed */
            MULADD(v, Ek[j - 1][k], lowlimb[k], w); vj = w;
        }
        if (k + 1 == stop_level) { collect(k + 1, rj, vj, NL, e); continue; }
        if (!e) EXPAND(k + 1, rj, vj);
    }
}

#undef EXPAND
#undef CHAIN
#undef MULADD
