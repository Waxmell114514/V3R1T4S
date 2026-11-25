# Lean audit g005-C02

Auditor: independent, fresh context. Worktree `.claude/worktrees/agent-a954faeb83c9d556e`, branch `g005-C02` at
70b8c58, parent b0500ba. I did not read proofs/ or the discussion.

## Claims
1. `CheckerWord.checkWord_sound {N m} (hm : 0 < m) (h : ∀ s < m, checkWord N s m = true) : UpTo N`, tier A.
2. `CheckerWord.mulMod_eq (v gh gl) (hgl : gl < 1162261467) : mulMod (3^38) v gh gl = v * (gh * 1162261467 + gl) % 3^38`.
3. `upTo_32 : UpTo (2 * 3^32)` (N = 3706040377703682), tier B, from 8 `native_decide` shard theorems.

## The "deep := true" diagnostic
- The branch has exactly one commit over the parent (`git log b0500ba..g005-C02` and `git reflog g005-C02`:
  created from b0500ba, then commit 70b8c58). `git log -p` has no committed version of `deep` other than
  `def deep (N F r i : Nat) : Bool := scanT N F r i (Nat.powMod 2 r (3 ^ (i + 38)) / 3 ^ i) 38`.
- The tracked tree is clean. The only untracked path is `lean/.scratch/`, which lake does not build, so it is irrelevant.
- I read the whole `CheckerWord` namespace in ETNative (mulMod, Lv, scanT, deep, scan, fast, table, top, wordDepth,
  checkWord). Every success path is either a real trit test (`x % 3 == 2`, `v / q3 % 3 == 2`), a bound
  (`N < r`, `N < r2`, `r ≤ 8` under `N < r + p`), or a recursive or `explore` call. There is no constant shortcut.
  The lemma would catch one anyway: `deep_sound` derives `Good N r` from `deep … = true` through `scanT_sound`,
  which could not be proved if `deep` were `true`.
- Rebuild from source: I deleted every build output under `lean/.lake/build` whose path contains ETNative,
  CheckerWord or UpTo32 (.olean/.ilean/.c/.o/.so/traces/hashes; none remained). The regenerated
  `ir/ETNative.c` (02:51:49 UTC) contains `CheckerWord_deep`, which calls `lean_nat_powmod(2, r, 3^(i+38))`,
  divides by `3^i`, then calls `scanT(…, 38)`. That is the committed definition.

## Build (`cd lean && lake build ErdosTernary ErdosTernary.Records.UpTo32`, LEAN_NUM_THREADS=1, nice)
```
✔ Built ETNative (332ms) / ETNative:c.o / ETNative:shared
✔ Built ErdosTernary.CheckerWord (1.0s)
✔ Built ErdosTernary.Records.UpTo32.Shard0 (134s) … Shard1 118s, Shard2 108s, Shard3 119s, Shard4 137s,
  Shard5 132s, Shard6 107s, Shard7 121s
✔ [4259/4260] Built ErdosTernary.Records.UpTo32 (769ms)
Build completed successfully (4260 jobs).
real 16m24.071s  user 16m21.231s  sys 0m2.952s
```

## lean_audit.py
- `ErdosTernary ErdosTernary.CheckerWord.checkWord_sound`:
  `LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']`
- `ErdosTernary.Records.UpTo32 ErdosTernary.upTo_32 --expect UpTo:2*3^32`:
  `LEAN_AUDIT: PASS tier=B axioms=['Classical.choice', word32_0..7._native.native_decide.ax_1_1 (8), 'Quot.sound', 'propext']`
- WARNs in the new files: only `native_decide` in Shard0..7. `tools/check_lock.py`: `LOCK: OK`.

## Hand checks
- `lakefile.toml`, `lake-manifest.json`, `lean-toolchain`, `verify/` and `tools/` are unchanged from the parent.
  The lean diff is: new `CheckerWord.lean`, the `CheckerWord` block appended to ETNative, a new import line in
  `ErdosTernary.lean`, `Records/UpTo32*` and a Records README row.
- ETNative: the diff is pure addition after line 98, with no `-` lines, so the existing definitions are unchanged.
  Grep over ETNative, CheckerWord.lean and UpTo32*.lean finds no extern, implemented_by, `@[…]`, unsafe, partial,
  opaque, set_option, macro, notation, instance, axiom or sorry. The one hit is the word "notation" inside a comment.
- Type fidelity:
  - `checkWord_sound` concludes the frozen `UpTo N` directly; `--expect` confirms this.
  - The proof covers both parities of n: n = n%2 + (n/2)·2·3^0, giving the roots r = 0 and r = 1 at level 0.
  - It uses `N` itself, not a shifted bound. `UpTo` is `n ≤ N`, and the checker's `N < r` cuts are consistent with it.
  - It uses all shards `s < m`. `top_sound` sends node `(d, r)` to shard `r / 2 % m`, which is `< m`.
  - `mulMod_eq` is exactly as claimed; it goes through `B_sq : 3^38 = 3^19·3^19` and `mulMod_gen`.
- `upTo_32` uses m = 8. The match covers s = 0..7 with `word32_0..7`, and the case `_ + 8` is refuted by `hs`.
  Each `word32_i : checkWord (2 * 3 ^ 32) i 8 = true` is the same `checkWord` with the same N and m, so all 8
  shards are combined.
- `native_decide` is used only on these 8 closed literal goals, nowhere else in the new code.
- 2·3^32 = 2·1853020188851841 = 3706040377703682. This matches the claim.

## Hypothetical deviation
Suppose `deep`, or any success branch, were a constant `true`, and a stale `.so` or `.olean` built from that
version had been reused. Then the 8 `native_decide` evaluations would certify a function that differs from the
one `checkWord_sound` was proved about, and `upTo_32` could hold vacuously with respect to the real search,
claiming UpTo (2·3^32) without the trits being checked. Two things rule this out: the rebuild from deleted outputs
(the regenerated C has the real `deep`), and the kernel-checked `deep_sound`. Remaining trust base (tier B):
the Lean compiler, the C toolchain and GMP, via `Lean.ofReduceBool` and native_decide's auxiliary axioms.

## Verdict
All three claims hold as stated. Claim 1 is tier A, claim 2 is a tier-A lemma, and claim 3 is tier B after a
clean rebuild.

pass: true
