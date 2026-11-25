import ErdosTernary.Basic
import ErdosTernary.Checker
import ErdosTernary.Counting
import ErdosTernary.CountingSharp
import ErdosTernary.CountingLambda
import ErdosTernary.E4
import ErdosTernary.E3Count
import ErdosTernary.CheckerShard
import ErdosTernary.CheckerWord
import ErdosTernary.CheckerKernel
import ErdosTernary.CheckerKernelUpTo16
-- Record modules (heavy native_decide / kernel evaluations) are NOT imported here; they live in
-- ErdosTernary/Records/ and are built and audited explicitly, e.g. `lake build ErdosTernary.Records.UpTo28`.
