# Claim g002-L02 (milestone M3 candidate)

Let A(X) = #{ n : 0 ≤ n ≤ X, the base-3 expansion of 2^n has no digit 2 }.

Claimed new statement (exact scope): for every natural number X (including X = 0),
    A(X) ≤ (X + 1)^{log_3 2}.
The constant 1 is optimal: equality holds at X = 0 and X = 2.
Lean: `ErdosTernary.Counting.card_noTwo_le_succ_rpow` in Counting.lean (copy here), Lean 4 + Mathlib v4.36.0,
tier A (axioms propext, Classical.choice, Quot.sound only), statement
  (((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card : ℝ) ≤ ((X : ℝ) + 1) ^ Real.logb 3 2.
Supporting theorems in the same file, labelled KNOWN / corollary of KNOWN, not claimed as new:
`card_noTwo_le` (X < 2·3^k ⇒ A(X) ≤ 2^k) and `card_noTwo_le_rpow` (X ≥ 2 ⇒ A(X) ≤ 2 (X/2)^{log_3 2}).

Prior bounds known to the claimant (not opened: Narkiewicz's original, its MR review, Schinzel's survey):
Narkiewicz 1980: A(T) ≤ 1.62 T^{log_3 2} (from the paper's own summary in zbMATH 0457.10003);
Lagarias 2009 (arXiv:math/0512006) Thm 1.4 proof; Holdum–Klausen–Rasmussen, Integers 15 (2015) A43, Thm 2.13:
#{0 ≤ s < a : 2^s has no digit 2} ≤ 1.3 a^{log_3 2} for all a ≥ 1, i.e. A(X) ≤ 1.3 (X+1)^{log_3 2}.
The claim sharpens 1.3 to the optimal 1 in this form. It has no bearing on the Erdős conjecture itself
(the true A(X) is conjecturally 3 for X ≥ 8).

Proof idea (for orientation only; check independently): induction on k of L_k(Y) ≤ Y^{log_3 2} for Y ≤ 2·3^k, where
L_k(Y) counts r < Y whose 2^r has low k+1 trits free of 2; the case Y = 2·3^k + s, s < 3^k, uses periodicity mod
2·3^k and concavity of x ↦ x^{log_3 2}.

How to rerun: `cd campaigns/erdos-ternary/lean && lake build`; from campaigns/erdos-ternary:
`python3 verify/lean_audit.py ErdosTernary.Counting ErdosTernary.Counting.card_noTwo_le_succ_rpow`.

## Revision 2 (after the CRITERION skeptic, panel/g002-L02/criterion.md) — scope narrowed, nothing widened
- Sharpness is now formalized (CountingSharp.lean, copy here; written by the orchestrator, needs its own audit):
  `sharp_at_zero`, `sharp_at_two` (equality at X = 0 and X = 2) and `const_ge_one`: if A(X) ≤ c·(X+1)^{log_3 2}
  for all X ≥ 0 then c ≥ 1. All tier A by verify/lean_audit.py.
- Comparison stated precisely: the improvement 1.3 → 1 holds only in the (X+1)^{log_3 2} normalization, where
  Holdum–Klausen–Rasmussen (2015, Thm 2.13, "s < a") reads A(X) ≤ 1.3 (X+1)^{log_3 2}. In the X^{log_3 2}
  normalization the new bound gives no improvement over the known 2^{1-log_3 2} ≈ 1.29. The normalization of
  Narkiewicz's 1.62·T^{log_3 2} is taken from a zbMATH summary and is unverified.
- Allowed one-sentence scope: "Lean-verified (tier A): for every integer X ≥ 0, the number of n with 0 ≤ n ≤ X such
  that 2^n has no digit 2 in base 3 is at most (X+1)^{log_3 2}, and the constant 1 cannot be lowered in this
  (X+1)-normalized form; this compares with the constant 1.3 of Holdum–Klausen–Rasmussen (2015) in the same
  normalization and says nothing about the Erdős conjecture."
