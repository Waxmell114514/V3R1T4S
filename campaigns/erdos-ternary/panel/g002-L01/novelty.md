# NOVELTY skeptic report, claim g002-L01

Read: claim/CLAIM.md, claim/Statement.lean (Checker.lean only listed). Sources fetched into sources/ and
logged in sources/FETCHLOG.txt (UTC date, HTTP status, sha256, URL). Every fetch returned 200. The directory was
empty before this run. The GitHub REST API refused one metadata query for kyo-oo/erdosternary2 with HTTP 403, so
I made no more API calls for that repo and read only its README over raw.githubusercontent (200).

## Published bounds (framing check)
- Vardi 1991: CRC Concise Encyclopedia entry "Ternary" (sources/crc_t088.html) says Erdős and Graham (1980)
  conjectured the statement and that it was checked "by Vardi (1991) up to n = 2·3^20". It cites Vardi, "The
  Digits of 2^n in Base Three", Computational Recreations in Mathematica, pp. 20-25. I did not get the book itself,
  so this rests on a secondary source. Saye's paper gives the same bound.
- Saye 2022, arXiv:2202.13256 (sources/arxiv_2202.13256.html, abstract) checks both the Erdős and the Sloane
  conjectures "for all 2^n with n ≤ 2·3^45 ≈ 5.9×10^21". The JIS version (sources/saye_jis.html) matches.
  erdosproblems.com/406 (sources/erdosproblems_406.html) also cites Saye for every ternary digit with
  16 ≤ n ≤ 5.9×10^21.
- CLAIM.md says exactly this: the bound 2·3^20 is Vardi's known bound, Saye went to 2·3^45, and the claim is a
  formal re-verification, not a new mathematical result. It claims nothing as new that is already known. The
  framing is accurate.

## Prior formal (Lean/Coq/Isabelle) work
- google-deepmind/formal-conjectures:
  - ErdosProblems/406.lean (sources/fc_406.lean) states a related form: finitely many powers of 2 with digits in
    {0,1}, plus a variant for digits {1,2}. It has `sorry` and no finite verification.
  - Arxiv/2107.12475/CollatzLike.lean (sources/fc_CollatzLike.lean) states the exact conjecture,
    `∀ n > 8, 2 ∈ Nat.digits 3 (2^n)`, with `sorry`. Its only computation is the `n = 8` test lemma (`norm_num`).
- google-deepmind/cryptids (sources/cryptids_*.lean): ErdosTernary15/14 prove in Lean that a Turing machine
  halts iff the conjecture is false. Propositions.lean defines `ErdosTernaryConjecture` identically to
  Statement.lean. I found no theorem for a finite range (no UpTo-style bound).
- kyo-oo/erdosternary2 (sources/kyo_erdosternary2_README.md) is a Lean workspace. Its README claims a full proof
  but admits "2 errors remained" and 1 `admit`. It is not a credible checked result and states no finite bound.
- GitHub code search: no Coq or Isabelle hits. A web search found no Lean Zulip thread and no Mathlib result on a
  machine-checked finite verification of this conjecture.

As far as this search goes, no earlier machine-checked proof of UpTo(2·3^20), or of any comparable finite bound,
is known. The claim makes no novelty assertion either way, so this does not affect the verdict. Calling it a
"formal re-verification" is accurate.

## Verdict
The framing is honest: the bound is correctly credited to Vardi (1991), Saye's larger 2·3^45 is acknowledged, and
nothing already known is claimed as new.

pass: true
