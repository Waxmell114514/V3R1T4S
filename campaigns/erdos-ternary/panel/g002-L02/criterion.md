# Skeptic CRITERION: g002-L02

Materials read: panel/g002-L02/claim/{CLAIM.md, Counting.lean, Statement.lean}, MISSION.md, CONSTRAINTS.md.
I did not read proofs/, reports/ or other panel files. I did not rerun Lean; that is REPRODUCE's job. This review compares the scope as written with the Lean statement.

## 1. Lean statement vs informal statement

Lean (`ErdosTernary.Counting.card_noTwo_le_succ_rpow`):
  ∀ X : ℕ, ((range (X+1)).filter (fun n => 2 ∉ Nat.digits 3 (2^n))).card (cast to ℝ) ≤ ((X:ℝ)+1) ^ Real.logb 3 2.

- Range: `Finset.range (X+1)` = {0,…,X}, so the range is inclusive at both ends: 0 ≤ n ≤ X. This matches CLAIM.md.
- n = 0 is counted. 2^0 = 1, and `Nat.digits 3 1 = [1]`, so A(0) = 1. This matches the informal A(X).
- X = 0 is covered: X is an arbitrary ℕ with no hypothesis, which matches "including X = 0".
- Digit predicate: it uses Mathlib's `Nat.digits 3` directly, the same notion as the frozen `verify/Statement.lean`. There is no redefinition (rule 12). The theorem does not mention `Statement` or `UpTo`, and it does not need to.
- Real cast and exponent: `Real.logb 3 2 = log 2 / log 3 = log_3 2 ≈ 0.6309`. The base is right, and `(X:ℝ)+1 ≥ 1 > 0`, so `rpow` behaves as the ordinary power. There are no hidden side conditions.
- Hypotheses: none. The statement is universal over X, as claimed.
Verdict: the "Claimed new statement (exact scope)" line matches the Lean theorem exactly. It claims no more and no less.

## 2. The optimality remark "equality at X = 0 and X = 2"

- It is true by a hand check. A(0) = 1 = 1^α. For X = 2: 2^0 = 1 = 1_3 (no 2), 2^1 = 2 = 2_3 (has a 2), 2^2 = 4 = 11_3 (no 2). So A(2) = 2 = 3^{log_3 2}. This exact equality holds, so the constant 1 cannot be lowered in the form C·(X+1)^α.
- It is NOT in the Lean package. No theorem states A(0) = 1, A(2) = 2 or 3^{logb 3 2} = 2. The claim appears only in a docstring and in CLAIM.md. Under rule 3 it is therefore at most PROVED-HERE (elementary check) and must not be presented as part of the Lean-verified result.
- Required: label it "PROVED-HERE (hand check, not formalized)". Alternatively, add a small Lean lemma, for example by `decide` on the two cardinalities plus `Real.rpow_logb`.
- Wording: "optimal" and "sharp" must be qualified as "optimal among bounds of the form C·(X+1)^{log_3 2} valid for all X ≥ 0". They are not optimal in any other normalization, as the next section shows.

## 3. Comparison with prior constants (normalization)

- HKR 2015 Thm 2.13, as quoted: #{0 ≤ s < a} ≤ 1.3·a^α for a ≥ 1. With a = X+1 this is exactly A(X) ≤ 1.3·(X+1)^α for X ≥ 0. The translation is correct, and the same normalization is used on both sides. "1.3 → 1" is precise ONLY in this (X+1)^α / "s < a" normalization.
- Narkiewicz 1980: "A(T) ≤ 1.62·T^α" comes from a zbMATH summary only, and the original was not opened. Two things are unverified: whether its count is over n ≤ T or n < T, and which range of T is allowed. It uses the T^α normalization, so it is not directly comparable. This must be marked "unverified normalization" (rule 1).
- In the X^α normalization the new bound is NOT an improvement of the leading constant:
  - At X = 2, the left side is 2 and 2^α ≈ 1.55, so any bound C·X^α needs C ≥ 2^{1-α} ≈ 1.29.
  - Restated in that form, the new bound gives sup_{X≥1} ((X+1)/X)^α = 2^α ≈ 1.55 for X ≥ 1, and (3/2)^α ≈ 1.29 for X ≥ 2.
  - The package's own KNOWN corollary `card_noTwo_le_rpow` already gives 2^{1-α} ≈ 1.2915 for X ≥ 2.
  - Asymptotically, every one of these forms has the same exponent; only the normalization of the constant differs.
- CLAIM.md's sentence "The claim sharpens 1.3 to the optimal 1 in this form" is acceptable only because it says "in this form". It must not be paraphrased as "improves Narkiewicz's 1.62" or "best known constant".

## 4. Overclaiming

- "It has no bearing on the Erdős conjecture itself" is correct and appropriately modest. "Conjecturally 3 for X ≥ 8" is correct (n = 0, 2, 8) and labelled as conjectural.
- I found none of the words "record", "first", "breakthrough" or "solve" (rule 6). "Claimed new" is acceptable as a claim; novelty is NOVELTY's call.
- The docstring title "Sharp counting bound" needs the qualifier from section 2. This is cosmetic, but it should be fixed in any public summary.
- The supporting theorems are correctly labelled KNOWN or corollary-of-KNOWN and are not claimed as new.
- Tier A is stated. The file contains no `native_decide`, which is consistent with rule 13.

## 5. Fit to M3

M3 requires at least one statement not in the literature, a Lean proof that passes audit, and a panel verdict of CONFIRMED_PARTIAL. The Lean-verified object is a single closed, unconditional, universally quantified statement whose scope exactly matches the claim. It is not a numeric computation or a heuristic. It therefore has the right shape for an M3 item.

Two parts of M3 are outside my role. Whether it counts depends on NOVELTY (absent from Narkiewicz, Lagarias and HKR, among others) and on the build/audit checks (REPRODUCE and the Lean auditor). The optimality remark must not count toward M3, because it is not Lean-verified.

## 6. Scope I would allow to be published (one sentence)

"Lean-verified (tier A): for every integer X ≥ 0, the number of n with 0 ≤ n ≤ X such that the base-3 expansion of 2^n has no digit 2 is at most (X+1)^{log_3 2}; by a hand check (not formalized), equality at X = 0 and X = 2 shows the constant 1 cannot be lowered in this (X+1)-normalized form, which compares with the constant 1.3 of Holdum–Klausen–Rasmussen (2015, Thm 2.13) in the same normalization and says nothing about the Erdős conjecture."

## Verdict

The Lean statement matches the claimed main statement exactly. The pass is conditional on two edits:
- relabel the optimality remark as PROVED-HERE (or formalize it);
- keep the comparison restricted to the (X+1)^α normalization, with the Narkiewicz constant marked as unverified in normalization.

pass: true
