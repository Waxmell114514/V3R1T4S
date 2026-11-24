# g003-C04 skeptic REPRODUCE

- claim/CheckerKernel.lean == lean/ErdosTernary/CheckerKernel.lean: IDENTICAL (diff empty)
- claim/Statement.lean == verify/Statement.lean: IDENTICAL
- sha256 CheckerKernelUpTo20.lean = a359976ee6e77097cb8e3bc66420b134cca71f8c47228f04caae81d94558b787, matches generated_files.sha256
  (CheckerKernelUpTo16.lean c20d05dd...7da6 also matches)
- Pre-build: no CheckerKernelUpTo20.* outputs under .lake/build/lib/lean/ErdosTernary/Records/ (so fresh build)
- Regeneration: copied tools/gen_kernel_upto.py to scratch (its output path is __file__/../../lean/..., so a copy
  writes only into scratch), ran `python3 tools/gen_kernel_upto.py 20` (defaults LIMIT=30000 K=64), 54.6 s:
  "nodes 12585293 {'leaves': 1024, 'inner': 511, 'max_leaf': 25828}". Output byte-IDENTICAL to committed
  Records/CheckerKernelUpTo20.lean (diff -q silent, same sha256 a359976e...).
- Independent C program (own code): 2^n mod 3^40 iterated by doubling for n=1..2*3^20=6973568802, scan trits;
  n<=63 exact. 0 exceptions with 8<n<=N; 501 n had no 2 in low 40 trits, all resolved by own Python
  pow(2,n,3^80) (first 2 at trit position <=56). Sanity run N=100 reports exactly exceptions n=2, n=8. 26 s.
- lake build (fresh, nice, LEAN_NUM_THREADS=1): `✔ [2142/2143] Built ErdosTernary.Records.CheckerKernelUpTo20 (882s)`, `Build completed successfully (2143 jobs).`, exit 0; wall 883 s (date stamps).

## Paper re-derivation (soundness)
Node (fuel, q=3^i, r, m, g) stands for the class C(i,r) = {r + t*2*3^i : t >= 0}; invariants m = 2^r mod M,
g = 2^(2*3^i) mod M, 3^(i+fuel) | M (M = 3^K; roots i=0, fuel=K, r=0,1, m=1,2, g=4 mod 3^K).
exploreK = true at fuel+1 holds by one of four disjuncts, each giving "every n in C(i,r) with 8<n<=N has a 2":
1. N < r: no member is <= N (vacuous).
2. m/q%3 = 2: since 3^(i+1) | M, trit i of (2^r mod M) is trit i of 2^r; by pow_class_mod
   (ord of 2 mod 3^(i+1) is 2*3^i) every 2^n, n in C(i,r), has the same low i+1 trits, so trit i = 2 and
   two_mem_digits_of gives 2 in Nat.digits 3 (2^n).
3. N < r+2q and r <= 8: the only member <= N is n = r <= 8, excluded by 8 < n.
4. all three children true: C(i,r) = C(i+1,r) u C(i+1,r+2q) u C(i+1,r+4q) (split t by t mod 3); children's
   m, g are m, m*g, m*g*g and g^3 mod M, which are exactly 2^r, 2^(r+2*3^i), 2^(r+4*3^i), 2^(2*3^(i+1)) mod M;
   fuel drops by 1 so 3^(i+1+fuel) | M persists; induction hypothesis applies.
Fuel 0 returns false, so it can never prove anything. checkK_sound: n = n%2 + (n/2)*2*3^0, so the two roots
cover all n. This is exactly the Lean proof of exploreK_sound / checkK_sound (read in full, no gaps seen).

## Assembly forces every subtree to be checked
exploreK_of_children: from = true of the three children (with exactly the child arguments 3q, r / r+2q / r+4q,
m / m*g%M / m*g%M*g%M, g*g%M*g%M) derive = true of the parent at fuel+1, by unfolding the definition. Each
generated theorem's statement is a closed `exploreK <numerals> = true`; it is proved either by `decide +kernel`
(kernel fully evaluates that subtree) or by exploreK_of_children applied to the three named child theorems,
where the kernel must check the child numerals are defeq to the parent expressions. checkK_of_roots needs both
roots, and upToK_20 = checkK_sound (K:=64) (checkK_of_roots _ _ n20_0 n20_1). So the proof term of upToK_20
references every leaf; any omitted/false leaf would be an unproved name or a failed decide, i.e. build error.
The file has 1535 generated theorems + upToK_20 = 1536 (1024 leaves + 511 inner = 1535, matching header);
grep shows no native_decide/sorry/axiom/set_option/macro/instance in it or in CheckerKernel.lean.

## Audits (last lines, verbatim)
`python3 verify/lean_audit.py ErdosTernary.Records.CheckerKernelUpTo20 ErdosTernary.upToK_20 --expect UpTo:2*3^20`
```
WARN ErdosTernary/Checker.lean: native_decide
WARN ErdosTernary/CheckerShard.lean: native_decide
WARN ErdosTernary/Records/UpTo28.lean: native_decide
'ErdosTernary.upToK_20' depends on axioms: [propext, Classical.choice, Quot.sound]
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
```
`python3 verify/lean_audit.py ErdosTernary.CheckerKernel ErdosTernary.CheckerKernel.checkK_sound`
```
'ErdosTernary.CheckerKernel.checkK_sound' depends on axioms: [propext, Classical.choice, Quot.sound]
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
```
The native_decide WARNs are in other files (tier-B results); the axiom lists show neither theorem depends on
them (no Lean.ofReduceBool / native_decide aux axiom). The --expect check elaborated
`example : ErdosTernary.UpTo (2*3^20) := @ErdosTernary.upToK_20` against frozen Statement.lean.

## Notes
- A stray `lake env lean ErdosTernary/CheckerKernelUpTo20.lean` process (PID 2416, not mine, file path no longer
  exists) was running at start; left untouched.
- Not done: upToK_16 / upToK_18 rebuilds (not in my mandate).

## Verdict
All mandated checks reproduce: fresh build 883 s, both audits tier A, sha256 match, CheckerKernel.lean identical,
regenerated file byte-identical, independent C+Python check finds no exception for 8 < n <= 2*3^20.

pass: true
