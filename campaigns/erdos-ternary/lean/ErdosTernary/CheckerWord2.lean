/- g006-C01: soundness of the two-word-state checker `CheckerWord2.checkWord2` (definitions in
`ErdosTernary/Native/ETNative.lean`, precompiled).

Same tree as `CheckerShard` / `CheckerWord`; the differences are only in how the state is computed:
* the state is `2^r % 3^76` as two words base `3^38`: `lo = 2^r % 3^38`, `hi = 2^r % 3^76 / 3^38` (`St r lo hi`);
* a child's words are `mulLo` / `mulHi` (schoolbook product in base `B = 3^19` with carries); `mul2_gen` proves
  `mulLo + B^2 * mulHi = (lo + B^2 hi) * (g0 + B g1 + B^2 h0 + B^3 h1) % B^4` and `mulLo < B^2` for every input;
* the table reaches level 74 (`tableL` for levels `10 .. 36` reading `lo`, `tableH` for `37 .. 74` reading `hi`).
Main theorem: `checkWord2_sound` (tier A). -/
import ErdosTernary.CheckerWord
import Mathlib.Tactic.LinearCombination

namespace ErdosTernary

namespace CheckerWord2

open Checker CheckerShard

/-! ### The two-word product -/

theorem two_digit {B x y : ℕ} (hx : x < B) (hy : y < B) : x * B + y < B * B := by
  have : (x + 1) * B ≤ B * B := Nat.mul_le_mul_right B hx
  nlinarith

/-- `mulLo` and `mulHi` with the base as a parameter (`mulLo_eq`, `mulHi_eq`: they agree at `B = 3^19`). -/
def mulLoB (B lo g0 g1 : ℕ) : ℕ :=
  let a0 := lo % B
  let a1 := lo / B
  let t0 := a0 * g0
  let t1 := a1 * g0 + a0 * g1 + t0 / B
  t1 % B * B + t0 % B

def mulHiB (B lo hi g0 g1 h0 h1 : ℕ) : ℕ :=
  let a0 := lo % B
  let a1 := lo / B
  let c0 := hi % B
  let c1 := hi / B
  let t0 := a0 * g0
  let t1 := a1 * g0 + a0 * g1 + t0 / B
  let t2 := a1 * g1 + a0 * h0 + c0 * g0 + t1 / B
  let t3 := a0 * h1 + a1 * h0 + c0 * g1 + c1 * g0 + t2 / B
  t3 % B * B + t2 % B

theorem mulLo_eq (lo g0 g1 : ℕ) : mulLo lo g0 g1 = mulLoB 1162261467 lo g0 g1 := rfl

theorem mulHi_eq (lo hi g0 g1 h0 h1 : ℕ) :
    mulHi lo hi g0 g1 h0 h1 = mulHiB 1162261467 lo hi g0 g1 h0 h1 := rfl

