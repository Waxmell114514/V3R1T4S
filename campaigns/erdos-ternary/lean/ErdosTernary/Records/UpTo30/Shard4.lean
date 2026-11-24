/- g004-C02: shard 4 of 8 for `N = 2 * 3^30`, one module per shard so shards build and cache separately.
   `checkShard` is precompiled (lib `ETNative`), so `native_decide` runs it as native code. -/
import ErdosTernary.CheckerShard

namespace ErdosTernary.CheckerShard

/-- Shard 4 of 8 for `N = 2 * 3^30` (tier B: `native_decide` on a closed `checkShard` term). -/
theorem shard30_4 : checkShard (2 * 3 ^ 30) 4 8 = true := by native_decide

end ErdosTernary.CheckerShard
