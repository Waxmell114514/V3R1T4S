# Lean audit: g003-L01

Auditor: independent Lean auditor, fresh context. Worktree branch `g003-L01-shard`, commit `9ae2acb`.
Files read: `lean/ErdosTernary/CheckerShard.lean`, `lean/ErdosTernary/Checker.lean`, `lean/ErdosTernary.lean`,
`lean/lakefile.toml`, `verify/Statement.lean`, `verify/lean_audit.py`. I did not read proofs/, .scratch/ or discussion.

## Claims audited
1. `ErdosTernary.CheckerShard.checkShard_sound` (tier A): for every N and every m > 0, if `checkShard N s m = true` for all s < m, then `UpTo N`.
2. `ErdosTernary.upTo_26 : UpTo (2*3^26)` (tier B). 2*3^26 = 5083731656658.
3. `ErdosTernary.upTo_28 : UpTo (2*3^28)` (tier B). 2*3^28 = 45753584909922.

## Commands run
`cd lean && lake build ErdosTernary.CheckerShard` (tail):
```
Build completed successfully (2141 jobs).
```
(Only "module system" import warnings. The cached olean was replayed. To re-run the 12 native_decide shards,
I also elaborated the file from scratch with `lake env lean ErdosTernary/CheckerShard.lean`, result below.)

FRESH_PLACEHOLDER

`python3 verify/lean_audit.py ErdosTernary.CheckerShard ErdosTernary.CheckerShard.checkShard_sound`:
```
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
```
`python3 verify/lean_audit.py ErdosTernary.CheckerShard ErdosTernary.upTo_26 --expect UpTo:2*3^26`:
```
LEAN_AUDIT: PASS tier=B axioms=['Classical.choice', 'ErdosTernary.CheckerShard.shard26_0._native.native_decide.ax_1_1', ..._1, ..._2, ..._3, 'Quot.sound', 'propext']
```
`python3 verify/lean_audit.py ErdosTernary.CheckerShard ErdosTernary.upTo_28 --expect UpTo:2*3^28`:
```
LEAN_AUDIT: PASS tier=B axioms=['Classical.choice', 'ErdosTernary.CheckerShard.shard28_0._native.native_decide.ax_1_1', ... shard28_7 ..., 'Quot.sound', 'propext']
```
The WARN lines name only `native_decide` (Checker.lean, CheckerShard.lean). No forbidden tokens were found.
`python3 tools/check_lock.py`: `LOCK: OK`. `git status`: the only change is the untracked `lean/.scratch/`, so the commit's sources are unmodified.

I also ran `#check` from a scratch file outside the repository:
```
@ErdosTernary.CheckerShard.checkShard_sound : ∀ {N m : ℕ},
  0 < m → (∀ s < m, ErdosTernary.CheckerShard.checkShard N s m = true) → ErdosTernary.UpTo N
ErdosTernary.upTo_26 : ErdosTernary.UpTo (2 * 3 ^ 26)
ErdosTernary.upTo_28 : ErdosTernary.UpTo (2 * 3 ^ 28)
```
`example : 2*3^26 = 5083731656658 ∧ 2*3^28 = 45753584909922 := by norm_num` elaborates.

