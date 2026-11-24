/- g004-P03: the residue-tree bound of Counting.lean for a general multiplier `l` with `3 ∤ l`:
   A_l(X) := #{0 ≤ n ≤ X : 2 ∉ Nat.digits 3 (l * 2^n)} ≤ (X+1)^(log₃ 2). See proofs/g004-P03.md. Tier A.
   * `card_noTwo_mul_le` (X < 2·3^k ⇒ A_l(X) ≤ 2^k): KNOWN in substance (Lagarias 2009 Thm 1.4, 3-adic λ,
     "essentially the same proof" as Narkiewicz 1980; per specs/literature.md).
   * `card_noTwo_mul_le_succ_rpow` (constant 1, all X): the g002-L02 sharp form, for every such `l`.
   * `card_noTwo_le_succ_rpow_of_lambda`: `l = 1` gives back `Counting.card_noTwo_le_succ_rpow`. -/
import ErdosTernary.Counting

namespace ErdosTernary
namespace CountingLambda

open Counting

variable (l : ℕ)

/-- `l·2^n mod 3^(k+1)` depends only on `n mod 2·3^k`. -/
theorem mul_two_pow_mod_period (k n : ℕ) :
    l * 2 ^ n % 3 ^ (k + 1) = l * 2 ^ (n % (2 * 3 ^ k)) % 3 ^ (k + 1) := by
  rw [Nat.mul_mod, two_pow_mod_period k n, ← Nat.mul_mod]

/-- Residues `r < 2·3^k` such that the low `k+1` trits of `l·2^r` avoid 2. -/
def tree (k : ℕ) : Finset ℕ :=
  (Finset.range (2 * 3 ^ k)).filter (fun r => ∀ i < k + 1, l * 2 ^ r / 3 ^ i % 3 ≠ 2)

theorem mem_tree {k r : ℕ} :
    r ∈ tree l k ↔ r < 2 * 3 ^ k ∧ ∀ i < k + 1, l * 2 ^ r / 3 ^ i % 3 ≠ 2 := by
  simp [tree]

variable {l}

theorem coprime_three_pow (hl : ¬ 3 ∣ l) (m e : ℕ) : Nat.Coprime (3 ^ m) (l * 2 ^ e) := by
  have h3 : Nat.Coprime 3 l := (Nat.Prime.coprime_iff_not_dvd Nat.prime_three).mpr hl
  exact Nat.Coprime.mul_right (Nat.Coprime.pow_left _ h3)
    (Nat.Coprime.pow _ _ (by decide : Nat.Coprime 3 2))

