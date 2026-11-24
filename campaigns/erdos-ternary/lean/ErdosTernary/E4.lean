/- g002-P04 (exploratory). Finite, kernel-checked digit facts only.

The E^(4) search of g002-P04 (all C(1, 2^a, 2^b, 2^c), 0 < a < b < c ≤ 1000) found NO component of positive
Hausdorff dimension, hence no Lagarias Theorem 1.7 witness for E^(4); nothing about E^(4) is stated here.

What is stated: one by-product witness for the E^(3)-component C(1, 2^2, 2^18). By Lagarias
(arXiv:math/0512006, Theorem 1.7; quoted in proofs/g002-P04.md) the three digit facts below imply
dim_H C(1, 2^2, 2^18) ≥ log_3 2 / 24 > 0. That implication is NOT formalized here (Mathlib has no
3-adic Cantor-set dimension theory); this file states only the three digit facts. -/
import Statement

namespace ErdosTernary

/-- N = 532261: N, 2^2·N and 2^18·N all have base-3 expansions without the digit 2. -/
theorem lagarias_witness_4_pow18 :
    2 ∉ Nat.digits 3 532261 ∧ 2 ∉ Nat.digits 3 (2 ^ 2 * 532261) ∧
      2 ∉ Nat.digits 3 (2 ^ 18 * 532261) := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

end ErdosTernary
