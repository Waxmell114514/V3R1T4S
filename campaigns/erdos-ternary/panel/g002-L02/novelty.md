# Skeptic NOVELTY: claim g002-L02

Role: NOVELTY (roles/skeptic.md). Input read: only `panel/g002-L02/claim/CLAIM.md`, including Revision 2.
Claim under test: for every integer X >= 0, A(X) := #{0 <= n <= X : 2^n has no ternary digit 2} <= (X+1)^{log_3 2}.
The constant is 1, and it is optimal in this (X+1)-normalized form.

Verdict: **NOT FOUND**, so the claim survives this check, with the access gaps listed under "Not reached".

## Sources and fetching
All sources were fetched by me in this run, into `panel/g002-L02/sources/novelty/`. Each fetch is logged in
`sources/novelty/FETCH_LOG.tsv` with the UTC time from `date -u`, the HTTP status, the sha256, the file name and the URL.
I used one plain curl request per page, with no browser impersonation. I did not use the files the interrupted
earlier run left in `sources/`, and I did not read any other panel files.

## What the literature states (checked in the fetched texts)
| Source | Statement on the count | Constant in the (X+1)^a form |
|---|---|---|
| Narkiewicz 1980, Publ. Elektroteh. Fak. Beograd 678-715, 173-174 (Zbl 0457.10003, MR 623247). I did not see the original. | N(X) <= 1.62 X^a, a = log_3 2. Quoted this way by Lagarias 2009, erdosproblems #406, Zhao-Li 2024/25 and Li-Zhao 2026. | > 1 |
| Kennedy-Cooper 2000, Publ. Elektroteh. Fak. Ser. Mat. 11, 36-40 (Zbl 0999.11008, review text). This is a general result for any base b and any a with gcd(a,b) = 1, about "large" digits (those >= b/2). | S(x) <= beta (b(1-theta)/(theta phi(b)))^theta (1/(1-theta)) x^theta. With b = 3 and a = 2 this gives a constant of about 2.49. | > 1 |
| Lagarias 2009, "Ternary expansions of powers of 2" (arXiv math/0512006v4), Thm 1.4 and its proof. Covers every nonzero 3-adic lambda. | #{n <= X : lambda 2^n omits 2} <= 2 X^a for X >= 2. The proof gives 2^{1-a} X^a (about 1.29), and counts only n >= 1. | > 1 |
| Holdum-Klausen-Rasmussen, Integers 15 (2015) #A43 (also arXiv 2601.09510v1). **Real title: "Powers in prime bases and a problem on central binomial coefficients".** | Thm 2.13: for alpha ≡ 2 (mod 3) and every a in N, S_3^1(a) = #{0 <= s < a : (alpha^s)_3 has no digit >= 3/2, i.e. no digit 2} <= 1.3 a^a. The proof gives 2·2^{-a}, about 1.29. Thm 2.14 (any prime p): S_p^1(a) <= 4 a^{log_p((p+1)/2)}. Lemma 2.12: S(s θ p^t) <= s θ ((p+1)/2)^t. | 1.3 (1.29 in the proof); 4 for general p |
| Zhao-Li, arXiv 2405.06220v2 (published 2025, Zbl 1578.11014, reviewed by Narkiewicz). A general result for number fields, any base and any omitted digit. | M_b(alpha,beta,N) <= C_1 N^{sigma(beta)}. C_1 depends only on beta and is not given; it is C_0 |N(beta)|^sigma. Cor. 1.9 covers rational p, q with some effectively computable C. | not given; not 1 |
| Li-Zhao, arXiv 2601.12753 (2026) | Equidistribution and complexity results; no counting constant beyond quoting Narkiewicz's 1.62. | none |
| Saye 2022 (arXiv 2202.13256, JIS 25, 22.3.4) | Computation only: verifies the conjecture for n <= 2·3^45 ≈ 5.9e21. No counting bound. | none |
| Dimitrov-Howe, arXiv 2105.06440 | About powers of 3 with few nonzero bits; cites Narkiewicz but states no counting bound. | none |
| Abram-Lagarias, arXiv 1308.3133 (the [AbLa14] linked from #406) | Hausdorff dimension of 3-adic intersections; no bound of this kind. | none |
| Ren-Roettger, arXiv 2511.03861 "Ternary digits of powers of two" | Digit frequencies and normality heuristics; no bound. | none |
| Idowu, arXiv 2610.03789 (Sept 2026) | Exact finite-depth count: the admissible residue classes mod 3^m number exactly 2^m (Cor. 4.7, 5.4); a binary tree of lifts. No bound on A(X) at an arbitrary X. | none |
| erdosproblems.com/406 page and its forum thread (5 comments, last edited 13 Apr 2026) | States only Narkiewicz's 1.62 x^a. Links La09, AbLa14, Sa22, Dimitrov-Howe, Dupuy-Weirich and OEIS A351928. | > 1 |
| google-deepmind formal-conjectures, ErdosProblems/406.lean | Only the open finiteness statement and the {1,2} variant; no counting lemma. | none |
| OEIS A351928, A102483; searches "erdos ternary powers of 2 digit 2" and "0,2,8 2^n base 3" | Nothing about a counting bound. No OEIS entry found for the list n = 0, 2, 8. | none |
| MathOverflow, via the StackExchange API: "Narkiewicz", "ternary expansion 2^n", title contains "ternary" | Nothing relevant. The closest is Q30357, which asks for a *lower* bound on nonzero digits. | none |
| arXiv API, mostly 2024-2026, sorted by date: abs:ternary AND "powers of two"; Erdos AND ternary; "powers of 2" AND "base 3"; ti:digits AND ti:powers; omit AND digit AND powers; authors Dimitrov-Howe, Abram-Lagarias, Dupuy-Weirich (the last returned no entries) | No paper with constant 1 and no paper with any (X+1)^{log_3 2} bound with a constant below 1.29. | none |

## Could a known result imply the claim?
I checked the obvious routes, and none of them gives it.
- **A full-period count.** Lagarias, HKR Lemma 2.12 and Idowu all give exactly 2^k admissible n in one period of
  length 2·3^k. At X+1 = 2·3^k this gives A(X) <= 2^k, and the claim also follows there because
  (2·3^k)^a = 2^a·2^k > 2^k. For intermediate X, though, the monotone extension used by HKR and Lagarias only gives the
  constant 2^{1-a} ≈ 1.29. Getting 1 needs a separate argument, such as the claimant's induction with concavity, and I
  found that argument stated nowhere.
- **General-base theorems.** Kennedy-Cooper, HKR Thm 2.14 and Zhao-Li Thm 1.5/1.8/Cor 1.9 all have constants that are
  > 1 or not specified. None of them specializes to 1 at b = 3, a = 2.
- **Computation plus a bound.** Saye's computation gives A(X) = 3 <= (X+1)^a for 5 <= X <= 5.9e21. For larger X, the
  known bounds (1.3, 1.62, 2) are weaker than (X+1)^a. Counting from 0 cannot be split into windows with any stated
  result. So no combination of published facts I found gives the claim for every X.

## Not reached (marked PENDING; these limit the verdict)
- **zbmath.org/?q=an:0457.10003.** HTTP 403 challenge page. The zbMATH API record for Narkiewicz 1980 has no review
  text. → PENDING.
- **MathSciNet MR 623247 (Narkiewicz review).** Login wall / JS-only page (HTTP 200). → PENDING.
- **Narkiewicz's original 2-page note.** Not found online. Every secondary source, including Narkiewicz's own 2025
  zbMATH review of Zhao-Li, reports only 1.62 X^a. A sharper (X+1)^a form with constant 1 there is therefore very
  unlikely but **unverified**.
- **Schinzel, "The work of Władysław Narkiewicz in number theory", Funct. Approx. 39 (2008) 7-18**
  (doi 10.7169/facm/1229696551). Incapsula challenge page. The zbMATH record withholds its content. → PENDING.
- **Guy, UPNT B33.** Not accessible. erdosproblems says it mentions Narkiewicz's result.
- **Further arXiv API queries** (all:Narkiewicz; ternary AND Erd*; "large digits"). HTTP 429; I stopped. → PENDING.
- **One MathOverflow API query.** Returned a throttle error, after which I used rephrased queries.
- **Dupuy-Weirich 2016.** Not fetched. The #406 forum describes it as an averaged equidistribution result, not a
  counting constant.

## Conclusion
In every source I reached, the best stated constant in the (X+1)^{log_3 2} normalization is 1.3 (HKR Thm 2.13; its
proof gives about 1.29). Lagarias states 2 and Narkiewicz, as quoted, 1.62, both against X^{log_3 2}. The general-base
theorems give constants that are larger or not specified. None states or implies constant 1, and the sharpness
statement does not appear either. The verdict rests on secondary quotations of Narkiewicz 1980, because the original,
its MR review and Schinzel's survey could not be reached.

pass: true
