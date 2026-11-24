# g003-C04 skeptic, role CRITERION

What I read: panel/g003-C04/claim/ (CLAIM.md, CheckerKernel.lean, Statement.lean, generated_files.sha256);
the first 40 and last 20 lines of lean/ErdosTernary/Records/CheckerKernelUpTo20.lean; MISSION.md and CONSTRAINTS.md.
I did not build anything (that is REPRODUCE's job). The only command I ran was a Python arithmetic check.

## Scope versus the Lean statements

- `checkK_sound {N K} (h : checkK N K = true) : UpTo N` is stated for all N and K and uses the frozen `UpTo`
  (claim copy of Statement.lean: `∀ n, n ≤ N → 8 < n → 2 ∈ Nat.digits 3 (2 ^ n)`). CLAIM.md's gloss
  "for all n with 8 < n ≤ N, the base-3 expansion of 2^n contains the digit 2" matches it exactly.
  The proof goes by induction on fuel and has no `decide` or `native_decide`. The only `native_decide` in the file
  is the word inside a docstring. It depends on `Checker.two_mem_digits_of` and `Checker.pow_class_mod` from
  ErdosTernary.Checker, which is not in the claim folder. The audit (`#print axioms`) covers that dependency.
- `upToK_20 : UpTo (2 * 3 ^ 20)` is stated in the frozen vocabulary. I checked by Python: 2*3^20 = 6973568802 and
  3^64 = 3433683820292512484657849089281, the literals in the generated file. The root `g` values (4, 64 at q=3,
  262144 at q=9) equal 2^(2*3^i). The final term is `checkK_sound (K := 64) (checkK_of_roots _ _ n20_0 n20_1)`,
  and the kernel identifies `3^64`, `1 % 3^64` and `4 % 3^64` with the literals by definitional unfolding.
  Scope item 2 matches.
- Rule 13 / tier A: no `native_decide` appears in the inspected header or tail, and CLAIM.md asserts none.
  The tier-A label (axioms ⊆ {propext, Classical.choice, Quot.sound}) is only as good as REPRODUCE's
  `lean_audit.py` run. The label is correct as a claim and must be confirmed there.

## Trusted base

- "Does not trust the Lean compiler" is accurate. `decide +kernel` sends the `Decidable` evaluation to the kernel's
  type checker (`of_decide_eq_true` with `Eq.refl true`). It does not compile code, so it adds neither
  `Lean.ofReduceBool` nor `Lean.trustCompiler`.
- What is still trusted, and CLAIM.md does not say this: the Lean 4 kernel itself, including its built-in
  GMP-backed Nat literal arithmetic (`Nat.add/mul/div/mod/ble/beq`, ...). That acceleration is C++ code in the kernel
  and is exercised heavily here, on 31-digit moduli across about 1024 `decide +kernel` declarations. The trusted
  base also includes Mathlib's `Nat.digits` and the frozen statement, `lean_audit.py`, and the build toolchain
  (elaborator, .olean storage). This is the standard tier-A trusted base, so the omission is not an overclaim.
  It should still be stated in one clause.
- "Untrusted generator, correctness rests only on Lean checking them" is accurate, with one qualification.
  The generator also writes the final theorem statement `upToK_20 : UpTo (2 * 3 ^ 20)`, so correctness rests on
  three things: the kernel check, `lean_audit.py --expect UpTo:2*3^20` confirming that this exact constant has the
  frozen type with allowed axioms, and the independent lean_auditor (MISSION (3)). The numbers in the generated
  header (12585293 nodes, largest subtree 25828, "≤30000-node subtrees") are generator output and unverified.
  They concern performance only, not soundness, and should not be read as checked facts.

## M1 gate

M1 requires three things: a Lean theorem `UpTo (2·3^20)` at tier A or B, an audit pass, and a Lean-proved checker
soundness theorem. `upToK_20` plus `checkK_sound` meet this at tier A, provided REPRODUCE's build and audit pass and
the lean_auditor passes. Nothing in the claim is beyond what M1 asks for.

## Overclaim check

There is no novelty overclaim. CLAIM.md disclaims anything new, credits Vardi with the 2*3^20 bound and calls itself
only an evidence upgrade of M1. It does not use "new", "first" or "record" (rule 6). Rule 4 does not apply here.

There is one excess. The parenthetical "(Also `upToK_16` ... and `upToK_18` in Records/CheckerKernelUpTo18.lean,
tier A)" goes beyond the reviewed evidence. generated_files.sha256 has no hash for CheckerKernelUpTo18.lean, and the
rerun instructions cover only UpTo20. The panel therefore cannot confirm upToK_18, and upToK_16 is not reproduced
either. These two theorems lie outside this panel's scope and must not be counted as panel-confirmed. Since UpTo18 and
UpTo16 are implied by UpTo20 anyway, dropping them costs nothing.

## Allowed scope (one sentence)

In the Lean 4 + Mathlib project campaigns/erdos-ternary/lean, using the frozen `ErdosTernary.UpTo`, the theorems
`ErdosTernary.CheckerKernel.checkK_sound : checkK N K = true → UpTo N` (for all N, K) and
`ErdosTernary.upToK_20 : UpTo (2 * 3 ^ 20)` (2*3^20 = 6973568802; Vardi's known bound, nothing new) are proved at
tier A (axioms only propext, Classical.choice, Quot.sound, subject to the REPRODUCE audit), with the concrete
instance checked by Lean kernel evaluation (`decide +kernel`), so the Lean compiler is not trusted but the Lean
kernel, including its GMP-accelerated Nat arithmetic, is. This meets M1 at tier A once the build, the audit and the
lean_auditor pass. upToK_16 and upToK_18 are not covered by this panel.

pass: true
