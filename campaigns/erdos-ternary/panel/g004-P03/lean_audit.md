# Lean audit: g004-P03

Auditor: independent Lean auditor (fresh context). Worktree branch g004-P03, commit 277de6f.
Files read: lean/ErdosTernary/CountingLambda.lean, lean/ErdosTernary/Counting.lean (statement of
card_noTwo_le_succ_rpow and grep), lean/ErdosTernary.lean, lean/lakefile.toml, verify/lean_audit.py (usage).
Not read: proofs/, discussion.

## Build
`cd lean && lake build ErdosTernary.CountingLambda` (LEAN_NUM_THREADS=1, nice):
```
Build completed successfully (4217 jobs).
exit 0
```
(Only "module system" import warnings from Counting.lean.)

## lean_audit.py
```
ErdosTernary.CountingLambda.card_noTwo_mul_le_succ_rpow   -> LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
ErdosTernary.CountingLambda.card_noTwo_mul_le             -> LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
ErdosTernary.CountingLambda.card_noTwo_le_succ_rpow_of_lambda -> LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
```
tools/check_lock.py: `LOCK: OK`.

## Statement check
1. `card_noTwo_mul_le_succ_rpow (l : ℕ) (hl : ¬ 3 ∣ l) (X : ℕ) :
   ((((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (l * 2 ^ n))).card : ℝ) ≤ ((X : ℝ) + 1) ^ Real.logb 3 2`.
   Range is 0 ≤ n ≤ X (range (X+1)), product is l * 2^n, hypothesis ¬ 3 ∣ l, cast to ℝ, exponent logb 3 2, base (X:ℝ)+1
   (no Nat subtraction, no truncation). Matches claim (1) exactly.
2. `card_noTwo_mul_le (hl : ¬ 3 ∣ l) (k X : ℕ) (hX : X < 2 * 3 ^ k) : (... same filter ...).card ≤ 2 ^ k` (in ℕ; l implicit).
   Matches claim (2).
3. `card_noTwo_le_succ_rpow_of_lambda (X : ℕ)` has, token for token, the type of `Counting.card_noTwo_le_succ_rpow`
   (filter predicate `2 ∉ Nat.digits 3 (2 ^ n)`). Matches claim (3).
Digit predicate uses Mathlib `Nat.digits 3` directly (little-endian list; membership is direction-independent).
Helper defs `tree`, `low` appear only in proofs, not in the statements. No attribute, instance, notation, macro, syntax,
set_option, native_decide, axiom, sorry, implemented_by in CountingLambda.lean or Counting.lean (grep). Module is
imported from lean/ErdosTernary.lean, so it is in the default target.

## Independent numeric check (own Python)
For l in {1,2,4,5,7,256,532261} plus 30 random l < 10^6 with 3 ∤ l, and every X ≤ 20000: count ≤ (X+1)^(log_3 2)
held in all cases (0 failures).
l = 3 (and l = 9, X ≤ 3000): inequality still holds, since Nat.digits 3 (3m) = 0 :: Nat.digits 3 m, so the count equals
that for l/3; excluded by the hypothesis anyway, so the hypothesis is not weakening anything incorrectly.
l = 0: fails at X = 1 (Nat.digits 3 0 = [], so every n counts: 2 > 2^0.6309 ≈ 1.55). The hypothesis ¬ 3 ∣ l excludes l = 0,
which is necessary.

## Hypothetical deviation
If the hypothesis were dropped (or written 3 ∣ l), the statement would be false at l = 0 and the theorem would prove
False-equivalent nonsense; if range X were used instead of range (X+1), the claimed bound would be for n < X and
the "(X+1)" constant-1 sharpness claim at X = 0, 2 would be misreported; if 2^n * l vs l * 2^n differed it would only
be a commutation (harmless), and it is exactly l * 2^n as claimed. None of these deviations are present.

pass: true
