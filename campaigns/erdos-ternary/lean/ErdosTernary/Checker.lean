/- g002-L01: a residue-tree checker for `UpTo N`, with a kernel-checked soundness proof.

Tree (a simplification of verify/CERT.md, sound by `explore_sound` below): a node `(i, r)` stands for the class
`{r + t * P | t : ℕ}` with `P = 2 * 3^i` (the multiplicative order of 2 mod 3^(i+1)). A node succeeds when
* `N < r` (no member of the class is `≤ N`), or
* trit `i` of `2^r` is 2 (then trit `i` of `2^n` is 2 for every member `n`, by periodicity), or
* `N < r + P` and `r ≤ 8` (the only member `≤ N` is `r` itself, and `r ≤ 8` is not in scope of `UpTo`),
otherwise it succeeds when its three children `(i+1, r + j * P)`, `j = 0, 1, 2`, succeed.
Recursion depth is bounded by `fuel`; running out of fuel returns `false`, which is harmless for soundness. -/
import Statement
import Mathlib.Data.Nat.ModEq
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

namespace ErdosTernary

namespace Checker

/-- One node of the residue tree. `Nat.powMod 2 r (3^(i+1))` is `2^r % 3^(i+1)` (`Nat.powMod_def`). -/
def explore (N : ℕ) : ℕ → ℕ → ℕ → Bool
  | 0, _, _ => false
  | fuel + 1, i, r =>
    let q := 3 ^ i
    if N < r then true
    else if Nat.powMod 2 r (3 * q) / q = 2 then true
    else if N < r + 2 * q ∧ r ≤ 8 then true
    else explore N fuel (i + 1) r && explore N fuel (i + 1) (r + 2 * q) &&
      explore N fuel (i + 1) (r + 2 * (2 * q))

/-- The checker: the two level-1 classes `n ≡ 0, 1 (mod 2)`. -/
def check (N : ℕ) : Bool := explore N (N + 64) 0 0 && explore N (N + 64) 0 1

/-- 2 has order dividing `2 * 3^i` modulo `3^(i+1)`. -/
theorem pow_period (i : ℕ) : 2 ^ (2 * 3 ^ i) % 3 ^ (i + 1) = 1 := by
  induction i with
  | zero => norm_num
  | succ i ih =>
    obtain ⟨q, hq⟩ : ∃ q, 2 ^ (2 * 3 ^ i) = 1 + 3 ^ (i + 1) * q :=
      ⟨2 ^ (2 * 3 ^ i) / 3 ^ (i + 1), by have := Nat.mod_add_div (2 ^ (2 * 3 ^ i)) (3 ^ (i + 1)); omega⟩
    have h : 2 ^ (2 * 3 ^ (i + 1)) =
        1 + 3 ^ (i + 1 + 1) * (q + 3 ^ (i + 1) * q ^ 2 + 3 ^ (2 * i + 1) * q ^ 3) := by
      rw [show 2 * 3 ^ (i + 1) = 2 * 3 ^ i * 3 by ring, pow_mul, hq]
      ring
    rw [h, Nat.add_mul_mod_self_left]
    exact Nat.mod_eq_of_lt (Nat.one_lt_pow (by omega) (by norm_num))

/-- `2^n mod 3^(i+1)` depends only on `n mod 2 * 3^i`. -/
theorem pow_class_mod (i r t : ℕ) : 2 ^ (r + t * (2 * 3 ^ i)) % 3 ^ (i + 1) = 2 ^ r % 3 ^ (i + 1) := by
  have h1 : 2 ^ (2 * 3 ^ i) ≡ 1 [MOD 3 ^ (i + 1)] := by
    unfold Nat.ModEq
    rw [pow_period, Nat.mod_eq_of_lt (Nat.one_lt_pow (by omega) (by norm_num))]
  have h2 : 2 ^ r * (2 ^ (2 * 3 ^ i)) ^ t ≡ 2 ^ r * 1 ^ t [MOD 3 ^ (i + 1)] := (h1.pow t).mul_left _
  rw [one_pow, mul_one, ← pow_mul, mul_comm (2 * 3 ^ i) t, ← pow_add] at h2
  exact h2

