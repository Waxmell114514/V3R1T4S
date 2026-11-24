# Critic: g002-L01 (residue-tree checker in Lean)

Branch commit 8f0b9ea (parent 4b4d3c7), worktree .claude/worktrees/agent-a0435d01c2a1ea8ec.

## Verdict: ACCEPT

## Checks
* **Scope.** Diff = lean/ErdosTernary/Checker.lean (new, 130 lines), lean/ErdosTernary.lean (+1 import line),
  proofs/g002-L01.md (new). plan.json `touched` lists only Checker.lean; the import line is required for the
  build and the proofs/ note is required by CONSTRAINTS rule 3. No unrelated changes. Minor: `touched` should
  have listed the two extra files (bookkeeping, not substance).
* **verify/ untouched.** `git diff 4b4d3c7 8f0b9ea -- verify/` empty; `python3 tools/check_lock.py` -> `LOCK: OK`.
* **No sorry/admit/axiom** in lean/ErdosTernary/ (grep empty).
* **Frozen definitions (rule 12).** `check_sound` concludes `UpTo N` from verify/Statement.lean directly; no
  redefinition of `UpTo`/`Statement` in lean/.
* **native_decide (rule 13).** Used only in `upTo_vardi`, on the closed term `Checker.check (2*3^20)`; the general
  soundness theorem uses no native_decide. Result correctly labelled tier B.
* **Build.** `lake build` -> `Build completed successfully (2145 jobs).`
* **Audits (rerun by Critic).**
  * `lean_audit.py ErdosTernary.Checker ErdosTernary.upTo_vardi --expect UpTo:2*3^20` (last line):
    `LEAN_AUDIT: PASS tier=B axioms=['Classical.choice', 'ErdosTernary.upTo_vardi._native.native_decide.ax_1_1', 'Quot.sound', 'propext']`
  * `ErdosTernary.Checker.check_sound`: `LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']`
  * `ErdosTernary.upTo_small --expect UpTo:2*3^12`: `LEAN_AUDIT: PASS tier=A` (same three axioms).
* **Proof review (by hand).** Node (i,r) = class r + t*2*3^i; period lemma `pow_period` (2^(2*3^i) = 1 mod 3^(i+1),
  by cubing) and `pow_class_mod` give that trit i of 2^n is constant on the class, so the trit-2 leaf is sound.
  `N < r` leaf: vacuous. `N < r + P ∧ r ≤ 8` leaf: the only member ≤ N is r ≤ 8, outside UpTo's scope. Split step
  t = t%3 + 3(t/3) maps each member to exactly one child of period 3P. Fuel exhaustion returns false (sound).
  Root covers n mod 2. No heuristic, no circularity, no hidden truncation: completeness of coverage is what the
  theorem proves, so it cannot be silently truncated. The simplification vs CERT.md (no E events / exhaustiveness
  test) affects only completeness (a genuine exception would make the checker return false), not soundness.

## Prediction vs result
Prediction: soundness tier A (met); UpTo(2*3^12)+ at tier B (exceeded: 2*3^12 at tier A via decide +kernel);
2*3^20 "within 1 hour" (reported ~10 s; Critic measured 10.6 s wall for `#eval check (2*3^20)` -> true).
Time is ~360x under the 1-hour figure, beyond prediction_miss_factor 5, but explained: the 1 hour was an upper
bound, not a point estimate, and the tree is small. Critic recount in Python with the same node rule: 12,585,293
nodes for N = 2*3^20 (surviving classes roughly double per level, ~2^(depth+1) with depth ~22), at ~1 µs per node
(GMP powMod on small moduli) -> ~10 s. Consistent with the reported time; no escalation needed. Not a throughput
metric (no prior Lean checker), so single_gen_throughput_jump does not apply.

## Regression
None. New files only plus one import; existing Basic builds; lock OK.

## Novelty
Honest. proofs/g002-L01.md states 2*3^20 is Vardi's bound "again, now as a Lean theorem; it is not new".
This is a formal re-verification (M1 is "复现"), not a new mathematical result. The 2*3^22 run (35 s) is a
reported evaluation only, not a Lean theorem in this commit, and must not be counted.

## M1 gate
As written: Lean theorem UpTo (2*3^20), tier A or B -> `upTo_vardi` tier B; audit passed -> yes (Critic rerun);
Lean-proved checker soundness theorem -> `check_sound` tier A. **M1 met, subject to** the independent Lean auditor
(rule 11) and the three-skeptic panel.

## Lesson
A residue-tree checker with a tier-A fuel-induction soundness proof turns UpTo N into a cheap closed evaluation
(~12.6M nodes, ~10 s for 2*3^20); predict runtimes from node counts, not as loose upper bounds.
