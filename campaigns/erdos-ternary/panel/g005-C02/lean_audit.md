# Lean audit g005-C02 (in progress)
Worktree branch g005-C02 @ 70b8c58 (parent b0500ba), single commit on top of parent.
- Deleted all ETNative / CheckerWord / Records/UpTo32* build outputs; rebuild started 02:5x UTC.
- Fresh ETNative.c (02:51:49) contains the real `deep` (powmod 2 r 3^(i+38), then scanT 38), no constant `true`.
- Source scan clean; lakefile/manifest/toolchain/verify unchanged; ETNative diff is pure addition. Shards building...
