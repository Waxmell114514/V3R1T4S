/- g006-D02: the Lean-side combination for `UpTo (2 * 3^34)`, compiled in the main environment WITHOUT importing the
   shard modules (proposals/0003, condition 4). The eight shard evaluations `checkWord (2 * 3^34) s 8 = true`
   are discharged in separate cloud sessions (UpTo34W/Shard*.lean), so this theorem is conditional here.
   Tier A as stated. Not imported by default. -/
import ErdosTernary.CheckerWord

namespace ErdosTernary

/-- If the eight shards of `checkWord (2 * 3^34) · 8` evaluate to `true`, then `UpTo (2 * 3^34)`. -/
theorem upTo_34_of_shards
    (h0 : CheckerWord.checkWord (2 * 3 ^ 34) 0 8 = true) (h1 : CheckerWord.checkWord (2 * 3 ^ 34) 1 8 = true)
    (h2 : CheckerWord.checkWord (2 * 3 ^ 34) 2 8 = true) (h3 : CheckerWord.checkWord (2 * 3 ^ 34) 3 8 = true)
    (h4 : CheckerWord.checkWord (2 * 3 ^ 34) 4 8 = true) (h5 : CheckerWord.checkWord (2 * 3 ^ 34) 5 8 = true)
    (h6 : CheckerWord.checkWord (2 * 3 ^ 34) 6 8 = true) (h7 : CheckerWord.checkWord (2 * 3 ^ 34) 7 8 = true) :
    UpTo (2 * 3 ^ 34) :=
  CheckerWord.checkWord_sound (m := 8) (by norm_num) fun s hs =>
    match s, hs with
    | 0, _ => h0
    | 1, _ => h1
    | 2, _ => h2
    | 3, _ => h3
    | 4, _ => h4
    | 5, _ => h5
    | 6, _ => h6
    | 7, _ => h7
    | _ + 8, h => absurd h (by omega)

end ErdosTernary
