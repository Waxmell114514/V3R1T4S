# Lean audit: g002-L01

Auditor: independent Lean auditor (fresh context). Worktree commit 8f0b9ea, toolchain leanprover/lean4:v4.36.0, Mathlib v4.36.0.
Files inspected: lean/ErdosTernary/Checker.lean, lean/ErdosTernary.lean, lean/lakefile.toml, verify/Statement.lean, verify/lean_audit.py
(plus Lean core's Init/Data/Nat/PowMod.lean to see how `Nat.powMod` is compiled). No proofs/ or discussion read.

## Commands run (by me)

`cd lean && lake build` (tail):
```
warning: ErdosTernary/Checker.lean: imports `Mathlib.Tactic.NormNum` from package `mathlib`, which is designed for use with the module system; ...
Build completed successfully (2145 jobs).
```
The build was cached, so I also re-elaborated the file from scratch with `lake env lean ErdosTernary/Checker.lean`:
it finished with no errors in 59.5 s (this covers `decide +kernel` and `native_decide`).

`python3 verify/lean_audit.py ErdosTernary.Checker ErdosTernary.Checker.check_sound`
```
WARN ErdosTernary/Checker.lean: native_decide
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
```
`python3 verify/lean_audit.py ErdosTernary.Checker ErdosTernary.upTo_small --expect UpTo:2*3^12`
```
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
```
`python3 verify/lean_audit.py ErdosTernary.Checker ErdosTernary.upTo_vardi --expect UpTo:2*3^20`
```
LEAN_AUDIT: PASS tier=B axioms=['Classical.choice', 'ErdosTernary.upTo_vardi._native.native_decide.ax_1_1', 'Quot.sound', 'propext']
```
`python3 tools/check_lock.py` gives `LOCK: OK`. Statement.lean matches verify.lock, as audit step 1 also checks.

The only WARN is the one intended `native_decide`, which is on line 128 (`upTo_vardi`).

## Line-by-line review of Checker.lean

* **Imports**: `Statement` (the frozen file, served by the `Frozen` lean_lib with `srcDir = "../verify"`), plus
  Mathlib ModEq, Ring and NormNum. The file does not redefine `UpTo`, `Statement` or `Nat.digits`.
  ErdosTernary.lean only imports Basic and Checker.
* **No meaning-changing constructs**: I grepped for `@[`, `attribute`, `set_option`, `macro`, `syntax`, `notation`,
  `instance`, `opaque`, `extern`, `implemented_by`, `csimp`, `axiom`, `sorry`, `unsafe` and `partial`, and none of them
  occurs. The file has only plain `def`s (`explore` and `check`, both structurally recursive on `fuel`, so the kernel
  can evaluate them) and `theorem`s.
* **check_sound**: `theorem check_sound {N : ℕ} (h : check N = true) : UpTo N`. This is exactly "check N = true → UpTo N",
  with the frozen `ErdosTernary.UpTo` (the theorem is in namespace ErdosTernary.Checker, so the name resolves to the
  frozen definition, and no local definition shadows it). The frozen `UpTo N` is `∀ n, n ≤ N → 8 < n → 2 ∈ Nat.digits 3 (2^n)`.
  Its bounds are `n ≤ N` (inclusive) and `8 < n` (strict), it uses `Nat.digits` (little-endian, but membership does
  not depend on direction), and it uses no Nat subtraction.
* **Proof structure**:
  * `pow_period`: 2^(2·3^i) ≡ 1 mod 3^(i+1).
  * `pow_class_mod`: 2^(r+tP) ≡ 2^r mod 3^(i+1).
  * `two_mem_digits_of`: if trit i of x is 2, then 2 ∈ digits.
  * `explore_sound`: induction on fuel. Each of the three success branches is justified. The recursive case splits
    t = t%3 + 3·(t/3), which covers the class exactly, because the class of (i, r) is the disjoint union of the three
    child classes (i+1, r + jP), j = 0, 1, 2. Running out of fuel returns `false`, which cannot make a false
    statement provable.
  * `check_sound`: n = n%2 + (n/2)·2 covers both root classes (P = 2·3^0 = 2).
  * Axioms are only the standard three, so the proof is tier A.
* **upTo_small**: `Checker.check_sound (by decide +kernel)`. The expected type `UpTo (2*3^12)` fixes N, so the
  goal is the closed term `check (2*3^12) = true`, which the kernel reduces. It is tier A, and `--expect UpTo:2*3^12`
  elaborated. (2·3^12 = 1,062,882, which matches the claim.)
* **upTo_vardi**: `Checker.check_sound (by native_decide)`. The only native goal is the closed Boolean equation
  `check (2*3^20) = true`. It is tier B, and `--expect UpTo:2*3^20` elaborated. (2·3^20 = 6,973,568,802, which matches
  the claim.) native_decide is not used anywhere else.

## Nat.powMod: what is trusted

In Lean core v4.36.0, `Nat.powMod` is `@[expose, semireducible, extern "lean_nat_powmod"]`. Its logical definition is
square-and-multiply, and `Nat.powMod_def : powMod b e m = b^e % m` is proved in core and used in `explore_sound`.

* **Kernel path (upTo_small)**: the kernel unfolds the logical definition (with its GMP-accelerated Nat
  primitives), so nothing beyond the kernel is trusted.
* **Compiled path (upTo_vardi)**: compiled code calls the C runtime `lean_nat_powmod` (GMP / small-nat code) instead
  of the Lean definition. `Nat` `/`, `<`, `+`, `*` and `^` also use runtime and GMP implementations.

So tier B trusts all of the following:
* the Lean compiler (LCNF, IR and C code generation) correctly compiles `explore` and `check`;
* `lean_nat_powmod` agrees with `Nat.powMod` (that is, it computes b^e mod m);
* the GMP and runtime bignum arithmetic is correct;
* the `Lean.ofReduceBool` mechanism, represented by the auxiliary axiom `upTo_vardi._native.native_decide.ax_1_1`.

None of these is introduced by this project. The project adds no `extern`, `implemented_by` or `csimp`, so the
compiled code differs from the logical definitions only through core's own extern. All values here are below 3^21 and
a few times 10^10, so a bug in this path would have to be a plain arithmetic error, not an edge case like modulus 0
(the modulus 3·3^i is never 0).

## Independent Python checks

* **The pruning rule `N < r + 2*3^i ∧ r ≤ 8` cannot hide an n > 8.** The members of node (i, r) are r + tP with
  P = 2·3^i ≥ 2. If N < r + P, then every member with t ≥ 1 is ≥ r + P > N, so it is outside `UpTo N`. The only member
  ≤ N is n = r itself (t = 0), and r ≤ 8 means 8 < n fails, so that member is outside the scope of UpTo. Both conjuncts
  are needed:
  * Without `N < r+P`, the class of r = 8 contains, for example, 8 + 2·3^i, which could be ≤ N.
  * With the bound raised to r ≤ 9, it could wrongly prune n = 9.
  This is exactly the `rcases t` case in the proof.
* **Reimplementation.** I reimplemented `explore` and `check` literally (iteratively, with the same fuel N+64, the same
  branch order, and `pow(2,r,3q)//q == 2`):
  * `check(2*3^8)` = **True** (2813 nodes). A brute-force check confirms UpTo(2·3^8). The only n ≤ 20 whose 2^n has no
    digit 2 are 0, 2 and 8.
  * Mutated version (`r ≤ 7` instead of `r ≤ 8`): `check(2*3^8)` = **False**. It fails by fuel exhaustion at node
    (i = 13186, r = 8). This is the expected result: 2^8 = 100111 in base 3 has no digit 2 at any position, so the
    j = 0 chain through r = 8 never closes. The pruning rule is therefore what discharges n = 8, and only n = 8.
  * `check(M)` is True for M = 7, 8, 9, 10, 100, and `check(2*3^12)` = True (48,929 nodes). This agrees with the
    kernel result.

## Hypothetical deviations and their consequences

* If check_sound's conclusion used `n < N` or a local copy of UpTo, the claims would assert a range different from the
  frozen one. This does not happen: `--expect` elaborated against the frozen `UpTo`.
* If the pruning were `r ≤ 9`, or dropped `N < r + P`, the checker could accept while some n > 8 lacked a 2.
  Soundness would then be unprovable, and the proof does prove it, so the kernel guards this case.
* If `lean_nat_powmod`, GMP or the compiler miscomputed, `native_decide` could accept a `check (2*3^20)` that is
  logically false. That would wrongly certify `UpTo (2*3^20)`. This is exactly the residual trust of tier B, which is
  stated correctly. Claims 1 and 2 do not depend on it.

## Verdict

* Claim 1 (check_sound, tier A): correct statement, kernel-checked, standard axioms only. **OK.**
* Claim 2 (upTo_small, UpTo (2·3^12), tier A): `decide +kernel`, standard axioms only. **OK.**
* Claim 3 (upTo_vardi, UpTo (2·3^20), tier B): native_decide only on the closed term `check (2*3^20)`, with its trust
  base as stated. **OK.**

pass: true
