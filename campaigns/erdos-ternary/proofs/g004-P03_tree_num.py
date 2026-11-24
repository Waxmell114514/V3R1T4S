"""g004-P03 numerics, part 2 (the quantity the proof actually bounds, which is not trivially small):
L_{lam,k}(Y) = #{r < Y : the low k+1 trits of lam*2^r avoid 2}, for 0 <= Y <= 2*3^k.
Checks |T_{lam,k}| = L_{lam,k}(2*3^k) <= 2^k (and records whether = 2^k) and L_{lam,k}(Y) <= Y^log3(2) for all Y."""
import math, sys
LMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 200
KMAX = int(sys.argv[2]) if len(sys.argv) > 2 else 7
ALPHA = math.log(2) / math.log(3)

worst = (0.0, None)
fails = []
tree_eq = 0
tree_tot = 0
for lam in range(1, LMAX + 1):
    if lam % 3 == 0:
        continue
    for k in range(KMAX + 1):
        P = 2 * 3 ** k
        Mk = 3 ** (k + 1)
        v = lam % Mk
        c = 0
        for r in range(P):
            # check bound at Y = r (count of r' < r)
            if r > 0:
                rat = c / r ** ALPHA
                if rat > worst[0]:
                    worst = (rat, (lam, k, r, c))
                if rat > 1 + 1e-12:
                    fails.append((lam, k, r, c))
            w, ok = v, True
            for _ in range(k + 1):
                w, d = divmod(w, 3)
                if d == 2:
                    ok = False
                    break
            c += ok
            v = v * 2 % Mk
        rat = c / P ** ALPHA
        if rat > worst[0]:
            worst = (rat, (lam, k, P, c))
        if rat > 1 + 1e-12 or c > 2 ** k:
            fails.append((lam, k, P, c))
        tree_tot += 1
        tree_eq += (c == 2 ** k)
print("LMAX", LMAX, "KMAX", KMAX)
print("tree size == 2^k in", tree_eq, "of", tree_tot, "(lam,k) pairs")
print("worst ratio L(Y)/Y^alpha:", worst)
print("failures:", fails[:20], "count", len(fails))
