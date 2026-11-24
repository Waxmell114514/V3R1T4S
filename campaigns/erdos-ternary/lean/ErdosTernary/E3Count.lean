/- g003-L02: the finite content of Lagarias' Theorem 1.7 (arXiv:math/0512006) for the E^(3)-component
   C(1, 2^2, 2^18), restricted to natural numbers. See proofs/g003-L02.md. Tier A: no native_decide.

   Mechanism: concatenate the witness block N = 532261 (lagarias_witness_4_pow18, E4.lean). Since
   N, 4N, 2^18·N < 3^24, the numbers x = Σ_{j<J} ε_j · N · 3^(24 j) (ε ∈ {0,1}^J) have x, 4x, 2^18·x
   all free of the ternary digit 2 (the block products do not overlap, so there are no carries).

   * `noTwo_add_mul_pow` (block concatenation lemma): KNOWN-style, elementary.
   * `card_ge_of_witness` (general N, L): the count bound for any Theorem 1.7 witness of C(1, 4, 2^18).
   * `e3_count_4_pow18`: 2^J ≤ #{x < 3^(24 J) : x, 4x, 2^18·x have no ternary digit 2}, for all J.
   NOT formalized: the step "therefore dim_H C(1, 2^2, 2^18) ≥ log_3 2 / 24" (no 3-adic Hausdorff
   dimension theory in Mathlib). -/
import Statement
import ErdosTernary.E4

namespace ErdosTernary
namespace E3Count

