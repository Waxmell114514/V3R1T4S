/- g003-C04: a kernel-friendly variant of the residue-tree checker of `ErdosTernary.Checker`.

Same tree as `Checker.explore` (node `(i, r)` = class `{r + t * 2 * 3^i}`), but every node carries its data:
* `q = 3^i` (children get `3 * q`, no `3^i` recomputed),
* `m = 2^r % M` and `g = 2^(2 * 3^i) % M` for one fixed modulus `M = 3^K` (children get `m * g % M`,
  `m * g % M * g % M` and `g * g % M * g % M`: no `Nat.powMod`),
* only `Nat.blt`, `Nat.ble`, `Nat.beq`, `*`, `/`, `%`, `+` (all GMP-accelerated in the kernel) and Bool `||`, `&&`.
Recursion is structural on `fuel ≤ K` (the depth bound); trit `i` of `2^r` is `m / q % 3`, valid while `i < K`.
Running out of fuel returns `false`, which is harmless for soundness. -/
import ErdosTernary.Checker

namespace ErdosTernary

namespace CheckerKernel

/-- One node at depth `i`, with `q = 3^i`, `m = 2^r % M`, `g = 2^(2 * 3^i) % M` (invariants of `exploreK_sound`). -/
def exploreK (N M : ℕ) : ℕ → ℕ → ℕ → ℕ → ℕ → Bool
  | 0, _, _, _, _ => false
  | fuel + 1, q, r, m, g =>
    Nat.blt N r || Nat.beq (m / q % 3) 2 || (Nat.blt N (r + 2 * q) && Nat.ble r 8) ||
      (exploreK N M fuel (3 * q) r m (g * g % M * g % M) &&
        exploreK N M fuel (3 * q) (r + 2 * q) (m * g % M) (g * g % M * g % M) &&
        exploreK N M fuel (3 * q) (r + 2 * (2 * q)) (m * g % M * g % M) (g * g % M * g % M))

/-- The checker with depth bound `K` (modulus `3^K`): the two level-0 classes `n ≡ 0, 1 (mod 2)`. -/
def checkK (N K : ℕ) : Bool :=
  exploreK N (3 ^ K) K 1 0 (1 % 3 ^ K) (4 % 3 ^ K) && exploreK N (3 ^ K) K 1 1 (2 % 3 ^ K) (4 % 3 ^ K)

