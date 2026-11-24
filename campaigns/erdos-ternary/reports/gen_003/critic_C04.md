# Critic: g003-C04 (exploratory, track C)

Branch g003-C04, commit 5a7b0f7 (parent 3188e92). Reviewed: the full diff stat, `CheckerKernel.lean` in full,
the header and footer of `CheckerKernelUpTo{16,18,20}.lean`, `tools/gen_kernel_upto.py` in full, the
`lakefile.toml` default targets, and `verify/Statement.lean` (`UpTo`). I did not run a full `lake build` or
`verify/lean_audit.py`, because another agent is doing that. My own check was one `#print axioms` run on the
existing build outputs of the worktree (result below).

## Verdict: ESCALATE

The mathematics and the Lean engineering look sound. The verdict is escalate only because the config's
throughput-jump rule, read literally, applies here (see section 4). The work itself should be accepted after
human or skeptic review, once the audit passes and the two housekeeping fixes in sections 5 and 6 are made.

## 1. Scope

- The plan names only `lean/ErdosTernary/CheckerKernel.lean`. The diff also adds three generated proof files
  (about 4,750 lines, mostly the 3,598 lines of `UpTo20`), `tools/gen_kernel_upto.py` (81 lines) and two
  import lines in `ErdosTernary.lean`.
- Everything extra exists to deliver this one hypothesis: the generated files are the proof objects and the
  script produces them. Nothing is unrelated, and `verify/` is not touched.
- I accept the scope. The ledger's `touched` list must be updated to name all six files.
- Both the generated files and the script are reproducible: the header of each file records the exact
  command that made it (`gen_kernel_upto.py k 30000 64`).

## 2. One mechanism?

Yes. The mechanism is a kernel-evaluable checker:

- structural recursion on fuel instead of well-founded recursion;
- `q = 3^i`, `m = 2^r mod 3^K` and `g = 2^(2·3^i) mod 3^K` carried down the tree instead of recomputed;
- only GMP-accelerated kernel Nat operations, and no `Nat.powMod`.

Splitting the tree into subtrees of at most 30,000 nodes is how the mechanism is applied at large N (it bounds
kernel memory per declaration). It is not a second idea. Its only trusted part is `exploreK_of_children`,
a one-line unfolding lemma.

## 3. Soundness: my audit

`exploreK_sound` is proved by induction on fuel, with three invariants:

- `3^(i+fuel) ∣ M`;
- `g = 2^(2·3^i) % M`;
- the node is called with `q = 3^i` and `m = 2^r % M`.

Each branch checks out:

- **`N < r`:** the hypothesis `r + t·P ≤ N` gives a contradiction (omega).
- **Trit = 2:** this branch uses `m / 3^i % 3` and is valid because `3^(i+1) ∣ M` (here `fuel ≥ 1`). It
  reduces through `Nat.mod_mod_of_dvd` to the reviewed g002 lemmas `pow_class_mod` and `two_mem_digits_of`.
- **`N < r+P` and `r ≤ 8`:** `t = 0` contradicts `8 < r`, and `t ≥ 1` contradicts the bound.
- **Children:** the three updates `g³`, `m·g` and `m·g²` (all mod M) are proved equal to the intended powers.
  `t` splits as `t%3 + 3·(t/3)`, which covers every residue class.
- **Fuel 0:** returns `false`, so it can only make a check fail and cannot hide a gap. Hidden truncation is
  therefore impossible.

`checkK_sound` covers both classes `n mod 2` with `M = 3^K`, `q = 3^0` and `g = 4`. It concludes with the frozen
`UpTo` from `verify/Statement.lean`, so constraint 12 is respected.

The generated files contain no `native_decide`, `sorry`, `axiom`, `implemented_by` or `extern`. The one grep
hit is the word "native_decide" inside a docstring. Every leaf is a closed `decide +kernel` goal, so
constraint 13 is respected and the result is tier A.

Axiom check (`#print axioms` on the built outputs): see the addendum at the end.

## 4. Prediction against result, and the throughput rule

**Prediction:** `UpTo(2·3^16)` at tier A, with `lake build` ≤ 20 min.

**Result:**

| N | Tier | Nodes | Kernel wall | Rate |
|---|---|---|---|---|
| 2·3^16 | A | 788,447 | 52.8 s | 14.9k nodes/s |
| 2·3^18 | A | 3,146,285 | 209.7 s | 15.0k nodes/s |
| 2·3^20 | A | 12,585,293 | 886.4 s | 14.2k nodes/s |

**Prediction miss.** The reach exceeds the prediction by N × 81, and the time at the predicted N is about
23 times faster than the budget. Both are well past the miss factor of 5, so the miss needs an explanation.
I find the explanation adequate:

- The rate is flat across the three runs, which suggests the numbers are real and not a cache artefact.
- Tree size grows by about 4× for every 9× in N, which matches `N^(log_3 2)` (the same tree as `tree_ref`).
- The time grows with the node count. Once per-node cost fell, the larger N followed.