/-- Block concatenation: if `a < 3^L` and neither `a` nor `c` has the ternary digit 2, then
`a + 3^L * c` (the digits of `a`, padded to length `L`, followed by those of `c`) has none either. -/
theorem noTwo_add_mul_pow :
    ∀ (L a c : ℕ), a < 3 ^ L → 2 ∉ Nat.digits 3 a → 2 ∉ Nat.digits 3 c →
      2 ∉ Nat.digits 3 (a + 3 ^ L * c)
  | 0, a, c, ha, _, hc => by
    have : a = 0 := by simpa using ha
    subst this; simpa using hc
  | L + 1, a, c, ha, hda, hc => by
    set P := 3 ^ L * c with hP
    have hsplit : a + 3 ^ (L + 1) * c = a + 3 * P := by rw [hP, pow_succ]; ring
    rw [hsplit]
    by_cases h0 : a + 3 * P = 0
    · rw [h0]; simp
    have hmod : (a + 3 * P) % 3 = a % 3 := by omega
    have hdiv : (a + 3 * P) / 3 = a / 3 + 3 ^ L * c := by rw [hP]; omega
    rw [Nat.digits_def' (by norm_num) (Nat.pos_of_ne_zero h0), hmod, hdiv]
    have hQ : a < 3 * 3 ^ L := by rwa [pow_succ, mul_comm] at ha
    have hlt : a / 3 < 3 ^ L := by omega
    by_cases ha0 : a = 0
    · subst ha0
      simp only [Nat.zero_mod, Nat.zero_div, List.mem_cons, not_or]
      exact ⟨by norm_num, noTwo_add_mul_pow L 0 c hlt (by simp) hc⟩
    · rw [Nat.digits_def' (by norm_num) (Nat.pos_of_ne_zero ha0)] at hda
      simp only [List.mem_cons, not_or] at hda ⊢
      exact ⟨hda.1, noTwo_add_mul_pow L (a / 3) c hlt hda.2 hc⟩

/-- The three digit conditions defining `C(1, 2^2, 2^18) ∩ ℕ`. -/
theorem good_step (N L a c : ℕ) (h1 : N < 3 ^ L) (h4 : 4 * N < 3 ^ L) (h18 : 2 ^ 18 * N < 3 ^ L)
    (hd1 : 2 ∉ Nat.digits 3 N) (hd4 : 2 ∉ Nat.digits 3 (4 * N))
    (hd18 : 2 ∉ Nat.digits 3 (2 ^ 18 * N)) (ha : a = 0 ∨ a = N)
    (hc : 2 ∉ Nat.digits 3 c ∧ 2 ∉ Nat.digits 3 (4 * c) ∧ 2 ∉ Nat.digits 3 (2 ^ 18 * c)) :
    2 ∉ Nat.digits 3 (a + 3 ^ L * c) ∧ 2 ∉ Nat.digits 3 (4 * (a + 3 ^ L * c)) ∧
      2 ∉ Nat.digits 3 (2 ^ 18 * (a + 3 ^ L * c)) := by
  have e4 : 4 * (a + 3 ^ L * c) = 4 * a + 3 ^ L * (4 * c) := by ring
  have e18 : 2 ^ 18 * (a + 3 ^ L * c) = 2 ^ 18 * a + 3 ^ L * (2 ^ 18 * c) := by ring
  rw [e4, e18]
  rcases ha with rfl | rfl
  · have z := fun c' (h : 2 ∉ Nat.digits 3 c') =>
      noTwo_add_mul_pow L 0 c' (by positivity) (by simp) h
    simp only [mul_zero, zero_add] at z ⊢
    exact ⟨z c hc.1, z _ hc.2.1, z _ hc.2.2⟩
  · exact ⟨noTwo_add_mul_pow L _ c h1 hd1 hc.1, noTwo_add_mul_pow L _ _ h4 hd4 hc.2.1,
      noTwo_add_mul_pow L _ _ h18 hd18 hc.2.2⟩

/-- Theorem 1.7, finite form, for any witness `N` of `C(1, 4, 2^18)` with block length `L`:
at least `2^J` numbers below `3^(L·J)` lie in `C(1, 4, 2^18)`. -/
theorem card_ge_of_witness (N L : ℕ) (hN0 : 0 < N) (h4 : 4 * N < 3 ^ L)
    (h18 : 2 ^ 18 * N < 3 ^ L) (hd1 : 2 ∉ Nat.digits 3 N) (hd4 : 2 ∉ Nat.digits 3 (4 * N))
    (hd18 : 2 ∉ Nat.digits 3 (2 ^ 18 * N)) (J : ℕ) :
    2 ^ J ≤ ((Finset.range (3 ^ (L * J))).filter (fun x => 2 ∉ Nat.digits 3 x ∧
      2 ∉ Nat.digits 3 (4 * x) ∧ 2 ∉ Nat.digits 3 (2 ^ 18 * x))).card := by
  have h1 : N < 3 ^ L := by omega
  have hpos : 0 < 3 ^ L := by positivity
  induction J with
  | zero =>
    simp only [pow_zero, mul_zero]
    apply Finset.card_pos.mpr
    exact ⟨0, by simp⟩
  | succ J ih =>
    set G := (Finset.range (3 ^ (L * J))).filter (fun x => 2 ∉ Nat.digits 3 x ∧
      2 ∉ Nat.digits 3 (4 * x) ∧ 2 ∉ Nat.digits 3 (2 ^ 18 * x)) with hG
    let f : ℕ → ℕ → ℕ := fun a c => a + 3 ^ L * c
    have hinj : ∀ a, Function.Injective (f a) := by
      intro a c c' h
      exact Nat.eq_of_mul_eq_mul_left hpos (Nat.add_left_cancel h)
    have hdisj : Disjoint (G.image (f 0)) (G.image (f N)) := by
      rw [Finset.disjoint_left]
      intro x hx hx'
      obtain ⟨c, -, rfl⟩ := Finset.mem_image.mp hx
      obtain ⟨c', -, hc'⟩ := Finset.mem_image.mp hx'
      have := congrArg (· % 3 ^ L) hc'
      simp only [f, zero_add, Nat.mul_mod_right, Nat.add_mul_mod_self_left,
        Nat.mod_eq_of_lt h1] at this
      omega
    have hsub : G.image (f 0) ∪ G.image (f N) ⊆
        (Finset.range (3 ^ (L * (J + 1)))).filter (fun x => 2 ∉ Nat.digits 3 x ∧
          2 ∉ Nat.digits 3 (4 * x) ∧ 2 ∉ Nat.digits 3 (2 ^ 18 * x)) := by
      have key : ∀ a, (a = 0 ∨ a = N) → ∀ x ∈ G.image (f a),
          x ∈ (Finset.range (3 ^ (L * (J + 1)))).filter (fun x => 2 ∉ Nat.digits 3 x ∧
            2 ∉ Nat.digits 3 (4 * x) ∧ 2 ∉ Nat.digits 3 (2 ^ 18 * x)) := by
        intro a ha x hx
        obtain ⟨c, hc, rfl⟩ := Finset.mem_image.mp hx
        rw [hG, Finset.mem_filter, Finset.mem_range] at hc
        rw [Finset.mem_filter, Finset.mem_range]
        refine ⟨?_, good_step N L a c h1 h4 h18 hd1 hd4 hd18 ha hc.2⟩
        have hal : a < 3 ^ L := by rcases ha with rfl | rfl <;> omega
        have hpw : 3 ^ (L * (J + 1)) = 3 ^ L * 3 ^ (L * J) := by
          rw [Nat.mul_succ, pow_add, mul_comm]
        rw [hpw]
        calc a + 3 ^ L * c < 3 ^ L + 3 ^ L * c := by omega
          _ = 3 ^ L * (c + 1) := by ring
          _ ≤ 3 ^ L * 3 ^ (L * J) := Nat.mul_le_mul_left _ hc.1
      intro x hx
      rcases Finset.mem_union.mp hx with hx | hx
      · exact key 0 (Or.inl rfl) x hx
      · exact key N (Or.inr rfl) x hx
    calc 2 ^ (J + 1) = 2 ^ J + 2 ^ J := by ring
      _ ≤ G.card + G.card := Nat.add_le_add ih ih
      _ = (G.image (f 0)).card + (G.image (f N)).card := by
        rw [Finset.card_image_of_injective _ (hinj 0), Finset.card_image_of_injective _ (hinj N)]
      _ = (G.image (f 0) ∪ G.image (f N)).card := (Finset.card_union_of_disjoint hdisj).symm
      _ ≤ _ := Finset.card_le_card hsub

/-- **Main theorem (g003-L02).** For every `J`, at least `2^J` natural numbers `x < 3^(24·J)` have
`x`, `4x` and `2^18·x` all free of the ternary digit 2 (concatenations of the block 532261). -/
theorem e3_count_4_pow18 (J : ℕ) :
    2 ^ J ≤ ((Finset.range (3 ^ (24 * J))).filter (fun x => 2 ∉ Nat.digits 3 x ∧
      2 ∉ Nat.digits 3 (4 * x) ∧ 2 ∉ Nat.digits 3 (2 ^ 18 * x))).card := by
  obtain ⟨hd1, hd4, hd18⟩ := lagarias_witness_4_pow18
  exact card_ge_of_witness 532261 24 (by norm_num) (by norm_num) (by norm_num) hd1
    (by rw [show (4 : ℕ) = 2 ^ 2 by norm_num]; exact hd4) hd18 J

end E3Count
end ErdosTernary
