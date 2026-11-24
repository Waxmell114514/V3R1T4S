/- Frozen definitions for the Erdős ternary conjecture (Erdős 1979). Frozen in phase 0 (revision v0.2).
   No proofs here. Results in lean/ErdosTernary/ must use these definitions directly. -/
import Mathlib.Data.Nat.Digits.Lemmas

namespace ErdosTernary

/-- Erdős: for every n > 8, the base-3 expansion of 2^n contains the digit 2. -/
def Statement : Prop := ∀ n : ℕ, 8 < n → 2 ∈ Nat.digits 3 (2 ^ n)

/-- The conjecture verified for all n with 8 < n ≤ N. -/
def UpTo (N : ℕ) : Prop := ∀ n : ℕ, n ≤ N → 8 < n → 2 ∈ Nat.digits 3 (2 ^ n)

end ErdosTernary
