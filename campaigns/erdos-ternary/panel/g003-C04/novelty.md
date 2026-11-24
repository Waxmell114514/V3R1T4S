# NOVELTY review: claim g003-C04

Skeptic role: NOVELTY. I read only `claim/CLAIM.md` (plus `roles/skeptic.md` for the role and the repo `AGENTS.md`).
Every source is saved under `sources/`. `sources/fetch_log.txt` records the UTC time, HTTP status, URL and sha256 of each one.
All fetches returned 200. No challenge pages and no 401, 403, 429 or 503 responses.

## What the claim says about novelty
It says nothing is new mathematically. 2*3^20 is Vardi's known bound, and the claim only upgrades the project's
evidence from tier B to tier A: a kernel-only Lean proof without native_decide.

## Checking the published bounds
- **Vardi.** MathWorld "Ternary" (`sources/mathworld_Ternary.html`) says: "Vardi (1991) verified that the only values of n for
  which 2^n has no 2 in its ternary expansion are 2 and 8 up to n=2·3^(20) approx 6.97×10^9". The source it cites is Vardi,
  *Computational Recreations in Mathematica*, pp. 20-25. This is a reliable secondary source. I did not fetch the book itself.
  The claim's description of Vardi's bound is correct.
- **Saye.** The abstract of arXiv:2202.13256 (`sources/arxiv_2202.13256.html`), a primary source published in J. Integer Seq. 25 (2022) 22.3.4, says:
  "we verify both conjectures for all 2^n with n ≤ 2·3^45 ≈ 5.9×10^21". erdosproblems.com/406 (`sources/erdosproblems_406.html`) says the same
  ("16 ≤ n ≤ 5.9×10^21"), and so does OEIS A102483 (`sources/oeis_A102483.txt.fmt`).
- **The claim's 2*3^20 lies far below the published frontier**, so the range it covers is already known to hold.
  Stating that as "not new" is honest.
- **Statement match.** UpTo N ("2^n has a digit 2 for 8 < n ≤ N") is the Erdős–Graham form that MathWorld gives. erdosproblems #406 asks a
  related question: are there finitely many 2^n with digits only 0 and 1? The claim's UpTo is consistent with that
  page. It does not claim to settle #406.

## Prior formal (kernel-checked) work
I searched GitHub code with gh for: erdos_406, Erdos406, `Nat.digits 3 (2 ^`, "2 * 3 ^ 20", Vardi, ternary in Lean, Coq and Isabelle,
and mathlib4. Results:
- **google-deepmind/formal-conjectures `ErdosProblems/406.lean`** (`sources/fc_406.lean`). It states `erdos_406` (finiteness of 2^n with
  digits in {0,1}) and the variant that 2^15 is the largest with digits in {1,2}. Both are `sorry`. It has no finite-range verification.
  `OEIS/104320.lean` (`sources/fc_OEIS_104320.lean`) proves only a(0)..a(4) by `decide`, and its conjecture is `sorry`.
- **google-deepmind/cryptids** (`sources/cryptids_ErdosTernary15.lean`, `sources/cryptids_RELATED_WORK.md`, `sources/cryptids_erdos_ternary_14_README.md`).
  It has Lean 4 proofs that the Stérin–Woods 15-state Turing machine, and Stérin's 14-state machine (Oct 2026), halt iff some 2^n
  with n>8 has no ternary digit 2. These are formal reductions of the conjecture, not verifications over a finite range.
  The claim does not contradict them, but they are prior formal work on this exact statement.
- **competemath/tengoku `GKPCarry/DensityOne.lean`** (`sources/tengoku_DensityOne.lean`) is a Lean density-one theorem about ternary
  carries of powers of two. It is not a finite-range check.
- **kyo-oo/erdosternary2** (`sources/kyo-oo_erdosternary2_README.md`) claims "PROVEN". Its own README reports 2 remaining errors and 1 admit, so
  it is not a credible proof. GitHub code search found no finite-range `decide` or `native_decide` result there, but the repo may not be indexed.
- **Mathlib**: no matching theorem (the code search returned 0 hits).
- **Not checked**: Lean Zulip, which has no public search I could use without logging in. The arXiv sweep covering the last 24 months was not exhaustive.

I found no public kernel-checked proof (Lean, Coq, Isabelle or HOL) of the conjecture for any finite range up to 2*3^20.
This upgrade may therefore be new as a formal artefact. The claim does not assert that formal novelty, and since my search was incomplete
it should not assert it.

## Verdict
The claim correctly calls the bound known, credits Vardi, and states nothing new beyond the formal tier upgrade. One optional
suggestion: also cite Saye's 2·3^45 and the cryptids Lean reductions as context.

pass: true
