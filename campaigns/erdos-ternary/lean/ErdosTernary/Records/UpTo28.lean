/- g003-L01 record evaluation moved out of the default build (Critic, reports/gen_003/critic_L01.md):
   eight native_decide shards for N = 2 * 3^28, ~11 min. Build explicitly: lake build ErdosTernary.Records.UpTo28 -/
import ErdosTernary.CheckerShard

namespace ErdosTernary

namespace CheckerShard

/-- Shard 0 of 8 for `N = 2 * 3^28` (tier B). -/
theorem shard28_0 : checkShard (2 * 3 ^ 28) 0 8 = true := by native_decide

/-- Shard 1 of 8 for `N = 2 * 3^28` (tier B). -/
theorem shard28_1 : checkShard (2 * 3 ^ 28) 1 8 = true := by native_decide

/-- Shard 2 of 8 for `N = 2 * 3^28` (tier B). -/
theorem shard28_2 : checkShard (2 * 3 ^ 28) 2 8 = true := by native_decide

/-- Shard 3 of 8 for `N = 2 * 3^28` (tier B). -/
theorem shard28_3 : checkShard (2 * 3 ^ 28) 3 8 = true := by native_decide

/-- Shard 4 of 8 for `N = 2 * 3^28` (tier B). -/
theorem shard28_4 : checkShard (2 * 3 ^ 28) 4 8 = true := by native_decide

/-- Shard 5 of 8 for `N = 2 * 3^28` (tier B). -/
theorem shard28_5 : checkShard (2 * 3 ^ 28) 5 8 = true := by native_decide

/-- Shard 6 of 8 for `N = 2 * 3^28` (tier B). -/
theorem shard28_6 : checkShard (2 * 3 ^ 28) 6 8 = true := by native_decide

/-- Shard 7 of 8 for `N = 2 * 3^28` (tier B). -/
theorem shard28_7 : checkShard (2 * 3 ^ 28) 7 8 = true := by native_decide

end CheckerShard

/-- `UpTo (2 * 3^28)` (N = 45753584909922). Tier B, from the eight shard evaluations `CheckerShard.shard28_i`. -/
theorem upTo_28 : UpTo (2 * 3 ^ 28) :=
  CheckerShard.checkShard_sound (m := 8) (by norm_num) fun s hs =>
    match s, hs with
    | 0, _ => CheckerShard.shard28_0
    | 1, _ => CheckerShard.shard28_1
    | 2, _ => CheckerShard.shard28_2
    | 3, _ => CheckerShard.shard28_3
    | 4, _ => CheckerShard.shard28_4
    | 5, _ => CheckerShard.shard28_5
    | 6, _ => CheckerShard.shard28_6
    | 7, _ => CheckerShard.shard28_7
    | _ + 8, h => absurd h (by omega)

end ErdosTernary
