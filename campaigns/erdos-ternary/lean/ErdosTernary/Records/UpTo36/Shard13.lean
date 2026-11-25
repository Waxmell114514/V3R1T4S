/- g006-C01: shard 13 of 16 for `N = 2 * 3^36`, one module per shard so shards build and cache separately.
   `checkWord2` is precompiled (lib `ETNative`), so `native_decide` runs it as native code. -/
import ErdosTernary.CheckerWord2

namespace ErdosTernary.CheckerWord2

/-- Shard 13 of 16 for `N = 2 * 3^36` (tier B: `native_decide` on a closed `checkWord2` term). -/
theorem word2_36_13 : checkWord2 (2 * 3 ^ 36) 13 16 = true := by native_decide

end ErdosTernary.CheckerWord2
