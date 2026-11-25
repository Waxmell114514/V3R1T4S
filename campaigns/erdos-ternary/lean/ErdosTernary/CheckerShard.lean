/- g003-L01: a sharded residue-tree checker with incremental state, sound by a tier-A proof.

Same tree as `ErdosTernary.Checker.explore` (g002-L01): node `(i, r)` is the class `{r + t * (2 * 3^i) | t : ℕ}`.
Changes:
* Sharding. `top` walks the tree down to the fixed level `d = shardDepth`; a surviving node `(d, r)` is explored
  only by shard `s = r / 2 % m` (every surviving `r` is even), every other shard returns `true` for it.
  `checkShard_sound`: if every shard `s < m` returns `true`, then `UpTo N`.
* Incremental state. Below level `d`, `fast` carries `v = 2^r % 3^L` (`L = modExp`) and a table with one record
  per level `j = i, i+1, …, L-1` holding `2^(2 * 3^j) % 3^L`, `2 * 3^j`, `4 * 3^j`, `3^(j+1)`, so a child's value
  is one multiplication mod `3^L` instead of a `Nat.powMod` call per node. A child's trit is tested before the
  recursive call.
* Single-member classes (`N < r + 2 * 3^i`) are finished by `scan`, which reads the remaining trits of `v` one by
  one instead of building three children per level.
When the table is used up (level `L`), both fall back to `Checker.explore` (g002-L01, reused unchanged). -/
import ErdosTernary.Checker

namespace ErdosTernary

namespace CheckerShard

open Checker

-- `Lvl`, `scan`, `fast`, `table`, `top`, `shardDepth`, `modExp` and `checkShard` are defined in
-- `ErdosTernary/Native/ETNative.lean` (precompiled, g004-C02).

/-! ### Soundness -/

/-- The invariant of the table: entry `k` describes level `i + k`. -/
def LV (M : ℕ) : ℕ → List Lvl → Prop
  | _, [] => True
  | i, e :: es => e.g = 2 ^ (2 * 3 ^ i) % M ∧ e.p = 2 * 3 ^ i ∧ e.p2 = 2 * (2 * 3 ^ i) ∧ e.q3 = 3 ^ (i + 1) ∧
      LV M (i + 1) es

theorem table_LV (M : ℕ) : ∀ n i, LV M i (table M i n) := by
  intro n
  induction n with
  | zero => intro i; simp [table, LV]
  | succ n ih =>
    intro i
    simp only [table, List.range'_succ, List.map_cons]
    exact ⟨Nat.powMod_def _ _ _, rfl, rfl, rfl, ih (i + 1)⟩

theorem table_length (M i n : ℕ) : (table M i n).length = n := by simp [table]

/-- A trit `2` of `x % 3^L` is a trit `2` of `x`. -/
theorem trit_of_mod {x i L : ℕ} (h : x % 3 ^ L / 3 ^ i % 3 = 2) : x / 3 ^ i % 3 = 2 := by
  by_cases hi : i < L
  · have hL : 3 ^ L = 3 ^ i * 3 ^ (L - i) := by rw [← pow_add]; congr 1; omega
    rw [hL, Nat.mod_mul_right_div_self, Nat.mod_mod_of_dvd _ (dvd_pow_self 3 (by omega))] at h
    exact h
  · have h1 : x % 3 ^ L < 3 ^ i :=
      lt_of_lt_of_le (Nat.mod_lt _ (by positivity)) (Nat.pow_le_pow_right (by norm_num) (by omega))
    rw [Nat.div_eq_of_lt h1] at h
    simp at h

/-- Membership from a trit of the class representative. -/
theorem mem_of_trit {i r : ℕ} (t : ℕ) (h : 2 ^ r / 3 ^ i % 3 = 2) :
    2 ∈ Nat.digits 3 (2 ^ (r + t * (2 * 3 ^ i))) := by
  apply two_mem_digits_of (i := i)
  rw [← Nat.mod_mul_right_div_self, ← pow_succ, pow_class_mod, pow_succ, Nat.mod_mul_right_div_self]
  exact h

/-- The property proved for every member of a class. -/
def Good (N n : ℕ) : Prop := n ≤ N → 8 < n → 2 ∈ Nat.digits 3 (2 ^ n)

/-- Splitting a class into its three child classes. -/
theorem split_class {N i r : ℕ}
    (h0 : ∀ t', Good N (r + t' * (2 * 3 ^ (i + 1))))
    (h1 : ∀ t', Good N (r + 2 * 3 ^ i + t' * (2 * 3 ^ (i + 1))))
    (h2 : ∀ t', Good N (r + 2 * (2 * 3 ^ i) + t' * (2 * 3 ^ (i + 1)))) :
    ∀ t, Good N (r + t * (2 * 3 ^ i)) := by
  intro t
  have key : r + t * (2 * 3 ^ i) = (r + t % 3 * (2 * 3 ^ i)) + t / 3 * (2 * 3 ^ (i + 1)) := by
    conv_lhs => rw [← Nat.mod_add_div t 3]
    ring
  rw [key]
  have hj : t % 3 = 0 ∨ t % 3 = 1 ∨ t % 3 = 2 := by omega
  rcases hj with hj | hj | hj <;> rw [hj]
  · simpa using h0 (t / 3)
  · simpa using h1 (t / 3)
  · exact h2 (t / 3)

