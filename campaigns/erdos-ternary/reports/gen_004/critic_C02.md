# Critic: g004-C02 (precompiled checker)

Branch g004-C02, commit 3e947f2 (parent 770152b). Reviewed the diff (`git diff 770152b 3e947f2`), proofs/g004-C02.md,
proofs/g004-A01.md, plan.json, CONSTRAINTS 5/11-13, MISSION tier definitions, config.yaml. I did not run a build:
an independent auditor is rebuilding, and rule 11's Lean check rests on that rebuild (see "Conditions").

## Verdict: ESCALATE

The rule forces it: per-node throughput rose about 4x (7.36 -> 1.79 s at 2*3^22, 29.9 -> 7.88 s at 2*3^24; UpTo28 module
136 s against the README's ~8-11 min, i.e. 3.5-4.9x). That is above `single_gen_throughput_jump = 3.0`, and
roles/critic.md says such jumps are "一律 escalate". I am applying the rule literally. The size of the jump is not
itself suspicious, and my findings below would support accepting the change once the escalation review clears it.

## Findings

1. **One mechanism: yes.** The only change that affects meaning is where the executable definitions live: a
   Mathlib-free lib `ETNative` with `precompileModules = true`. The diff of ETNative.lean against the removed blocks
   is verbatim except for `ℕ` -> `Nat`. Names, fuel, `shardDepth = 10` and `modExp = 40` are unchanged. ETNative.lean
   has no `@[extern]`, `implemented_by`, `csimp` or `opaque`. The implementer's `pp.all` comparison found two
   differences: `^` now goes through core `instPowNat` instead of Mathlib's `Monoid.npow` (definitionally equal), and
   `top` reuses the `explore.match_1` matcher. Neither changes meaning, and the soundness proofs re-check unchanged
   (the rebuild confirms this).
2. **Scope: slightly wider than the plan, but required by the mechanism.** plan.json listed `lakefile.toml` and
   `Records/`. The change also edits the audited Checker.lean and CheckerShard.lean, though only to delete the moved
   definitions. No proof text changed in either file. The implementer explains why this is needed: precompiling a
   module requires its whole import closure to be precompiled, which would mean compiling Mathlib. The 9 new Records
   files (UpTo30 plus 8 shard modules) are the record that the prediction itself named. verify/ is untouched
   (rule 5). No redefinition collides with a frozen name (rule 12): Statement.lean defines only `Statement` and
   `UpTo`, and `upTo_30` uses the frozen `UpTo`.
3. **Prediction miss, explained.** The prediction was >= 10x and the measured gain is ~4x, a factor of 2.5, which is
   under the `prediction_miss_factor` of 5. The explanation is plausible and consistent with A01, though labelled
   HEURISTIC: state lives mod 3^40 > 2^63, so every `v * g % M` is GMP work that costs the same in the interpreter and
   in native code. Only dispatch overhead goes away. The interpreter baseline cross-checks: C02's 7.36 s matches
   A01's `ref_g003` at 2*3^22 (7.350 ± 0.239 s). The second half of the prediction, UpTo(2*3^30) within 1 hour, is met
   at 687 s sequential. The 8 shard times add to 672 s, plus 1 s to combine; the remaining ~14 s is presumably Lake
   overhead.
4. **Rule 13: complies.** Each `native_decide` proves a closed numeral goal, `checkShard (2 * 3 ^ 30) s 8 = true` with
   s = 0..7. The general step is `checkShard_sound`, which is tier A. `upTo_30` combines the 8 shards with an `omega`
   case split.
5. **The trust base changed, and this is the real issue for the escalation.** MISSION's tier B is defined by
   axioms ("另含 Lean.ofReduceBool / Lean.trustCompiler，信任 Lean 编译器"). The axiom set does not change, so the label
   B is still literally correct. What is trusted has grown, though:
   * Before: Lean's compiler to IR, plus the IR interpreter.
   * Now, in addition: the Lean -> C code generator, the bundled C compiler and linker (clang), the Lean runtime/GMP
     linked into `libErdosTernary_ETNative.so`, and Lake's plugin loading. On that last point, the result is only as
     good as the claim that the `.so` loaded through `--load-dynlib` / the setup plugin list was built from the audited
     ETNative.lean and is not stale. Lake's trace is the only thing that ties the two together.
   * `verify/lean_audit.py` scans `.lean` sources and the axioms of the final theorem. It does not look at
     `lakefile.toml`, at `precompileModules`, at plugin or `moreLeanArgs` settings, or at any `.so`. Arbitrary native
     code loaded into the elaborator could therefore change a `native_decide` outcome without the audit seeing it.
   MISSION requires that "B 级成果必须在报告中写明所信任的内容". proofs/g004-C02.md and Records/README.md currently
   say only "precompiled checker". Both should list the bullets above explicitly. I recommend that the human/panel
   decide whether MISSION's tier-B sentence should name the C toolchain and the plugin, and that the auditor (a) diff
   lakefile.toml by hand and (b) rebuild from a clean `.lake` (`lake clean` or a fresh clone) so that no stale `.so`
   can be loaded. Until then, results produced through precompiled modules should be described as "tier B (trusts
   Lean compiler + C toolchain + native plugin)".

## Conditions for clearing the escalation
* The independent auditor's clean rebuild passes, and `lean_audit.py` passes, for `upTo_30` and for the re-checked
  `checkShard_sound` and `upTo_28`. Per rule 11, until then the change is not counted as a result.
* The trust statement above is added to proofs/g004-C02.md and the README row. The README cost column should give
  687 s instead of "see proofs", and the UpTo28 row should give its new 136 s.
* Optional cross-check that would make the escalation review straightforward: one shard at 2*3^24 evaluated with the
  interpreter (old build) and with native code, giving the same `true` and the timings the report states.

## Lesson (ledger)
Precompiling the checker removes only interpretive overhead (~4x). The remaining cost is bignum arithmetic mod 3^40,
and the gain comes from widening the trust base to the C toolchain and a native plugin, which the audit script does
not see.

## Next speed hypothesis
Remove GMP from the hot loop, as the implementer suggests: keep `v` in machine words. 3^40 > 2^63, so the options are
residues mod 3^20 < 2^32, with one `powMod` re-seed at level 20, or two-limb `UInt64` arithmetic. Bundle with it the
scan-tail improvement (A01 #2: test a 3^m block of trits at a time), because (b) is where the time goes. Prediction to
record: a further 3-5x per node. The scaling estimate in proofs/g004-C02.md (2.25x per power of 3, 2*3^46 ~ 9
CPU-years) shows that constant factors cannot reach M2 (N > 2·3^45). The hypothesis after this one has to be
algorithmic: reduce the number of nodes, not the cost per node. Its machine-word proofs (UInt64/BitVec lemmas) need
an auditor's review.