The prediction was simply conservative, so the miss alone does not require escalation.

**Throughput jump.** `config.escalate.single_gen_throughput_jump = 3.0` says any throughput rise above 3× in
one generation is escalated without exception ("一律"). MISSION line 80 makes the Lean checker throughput a
reported throughput.

- **Baseline:** the ledger records g002-L01 `upTo_small` as `2·3^12` in 48 s of `decide +kernel`. Its tree
  is about 788k / 16 ≈ 49k nodes, so about 1.0k nodes/s.
- **Now:** about 14–15k nodes/s, roughly 14× the baseline, on the same metric and the same kernel.
- Tier-A reach rose from `2·3^12` to `2·3^20`, a factor of 6,561 in N.

Read literally, the rule is triggered. It makes no exception for exploratory experiments or for jumps that
can be explained, so the verdict is **escalate**. The jump is plausible: the old kernel path paid for
`Nat.powMod` and well-founded unfolding at every node. The point of escalation is an independent re-run, and
it also coincides with an M1 claim below.

**Caveat on the numbers.** The kernel wall times come from the commit message (`lake env lean`, nice 10).
A reviewer must reproduce them with `lake build` and confirm that they come from real output.

**M1 tier.** `upToK_20` would upgrade M1's `UpTo(2·3^20)` from tier B to tier A. That is a change to a
milestone claim. It needs `lean_audit.py ErdosTernary.CheckerKernelUpTo20 ErdosTernary.upToK_20
--expect UpTo:2*3^20` to print PASS tier=A, plus the usual skeptic panel, before `STATUS.md` changes.
It is still a formal re-verification of Vardi's bound, not a new result.

## 5. Build-time cost

- The default build (`ErdosTernary.lean`) imports only `CheckerKernel` and `CheckerKernelUpTo16`, about 1 min
  of kernel time. That is acceptable for the default build.
- `UpTo18` (about 3.5 min) and `UpTo20` (about 15 min) are not imported, so they are already outside the
  default build.
- However, they sit at the top level of `lean/ErdosTernary/` and not in `lean/ErdosTernary/Records/`, the
  convention the gen-003 L01 critic set for `UpTo28`.
- **Required:** move them to `Records/KernelUpTo18.lean` and `Records/KernelUpTo20.lean` (or similar), each
  with the header line "out of default build, build explicitly: lake build ErdosTernary.Records.…". Without
  that header, a later `lake build` can report success while the tier-A 3^20 theorem was never checked.
- Any milestone or status claim must name the explicit build command that checks it.

## 6. Safeguards for generated proof files

The design is correct in principle:

- **The generator is untrusted.** Every numeral it emits is either re-evaluated by `decide +kernel` (leaves)
  or must match `exploreK_of_children` up to definitional equality (inner nodes). The final theorem's type
  is fixed as `UpTo (2 * 3 ^ k)`. A wrong or adversarial script can only make the build fail; it cannot
  produce a false theorem.
- **Nothing in the trusted base grew.** The trusted chain is `checkK_sound`, `exploreK_of_children` and
  `checkK_of_roots`. All three are hand-written in `CheckerKernel.lean` and reviewed above.

Required safeguards:

1. **Statement check.** The audit must run on the generated module itself, with `--expect UpTo:2*3^k`. That
   checks the exact final statement and its axioms, so nobody has to trust the 3,600 lines.
2. **Pattern grep.** The audit's pattern check (`native_decide`, `attribute [`, `decide := true` and similar)
   must cover the generated files. These files are the most likely place for an injected `implemented_by` or
   a local instance to hide.
3. **Regeneration check.** Regenerating from the recorded command must give a byte-identical file. If not,
   the file was edited by hand, which its header says is forbidden.
4. **Generator hygiene.** `gen_kernel_upto.py` writes into `lean/` and must not run during `lake build`. It is
   a development tool, and its output is accepted only through the Lean checks above. It already uses only
   the standard library.

## Lesson (for the ledger)

Kernel tier-A evaluation is limited by per-node cost: structural fuel, carried residues and GMP-only Nat ops
raised kernel throughput about 14× (to about 15k nodes/s). Generated proof trees stay safe without trusting
the generator, as long as the assembly lemmas are hand-proved and the final `UpTo` statement is audited.

## Addendum: axiom check

I ran `lake env lean` with `#print axioms` against the worktree's existing build outputs. These outputs were
built by the implementer, not by me.

- `checkK_sound`, `upToK_16` and `upToK_20` each depend only on `[propext, Classical.choice, Quot.sound]`.
  That is tier A.
- `upToK_20` has the type `ErdosTernary.UpTo (2 * 3 ^ 20)`, the frozen definition.

This confirms the statement and the tier, provided the build outputs match the source. A fresh
`lake build ErdosTernary.CheckerKernelUpTo20` followed by `lean_audit.py` (the other agent's job) is still
required before the claim counts.
