"""g002-L02 numerics: residue-tree counting bounds for A(X) = #{n <= X : 2 not a ternary digit of 2^n}.
Exploration only (not a result). Run: python3 proofs/g002-L02_num.py"""
import bisect, math

a = math.log(2) / math.log(3)
K = 13          # P_13 = 2*3^12 = 1062882 > 10^6
XMAX = 10**6


def free(m, k):
    for _ in range(k):
        if m % 3 == 2:
            return False
        m //= 3
    return True


def kmin(X):  # minimal k >= 1 with X < P_k = 2*3^(k-1)
    k = 1
    while X >= 2 * 3**(k - 1):
        k += 1
    return k


T = {}
for k in range(1, K + 1):
    P, M = 2 * 3**(k - 1), 3**k
    x, s = 1, []
    for r in range(P):
        if free(x, k):
            s.append(r)
        x = x * 2 % M
    T[k] = s
    assert len(s) == 2**(k - 1), (k, len(s))
print("|T_k| = 2^(k-1) verified for k = 1..%d" % K)

best1 = (0, None)
best3 = (0, None)
best3b = (0, None)
for X in range(1, XMAX + 1):
    k = kmin(X)
    r = 2**(k - 1) / X**a
    if r > best1[0]:
        best1 = (r, X)
    c = bisect.bisect_right(T[k], X)
    if c / X**a > best3[0]:
        best3 = (c / X**a, X)
    if c / (X + 1)**a > best3b[0]:
        best3b = (c / (X + 1)**a, X)
print("(1) sup_{1<=X<=1e6} 2^(k(X)-1)/X^a = %.6f at X=%d ; 2^(1-a) = %.6f" % (best1[0], best1[1], 2**(1 - a)))
print("(3) sup_{1<=X<=1e6} #(T_k(X) cap [0,X])/X^a = %.6f at X=%d" % best3)
print("(3b) sup_{1<=X<=1e6} #(T_k(X) cap [0,X])/(X+1)^a = %.6f at X=%d" % best3b)

best2 = (0, None)
for X in range(1, XMAX + 1):
    m = min(-(-(X + 1) // (2 * 3**(k - 1))) * 2**(k - 1) for k in range(1, K + 1))
    if m / X**a > best2[0]:
        best2 = (m / X**a, X)
print("(2) sup_{1<=X<=1e6} min_k ceil((X+1)/P_k) 2^(k-1) / X^a = %.6f at X=%d" % best2)

for X in [10, 100, 1000, 10**4, 10**5, 10**6]:
    print("X=%d  A_13(X)=%d  X^a=%.2f" % (X, bisect.bisect_right(T[13], X), X**a))


def tern(m):
    d = []
    while m:
        d.append(m % 3)
        m //= 3
    return d


print("exceptions n < 3000:", [n for n in range(3000) if 2 not in tern(2**n)])
