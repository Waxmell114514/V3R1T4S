# Critic: g003-L01 (sharded checker with incremental state)

Branch g003-L01-shard, commit 9ae2acb (parent 3188e92), worktree .claude/worktrees/agent-a7e2da9226ed27539.

## Verdict: ESCALATE

This is not a reject. The theorems check out. Two things trigger the escalation. First, config
`escalate.single_gen_throughput_jump: 3.0` applies literally: the reported per-node speedup is 3.06 to 3.33x,
which is above 3.0, and the rule says "一律 escalate". Second, the speedup comes from mechanisms the hypothesis
did not name. My recommendation to the human: once the escalation review re-measures the speedup, accept
`checkShard_sound` (tier A) and `upTo_26` (tier B). Accept `upTo_28` (tier B) only after it moves out of the
default build (see "Build time" below).

## Checks
* **Scope.** `git diff --stat 3188e92 9ae2acb` shows lean/ErdosTernary/CheckerShard.lean (new, 348 lines) and
  lean/ErdosTernary.lean (+1 import line). The import line is needed. The file is in plan `touched`. The
  extras beyond the brief are: `upTo_28` with 8 shard theorems (the plan predicted only 2·3^26), and the
  helpers `Lvl`/`table`/`scan`/`fast`/`top`. There are no unrelated edits. There is no proofs/g003-L01.md
  note. Earlier generations had one, and rule 3 labelling is easier to audit with it.
* **verify/ untouched.** The diff touches no verify/ file. `python3 tools/check_lock.py` prints `LOCK: OK`
  in both the main checkout and the worktree.
* **Forbidden tokens.** The diff adds no sorry/admit/axiom/unsafe/implemented_by/extern. The audit source
  scan only raises the expected WARN for `native_decide`.
* **Rule 12.** `--expect UpTo:<N>` elaborates for both record theorems, so they use the frozen `UpTo` directly.
* **Rule 13.** `native_decide` appears only in the 12 closed `checkShard <lit> <lit> <lit> = true` goals.
  `checkShard_sound` is tier A.
* **Audit (one run per theorem, cached oleans).** I did not rebuild. `lake build --no-build
  ErdosTernary.CheckerShard` reported "All targets up-to-date", so the audit's build step only replayed the
  cached build.
  * `ErdosTernary.CheckerShard.checkShard_sound`: `LEAN_AUDIT: PASS tier=A` (propext, Classical.choice, Quot.sound).
  * `ErdosTernary.upTo_26 --expect 'UpTo:2 * 3 ^ 26'`: `LEAN_AUDIT: PASS tier=B` (4 shard26 native axioms).
  * `ErdosTernary.upTo_28 --expect 'UpTo:2 * 3 ^ 28'`: `LEAN_AUDIT: PASS tier=B` (8 shard28 native axioms).
* **Soundness design.** Each node is assigned to shard `r / 2 % m` at level 10. Nodes outside shard `s`
  return `true`, so completeness rests on `∀ s < m` in `checkShard_sound`. The kernel checks that argument,
  and the `match` in `upTo_26`/`upTo_28` covers every `s < m`. A faster checker therefore cannot silently
  truncate coverage (rule 2). Only the compiler/runtime trust of tier B remains.
* **Numbers (rule 1).** I did not re-measure the 81 s wall time or the 3.06 to 3.33x speedup. Both come from
  the implementer. A fresh single-file run started by another agent was still in progress when I wrote this.
  The escalation review should take its timing from that run.

## Prediction vs result
* "UpTo(2·3^26) tier B": met.
* "≤ 30 min with 4 shards": met. 81 s is about 22x under the bound. This is not a miss in the sense of
  `prediction_miss_factor` 5, because the prediction was an upper bound. It does show the cost model was loose.
* "per-node speedup ≥ 3x": met by a small margin (3.06 to 3.33x).

## One mechanism per hypothesis
roles/planner.md says each hypothesis changes only one mechanism. The plan had already bundled two: sharding
and incremental state. The implementation added three more speed mechanisms: children tested before
recursing, a single-member `scan` loop, and a per-level constant table. The implementer reports that
incremental state alone gave no speedup. So the speed part of the hypothesis is refuted as stated, and the
predicted metric was reached through mechanisms nobody hypothesized.

The theorems are valid whatever caused the speedup, and the soundness proof covers all the mechanisms
together. That is not grounds to reject the Lean results. It is grounds to refuse credit for the attribution.
The ledger should record that incremental state alone does not help, and that the gain came from the other
three mechanisms jointly, without an ablation. Before anyone builds on them, a later experiment should run
the ablation, one mechanism per hypothesis.

## Throughput trigger
I read the rule literally. "Throughput" is the checker's nodes per second. A per-node speedup is exactly
that quantity, and 3.06 to 3.33 is greater than 3.0, so the rule fires. The rule has no exemption for Lean
checkers versus C engines, and the margin is small, so I escalate. The rule exists to guard against hidden
truncation. That risk is low here, because `checkShard_sound` is kernel-checked. The escalation review can
therefore be a quick re-timing from the fresh build plus a node-count check, not a full re-derivation.

## Build time and upTo_28
A full `lake build` now takes about 15 min. `ErdosTernary.lean` imports CheckerShard, which is in the default
target. Every edit to Checker.lean (or to anything else upstream) re-runs all 12 native_decide evaluations,
and so does every fresh build by an auditor or skeptic. Most of that time is the 2·3^28 shards. At this point
the cost is tolerable. It will not stay tolerable: the work grows about 2x per power of 3, which puts
2·3^45 far beyond any default build.

Recommendation: keep `checkShard`, its soundness, and possibly the 81 s `upTo_26` in the default build. Move
`upTo_28` and every larger record into a separate optional module, for example
`ErdosTernary/Records/UpTo28.lean`. Do not import it from `ErdosTernary.lean`. Build it only through
`lean_audit.py ErdosTernary.Records.UpTo28 ...`. Better still, give each record module its own shard files,
so the shards build in parallel and cache separately.

## Lesson (ledger)
Sharding with a tier-A `∀ s < m` soundness theorem is the right structure for M2. The 3x per-node gain came
from testing children before recursing, the single-member scan, and the level table. Incremental `2^r mod 3^L`
alone gave nothing. Ablate before attributing, and keep record evaluations out of the default build.
