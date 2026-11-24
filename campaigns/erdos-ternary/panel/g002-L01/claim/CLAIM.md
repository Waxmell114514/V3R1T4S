# Claim g002-L01 (milestone M1)

Scope, exactly: the Lean 4 + Mathlib v4.36.0 project at campaigns/erdos-ternary/lean (commit on branch
claude/dreamy-curie-mcxq35, file lean/ErdosTernary/Checker.lean, copy here) proves, against the frozen definitions in
verify/Statement.lean (copy here):
1. `ErdosTernary.Checker.check_sound : check N = true → ErdosTernary.UpTo N` for every N — tier A (axioms propext,
   Classical.choice, Quot.sound only).
2. `ErdosTernary.upTo_small : UpTo (2*3^12)` — tier A (kernel evaluation via `decide +kernel`).
3. `ErdosTernary.upTo_vardi : UpTo (2*3^20)` — tier B: `native_decide` on the closed term `check (2*3^20)`, which
   trusts the Lean compiler, the runtime's native `Nat.powMod` (extern lean_nat_powmod) and GMP.
UpTo N means: for all n with 8 < n ≤ N, the base-3 expansion of 2^n contains the digit 2.

Not claimed: anything beyond these three theorems. The bound 2*3^20 is Vardi's (1991) known computational bound
and Saye (2022) verified up to 2*3^45; this is a formal (machine-checked) re-verification, not a new mathematical
result. M1's gate (MISSION.md): a Lean theorem UpTo(2*3^20), tier A or B, audit passed, plus a Lean-proved checker
soundness theorem.

How to rerun: `cd campaigns/erdos-ternary/lean && lake build`, then from campaigns/erdos-ternary:
`python3 verify/lean_audit.py ErdosTernary.Checker <theorem> [--expect UpTo:2*3^20]`.

## Revision 2 (after the CRITERION skeptic, panel/g002-L01/criterion.md) — wording only, scope unchanged
- Pinned: Checker.lean as of commit 8f0b9ea27d1554d5b30bc61e7f81ec8895c8c4a9 on branch claude/dreamy-curie-mcxq35.
- Tier B trust, stated as observed: with Lean v4.36.0, `#print axioms ErdosTernary.upTo_vardi` lists propext,
  Classical.choice, Quot.sound and the auxiliary axiom `ErdosTernary.upTo_vardi._native.native_decide.ax_1_1`
  created by native_decide (this Lean version does not list Lean.ofReduceBool). It trusts the Lean compiler and
  runtime, including the compiled implementation of Nat.powMod (core marks it @[extern "lean_nat_powmod"], as read
  by the independent Lean auditor in panel/g002-L01/lean_audit.md) and GMP.
- Audit evidence: verify/lean_audit.py PASS (check_sound tier A, upTo_small tier A, upTo_vardi tier B) and the
  independent auditor's pass: panel/g002-L01/lean_audit.md.
- Sources: Saye 2022 bound read from the arXiv abstract (specs/sources/arxiv-2202.13256-abs.html); Vardi 1991 bound
  未核实 (seen only in secondary sources, not in Vardi's book).
- Allowed one-sentence scope: "In Lean 4 + Mathlib, against the frozen definition ErdosTernary.UpTo, we prove
  check N = true → UpTo N for all N (tier A), UpTo (2·3^12) by kernel evaluation (tier A), and UpTo (2·3^20)
  (every n with 8 < n ≤ 6973568802 has 2^n containing the ternary digit 2) by native_decide on the closed term
  check (2·3^20) (tier B, trusting the Lean compiler and runtime including GMP) — a machine-checked re-verification
  of Vardi's known bound, not a new result."
