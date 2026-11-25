/- g006-C01 record: `UpTo (2 * 3^36)` from 16 native_decide shards (ErdosTernary/Records/UpTo36/Shard*.lean) and the
   tier-A `CheckerWord2.checkWord2_sound` (two-word state mod 3^76). Not imported by default. Build explicitly:
   lake build ErdosTernary.Records.UpTo36 -/
import ErdosTernary.Records.UpTo36.Shard0
import ErdosTernary.Records.UpTo36.Shard1
import ErdosTernary.Records.UpTo36.Shard2
import ErdosTernary.Records.UpTo36.Shard3
import ErdosTernary.Records.UpTo36.Shard4
import ErdosTernary.Records.UpTo36.Shard5
import ErdosTernary.Records.UpTo36.Shard6
import ErdosTernary.Records.UpTo36.Shard7
import ErdosTernary.Records.UpTo36.Shard8
import ErdosTernary.Records.UpTo36.Shard9
import ErdosTernary.Records.UpTo36.Shard10
import ErdosTernary.Records.UpTo36.Shard11
import ErdosTernary.Records.UpTo36.Shard12
import ErdosTernary.Records.UpTo36.Shard13
import ErdosTernary.Records.UpTo36.Shard14
import ErdosTernary.Records.UpTo36.Shard15

namespace ErdosTernary

/-- `UpTo (2 * 3^36)` (N = 300189270593998242). Tier B, from the 16 shard evaluations `CheckerWord2.word2_36_i`. -/
theorem upTo_36 : UpTo (2 * 3 ^ 36) :=
  CheckerWord2.checkWord2_sound (m := 16) (by norm_num) fun s hs =>
    match s, hs with
    | 0, _ => CheckerWord2.word2_36_0
    | 1, _ => CheckerWord2.word2_36_1
    | 2, _ => CheckerWord2.word2_36_2
    | 3, _ => CheckerWord2.word2_36_3
    | 4, _ => CheckerWord2.word2_36_4
    | 5, _ => CheckerWord2.word2_36_5
    | 6, _ => CheckerWord2.word2_36_6
    | 7, _ => CheckerWord2.word2_36_7
    | 8, _ => CheckerWord2.word2_36_8
    | 9, _ => CheckerWord2.word2_36_9
    | 10, _ => CheckerWord2.word2_36_10
    | 11, _ => CheckerWord2.word2_36_11
    | 12, _ => CheckerWord2.word2_36_12
    | 13, _ => CheckerWord2.word2_36_13
    | 14, _ => CheckerWord2.word2_36_14
    | 15, _ => CheckerWord2.word2_36_15
    | _ + 16, h => absurd h (by omega)

end ErdosTernary
