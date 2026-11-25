# g005-R01: can pruning cut the NUMBER OF NODES of the low-digit residue tree? (Researcher/analyst)

Written 2026-11-25 (UTC). Branch `g005-R01` from `b0500ba`. Code: `search/g005-R01/` (exploration only, not results,
CONSTRAINTS rule 11). Raw outputs: `search/g005-R01/out/*.json`. Tables below are printed by
`python3 search/g005-R01/table.py`. All runs: nice 15, one core, under 1.5 GB RSS.
Labels follow CONSTRAINTS rule 3: KNOWN (with source), PROVED-HERE (complete paper proof, not formalised), HEURISTIC,
plus NUMERICAL (copied from command output, nothing proved). Nothing in this file is LEAN-VERIFIED.
No web page was fetched for this note: the only sources are the PDFs already stored in `specs/sources/`
(Saye 2022 `arxiv-2202.13256.pdf`, Dimitrov–Howe `arxiv-2105.06440.pdf`, Lagarias `arxiv-math0512006.pdf`) and the
existing summaries `specs/saye2022.md` and `specs/literature.md`.

Prediction recorded by the orchestrator: "at least one candidate with >= 10x fewer nodes at 2*3^20, or an honest negative".
**Outcome: honest negative.** No candidate cuts the node count asymptotically. The best real reduction
(scan + pre-test, about 6x fewer nodes than the CERT candidate count) is already in the Lean checker since g003.
For any certificate that uses only trailing digits there is a proved lower bound (section 2): the current checker is
already within a factor 2 of it. Combining leading digits gives at most 1.16x to 1.41x (NUMERICAL), and only if
emptiness is free (an oracle), which it is not. The way to M2 is cost per node (about 100x is left between the Lean
native checker and plain C, section 5), not node count.

## 1. Baseline: the shape of the tree (NUMERICAL, `tree_stats.py`)

`tree_stats.py K` simulates the CERT rules (verify/CERT.md) for N = 2·3^K. It counts every candidate
(alive, `N` leaf, `D` leaf, `E`) and records data for each single-member chain. Cross-checks: at K = 6 and K = 10 the
alive count and event count equal `verify/tree_ref.py` (260/516 and 3982/7960, exceptions {0,2,8}). At K = 20 the
candidate count, 12585293, equals the g004-A01 Lean `calls` count exactly; at K = 22 it is 50335868, also equal.
The leading-digit routine (`top_digits`, frac(r·log_3 2) with 60-digit `Decimal`) agrees with exact 2^r on the first
30 digits for all 800 tested r in [400, 6000) (`selftest_high.py`).

| K | baseline candidates | alive | N-leaves | D-leaves | multi-member alive | chains | lower bound 2^K-2 | baseline/(multi+chains) | baseline/lower bound | low trits/chain | top digits/chain | min(low,top)/chain |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 12 | 48929 | 16312 | 24427 | 8190 | 4096 | 4097 | 4094 | 5.972 | 11.95 | 2.981 | 3.080 | 1.813 |
| 13 | 97349 | 32452 | 48515 | 16382 | 8192 | 8193 | 8190 | 5.941 | 11.89 | 2.961 | 3.087 | 1.819 |
| 14 | 195800 | 65269 | 97765 | 32766 | 16384 | 16385 | 16382 | 5.975 | 11.95 | 2.983 | 3.075 | 1.802 |
| 15 | 393305 | 131104 | 196667 | 65534 | 32768 | 32769 | 32766 | 6.001 | 12.00 | 3.001 | 3.077 | 1.806 |
| 16 | 788447 | 262818 | 394559 | 131070 | 65536 | 65537 | 65534 | 6.015 | 12.03 | 3.010 | 3.078 | 1.801 |
| 17 | 1574138 | 524715 | 787281 | 262142 | 131072 | 131073 | 131070 | 6.005 | 12.01 | 3.003 | 3.074 | 1.801 |
| 18 | 3146285 | 1048764 | 1573235 | 524286 | 262144 | 262145 | 262142 | 6.001 | 12.00 | 3.001 | 3.079 | 1.801 |
| 19 | 6295229 | 2098412 | 3148243 | 1048574 | 524288 | 524289 | 524286 | 6.004 | 12.01 | 3.002 | 3.077 | 1.802 |
| 20 | 12585293 | 4195100 | 6293043 | 2097150 | 1048576 | 1048577 | 1048574 | 6.001 | 12.00 | 3.001 | 3.078 | 1.802 |
| 21 | 25170875 | 8390294 | 12586279 | 4194302 | 2097152 | 2097153 | 2097150 | 6.001 | 12.00 | 3.001 | 3.077 | 1.801 |
| 22 | 50335868 | 16778625 | 25168637 | 8388606 | 4194304 | 4194305 | 4194302 | 6.001 | 12.00 | 3.000 | 3.077 | 1.801 |

