# g002-L02 — skeptic REPRODUCE

Scope: only `panel/g002-L02/claim/` (CLAIM.md, Counting.lean, Statement.lean), the Lean project
`campaigns/erdos-ternary/lean`, and `verify/lean_audit.py`. No proofs/, reports/, ledger/ or other panel files read.

## 1. Rerun of Lean build and audit

Copy identity:
```
$ diff panel/g002-L02/claim/Counting.lean lean/ErdosTernary/Counting.lean && echo IDENTICAL
IDENTICAL
$ sha256sum panel/g002-L02/claim/Counting.lean lean/ErdosTernary/Counting.lean
22e8ad7abfa0688cf111421ddc831e5c91979fcc91bba2753e524c873c71e54c  panel/g002-L02/claim/Counting.lean
22e8ad7abfa0688cf111421ddc831e5c91979fcc91bba2753e524c873c71e54c  lean/ErdosTernary/Counting.lean
$ diff verify/Statement.lean panel/g002-L02/claim/Statement.lean && echo STMT_SAME
STMT_SAME
```
(There is no `lean/ErdosTernary/Statement.lean`; the claim's Statement.lean equals the frozen `verify/Statement.lean`.
The theorem does not use `Statement`/`UpTo`; it is stated directly with `Nat.digits 3 (2 ^ n)`.)

`cd lean && lake build` (tail; only "module system" import warnings):
```
⚠ [4218/4225] Replayed ErdosTernary.Counting
⚠ [4219/4225] Ran ErdosTernary.Counting:irArts
Build completed successfully (4225 jobs).
```
`python3 verify/lean_audit.py ErdosTernary.Counting ErdosTernary.Counting.card_noTwo_le_succ_rpow`:
```
Build completed successfully (4215 jobs).
WARN ErdosTernary/Checker.lean: native_decide
'ErdosTernary.Counting.card_noTwo_le_succ_rpow' depends on axioms: [propext, Classical.choice, Quot.sound]
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
```
The `native_decide` warning is for a different file (Checker.lean); the audited theorem's axiom set is tier A.
`grep sorry|axiom|native_decide` in Counting.lean: only a comment saying "no native_decide". The Lean statement
(lines 374-376) is exactly the one in CLAIM.md:
`(((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card : ℝ) ≤ ((X : ℝ) + 1) ^ Real.logb 3 2`.

## 2. Independent paper proof

Let α = log_3 2 ∈ (0,1), f(y) = y^α (increasing on [0,∞), f(3^j) = 2^j). For k ≥ 0 put Q = 3^k, P = 2Q and
L_k(Y) = #{0 ≤ r < Y : the k+1 lowest trits of 2^r (i.e. 2^r mod 3^{k+1}, padded with zeros) contain no 2}.

**Fact 1 (period).** ord of 2 mod 3^{k+1} divides 2·3^k (it is φ(3^{k+1})), so goodness of r at level k depends only
on r mod P, and L_k(P + s) = L_k(P) + L_k(s) for 0 ≤ s ≤ P.

**Fact 2 (lifting).** v_3(4^{3^k} − 1) = v_3(4−1) + k = k+1 (lifting the exponent, p = 3 odd, 3 | 4−1), so
2^P = 1 + 3^{k+1}u with 3 ∤ u. For r0 good at level k and j ∈ {0,1,2}:
2^{r0 + jP} ≡ 2^{r0} + j·u·2^{r0}·3^{k+1} (mod 3^{k+2}); the low k+1 trits are unchanged, and trit k+1 runs through
all three residues as j varies (u·2^{r0} is a unit mod 3). Hence exactly 2 of the 3 lifts of r0 to [0, 3P) are good at
level k+1, and residues bad at level k have only bad lifts. So G_{k+1} := L_{k+1}(2·3^{k+1}) = 2·G_k, and with
G_0 = L_0(2) = 1 (2^0 = 1 has trit 1, 2^1 = 2 has trit 2) we get G_k = 2^k.

**Fact 3 (monotonicity).** L_{k+1}(Y) ≤ L_k(Y) (more conditions) and L_k is nondecreasing in Y.

**Lemma.** For all k and 0 ≤ Y ≤ 2·3^k: L_k(Y) ≤ Y^α.

*Base k = 0:* L_0(0) = 0 ≤ 0, L_0(1) = 1 ≤ 1, L_0(2) = 1 ≤ 2^α ≈ 1.587.

