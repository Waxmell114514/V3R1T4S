/- g005-C02: soundness of the word-size-state checker `CheckerWord.checkWord` (definitions in
`ErdosTernary/Native/ETNative.lean`, precompiled).

Same tree as `CheckerShard` (g003-L01); the differences are only in how the state is computed:
* modulus `M = 3^38 < 2^63` instead of `3^40`, so the state `v = 2^r % M` is a scalar `Nat` at run time;
* `mulMod M v gh gl` (two-halves product with one conditional subtraction) instead of `v * g % M`;
  `mulMod_eq` proves it equals `v * g % M` when `g = gh * 3^19 + gl`, `gl < 3^19`;
* a single-member tail that passes level 38 is re-seeded once (`deep`) and reads 38 more trits before the
  `Checker.explore` fallback.
Main theorem: `checkWord_sound` (tier A). -/
import ErdosTernary.CheckerShard

namespace ErdosTernary

namespace CheckerWord

open Checker CheckerShard

/-! ### The two-halves product -/

theorem mulMod_gen (v gh gl B : ℕ) (hgl : gl < B) :
    (if (v / B * gl + v % B * gh) % B * B + v % B * gl < B * B
      then (v / B * gl + v % B * gh) % B * B + v % B * gl
      else (v / B * gl + v % B * gh) % B * B + v % B * gl - B * B) = v * (gh * B + gl) % (B * B) := by
  have hB : 0 < B := by omega
  have hv := Nat.mod_add_div v B
  have hvl := Nat.mod_lt v hB
  generalize v / B = vh at hv ⊢
  generalize v % B = vl at hv hvl ⊢
  subst hv
  have hX := Nat.mod_add_div (vh * gl + vl * gh) B
  have ha := Nat.mod_lt (vh * gl + vl * gh) hB
  generalize (vh * gl + vl * gh) % B = a at hX ha ⊢
  generalize (vh * gl + vl * gh) / B = c at hX
  have key : (vl + B * vh) * (gh * B + gl) = (a * B + vl * gl) + B * B * (c + vh * gh) := by
    calc (vl + B * vh) * (gh * B + gl) = vl * gl + B * (vh * gl + vl * gh) + B * B * (vh * gh) := by ring
      _ = vl * gl + B * (a + B * c) + B * B * (vh * gh) := by rw [hX]
      _ = (a * B + vl * gl) + B * B * (c + vh * gh) := by ring
  have h1 : a * B < B * B := Nat.mul_lt_mul_of_pos_right ha hB
  have h2 : vl * gl < B * B := Nat.mul_lt_mul'' hvl hgl
  rw [key, Nat.add_mul_mod_self_left]
  split_ifs with h
  · exact (Nat.mod_eq_of_lt h).symm
  · rw [Nat.mod_eq_sub_mod (by omega), Nat.mod_eq_of_lt (by omega)]

theorem B_sq : (3 : ℕ) ^ 38 = 1162261467 * 1162261467 := by norm_num

theorem mulMod_eq (v gh gl : ℕ) (hgl : gl < 1162261467) :
    mulMod (3 ^ 38) v gh gl = v * (gh * 1162261467 + gl) % 3 ^ 38 := by
  rw [B_sq]
  exact mulMod_gen v gh gl _ hgl

/-! ### Soundness -/

/-- The invariant of the table: entry `k` describes level `i + k`. -/
def LW : ℕ → List Lv → Prop
  | _, [] => True
  | i, e :: es => e.gh * 1162261467 + e.gl = 2 ^ (2 * 3 ^ i) % 3 ^ 38 ∧ e.gl < 1162261467 ∧
      e.p = 2 * 3 ^ i ∧ e.p2 = 2 * (2 * 3 ^ i) ∧ e.q3 = 3 ^ (i + 1) ∧ LW (i + 1) es