Definitions: *multi-member* alive node = class (k, r) with r + P_k ≤ N; *chain* = alive single-member class
(r ≤ N < r + P_k) whose parent is multi-member. "low trits/chain" = trits a scan reads from the chain start
upward, up to and including the first 2. "top digits/chain" = leading digits of 2^r read up to and including the
first 2.

Exact pattern seen at every K (PROVED-HERE for N = 2·3^K = P_{K+1}, from Saye Lemma 3.1 (KNOWN) as summarised
in specs/saye2022.md §2): every alive node at level k ≤ K is multi-member (r + P_k < 2P_k ≤ P_{K+1}), which gives
2^K − 1 nodes, plus the class r = 0 at level K+1. So multi = 2^K. The 2^K alive classes at level K+1 are
single-member except r = 0; its two children r = 0 and r = N give 2 more chains. So chains = 2^K + 1.
Baseline candidates ≈ 12·2^K: each chain of length L costs 3L + 1 candidates, and E[L] ≈ 3.

## 2. Proved lower bound for every trailing-digit certificate (PROVED-HERE)

**Setting.** A *trailing-digit certificate* for N is a finite set of leaves (p, c), where c is a residue mod P_{p+1}
and trit p (0-based) of 2^c is 2. Trit p of 2^n depends only on 2^n mod 3^{p+1}, hence only on n mod P_{p+1}.
So the leaf proves that trit p of 2^n is 2 for every n ≡ c. The certificate must cover every n ≤ N with
n ∉ {0, 2, 8}. The CERT tree, the scan variant, every per-level batching (candidate 2) and every early switch
(candidate 2') produce certificates of this kind.

**Claim.** Let Kf = max{k : P_k ≤ N} and F(N) = #{n ≤ N : trits 0..Kf−1 of 2^n contain no 2}. Then every
trailing-digit certificate has at least F(N) − 3 leaves. Also F(N) ≥ 2^{Kf−1}·⌊(N+1)/P_{Kf}⌋.

**Proof.** Take n ≤ N, n ∉ {0,2,8}, counted in F(N). Its covering leaf (p, c) has trit p of 2^n equal to 2, so
p ≥ Kf. Then P_{p+1} ≥ P_{Kf+1} > N, so the class c mod P_{p+1} contains at most one integer in [0, N]. Two
different such n therefore need different leaves. For the count: by Saye Lemma 3.1 (equivalently Lagarias
Thm 1.4's argument, KNOWN), exactly 2^{Kf−1} residues mod P_{Kf} have no 2 in trits 0..Kf−1, and [0, N] contains
⌊(N+1)/P_{Kf}⌋ disjoint full periods. ∎

For N = 2·3^K: Kf = K+1, F = 2^K + 1, so at least 2^K − 2 leaves. That is the "lower bound" column.
**Consequence:** at N = 2·3^20 no trailing-digit pruning of any kind can have fewer than 1048574 leaves, which is
12585293/12.00. Compared with the raw candidate count, the most any trailing-digit method can gain is 12.0x, and the
plain scan + pre-test variant already gains 6.0x (multi + chains = 2^{K+1} + 1). A further ≥ 10x is impossible
with trailing digits alone, at every K. The survivor counts are also rigid: inside full periods the number of
survivors after any number of trailing trits is exact (2 of 3 per level), not a statistical average. There is no
"lucky" class to cut.

## 3. Candidates, ranked by measured reduction relative to the current Lean checker (`fast` = pre-test + scan + table)

The unit of cost is the g004-A01 measure for `fast`: one unit per multi-member alive node and one per chain (scan).
For the current checker that is 2^{K+1} + 1 units (2097153 at K = 20).

### Rank 1 (already done): scan + pre-test, 6.0x vs CERT candidates. KNOWN in this repo (g003-L01, g004-A01)
Measured here: baseline/(multi+chains) = 5.94 to 6.02 for K = 12..22 (table above). It is constant in K and has
no asymptotic effect. In the Lean checker it gave about 3x time (g004-A01).

### Rank 2: joint trailing + leading digit tree (Lagarias's "combine the two approaches"), 1.16x to 1.41x. NUMERICAL, with an oracle
`joint.py K A0`. Every n ≤ N that survives A0 trailing trits is a point. A node is the set of points sharing a
pattern of a trailing trits and b leading digits of 2^n, with no 2 in either. A schedule picks, stage by stage,
whether the next split reads a trailing trit or a leading digit. Units are the same as above: a nonempty node with
≥ 2 members costs 1; a singleton costs 1 and is finished by a scan. **The emptiness of a child is taken as free.**
That is generous: for a leading-digit split, a certificate must prove that no member n = r + tP_a of the class has
frac(n·log_3 2) in the dead interval. Check: the "low" schedule reproduces the tree count exactly
(K = 12, A0 = 6: 8162 = 8193 − 31 nodes above level 6).

| K | A0 | low-only units | h1/4 | h1/3 | h1/2 | h2/3 | high | best ratio |
|---|---|---|---|---|---|---|---|---|
| 14 | 6 | 32738 | 27274 | 26481 | 28076 | 27907 | 27913 | 1.236 |
| 16 | 6 | 131042 | 109291 | 115543 | 113200 | 111974 | 109092 | 1.201 |
| 12 | 8 | 8066 | 7413 | 7119 | 6962 | 7383 | 7107 | 1.159 |
| 14 | 8 | 32642 | 27839 | 27434 | 27344 | 27945 | 27744 | 1.194 |
| 16 | 8 | 130946 | 107831 | 110218 | 111748 | 110063 | 92869 | 1.410 |
| 17 | 8 | 262018 | 217118 | 229516 | 224286 | 241414 | 194806 | 1.345 |
| 18 | 10 | 523778 | 435077 | 416017 | 455651 | 455898 | 460109 | 1.259 |

(hx = fraction x of splits on leading digits after the first A0 trailing trits; "high" = all leading.) The best ratio
moves between 1.16 and 1.41 with K and A0 and does not grow with K. Points within 1e-6 of a digit boundary in the
longdouble step: 6 to 21 per run (reported as `near_boundary`), too few to change the ratios.

Why it cannot grow (HEURISTIC): a leading digit also kills about 1/3 per digit (measured: the first digit is 2 for
36.9% of chains, i.e. 1 − log_3 2 = 0.369). At total depth s there are about min(2^s, N·(2/3)^s) nonempty nodes
however s is split between the two sides, because the two sides are uncorrelated (the open question in Lagarias
§1.6). That peaks at 2^{log_3 N} = N^{log_3 2} at s = log_3 N, exactly as the trailing-only tree does. A method that
beat this asymptotically would answer Lagarias's open problem ("Can one obtain an upper bound of O(X^β) for some
β < log3 2 in this way?", quoted in specs/literature.md §2) in the computational sense. I found no mechanism that
does.

Real cost: each leading-digit split needs frac(n·log_3 2) to about 3^{-(b+guard)} for n up to 6e21, so log_3 2 is
needed to about 35 decimal digits, and the emptiness/three-gap enumeration has to be computed. Per node this is far
more expensive than one modular multiplication. Projected to 2·3^46: at most 1.4x fewer units, each unit several
times dearer. Net slower. **Lean difficulty: medium-high.** Mathlib has `Real.log_two_near_10` and
`Real.log_three_near_10` (only 1e-10, in `Analysis/Complex/ExponentialBounds.lean`), the series lemma
`Real.abs_log_sub_add_sum_range_le` (`Analysis/SpecialFunctions/Log/Deriv.lean`), and `Real.rpow`/`Real.logb`
monotonicity. A 1e-35 enclosure of log_3 2 by the same series technique, plus a lemma "n·α ∈ [lo, hi] ⇒ leading digits
of 2^n are d", is about 1–3 weeks of work (estimate). Then every checked n needs rational interval arithmetic inside
native_decide. Not worth it for ≤ 1.4x.

### Rank 3: leading digits instead of trailing digits for single-member chains (candidate 1), 1.0x. NUMERICAL
For each chain the top digits of 2^r follow from frac(r·log_3 2). Fraction of chains killed by the top m digits
(K = 20, 1048577 chains): m = 1: 0.369, m ≤ 2: 0.535, m ≤ 3: 0.677, m ≤ 5: 0.853 (same at K = 12, 16, 22 to ±0.002).
Mean digits read: leading 3.08, trailing 3.00. Alternating trailing/leading: 3.00. Only an oracle that knows in
advance which side reaches a 2 first gives 1.80 (the min column). So the leading side is **not cheaper** than the
scan. It only replaces the scan's ~3 machine-word divisions with high-precision real arithmetic. The chain still costs
1 unit; the node count does not change. Lean difficulty as in rank 2, without any gain. **Reject.**

### Rank 4: batch handling of single-member classes, per level (candidate 2): 1.0x node count. HEURISTIC/structural
Batching changes the constant cost per chain (vectorisation, shared tables) but not the number of chains, which is at
least F(N) − 3 by section 2. The orchestrator can still use it as an engineering idea for per-node speed.

### Rank 5: early switch to per-member handling, threshold τ (candidate 2'): ≤ 1.0x, worse for τ ≥ 9. NUMERICAL (`tau.py`)
Units at K = 20: τ = 1: 2097153; τ = 2..6: 2097152 (only the class r = 0 with 2 members saves one unit); τ = 9: 2621438;
27: 3670008; 81: 5373926; 243: 7995312. Same pattern at K = 12, 14, 16, 18. The reason (HEURISTIC, consistent with the
data): a class with T members has a subtree of about T^{log_3 2} nodes, which is less than T. Expanding is always
cheaper than per-member work.

### Rank 6: Saye 2022 pruning we lack (candidate 3): none. KNOWN (specs/saye2022.md §2–3, Algorithm 1 re-read in `arxiv-2202.13256.pdf`)
Saye's only pruning is line 4 (d_k(2^j) = χ). It is the same tree. The extra work Saye does (line 1, a search for the
first χ digit at every node) is equivalent to our scan. His gains are engineering: fixed κ = 54-trit arithmetic in
three base-3^18 uint32 limbs, and one multiplication per child. He states the node count is Θ(2^K). Nothing to adopt
for node count; his per-node arithmetic is exactly what section 5 recommends.

### Rank 7: Dimitrov–Howe style mixed moduli (candidate 5): not applicable. HEURISTIC
Dimitrov–Howe (arXiv:2105.06440, read in `specs/sources/arxiv-2105.06440.pdf`, §2) sieve the equation
2^n = Σ_{i≤m} 3^{a_i} modulo M = 3^a·(primes with small orders), for a *fixed* number m ≤ 25 of summands. Modulo a
prime p ≠ 3 with ord_p(3) = d, a {0,1}-digit 2^n gives only Σ_j c_j 3^j with c_j = number of 1s in positions ≡ j
(mod d). The c_j are unbounded when the number of 1s is unbounded, so the congruence says nothing. The method needs
the bound on the number of 1s, and that is exactly what the general conjecture lacks. No later paper in
specs/literature.md §8 (Idowu 2610.03789, Roettger–Ren 2511.03861) has an algorithmic pruning.

## 4. Projected cost to N = 2·3^46 (K = 46). HEURISTIC extrapolation from the exact formulas above
* CERT candidates ≈ 12·2^46 ≈ 8.4e14; current-checker units = 2^47 + 1 ≈ 1.41e14 (exact formula for N = 2·3^K).
* Best measured node reduction beyond the current checker: ≤ 1.41x (joint tree, with an oracle), so ≥ 1.0e14 units.
* Lean native checker (g004-C02: about 9 CPU-years to 2·3^46): ≈ 9·3.15e7 s / 1.41e14 ≈ 2.0 µs per unit.
* Plain C probe (`search/g005-R01/scan_c.c`, gcc -O2, one core, `u128 %` arithmetic mod 3^40, NUMERICAL):
  17.9–21.3 ns per unit for K = 16, 20, 24, 26 (K = 26: 134217729 units in 2.405 s). It is not a checker: there is no
  fallback beyond 40 trits (345716 chains at K = 26 ran out of precision), so a real one needs 2 limbs. Extrapolated:
  1.41e14 × 18–40 ns ≈ 29–65 CPU-days (≈ 1–2.5 weeks on 4 cores). Saye's "a few days on 64 cores" for K = 46 (both
  conjectures) is of the same order (specs/saye2022.md §5).
