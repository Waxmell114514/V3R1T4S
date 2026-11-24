"""g002-P04: Abram-Lagarias carry automaton (arXiv:1308.3133, Thm 3.1 / Thm 1.6) for C(1, M_1, ..., M_n).
State = tuple of carries (N_1..N_n); digit a in {0,1} (digit of lambda) allowed iff (N_i + M_i a) mod 3 in {0,1}
for every i; next carry N_i' = (N_i + M_i a) // 3.  dim_H C = log_3(spectral radius of reachable graph).
beta > 1 iff some SCC has more internal edges than vertices (a strongly connected digraph is a single cycle
iff #E == #V).  Theorem 1.7 (Lagarias) witness N exists iff the zero state has a cycle other than the 0-self-loop,
i.e. iff the SCC of the zero state has more than one vertex.
Usage: pathset.py EXPMAX CAP MODE   MODE in single|pair|triple:
  all C(1, 2^e1, ..., 2^er), 0 < e1 < ... < er <= EXPMAX, all e even (odd differences give {0}, Lagarias Lemma 4.1).
"""
import sys, itertools, math


def build(Ms, cap):
    start = (0,) * len(Ms)
    idx = {start: 0}; states = [start]; edges = []
    i = 0
    while i < len(states):
        s = states[i]; out = []
        for a in (0, 1):
            ok = True; nxt = []
            for N, M in zip(s, Ms):
                t = N + M * a
                if t % 3 == 2:
                    ok = False; break
                nxt.append(t // 3)
            if ok:
                nxt = tuple(nxt)
                if nxt not in idx:
                    if len(states) >= cap:
                        return None
                    idx[nxt] = len(states); states.append(nxt)
                out.append((a, idx[nxt]))
        edges.append(out); i += 1
    return states, edges


def sccs(n, edges):
    index = [None] * n; low = [0] * n; onst = [False] * n; st = []; comp = [-1] * n; c = 0; cnt = 0
    for root in range(n):
        if index[root] is not None:
            continue
        work = [(root, 0)]; index[root] = low[root] = cnt; cnt += 1; st.append(root); onst[root] = True
        while work:
            v, k = work[-1]
            if k < len(edges[v]):
                work[-1] = (v, k + 1); w = edges[v][k][1]
                if index[w] is None:
                    index[w] = low[w] = cnt; cnt += 1; st.append(w); onst[w] = True; work.append((w, 0))
                elif onst[w]:
                    low[v] = min(low[v], index[w])
            else:
                work.pop()
                if work:
                    low[work[-1][0]] = min(low[work[-1][0]], low[v])
                if low[v] == index[v]:
                    while True:
                        w = st.pop(); onst[w] = False; comp[w] = c
                        if w == v:
                            break
                    c += 1
    return comp, c


def spectral(nodes, edges, comp, cid, iters=4000):
    """Perron root of the SCC via power iteration on (A + I) (handles periodic SCCs)."""
    import numpy as np
    pos = {v: j for j, v in enumerate(nodes)}
    src = np.array([pos[v] for v in nodes for a, w in edges[v] if comp[w] == cid])
    dst = np.array([pos[w] for v in nodes for a, w in edges[v] if comp[w] == cid])
    x = np.ones(len(nodes)); lam = 1.0
    for _ in range(iters):
        y = x.copy(); np.add.at(y, src, x[dst])
        lam = y.max(); x = y / lam
    return lam - 1


def analyse(Ms, cap):
    g = build(Ms, cap)
    if g is None:
        return None
    states, edges = g; n = len(states)
    comp, c = sccs(n, edges)
    nv = [0] * c; ne = [0] * c
    for v in range(n):
        nv[comp[v]] += 1
        for a, w in edges[v]:
            if comp[w] == comp[v]:
                ne[comp[v]] += 1
    pos = [k for k in range(c) if ne[k] > nv[k]]
    beta = 1.0
    for k in pos:
        nodes = [v for v in range(n) if comp[v] == k]
        beta = max(beta, spectral(nodes, edges, comp, k))
    return n, c, len(pos), beta, nv[comp[0]], ne[comp[0]]


if __name__ == "__main__":
    E = int(sys.argv[1]); cap = int(sys.argv[2]); mode = sys.argv[3]
    r_ = {"single": 1, "pair": 2, "triple": 3}[mode]
    combos = itertools.combinations(range(2, E + 1, 2), r_)
    print(f"# mode={mode} EXPMAX={E} cap={cap} combos={math.comb(E // 2, r_)}", flush=True)
    ncomb = 0
    npos = ncap = maxst = 0
    for cb in combos:
        ncomb += 1
        r = analyse([2 ** e for e in cb], cap)
        if r is None:
            ncap += 1; print("CAPPED", cb, flush=True); continue
        n, c, p, beta, z, ze = r
        maxst = max(maxst, n)
        if p or mode != "triple":
            print(cb, f"states={n} sccs={c} posSCCs={p} beta={beta:.6f} dim={math.log(beta, 3):.6f} "
                      f"zeroSCC=(V{z},E{ze})", flush=True)
        if p:
            npos += 1
    print(f"# DONE combos={ncomb} positive={npos} capped={ncap} max_states={maxst}", flush=True)
