/- g006-C01 record: `UpTo (2 * 3^34)` from 8 native_decide shards (ErdosTernary/Records/UpTo34/Shard*.lean) and the
   tier-A `CheckerWord2.checkWord2_sound` (two-word state mod 3^76). Not imported by default. Build explicitly:
   lake build ErdosTernary.Records.UpTo34 -/
import ErdosTernary.Records.UpTo34.Shard0
import ErdosTernary.Records.UpTo34.Shard1
import ErdosTernary.Records.UpTo34.Shard2
import ErdosTernary.Records.UpTo34.Shard3
import ErdosTernary.Records.UpTo34.Shard4
import ErdosTernary.Records.UpTo34.Shard5
import ErdosTernary.Records.UpTo34.Shard6
import ErdosTernary.Records.UpTo34.Shard7

namespace ErdosTernary

/-- `UpTo (2 * 3^34)` (N = 33354363399333138). Tier B, from the 8 shard evaluations `CheckerWord2.word2_34_i`. -/
theorem upTo_34 : UpTo (2 * 3 ^ 34) :=
  CheckerWord2.checkWord2_sound (m := 8) (by norm_num) fun s hs =>
    match s, hs with
    | 0, _ => CheckerWord2.word2_34_0
    | 1, _ => CheckerWord2.word2_34_1
    | 2, _ => CheckerWord2.word2_34_2
    | 3, _ => CheckerWord2.word2_34_3
    | 4, _ => CheckerWord2.word2_34_4
    | 5, _ => CheckerWord2.word2_34_5
    | 6, _ => CheckerWord2.word2_34_6
    | 7, _ => CheckerWord2.word2_34_7
    | _ + 8, h => absurd h (by omega)

end ErdosTernary
