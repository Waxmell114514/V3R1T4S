/- g004-C02: the checker's executable definitions, in a module that imports only Lean core (no Mathlib).

This file is the whole lean_lib `ETNative` (lakefile.toml, `precompileModules = true`). Lake compiles it to C and a
shared library and loads that library (`--load-dynlib`) when elaborating any module that imports it, so
`native_decide` on `checkShard …` runs these functions as compiled machine code instead of in Lean's IR
interpreter. Precompiling a module requires precompiling its whole import closure, which is why the definitions
live here, away from Mathlib; their soundness proofs stay in `ErdosTernary.Checker` and
`ErdosTernary.CheckerShard`, which import this file.

The definitions are moved verbatim from `ErdosTernary/Checker.lean` (g002-L01: `explore`, `check`) and
`ErdosTernary/CheckerShard.lean` (g003-L01: `Lvl`, `scan`, `fast`, `table`, `top`, `shardDepth`, `modExp`,
`checkShard`), with the same fully qualified names; only `ℕ` is spelled `Nat` (Mathlib notation). See those files
for the documentation of each definition. -/

namespace ErdosTernary

namespace Checker

/-- One node of the residue tree (see `ErdosTernary/Checker.lean`). -/
def explore (N : Nat) : Nat → Nat → Nat → Bool
  | 0, _, _ => false
  | fuel + 1, i, r =>
    let q := 3 ^ i
    if N < r then true
    else if Nat.powMod 2 r (3 * q) / q = 2 then true
    else if N < r + 2 * q ∧ r ≤ 8 then true
    else explore N fuel (i + 1) r && explore N fuel (i + 1) (r + 2 * q) &&
      explore N fuel (i + 1) (r + 2 * (2 * q))

/-- The checker: the two level-1 classes `n ≡ 0, 1 (mod 2)`. -/
def check (N : Nat) : Bool := explore N (N + 64) 0 0 && explore N (N + 64) 0 1

end Checker

namespace CheckerShard

open Checker

/-- Per-level constants for level `j` (invariant `LV` in `ErdosTernary/CheckerShard.lean`). -/
structure Lvl where
  /-- `2^(2 * 3^j) % 3^L` -/
  g : Nat
  /-- `2 * 3^j`, the period at level `j` -/
  p : Nat
  /-- `2 * (2 * 3^j)` -/
  p2 : Nat
  /-- `3^(j+1)` -/
  q3 : Nat

/-- Trits `i, i+1, …` of `2^r` (one per remaining table entry), given `x = 2^r % 3^L / 3^i`;
then `Checker.explore` at level `L`. -/
def scan (N F L r : Nat) : Nat → List Lvl → Bool
  | _, [] => explore N F L r
  | x, _ :: es => if x % 3 == 2 then true else scan N F L r (x / 3) es

/-- Exploration of node `(i, r)` below the shard level, with `M = 3^L`, `v = 2^r % M` and `es` the table for
levels `i, i+1, …, L-1`. `F` is the fuel of the fallback. -/
def fast (N M L F : Nat) : Nat → Nat → List Lvl → Bool
  | r, _, [] => explore N F L r
  | r, v, e :: es =>
    if N < r + e.p then (r ≤ 8 || scan N F L r (v / e.q3) es)
    else
      let q3 := e.q3
      let v1 := v * e.g % M
      let v2 := v1 * e.g % M
      let r2 := r + e.p2
      (v / q3 % 3 == 2 || fast N M L F r v es) &&
      (v1 / q3 % 3 == 2 || fast N M L F (r + e.p) v1 es) &&
      (N < r2 || v2 / q3 % 3 == 2 || fast N M L F r2 v2 es)

