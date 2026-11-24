/- g002-L02: counting upper bounds for A(X) = #{n ≤ X : 2 ∉ Nat.digits 3 (2^n)} from the low-trit
   residue tree (g0-baseline lemma 3). See proofs/g002-L02.md. Tier A: no native_decide.
   * `card_noTwo_le` (X < 2·3^k ⇒ A(X) ≤ 2^k): KNOWN (Narkiewicz 1980 via Lagarias 2009 Thm 1.4 /
     step (3.3); Holdum–Klausen–Rasmussen, Integers 15 (2015) A43, Lemma 2.12, per specs/narkiewicz1980.md).
   * `card_noTwo_le_rpow` (A(X) ≤ 2·(X/2)^(log₃ 2) for X ≥ 2): an immediate consequence of the known form.
   * `card_noTwo_le_succ_rpow` (A(X) ≤ (X+1)^(log₃ 2) for all X, constant 1, sharp at X = 0, 2): not found
     in the literature by Researcher g002-R03; novelty to be judged separately. -/
import Statement
import Mathlib.Analysis.SpecialFunctions.Log.Base
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.Convex.SpecificFunctions.Pow

namespace ErdosTernary
namespace Counting

/-! ### Digits and the trit `m / 3^i % 3` -/

/-- If `m / 3^i ≠ 0`, its last trit is a base-3 digit of `m`. -/
theorem trit_mem_digits : ∀ (i m : ℕ), m / 3 ^ i ≠ 0 → m / 3 ^ i % 3 ∈ Nat.digits 3 m
  | 0, m, h => by
    have hm : 0 < m := by simpa using Nat.pos_of_ne_zero h
    rw [Nat.digits_def' (by norm_num) hm]
    simp
  | i + 1, m, h => by
    have h' : m / 3 / 3 ^ i ≠ 0 := by
      rwa [Nat.div_div_eq_div_mul, ← pow_succ']
    have hm : 0 < m := by
      rcases Nat.eq_zero_or_pos m with rfl | hm
      · simp at h
      · exact hm
    rw [Nat.digits_def' (by norm_num) hm, pow_succ', ← Nat.div_div_eq_div_mul]
    exact List.mem_cons_of_mem _ (trit_mem_digits i (m / 3) h')

/-- A number with no base-3 digit 2 has no trit equal to 2. -/
theorem trit_ne_two_of_not_mem {m : ℕ} (h : 2 ∉ Nat.digits 3 m) (i : ℕ) : m / 3 ^ i % 3 ≠ 2 := by
  intro h2
  by_cases h0 : m / 3 ^ i = 0
  · rw [h0] at h2; simp at h2
  · exact h (h2 ▸ trit_mem_digits i m h0)

/-- The trit at position `i < k` only depends on the residue mod `3^k`. -/
theorem trit_mod (a i k : ℕ) (hi : i < k) : a % 3 ^ k / 3 ^ i % 3 = a / 3 ^ i % 3 := by
  have hk : 3 ^ k = 3 ^ i * 3 ^ (k - i) := by rw [← pow_add]; congr 1; omega
  rw [hk, Nat.mod_mul_right_div_self]
  exact Nat.mod_mod_of_dvd _ (dvd_pow_self 3 (by omega))

theorem trit_eq_of_mod_eq {a b i k : ℕ} (h : a % 3 ^ k = b % 3 ^ k) (hi : i < k) :
    a / 3 ^ i % 3 = b / 3 ^ i % 3 := by
  rw [← trit_mod a i k hi, ← trit_mod b i k hi, h]

/-! ### The order of 2 modulo powers of 3 -/

/-- `4^(3^k) = 1 + 3^(k+1) t` with `3 ∤ t` (lifting the exponent, by hand). -/
theorem four_pow_three_pow (k : ℕ) : ∃ t, 4 ^ 3 ^ k = 1 + 3 ^ (k + 1) * t ∧ ¬ 3 ∣ t := by
  induction k with
  | zero => exact ⟨1, by norm_num, by norm_num⟩
  | succ k ih =>
    obtain ⟨t, ht, h3⟩ := ih
    refine ⟨t + 3 * (3 ^ k * t ^ 2 + 3 ^ (2 * k) * t ^ 3), ?_, ?_⟩
    · rw [pow_succ, pow_mul, ht]; ring
    · intro hd
      exact h3 ((Nat.dvd_add_left (dvd_mul_right 3 _)).mp hd)

/-- For `j ∈ {1, 2}`: `2^(j · 2·3^k) = 1 + 3^(k+1) u` with `3 ∤ u`. -/
theorem two_pow_period_mul (k j : ℕ) (hj1 : 1 ≤ j) (hj2 : j ≤ 2) :
    ∃ u, 2 ^ (j * (2 * 3 ^ k)) = 1 + 3 ^ (k + 1) * u ∧ ¬ 3 ∣ u := by
  obtain ⟨t, ht, h3⟩ := four_pow_three_pow k
  have h4 : 2 ^ (j * (2 * 3 ^ k)) = (4 ^ 3 ^ k) ^ j := by
    rw [← pow_mul, show (4 : ℕ) = 2 ^ 2 by norm_num, ← pow_mul]; ring_nf
  interval_cases j
  · exact ⟨t, by rw [h4, ht, pow_one], h3⟩
  · refine ⟨2 * t + 3 ^ (k + 1) * t ^ 2, by rw [h4, ht]; ring, ?_⟩
    intro hd
    have h' : 3 ∣ 2 * t := (Nat.dvd_add_left (dvd_mul_of_dvd_left
      (dvd_pow_self 3 (Nat.succ_ne_zero k)) _)).mp hd
    exact h3 ((Nat.Coprime.dvd_mul_left (by decide)).mp h')

theorem two_pow_period_modEq (k : ℕ) : 2 ^ (2 * 3 ^ k) ≡ 1 [MOD 3 ^ (k + 1)] := by
  obtain ⟨u, hu, -⟩ := two_pow_period_mul k 1 le_rfl (by norm_num)
  rw [one_mul] at hu
  rw [hu]
  refine ((Nat.modEq_iff_dvd' (Nat.le_add_right 1 _)).mpr ?_).symm
  simp

theorem two_pow_period_not_modEq (k j : ℕ) (hj1 : 1 ≤ j) (hj2 : j ≤ 2) :
    ¬ 2 ^ (j * (2 * 3 ^ k)) ≡ 1 [MOD 3 ^ (k + 2)] := by
  obtain ⟨u, hu, h3⟩ := two_pow_period_mul k j hj1 hj2
  rw [hu]
  intro h
  have hd : 3 ^ (k + 2) ∣ 3 ^ (k + 1) * u := by
    have := (Nat.modEq_iff_dvd' (Nat.le_add_right 1 _)).mp h.symm
    simpa using this
  rw [pow_succ 3 (k + 1)] at hd
  exact h3 (Nat.dvd_of_mul_dvd_mul_left (by positivity) hd)

/-- `2^n mod 3^(k+1)` depends only on `n mod 2·3^k`. -/
theorem two_pow_mod_period (k n : ℕ) :
    2 ^ n % 3 ^ (k + 1) = 2 ^ (n % (2 * 3 ^ k)) % 3 ^ (k + 1) := by
  have h : 2 ^ n = 2 ^ (n % (2 * 3 ^ k)) * (2 ^ (2 * 3 ^ k)) ^ (n / (2 * 3 ^ k)) := by
    rw [← pow_mul, ← pow_add, Nat.mod_add_div]
  have := ((two_pow_period_modEq k).pow (n / (2 * 3 ^ k))).mul_left (2 ^ (n % (2 * 3 ^ k)))
  rw [one_pow, mul_one, ← h] at this
  exact this

/-! ### The residue tree -/

/-- Residues `r < 2·3^k` such that the low `k+1` trits of `2^r` avoid 2. -/
def tree (k : ℕ) : Finset ℕ :=
  (Finset.range (2 * 3 ^ k)).filter (fun r => ∀ i < k + 1, 2 ^ r / 3 ^ i % 3 ≠ 2)

theorem mem_tree {k r : ℕ} :
    r ∈ tree k ↔ r < 2 * 3 ^ k ∧ ∀ i < k + 1, 2 ^ r / 3 ^ i % 3 ≠ 2 := by
  simp [tree]

/-- Lemma 3 (upper half): each node has at most two children. -/
theorem card_tree_succ_le (k : ℕ) : (tree (k + 1)).card ≤ 2 * (tree k).card := by
  set P := 2 * 3 ^ k with hP
  have hP3 : 2 * 3 ^ (k + 1) = 3 * P := by rw [hP, pow_succ]; ring
  have hPpos : 0 < P := by positivity
  -- trits below k+1 are P-periodic
  have per : ∀ r i, i < k + 1 → 2 ^ r / 3 ^ i % 3 = 2 ^ (r % P) / 3 ^ i % 3 :=
    fun r i hi => trit_eq_of_mod_eq (two_pow_mod_period k r) hi
  apply Finset.card_le_mul_card_image_of_maps_to (f := fun r => r % P)
  · intro r hr
    rw [mem_tree] at hr ⊢
    refine ⟨Nat.mod_lt _ hPpos, fun i hi => ?_⟩
    rw [← per r i hi]
    exact hr.2 i (by omega)
  · intro r0 hr0
    rw [mem_tree] at hr0
    set F := (tree (k + 1)).filter (fun r => r % P = r0)
    have hsub : F ⊆ {r0, r0 + P, r0 + 2 * P} := by
      intro r hr
      simp only [F, Finset.mem_filter, mem_tree] at hr
      have hq : r / P < 3 := by
        rw [Nat.div_lt_iff_lt_mul hPpos]; rw [hP3] at hr; linarith [hr.1.1]
      have hr' : r = r0 + P * (r / P) := by rw [← hr.2]; exact (Nat.mod_add_div r P).symm
      simp only [Finset.mem_insert, Finset.mem_singleton]
      interval_cases h : r / P <;> omega
    -- trit k+1 of the three lifts
    have hnot : ¬ ({r0, r0 + P, r0 + 2 * P} : Finset ℕ) ⊆ F := by
      intro hall
      have good : ∀ j, j ≤ 2 → 2 ^ (r0 + j * P) / 3 ^ (k + 1) % 3 ≠ 2 := by
        intro j hj
        have hmem : r0 + j * P ∈ F := by
          apply hall
          interval_cases j <;> simp
        simp only [F, Finset.mem_filter, mem_tree] at hmem
        exact hmem.1.2 (k + 1) (by omega)
      -- low k+1 trits agree for all lifts
      have low : ∀ j, 2 ^ (r0 + j * P) % 3 ^ (k + 1) = 2 ^ r0 % 3 ^ (k + 1) := by
        intro j
        rw [two_pow_mod_period k (r0 + j * P), two_pow_mod_period k r0]
        congr 2
        rw [Nat.add_mul_mod_self_right]
      have sep : ∀ j j', j < j' → j' ≤ 2 →
          2 ^ (r0 + j * P) / 3 ^ (k + 1) % 3 ≠ 2 ^ (r0 + j' * P) / 3 ^ (k + 1) % 3 := by
        intro j j' hjj hj' heq
        have hm : 2 ^ (r0 + j * P) * 1 ≡ 2 ^ (r0 + j * P) * 2 ^ ((j' - j) * P) [MOD 3 ^ (k + 2)] := by
          rw [mul_one, ← pow_add, show r0 + j * P + (j' - j) * P = r0 + j' * P by
            rw [add_assoc, ← add_mul]; congr 2; omega]
          unfold Nat.ModEq
          rw [Nat.mod_pow_succ, Nat.mod_pow_succ (x := 2 ^ (r0 + j' * P)), low j, low j', heq]
        have hc := Nat.ModEq.cancel_left_of_coprime
          (Nat.Coprime.pow _ _ (by decide : Nat.Coprime 3 2)) hm
        exact two_pow_period_not_modEq k (j' - j) (by omega) (by omega) hc.symm
      have g0 := good 0 (by norm_num)
      have g1 := good 1 (by norm_num)
      have g2 := good 2 le_rfl
      have s01 := sep 0 1 (by norm_num) (by norm_num)
      have s02 := sep 0 2 (by norm_num) le_rfl
      have s12 := sep 1 2 (by norm_num) le_rfl
      have l0 := Nat.mod_lt (2 ^ (r0 + 0 * P) / 3 ^ (k + 1)) (by norm_num : 0 < 3)
      have l1 := Nat.mod_lt (2 ^ (r0 + 1 * P) / 3 ^ (k + 1)) (by norm_num : 0 < 3)
      have l2 := Nat.mod_lt (2 ^ (r0 + 2 * P) / 3 ^ (k + 1)) (by norm_num : 0 < 3)
      omega
    have h3 : ({r0, r0 + P, r0 + 2 * P} : Finset ℕ).card ≤ 3 := Finset.card_le_three
    by_contra hc
    rw [not_le] at hc
    exact hnot (Finset.eq_of_subset_of_card_le hsub (by omega)).symm.subset

theorem card_tree_zero : (tree 0).card = 1 := by decide

/-- Corollary 4 (upper bound form): the tree has at most `2^k` nodes at depth `k+1`. -/
theorem card_tree_le (k : ℕ) : (tree k).card ≤ 2 ^ k := by
  induction k with
  | zero => rw [card_tree_zero]; norm_num
  | succ k ih => calc
      (tree (k + 1)).card ≤ 2 * (tree k).card := card_tree_succ_le k
      _ ≤ 2 * 2 ^ k := by omega
      _ = 2 ^ (k + 1) := by ring

/-! ### Main theorems -/

/-- **Main theorem (finite form).** If `X < 2·3^k`, then at most `2^k` of the `n ≤ X` have `2^n` free of
the ternary digit 2. -/
theorem card_noTwo_le (k X : ℕ) (hX : X < 2 * 3 ^ k) :
    ((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card ≤ 2 ^ k := by
  refine le_trans (Finset.card_le_card ?_) (card_tree_le k)
  intro n hn
  simp only [Finset.mem_filter, Finset.mem_range] at hn
  rw [mem_tree]
  exact ⟨by omega, fun i _ => trit_ne_two_of_not_mem hn.2 i⟩

/-- **Real-exponent corollary.** For `X ≥ 2`, `A(X) ≤ 2 · (X/2)^(log₃ 2)` (≈ 1.2915 · X^(log₃ 2)). -/
theorem card_noTwo_le_rpow (X : ℕ) (hX : 2 ≤ X) :
    (((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card : ℝ) ≤
      2 * ((X : ℝ) / 2) ^ Real.logb 3 2 := by
  set m := X / 2 with hm
  have hm1 : 1 ≤ m := by omega
  set j := Nat.log 3 m
  have hlo : 3 ^ j ≤ m := Nat.pow_log_le_self 3 (by omega)
  have hhi : m < 3 ^ (j + 1) := Nat.lt_pow_succ_log_self (by norm_num) m
  have hX' : X < 2 * 3 ^ (j + 1) := by omega
  have hcard := card_noTwo_le (j + 1) X hX'
  have hreal : ((3 : ℝ) ^ j) ≤ (X : ℝ) / 2 := by
    rw [le_div_iff₀ (by norm_num)]
    exact_mod_cast (by omega : 3 ^ j * 2 ≤ X)
  have hpow : ((3 : ℝ) ^ j) ^ Real.logb 3 2 = 2 ^ j := by
    rw [← Real.rpow_natCast, ← Real.rpow_mul (by norm_num), mul_comm, Real.rpow_mul (by norm_num),
      Real.rpow_logb (by norm_num) (by norm_num) (by norm_num), Real.rpow_natCast]
  have hmono : ((3 : ℝ) ^ j) ^ Real.logb 3 2 ≤ ((X : ℝ) / 2) ^ Real.logb 3 2 :=
    Real.rpow_le_rpow (by positivity) hreal
      (Real.logb_nonneg (by norm_num) (by norm_num))
  calc (((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card : ℝ)
      ≤ ((2 ^ (j + 1) : ℕ) : ℝ) := by exact_mod_cast hcard
    _ = 2 * ((3 : ℝ) ^ j) ^ Real.logb 3 2 := by rw [hpow]; push_cast; ring
    _ ≤ 2 * ((X : ℝ) / 2) ^ Real.logb 3 2 := by linarith

/-! ### The sharp form `A(X) ≤ (X+1)^(log₃ 2)` (uses where the residues sit, not only how many) -/

/-- Number of `r < Y` whose power `2^r` has its low `k+1` trits free of 2. -/
def low (k Y : ℕ) : ℕ :=
  ((Finset.range Y).filter (fun r => ∀ i < k + 1, 2 ^ r / 3 ^ i % 3 ≠ 2)).card

theorem low_period (k : ℕ) : low k (2 * 3 ^ k) = (tree k).card := rfl

theorem low_mono_right (k : ℕ) {Y Y' : ℕ} (h : Y ≤ Y') : low k Y ≤ low k Y' := by
  apply Finset.card_le_card
  intro r hr
  simp only [Finset.mem_filter, Finset.mem_range] at hr ⊢
  exact ⟨by omega, hr.2⟩

theorem low_succ_le (k Y : ℕ) : low (k + 1) Y ≤ low k Y := by
  apply Finset.card_le_card
  intro r hr
  simp only [Finset.mem_filter, Finset.mem_range] at hr ⊢
  exact ⟨hr.1, fun i hi => hr.2 i (by omega)⟩

theorem good_iff_mod (k r : ℕ) : (∀ i < k + 1, 2 ^ r / 3 ^ i % 3 ≠ 2) ↔
    (∀ i < k + 1, 2 ^ (r % (2 * 3 ^ k)) / 3 ^ i % 3 ≠ 2) := by
  constructor <;> intro h i hi
  · rw [← trit_eq_of_mod_eq (two_pow_mod_period k r) hi]; exact h i hi
  · rw [trit_eq_of_mod_eq (two_pow_mod_period k r) hi]; exact h i hi

/-- One period plus a partial period. -/
theorem low_add_le (k s : ℕ) :
    low k (2 * 3 ^ k + s) ≤ (tree k).card + low k s := by
  set P := 2 * 3 ^ k with hP
  have hsub : (Finset.range (P + s)).filter (fun r => ∀ i < k + 1, 2 ^ r / 3 ^ i % 3 ≠ 2) ⊆
      tree k ∪ ((Finset.range s).filter (fun r => ∀ i < k + 1, 2 ^ r / 3 ^ i % 3 ≠ 2)).image
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

/-- Two-point majorization for a concave function. -/
theorem concave_two_point {g : ℝ → ℝ} (hg : ConcaveOn ℝ (Set.Ici 0) g) {a b c d : ℝ}
    (hc : 0 ≤ c) (hca : c ≤ a) (had : a ≤ d) (hcb : c ≤ b) (hbd : b ≤ d) (hs : a + b = c + d) :
    g c + g d ≤ g a + g b := by
  rcases eq_or_lt_of_le (hca.trans had) with h | h
  · have ha : a = c := by linarith
    have hb : b = c := by linarith
    rw [ha, hb, ← h]
  · have hdc : 0 < d - c := by linarith
    have hcm : c ∈ Set.Ici (0 : ℝ) := hc
    have hdm : d ∈ Set.Ici (0 : ℝ) := by simp only [Set.mem_Ici]; linarith
    have hl : 0 ≤ (d - a) / (d - c) := div_nonneg (by linarith) hdc.le
    have hm : 0 ≤ (a - c) / (d - c) := div_nonneg (by linarith) hdc.le
    have h1 := hg.2 hcm hdm hl hm (by field_simp; ring)
    have h2 := hg.2 hcm hdm hm hl (by field_simp; ring)
    simp only [smul_eq_mul] at h1 h2
    have ea : (d - a) / (d - c) * c + (a - c) / (d - c) * d = a := by field_simp; ring
    have eb : (a - c) / (d - c) * c + (d - a) / (d - c) * d = b := by
      rw [show b = c + d - a by linarith]; field_simp; ring
    rw [ea] at h1
    rw [eb] at h2
    have hsum : (d - a) / (d - c) + (a - c) / (d - c) = 1 := by field_simp; ring
    have key : g c + g d = ((d - a) / (d - c) * g c + (a - c) / (d - c) * g d) +
        ((a - c) / (d - c) * g c + (d - a) / (d - c) * g d) := by
      linear_combination (-(g c + g d)) * hsum
    linarith [key, h1, h2]

theorem alpha_nonneg : 0 ≤ Real.logb 3 2 := Real.logb_nonneg (by norm_num) (by norm_num)

theorem alpha_le_one : Real.logb 3 2 ≤ 1 :=
  (Real.logb_le_iff_le_rpow (by norm_num) (by norm_num)).mpr (by norm_num)

theorem three_pow_rpow (n : ℕ) : ((3 : ℝ) ^ n) ^ Real.logb 3 2 = 2 ^ n := by
  rw [← Real.rpow_natCast, ← Real.rpow_mul (by norm_num), mul_comm, Real.rpow_mul (by norm_num),
    Real.rpow_logb (by norm_num) (by norm_num) (by norm_num), Real.rpow_natCast]

/-- The partial-period counts are bounded by `Y^(log₃ 2)` on a whole period. -/
theorem low_le_rpow : ∀ (k Y : ℕ), Y ≤ 2 * 3 ^ k → (low k Y : ℝ) ≤ (Y : ℝ) ^ Real.logb 3 2
  | 0, Y, hY => by
    rcases Nat.eq_zero_or_pos Y with rfl | hY0
    · have h0 : low 0 0 = 0 := rfl
      rw [h0, Nat.cast_zero]
      exact Real.rpow_nonneg le_rfl _
    · have h1 : low 0 Y ≤ 1 := by
        have := low_mono_right 0 (show Y ≤ 2 * 3 ^ 0 by simpa using hY)
        rwa [low_period, card_tree_zero] at this
      have h2 : (1 : ℝ) ≤ (Y : ℝ) ^ Real.logb 3 2 :=
        Real.one_le_rpow (by exact_mod_cast hY0) alpha_nonneg
      calc (low 0 Y : ℝ) ≤ 1 := by exact_mod_cast h1
        _ ≤ _ := h2
  | k + 1, Y, hY => by
    have hα0 := alpha_nonneg
    by_cases hA : Y ≤ 2 * 3 ^ k
    · calc (low (k + 1) Y : ℝ) ≤ low k Y := by exact_mod_cast low_succ_le k Y
        _ ≤ _ := low_le_rpow k Y hA
    by_cases hB : 3 ^ (k + 1) ≤ Y
    · have h1 : low (k + 1) Y ≤ 2 ^ (k + 1) := by
        have := low_mono_right (k + 1) hY
        rw [low_period] at this
        exact this.trans (card_tree_le (k + 1))
      have h2 : ((3 : ℝ) ^ (k + 1)) ^ Real.logb 3 2 ≤ (Y : ℝ) ^ Real.logb 3 2 :=
        Real.rpow_le_rpow (by positivity) (by exact_mod_cast hB) hα0
      rw [three_pow_rpow] at h2
      calc (low (k + 1) Y : ℝ) ≤ ((2 ^ (k + 1) : ℕ) : ℝ) := by exact_mod_cast h1
        _ = 2 ^ (k + 1) := by push_cast; ring
        _ ≤ _ := h2
    -- 2·3^k < Y < 3^(k+1): one full period plus a short partial period s < 3^k
    set s := Y - 2 * 3 ^ k with hsdef
    have h3k : 3 ^ (k + 1) = 3 * 3 ^ k := by ring
    have hs1 : s < 3 ^ k := by omega
    have hYs : Y = 2 * 3 ^ k + s := by omega
    have hcount : low (k + 1) Y ≤ 2 ^ k + low k s := by
      have := low_add_le k s
      rw [← hYs] at this
      exact (low_succ_le k Y).trans (this.trans (Nat.add_le_add_right (card_tree_le k) _))
    have hIH := low_le_rpow k s (by omega)
    have hkar := concave_two_point (Real.concaveOn_rpow hα0 alpha_le_one)
      (a := (Y : ℝ)) (b := (3 : ℝ) ^ k) (c := (s : ℝ)) (d := (3 : ℝ) ^ (k + 1))
      (Nat.cast_nonneg s)
      (by exact_mod_cast (by omega : s ≤ Y))
      (by exact_mod_cast (by omega : Y ≤ 3 ^ (k + 1)))
      (by exact_mod_cast hs1.le)
      (by exact_mod_cast (by omega : 3 ^ k ≤ 3 ^ (k + 1)))
      (by rw [hYs]; push_cast; ring)
    simp only [three_pow_rpow] at hkar
    calc (low (k + 1) Y : ℝ) ≤ ((2 ^ k + low k s : ℕ) : ℝ) := by exact_mod_cast hcount
      _ = 2 ^ k + (low k s : ℝ) := by push_cast; ring
      _ ≤ _ := by rw [pow_succ] at hkar; linarith

/-- **Sharp counting bound.** For every `X ≥ 0`, `A(X) ≤ (X+1)^(log₃ 2)`.
Equality holds at `X = 0` and `X = 2`. -/
theorem card_noTwo_le_succ_rpow (X : ℕ) :
    (((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card : ℝ) ≤
      ((X : ℝ) + 1) ^ Real.logb 3 2 := by
  have hX : X + 1 ≤ 2 * 3 ^ X := by
    have := Nat.lt_pow_self (by norm_num : 1 < 3) (n := X)
    omega
  have hsub : ((Finset.range (X + 1)).filter (fun n => 2 ∉ Nat.digits 3 (2 ^ n))).card ≤
      low X (X + 1) := by
    apply Finset.card_le_card
    intro n hn
    simp only [Finset.mem_filter, Finset.mem_range] at hn ⊢
    exact ⟨hn.1, fun i _ => trit_ne_two_of_not_mem hn.2 i⟩
  have := low_le_rpow X (X + 1) hX
  push_cast at this
  calc _ ≤ (low X (X + 1) : ℝ) := by exact_mod_cast hsub
    _ ≤ _ := this

end Counting
end ErdosTernary