theorem mul2_gen (B lo hi g0 g1 h0 h1 : ℕ) (hB : 0 < B) :
    mulLoB B lo g0 g1 + B * B * mulHiB B lo hi g0 g1 h0 h1 =
      (lo + B * B * hi) * (g0 + B * g1 + B * B * h0 + B * B * B * h1) % (B * B * (B * B)) ∧
    mulLoB B lo g0 g1 < B * B := by
  simp only [mulLoB, mulHiB]
  have elo := Nat.mod_add_div lo B
  have ehi := Nat.mod_add_div hi B
  generalize lo % B = a0 at *
  generalize lo / B = a1 at *
  generalize hi % B = c0 at *
  generalize hi / B = c1 at *
  subst elo ehi
  have e0 := Nat.mod_add_div (a0 * g0) B
  have b0 := Nat.mod_lt (a0 * g0) hB
  generalize a0 * g0 % B = d0 at *
  generalize a0 * g0 / B = k0 at *
  have e1 := Nat.mod_add_div (a1 * g0 + a0 * g1 + k0) B
  have b1 := Nat.mod_lt (a1 * g0 + a0 * g1 + k0) hB
  generalize (a1 * g0 + a0 * g1 + k0) % B = d1 at *
  generalize (a1 * g0 + a0 * g1 + k0) / B = k1 at *
  have e2 := Nat.mod_add_div (a1 * g1 + a0 * h0 + c0 * g0 + k1) B
  have b2 := Nat.mod_lt (a1 * g1 + a0 * h0 + c0 * g0 + k1) hB
  generalize (a1 * g1 + a0 * h0 + c0 * g0 + k1) % B = d2 at *
  generalize (a1 * g1 + a0 * h0 + c0 * g0 + k1) / B = k2 at *
  have e3 := Nat.mod_add_div (a0 * h1 + a1 * h0 + c0 * g1 + c1 * g0 + k2) B
  have b3 := Nat.mod_lt (a0 * h1 + a1 * h0 + c0 * g1 + c1 * g0 + k2) hB
  generalize (a0 * h1 + a1 * h0 + c0 * g1 + c1 * g0 + k2) % B = d3 at *
  generalize (a0 * h1 + a1 * h0 + c0 * g1 + c1 * g0 + k2) / B = k3 at *
  have hlo : d1 * B + d0 < B * B := two_digit b1 b0
  have hhi : d3 * B + d2 < B * B := two_digit b3 b2
  refine ⟨?_, hlo⟩
  have key : (a0 + B * a1 + B * B * (c0 + B * c1)) * (g0 + B * g1 + B * B * h0 + B * B * B * h1) =
      (d1 * B + d0 + B * B * (d3 * B + d2)) + B * B * (B * B) *
        (k3 + a1 * h1 + c0 * h0 + c1 * g1 + B * (c0 * h1 + c1 * h0) + B * B * (c1 * h1)) := by
    have z0 : ((d0 : ℤ) + B * k0) = a0 * g0 := by exact_mod_cast e0
    have z1 : ((d1 : ℤ) + B * k1) = a1 * g0 + a0 * g1 + k0 := by exact_mod_cast e1
    have z2 : ((d2 : ℤ) + B * k2) = a1 * g1 + a0 * h0 + c0 * g0 + k1 := by exact_mod_cast e2
    have z3 : ((d3 : ℤ) + B * k3) = a0 * h1 + a1 * h0 + c0 * g1 + c1 * g0 + k2 := by exact_mod_cast e3
    zify
    linear_combination (-1 : ℤ) * z0 - (B : ℤ) * z1 - (B : ℤ) ^ 2 * z2 - (B : ℤ) ^ 3 * z3
  rw [key, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt]
  have := two_digit hhi hlo
  linarith

theorem B_sq' : (1162261467 : ℕ) * 1162261467 = 3 ^ 38 := by norm_num
theorem B_four : (1162261467 : ℕ) * 1162261467 * (1162261467 * 1162261467) = 3 ^ 76 := by norm_num

/-- The two-word state of `r`. -/
def St (r lo hi : ℕ) : Prop := lo = 2 ^ r % 3 ^ 38 ∧ hi = 2 ^ r % 3 ^ 76 / 3 ^ 38

theorem st_of (r x : ℕ) (hx : x = 2 ^ r % 3 ^ 76) : St r (x % 3 ^ 38) (x / 3 ^ 38) := by
  subst hx
  refine ⟨?_, rfl⟩
  exact Nat.mod_mod_of_dvd _ (pow_dvd_pow 3 (by norm_num))

theorem st_val {r lo hi : ℕ} (h : St r lo hi) : lo + 3 ^ 38 * hi = 2 ^ r % 3 ^ 76 := by
  obtain ⟨h1, h2⟩ := h
  rw [h1, h2, ← Nat.mod_mod_of_dvd (2 ^ r) (pow_dvd_pow 3 (show 38 ≤ 76 by norm_num))]
  exact Nat.mod_add_div _ _

/-- The table invariant of one entry: the pieces of `g = 2^(2 * 3^i) % 3^76` and the periods. -/
def EG (i : ℕ) (e : Lv2) : Prop :=
  e.g0 + 1162261467 * e.g1 + 1162261467 * 1162261467 * e.h0 + 1162261467 * 1162261467 * 1162261467 * e.h1 =
      2 ^ (2 * 3 ^ i) % 3 ^ 76 ∧ e.p = 2 * 3 ^ i ∧ e.p2 = 2 * (2 * 3 ^ i)