## Item-by-item check
* **Statement is exact.** `UpTo` is the frozen definition from `verify/Statement.lean`: `∀ n ≤ N, 8 < n → 2 ∈ Nat.digits 3 (2^n)`. It is not redefined. The hypotheses quantify over `s < m` (strict) with `0 < m`. That is the informal claim exactly.
* **Shard coverage in the soundness proof.** In `top_sound`, at level `i = d`, the proof takes the hypothesis for the one shard `s = r/2 % m`. It gets `s < m` from `Nat.mod_lt _ hm`, unfolds `top`, and calls `fast_sound`. This needs no assumption about `r` (for example, evenness). For `i ≠ d`, it uses all shards for each of the three children and applies `split_class`. In `checkShard_sound`, `n` is split by `n % 2` into the classes (0,0) and (0,1). Both conjuncts of `checkShard` are used.
* **Combining the shards.** `upTo_26` passes `m := 4` and matches on `s` with cases 0,1,2,3 and `_ + 4` (absurd by `hs : s < 4`). `upTo_28` passes `m := 8` with cases 0..7 and `_ + 8`. Lean checks that a `match` is exhaustive, and every case's type is the `checkShard (2*3^K) s m = true` goal with the same N and m as the shard theorems. So exactly the shards s < m are discharged, and the `#check` above confirms the resulting types.
* **native_decide.** It appears only on the 12 closed goals `checkShard (2*3^K) i m = true` with literal arguments. It does not appear in the general argument: `checkShard_sound` is tier A.
* **The LV table.** `table` is an ordinary `def` built from `Nat.powMod`, `2*3^j`, `2*(2*3^j)` and `3^(j+1)`. `checkShard` evaluates exactly that term. `table_LV` proves `LV (3^modExp) shardDepth (table ...)` for that same term, using `Nat.powMod_def` (tier A axioms only). `hlen` (length = 30, `10 + 30 = 40`) is proved by `decide` after `table_length`. So the table is not an unchecked list of constants: its values are proved correct before the computation relies on them.
* **Helper definitions.** `Lvl`, `LV`, `Good`, `fast`, `scan`, `top`, `shardDepth`, `modExp` and `table` occur only in the checker and its soundness lemmas. `Good N n` unfolds to exactly the body of `UpTo` for a single n. None of them can change `UpTo`, because the final types are stated against the frozen `ErdosTernary.UpTo`.
* **Constructs that could make compiled behaviour differ from the logic.** I grepped both checker files and `ErdosTernary.lean` for `@[`, `attribute`, `set_option`, `macro`, `syntax`, `notation`, `instance`, `opaque`, `partial`, `extern`, `implemented_by`, `csimp` and `unsafe`. There are none. All recursion is structural: fuel for `top` and `explore`, the list for `fast` and `scan`. What remains for native_decide to trust is the compiler and runtime, including GMP and the core `Nat.powMod` implementation. That is the stated tier B.
* **Edge cases.** The bound is `n ≤ N`, matching `UpTo`. `8 < n` is used strictly. `modExp - shardDepth` = 30, so no truncated subtraction applies. Running out of fuel returns `false`, which is harmless for soundness. The fuel `shardDepth+1 = 11` from level 0 reaches level 10 with fuel 1 left.

## Independent Python check of the shard assignment
I reimplemented `top` down to level 10 (same three tests, children `r + j*2*3^i`) for both N values. For each N, there are 1024 surviving level-10 nodes, all distinct, all even, and pairwise distinct mod 2*3^10. Under `s = (r/2) % m`, each node is assigned to exactly one s in [0, m):
* K=26, m=4: per-shard counts 283/263/226/252 (sum 1024).
* K=28, m=8: per-shard counts 140/124/114/125/143/139/112/127 (sum 1024).

The soundness proof does not need this (it holds for any r), but it confirms that the docstring's description is right and no shard is empty.

## Hypothetical deviations and what they would wrongly conclude
* Suppose `top_sound` used the hypothesis for a fixed shard instead of `r/2 % m`, or `top` sent nodes with `r/2 % m ≠ s` to `true` and the proof assumed one shard. Then a single passing shard would "prove" `UpTo N` while about (m-1)/m of the level-10 classes were never explored. That would be a false verification bound.
* Suppose the match in `upTo_28` covered only s < 7. It would not compile, because the match would not be exhaustive. Without the match check, shard 7's 127 classes would go unchecked.
* Suppose `LV` were assumed rather than proved, or `table` were a literal list. A wrong `g` entry would make `fast` test trits of the wrong residues, and the checker could accept n whose `2^n` has no digit 2. Here `table_LV` excludes this.
* Suppose the statement said `n < N` or used a local `UpTo`. It would prove a weaker or different proposition. The `--expect UpTo:2*3^K` check against the frozen definition excludes this.

None of these deviations is present.

pass: true