/-- Each node has at most two children. -/
theorem card_tree_succ_le (hl : ¬ 3 ∣ l) (k : ℕ) :
    (tree l (k + 1)).card ≤ 2 * (tree l k).card := by
  set P := 2 * 3 ^ k with hP
  have hP3 : 2 * 3 ^ (k + 1) = 3 * P := by rw [hP, pow_succ]; ring
  have hPpos : 0 < P := by positivity
  have per : ∀ r i, i < k + 1 → l * 2 ^ r / 3 ^ i % 3 = l * 2 ^ (r % P) / 3 ^ i % 3 :=
    fun r i hi => trit_eq_of_mod_eq (mul_two_pow_mod_period l k r) hi
  apply Finset.card_le_mul_card_image_of_maps_to (f := fun r => r % P)
  · intro r hr
    rw [mem_tree] at hr ⊢
    refine ⟨Nat.mod_lt _ hPpos, fun i hi => ?_⟩
    rw [← per r i hi]
    exact hr.2 i (by omega)
  · intro r0 hr0
    rw [mem_tree] at hr0
    set F := (tree l (k + 1)).filter (fun r => r % P = r0)
    have hsub : F ⊆ {r0, r0 + P, r0 + 2 * P} := by
      intro r hr
      simp only [F, Finset.mem_filter, mem_tree] at hr
      have hq : r / P < 3 := by
        rw [Nat.div_lt_iff_lt_mul hPpos]; rw [hP3] at hr; linarith [hr.1.1]
      have hr' : r = r0 + P * (r / P) := by rw [← hr.2]; exact (Nat.mod_add_div r P).symm
      simp only [Finset.mem_insert, Finset.mem_singleton]
      interval_cases h : r / P <;> omega
    have hnot : ¬ ({r0, r0 + P, r0 + 2 * P} : Finset ℕ) ⊆ F := by
      intro hall
      have good : ∀ j, j ≤ 2 → l * 2 ^ (r0 + j * P) / 3 ^ (k + 1) % 3 ≠ 2 := by
        intro j hj
        have hmem : r0 + j * P ∈ F := by
          apply hall
          interval_cases j <;> simp
        simp only [F, Finset.mem_filter, mem_tree] at hmem
        exact hmem.1.2 (k + 1) (by omega)
      have low : ∀ j, l * 2 ^ (r0 + j * P) % 3 ^ (k + 1) = l * 2 ^ r0 % 3 ^ (k + 1) := by
        intro j
        rw [mul_two_pow_mod_period l k (r0 + j * P), mul_two_pow_mod_period l k r0]
        congr 3
        rw [Nat.add_mul_mod_self_right]
      have sep : ∀ j j', j < j' → j' ≤ 2 →
          l * 2 ^ (r0 + j * P) / 3 ^ (k + 1) % 3 ≠ l * 2 ^ (r0 + j' * P) / 3 ^ (k + 1) % 3 := by
        intro j j' hjj hj' heq
        have hm : l * 2 ^ (r0 + j * P) * 1 ≡ l * 2 ^ (r0 + j * P) * 2 ^ ((j' - j) * P)
            [MOD 3 ^ (k + 2)] := by
          rw [mul_one, mul_assoc, ← pow_add, show r0 + j * P + (j' - j) * P = r0 + j' * P by
            rw [add_assoc, ← add_mul]; congr 2; omega]
          unfold Nat.ModEq
          rw [Nat.mod_pow_succ, Nat.mod_pow_succ (x := l * 2 ^ (r0 + j' * P)), low j, low j', heq]
        have hc := Nat.ModEq.cancel_left_of_coprime (coprime_three_pow hl (k + 2) _) hm
        exact two_pow_period_not_modEq k (j' - j) (by omega) (by omega) hc.symm
      have g0 := good 0 (by norm_num)
      have g1 := good 1 (by norm_num)
      have g2 := good 2 le_rfl
      have s01 := sep 0 1 (by norm_num) (by norm_num)
      have s02 := sep 0 2 (by norm_num) le_rfl
      have s12 := sep 1 2 (by norm_num) le_rfl
      have l0 := Nat.mod_lt (l * 2 ^ (r0 + 0 * P) / 3 ^ (k + 1)) (by norm_num : 0 < 3)
      have l1 := Nat.mod_lt (l * 2 ^ (r0 + 1 * P) / 3 ^ (k + 1)) (by norm_num : 0 < 3)
      have l2 := Nat.mod_lt (l * 2 ^ (r0 + 2 * P) / 3 ^ (k + 1)) (by norm_num : 0 < 3)
      omega
    have h3 : ({r0, r0 + P, r0 + 2 * P} : Finset ℕ).card ≤ 3 := Finset.card_le_three
    by_contra hc
    rw [not_le] at hc
    exact hnot (Finset.eq_of_subset_of_card_le hsub (by omega)).symm.subset

/-- The root: of `l` and `2l`, exactly one is `≡ 2 (mod 3)`; we only need at most one survivor. -/
theorem card_tree_zero_le (hl : ¬ 3 ∣ l) : (tree l 0).card ≤ 1 := by
  rw [Finset.card_le_one]
  intro a ha b hb
  rw [mem_tree] at ha hb
  have ha2 := ha.2 0 (by norm_num)
  have hb2 := hb.2 0 (by norm_num)
  simp only [pow_zero, Nat.div_one] at ha2 hb2
  have ha1 : a < 2 := by simpa using ha.1
  have hb1 : b < 2 := by simpa using hb.1
  interval_cases a <;> interval_cases b <;> simp at ha2 hb2 ⊢ <;> omega

theorem card_tree_le (hl : ¬ 3 ∣ l) (k : ℕ) : (tree l k).card ≤ 2 ^ k := by
  induction k with
  | zero => simpa using card_tree_zero_le hl
  | succ k ih => calc
      (tree l (k + 1)).card ≤ 2 * (tree l k).card := card_tree_succ_le hl k
      _ ≤ 2 * 2 ^ k := by omega
      _ = 2 ^ (k + 1) := by ring

/-- **Finite form.** If `3 ∤ l` and `X < 2·3^k`, at most `2^k` of the `n ≤ X` have `l·2^n` free of the
ternary digit 2. -/
theorem card_noTwo_mul_le (hl : ¬ 3 ∣ l) (k X : ℕ) (hX : X < 2 * 3 ^ k) :
    ((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (l * 2 ^ n))).card ≤ 2 ^ k := by
  refine le_trans (Finset.card_le_card ?_) (card_tree_le hl k)
  intro n hn
  simp only [Finset.mem_filter, Finset.mem_range] at hn
  rw [mem_tree]
  exact ⟨by omega, fun i _ => trit_ne_two_of_not_mem hn.2 i⟩

/-! ### The sharp form -/

variable (l) in
/-- Number of `r < Y` such that the low `k+1` trits of `l·2^r` avoid 2. -/
def low (k Y : ℕ) : ℕ :=
  ((Finset.range Y).filter (fun r => ∀ i < k + 1, l * 2 ^ r / 3 ^ i % 3 ≠ 2)).card

variable (l) in
theorem low_period (k : ℕ) : low l k (2 * 3 ^ k) = (tree l k).card := rfl

variable (l) in
theorem low_mono_right (k : ℕ) {Y Y' : ℕ} (h : Y ≤ Y') : low l k Y ≤ low l k Y' := by
  apply Finset.card_le_card
  intro r hr
  simp only [Finset.mem_filter, Finset.mem_range] at hr ⊢
  exact ⟨by omega, hr.2⟩

variable (l) in
theorem low_succ_le (k Y : ℕ) : low l (k + 1) Y ≤ low l k Y := by
  apply Finset.card_le_card
  intro r hr
  simp only [Finset.mem_filter, Finset.mem_range] at hr ⊢
  exact ⟨hr.1, fun i hi => hr.2 i (by omega)⟩

variable (l) in
theorem good_iff_mod (k r : ℕ) : (∀ i < k + 1, l * 2 ^ r / 3 ^ i % 3 ≠ 2) ↔
    (∀ i < k + 1, l * 2 ^ (r % (2 * 3 ^ k)) / 3 ^ i % 3 ≠ 2) := by
  constructor <;> intro h i hi
  · rw [← trit_eq_of_mod_eq (mul_two_pow_mod_period l k r) hi]; exact h i hi
  · rw [trit_eq_of_mod_eq (mul_two_pow_mod_period l k r) hi]; exact h i hi

variable (l) in
/-- One period plus a partial period. -/
theorem low_add_le (k s : ℕ) :
    low l k (2 * 3 ^ k + s) ≤ (tree l k).card + low l k s := by
  set P := 2 * 3 ^ k with hP
  have hsub : (Finset.range (P + s)).filter (fun r => ∀ i < k + 1, l * 2 ^ r / 3 ^ i % 3 ≠ 2) ⊆
      tree l k ∪ ((Finset.range s).filter (fun r => ∀ i < k + 1, l * 2 ^ r / 3 ^ i % 3 ≠ 2)).image
        (fun r => r + P) := by
    intro r hr
    simp only [Finset.mem_filter, Finset.mem_range] at hr
    rw [Finset.mem_union, mem_tree]
    by_cases hrP : r < P
    · exact Or.inl ⟨hrP, hr.2⟩
    · right
      rw [Finset.mem_image]
      refine ⟨r - P, ?_, by omega⟩
      simp only [Finset.mem_filter, Finset.mem_range]
      refine ⟨by omega, ?_⟩
      have hmod : (r - P) % P = r % P := by
        conv_rhs => rw [show r = (r - P) + P by omega]
        rw [Nat.add_mod_right]
      rw [good_iff_mod, hmod, ← good_iff_mod]
      exact hr.2
  unfold low
  calc _ ≤ _ := Finset.card_le_card hsub
    _ ≤ _ := Finset.card_union_le _ _
    _ ≤ _ := Nat.add_le_add_left Finset.card_image_le _

/-- The partial-period counts are bounded by `Y^(log₃ 2)` on a whole period. -/
theorem low_le_rpow (hl : ¬ 3 ∣ l) :
    ∀ (k Y : ℕ), Y ≤ 2 * 3 ^ k → (low l k Y : ℝ) ≤ (Y : ℝ) ^ Real.logb 3 2
  | 0, Y, hY => by
    rcases Nat.eq_zero_or_pos Y with rfl | hY0
    · have h0 : low l 0 0 = 0 := rfl
      rw [h0, Nat.cast_zero]
      exact Real.rpow_nonneg le_rfl _
    · have h1 : low l 0 Y ≤ 1 := by
        have := low_mono_right l 0 (show Y ≤ 2 * 3 ^ 0 by simpa using hY)
        rw [low_period] at this
        exact this.trans (card_tree_zero_le hl)
      have h2 : (1 : ℝ) ≤ (Y : ℝ) ^ Real.logb 3 2 :=
        Real.one_le_rpow (by exact_mod_cast hY0) alpha_nonneg
      calc (low l 0 Y : ℝ) ≤ 1 := by exact_mod_cast h1
        _ ≤ _ := h2
  | k + 1, Y, hY => by
    have hα0 := alpha_nonneg
    by_cases hA : Y ≤ 2 * 3 ^ k
    · calc (low l (k + 1) Y : ℝ) ≤ low l k Y := by exact_mod_cast low_succ_le l k Y
        _ ≤ _ := low_le_rpow hl k Y hA
    by_cases hB : 3 ^ (k + 1) ≤ Y
    · have h1 : low l (k + 1) Y ≤ 2 ^ (k + 1) := by
        have := low_mono_right l (k + 1) hY
        rw [low_period] at this
        exact this.trans (card_tree_le hl (k + 1))
      have h2 : ((3 : ℝ) ^ (k + 1)) ^ Real.logb 3 2 ≤ (Y : ℝ) ^ Real.logb 3 2 :=
        Real.rpow_le_rpow (by positivity) (by exact_mod_cast hB) hα0
      rw [three_pow_rpow] at h2
      calc (low l (k + 1) Y : ℝ) ≤ ((2 ^ (k + 1) : ℕ) : ℝ) := by exact_mod_cast h1
        _ = 2 ^ (k + 1) := by push_cast; ring
        _ ≤ _ := h2
    set s := Y - 2 * 3 ^ k with hsdef
    have h3k : 3 ^ (k + 1) = 3 * 3 ^ k := by ring
    have hs1 : s < 3 ^ k := by omega
    have hYs : Y = 2 * 3 ^ k + s := by omega
    have hcount : low l (k + 1) Y ≤ 2 ^ k + low l k s := by
      have := low_add_le l k s
      rw [← hYs] at this
      exact (low_succ_le l k Y).trans (this.trans (Nat.add_le_add_right (card_tree_le hl k) _))
    have hIH := low_le_rpow hl k s (by omega)
    have hkar := concave_two_point (Real.concaveOn_rpow hα0 alpha_le_one)
      (a := (Y : ℝ)) (b := (3 : ℝ) ^ k) (c := (s : ℝ)) (d := (3 : ℝ) ^ (k + 1))
      (Nat.cast_nonneg s)
      (by exact_mod_cast (by omega : s ≤ Y))
      (by exact_mod_cast (by omega : Y ≤ 3 ^ (k + 1)))
      (by exact_mod_cast hs1.le)
      (by exact_mod_cast (by omega : 3 ^ k ≤ 3 ^ (k + 1)))
      (by rw [hYs]; push_cast; ring)
    simp only [three_pow_rpow] at hkar
    calc (low l (k + 1) Y : ℝ) ≤ ((2 ^ k + low l k s : ℕ) : ℝ) := by exact_mod_cast hcount
      _ = 2 ^ k + (low l k s : ℝ) := by push_cast; ring
      _ ≤ _ := by rw [pow_succ] at hkar; linarith

/-- **Sharp counting bound for a multiplier.** For every natural `l` with `3 ∤ l` and every `X ≥ 0`,
`#{0 ≤ n ≤ X : 2 ∉ Nat.digits 3 (l·2^n)} ≤ (X+1)^(log₃ 2)`. -/
theorem card_noTwo_mul_le_succ_rpow (l : ℕ) (hl : ¬ 3 ∣ l) (X : ℕ) :
    (((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (l * 2 ^ n))).card : ℝ) ≤
      ((X : ℝ) + 1) ^ Real.logb 3 2 := by
  have hX : X + 1 ≤ 2 * 3 ^ X := by
    have := Nat.lt_pow_self (by norm_num : 1 < 3) (n := X)
    omega
  have hsub : ((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (l * 2 ^ n))).card ≤
      low l X (X + 1) := by
    apply Finset.card_le_card
    intro n hn
    simp only [Finset.mem_filter, Finset.mem_range] at hn ⊢
    exact ⟨hn.1, fun i _ => trit_ne_two_of_not_mem hn.2 i⟩
  have := low_le_rpow hl X (X + 1) hX
  push_cast at this
  calc _ ≤ (low l X (X + 1) : ℝ) := by exact_mod_cast hsub
    _ ≤ _ := this

/-- `l = 1` recovers `Counting.card_noTwo_le_succ_rpow` (statement for statement). -/
theorem card_noTwo_le_succ_rpow_of_lambda (X : ℕ) :
    (((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card : ℝ) ≤
      ((X : ℝ) + 1) ^ Real.logb 3 2 := by
  simpa using card_noTwo_mul_le_succ_rpow 1 (by norm_num) X

end CountingLambda
end ErdosTernary
