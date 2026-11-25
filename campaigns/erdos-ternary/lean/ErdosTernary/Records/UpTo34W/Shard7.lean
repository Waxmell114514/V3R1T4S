/- g006-D02 distributed pilot: shard 7 of 8 for `N = 2 * 3^34` with the accepted word checker (g005-C02).
   Built in a separate cloud session; see campaigns/erdos-ternary/certs/g006-D02/ and proposals/0003 (tier B'). -/
import ErdosTernary.CheckerWord

namespace ErdosTernary.CheckerWord

/-- Shard 7 of 8 for `N = 2 * 3^34` (`native_decide` on a closed `checkWord` term). -/
theorem word34_7 : checkWord (2 * 3 ^ 34) 7 8 = true := by native_decide

end ErdosTernary.CheckerWord
