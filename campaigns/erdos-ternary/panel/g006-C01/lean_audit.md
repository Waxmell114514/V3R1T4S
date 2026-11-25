# Lean audit: g006-C01

Auditor: independent Lean auditor, fresh context. I read only the Lean sources under `lean/`, `verify/Statement.lean`, `verify/lean_audit.py` and `tools/check_lock.py`. I did not read `proofs/` or any discussion.
Worktree: `.claude/worktrees/agent-a50161072126a61e9/campaigns/erdos-ternary`, branch `g006-C01`, commit c4b90bc (parent daad90e). The working tree is clean (`git status` shows nothing).

## Claims audited
1. `CheckerWord2.checkWord2_sound {N m} (hm : 0 < m) (h : ∀ s < m, checkWord2 N s m = true) : UpTo N`, tier A.
2. `CheckerWord2.mul2_gen`: the two-word schoolbook product modulo `B^4`, together with `mulLoB < B^2`.
3. `upTo_34 : UpTo (2*3^34)`, tier B, built from 8 shards.
4. Additionally, `upTo_36 : UpTo (2*3^36)`, tier B, built from 16 shards. **I did not rebuild this one.** It was audited against the existing build outputs.

## Rebuild from source (diagnostic-variant rule)
- I deleted these outputs at 06:34 UTC:
  - `.lake/build/lib/libErdosTernary_ETNative.so*`
  - `.lake/build/lib/lean/ETNative.*`
  - `.lake/build/ir/ETNative.*`
  - all `Records/UpTo34*` outputs in `lib/lean` and `ir`
- The build used `LEAN_NUM_THREADS=1` and `nice`. Lake has no option to limit jobs, so I built the shards in groups of 3 or fewer:
  1. `lake build ErdosTernary`: exit 0, 3 s. It rebuilt `ETNative`, `ETNative:c.o` and `ETNative:shared`.
  2. Shards 0–2: 599 s wall (223, 196 and 177 s).
  3. Shards 3–5: 665 s wall (203, 235 and 223 s).
  4. Shards 6–7: 389 s wall (205 and 182 s).
  5. `lake build ErdosTernary ErdosTernary.Records.UpTo34`: `✔ [4261/4262] Built ErdosTernary.Records.UpTo34 (864ms)` / `Build completed successfully (4262 jobs).`
  - Total: about 1660 s wall and about 1644 s of shard CPU time.
- The `.so` was refreshed:
  - The new file has mtime 2026-11-25 06:34:31; the old one was 05:25.
  - `ETNative.olean` and `ir/ETNative.c` also have new timestamps (06:34:31).
  - `nm -D` lists 24 `CheckerWord2` symbols, including `lp_ErdosTernary_ErdosTernary_CheckerWord2_checkWord2`.
  - `UpTo34.olean` has mtime 07:02:07.
- UpTo36:
  - `lake build --no-build ErdosTernary.Records.UpTo36` reports "All targets up-to-date". The rebuilt ETNative has the same trace hash, and CheckerWord2 was "Replayed".
  - Its shard oleans come from the author's earlier build (UpTo36.olean mtime 06:31:47). **Its native_decide evaluations were not re-run by me.**

## lean_audit.py (last lines)
- `ErdosTernary.CheckerWord2 ErdosTernary.CheckerWord2.checkWord2_sound` → `LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']`
- `ErdosTernary.Records.UpTo34 ErdosTernary.upTo_34 --expect UpTo:2*3^34` → `LEAN_AUDIT: PASS tier=B`
  - Axioms: the 3 standard ones plus exactly `word2_34_{0..7}._native.native_decide.ax_1_1`.
- `ErdosTernary.Records.UpTo36 ErdosTernary.upTo_36 --expect UpTo:2*3^36` → `LEAN_AUDIT: PASS tier=B`
  - Axioms: the 3 standard ones plus exactly `word2_36_{0..15}._native.native_decide.ax_1_1`.
  - This result uses the existing build. It was not rebuilt.
- The only WARNs are `native_decide` occurrences. There are no FORBIDDEN hits.
- `python3 tools/check_lock.py` → `LOCK: OK`.

