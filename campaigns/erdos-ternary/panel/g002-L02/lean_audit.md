# Lean audit: g002-L02

Auditor: independent Lean auditor (fresh context). Worktree branch g002-L02, commit 1399d42.
Files inspected: lean/ErdosTernary/Counting.lean, lean/ErdosTernary.lean, lean/lakefile.toml,
verify/Statement.lean, verify/lean_audit.py. proofs/ and discussion not read.

## Build (`cd lean && lake build`, tail)
```
warning: ErdosTernary/Counting.lean: imports `Mathlib.Analysis.Convex.SpecificFunctions.Pow` from package `mathlib`, which is designed for use with the module system; consider adding `module` to the start of this file
Build completed successfully (4221 jobs).
```
(Only module-system import warnings; no errors, no sorry warnings.)

## lean_audit.py (last lines)
```
ErdosTernary.Counting.card_noTwo_le            -> 'depends on axioms: [propext, Classical.choice, Quot.sound]'  LEAN_AUDIT: PASS tier=A
ErdosTernary.Counting.card_noTwo_le_rpow       -> 'depends on axioms: [propext, Classical.choice, Quot.sound]'  LEAN_AUDIT: PASS tier=A
ErdosTernary.Counting.card_noTwo_le_succ_rpow  -> 'depends on axioms: [propext, Classical.choice, Quot.sound]'  LEAN_AUDIT: PASS tier=A
```
No WARN lines printed (no macro/syntax/notation/instance/set_option/attribute/native_decide).
`python3 tools/check_lock.py` -> `LOCK: OK`.

## Statement-by-statement check

Common subterm: `(Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))`, `.card`.
`Finset.range (X+1)` = {0,...,X} (inclusive of X, n ≤ X). `Nat.digits 3 m` is Mathlib's base-3 digit list
(little-endian; direction irrelevant for membership; `Nat.digits 3 1 = [1]`, so n = 0 counts, as intended).
`2 : ℕ`. This is exactly A(X). The main statements mention only Nat.digits, Finset, Nat/Real operations;
the helper defs `tree`, `low` appear only in lemmas/proofs, not in the three statement types.

1. `card_noTwo_le (k X : ℕ) (hX : X < 2 * 3 ^ k) : A(X) ≤ 2 ^ k` in ℕ. Universal in k, X, strict bound
   X < 2·3^k as claimed. No other hypotheses. Matches claim 1.
2. `card_noTwo_le_rpow (X : ℕ) (hX : 2 ≤ X) : (A(X) : ℝ) ≤ 2 * ((X : ℝ) / 2) ^ Real.logb 3 2`.
   Division is real division (cast before `/`), base X/2 ≥ 1 > 0 so rpow is the genuine power;
   `Real.logb 3 2 = log 2 / log 3 = log_3 2`. Hypothesis 2 ≤ X as claimed. Matches claim 2.
3. `card_noTwo_le_succ_rpow (X : ℕ) : (A(X) : ℝ) ≤ ((X : ℝ) + 1) ^ Real.logb 3 2`.
   No hypotheses (X = 0 included); base (X:ℝ)+1 ≥ 1, cast-then-add so no truncation issue. Matches claim 3.

No Nat subtraction in statements. No new instances, notation, macros, local attributes, set_option, or
native_decide anywhere in Counting.lean (grep confirms; the only "native_decide" string is in a comment).
`decide` is used only for `card_tree_zero` (a concrete finite computation) and `Nat.Coprime` facts.
Frozen definitions in verify/Statement.lean are not redefined (hash lock OK); the results do not use
`Statement`/`UpTo` (they are auxiliary counting results, so no `--expect` applies).

## Hypothetical deviations and their consequences
- If `range X` were used instead of `range (X+1)`, the theorems would count n < X and claim 2/3 would be
  weaker than stated (e.g. at X = 2 the sharp equality would be lost). Not the case.
- If `/` were ℕ division, claim 2 would bound by 2·⌊X/2⌋^α, a different (stronger-looking, X odd) statement.
  Not the case: the cast precedes the division.
- If the exponent were a Nat-cast or the base could be negative, rpow could degenerate (e.g. x^y = cos-term
  for x<0) and the statement would be vacuous or wrong. Not the case: bases are ≥ 1.

## Independent numerical check (own Python, X ≤ 3000)
Exponents n ≤ 3000 with 2^n free of ternary digit 2: [0, 2, 8] only.
All three inequalities hold for every X ≤ 3000 (claim 1 checked for the minimal k with X < 2·3^k and the
next two k). Claim 3 equality: X = 0: A = 1 = 1^α; X = 2: A = 2 = 3^α. Claim 1 is tight for k = 0, 1
(X = 1: A = 1 = 2^0; X = 5: A = 2 = 2^1).

## Verdict
All three Lean statements say exactly the informal claims, build cleanly, and are tier A
(axioms propext, Classical.choice, Quot.sound only). No meaning-changing constructs found.

pass: true
