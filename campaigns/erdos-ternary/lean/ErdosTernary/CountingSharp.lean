/- g002-L02 follow-up: the constant 1 in `card_noTwo_le_succ_rpow` cannot be lowered, because the bound is attained
   at X = 0 and X = 2. Requested by the CRITERION skeptic (panel/g002-L02/criterion.md). -/
import ErdosTernary.Counting

namespace ErdosTernary.Counting

/-- A(0) = 1 = (0+1)^{log_3 2}. -/
theorem sharp_at_zero :
    (((Finset.range (0 + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card : ℝ) =
      ((0 : ℝ) + 1) ^ Real.logb 3 2 := by
  have h : ((Finset.range (0 + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card = 1 := by decide
  rw [h]; simp

/-- A(2) = 2 = (2+1)^{log_3 2}. -/
theorem sharp_at_two :
    (((Finset.range (2 + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card : ℝ) =
      ((2 : ℝ) + 1) ^ Real.logb 3 2 := by
  have h : ((Finset.range (2 + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card = 2 := by decide
  rw [h]
  have h3 : (2 : ℝ) + 1 = 3 := by norm_num
  rw [h3, Real.rpow_logb (by norm_num) (by norm_num) (by norm_num)]
  norm_num

/-- Hence no constant c < 1 works: if A(X) ≤ c (X+1)^{log_3 2} for all X, then c ≥ 1. -/
theorem const_ge_one (c : ℝ)
    (hc : ∀ X : ℕ, (((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card : ℝ) ≤
      c * ((X : ℝ) + 1) ^ Real.logb 3 2) : 1 ≤ c := by
  have h := hc 0
  rw [sharp_at_zero] at h
  simpa using h

end ErdosTernary.Counting