## Hand checks
- **Claim 1 type:**
  - In a separate check file, `example : ∀ {N m : ℕ}, 0 < m → (∀ s < m, CheckerWord2.checkWord2 N s m = true) → ErdosTernary.UpTo N := @CheckerWord2.checkWord2_sound` elaborates with `import Statement`. So `UpTo` is the frozen definition: `∀ n ≤ N, 8 < n → 2 ∈ Nat.digits 3 (2^n)`, i.e. `n ≤ N`, which is inclusive.
  - `#print axioms` gives the 3 standard axioms only.
  - The proof proceeds by full induction through `top_sound`, `fastL_sound`, `fastH_sound`, `scanL_sound`, `scanH_sound` and `st_step`. The shard selector `r / 2 % m` is used with `Nat.mod_lt _ hm`, so every node at depth `d` is covered by some shard `s < m`. `m` is arbitrary positive.
- **Claim 2:** the statement in the file matches the claim exactly: `mulLoB B lo g0 g1 + B*B*mulHiB … = (lo + B*B*hi) * (g0 + B*g1 + B*B*h0 + B*B*B*h1) % (B*B*(B*B)) ∧ mulLoB … < B*B`, for all inputs and `0 < B`.
  - My re-elaborated copy of this type is accepted, and it depends on the 3 standard axioms only.
  - `mulLo_eq` and `mulHi_eq` are `rfl` links to the native `mulLo` and `mulHi` at `B = 3^19 = 1162261467`. `B_four` and `B_sq'` connect this to `3^76` and `3^38`.
- **ETNative diff:** one hunk, purely additive (0 removed lines). It adds only `namespace CheckerWord2 … end CheckerWord2` after `end CheckerWord`. The existing definitions are unchanged.
- **Forbidden constructs:** the added lines contain no `extern`, `implemented_by`, `@[...]`, `unsafe`, `partial`, `opaque`, `set_option`, `axiom`, `sorry`, `macro`, `notation`, `instance` or `attribute`.
- **Unchanged files:** `lakefile.toml` and `lake-manifest.json` are unchanged versus the parent. So is `verify/`. `ErdosTernary.lean` adds only `import ErdosTernary.CheckerWord2`.
- **History:**
  - `daad90e..g006-C01` contains a single commit, c4b90bc. The reflog shows the branch was created from daad90e and then got one commit.
  - `git log --all -S CheckerWord2` finds only c4b90bc and 2ea4981, and 2ea4981 has no `.lean` files.
  - `git log -p` over `lean/` shows no committed `implemented_by`, `extern`, `unsafe`, `partial`, `opaque`, `set_option`, `sorry` or `axiom`. No unsound diagnostic variant was ever committed.
- **Shard combination:**
  - `upTo_34` uses `(m := 8)` and matches `0..7` onto `word2_34_0..7`, with `_ + 8` ruled out by omega.
  - `upTo_36` uses `(m := 16)` and matches `0..15` onto `word2_36_0..15`, with `_ + 16` ruled out by omega.
  - Each shard file states `checkWord2 (2 * 3 ^ K) s m = true` with the matching `K`, `s` and `m`. All shard files are textually identical apart from their numbers.
- **native_decide:** used only on closed Boolean goals `checkWord2 (2*3^K) s m = true` with literal arguments.
- **Hypothetical deviation:**
  - If one shard index were omitted, or a shard ran with a wrong `m` or `N`, then `checkWord2_sound`'s hypothesis `∀ s < m` would not be met. The match would then fail to typecheck, so this cannot silently give a false result.
  - If `mulLo`/`mulHi` in native code differed from the kernel definitions (for example via `implemented_by`), a false `checkWord2 … = true` could be accepted. That would yield `UpTo (2*3^34)` from an unexhausted search. The source scan, the diff check and the fresh `.so` rebuild exclude this for UpTo34.
  - If `UpTo` were redefined, the conclusion could be weaker than the frozen statement, for example `n < N` instead of `n ≤ N`. The `--expect` check against the frozen `Statement` rules this out.

## Verdict
- Claims 1 and 2 hold at tier A.
- Claim 3 holds at tier B, rebuilt from source with the precompiled library deleted first.
- `upTo_36` also passes the audit at tier B with the existing build. It was not rebuilt here.

pass: true
