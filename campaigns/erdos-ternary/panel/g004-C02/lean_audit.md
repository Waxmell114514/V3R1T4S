# Lean audit g004-C02

Auditor: independent Lean auditor (fresh context). Worktree branch g004-C02, commit 3e947f2 (parent 770152b), clean working tree.
Did not read proofs/ or discussion.

## Claims audited
1. The checker's executable definitions (`Checker.explore`, `check`; `CheckerShard.Lvl`, `scan`, `fast`, `table`, `top`,
   `shardDepth`, `modExp`, `checkShard`) moved verbatim into the Mathlib-free, precompiled lib `ETNative`
   (lakefile `[[lean_lib]] ETNative`, `precompileModules = true`); previously audited theorems unchanged:
   `Checker.check_sound`, `CheckerShard.checkShard_sound` (tier A), `upTo_vardi`, `upTo_26` (tier B).
2. `ErdosTernary.upTo_30 : UpTo (2*3^30)` (2*3^30 = 411782264189298, checked) at tier B, from 8 shard theorems
   `checkShard (2*3^30) s 8 = true := by native_decide`, s = 0..7.

## (a) Clean rebuild
Deleted only `.lake/build/{ir,lib/lean}/ETNative.*`, `lib/libErdosTernary_ETNative.so*`, and the `Records/UpTo30{,.*}` outputs; then
`nice lake build ErdosTernary ErdosTernary.Records.UpTo30` (LEAN_NUM_THREADS=1):
```
✔ Built ETNative (293ms)  ✔ Built ETNative:c.o (208ms)  ✔ Built ETNative:shared (47ms)
✔ Built ErdosTernary.Records.UpTo30.Shard0 (92s) ... Shard1 82s, Shard2 75s, Shard3 82s, Shard4 94s, Shard5 91s, Shard6 73s
✔ [4242/4256] Built ErdosTernary.Records.UpTo30.Shard7 (83s)
✔ [4255/4256] Built ErdosTernary.Records.UpTo30 (863ms)
Build completed successfully (4256 jobs).
```
Wall time 679 s total (includes rebuild of Checker/CheckerShard and their native_decide); shards sum ~672 s sequential, ~1.4 min each.
Only warnings: Mathlib "module system" import notices.

## (b) lean_audit.py and lock
```
Checker.check_sound              LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
CheckerShard.checkShard_sound    LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
upTo_vardi --expect UpTo:2*3^20  LEAN_AUDIT: PASS tier=B axioms=[... upTo_vardi._native.native_decide.ax_1_1 ...]
upTo_26    --expect UpTo:2*3^26  LEAN_AUDIT: PASS tier=B axioms=[... shard26_0..3._native.native_decide.ax_1_1 ...]
Records.UpTo30 upTo_30 --expect UpTo:2*3^30
  LEAN_AUDIT: PASS tier=B axioms=['Classical.choice', shard30_0 .. shard30_7 ._native.native_decide.ax_1_1, 'Quot.sound', 'propext']
tools/check_lock.py              LOCK: OK
```
WARNs are only `native_decide` in Checker, CheckerShard, Records/UpTo30/Shard0..7 (and older Records), as expected.

## (c) Hand checks (lakefile / ETNative not fully covered by the script)
- `git diff 770152b 3e947f2 -- lean/lakefile.toml`: the only change is the added `[[lean_lib]] ETNative` block
  (name, srcDir = "ErdosTernary/Native", roots = ["ETNative"], precompileModules = true) plus comments. No
  moreLinkArgs / moreLeancArgs / moreLeanArgs / weakLeanArgs / extraDepTargets / extern_lib / lean_exe / target; no lakefile.lean.
  The ErdosTernary lib block is unchanged (no globs, so ETNative is not double-registered).
- `ETNative.lean`: no `import` at all (core prelude only); no extern, implemented_by, @[export]/any `@[`, unsafe, partial,
  opaque, set_option, macro, syntax, notation, instance, attribute, csimp, initialize — the only grep hits are inside the header comment.
  (It also lies under ErdosTernary/**, so lean_audit.py's FORBIDDEN scan does cover it.)
- Verbatim: extracted the definition text from 770152b Checker.lean / CheckerShard.lean and from 3e947f2 ETNative.lean,
  applied ℕ→Nat to the old text, and diffed. Code is byte-identical; the sole difference is one shortened docstring
  (`fast`: "(see `LV`); the level `i` itself is implicit" removed). Namespaces are the same
  (`ErdosTernary.Checker`, `ErdosTernary.CheckerShard` with `open Checker`), so fully qualified names are unchanged.
- Residual diff in Checker.lean / CheckerShard.lean: only `+import ETNative` and removal of the definitions (replaced by a
  comment). All theorem statements and proofs untouched; `check_sound`, `checkShard_sound` re-elaborate against the moved defs (tier A).

## (d) upTo_30 composition
`upTo_30 := checkShard_sound (m := 8) (by norm_num) fun s hs => match s, hs with | 0..7 => shard30_0..7 | _+8, h => absurd h (by omega)`.
All 8 indices 0..7 are present, each shard theorem has exactly the statement `checkShard (2 * 3 ^ 30) s 8 = true` with the matching s,
and the axiom list confirms all 8 shard native axioms are used. `checkShard_sound {N m} (hm : 0 < m) (h : ∀ s < m, checkShard N s m = true) : UpTo N`
with `UpTo` the frozen definition from verify/Statement.lean (`∀ n ≤ N, 8 < n → 2 ∈ Nat.digits 3 (2^n)`); `--expect` elaborated.
native_decide is used only on closed numeral terms.

## What tier B now trusts
Besides the kernel and the tier-A soundness proof: (i) the Lean compiler pipeline (LCNF/IR -> C emission) for ETNative's
definitions, (ii) the C toolchain bundled with Lean (leanc / clang) that compiled `ETNative.c` to `ETNative.c.o` and linked
`libErdosTernary_ETNative.so`, (iii) the Lean runtime (GMP-backed Nat bignum ops, `Nat.powMod`), (iv) Lake correctly building that
.so from this exact source and loading it via `--load-dynlib` when elaborating the shard modules (the plugin is trusted as an
opaque binary; a stale or swapped .so would not be detected by the kernel). Previously (IR interpreter) (ii) and (iv) were not in
the trust base; (i) and (iii) were in part. This is still within the standard `Lean.ofReduceBool` / native_decide trust model.

## Hypothetical deviation
If the moved code were not verbatim (e.g. `top` dropped the `r / 2 % m = s` guard or `fast` returned `true` on a branch), then
`checkShard_sound` would either fail to re-prove (caught: it is tier A on the new defs) or, if the change kept it provable, it
would still be sound since the proof is about the very definitions that are executed. The real residual risk is a mis-compiled
or substituted .so making a shard return `true` wrongly, which would yield a false `UpTo (2*3^30)`; mitigated only by trusting
the toolchain and by my clean rebuild from source.

pass: true
