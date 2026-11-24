# Lean audit g003-C04

Auditor: independent Lean auditor (fresh context). Worktree branch g003-C04 @ 5a7b0f7.
Files read: lean/ErdosTernary/CheckerKernel.lean, CheckerKernelUpTo{16,18,20}.lean, Checker.lean (lemmas used),
lean/ErdosTernary.lean, lean/lakefile.toml, verify/Statement.lean, verify/lean_audit.py, tools/gen_kernel_upto.py (untrusted, structure only).

## Claims
1. `CheckerKernel.checkK_sound : checkK N K = true → UpTo N` (tier A).
2. `upToK_16 : UpTo (2 * 3 ^ 16)`, `upToK_18 : UpTo (2 * 3 ^ 18)`, `upToK_20 : UpTo (2 * 3 ^ 20)`, each tier A, kernel evaluation only.

## Commands and output
- `python3 tools/check_lock.py` -> `LOCK: OK`
- `lake build ErdosTernary.CheckerKernel` -> `Build completed successfully (2141 jobs).` (249 s, incl. dependency replay)
- `lake build ErdosTernary.CheckerKernelUpTo16/18/20` -> `Build completed successfully (2143 jobs).` (oleans were already cached by lake; trace hashes match sources, 1 s each)
- Independent re-elaboration without the cache (`lake env lean ErdosTernary/CheckerKernelUpTo{16,18,20}.lean`): see section below.
- `lean_audit.py ErdosTernary.CheckerKernel ErdosTernary.CheckerKernel.checkK_sound`
  -> `LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']`
- `lean_audit.py ErdosTernary.CheckerKernelUpTo16 ErdosTernary.upToK_16 --expect UpTo:2*3^16`
  -> `LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']`
- same for 18 (`--expect UpTo:2*3^18`) -> `LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']`
- same for 20 (`--expect UpTo:2*3^20`) -> `LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']`
- Only WARN printed: `ErdosTernary/Checker.lean: native_decide` — this is the pre-existing tier-B `Checker` theorem (line 128),
  not used by any audited theorem (the axiom lists above contain no `ofReduceBool`/native axioms).

## Code review
- Statements: `checkK_sound {N K} (h : checkK N K = true) : UpTo N`; `upToK_k : UpTo (2 * 3 ^ k)` with `UpTo` the frozen
  definition from verify/Statement.lean (`∀ n, n ≤ N → 8 < n → 2 ∈ Nat.digits 3 (2 ^ n)`, Statement.lean hash-locked, LOCK OK).
  `--expect` confirms the types elaborate against the frozen `UpTo`. No redefinition of UpTo/Statement (audit scan forbids it).
- `exploreK` is a plain structurally recursive `def` on fuel (no partial/opaque/implemented_by/extern/csimp); `checkK` uses
  modulus `3^K`. `exploreK_sound` is proved by induction on fuel with invariants q = 3^i, m = 2^r % M, g = 2^(2·3^i) % M,
  3^(i+fuel) ∣ M; three success cases handled (r > N via omega; trit i = 2 via `Checker.two_mem_digits_of` + `pow_class_mod`;
  r ≤ 8 with only one member ≤ N), recursive case splits t by t % 3 to the three children. Fuel-out returns false (harmless).
- Assembly: `exploreK_of_children` is a proved theorem (`rw [exploreK, ha, hb, hc]; simp`), requiring all three child proofs
  `ha hb hc` with exactly the children's arguments (3q; r, r+2q, r+4q; m, m·g%M, m·g%M·g%M; g³%M). `checkK_of_roots` (proved, `rfl`)
  needs both roots. Each generated theorem has an explicit statement; every inner node is `exploreK_of_children ... name_0 name_1 name_2`,
  so the kernel type-checks each child's stated type against the parent's required child type (defeq up to numeral arithmetic).
  No subtree can be skipped: an omitted/mismatched child is a type error. Root `n_k_1` (r=1, odd) is decided directly.
- Generated files contain only lines of the form `theorem n.. : exploreK <numerals> = true := by decide +kernel` or
  `:= exploreK_of_children <numerals> n.._0 n.._1 n.._2`, plus header/namespace/final theorem (checked by grep filter: no other lines).
  Counts: 16: 64 leaves/31 assembly; 18: 256/127; 20: 1024/511 (match headers).
- grep over CheckerKernel*.lean, Checker.lean, ErdosTernary.lean for native_decide, set_option, attribute, @[, opaque,
  implemented_by, extern, axiom, sorry, macro, notation, instance, `decide :=`, unsafe, partial, csimp: none in CheckerKernel*
  files (no set_option at all, no maxRecDepth/maxHeartbeats). Only hit in Checker.lean is the unrelated tier-B native_decide.
- Note: lean/ErdosTernary.lean imports CheckerKernel and CheckerKernelUpTo16 only (18/20 are separate targets); not an issue.

## Independent sanity (own Python, scratchpad tree.py mirroring exploreK, K=64, M=3^64)
- 2*3^20 = 6973568802 (True); 3^64 = 3433683820292512484657849089281 matches the numeral in the files.
- Node counts: 2*3^16 -> 788447, 2*3^18 -> 3146285, 2*3^20 -> 12585293; all true; max depth 42/55/55 < 64.
  These equal the generator's stated tree sizes.

## Hypothetical deviation
If the assembly lemma were assumed (axiom) or a child could be omitted, a subtree containing a counterexample n ≤ 2·3^20
would go unchecked and `UpTo (2*3^20)` could be "proved" while false. Ruled out: lemma is proved, axioms are tier A, each
inner node consumes exactly three typed child proofs. If `UpTo` used n < N instead of n ≤ N, N itself would be missing; the
frozen definition uses `≤` and checkK_sound covers all n ≤ N.

## Re-elaboration
Uncached `lake env lean` re-elaboration results so far: CheckerKernelUpTo16 rc=0 66 s; CheckerKernelUpTo18 rc=0 224 s; CheckerKernelUpTo20 rc=0 917 s (all three kernel-rechecked without cache).

## Verdict
All claims verified: checkK_sound and upToK_16/18/20 tier A, statements match frozen UpTo, assembly proved and complete, no native_decide/set_option/opaque/implemented_by in the audited files.

pass: true
