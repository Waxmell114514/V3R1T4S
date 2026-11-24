/- g004-C02 record: `UpTo (2 * 3^30)` from 8 native_decide shards (ErdosTernary/Records/UpTo30/Shard*.lean) and the
   tier-A `CheckerShard.checkShard_sound`. Not imported by default. Build explicitly:
   lake build ErdosTernary.Records.UpTo30 -/
import ErdosTernary.Records.UpTo30.Shard0
import ErdosTernary.Records.UpTo30.Shard1
import ErdosTernary.Records.UpTo30.Shard2
import ErdosTernary.Records.UpTo30.Shard3
import ErdosTernary.Records.UpTo30.Shard4
import ErdosTernary.Records.UpTo30.Shard5
import ErdosTernary.Records.UpTo30.Shard6
import ErdosTernary.Records.UpTo30.Shard7

namespace ErdosTernary

/-- `UpTo (2 * 3^30)` (N = 411782264189298). Tier B, from the 8 shard evaluations `CheckerShard.shard30_i`. -/
theorem upTo_30 : UpTo (2 * 3 ^ 30) :=
  CheckerShard.checkShard_sound (m := 8) (by norm_num) fun s hs =>
    match s, hs with
    | 0, _ => CheckerShard.shard30_0
    | 1, _ => CheckerShard.shard30_1
    | 2, _ => CheckerShard.shard30_2
    | 3, _ => CheckerShard.shard30_3
    | 4, _ => CheckerShard.shard30_4
    | 5, _ => CheckerShard.shard30_5
    | 6, _ => CheckerShard.shard30_6
    | 7, _ => CheckerShard.shard30_7
    | _ + 8, h => absurd h (by omega)

end ErdosTernary
