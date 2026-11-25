/- g005-C02 record: `UpTo (2 * 3^32)` from 8 native_decide shards (ErdosTernary/Records/UpTo32/Shard*.lean) and the
   tier-A `CheckerWord.checkWord_sound` (word-size state). Not imported by default. Build explicitly:
   lake build ErdosTernary.Records.UpTo32 -/
import ErdosTernary.Records.UpTo32.Shard0
import ErdosTernary.Records.UpTo32.Shard1
import ErdosTernary.Records.UpTo32.Shard2
import ErdosTernary.Records.UpTo32.Shard3
import ErdosTernary.Records.UpTo32.Shard4
import ErdosTernary.Records.UpTo32.Shard5
import ErdosTernary.Records.UpTo32.Shard6
import ErdosTernary.Records.UpTo32.Shard7

namespace ErdosTernary

/-- `UpTo (2 * 3^32)` (N = 3706040377703682). Tier B, from the 8 shard evaluations `CheckerWord.word32_i`. -/
theorem upTo_32 : UpTo (2 * 3 ^ 32) :=
  CheckerWord.checkWord_sound (m := 8) (by norm_num) fun s hs =>
    match s, hs with
    | 0, _ => CheckerWord.word32_0
    | 1, _ => CheckerWord.word32_1
    | 2, _ => CheckerWord.word32_2
    | 3, _ => CheckerWord.word32_3
    | 4, _ => CheckerWord.word32_4
    | 5, _ => CheckerWord.word32_5
    | 6, _ => CheckerWord.word32_6
    | 7, _ => CheckerWord.word32_7
    | _ + 8, h => absurd h (by omega)

end ErdosTernary
