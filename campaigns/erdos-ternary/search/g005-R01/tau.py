"""g005-R01 candidate (2'): early switch to per-member handling.

usage: python3 tau.py K   (N = 2*3^K)
Low-digit tree (CERT). Unit cost model "units":
  * a multi-member alive node costs 1,
  * a single-member alive class (chain start) costs 1 (scan),
  * with threshold tau: a multi-member alive node whose class has T <= tau members n <= N is not expanded;
    it costs T units (each member handled on its own, like a chain start).
tau = 1 is the plain scan variant (B2 in tree_stats.py). Prints JSON {tau: units}.
"""
import json, sys

K = int(sys.argv[1]); N = 2 * 3 ** K
MODE = 60; M3 = 3 ** MODE
P = [0] + [2 * 3 ** (k - 1) for k in range(1, 80)]
G = [0] + [pow(2, P[k], M3) for k in range(1, 80)]
POW3 = [3 ** i for i in range(MODE + 1)]
TAUS = [1, 2, 3, 4, 6, 9, 27, 81, 243]


def main():
    cost = {t: 0 for t in TAUS}
    # each stack entry: (k, r, v, active) where active = set of tau indices still expanding above this node
    stack = [(1, 0, 1, len(TAUS))]   # r=1 at level 1 is a D leaf; never matters
    while stack:
        k, r, v, act = stack.pop()
        if r > N or (v // POW3[k - 1]) % 3 == 2:
            continue
        T = (N - r) // P[k] + 1           # members r + t*P_k <= N
        if T == 1:
            for i in range(act):
                cost[TAUS[i]] += 1
            continue
        # TAUS sorted ascending; taus with T <= tau stop here and pay T
        nact = act
        for i in range(act):
            if T <= TAUS[i]:
                nact = i; break
        for i in range(nact, act):
            cost[TAUS[i]] += T
        if nact == 0:
            continue
        for i in range(nact):
            cost[TAUS[i]] += 1
        g = G[k]; v1 = v * g % M3; v2 = v1 * g % M3
        stack.append((k + 1, r, v, nact)); stack.append((k + 1, r + P[k], v1, nact))
        stack.append((k + 1, r + 2 * P[k], v2, nact))
    print(json.dumps({'K': K, 'units': cost}))


if __name__ == '__main__':
    main()
