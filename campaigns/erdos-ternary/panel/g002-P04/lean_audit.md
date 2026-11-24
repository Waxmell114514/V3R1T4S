# Lean audit: g002-P04

Auditor: independent Lean auditor (fresh context). Worktree branch g002-P04, commit 2a3e009.
Files inspected: lean/ErdosTernary/E4.lean, lean/ErdosTernary.lean, lean/lakefile.toml, verify/Statement.lean, verify/lean_audit.py.

## Informal claim
`ErdosTernary.lagarias_witness_4_pow18`: 532261, 2^2·532261 and 2^18·532261 each have no digit 2 in base 3.
No Hausdorff-dimension claim. Claimed tier A.

## Commands run
`cd lean && lake build` (tail):
```
warning: ../verify/Statement.lean: imports `Mathlib.Data.Nat.Digits.Lemmas` from package `mathlib`, which is designed for use with the module system; consider adding `module` to the start of this file
Build completed successfully (2145 jobs).
```
`python3 verify/lean_audit.py ErdosTernary.E4 ErdosTernary.lagarias_witness_4_pow18` (last line):
```
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
```
No WARN lines were emitted. `python3 tools/check_lock.py`: `LOCK: OK`.

## Statement check
```lean
theorem lagarias_witness_4_pow18 :
    2 ∉ Nat.digits 3 532261 ∧ 2 ∉ Nat.digits 3 (2 ^ 2 * 532261) ∧
      2 ∉ Nat.digits 3 (2 ^ 18 * 532261) := by
  refine ⟨?_, ?_, ?_⟩ <;> decide
```
- Numbers/exponents: N = 532261, multipliers 2^2 and 2^18 - exactly as claimed.
- `Nat.digits 3 m` is Mathlib's base-3 digit list (little-endian); the direction is irrelevant for a membership
  statement. For m > 0 there are no leading-zero artefacts; digits of a base-3 expansion are in {0,1,2}, so
  "2 ∉ digits" is exactly "all digits are 0 or 1".
- No new definitions, instances, notation, macros, attributes, or set_option in E4.lean or ErdosTernary.lean.
  No native_decide; proof is kernel `decide` (tier A confirmed by axioms). The frozen `Statement`/`UpTo`
  are not used or redefined (not needed: this is a by-product fact, not a statement of the conjecture).
- lakefile.toml: Frozen lib from ../verify, Mathlib pinned v4.36.0; nothing unusual.

## Independent verification (own Python, repeated division by 3)
| exp | value | base 3 (MSB first) | contains 2 |
|---|---|---|---|
| 0 | 532261 | 1000001010101 | no |
| 2 | 2129044 | 11000011111111 | no |
| 18 | 139529027584 | 111100011000111000001101 | no |

## Comments / docstrings
The module header mentions the E^(4) search (stated as a negative search result, "nothing about E^(4) is
stated here") and the Lagarias Thm 1.7 consequence dim_H C(1,2^2,2^18) ≥ log_3 2 / 24, explicitly labelled
"That implication is NOT formalized here ... this file states only the three digit facts." The theorem
docstring claims only the three digit facts. No over-claiming.

## Hypothetical deviation
If an exponent or N were wrong (e.g. 2^17 instead of 2^18), the theorem would certify a different triple and
any downstream use as a Lagarias witness for C(1,2^2,2^18) would be unsupported; if the dimension remark
were presented as proved, a reader would wrongly believe a dimension bound is kernel-checked. Neither occurs.

## Verdict
Statement matches the informal claim exactly; builds; tier A with only standard axioms; independently
confirmed numerically; comments correctly label the unformalized implication.

pass: true