/-- A nonzero trit gives membership in `Nat.digits`. -/
theorem two_mem_digits_of {x i : ℕ} (h : x / 3 ^ i % 3 = 2) : 2 ∈ Nat.digits 3 x := by
  induction i generalizing x with
  | zero =>
    simp only [pow_zero, Nat.div_one] at h
    rw [Nat.digits_def' (by norm_num) (by omega), h]
    exact List.mem_cons_self
  | succ i ih =>
    have hx : 0 < x := by
      rcases Nat.eq_zero_or_pos x with rfl | hx
      · simp at h
      · exact hx
    rw [Nat.digits_def' (by norm_num) hx]
    apply List.mem_cons_of_mem
    apply ih
    rwa [Nat.div_div_eq_div_mul, ← pow_succ']

/-- Soundness of one node: every member `n ≤ N`, `8 < n`, of the class of `(i, r)` has a digit 2. -/
theorem explore_sound (N : ℕ) : ∀ fuel i r, explore N fuel i r = true →
    ∀ t, r + t * (2 * 3 ^ i) ≤ N → 8 < r + t * (2 * 3 ^ i) →
      2 ∈ Nat.digits 3 (2 ^ (r + t * (2 * 3 ^ i))) := by
  intro fuel
  induction fuel with
  | zero => intro i r h; simp [explore] at h
  | succ fuel ih =>
    intro i r h t hle h8
    simp only [explore] at h
    split_ifs at h with h1 h2 h3
    · omega
    · apply two_mem_digits_of (i := i)
      rw [← Nat.mod_mul_right_div_self, ← pow_succ, pow_class_mod, ← Nat.powMod_def, pow_succ,
        mul_comm (3 ^ i) 3]
      exact h2
    · obtain ⟨hlt, hr8⟩ := h3
      rcases t with _ | t
      · omega
      · have : 2 * 3 ^ i ≤ (t + 1) * (2 * 3 ^ i) := Nat.le_mul_of_pos_left _ (by omega)
        omega
    · simp only [Bool.and_eq_true] at h
      obtain ⟨⟨ha, hb⟩, hc⟩ := h
      have key : r + t * (2 * 3 ^ i) = (r + t % 3 * (2 * 3 ^ i)) + t / 3 * (2 * 3 ^ (i + 1)) := by
        conv_lhs => rw [← Nat.mod_add_div t 3]
        ring
      rw [key] at hle h8 ⊢
      have hj : t % 3 = 0 ∨ t % 3 = 1 ∨ t % 3 = 2 := by omega
      rcases hj with hj | hj | hj <;> rw [hj] at hle h8 ⊢
      · rw [Nat.zero_mul, Nat.add_zero] at hle h8 ⊢
        exact ih (i + 1) r ha _ hle h8
      · rw [Nat.one_mul] at hle h8 ⊢
        exact ih (i + 1) _ hb _ hle h8
      · exact ih (i + 1) _ hc _ hle h8

/-- Soundness of the checker (tier A: no `native_decide` here). -/
theorem check_sound {N : ℕ} (h : check N = true) : UpTo N := by
  intro n hn h8
  simp only [check, Bool.and_eq_true] at h
  have key : n = n % 2 + n / 2 * (2 * 3 ^ 0) := by simp; omega
  have hj : n % 2 = 0 ∨ n % 2 = 1 := by omega
  rw [key] at hn h8 ⊢
  rcases hj with hj | hj <;> rw [hj] at hn h8 ⊢
  · exact explore_sound N _ 0 0 h.1 _ hn h8
  · exact explore_sound N _ 0 1 h.2 _ hn h8

end Checker

/-- `UpTo (2 * 3^12)` (N = 1062882), checked entirely by the kernel (`decide +kernel`, tier A). -/
theorem upTo_small : UpTo (2 * 3 ^ 12) :=
  Checker.check_sound (by decide +kernel)

/-- `UpTo (2 * 3^20)` (N = 6973568802), Vardi's bound. Tier B: `native_decide` evaluates only the closed term
`Checker.check (2 * 3^20)`; the general argument is `Checker.check_sound` (tier A). -/
theorem upTo_vardi : UpTo (2 * 3 ^ 20) :=
  Checker.check_sound (by native_decide)

end ErdosTernary