* **So the gap to M2 is about 50–100x per node, in the Lean evaluation path, not in the node count.**

## 5. Recommendation for generation 6
1. Stop looking for node-count pruning in the trailing-digit tree. Section 2 is a proof that nothing beyond 2x
   (vs the current checker) is possible there. The joint idea is an open research problem (Lagarias §1.6) and gave
   ≤ 1.41x even with free emptiness tests.
2. Put both computational hypotheses on **cost per unit in the Lean-native checker**. The g004-A01/C02 diagnosis is
   that every `v * g mod 3^40` is a GMP bignum (3^40 > 2^63). Concretely:
   (a) residues in fixed `UInt64` limbs (base 3^19 or 3^20, as in search/c2/engine.c and Saye's base-3^18 uint32)
   with a soundness lemma `toNat (mulMod a b) = a.toNat * b.toNat % 3^L` (UInt64/`Nat` bridge lemmas: `UInt64.toNat_mul`
   and friends in core).
   (b) scan of trits out of one limb with `UInt64` div/mod by 3 (or 3^k block tests).
   Target: ≤ 100 ns per unit in native code, i.e. 2·3^46 in ≈ 160 CPU-days → 40 days on 4 cores. Getting closer to
   C's ~20–40 ns would give ≈ 1–2.5 weeks on 4 cores.
3. Optional theory-track item (cheap, A-tier): formalise section 2's lower bound (any trailing-digit cover needs
   ≥ F(N) − 3 leaves). It is elementary: residue periodicity + pigeonhole + the exact 2^{k−1} count already used in
   the Counting files. It documents why the tree is near-optimal. Its novelty is unchecked; it is probably folklore
   given Narkiewicz/Lagarias Thm 1.4.

## Files
* `search/g005-R01/tree_stats.py`: CERT simulation + chain statistics (leading digits by `Decimal`).
* `search/g005-R01/selftest_high.py`: leading-digit routine vs exact 2^r.
* `search/g005-R01/tau.py`: early-switch thresholds.
* `search/g005-R01/joint.py`: joint trailing/leading tree under schedules (numpy, longdouble).
* `search/g005-R01/scan_c.c`: C timing probe of the scan tree (not a checker).
* `search/g005-R01/table.py`: prints the tables in this file. `search/g005-R01/out/`: raw JSON and timings.
