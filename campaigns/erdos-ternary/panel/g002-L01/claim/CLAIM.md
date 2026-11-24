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
