# Lean audit: g003-L02

Worktree branch g003-L02, commit ce68f7d. Files read: lean/ErdosTernary/E3Count.lean, lean/ErdosTernary/E4.lean,
lean/ErdosTernary.lean, lean/lakefile.toml, verify/Statement.lean, verify/lean_audit.py.

## Build
`cd lean && lake build ErdosTernary.E3Count` (LEAN_NUM_THREADS=1, nice), tail:
```
warning: ../verify/Statement.lean: imports `Mathlib.Data.Nat.Digits.Lemmas` from package `mathlib`, which is designed for use with the module system; consider adding `module` to the start of this file
Build completed successfully (2141 jobs).
```

## lean_audit.py
```
$ python3 verify/lean_audit.py ErdosTernary.E3Count ErdosTernary.E3Count.e3_count_4_pow18
WARN ErdosTernary/Checker.lean: native_decide
'ErdosTernary.E3Count.e3_count_4_pow18' depends on axioms: [propext, Classical.choice, Quot.sound]
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
$ python3 verify/lean_audit.py ErdosTernary.E3Count ErdosTernary.E3Count.card_ge_of_witness
WARN ErdosTernary/Checker.lean: native_decide
'ErdosTernary.E3Count.card_ge_of_witness' depends on axioms: [propext, Classical.choice, Quot.sound]
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
$ python3 tools/check_lock.py
LOCK: OK
```
The only WARN is in Checker.lean (pre-existing, not imported by E3Count or E4); the axiom list confirms tier A.

## Statement check
* `e3_count_4_pow18 (J : ℕ) : 2 ^ J ≤ ((Finset.range (3 ^ (24 * J))).filter (fun x => 2 ∉ Nat.digits 3 x ∧
  2 ∉ Nat.digits 3 (4 * x) ∧ 2 ∉ Nat.digits 3 (2 ^ 18 * x))).card`: universally quantified over J, strict
  range x < 3^(24J), exactly the three conditions x, 4x, 2^18 x, digits via Mathlib `Nat.digits 3`
  (same convention as the frozen Statement.lean; digit membership is independent of list direction).
  Matches claim (1). J = 0 gives 1 ≤ card (x = 0 counted), fine.
* `card_ge_of_witness (N L) (hN0 : 0 < N) (h4 : 4N < 3^L) (h18 : 2^18 N < 3^L) (hd1 hd4 hd18) (J)`: same
  conclusion with range 3^(L*J). Matches claim (2). N < 3^L is not a separate hypothesis but is derived
  inside the proof (`h1 : N < 3^L := by omega` from h4), so its absence is correct, not a gap. Hypotheses
  are not vacuous: N = 532261, L = 24 discharges them (by norm_num and the E4 witness, proved by `decide`).
  hN0 is genuinely needed (for N = 0 the two image sets coincide and the bound 2^J would be false).
* No new definitions affecting meaning; no attributes, instances, notation, macro, set_option or
  native_decide in E3Count.lean or E4.lean. lakefile pulls Statement from ../verify (hash-locked, LOCK OK).
* Comments: header explicitly says the Hausdorff dimension step is NOT formalized; "Theorem 1.7, finite
  form" in the docstring is a description, not a claim of the dimension result. No overclaim.

## Deviation analysis
Hypothetical deviations and their consequence: if the range were `≤` instead of `<` the bound would be
weaker-trivially different (off by one element); if `4 * N < 3^L` were dropped, carries between blocks could
create digit 2 and the general lemma would be false (the proof would not go through); if hN0 were dropped
the lemma would be false for N = 0. None of these occurs in the Lean statement.

## Independent check (own Python)
N = 532261: N, 4N, 2^18 N = 139529027584 all < 3^24 = 282429536481 and free of digit 2. For J = 1, 2, 3 the
2^J block sums Σ ε_j N 3^(24 j) are pairwise distinct (2, 4, 8 values), all < 3^(24J), and all satisfy the
three digit conditions. Small brute-force analogue: x < 3^14 has exactly 3 such x (consistent, not a
counterexample; the block length 24 is what gives the nontrivial count).

pass: true
