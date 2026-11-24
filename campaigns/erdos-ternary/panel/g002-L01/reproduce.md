# g002-L01 — skeptic REPRODUCE

Inputs read: panel/g002-L01/claim/{CLAIM.md, Checker.lean, Statement.lean}, lean/lakefile.toml, verify/lean_audit.py.
Repo HEAD 5050a69ab0632225b5b7689d560622169fddb572, branch claude/dreamy-curie-mcxq35. Date 2026-11-24.

## 1. Rerun

- `diff panel/g002-L01/claim/Checker.lean lean/ErdosTernary/Checker.lean` -> no output (identical).
- `diff panel/g002-L01/claim/Statement.lean verify/Statement.lean` -> no output (identical). The lakefile's
  `Frozen` lib has srcDir ../verify, so `import Statement` resolves to the frozen file.
- `cd lean && lake build` -> `Build completed successfully (4227 jobs).` (only "module system" import warnings).
- Audits (from campaigns/erdos-ternary):
```
== ErdosTernary.Checker.check_sound
Build completed successfully (2139 jobs).
WARN ErdosTernary/Checker.lean: native_decide
'ErdosTernary.Checker.check_sound' depends on axioms: [propext, Classical.choice, Quot.sound]
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
== ErdosTernary.upTo_small --expect UpTo:2*3^12
Build completed successfully (2139 jobs).
WARN ErdosTernary/Checker.lean: native_decide
'ErdosTernary.upTo_small' depends on axioms: [propext, Classical.choice, Quot.sound]
LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
== ErdosTernary.upTo_vardi --expect UpTo:2*3^20
Build completed successfully (2139 jobs).
WARN ErdosTernary/Checker.lean: native_decide
'ErdosTernary.upTo_vardi' depends on axioms: [propext, Classical.choice, Quot.sound,
 ErdosTernary.upTo_vardi._native.native_decide.ax_1_1]
LEAN_AUDIT: PASS tier=B axioms=['Classical.choice', 'ErdosTernary.upTo_vardi._native.native_decide.ax_1_1', 'Quot.sound', 'propext']
```
The single WARN is the expected `native_decide` in upTo_vardi; it matches the claimed tier B.

## 2. Why check N = true implies UpTo N (own derivation)

- Periodicity: 2^(2*3^i) = 1 mod 3^(i+1) (i=0: 4 = 1 mod 3; step: if 2^(2*3^i) = 1 + 3^(i+1)q then cubing gives
  1 + 3^(i+2)(q + 3^(i+1)q^2 + 3^(2i+1)q^3)). Hence 2^n mod 3^(i+1), and so trit i of 2^n
  = floor((2^n mod 3^(i+1)) / 3^i), depends only on n mod P, P = 2*3^i. Only "order divides P" is needed, not
  exact order, so the docstring's "multiplicative order" remark is not load-bearing.
- `Nat.powMod 2 r (3q) / q` with q = 3^i is exactly trit i of 2^r (value < 3q, so the quotient is in {0,1,2}).
- Node (i,r) = class {r + tP}. It returns true only if (a) N < r: every member exceeds N; (b) trit i of 2^r is 2:
  then trit i of every member is 2, and a nonzero trit at position i means 2 is in Nat.digits 3 (two_mem_digits_of);
  (c) N < r+P and r <= 8: the only member <= N is r, which is out of scope (8 < n fails); or (d) all three children
  (i+1, r + jP), j=0,1,2, return true — these partition the class since {r+tP} = union_j {r+jP + s*3P}
  (t = j + 3s, P' = 3P = 2*3^(i+1)). Induction on fuel gives explore_sound; fuel 0 returns false, so fuel can only
  cost completeness, never soundness.
- Root: n mod 2 in {0,1} covers all n with P = 2*3^0 = 2. So check N = true gives UpTo N.
- Gaps found: none in the logic. Trust notes: upTo_small is kernel-checked (tier A); upTo_vardi additionally trusts
  the compiler + native Nat.powMod/GMP (tier B), exactly as CLAIM.md states. The audit's "Build completed" plus
  the `example : UpTo (2*3^20) := @upTo_vardi` elaboration confirms the theorem type is the frozen UpTo.

## 3. Independent computation (own C code, no project code; /tmp/claude-0/-home-user-V3R1T4S/574261f0-a436-50ae-bd9e-c4ad05e010b7/scratchpad/sk)

brute.c: base-3 digit array of 2^n maintained by repeated doubling, n = 0..20000, flag any power with no digit 2.
tree.c: own residue-tree DFS; 2^r mod 3^(i+1) by binary powmod with unsigned __int128 (direct product when
modulus <= 2^64, double-and-add mulmod for moduli < 2^126); depth cap 78 counted as failure; leaf r <= LIM
accepted only when r is the sole member <= N.
```
$ nice -n 15 timeout 30m ./brute 20000
no-2: n=0 (trits=1)
no-2: n=2 (trits=2)
no-2: n=8 (trits=6)
brute: checked 0..20000, exceptions with n>8: 0
$ ./tree 20000
tree: N=20000 nodes=3905 maxdepth=21 small-leaves(r<=8)=3 failures=0
$ ./tree 1062882          # 2*3^12
tree: N=1062882 nodes=48929 maxdepth=36 small-leaves(r<=8)=3 failures=0
$ nice -n 15 timeout 30m ./tree 6973568802     # 2*3^20 ; real 0m2.293s
tree: N=6973568802 nodes=12585293 maxdepth=55 small-leaves(r<=8)=3 failures=0
exit=0
$ ./tree_neg 20000        # negative control: LIM=7, so n=8 must be caught
DEPTH LIMIT at r=8
tree: N=20000 nodes=4112 maxdepth=78 small-leaves(r<=8)=2 failures=1
neg exit=1
slow-path powmod cross-check vs Python pow (moduli 3^45, 3^62, 3^79; exponents up to 6973568802): OK
```
The search reaches depth 55 (moduli > 2^64), so the slow mulmod path was exercised and cross-checked.
Conclusion: independent brute force (8 < n <= 20000) and independent tree search (8 < n <= 2*3^20) find no
exception, agreeing with upTo_vardi. Exactly n = 0, 2, 8 lack a digit 2 in 0..20000.

pass: true
