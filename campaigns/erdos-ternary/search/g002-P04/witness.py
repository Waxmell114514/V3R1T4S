"""Shortest Lagarias Thm-1.7 integer witness N for C(1, 2^e1, ..., 2^er): a cycle 0 -(digit 1)-> ... -> 0 in the
Abram-Lagarias carry automaton.  Prints N, its base-3 digits, and an independent check that N and every N*2^ei
have base-3 digits in {0,1}.  Usage: witness.py e1 e2 ..."""
import sys
from collections import deque
from pathset import build


def digits3(x):
    d = []
    while x:
        d.append(x % 3); x //= 3
    return d


Ms = [2 ** int(e) for e in sys.argv[1:]]
states, edges = build(Ms, 10 ** 6)
first = [w for a, w in edges[0] if a == 1]
if not first:
    print("no digit-1 edge from 0"); sys.exit()
s = first[0]
prev = {s: None}; q = deque([s]); found = s == 0
while q and not found:
    v = q.popleft()
    for a, w in edges[v]:
        if w not in prev:
            prev[w] = (v, a); q.append(w)
            if w == 0:
                found = True; break
if 0 not in prev:
    print("no witness (0 not reachable after a 1)"); sys.exit()
digs = []; v = 0
while v != s:
    p, a = prev[v]; digs.append(a); v = p
digs.append(1); digs.reverse()            # digits a_0 = 1, a_1, ... (least significant first)
N = sum(a * 3 ** i for i, a in enumerate(digs))
print("exps", sys.argv[1:], "N =", N, "digits(lsb first) =", "".join(map(str, digs)))
for M in [1] + Ms:
    d = digits3(N * M)
    print(f"  N*{M}: {len(d)} digits, max digit {max(d)}")