*Step k → k+1* (Q = 3^k; now Y ≤ 2·3^{k+1} = 6Q). Three cases.
- (a) Y ≤ 2Q: L_{k+1}(Y) ≤ L_k(Y) ≤ Y^α by Fact 3 and IH.
- (b) 2Q < Y < 3Q, write Y = 2Q + s with 0 < s < Q. By Facts 3, 1, 2 and IH (s < Q ≤ 2Q):
  L_{k+1}(Y) ≤ L_k(2Q + s) = 2^k + L_k(s) ≤ 2^k + s^α.
  It remains to show 2^k + s^α ≤ (2Q + s)^α. Divide by Q^α = 2^k and put t = s/Q ∈ (0,1): need
  g(t) := (2+t)^α − t^α − 1 ≥ 0. Here g'(t) = α[(2+t)^{α−1} − t^{α−1}] < 0 for t > 0 (since α − 1 < 0 and
  2+t > t), so g is strictly decreasing on (0,1] and g(t) > g(1) = 3^α − 2 = 0. (So the inequality is strict inside
  the interval and tight only at s = Q, where Y = 3^{k+1}; at s → 0 the slack is 2^α − 1 > 0.) Note the naive range
  t up to 2 would fail (1 + 2^α ≈ 2.587 > 4^α ≈ 2.40), which is why case (c) must be handled differently.
- (c) 3Q ≤ Y ≤ 6Q: L_{k+1}(Y) ≤ L_{k+1}(6Q) = 2^{k+1} = (3^{k+1})^α ≤ Y^α (Facts 2, 3, f increasing).

**Theorem.** A(X) ≤ (X+1)^α. Take k = X; then X+1 ≤ 2·3^X. If 2^n has no digit 2, its lowest X+1 trits (with zero
padding; 0 ≠ 2) have no 2, so A(X) ≤ L_X(X+1) ≤ (X+1)^α. Equality: A(0) = 1 = 1^α; A(2) = 2 = 3^α
(2^0 = 1, 2^1 = 2 has a 2, 2^2 = 4 = 11_3). All inequalities checked; I find no gap.

## 3. Independent computation

Own script (Python, no project code): `indep.py` (scratchpad). For k = 0..12 it walks r = 0..2·3^k − 1 keeping
2^r mod 3^{k+1}, checks the k+1 low trits, and tests L_k(Y) ≤ Y^α for every Y in [0, 2·3^k] using log comparison with
an exact tie test (a tie is accepted only if L = 2^j, Y = 3^j; any other near-tie aborts). For A(X) it screens 2^n mod
3^40 and computes the full base-3 expansion of 2^n whenever the low 40 trits are 2-free (exact for small n).
Output of `python3 -I indep.py 12 100000` (2.4 s):
```
k= 0 P=      2 |G_k|=L_k(P)=    1 (2^k=1) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1] 2^P%M==1:True
k= 1 P=      6 |G_k|=L_k(P)=    2 (2^k=2) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
k= 2 P=     18 |G_k|=L_k(P)=    4 (2^k=4) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3, 9] 2^P%M==1:True
k= 3 P=     54 |G_k|=L_k(P)=    8 (2^k=8) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
k= 4 P=    162 |G_k|=L_k(P)=   16 (2^k=16) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
k= 5 P=    486 |G_k|=L_k(P)=   32 (2^k=32) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
k= 6 P=   1458 |G_k|=L_k(P)=   64 (2^k=64) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
k= 7 P=   4374 |G_k|=L_k(P)=  128 (2^k=128) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
k= 8 P=  13122 |G_k|=L_k(P)=  256 (2^k=256) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
k= 9 P=  39366 |G_k|=L_k(P)=  512 (2^k=512) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
k=10 P= 118098 |G_k|=L_k(P)= 1024 (2^k=1024) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
k=11 P= 354294 |G_k|=L_k(P)= 2048 (2^k=2048) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
k=12 P=1062882 |G_k|=L_k(P)= 4096 (2^k=4096) allY_ok=True max L/Y^a=1.000000 at Y=1 ties(Y)=[0, 1, 3] 2^P%M==1:True
  equality A(0)=1=(X+1)^a
  equality A(2)=2=(X+1)^a
A(X): N=100000 n with no digit 2 = [0, 2, 8]; A(N)=3; all X<=N ok=True; max A/(X+1)^a=1.000000 at X=0; full expansions computed=3
```
Ties occur exactly where expected (Y = 0, 1, 3, and 9 for k = 2, i.e. Y = 3^j with L = 2^j), the maximum ratio is
exactly 1, G_k = 2^k for all k ≤ 12, and the only n ≤ 10^5 with 2^n free of digit 2 are 0, 2, 8, so A(X) ≤ (X+1)^α
holds on [0, 10^5] with equality only at X = 0 and X = 2.

## Verdict

Lean build and tier-A audit reproduce; the panel copy is byte-identical to the project file; the statement matches the
claim; the independent paper proof (including the 2·3^k < Y < 3^{k+1} case, which is tight only at the endpoint
3^{k+1}) goes through; the independent computations agree. Novelty and scope are outside this role.

pass: true