/-- A class whose representative has trit `i` equal to 2. -/
theorem good_of_trit {N i r : ℕ} (h : 2 ^ r / 3 ^ i % 3 = 2) : ∀ t, Good N (r + t * (2 * 3 ^ i)) :=
  fun t _ _ => mem_of_trit t h

/-- A class with no member `≤ N`. -/
theorem good_of_lt {N i r : ℕ} (h : N < r) : ∀ t, Good N (r + t * (2 * 3 ^ i)) := by
  intro t hle _; omega

/-- A class whose only member `≤ N` is `r`. -/
theorem good_single {N i r : ℕ} (h : N < r + 2 * 3 ^ i) (hr : Good N r) : ∀ t, Good N (r + t * (2 * 3 ^ i)) := by
  intro t hle h8
  rcases t with _ | t
  · simpa using hr (by simpa using hle) (by simpa using h8)
  · have : 2 * 3 ^ i ≤ (t + 1) * (2 * 3 ^ i) := Nat.le_mul_of_pos_left _ (by omega)
    omega

theorem good_of_explore {N F i r : ℕ} (h : explore N F i r = true) : ∀ t, Good N (r + t * (2 * 3 ^ i)) :=
  fun t => explore_sound N F i r h t

/-- Soundness of `scan`. -/
theorem scan_sound (N F L r : ℕ) : ∀ es x i, i + es.length = L → x = 2 ^ r % 3 ^ L / 3 ^ i →
    scan N F L r x es = true → Good N r := by
  intro es
  induction es with
  | nil =>
    intro x i hi _ h
    simp only [List.length_nil, Nat.add_zero] at hi
    subst hi
    have := good_of_explore (by simpa [scan] using h) 0
    simpa using this
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
theorem fast_sound (N L F : ℕ) : ∀ es i r v, LV (3 ^ L) i es → i + es.length = L → v = 2 ^ r % 3 ^ L →
    fast N (3 ^ L) L F r v es = true → ∀ t, Good N (r + t * (2 * 3 ^ i)) := by
  intro es
  induction es with
  | nil =>
    intro i r v _ hi _ h
    simp only [List.length_nil, Nat.add_zero] at hi
    subst hi
    exact good_of_explore (by simpa [fast] using h)
  | cons e es ih =>
    intro i r v hlv hlen hv h
    obtain ⟨hg, hp, hp2, hq3, hlv'⟩ := hlv
    simp only [List.length_cons] at hlen
    have hlen' : i + 1 + es.length = L := by omega
    simp only [fast] at h
    split_ifs at h with h1
    · rw [hp] at h1
      refine good_single h1 ?_
      simp only [Bool.or_eq_true, decide_eq_true_eq] at h
      rcases h with h | h
      · intro _ h8; omega
      · refine scan_sound N F L r es _ (i + 1) hlen' ?_ h
        rw [hv, hq3]
    · have hv1 : v * e.g % 3 ^ L = 2 ^ (r + 2 * 3 ^ i) % 3 ^ L := by
        rw [hv, hg, pow_add, Nat.mul_mod, Nat.mod_mod, Nat.mod_mod, ← Nat.mul_mod]
      have hv2 : v * e.g % 3 ^ L * e.g % 3 ^ L = 2 ^ (r + 2 * (2 * 3 ^ i)) % 3 ^ L := by
        rw [hv1, hg, show r + 2 * (2 * 3 ^ i) = r + 2 * 3 ^ i + 2 * 3 ^ i by ring, pow_add 2 (r + _),
          Nat.mul_mod, Nat.mod_mod, Nat.mod_mod, ← Nat.mul_mod]
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
theorem top_sound (N d L F m : ℕ) (tbl : List Lvl) (hm : 0 < m) (htbl : LV (3 ^ L) d tbl)
    (hlen : d + tbl.length = L) : ∀ fuel i r, (∀ s < m, top N d L (3 ^ L) F m s tbl fuel i r = true) →
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
      exact fast_sound N L F tbl i r _ htbl hlen (Nat.powMod_def _ _ _) h'
    · have hs' : ∀ s < m, top N d L (3 ^ L) F m s tbl fuel (i + 1) r = true ∧
          top N d L (3 ^ L) F m s tbl fuel (i + 1) (r + 2 * 3 ^ i) = true ∧
          top N d L (3 ^ L) F m s tbl fuel (i + 1) (r + 2 * (2 * 3 ^ i)) = true := by
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

