# Critic: g003-L02 (branch g003-L02, commit ce68f7d, parent 3188e92)

**Verdict: accept** (as a correct tier-A formalization). **Recommendation: record as an intermediate result; do not panel it as an M3 candidate by itself.**

## Checks
- Diff `3188e92..ce68f7d`: 3 files, all additions: `lean/ErdosTernary.lean` (+1 import), `lean/ErdosTernary/E3Count.lean` (new, 133 lines), `proofs/g003-L02.md` (new). This matches the plan entry's `touched` list (the extra import line is needed to build the file). No unrelated changes. verify/ is untouched.
- `E3Count.lean`: no sorry, admit, axiom or native_decide (grep finds only the docstring word "native_decide" on line 2). It uses the frozen `Nat.digits` directly and does not redefine anything.
- I reran it in the worktree, with nice and LEAN_NUM_THREADS=1:
  `python3 verify/lean_audit.py ErdosTernary.E3Count ErdosTernary.E3Count.e3_count_4_pow18`
  Last line: `LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']`
  I did not rerun the audit for `card_ge_of_witness`; the author's run and the independent audit cover it.
- Mathematics: I read every step. Lemma A (no carries when a < 3^L), Lemma B and Theorem C (injective maps, disjoint images since 0 < N < 3^L) are all correct. Tier A is justified: the witness facts come from `decide` in E4.lean.
- Prediction (+1 tier-A general theorem) matches the outcome, so no prediction-miss issue arises.

## Labels (CONSTRAINTS 3, 10)
Mostly correct, with two small defects:
- Lemma A is tagged "KNOWN-style" with no source. KNOWN requires a citation. Either cite Lagarias's Thm 1.7 proof (the block construction) or tag it PROVED-HERE + LEAN-VERIFIED.
- Theorem C is the concatenation argument from Lagarias's Thm 1.7 proof, specialised to x, 4x and 2^18 x. The draft should say plainly that the mechanism is KNOWN (Lagarias, arXiv:math/0512006). The only non-literature input is the witness N = 532261.

§3 and §4 honestly state that dim_H is not formalized and that the result has no bearing on the Erdős conjecture.

## Novelty judgment (MISSION M3)
- `card_ge_of_witness` is Lagarias's own construction. It is a formalization of KNOWN mathematics, not a new statement.
- `e3_count_4_pow18` = `card_ge_of_witness` + `lagarias_witness_4_pow18`. The witness was already found and LEAN-VERIFIED in g002-P04, and the specialisation is a one-line application. So the only mathematical content not in the literature is "C(1,2^2,2^18) has a Lagarias witness", equivalently positive dimension of that component. That fact was already recorded as g002-P04's finite witness.
- Even that novelty is weak. specs/e3-components.md only says NOT FOUND within the sources searched, and lists gaps: Semantic Scholar and arXiv returned 429, and three citing papers were seen by title only. So "not in the literature" is unconfirmed.
- The statement that would be a fair M3 candidate is "dim_H C(1,2^2,2^18) > 0" (or ≥ log_3 2 / 24), and that is exactly the part that is not formalized.

Counting this as a separate new theorem would count the P04 witness a second time, under a Lagarias wrapper.

## Recommendation
- Record L02 as an intermediate formalization (infrastructure). The general lemma is reusable for the other 8 components.
- If a panel happens, panel one combined item: witness (P04) + count (L02) for C(1,2^2,2^18). It should be conditioned on finishing the literature search (close the 429 and full-text gaps), and labelled as a finite counting core, not a dimension theorem.

## Lesson
Formalizing a known mechanism around a new witness adds no new mathematics. The M3 novelty stays with the witness (and the unformalized dimension claim), so count it once.
