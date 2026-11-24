# Critic: g004-P03 (branch g004-P03, commit 277de6f, parent 770152b)

**Verdict: accept.** I recommend recording this as an extension of the M3 result g002-L02, not as a separate M3 result. It is a tier-A Lean theorem and counts toward Lean.new_theorems. It does not add to M3_confirmed_new_statements.

## Scope
- The diff matches plan.json `touched`. It adds lean/ErdosTernary/CountingLambda.lean and proofs/g004-P03.md, plus two numerics scripts under proofs/ and a one-line import in lean/ErdosTernary.lean. The scripts and the import were not listed in `touched`, but they are harmless and directly related.
- `git diff --stat 770152b 277de6f -- campaigns/erdos-ternary/verify` is empty, so verify/ is untouched. Counting.lean is unchanged.
- grep finds no sorry, admit, axiom, native_decide or set_option in CountingLambda.lean.
- The statement uses `Nat.digits 3`, `Finset.range` and `Real.logb` directly, in the same form as the accepted `Counting.card_noTwo_le_succ_rpow`. Nothing frozen is redefined (C12 holds).

## Audit (rerun in the worktree)
`python3 verify/lean_audit.py ErdosTernary.CountingLambda ErdosTernary.CountingLambda.card_noTwo_mul_le_succ_rpow`
→ "Build completed successfully (4217 jobs)". Axioms: [propext, Classical.choice, Quot.sound]. The last line was:
`LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']`
The native_decide warnings come from Checker, CheckerShard and Records, which this commit does not touch.

## Math
The proof is correct. The hypothesis 3 ∤ λ is used in exactly two places, and both uses are valid:
- **The ≤2-children step.** λ·2^{r0+jP} is coprime to 3^{k+2}, so it can be cancelled. That gives 2^{(j'−j)P} ≡ 1 mod 3^{k+2}, which contradicts ord = 2·3^{k+1}.
- **The root.** If λ ≡ 1 (mod 3), only r = 0 survives. If λ ≡ 2, only r = 1 survives. So |T_{λ,0}| = 1.

Periodicity and the concavity step (Lemma E) do not depend on λ. They are reused unchanged from g002-L02.

## Labels
- The labels are correct. The main theorem, the finite form and the λ=1 corollary are LEAN-VERIFIED.
- The finite form is correctly marked as having KNOWN substance (Lagarias 2009 Thm 1.4, cited via specs, "本人未打开原文").
- The 3 | λ reduction is marked PROVED-HERE. The ℤ_3^× extension is marked SKETCH. Numerics are explicitly not counted as results.
- "新颖性未经检索，不作判断" is honest.

## Novelty
According to specs/literature.md §2 and specs/narkiewicz1980.md §4:
- **What Lagarias already has.** Thm 1.4 gives Ñ_λ(X) ≤ 2X^α for every nonzero λ ∈ ℤ_3 and X ≥ 2, "using essentially the same proof" as Narkiewicz (λ = 1). It also states the exact count of 2^{k−1} good residues per period for every λ. So the λ-uniformity, and the fact that the per-period count does not depend on λ, are already in the literature.
- **What is new here.** The only part not found in the literature is constant 1 in the (X+1) normalization, valid for all X. That is exactly what g002-L02 contributed, and it was confirmed and accepted by the human.
- **How the new part was obtained.** P03 gets the λ-version by changing two lines of the g002-L02 proof, because Lemma E uses only |T_k| ≤ 2^k plus periodicity. That is a routine corollary of the g002-L02 method, combined with the λ-uniformity Lagarias already observed. It is not a separate new statement.

The statement itself, constant 1 for the whole family 3 ∤ λ, does not appear in any source opened so far. So it may be recorded as "M3 result, generalized form (Lean, tier A)" under panel/g002-L02. It should not take part in a fresh novelty claim.

**Sharpness.** It applies to the family as a whole, through λ = 1. Whether the bound is tight for any individual λ ≠ 1 was not studied, and the proof doc correctly says so.

## Prediction
The prediction was +1 tier-A theorem. The result was +1 tier-A theorem (plus a finite form and a λ=1 corollary). The miss factor is 1, so no escalation is needed.

## Lesson (ledger)
Extending a confirmed counting bound to multipliers λ (3 ∤ λ) is a two-line change once the proof uses only |T_k| ≤ 2^k and periodicity. Record such generalizations as extensions of the parent M3 result, not as new M3 statements, especially since Lagarias Thm 1.4 already has the λ-uniform version with constant 2.
