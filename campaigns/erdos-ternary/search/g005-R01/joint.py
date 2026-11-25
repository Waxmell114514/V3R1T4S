"""g005-R01 candidate (4): joint low+high digit tree (combine trailing and leading ternary digits).

usage: python3 joint.py K A0     (N = 2*3^K; first A0 low trits are used by every schedule)

A node is a set of n <= N sharing a pattern of `a` low trits and `b` leading trits of 2^n, none of them 2.
A schedule decides, stage by stage, whether the next split reads one more low trit or one more leading trit.
Cost model ("units", same as tau.py / tree_stats.py B2): every nonempty node with >= 2 members costs 1;
a node with exactly 1 member costs 1 and is finished by a per-member scan (not expanded further).
Emptiness of a child is taken as FREE (oracle). In the low-only tree it is free (r > N); for a leading-digit
split it is not (one must prove no member of the class has frac(n log_3 2) in an interval), so this
measurement is generous to the joint scheme.

Leading digits: x = frac(n*log_3 2) from a 128-bit fixed-point log_3 2, then 3^(x+BT-1) in numpy longdouble
(64-bit mantissa) -> top BT digits. NUMERICAL; the number of n within 1e-6 of a digit boundary is reported.
"""
import json, sys
from decimal import Decimal, getcontext
import numpy as np

K = int(sys.argv[1]); A0 = int(sys.argv[2]); N = 2 * 3 ** K
LM = 39; M3 = 3 ** LM                       # low residues mod 3^39 < 2^63
BT = 24                                     # leading digits computed
getcontext().prec = 60
ALPHA = Decimal(2).ln() / Decimal(3).ln()
A128 = int(ALPHA * (Decimal(2) ** 128))
P = [0] + [2 * 3 ** (k - 1) for k in range(1, 60)]


def survivors():
    """all n <= N whose low A0 trits of 2^n have no 2, with v = 2^n mod 3^39."""
    cls = [(0, 1)]                           # level-1 alive class r=0 (r=1 dies)
    for k in range(1, A0):
        g = pow(2, P[k], M3); new = []
        for r, v in cls:
            for j in range(3):
                rr = r + j * P[k]; vv = v * pow(g, j, M3) % M3
                if (vv // 3 ** k) % 3 != 2:
                    new.append((rr, vv))
        cls = new
    ns = []; vs = []
    g = pow(2, P[A0], M3)
    for r, v in cls:
        n = r
        while n <= N:
            ns.append(n); vs.append(v)
            n += P[A0]; v = v * g % M3
    return ns, vs


def main():
    ns, vs = survivors()
    n = np.array(ns, dtype=np.uint64); v = np.array(vs, dtype=np.uint64)
    x_hi = np.array([((m * A128) & ((1 << 128) - 1)) >> 64 for m in ns], dtype=np.uint64)
    x = x_hi.astype(np.longdouble) / np.longdouble(2.0) ** 64
    y = np.exp((x + np.longdouble(BT - 1)) * np.log(np.longdouble(3)))
    T = np.floor(y)
    near = int(np.sum(np.minimum(y - T, T + 1 - y) < 1e-6))
    T = T.astype(np.uint64)
    pow3 = [np.uint64(3 ** i) for i in range(LM + 1)]

    def low_d(i):   # trit i (0-based from bottom) of 2^n
        return (v // pow3[i]) % np.uint64(3)

    def high_d(j):  # j-th leading digit (1-based)
        return (T // pow3[BT - j]) % np.uint64(3)

    results = {}
    schedules = {'low': 0.0, 'h1/4': 0.25, 'h1/3': 1 / 3, 'h1/2': 0.5, 'h2/3': 2 / 3, 'high': 1.0}
    for name, th in schedules.items():
        alive = np.ones(len(ns), dtype=bool)
        a = A0; b = 0; units = 0; hacc = 0.0; stages = 0
        # stage 0: the A0-low-trit pattern; count its nodes the same way as later stages
        lowkey = v % pow3[a]; highkey = np.zeros(len(ns), dtype=np.uint64)
        units_pre = 0
        while alive.any():
            idx = np.nonzero(alive)[0]
            keys = np.stack([lowkey[idx], highkey[idx]], axis=1)
            _, inv, cnt = np.unique(keys, axis=0, return_inverse=True, return_counts=True)
            inv = inv.ravel()
            units += len(cnt)
            single = cnt[inv] == 1
            alive[idx[single]] = False
            # next split
            hacc += th
            if hacc >= 1.0 - 1e-12 and b < BT:
                hacc -= 1.0; b += 1
                d = high_d(b); highkey = highkey * np.uint64(3) + d
            else:
                if a >= LM:
                    raise SystemExit('low depth exhausted')
                d = low_d(a); a += 1; lowkey = v % pow3[a]
            alive &= (d != 2)
            stages += 1
        results[name] = dict(units=units, final_a=a, final_b=b, stages=stages)
    # baseline structure count for reference: multi-member nodes + chains of the low tree above level A0
    print(json.dumps({'K': K, 'A0': A0, 'members_after_A0': len(ns), 'near_boundary': near,
                      'schedules': results}))


if __name__ == '__main__':
    main()
