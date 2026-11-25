# Critic: g005-C02 (word-size checker state)

Branch g005-C02, commit 70b8c58 (parent b0500ba). I reviewed `git diff b0500ba 70b8c58` (14 files) and
proofs/g005-C02.md, along with roles/critic.md, CONSTRAINTS 11-13, config.yaml, plan.json and specs/node-reduction.md.
I did not run a build because an independent auditor is rebuilding. The Lean part of rule 11 rests on that rebuild
(see "Conditions").

## Verdict: ESCALATE

The rule forces this verdict. Per-node throughput rose 8.0x at the benchmark T1_N = 2·3^24 (7.874 s to 0.987 s,
3 repeats). It rose 8.4x at 2·3^22 and about 5.0x at 2·3^30 (687 s to 138.6 s, compared across sessions). Every one
of these is above `single_gen_throughput_jump = 3.0`, and roles/critic.md says such jumps are "一律 escalate". I
am applying that rule literally. Nothing I found is suspicious. If the escalation review and the auditor's rebuild
pass, these findings support accepting the change.

## Findings
1. **One mechanism: yes.** The change keeps the hot-loop residue below 2^63 so that the runtime keeps it as a scalar
   `Nat`. The once-per-tail `deep` re-seed belongs to the same mechanism, because the hypothesis itself says
   "re-seed with one powMod". The plan said "mod 3^20, re-seed at level 20". The implementation uses mod 3^38 with
   base-3^19 halves, re-seeded at level 38. That is a parameter choice inside the same idea, not a second mechanism.
   * The existing `CheckerShard`/`Checker` definitions are unchanged. The new code is a separate namespace in
     ETNative.lean.
   * The new code has no `@[extern]`, `implemented_by` or `csimp`.
   * verify/ is untouched (rule 5).
   * `upTo_32` uses the frozen `UpTo` (rule 12).
   * `native_decide` appears only on the closed terms `checkWord (2*3^32) s 8 = true`, and the record is marked
     tier B (rule 13).
   * The scope adds two small files outside plan.json's `touched`: the ErdosTernary.lean import and a README line.
     Both are required and harmless.
2. **`mulMod` is correct.** Write v = vh·B + vl and g = gh·B + gl with B = 3^19, so B² = M. The vh·gh·B² term
   vanishes mod M. The remainder is ((vh·gl + vl·gh) mod B)·B + vl·gl, which is less than 2M whenever gl < B. So a
   single conditional subtraction is exact, and `mulMod_gen`/`mulMod_eq` need only `gl < B`, as stated. Correctness
   does not depend on the bounds; only speed does. The auditor still has to confirm `checkWord_sound` at tier A.
3. **Prediction vs result: no miss.** The prediction was 3-5x per node and the result is 8.4x/8.0x at small N. That
   beats the prediction by about 1.7x, well under the miss factor of 5. At larger N the result falls to 7.3x, 5.6x,
   about 5.0x, and about 3.3x at 2·3^32. The 3.3x is extrapolated: checkShard was not run at 2·3^32, and the report
   says so.
   * The falloff is explained by a measurement: the GMP `powMod` in `deep` is 40% of the time at K=28 and 61% at
     K=30.
   * The UpTo(2·3^32) ≤ 1.5 h part was met: about 1008-1021 s CPU, about 8.5 min wall, with a clean rebuild from
     source.
   * Wording nit: the "Outcome" line names 5.6x at K=28 as the low end, but the 3.3x row should be named as well.
4. **The temporary unsound `deep := true` variant is acceptable as an ablation, but only because of how it was
   handled.** It was disclosed, used only to split the timing, never committed (the diff has no such line), and
   followed by a clean rebuild of ETNative and the UpTo32 oleans before the record numbers.
   * The danger is real. The kernel does not see the .so (README "What tier B trusts"), so a stale unsound .so
     would pass native_decide silently. Disclosure is good practice, but disclosure alone does not make the
     practice safe.
   * **Recommended rule:** do diagnostic variants of executable checker code under a different name (for example
     `checkWordDiag`) or in a scratch worktree. Never edit in place a definition that a record uses. Any record
     build after any in-place edit must first delete ETNative build outputs, and the report must log that it did.
     Timing-only numbers from such variants must be labeled as diagnostic.
5. **The scaling analysis (75 CPU-days to 2·3^46 with a two-word state) is credible as an order-of-magnitude
   HEURISTIC, and probably at the optimistic end.**
   * The no-deep variant ran 53.4 s at K=30. With 2^31+1 ≈ 2.15e9 units, that is about 25 ns/unit, which is
     already at the C probe's 18-21 ns.
   * The report assumes a two-word node costs 2x that, about 50 ns/unit. That assumption is not measured: it needs
     four partial products instead of three, and the state is twice as wide. Times 1.41e14 units, it gives about
     80 CPU-days, consistent with the stated 75.
   * specs/node-reduction.md §4 gives 29-65 CPU-days for C at 18-40 ns, without a real fallback. Landing at about
     1.2-2.6x of the C figure is plausible for compiled Lean scalar code.
   * Caveats:
     * The no-deep timing is a lower bound, because it skipped the deep tails' work as well as the powMod.
     * Growth of 3.95x per two powers of 3 matches the exact unit ratio of about 4.
     * Nothing has been measured at K ≥ 38, where multi-member nodes reach the table's end.
   * Treat the 75 CPU-days figure as ±2x. It meets node-reduction.md's ≤ 100 ns target, but M2 (about 19 days on
     4 cores) still exceeds the 24 h `max_wall_hours` budget by far.

## Conditions for acceptance after escalation
* The auditor rebuilds ETNative from source (deleting the build outputs first), and `lake build` plus
  `verify/lean_audit.py` pass: `checkWord_sound` at tier A, `upTo_32` at tier B with exactly the 8 `word32_i`
  native_decide axioms.
* The k ≥ 26 timing rows are single runs on a machine with load 2-3. That is acceptable for an escalation review,
  but the benchmark number at T1_N should be re-measured once on a quiet machine.

## Lesson (ledger)
Keeping the residue in scalar machine words gave 8x per node at small N. The gain decays with N because the
remaining GMP re-seed (`deep`) dominates. Precision must cover the whole tree depth (2 words up to level 75), or
bignum work comes back exactly where the tree grows.

## Next hypothesis
Two-word scalar state (2^r mod 3^76 as two base-3^38 words, four 19-trit partial products), with the table to level
75 and no `deep`/`explore` for K ≤ 46. Prediction: at most 2x the no-deep node cost (≤ 60 ns/unit), so
UpTo(2·3^34) B in ≤ 45 min CPU and growth of ≤ 4.1x per two powers through K = 34. A UInt64 version is an optional
second step. Keep it separate so that one mechanism is measured per experiment.