theorem st_step {r lo hi i : ℕ} {e : Lv2} (hs : St r lo hi) (he : EG i e) :
    St (r + 2 * 3 ^ i) (mulLo lo e.g0 e.g1) (mulHi lo hi e.g0 e.g1 e.h0 e.h1) := by
  obtain ⟨hv, hlt⟩ := mul2_gen 1162261467 lo hi e.g0 e.g1 e.h0 e.h1 (by norm_num)
  rw [← mulLo_eq, ← mulHi_eq] at hv
  rw [← mulLo_eq] at hlt
  rw [he.1, B_four, B_sq', st_val hs, ← Nat.mul_mod, ← pow_add] at hv
  rw [B_sq'] at hlt
  generalize mulLo lo e.g0 e.g1 = a at hv hlt
  generalize mulHi lo hi e.g0 e.g1 e.h0 e.h1 = b at hv
  constructor
  · rw [← Nat.mod_mod_of_dvd (2 ^ (r + 2 * 3 ^ i)) (pow_dvd_pow 3 (show 38 ≤ 76 by norm_num)), ← hv,
      Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hlt]
  · rw [← hv, Nat.add_mul_div_left _ _ (by positivity), Nat.div_eq_of_lt hlt, zero_add]

theorem entry_EG (j q : ℕ) : EG j (entry j q) := by
  refine ⟨?_, rfl, rfl⟩
  simp only [entry]
  rw [← Nat.powMod_def]
  generalize Nat.powMod 2 (2 * 3 ^ j) (3 ^ 76) = g
  have e1 := Nat.mod_add_div g 1162261467
  have e2 := Nat.mod_add_div (g / 1162261467) 1162261467
  have e3 := Nat.mod_add_div (g / 1162261467 / 1162261467) 1162261467
  omega

/-- Invariant of `tableL`-style lists: entry `k` describes level `i + k` and reads trit `i + k + 1` from `lo`. -/
def LL : ℕ → List Lv2 → Prop
  | _, [] => True
  | i, e :: es => EG i e ∧ e.q = 3 ^ (i + 1) ∧ LL (i + 1) es

/-- Invariant of `tableH`-style lists: entry `k` describes level `i + k` and reads trit `i + k + 1` from `hi`. -/
def LH : ℕ → List Lv2 → Prop
  | _, [] => True
  | i, e :: es => EG i e ∧ 3 ^ 38 * e.q = 3 ^ (i + 1) ∧ LH (i + 1) es

theorem tableL_LL : ∀ n i, LL i (tableL i n) := by
  intro n
  induction n with
  | zero => intro i; simp [tableL, LL]
  | succ n ih =>
    intro i
    simp only [tableL, List.range'_succ, List.map_cons]
    exact ⟨entry_EG _ _, rfl, ih (i + 1)⟩

theorem tableH_LH : ∀ n i, 37 ≤ i → LH i (tableH i n) := by
  intro n
  induction n with
  | zero => intro i _; simp [tableH, LH]
  | succ n ih =>
    intro i hi
    simp only [tableH, List.range'_succ, List.map_cons]
    refine ⟨entry_EG _ _, ?_, ih (i + 1) (by omega)⟩
    show 3 ^ 38 * 3 ^ (i + 1 - 38) = 3 ^ (i + 1)
    rw [← pow_add]; congr 1; omega

theorem tableL_length (i n : ℕ) : (tableL i n).length = n := by simp [tableL]
theorem tableH_length (i n : ℕ) : (tableH i n).length = n := by simp [tableH]

/-- A trit `2` read from `lo`. -/
theorem trit_lo {r lo hi j : ℕ} (hs : St r lo hi) (h : lo / 3 ^ j % 3 = 2) : 2 ^ r / 3 ^ j % 3 = 2 := by
  rw [hs.1] at h; exact trit_of_mod h

/-- A trit `2` read from `hi`. -/
theorem trit_hi {r lo hi j q : ℕ} (hs : St r lo hi) (hq : 3 ^ 38 * q = 3 ^ j) (h : hi / q % 3 = 2) :
    2 ^ r / 3 ^ j % 3 = 2 := by
  rw [hs.2, Nat.div_div_eq_div_mul, hq] at h; exact trit_of_mod h

/-! ### Soundness -/

theorem scanH_sound (N F r : ℕ) : ∀ es x i, i + es.length = 75 → x = 2 ^ r % 3 ^ 76 / 3 ^ i →
    scanH N F r x es = true → Good N r := by
  intro es
  induction es with
  | nil =>
    intro x i hi hx h
    simp only [List.length_nil, Nat.add_zero] at hi
    subst hi
    simp only [scanH, Bool.or_eq_true, beq_iff_eq] at h
    rcases h with h | h
    · intro _ _
      apply two_mem_digits_of (i := 75)
      rw [hx] at h
      exact trit_of_mod h
    · simpa using good_of_explore h 0
  | cons e es ih =>
    intro x i hk hx h
    simp only [List.length_cons] at hk
    simp only [scanH] at h
    split_ifs at h with h1
    · intro _ _
      apply two_mem_digits_of (i := i)
      rw [beq_iff_eq, hx] at h1
      exact trit_of_mod h1
    · refine ih (x / 3) (i + 1) (by omega) ?_ h
      rw [hx, Nat.div_div_eq_div_mul, ← pow_succ]

theorem scanL_sound (N F r hi : ℕ) (hhi : hi = 2 ^ r % 3 ^ 76 / 3 ^ 38) : ∀ es x i, i + es.length = 37 →
    x = 2 ^ r % 3 ^ 38 / 3 ^ i → scanL N F r hi x es = true → Good N r := by
  intro es
  induction es with
  | nil =>
    intro x i hi hx h
    simp only [List.length_nil, Nat.add_zero] at hi
    subst hi
    simp only [scanL, Bool.or_eq_true, beq_iff_eq] at h
    rcases h with h | h
    · intro _ _
      apply two_mem_digits_of (i := 37)
      rw [hx] at h
      exact trit_of_mod h
    · exact CheckerWord.scanT_sound N F r 38 38 hi hhi h
  | cons e es ih =>
    intro x i hk hx h
    simp only [List.length_cons] at hk
    simp only [scanL] at h
    split_ifs at h with h1
    · intro _ _
      apply two_mem_digits_of (i := i)
      rw [beq_iff_eq, hx] at h1
      exact trit_of_mod h1
    · refine ih (x / 3) (i + 1) (by omega) ?_ h
      rw [hx, Nat.div_div_eq_div_mul, ← pow_succ]

theorem fastH_sound (N F : ℕ) : ∀ es i r lo hi, LH i es → i + es.length = 75 → St r lo hi →
    fastH N F r lo hi es = true → ∀ t, Good N (r + t * (2 * 3 ^ i)) := by
  intro es
  induction es with
  | nil =>
    intro i r lo hi _ hi' _ h
    simp only [List.length_nil, Nat.add_zero] at hi'
    subst hi'
    exact good_of_explore (by simpa [fastH] using h)
  | cons e es ih =>
    intro i r lo hi hlv hlen hs h
    obtain ⟨he, hq, hlv'⟩ := hlv
    have hp := he.2.1
    have hp2 := he.2.2
    simp only [List.length_cons] at hlen
    have hlen' : i + 1 + es.length = 75 := by omega
    simp only [fastH] at h
    split_ifs at h with h1
    · rw [hp] at h1
      refine good_single h1 ?_
      simp only [Bool.or_eq_true, decide_eq_true_eq] at h
      rcases h with h | h
      · intro _ h8; omega
      · refine scanH_sound N F r es _ (i + 1) hlen' ?_ h
        rw [hs.2, Nat.div_div_eq_div_mul, hq]
    · have hs1 := st_step hs he
      have hs2 := st_step hs1 he
      rw [show r + 2 * 3 ^ i + 2 * 3 ^ i = r + 2 * (2 * 3 ^ i) by ring] at hs2
      simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq, beq_iff_eq] at h
      obtain ⟨⟨ha, hb⟩, hc⟩ := h
      rw [hp] at hb
      rw [hp2] at hc
      refine split_class ?_ ?_ ?_
      · rcases ha with ha | ha
        · exact good_of_trit (trit_hi hs hq ha)
        · exact ih (i + 1) r lo hi hlv' hlen' hs ha
      · rcases hb with hb | hb
        · exact good_of_trit (trit_hi hs1 hq hb)
        · exact ih (i + 1) _ _ _ hlv' hlen' hs1 hb
      · rcases hc with (hc | hc) | hc
        · exact good_of_lt hc
        · exact good_of_trit (trit_hi hs2 hq hc)
        · exact ih (i + 1) _ _ _ hlv' hlen' hs2 hc

theorem fastL_sound (N F : ℕ) (th : List Lv2) (hth : LH 37 th) (hthl : th.length = 38) :
    ∀ es i r lo hi, LL i es → i + es.length = 37 → St r lo hi →
    fastL N F th r lo hi es = true → ∀ t, Good N (r + t * (2 * 3 ^ i)) := by
  intro es
  induction es with
  | nil =>
    intro i r lo hi _ hi' hs h
    simp only [List.length_nil, Nat.add_zero] at hi'
    subst hi'
    exact fastH_sound N F th 37 r lo hi hth (by omega) hs (by simpa [fastL] using h)
  | cons e es ih =>
    intro i r lo hi hlv hlen hs h
    obtain ⟨he, hq, hlv'⟩ := hlv
    have hp := he.2.1
    have hp2 := he.2.2
    simp only [List.length_cons] at hlen
    have hlen' : i + 1 + es.length = 37 := by omega
    simp only [fastL] at h
    split_ifs at h with h1
    · rw [hp] at h1
      refine good_single h1 ?_
      simp only [Bool.or_eq_true, decide_eq_true_eq] at h
      rcases h with h | h
      · intro _ h8; omega
      · refine scanL_sound N F r hi hs.2 es _ (i + 1) hlen' ?_ h
        rw [hs.1, hq]
    · have hs1 := st_step hs he
      have hs2 := st_step hs1 he
      rw [show r + 2 * 3 ^ i + 2 * 3 ^ i = r + 2 * (2 * 3 ^ i) by ring] at hs2
      simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq, beq_iff_eq] at h
      obtain ⟨⟨ha, hb⟩, hc⟩ := h
      rw [hq] at ha hb hc
      rw [hp] at hb
      rw [hp2] at hc
      refine split_class ?_ ?_ ?_
      · rcases ha with ha | ha
        · exact good_of_trit (trit_lo hs ha)
        · exact ih (i + 1) r lo hi hlv' hlen' hs ha
      · rcases hb with hb | hb
        · exact good_of_trit (trit_lo hs1 hb)
        · exact ih (i + 1) _ _ _ hlv' hlen' hs1 hb
      · rcases hc with (hc | hc) | hc
        · exact good_of_lt hc
        · exact good_of_trit (trit_lo hs2 hc)
        · exact ih (i + 1) _ _ _ hlv' hlen' hs2 hc

/-- Soundness of `top`, combining all shards `s < m`. -/
theorem top_sound (N d F m : ℕ) (tl th : List Lv2) (hm : 0 < m) (htl : LL d tl)
    (hlen : d + tl.length = 37) (hth : LH 37 th) (hthl : th.length = 38) :
    ∀ fuel i r, (∀ s < m, top N d F m s tl th fuel i r = true) →
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
      exact fastL_sound N F th hth hthl tl i r _ _ htl hlen (st_of r _ (Nat.powMod_def _ _ _)) h'
    · have hs' : ∀ s < m, top N d F m s tl th fuel (i + 1) r = true ∧
          top N d F m s tl th fuel (i + 1) (r + 2 * 3 ^ i) = true ∧
          top N d F m s tl th fuel (i + 1) (r + 2 * (2 * 3 ^ i)) = true := by
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

/-- Soundness of the two-word-state sharded checker (tier A): if every shard `s < m` returns `true`, then
`UpTo N`. -/
theorem checkWord2_sound {N m : ℕ} (hm : 0 < m) (h : ∀ s < m, checkWord2 N s m = true) : UpTo N := by
  intro n hn h8
  have key : n = n % 2 + n / 2 * (2 * 3 ^ 0) := by simp; omega
  have hj : n % 2 = 0 ∨ n % 2 = 1 := by omega
  simp only [checkWord2, Bool.and_eq_true] at h
  have htl := tableL_LL (37 - CheckerWord.wordDepth) CheckerWord.wordDepth
  have hlen : CheckerWord.wordDepth + (tableL CheckerWord.wordDepth (37 - CheckerWord.wordDepth)).length = 37 := by
    rw [tableL_length]; decide
  have hth := tableH_LH 38 37 le_rfl
  have hthl := tableH_length 37 38
  rw [key] at hn h8 ⊢
  rcases hj with hj | hj <;> rw [hj] at hn h8 ⊢
  · exact top_sound N _ _ m _ _ hm htl hlen hth hthl _ 0 0 (fun s hs => (h s hs).1) _ hn h8
  · exact top_sound N _ _ m _ _ hm htl hlen hth hthl _ 0 1 (fun s hs => (h s hs).2) _ hn h8

end CheckerWord2

end ErdosTernary
