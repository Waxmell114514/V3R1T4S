# Lean audit: g000-lean

Auditor: independent Lean auditor (fresh context). Files examined: lean/ErdosTernary/Basic.lean,
lean/ErdosTernary.lean, lean/lakefile.toml, verify/Statement.lean. Toolchain leanprover/lean4:v4.36.0.

## Claims
1. `ErdosTernary.exceptions_have_no_two`: base-3 expansions of 2^0, 2^2, 2^8 contain no digit 2.
2. `ErdosTernary.upTo_40`: for every n with 8 < n <= 40, 2^n in base 3 contains a 2 (`UpTo 40`).

## Build (`cd lean && lake build`, tail)
```
warning: ../verify/Statement.lean: imports `Mathlib.Data.Nat.Digits.Lemmas` from package `mathlib`, which is designed for use with the module system; consider adding `module` to the start of this file
Build completed successfully (2143 jobs).
```
(The only warning is the module-system advisory on the frozen file; harmless.)

## lean_audit.py
```
$ python3 verify/lean_audit.py ErdosTernary.Basic ErdosTernary.upTo_40 --expect UpTo:40
'ErdosTernary.upTo_40' depends on axioms: [propext, Classical.choice, Quot.sound]
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']

$ python3 verify/lean_audit.py ErdosTernary.Basic ErdosTernary.exceptions_have_no_two
'ErdosTernary.exceptions_have_no_two' depends on axioms: [propext, Classical.choice, Quot.sound]
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
```

## Independent type check (scratch file, `lake env lean`)
```
upTo_40 : UpTo 40
exceptions_have_no_two : 2 ∉ Nat.digits 3 (2 ^ 0) ∧ 2 ∉ Nat.digits 3 (2 ^ 2) ∧ 2 ∉ Nat.digits 3 (2 ^ 8)
def ErdosTernary.UpTo : ℕ → Prop := fun N => ∀ n ≤ N, 8 < n → 2 ∈ Nat.digits 3 (2 ^ n)
example : UpTo 40 = (∀ n : ℕ, n ≤ 40 → 8 < n → 2 ∈ Nat.digits 3 (2 ^ n)) := rfl   -- accepted
#eval Nat.digits 3 0    = []
#eval Nat.digits 3 1    = [1]
#eval Nat.digits 3 4    = [1, 1]
#eval Nat.digits 3 256  = [1, 1, 1, 0, 0, 1]     (256 = 100111_3, LSD first)
#eval Nat.digits 3 5    = [2, 1]                 (5 = 12_3)
#eval Nat.digits 3 512  = [2, 2, 2, 0, 0, 2]
Nat.ofDigits_digits : ofDigits b (b.digits n) = n
Nat.getLast_digit_ne_zero : (b.digits m).getLast _ ≠ 0  for m ≠ 0
```

## Checklist
- Quantifiers/range: `UpTo N` is `∀ n, n ≤ N → 8 < n → ...`, i.e. 8 < n <= N inclusive. `UpTo 40`
  covers n = 9..40 (32 values), matching claim 2 exactly. No n < N off-by-one.
- Truncated subtraction: none appears in either statement.
- Digit semantics: `Nat.digits 3 x` is least-significant-first with no leading zeros (last digit
  nonzero for x ≠ 0, round-trips via ofDigits). Order is irrelevant to membership; absence of leading
  zeros matters only for digit 0, not 2. So `2 ∈ Nat.digits 3 x` means exactly "x has a ternary digit 2".
  Edge case `Nat.digits 3 0 = []` is irrelevant since 2^n ≥ 1 (2^0 = 1 gives [1]).
- Frozen definitions used directly: Basic.lean imports `Statement` and uses `UpTo` and `Nat.digits`
  verbatim; no new defs, instances, notation, macros, local attributes, or set_option.
- Proof method: `decide` (kernel) after `interval_cases`; no `native_decide`, no sorry. Axioms are the
  standard three only.
- lakefile: frozen lib `Frozen` built from ../verify, roots = Statement; nothing overrides it.
- Frozen `Statement` correctly formalizes Erdős's conjecture (∀ n > 8, 2 ∈ digits 3 (2^n)).

## Independent Python check
```
exceptions [(0, [1], False), (2, [1, 1], False), (8, [1, 1, 1, 0, 0, 1], False)]
9..40 missing 2: []
0..40 without 2: [0, 2, 8]
```

## Hypothetical deviation analysis
- If `UpTo` used `n < N`, `UpTo 40` would omit n = 40 and the claim "≤ 40" would be overstated by one.
  Not the case.
- If digits were computed with leading zeros or a different base, membership of 2 could be spurious
  or missing; the #eval outputs rule this out.
- If `native_decide` were used, correctness would rest on the compiler (tier drop); not used.
- If the theorem restated its own copy of the predicate, it could silently differ from the frozen one;
  the `rfl` check and `#check` show it is literally `ErdosTernary.UpTo 40`.

## Verdict
Both Lean theorems state exactly the informal claims, using the frozen definitions, kernel-checked
with standard axioms only. No concerns.

pass: true