theorem table_LW : ∀ n i, LW i (table (3 ^ 38) i n) := by
  intro n
  induction n with
  | zero => intro i; simp [table, LW]
  | succ n ih =>
    intro i
    simp only [table, List.range'_succ, List.map_cons]
    refine ⟨?_, Nat.mod_lt _ (by norm_num), rfl, rfl, rfl, ih (i + 1)⟩
    rw [Nat.powMod_def, mul_comm, Nat.div_add_mod]

theorem table_length' (M i n : ℕ) : (table M i n).length = n := by simp [table]

/-- Soundness of `scanT`. -/
theorem scanT_sound (N F r : ℕ) : ∀ k i x, x = 2 ^ r % 3 ^ (i + k) / 3 ^ i →
    scanT N F r i x k = true → Good N r := by
  intro k
  induction k with
  | zero =>
    intro i x _ h
    have := good_of_explore (by simpa [scanT] using h) 0
    simpa using this
  | succ k ih =>
    intro i x hx h
    simp only [scanT] at h
    split_ifs at h with h1
    · intro _ _
      apply two_mem_digits_of (i := i)
      rw [beq_iff_eq, hx] at h1
      exact trit_of_mod h1
    · refine ih (i + 1) (x / 3) ?_ h
      rw [hx, Nat.div_div_eq_div_mul, ← pow_succ, show i + 1 + k = i + (k + 1) by omega]

theorem deep_sound {N F r i : ℕ} (h : deep N F r i = true) : Good N r :=
  scanT_sound N F r 38 i _ (by rw [Nat.powMod_def]) h

/-- Soundness of `scan`. -/
theorem scan_sound (N F r : ℕ) : ∀ es x i, i + es.length = 38 → x = 2 ^ r % 3 ^ 38 / 3 ^ i →
    scan N F r x es = true → Good N r := by
  intro es
  induction es with
  | nil =>
    intro x i _ _ h
    exact deep_sound (by simpa [scan] using h)
  | cons e es ih =>
    intro x i hk hx h
    simp only [List.length_cons] at hk
    simp only [scan] at h
    split_ifs at h with h1
    · intro _ _
      apply two_mem_digits_of (i := i)
      rw [beq_iff_eq, hx] at h1
      exact trit_of_mod h1
    · refine ih (x / 3) (i + 1) (by omega) ?_ h
      rw [hx, Nat.div_div_eq_div_mul, ← pow_succ]

/-- Soundness of `fast`, under the state invariants (`i` is the level of the node). -/
theorem fast_sound (N F : ℕ) : ∀ es i r v, LW i es → i + es.length = 38 → v = 2 ^ r % 3 ^ 38 →
    fast N F (3 ^ 38) r v es = true → ∀ t, Good N (r + t * (2 * 3 ^ i)) := by
  intro es
  induction es with
  | nil =>
    intro i r v _ hi _ h
    simp only [List.length_nil, Nat.add_zero] at hi
    subst hi
    exact good_of_explore (by simpa [fast] using h)
  | cons e es ih =>
    intro i r v hlv hlen hv h
    obtain ⟨hg, hgl, hp, hp2, hq3, hlv'⟩ := hlv
    simp only [List.length_cons] at hlen
    have hlen' : i + 1 + es.length = 38 := by omega
    simp only [fast] at h
    split_ifs at h with h1
    · rw [hp] at h1
      refine good_single h1 ?_
      simp only [Bool.or_eq_true, decide_eq_true_eq] at h
      rcases h with h | h
      · intro _ h8; omega
      · refine scan_sound N F r es _ (i + 1) hlen' ?_ h
        rw [hv, hq3]
    · have hv1 : mulMod (3 ^ 38) v e.gh e.gl = 2 ^ (r + 2 * 3 ^ i) % 3 ^ 38 := by
        rw [mulMod_eq _ _ _ hgl, hv, hg, pow_add, Nat.mul_mod, Nat.mod_mod, Nat.mod_mod, ← Nat.mul_mod]
      have hv2 : mulMod (3 ^ 38) (mulMod (3 ^ 38) v e.gh e.gl) e.gh e.gl =
          2 ^ (r + 2 * (2 * 3 ^ i)) % 3 ^ 38 := by
        rw [mulMod_eq _ _ _ hgl, hv1, hg, show r + 2 * (2 * 3 ^ i) = r + 2 * 3 ^ i + 2 * 3 ^ i by ring,
          pow_add 2 (r + _), Nat.mul_mod, Nat.mod_mod, Nat.mod_mod, ← Nat.mul_mod]
      simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq, beq_iff_eq] at h
      obtain ⟨⟨ha, hb⟩, hc⟩ := h
      rw [hq3] at ha hb hc
      rw [hp] at hb
      rw [hp2] at hc
      refine split_class ?_ ?_ ?_
      · rcases ha with ha | ha
        · rw [hv] at ha; exact good_of_trit (trit_of_mod ha)
        · exact ih (i + 1) r v hlv' hlen' hv ha
      · rcases hb with hb | hb
        · rw [hv1] at hb; exact good_of_trit (trit_of_mod hb)
        · exact ih (i + 1) _ _ hlv' hlen' hv1 hb
      · rcases hc with (hc | hc) | hc
        · exact good_of_lt hc
        · rw [hv2] at hc; exact good_of_trit (trit_of_mod hc)
        · exact ih (i + 1) _ _ hlv' hlen' hv2 hc

