/- g006-C01: shard 3 of 8 for `N = 2 * 3^34`, one module per shard so shards build and cache separately.
   `checkWord2` is precompiled (lib `ETNative`), so `native_decide` runs it as native code. -/
import ErdosTernary.CheckerWord2

namespace ErdosTernary.CheckerWord2

/-- Shard 3 of 8 for `N = 2 * 3^34` (tier B: `native_decide` on a closed `checkWord2` term). -/
theorem word2_34_3 : checkWord2 (2 * 3 ^ 34) 3 8 = true := by native_decide

end ErdosTernary.CheckerWord2
