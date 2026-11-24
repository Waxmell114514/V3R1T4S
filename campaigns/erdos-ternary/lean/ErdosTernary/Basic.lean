/- g0 Lean baseline: small facts that also serve as a smoke test of the audit pipeline. -/
import Statement

namespace ErdosTernary

/-- The three known exceptions really have no digit 2. -/
theorem exceptions_have_no_two : 2 ∉ Nat.digits 3 (2 ^ 0) ∧ 2 ∉ Nat.digits 3 (2 ^ 2) ∧
    2 ∉ Nat.digits 3 (2 ^ 8) := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

/-- The conjecture holds for 8 < n ≤ 40, checked by the kernel. -/
theorem upTo_40 : UpTo 40 := by
  intro n hn h8
  interval_cases n <;> decide

end ErdosTernary