/-- Soundness of `top`, combining all shards `s < m`. -/
theorem top_sound (N d F m : ℕ) (tbl : List Lv) (hm : 0 < m) (htbl : LW d tbl)
    (hlen : d + tbl.length = 38) : ∀ fuel i r, (∀ s < m, top N d F (3 ^ 38) m s tbl fuel i r = true) →
    ∀ t, Good N (r + t * (2 * 3 ^ i)) := by
  intro fuel
  induction fuel with
  | zero => intro i r h; have := h 0 hm; simp [top] at this
  | succ fuel ih =>
    intro i r h
    by_cases h1 : N < r
    · exact good_of_lt h1
    by_cases h2 : Nat.powMod 2 r (3 * 3 ^ i) / 3 ^ i = 2
    · have h2' := h2
      rw [Nat.powMod_def, mul_comm, Nat.mod_mul_right_div_self] at h2'
      exact good_of_trit h2'
    by_cases h3 : N < r + 2 * 3 ^ i ∧ r ≤ 8
    · exact good_single h3.1 (fun _ h8 => by omega)
    by_cases hd : i = d
    · have h' := h (r / 2 % m) (Nat.mod_lt _ hm)
      subst hd
      simp only [top] at h'
      simp only [eq_false h1, eq_false h2, eq_false h3, ↓reduceIte] at h'
      exact fast_sound N F tbl i r _ htbl hlen (Nat.powMod_def _ _ _) h'
    · have hs' : ∀ s < m, top N d F (3 ^ 38) m s tbl fuel (i + 1) r = true ∧
          top N d F (3 ^ 38) m s tbl fuel (i + 1) (r + 2 * 3 ^ i) = true ∧
          top N d F (3 ^ 38) m s tbl fuel (i + 1) (r + 2 * (2 * 3 ^ i)) = true := by
        intro s hsm
        have := h s hsm
        simp only [top] at this
        simp only [eq_false h1, eq_false h2, eq_false h3, eq_false hd, ↓reduceIte] at this
        simp only [Bool.and_eq_true] at this
        exact ⟨this.1.1, this.1.2, this.2⟩
      refine split_class ?_ ?_ ?_
      · exact ih (i + 1) r (fun s hs => (hs' s hs).1)
      · exact ih (i + 1) _ (fun s hs => (hs' s hs).2.1)
      · exact ih (i + 1) _ (fun s hs => (hs' s hs).2.2)

/-- Soundness of the word-state sharded checker (tier A): if every shard `s < m` returns `true`, then `UpTo N`. -/
theorem checkWord_sound {N m : ℕ} (hm : 0 < m) (h : ∀ s < m, checkWord N s m = true) : UpTo N := by
  intro n hn h8
  have key : n = n % 2 + n / 2 * (2 * 3 ^ 0) := by simp; omega
  have hj : n % 2 = 0 ∨ n % 2 = 1 := by omega
  simp only [checkWord, Bool.and_eq_true] at h
  have htbl := table_LW (38 - wordDepth) wordDepth
  have hlen : wordDepth + (table (3 ^ 38) wordDepth (38 - wordDepth)).length = 38 := by
    rw [table_length']; decide
  rw [key] at hn h8 ⊢
  rcases hj with hj | hj <;> rw [hj] at hn h8 ⊢
  · exact top_sound N _ _ m _ hm htbl hlen _ 0 0 (fun s hs => (h s hs).1) _ hn h8
  · exact top_sound N _ _ m _ hm htbl hlen _ 0 1 (fun s hs => (h s hs).2) _ hn h8

end CheckerWord

end ErdosTernary
