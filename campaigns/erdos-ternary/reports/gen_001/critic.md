# Critic report, generation 1

Scope: g001-e01 (a0142b4) and g001-e02 (88b6e71), both based on de763cf. Parent g000-e00 = 1.47e5 events/s/core.
Rules applied: CONSTRAINTS.md 1, 2, 5, 9, 11-13; config.yaml escalate.single_gen_throughput_jump = 3.0 and
escalate.prediction_miss_factor = 5. This generation does not claim a result: no Lean theorem, no new verified N.
Under rules 11-13, both engines are intermediate tools only.

## Checks run by the critic (real output, this container, 4 cores, nice 15)

| check | e01 | e02 |
|---|---|---|
| `git diff --stat de763cf <c> -- campaigns/erdos-ternary` | search/run.py, search/c1/tree_c1.c | search/run.py, search/c2/engine.c, search/c2/core.inc |
| verify/ touched | no | no |
| files outside campaigns/ touched | none | none |
| `verify/test_T0.py --skip-brute` (in worktree) | T0: PASS (24/24 ok) | T0: PASS (24/24 ok) |
| N=2*3^24, 0/1 vs `verify/tree_ref.py 2*3^24 0 1` (depth_counts, exceptions, events, leaf_digest, d0) | identical | identical |
| single-core wall at N=2*3^24 (run.py wall_s) | 11.646 s, 1.152e7 events/s | 2.033 s, 6.602e7 events/s |
| reported T1 single core | 1.225e7 (std 1e5) | 6.8471e7 (std 1.3e6) |

Reference at N=2*3^24: events 134215298, leaf_digest 70be1966...7c7a9f67, exceptions [0,2,8], 67 levels,
tree_ref 23.883 s (5.62e6 events/s). My single runs fall 6% (e01) and 4% (e02) below the reported means. That is
consistent with one niced run on a shared machine. I ran each once, so I do not count it as a discrepancy.

## g001-e01: C port, generic base-3^40 mulmod

**Verdict: ESCALATE** (required by the throughput-jump rule; on substance I would accept it as a correct intermediate tool).

Reasons:
- The throughput jump is 1.225e7 / 1.47e5 = 83x, above the 3.0x threshold. The rule says to escalate in every such case.
- The prediction miss is 1.5e7 / 1.225e7 = 1.22x, well inside the factor of 5.
- The diff matches the hypothesis. It is a direct C port of the g0 DFS, with a BFS prefix to d0 and a DFS below it.
  Children come from a generic truncated schoolbook mulmod in base 3^40. The 128/64 reduction uses a precomputed
  inverse, and a self-test runs at start-up. Nothing else changed.
- Coverage: I found no hidden truncation. A candidate deeper than 240 trits exits with code 3. N >= 2^100 is
  rejected. Overflow of P_k mod 2^128 is handled with an exact `P_k > N` flag, so the `r > N` test stays exact. The E
  test uses an exact bitlength of 3^k. run.py fails loudly on any non-zero exit.
- The hash follows CERT.md literally (r mod 2^128). See the verifier section: at levels >= 81 it therefore disagrees
  with tree_ref.c and agrees with tree_py.

Lesson: a straight C port with generic multi-limb mulmod gives about 80x over Python (1.2e7 events/s/core); the
remaining cost is the full mulmod per child.

## g001-e02: short products from 2^(P_k) = 1 + 3^k e_k, dying child chosen from trit k

