"""g005-R01: node counts of the CERT residue tree (verify/CERT.md) and of pruning variants.

usage: python3 tree_stats.py K   (N = 2*3^K)
Prints one JSON line. Exploration code only (not a result, CONSTRAINTS rule 11).

Baseline = every CERT *candidate* (alive + N-leaves + D-leaves), simulated by the CERT rules.
A node is multi-member if r + P_k <= N, single-member if r <= N < r + P_k.
For every single-member chain start (first single-member alive node) we record:
  low  = number of further low trits read (positions k, k+1, ...) until a 2   (scan length)
  high = number of top ternary digits of 2^r read until a 2 (Archimedean side)
"""
import json, sys
from decimal import Decimal, getcontext

K = int(sys.argv[1]); N = 2 * 3 ** K
MODE = 120                      # 2^r mod 3^MODE; fallback to longer powmod if no 2 found
M3 = 3 ** MODE

getcontext().prec = 60
LN3 = Decimal(3).ln()
ALPHA = Decimal(2).ln() / LN3                      # log_3 2
FB = 180
A_FIX = int(ALPHA * (Decimal(2) ** FB))            # alpha*2^FB, error < 2^-15 absolute on the 2^FB scale
TWO_FB = Decimal(2) ** FB


def top_digits(r, m):
    """leading m ternary digits of 2^r (list), exact for r < 400, else via frac(r*alpha) (NUMERICAL)."""
    if r < 400:
        s = []
        x = 1 << r
        while x:
            s.append(x % 3); x //= 3
        s.reverse()
        return s[:m]
    fx = (r * A_FIX) % (1 << FB)
    y = ((Decimal(fx) / TWO_FB) * LN3).exp()        # 3^frac in [1,3)
    out = []
    for _ in range(m):
        d = int(y); out.append(d); y = (y - d) * 3
    return out


def high_run(r, maxd=30):
    """digits of 2^r read from the top, up to and including the first 2 (maxd+1 if none among maxd)."""
    s = top_digits(r, maxd)
    for i, d in enumerate(s):
        if d == 2:
            return i + 1
    return maxd + 1


P = [0] + [2 * 3 ** (k - 1) for k in range(1, 200)]
G = [0] + [pow(2, P[k], M3) for k in range(1, 200)]
POW3 = [3 ** i for i in range(400)]


def trit(v, i):
    return (v // POW3[i]) % 3


def low_run(r, i, v):
    """trits read from position i upward until a 2 (count includes the 2); v = 2^r mod 3^MODE"""
    c = 0; mod = MODE
    while True:
        if i >= mod:
            mod *= 2; v = pow(2, r, 3 ** mod)
        c += 1
        if trit(v, i) == 2:
            return c
        i += 1


def main():
    st = dict(K=K, N=str(N), cand=0, alive=0, Nleaf=0, Dleaf=0, Eev=0, multi=0, single_alive=0,
              chains=0, lowsum=0, highsum=0, minsum=0, altsum=0, exceptions=[],
              high1_kill=0, high2_kill=0, high3_kill=0, high5_kill=0)
    lowhist = {}; highhist = {}; level_multi = {}; multi_D_children = 0
    stack = [(1, 1, 2), (1, 0, 1)]     # (k, r, v=2^r mod 3^MODE)
    while stack:
        k, r, v = stack.pop()
        st['cand'] += 1
        if r > N:
            st['Nleaf'] += 1; continue
        if trit(v, k - 1) == 2:
            st['Dleaf'] += 1; continue
        st['alive'] += 1
        if r + P[k] <= N:
            st['multi'] += 1; level_multi[k] = level_multi.get(k, 0) + 1
            g = G[k]
            v1 = v * g % M3; v2 = v1 * g % M3
            stack.append((k + 1, r + 2 * P[k], v2)); stack.append((k + 1, r + P[k], v1))
            stack.append((k + 1, r, v))
            continue
        # single-member class (only member r <= N): simulate the chain exactly by the CERT rules
        st['chains'] += 1
        if r in (0, 2, 8):
            kk = k
            while not 3 ** kk > 2 ** r:
                assert trit(v, kk - 1) != 2
                st['cand'] += 3; st['Nleaf'] += 2; st['alive'] += 1; st['single_alive'] += 1
                kk += 1
            st['single_alive'] += 1; st['Eev'] += 1; st['exceptions'].append(r)
            continue
        L = low_run(r, k, v)             # trits k, k+1, ..., k+L-1; the last one is 2
        # alive chain nodes: levels k .. k+L-1 (L nodes); each gets 3 children: 1 continues, 2 are N-leaves;
        # the child at level k+L (trit k+L-1) is the D-leaf.
        st['alive'] += L - 1; st['single_alive'] += L
        st['cand'] += 3 * L; st['Nleaf'] += 2 * L; st['Dleaf'] += 1
        h = high_run(r)
        st['lowsum'] += L; st['highsum'] += h; st['minsum'] += min(L, h)
        st['altsum'] += (2 * L - 1) if L <= h else 2 * h     # low, high, low, high, ...
        for m in (1, 2, 3, 5):
            if h <= m:
                st['high%d_kill' % m] += 1
        lowhist[L] = lowhist.get(L, 0) + 1
        hk = min(h, 31); highhist[hk] = highhist.get(hk, 0) + 1
    Kf = max(k for k in range(1, 199) if P[k] <= N)
    st['Kf'] = Kf
    st['lowhist'] = dict(sorted(lowhist.items())); st['highhist'] = dict(sorted(highhist.items()))
    st['level_multi'] = dict(sorted(level_multi.items()))
    print(json.dumps(st))


if __name__ == '__main__':
    main()