/-- The table for levels `i, i+1, …, i+n-1`. -/
def table (M i n : Nat) : List Lvl :=
  (List.range' i n).map fun j => ⟨Nat.powMod 2 (2 * 3 ^ j) M, 2 * 3 ^ j, 2 * (2 * 3 ^ j), 3 ^ (j + 1)⟩

/-- The top of the tree down to level `d`, where node `(d, r)` goes to `fast` only in shard `r / 2 % m = s`.
`tbl` is the table for levels `d, …, L-1`. -/
def top (N d L M F m s : Nat) (tbl : List Lvl) : Nat → Nat → Nat → Bool
  | 0, _, _ => false
  | fuel + 1, i, r =>
    let q := 3 ^ i
    if N < r then true
    else if Nat.powMod 2 r (3 * q) / q = 2 then true
    else if N < r + 2 * q ∧ r ≤ 8 then true
    else if i = d then (if r / 2 % m = s then fast N M L F r (Nat.powMod 2 r M) tbl else true)
    else top N d L M F m s tbl fuel (i + 1) r && top N d L M F m s tbl fuel (i + 1) (r + 2 * q) &&
      top N d L M F m s tbl fuel (i + 1) (r + 2 * (2 * q))

/-- Shard level and modulus exponent used by `checkShard`. -/
def shardDepth : Nat := 10
def modExp : Nat := 40

/-- Shard `s` of `m`: the two level-0 classes `n ≡ 0, 1 (mod 2)`, restricted to shard `s` at level `shardDepth`. -/
def checkShard (N s m : Nat) : Bool :=
  let M := 3 ^ modExp
  let tbl := table M shardDepth (modExp - shardDepth)
  top N shardDepth modExp M (N + 64) m s tbl (shardDepth + 1) 0 0 &&
    top N shardDepth modExp M (N + 64) m s tbl (shardDepth + 1) 0 1

end CheckerShard

/-! ### g005-C02: word-size state (`CheckerWord`)

Same tree and same shape as `CheckerShard`, but the hot-loop state `v = 2^r % 3^38` and every intermediate value
stays below `2^63`, so Lean's runtime keeps it as an unboxed scalar `Nat` (no GMP). `3^38 < 2^63` but
`v * g` can reach `3^76`, so the product mod `M = 3^38` is computed by `mulMod` from the halves
`v = vh * 3^19 + vl`, `g = gh * 3^19 + gl` (each `< 3^19 < 2^31`): every product is `< 3^38`, every sum
`< 2 * 3^38 < 2^63`, and the last reduction is one conditional subtraction. `1162261467 = 3^19` is a literal
(a compile-time constant divisor); `M` is passed as an argument because a literal `≥ 2^32` is rebuilt from a
string on every use in the generated C. Single-member tails read trits of `v` up to level 38, then re-seed once
with `Nat.powMod 2 r (3^76)` (the only bignum step, once per such tail) and read trits 38..75 of the small value
`2^r % 3^76 / 3^38`; only then `Checker.explore` is the fallback. Soundness: `ErdosTernary/CheckerWord.lean`. -/

namespace CheckerWord

open Checker

/-- `v * (gh * 3^19 + gl) % M` for `M = 3^38` and `gl < 3^19`; all intermediates `< 2^63` when also
`v < M` and `gh < 3^19`. -/
def mulMod (M v gh gl : Nat) : Nat :=
  let vh := v / 1162261467
  let vl := v % 1162261467
  let s := (vh * gl + vl * gh) % 1162261467 * 1162261467 + vl * gl
  if s < M then s else s - M

/-- Per-level constants for level `j`: `g = 2^(2 * 3^j) % 3^38` split as `gh = g / 3^19`, `gl = g % 3^19`. -/
structure Lv where
  gh : Nat
  gl : Nat
  /-- `2 * 3^j` -/
  p : Nat
  /-- `2 * (2 * 3^j)` -/
  p2 : Nat
  /-- `3^(j+1)` -/
  q3 : Nat

/-- Trits `i, i+1, …, i+k-1` of `2^r`, given `x = 2^r % 3^(i+k) / 3^i`; then `Checker.explore` at level `i+k`. -/
def scanT (N F r : Nat) : Nat → Nat → Nat → Bool
  | i, _, 0 => explore N F i r
  | i, x, k + 1 => if x % 3 == 2 then true else scanT N F r (i + 1) (x / 3) k

/-- Re-seed at level `i`: the next 38 trits from one `Nat.powMod`. -/
def deep (N F r i : Nat) : Bool := scanT N F r i (Nat.powMod 2 r (3 ^ (i + 38)) / 3 ^ i) 38

/-- Trits of `2^r` from the word state (one per remaining table entry), given `x = 2^r % 3^38 / 3^i`;
then `deep` at level 38. -/
def scan (N F r : Nat) : Nat → List Lv → Bool
  | _, [] => deep N F r 38
  | x, _ :: es => if x % 3 == 2 then true else scan N F r (x / 3) es

/-- Exploration of node `(i, r)`, `M = 3^38`, `v = 2^r % M`, `es` the table for levels `i, …, 37`. -/
def fast (N F M : Nat) : Nat → Nat → List Lv → Bool
  | r, _, [] => explore N F 38 r
  | r, v, e :: es =>
    if N < r + e.p then (r ≤ 8 || scan N F r (v / e.q3) es)
    else
      let q3 := e.q3
      let v1 := mulMod M v e.gh e.gl
      let v2 := mulMod M v1 e.gh e.gl
      let r2 := r + e.p2
      (v / q3 % 3 == 2 || fast N F M r v es) &&
      (v1 / q3 % 3 == 2 || fast N F M (r + e.p) v1 es) &&
      (N < r2 || v2 / q3 % 3 == 2 || fast N F M r2 v2 es)

/-- The table for levels `i, …, i+n-1`, modulus `M`. -/
def table (M i n : Nat) : List Lv :=
  (List.range' i n).map fun j =>
    let g := Nat.powMod 2 (2 * 3 ^ j) M
    ⟨g / 1162261467, g % 1162261467, 2 * 3 ^ j, 2 * (2 * 3 ^ j), 3 ^ (j + 1)⟩

/-- The top of the tree down to level `d`; node `(d, r)` goes to `fast` only in shard `r / 2 % m = s`. -/
def top (N d F M m s : Nat) (tbl : List Lv) : Nat → Nat → Nat → Bool
  | 0, _, _ => false
  | fuel + 1, i, r =>
    let q := 3 ^ i
    if N < r then true
    else if Nat.powMod 2 r (3 * q) / q = 2 then true
    else if N < r + 2 * q ∧ r ≤ 8 then true
    else if i = d then (if r / 2 % m = s then fast N F M r (Nat.powMod 2 r M) tbl else true)
    else top N d F M m s tbl fuel (i + 1) r && top N d F M m s tbl fuel (i + 1) (r + 2 * q) &&
      top N d F M m s tbl fuel (i + 1) (r + 2 * (2 * q))

/-- Shard level used by `checkWord`. -/
def wordDepth : Nat := 10

/-- Shard `s` of `m` (word-size state, `M = 3^38`). -/
def checkWord (N s m : Nat) : Bool :=
  let M := 3 ^ 38
  let tbl := table M wordDepth (38 - wordDepth)
  top N wordDepth (N + 64) M m s tbl (wordDepth + 1) 0 0 &&
    top N wordDepth (N + 64) M m s tbl (wordDepth + 1) 0 1

end CheckerWord

end ErdosTernary
