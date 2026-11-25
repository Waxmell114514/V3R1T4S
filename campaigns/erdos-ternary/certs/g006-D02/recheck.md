# g006-D02 independent recheck (relayed by message from session_01UnC7uYjeuuexmmY63Q5Sub, received 2026-11-25T06:28Z)

- Fresh container (no lean/.lake/build before), HEAD 533aa7d96e6f49c0fe03eb2cf3fece28e25cd5b5; `git diff daad90e7..HEAD -- lean verify` empty
- Lean 4.36.0 (611c117b…); lake build ErdosTernary.CheckerWord exit 0 (ETNative .so rebuilt from source)
- sha256 of Shard2, Shard7, ETNative.lean, CheckerWord.lean: all match sources.sha256 (`sha256sum -c` OK)
- Source review: each shard is exactly `word34_s : checkWord (2 * 3 ^ 34) s 8 = true := by native_decide`; lakefile has
  precompileModules only on ETNative, no link/extern tricks; grep for extern/implemented_by/csimp/@[export/unsafe/opaque/axiom/sorry: none;
  upTo_34_of_shards has exactly the 8 shard hypotheses and concludes the frozen UpTo (2 * 3 ^ 34)
- Rebuilds (parallel, LEAN_NUM_THREADS=1, nice 10): Shard2 EXIT=0 real 16m12s (lake 970s); Shard7 EXIT=0 real 18m01s (lake 1079s)
- lean_audit: checkWord_sound PASS tier=A; upTo_34_of_shards PASS tier=A
- Scope stated by the auditor: condition 3 only, for shards 2 and 7.
- Verdict: pass: true