/-- Soundness of one node, under the invariants on `q`, `m`, `g` and `3^(i + fuel) ∣ M`. -/
theorem exploreK_sound (N M : ℕ) : ∀ fuel i r g, 3 ^ (i + fuel) ∣ M → g = 2 ^ (2 * 3 ^ i) % M →
    exploreK N M fuel (3 ^ i) r (2 ^ r % M) g = true →
    ∀ t, r + t * (2 * 3 ^ i) ≤ N → 8 < r + t * (2 * 3 ^ i) →
      2 ∈ Nat.digits 3 (2 ^ (r + t * (2 * 3 ^ i))) := by
  intro fuel
  induction fuel with
  | zero => intro i r g _ _ h; simp [exploreK] at h
  | succ fuel ih =>
    intro i r g hM hg h t hle h8
    simp only [exploreK, Bool.or_eq_true, Bool.and_eq_true, Nat.blt_eq, Nat.ble_eq, Nat.beq_eq] at h
    rcases h with ((h1 | h2) | ⟨hlt, hr8⟩) | ⟨⟨ha, hb⟩, hc⟩
    · omega
    · apply Checker.two_mem_digits_of (i := i)
      have hdvd : 3 ^ (i + 1) ∣ M := (Nat.pow_dvd_pow 3 (by omega : i + 1 ≤ i + (fuel + 1))).trans hM
      rw [← Nat.mod_mul_right_div_self, ← pow_succ, Checker.pow_class_mod, ← Nat.mod_mod_of_dvd _ hdvd,
        pow_succ, Nat.mod_mul_right_div_self]
      exact h2
    · rcases t with _ | t
      · omega
      · have : 2 * 3 ^ i ≤ (t + 1) * (2 * 3 ^ i) := Nat.le_mul_of_pos_left _ (by omega)
        omega
    · have hM' : 3 ^ (i + 1 + fuel) ∣ M := by rw [show i + 1 + fuel = i + (fuel + 1) by omega]; exact hM
      have hq : 3 * 3 ^ i = 3 ^ (i + 1) := by rw [pow_succ, mul_comm]
      have hg' : g * g % M * g % M = 2 ^ (2 * 3 ^ (i + 1)) % M := by
        have e : 2 ^ (2 * 3 ^ (i + 1)) = 2 ^ (2 * 3 ^ i) * 2 ^ (2 * 3 ^ i) * 2 ^ (2 * 3 ^ i) := by
          rw [← pow_add, ← pow_add]; congr 1; rw [pow_succ]; ring
        rw [hg, e, Nat.mul_mod (2 ^ (2 * 3 ^ i) * 2 ^ (2 * 3 ^ i)), Nat.mul_mod (2 ^ (2 * 3 ^ i))]
      have hm1 : 2 ^ r % M * g % M = 2 ^ (r + 2 * 3 ^ i) % M := by
        rw [hg, ← Nat.mul_mod, ← pow_add]
      have hm2 : 2 ^ r % M * g % M * g % M = 2 ^ (r + 2 * (2 * 3 ^ i)) % M := by
        rw [hm1, hg, ← Nat.mul_mod, ← pow_add]; congr 2; ring
      rw [hq, hg'] at ha hb hc
      rw [hm1] at hb
      rw [hm2] at hc
      have key : r + t * (2 * 3 ^ i) = (r + t % 3 * (2 * 3 ^ i)) + t / 3 * (2 * 3 ^ (i + 1)) := by
        conv_lhs => rw [← Nat.mod_add_div t 3]
        ring
      rw [key] at hle h8 ⊢
      have hj : t % 3 = 0 ∨ t % 3 = 1 ∨ t % 3 = 2 := by omega
      rcases hj with hj | hj | hj <;> rw [hj] at hle h8 ⊢
      · rw [Nat.zero_mul, Nat.add_zero] at hle h8 ⊢
        exact ih (i + 1) r _ hM' rfl ha _ hle h8
      · rw [Nat.one_mul] at hle h8 ⊢
        exact ih (i + 1) _ _ hM' rfl hb _ hle h8
      · exact ih (i + 1) _ _ hM' rfl hc _ hle h8

/-- Assembly step used to split one large kernel evaluation into many declarations (bounded memory per
declaration): a node succeeds if its three children do. -/
theorem exploreK_of_children (N M fuel q r m g : ℕ)
    (ha : exploreK N M fuel (3 * q) r m (g * g % M * g % M) = true)
    (hb : exploreK N M fuel (3 * q) (r + 2 * q) (m * g % M) (g * g % M * g % M) = true)
    (hc : exploreK N M fuel (3 * q) (r + 2 * (2 * q)) (m * g % M * g % M) (g * g % M * g % M) = true) :
    exploreK N M (fuel + 1) q r m g = true := by
  rw [exploreK, ha, hb, hc]; simp

/-- Assembly of `checkK` from its two roots. -/
theorem checkK_of_roots (N K : ℕ) (h0 : exploreK N (3 ^ K) K 1 0 (1 % 3 ^ K) (4 % 3 ^ K) = true)
    (h1 : exploreK N (3 ^ K) K 1 1 (2 % 3 ^ K) (4 % 3 ^ K) = true) : checkK N K = true := by
  rw [checkK, h0, h1]; rfl

/-- Soundness of the kernel-friendly checker (tier A: no `native_decide`). -/
theorem checkK_sound {N K : ℕ} (h : checkK N K = true) : UpTo N := by
  intro n hn h8
  simp only [checkK, Bool.and_eq_true] at h
  have key : n = n % 2 + n / 2 * (2 * 3 ^ 0) := by simp; omega
  have hj : n % 2 = 0 ∨ n % 2 = 1 := by omega
  have hM : 3 ^ (0 + K) ∣ 3 ^ K := by simp
  have hg : 4 % 3 ^ K = 2 ^ (2 * 3 ^ 0) % 3 ^ K := by norm_num
  rw [key] at hn h8 ⊢
  rcases hj with hj | hj <;> rw [hj] at hn h8 ⊢
  · exact exploreK_sound N _ K 0 0 _ hM hg (by simpa using h.1) _ hn h8
  · exact exploreK_sound N _ K 0 1 _ hM hg (by simpa using h.2) _ hn h8

end CheckerKernel

end ErdosTernary