**Verdict: ESCALATE** (required by the throughput-jump rule; on substance I recommend making it the population's best intermediate engine once the human review below is done).

Reasons:
- The throughput jump is 6.8471e7 / 1.47e5 = 466x, above the 3.0x threshold, so escalation is required. The jump
  over the sibling e01 is 5.6x on reported numbers and 5.7x in my runs.
- The prediction miss is 6.8471e7 / 4.5e7 = 1.52x faster than predicted, inside the factor of 5. The cause is the
  chain loop (next bullet), which the prediction did not include.
- The diff matches the hypothesis, plus two additions:
  1. The dying child is read from trit k. Child j has trit k equal to t + j*c_k*(2^r mod 3) mod 3. This is correct,
     because 2^r(1+3^k e)^j = 2^r + j*3^k*e*2^r mod 3^(k+1), and adding a multiple of 3^k does not carry into the
     lower trits. c_k != 0 and the j=2 relation are both checked at start-up for every branching level.
  2. Children j=1 and j=2 are computed as v + v*(g^j - 1). The limbs below k/19 are zero, giving a triangular
     product. The accumulator bound holds: at most 8 products below 1.35e18, plus v and a carry, stays under 2^64.
  3. Extra, not in plan.json: once P_k > N only child j=0 can be <= N, so each subtree becomes a chain of trit reads
     on a fixed v. This follows directly from the same tree rules, and it is the main reason the result beat the
     prediction.
  4. Extra, not in plan.json: an opt-in `--ref-sat` / `ERDOS_C2_REFSAT=1` mode reproduces tree_ref.c's saturated
     hash. It is off by default and documented, so it hides nothing. It does put a second hash convention into
     search/, and it should be removed once the reference is fixed.
- Coverage: I found no hidden truncation. Chains deeper than the fast precision fall back to an exact 266-trit
  recomputation. Every limit (depth 265, branching beyond precision, stop level, MAXEXC = 4096 exceptions, oom,
  N >= 2^120) exits with code 3. run.py exits non-zero on failure or incomplete output. The skipped value computation
  for j>0 terminal exception children is safe because those nodes are never expanded.
- Do I recommend it as the best intermediate engine? Yes. The math in the new mechanism is checked numerically at
  runtime. T0 passes. It matches tree_ref exactly at 2*3^24. On the deep-level tests below its counts, events and
  exceptions agree with both references, and its default digest agrees with tree_py. It is 5.7x faster than e01.
  Before any long run it needs:
  1. the human escalation sign-off;
  2. the reference fix below; without it, check_cert.py will fail honest deep shards;
  3. an independent T1 re-run under quota.
  Until Lean, it remains a tool, not a result (rule 11).

Lesson: using 2^(P_k) = 1 + 3^k e_k to choose the dying child from one trit, plus short products, and running the
P_k > N subtrees as trit-read chains gives about 6.8e7 events/s/core, 5.6x over the generic C port.

## Verifier issue: tree_ref.c saturates P_k at 2^125

**The claim is real, and I confirmed it by testing.**

What the code does:
- `verify/tree_ref.c` sets `Pk[k] = min(3*Pk[k-1], 2^125)`.
- 2*3^78 is about 2^124.6 and 2*3^79 is about 2^126.2, so P_k is exact for k <= 79 and saturated for k >= 80.
- `verify/tree_py.py` and CERT.md use the true r, which `h` reduces mod 2^128.

Which levels are affected:
- Only N-type events (code 1) at levels k+1 >= 81. These are the children j=1,2 of alive non-terminal nodes at levels
  k >= 80.
- Those r are recorded as r + j*2^125 instead of r + j*P_k mod 2^128.

Coverage soundness is **not** affected:
- The saturated value is still > N, because N < 2^120 is enforced. So the r > N classification is unchanged.
- `r + Pk > N` in the E test is unchanged.
- G_k = 2^(P_k) is computed by exact cubing, independent of Pk[].
- So depth_counts, events and exceptions are correct. Only leaf_digest differs.

Test (N = 2*3^30 = 411782264189298, m = 4096, d0 = 18):
- I swept all 4096 shards with the e02 binary: 8,590,066,004 events in 77 s on 4 processes.
- Shards with alive nodes at level >= 80 are 2721 (81 levels), 1115 (82) and 754 (98).
- Shard 1206 (79 levels) is the control.

| shard | levels | e01 vs tree_ref | e02 vs tree_ref | e02 --ref-sat vs tree_ref | tree_py vs tree_ref | tree_py vs e01 / e02 |
|---|---|---|---|---|---|---|
| 754 | 98 | counts, exceptions, events equal; digest differs | same | all equal | digest differs | identical |
| 1115 | 82 | same | same | all equal | digest differs | identical |
| 2721 | 81 | same | same | all equal | (not run) | (not run) |
| 1206 | 79 | all equal | all equal | all equal | n/a | n/a |

So the two frozen references disagree with each other once a shard has an alive node at level >= 80. The fraction of
such shards grows quickly with N: alive nodes at level 80 are expected to be roughly 2^(K+1)*(2/3)^(80-K) for
N = 2*3^K. That is about 5 nodes in the whole tree at K = 30, but a large fraction of shards at K = 45. As frozen,
`check_cert.py` (which rechecks only against tree_ref) will FAIL honest CERT.md-literal certificates at production
scale. The only way to pass would be to match the saturated convention, which is what `--ref-sat` does. This is a
false-negative risk, not a soundness hole. T0 does not catch it, because every T0 N stays below level 80 (2*3^24
reaches level 67).

**Recommended fix.** This is a human-approved re-freeze, because rule 5 forbids any role from editing verify/
outside phase 0. I filed nothing and changed nothing.
1. In tree_ref.c, keep P_k exact mod 2^128, by plain wrapping multiplication or a 3-limb exact value. Add a separate
   exact `P_k > N` flag for classification, as both engines already do. Do not amend CERT.md to define saturation:
   tree_py, CERT.md and both engines already agree on the literal formula.
2. Add a T0 case above level 80. For example, N = 2*3^30, shards 754/4096 and 1115/4096: tree_py == tree_ref ==
   engine. tree_py ran them in a few minutes here.
3. After the re-freeze, delete `--ref-sat` from search/c2.
4. Record the re-freeze in reports/ the same way as refreeze_v0.2.md.

## Escalation summary
- Throughput jump (> 3.0x) triggered for both experiments: e01 83x, e02 466x. Both need human review before their
  numbers enter the ledger as accepted.
- Prediction miss (> 5x) did not trigger: e01 1.22x, e02 1.52x.
- Verifier inconsistency: tree_ref.c and CERT.md / tree_py disagree on the digest above level 80. This needs a human
  re-freeze before any long run or check_cert at N >= about 2*3^30.

Critic scratch outputs (not committed): /tmp/claude-0/-home-user-V3R1T4S/574261f0-a436-50ae-bd9e-c4ad05e010b7/scratchpad/
