# Skeptic CRITERION: g002-L01

Material read: panel/g002-L01/claim/{CLAIM.md, Checker.lean, Statement.lean}, MISSION.md, CONSTRAINTS.md. Nothing else.
I did not rebuild anything or run the audit. That is REPRODUCE's job. An attempt to diff the claim copies against
lean/ and verify/ and to inspect the toolchain was blocked in this session, so those checks are not done here.

## Does the scope match the Lean statements?

- **UpTo**: `UpTo N := ∀ n, n ≤ N → 8 < n → 2 ∈ Nat.digits 3 (2^n)`, from the claim's copy of the frozen
  Statement.lean. This is exactly the informal "for all n with 8 < n ≤ N, the base-3 expansion of 2^n contains the
  digit 2". The bound is inclusive and the lower bound is strict, as claimed.
- **Literal values**: 2·3^12 = 1062882 and 2·3^20 = 6973568802, both computed with python3 here. The docstrings
  give the same numbers, and the theorems use the symbolic `2 * 3 ^ 12` and `2 * 3 ^ 20`.
- **check_sound**: `check N = true → UpTo N`, with N a free variable. The proof goes through `explore_sound`,
  `pow_period`, `pow_class_mod` and `two_mem_digits_of` and contains no `decide` or `native_decide`. Claiming tier A
  is consistent with the source. I also read through the logic of the three success cases and the case split into
  three children (t mod 3), and it is sound. `fuel` running out returns false, which is harmless.
- **upTo_small**: `check_sound (by decide +kernel)`. Kernel reduction adds no axiom, so tier A is consistent. As
  usual, this relies on the kernel's GMP-accelerated Nat arithmetic.
- **upTo_vardi**: `check_sound (by native_decide)` applied only to the closed Bool term `check (2*3^20) = true`.
  This complies with rule 13, and the theorem is correctly labelled tier B.
- **Nothing extra**: CLAIM.md states exactly these three theorems and says "Not claimed: anything beyond these
  three theorems". That matches the source.

## What native_decide trusts

The statement is substantially correct (compiler, runtime Nat.powMod, GMP), with two corrections:

1. It should name the axioms that define tier B in MISSION.md: `Lean.ofReduceBool` (plus `Lean.trustCompiler`
   where the toolchain emits it).
2. The extern symbol name "lean_nat_powmod" is not verified. I could not inspect the toolchain. It is safer to say
   "the compiled runtime implementation of `Nat.powMod` and GMP bignum arithmetic" unless the exact symbol is
   checked against the toolchain source.

## M1 gate as written

The gate asks for four things:

- a Lean theorem `UpTo (2·3^20)` at tier A or B: provided, at tier B;
- a Lean-proved checker soundness theorem: provided, `check_sound`, tier A;
- `lean_audit.py` PASS;
- an independent auditor PASS.

CLAIM.md gives instructions for rerunning the audit but does not report a result, and no audit record is in the
claim folder. The scope meets the gate's statement requirements. Passing the gate still depends on the REPRODUCE
skeptic and the auditor confirming `lake build`, `lean_audit.py --expect UpTo:2*3^20` PASS, and the axiom lists:
{propext, Classical.choice, Quot.sound} for `check_sound` and `upTo_small`, plus `Lean.ofReduceBool` for
`upTo_vardi`.

## Overclaiming

None found. CLAIM.md explicitly says this is a formal re-verification of Vardi's known bound and "not a new
mathematical result". It does not use the words record, first, new result, solved or CONFIRMED. That is consistent
with rule 6. Rule 4 does not apply.

Minor nits:

- The provenance is "commit on branch claude/dreamy-curie-mcxq35". It should pin a commit hash.
- "Vardi (1991)" and the Saye 2·3^45 figure are cited from memory. Rule 1 requires them to be marked 未核实
  (unverified) unless a source was opened. Also, Saye's result is for 16 ≤ n ≤ 2·3^45 and is a stronger statement
  (all three digits appear).

## Scope I would allow to be published

"In Lean 4 + Mathlib, against the frozen definition `ErdosTernary.UpTo`, we prove the following:

- a checker soundness theorem `check N = true → UpTo N` for all N, at tier A;
- `UpTo (2·3^12)` by kernel evaluation, at tier A;
- `UpTo (2·3^20)` (for every n with 8 < n ≤ 6973568802, the base-3 expansion of 2^n contains a 2) by
  `native_decide` on the closed term `check (2·3^20)`, at tier B, trusting `Lean.ofReduceBool`, that is, the Lean
  compiler and runtime including GMP.

This is a machine-checked re-verification of Vardi's known bound, not a new result."

pass: true
