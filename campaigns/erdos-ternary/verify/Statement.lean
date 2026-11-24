/- Frozen statement of the Erdős ternary conjecture (Erdős 1979).
   Lean 4 + Mathlib could not be installed in phase 0 (see reports/preflight.md); this file freezes the
   statement text. A proof attempt in proofs/lean/ must prove exactly this theorem, with no sorry, admit or
   new axiom. -/
import Mathlib.Data.Nat.Digits

theorem erdos_ternary : ∀ n : ℕ, 8 < n → 2 ∈ Nat.digits 3 (2 ^ n) := by
  sorry
