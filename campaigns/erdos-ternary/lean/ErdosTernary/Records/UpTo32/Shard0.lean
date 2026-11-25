/- g005-C02: shard 0 of 8 for `N = 2 * 3^32`, one module per shard so shards build and cache separately.
   `checkWord` is precompiled (lib `ETNative`), so `native_decide` runs it as native code. -/
import ErdosTernary.CheckerWord

namespace ErdosTernary.CheckerWord

/-- Shard 0 of 8 for `N = 2 * 3^32` (tier B: `native_decide` on a closed `checkWord` term). -/
theorem word32_0 : checkWord (2 * 3 ^ 32) 0 8 = true := by native_decide

end ErdosTernary.CheckerWord
