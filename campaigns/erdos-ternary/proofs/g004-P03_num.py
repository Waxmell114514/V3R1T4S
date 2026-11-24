"""g004-P03 numerics: A_lam(X) = #{0<=n<=X : 2 not in base-3 digits of lam*2^n} vs (X+1)^log3(2),
for 1 <= lam <= LMAX with 3 does not divide lam, 0 <= X <= XMAX.
Exact: a low-K-trit filter on lam*2^n mod 3^K, then a full base-3 check of the survivors.
The bound only needs checking at the n where the count jumps (A is a step function, RHS increasing)."""
import math, sys
LMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 200
XMAX = int(sys.argv[2]) if len(sys.argv) > 2 else 100000
K = 60
M = 3 ** K
ALPHA = math.log(2) / math.log(3)


def no_two(m):
    while m:
        m, d = divmod(m, 3)
        if d == 2:
            return False
    return True


def no_two_low(v):
    for _ in range(K):
        v, d = divmod(v, 3)
        if d == 2:
            return False
    return True


worst = (0.0, None)
fails = []
nlam = 0
for lam in range(1, LMAX + 1):
    if lam % 3 == 0:
        continue
    nlam += 1
    v = lam % M
    c = 0
    hits = []
    for n in range(XMAX + 1):
        if no_two_low(v) and no_two(lam << n):
            c += 1
            hits.append(n)
            r = c / (n + 1) ** ALPHA
            if r > worst[0]:
                worst = (r, (lam, n, c))
            if r > 1 + 1e-12:
                fails.append((lam, n, c))
        v = (v * 2) % M
    print(f"lam={lam} A({XMAX})={c} hits={hits}", flush=True)
print("LMAX", LMAX, "XMAX", XMAX, "lambdas", nlam)
print("worst ratio A(X)/(X+1)^alpha:", worst)
print("failures:", fails[:20], "count", len(fails))
