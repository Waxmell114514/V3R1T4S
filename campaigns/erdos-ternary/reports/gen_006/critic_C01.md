# Critic: g006-C01 (two-word checker state, CheckerWord2)

Branch g006-C01, commit c4b90bc (parent daad90e). Read: roles/critic.md, CONSTRAINTS.md 11-13, MISSION.md, config.yaml,
reports/gen_006/plan.json, specs/node-reduction.md, certs/g006-D02/gate.md, proofs/g006-C01.md, and the diff `daad90e..c4b90bc`.
No builds were run (orchestrator's budget). So the Lean items below are as reported, not re-run by me. See "Conditions".

## Verdict: ACCEPT (the mechanism and its measurements), with conditions on counting the records

## 1. One mechanism, and scope
* One mechanism: the `2^r mod 3^76` state is held in two `< 3^38` words, multiplied by table entries split into four `3^19` pieces,
  and the table runs from level 10 to level 74. Everything in the diff serves that mechanism or its records.
* It does not touch `verify/` (the diff is empty there). It deletes nothing from `ETNative.lean`: the new namespace
  `ErdosTernary.CheckerWord2` is purely additive. It reuses `Checker.explore`, `CheckerWord.scanT` and `wordDepth`.
* `CheckerWord2.lean` has no sorry, axiom, extern, implemented_by, unsafe, partial or attributes. `mul2_gen` holds for all inputs,
  so an overflow costs speed and never soundness. That is the right design.
* Small mismatch with the plan: the plan says "table to level 75", but the implementation's table stops at level 74. A node
  that still has several members at level 75 falls back to `explore`, which is unreachable for N < 2·3^75. This does not matter.
* Scope beyond the brief: the plan listed only `Records/UpTo34*`. The diff also adds `Records/UpTo36.lean` plus 16 shard
  modules, a README edit and one import line in `ErdosTernary.lean`. The additions are additive and not imported by default,
  they use the same mechanism, and they supplied the 34→36 growth measurement. I accept them as scope creep and note it in the
  ledger. It is not a reason to reject.
* Side effect worth recording: `upTo_34` is built in one environment at tier B, so it supersedes the D02 pilot's tier B′
  result for the same N. `upTo_36` at tier B is the new highest single-environment record. Both are formal re-verifications
  of ranges below Saye's 2·3^45, so neither is a new result.

## 2. Throughput-jump rule (single_gen_throughput_jump = 3.0), applied literally
* Config benchmark `T1_N = 2·3^24`: 1.526 s against 0.952 s (mean of 3 runs each), which is **0.62x**, a regression. No trigger.
* Larger N, measured in the same harness against the parent `checkWord`:
  | N | ratio |
  |---|---|
  | 2·3^28 | 0.89x |
  | 2·3^30 | 1.36x |
  | 2·3^32 | **2.44x** |

  None of these readings exceeds 3.0, so the rule does not fire.
* Not measured, but one step away: the parent grows about 7.2x per two powers, against 4.0x here. So at 2·3^34 the
  like-for-like ratio would be about 4.4x. The workload-level comparison with the D02 pilot is also above 3.0. D02 took
  18-23 min per shard-core for the old checker at 2·3^34, while C01 took about 3.3 min per shard (1572 s / 8). That is about
  5.5-7x, but on different machines.
* Literal reading: the rule's metric is the T1 benchmark, and every measured reading is ≤ 2.44x, so there is no escalation.
* The larger ratios are explained, not anomalous. The parent's per-unit cost rises with K because of GMP `powMod` and
  `explore` in `deep`. The new state removes that cost, so the per-unit cost stays flat at 45.4-45.7 ns from K = 24 to 36.
* Recommendation: put a second benchmark point at large N (for example 2·3^32) in config, and record it to the human as a
  proposal. Otherwise the 3.0 rule will either never see gains that only appear at scale, or fire on them unexplained.

## 3. Prediction against outcome (prediction_miss_factor = 5)
| Predicted | Reported | Status |
|---|---|---|
| ≤ 60 ns/unit | 45.5 ns/unit | met |
| UpTo(2·3^34) ≤ 45 min CPU | 26.2 min CPU | met |
| growth ≤ 4.1x per two powers | 3.98-4.03x | met |

No reading misses by more than 5x.

## 4. The hypothesis statement was falsified in part
* The plan's hypothesis says the checker removes bignum `powMod` and the `explore` fallback in `deep` for **K ≤ 46**,
  implying no node needs a bignum. That is **false for K ≥ 40**. Since 2·3^39 < 2^63 < 2·3^40, from K = 40 on the following
  are GMP numbers: `N`, the representative `r` at levels ≥ 40, and the periods `2·3^j` for j ≥ 39.
* Effect: every comparison `N < r + e·p` and every addition allocates. The one sample measured 9.9x from K = 38 to 40, where
  4x was expected.
* The residue state itself is scalar as claimed.
* The implementer found and reported the falsification. That is good practice and is not a defect of the experiment.
* Ledger recording: status `accepted`, prediction `met (K ≤ 36)`, hypothesis `partially falsified`. Scope of validity:
  N < 2^63 (K ≤ 39). For K ≥ 40 the measured cost is a single sample, about 2.47x per unit. Do not record "bignum-free to
  K = 46" anywhere, and do not reuse the plan sentence as a finding.

## 5. Credibility of the 74-180 CPU-day extrapolation to 2·3^46
* **74 CPU-days** (1.41e14 units at 45.4 ns): this is not achievable with the committed code. It is the target for the next
  hypothesis, and only a lower bound for this one. It assumes flat 45 ns per unit beyond K = 36, which was measured only up
  to K = 38 on a sampled shard.
* **180 CPU-days** (about 112 ns per unit): this rests on **one run of one shard out of 2048**, at one K transition.
  * The penalty is plausibly flat for K = 40..46, because the number of bignum operations per node is constant and the
    operands stay at 64-75 bits.
  * But it is unreplicated. Shard 5 of 2048 can also differ from the average shard in its top-level share.
  * I read it as order-of-magnitude credible, roughly 120-270 CPU-days. The ±50% stated is fair, but that is not a
    measurement.
* Both numbers were measured on this machine. On the cloud sessions the rate per core is likely about 1.3-1.6x slower. For
  comparison: D02 measured 18-23 min per shard-core for checkWord at 2·3^34; extrapolating checkWord here at 34 gives about
  14 min per shard.
* The figures are marked HEURISTIC in the proof notes. That is correct.

## 6. What the next hypothesis must be (computational track, one mechanism)
* Make `r`, `N` and the periods scalar.
* Natural form: the tree's representatives are mixed-radix, `r = r0 + Σ e_k·P_k`, and no carries occur.
  * Store `r = rlo + P39·rhi`, with `P39 = 2·3^38 < 2^63` and `rlo < P39`. Levels below 39 update `rlo`. Levels ≥ 39 add
    `e·3^(j−39)` to `rhi`.
  * Split `N` once as `(N / P39, N % P39)`, and do the comparison `N < r + e·p` lexicographically on the two words.
  * Soundness is one more conjunct in `St`: `r = rlo + P39·rhi`.
* Prediction to record beforehand:
  * The sampled shard grows 4.0 ± 0.3x from K = 38 to 40, and 40 to 42.
  * 45-50 ns per unit, flat through K = 42.
  * Unchanged at T1 (it is still 0.6x the parent there).
* Falsifier: a K = 38→40 ratio above 5x.

## 7. M2 cost if section 6 works (scalar r/N/periods, about 45 ns/unit here, ×1.3-1.6 on cloud cores)
* M2 needs N > 2·3^45, not 2·3^46. The minimal target, N just above 2·3^45, costs about 2^46 = 7.0e13 units. That is
  about 37 CPU-days here, so about 890 CPU-h, or about 1150-1420 CPU-h on cloud cores. 2·3^46 costs twice that.
* Wall time on k parallel 4-core sessions. Setup is about 3.5 min per session (D02), which is negligible. Assumes many
  shards (≥ 4096, so each shard is under 30 min per core and survives a recycled container) and that sharding balances
  as in D02.

  | Target | k = 8 | k = 16 | k = 32 | k = 64 |
  |---|---|---|---|---|
  | just above 2·3^45 | ≈ 36-44 h | ≈ 18-22 h | ≈ 9-11 h | ≈ 4.5-5.5 h |
  | 2·3^46 | ≈ 72-89 h | ≈ 36-44 h | ≈ 18-22 h | ≈ 9-11 h |

* At the current, unfixed code (×2.47 for K ≥ 40), roughly double the 2·3^46 row (for example ≈ 45-55 h on k = 32).
* `max_wall_hours = 24` forces k ≥ 16-20 for the minimal M2 target, or k ≥ 32-40 for 2·3^46.
* Distributed evaluation gives tier **B′**. That rule is proposals/0003 and is still awaiting the human. A single 4-core
  environment needs about 9-11 days for the minimal target, so M2 at strict tier B is impractical under the budget. That
  confirmation is therefore on the critical path for M2. The three-skeptic panel is also required.

## Conditions (CONSTRAINTS 11; critic.md requires rerunning the Lean build and audit, which I could not do here)
1. Before `upTo_34` and `upTo_36` are counted as achievements (tier B), someone must:
   * delete the ETNative outputs (`.so`, `.olean`, `ir`), rebuild with `lake build ETNative:shared` (not plain
     `lake build ETNative`, which leaves a stale `.so`), then run `lake build` on the record modules;
   * rerun `verify/lean_audit.py` for `checkWord2_sound` (expect tier A), `upTo_34` and `upTo_36` (expect tier B, with
     `--expect`);
   * have the independent `lean_auditor` check `checkWord2_sound`, `mul2_gen` and `St`.
2. Until all three pass, the records are "reported", not achievements. The README's tier-B trust sentence must name the
   ETNative-compiled `checkWord2`.

## Lesson (one sentence for the ledger)
Two-word residues made the per-unit cost flat at 45 ns up to K = 36. But in Lean, every `Nat` ≥ 2^63 is a GMP object,
so the whole hot path has to be checked against that limit: the residues, the representative `r`, `N` and the periods.
Here r, N and the periods crossed it at K = 40. A benchmark at T1 = 2·3^24 alone cannot show this gain or this loss.