/-- Soundness of the sharded checker (tier A): if every shard `s < m` returns `true`, then `UpTo N`. -/
theorem checkShard_sound {N m : ℕ} (hm : 0 < m) (h : ∀ s < m, checkShard N s m = true) : UpTo N := by
  intro n hn h8
  have key : n = n % 2 + n / 2 * (2 * 3 ^ 0) := by simp; omega
  have hj : n % 2 = 0 ∨ n % 2 = 1 := by omega
  simp only [checkShard, Bool.and_eq_true] at h
  have htbl := table_LV (3 ^ modExp) (modExp - shardDepth) shardDepth
  have hlen : shardDepth + (table (3 ^ modExp) shardDepth (modExp - shardDepth)).length = modExp := by
    rw [table_length]; decide
  rw [key] at hn h8 ⊢
  rcases hj with hj | hj <;> rw [hj] at hn h8 ⊢
  · exact top_sound N _ _ _ m _ hm htbl hlen _ 0 0 (fun s hs => (h s hs).1) _ hn h8
  · exact top_sound N _ _ _ m _ hm htbl hlen _ 0 1 (fun s hs => (h s hs).2) _ hn h8

/-! ### Evaluations (tier B)

Each shard is a closed term `checkShard <literal> <literal> <literal>` evaluated by `native_decide`, which trusts
the Lean compiler and runtime (including GMP and the native `Nat.powMod`). The combination is tier A
(`checkShard_sound`). -/

/-- Shard 0 of 4 for `N = 2 * 3^26` (tier B: `native_decide` on a closed `checkShard` term). -/
theorem shard26_0 : checkShard (2 * 3 ^ 26) 0 4 = true := by native_decide

/-- Shard 1 of 4 for `N = 2 * 3^26` (tier B: `native_decide` on a closed `checkShard` term). -/
theorem shard26_1 : checkShard (2 * 3 ^ 26) 1 4 = true := by native_decide

/-- Shard 2 of 4 for `N = 2 * 3^26` (tier B: `native_decide` on a closed `checkShard` term). -/
theorem shard26_2 : checkShard (2 * 3 ^ 26) 2 4 = true := by native_decide

/-- Shard 3 of 4 for `N = 2 * 3^26` (tier B: `native_decide` on a closed `checkShard` term). -/
theorem shard26_3 : checkShard (2 * 3 ^ 26) 3 4 = true := by native_decide

end CheckerShard

/-- `UpTo (2 * 3^26)` (N = 5083731656658): every `n` with `8 < n ≤ 2 * 3^26` has a digit 2 in base 3 in `2^n`.
Tier B, from the four shard evaluations `CheckerShard.shard26_i` and `CheckerShard.checkShard_sound`. -/
theorem upTo_26 : UpTo (2 * 3 ^ 26) :=
  CheckerShard.checkShard_sound (m := 4) (by norm_num) fun s hs =>
    match s, hs with
    | 0, _ => CheckerShard.shard26_0
    | 1, _ => CheckerShard.shard26_1
    | 2, _ => CheckerShard.shard26_2
    | 3, _ => CheckerShard.shard26_3
    | _ + 4, h => absurd h (by omega)

end ErdosTernary
