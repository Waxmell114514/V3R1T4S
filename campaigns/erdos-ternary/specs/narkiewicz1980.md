# g002-R03 Narkiewicz 1980 核查与候选命题新颖性（Researcher）

写于 2026-11-24（UTC）。抓取记录见文末附录（URL、`date -u` 时间、HTTP 状态、`sha256sum`），
原始文件按抓取原样保存在 `specs/sources/`。级别标记遵循 CONSTRAINTS.md 第 3 条；
"未核实" = 本人没有打开一手原文。

记号：α0 := log_3 2（`python3` 输出 0.6309297535714574）；
A(X) := #{0 ≤ n ≤ X : 2^n 的三进制展开不含数字 2}（含 n = 0）。

---

## 1. 引文核实（KNOWN，两个独立书目来源一致）

- zbMATH Zbl 0457.10003（打开，HTTP 200）："Narkiewicz, W. A note on a paper of H. Gupta concerning powers of two and three.
  (English) Publ. Elektroteh. Fak., Univ. Beogr., Ser. Mat. Fiz. 678-715, 173-174 (1980)"。MSC 11A41, 11N05。
- MR Lookup（打开，HTTP 200）：MR623247，NUMBER = {678-715, 678}，YEAR = {1980}，PAGES = {173--174 (1981)}，
  ISSN 0522-8441，MRCLASS 10A30 (10L10)，MRREVIEWER = John T. Hardy。完整标题带副标题：
  "…: ``Powers of 2 and sums of distinct powers of 3'' [Univ. Beograd. Publ. Elektrotehn. Fak. Ser. Mat. Fiz. No. 602-633 (1978),
  151--158 (1979); MR 81g:10016]"。
- 结论：题目中是 "powers of two and three"（文字），No. 678–715，pp. 173–174，标 1980 年、实际 1981 年印出。
  MR 评论正文（Hardy）需要订阅，**未打开**。

## 2. 原文获取：PENDING

- JSTOR 检索页：HTTP 200 但内容是 "Client Challenge … JavaScript is disabled"（反爬挑战页），按规则停止，未重试。
- pefmath.etf.rs：TLS 失败（"no alternative certificate subject name matches target host name"），服务器证书问题，
  未绕过（不得关闭证书校验）。
- eudml.org：TLS 失败（"certificate has expired"），同上未绕过。
- **Narkiewicz 原文未打开，状态 PENDING。** 下面关于陈述和方法的内容全部来自二手来源。

## 3. 陈述（KNOWN，作者自撰摘要）

zbMATH 页面给出的是扫描的 1981 年 Zentralblatt 印刷版（`/scans/457/052.gif`，已存档并用眼睛读过），
条目末尾署 **"From the paper."**，也就是作者本人的摘要，不是评论者的转述。扫描原文：

> "The aim of this note is to observe that a simple counting argument shows that there cannot be very many such integers m.
> More precisely we prove the following evaluation: Theorem. If N(T) denotes the number of nonnegative integers m ≤ T with the
> property that 2^m can be written as a sum of distinct powers of 3, then N(t) ≤ 1.62 T^{log 2/ log 3} and in particular the
> density of the set of such m's is zero."

（网页上 MathPix 转写成 "1.62 T^{108} 2 / log_3"，是 OCR 错误；扫描图上是 T^{log 2/log 3}。）

- **不等式**：N(T) ≤ 1.62 T^{log 2/log 3}，N(T) 计数**非负**整数 m ≤ T（含 m = 0），所以 N = A。
- **T 的范围**：摘要没有写限制（"N(t)" 与 "T" 混用，大概是排版错误）。T = 0 时 N(0) = 1 > 0，所以实际只能对 T ≥ 1
  （或 T 不太小）成立；原文怎么写的**未核实**。没有"充分大"之类的限定词。
- 另：摘要说 Gupta 证明了在区间 "(8, 4734)" 内无解；Lagarias 2009 写的是 "n < 4374"。两处不一致，原文未核实。

## 4. 方法：是否就是低位剩余类论证？——PROBABLY YES（二手一致，原文未核实）

证据（都已打开）：
1. **Lagarias 2009**（arXiv:math/0512006v4，§1.3）："an upper bound … valid for all nonzero λ ∈ Z3, which extends the result of
   Narkiewicz [18] for λ = 1, using essentially the same proof." 他对 Thm 1.4 的证明（§3）原文：
   "The proof is based on the fact that 2 is a primitive root (mod 3^k) for each k ≥ 1. … runs over all 2·3^{k−1} invertible residue
   classes (mod 3^k). Of these, exactly 2^{k−1} residue classes have a 3-adic expansion that omits the digit 2. Now, given X, pick that k
   such that 2·3^{k−2} < X ≤ 2·3^{k−1}. … Ñλ(X) ≤ 2^{k−1} = 2·2^{k−2} = 2·3^{α0(k−2)} = 2^{1−α0}(2·3^{k−2})^{α0} ≤ 2X^{α0}"。
   （注意 (3.2) 中计数的是 1 ≤ n ≤ X，而 (1.9) 写的是 n ≤ X。）
2. **作者摘要**："a simple counting argument"。
3. **Kennedy–Cooper 2000**（Zbl 0999.11008 评论，打开）："The method of W. Narkiewicz … is generalized"；推广后的界含 φ(b)、
   "小"既约剩余数 β、指数 θ = log((b+1)/2)/log b（评论里印成 "20 log"，应是 OCR 错误）。这些量正是"模 b^k 的周期 φ(b^k)，
   低 k 位只含小数字的既约剩余类个数 β·((b+1)/2)^{k−1}"的计数结构。
4. **Holdum–Klausen–Rasmussen 2015**（Integers 15, A43；arXiv:2601.09510v1，打开全文）：用周期性 + 剩余类计数
   （Lemma 2.12）"improves a result by Narkiewicz [8] by a constant factor"。

**1.62 是怎么来的：未核实。** 我用 `python3` 算了几种自然的取法，都得不到 1.62：
- 朴素论证（取最小 k 使 X < 2·3^{k−1}）给出 2^{1−α0} = 1.2915202343301952；
- 连续优化 2^{k−1}(X/(2·3^{k−1}) + 1)（k 当作实数）给出 1.2474878579731206；k 取整数、X > 100 时上确界为 1.29151491790696；
- Kennedy–Cooper 公式按评论原样代入 b = 3、β = 1、φ = 2 得 2.494975715946241（大于 1.62，可能评论转写有缺漏，未核实）。
因此 Narkiewicz 的取整或分段方式比 Lagarias 的写法粗；具体细节要等原文。

## 5. 小规模事实（`python3` 实际输出，n ≤ 2999）

- 满足条件的 n：[0, 2, 8]。A(0)=1，A(1)=1，A(2)=2，A(8)=3，A(2999)=3。
- max_{1≤X≤2999} A(X)/X^{α0} = 1.2915202343301952，在 X = 2 取到（= 2^{1−α0}，因为 A(2) = 2）。
- max_{0≤X≤2999} A(X)/(X+1)^{α0} = 1.0，在 X = 0 和 X = 2 取到（A(2) = 2 = 3^{α0}）。
- 推论（PROVED-HERE，平凡）：若计入 n = 0，**形如 C·X^{α0}（对所有 X ≥ 1）的界不可能有 C < 2^{1−α0} ≈ 1.2915**；
  形如 C·(X+1)^{α0} 的界不可能有 C < 1。所以"常数改进"在全范围意义下已经到头，只有渐近常数 limsup A(X)/X^{α0} 还有空间
  （而由 Saye 2022 的计算，A(X) = 3 对 8 ≤ X ≤ 2·3^45；这是计算结果，不是证明里能用的渐近信息）。

## 6. 候选命题的新颖性判定

**(a) 对所有 k ≥ 1 及 0 ≤ X < 2·3^{k−1}，A(X) ≤ 2^{k−1}。——KNOWN。**
- Holdum–Klausen–Rasmussen 2015，Lemma 2.12：S_p^1(s γ p^t) ≤ s θ ((p+1)/2)^t，其中 S_p^1(a) = #{0 ≤ s < a : (α^s)_p 无大数字}。
  取 p = 3、α = 2（γ = ord_3 2 = 2，θ = 1）、s = 1、t = k−1：#{0 ≤ n < 2·3^{k−1}} ≤ 2^{k−1}；再用单调性（原文
  "S_3^1 clearly is weakly increasing"）即得 (a)。
- Lagarias 2009 Thm 1.4 证明中的 (3.3) 与下一句（λ = 1）：一个完整周期 2·3^{k−1} 内恰有 2^{k−1} 个 n 使低 k 位不含 2。
  （他写的是 1 ≤ n ≤ 2·3^{k−1}；对 0 ≤ n < 2·3^{k−1} 同样是一个完整周期，结论相同。）
- 很可能也就是 Narkiewicz 原文的核心步骤（未核实，见 §4）。

**(b) A(X) ≤ 2(X+1)^{α0}。——KNOWN（被更强结果直接蕴含）。**
- Holdum–Klausen–Rasmussen 2015 **Theorem 2.13**（原文）："Let α ≡ 2 (mod 3) in the definition of S. For every a ∈ N we have
  S_3^1(a) ≤ 1.3 a^{log_3(2)}." 取 a = X+1：A(X) ≤ 1.3 (X+1)^{α0} ≤ 2(X+1)^{α0}。
- 另见 Lagarias 2009 Thm 1.4：对 X ≥ 2，Ñ_1(X) ≤ 2X^{α0}（形式略有不同）。

**(c) A(X) ≤ (X+1)^{α0}（对所有 X ≥ 0）。——NOT FOUND。**
- 在打开的所有来源里，已发表的最好常数是：Narkiewicz 1.62（X^{α0} 形式）、Lagarias 2（X ≥ 2）、
  Holdum 等 1.3（(X+1)^{α0} 形式，证明里实际是 2^{1−α0} ≈ 1.2915）。Zhao–Li（arXiv:2405.06220v2，2025-12-04；
  Quaest. Math. 48 (2025)）原文仍说 "The best known bound on M(N) is due to Narkiewicz … M(N) ≤ 1.62 N^σ"，
  他们没有提到更好的常数（而且似乎忽略了 Holdum 等的 1.3，尽管引用了这篇文章）。
- 常数 1 在 (X+1) 形式下是最优的（X = 0、2 时取等号，见 §5）。由于 (X+1)^{α0}/X^{α0} → 1，(c) 给出
  limsup A(X)/X^{α0} ≤ 1，渐近上严格好于 2^{1−α0}；单纯的"一个周期内 2^{k−1} 个剩余类"论证在 X 略大于 2·3^{k−2} 时只能给出
  2^{1−α0}，所以 (c) 需要剩余类在 [0, 2·3^{k−1}) 内部的分布信息（树结构 / Saye 式递归），不是现有论证的直接推论。
- 保留意见：Narkiewicz 原文与 MR 评论（Hardy）都没有打开；但作者自撰摘要明确写的常数是 1.62，原文给出常数 1 的可能性很小。
  zbMATH 记录的 4 篇引用文献（Zhao–Li 2025、Holdum 等 2015、Schinzel 2008 综述、Kennedy–Cooper 2000）中，
  Schinzel 综述没有打开；Kennedy–Cooper 只看了评论。

**(d) C·X^{α0} 中任何小于 1.62 的常数。——KNOWN。**
- 1.3：Holdum–Klausen–Rasmussen 2015 Thm 2.13（(X+1)^{α0} 形式；对 X ≥ 1，(X+1)^{α0} ≤ 2^{α0}X^{α0}，换算到 X^{α0} 形式只得
  1.3·2^{α0} ≈ 2.01，所以 X^{α0} 形式要另看下一条）。
- 2^{1−α0} ≈ 1.2915：Lagarias 2009 Thm 1.4 证明的倒数第二步 "2^{1−α0}(2·3^{k−2})^{α0}"，配合 2·3^{k−2} < X，直接得到
  Ñ(X) ≤ 2^{1−α0} X^{α0}（他只写成 ≤ 2X^{α0}，所以说"隐含于证明"）。含 n = 0 时同样成立（取最小 k 使 X < 2·3^{k−1}），
  而且由 §5，这个常数对所有 X ≥ 1 而言是最优的（X = 2 取等号）。
- 因此"在 X^{α0} 形式下把 1.62 改小"不是新结果；对所有 X 成立的形式里也没有低于 1.2915 的余地。可能有新意的只有渐近形式
  limsup ≤ C < 1.2915，也就是 (c) 那一类命题。

## 7. 对理论轨道的提示

- literature.md §10 排名 1 的"新颖性"段落应更新：常数 1.62 → 1.3/1.2915 已发表（Holdum 等 2015；Lagarias 2009 隐含）；
  (a)(b)(d) 不能作为新结果。只有 (c)（或任何 limsup 常数 < 2^{1−α0} 的结果）在检索范围内没有找到。
- 形式化建议：(a) 是 (c) 的必要引理，可以作为 KNOWN 的 Lean 定理（引 Holdum Lemma 2.12 / Lagarias Thm 1.4 证明）；
  成果陈述应选 (c)，并在文中标注 "constant 1 optimal at X = 2"。

---

## 附录：抓取记录（每页一次请求；curl 默认 User-Agent；时间来自 `date -u`，哈希来自 `sha256sum`）

| URL | UTC 时间 | HTTP | sha256 | 本地文件（specs/sources/） |
|---|---|---|---|---|
| https://api.zbmath.org/v1/document/_structured_search?author=Narkiewicz&title=Gupta&results_per_page=20 | 2026-11-24T11:34:52Z | 400 | `f783f6a33036303abc3683d2164b6534c6c9d6ab28272673bed9febc29cb9f88` | zbmath-api-narkiewicz-gupta.json |
| https://zbmath.org/?q=ai%3Anarkiewicz.wladyslaw+py%3A1980 | 2026-11-24T11:34:53Z | 200 | `3680903b3cd95f14591d74add11e36a4d38c88dc62b4b1685eff4004e6a979cd` | zbmath-narkiewicz-1980-search.html |
| https://zbmath.org/?q=an%3A0457.10003 | 2026-11-24T11:35:09Z | 200 | `361d0db4831c736b33ad65f54dd129780c39bb3e3ff5916fb4f46291a349745f` | zbmath-0457.10003.html |
| https://zbmath.org/scans/457/052.gif | 2026-11-24T11:35:26Z | 200 | `fd3eb862a52a87a4d4b459676e836a9ceb53d2514737ffaf683043a799228081` | zbmath-scan-457-052.gif |
| https://zbmath.org/?q=ci%3A3715658 | 2026-11-24T11:35:27Z | 200 | `c3bd24cebe420afb2b319a442a1d7b23d205c909f59cace8971285d07e2dac72` | zbmath-citing-0457.10003.html |
| https://api.crossref.org/works?query.bibliographic=Narkiewicz+note+paper+Gupta+powers+two+three&rows=5 | 2026-11-24T11:35:51Z | 200 | `810982f855e69e0a2ce9eb9eabdccf9e316170f5135dfb21637b9a1f358ea946` | crossref-narkiewicz-gupta.json（无相关命中） |
| https://zbmath.org/?q=an%3A0999.11008 | 2026-11-24T11:35:52Z | 200 | `73120e3db08c0ccdf93a7a67c113bb2c25e9fa243e56eb20e16d5fd72978603b` | zbmath-0999.11008.html |
| https://export.arxiv.org/api/query?search_query=ti:%22Powers+in+prime+bases%22&max_results=5 | 2026-11-24T11:35:53Z | 200 | `85102f5784b04bc06e27c3da5f39a09c5409ad84465b4c28f97d824b546724cc` | arxiv-api-holdum.xml |
| https://arxiv.org/pdf/2601.09510v1 | 2026-11-24T11:37:56Z | 200 | `d7310e38fb8c521b03fe69bebebff65dfdc646525a047fd196efa56b1c64c09d` | arxiv-2601.09510v1.pdf |
| https://export.arxiv.org/api/query?search_query=ti:%22omitting+a+digit%22&max_results=10 | 2026-11-24T11:37:57Z | 200 | `67e09396da578905621d988abf7184e893197221f6e1f0ccb7f9dd06c2cae6d5` | arxiv-api-omitting-digit.xml |
| https://arxiv.org/pdf/2405.06220v2 | 2026-11-24T11:38:32Z | 200 | `42ba7612ddc9df2cf1a716c1c918d6f0f3d1e681583883a59ca3e9ad6c50020e` | arxiv-2405.06220v2.pdf |
| https://www.jstor.org/action/doBasicSearch?Query=Narkiewicz+Gupta+powers+of+two+and+three | 2026-11-24T11:38:43Z | 200（反爬挑战页，视为被拦，PENDING） | `32ed63159c77e21ee19ca1b9aa3213ccf0218eb59539560b132a8e68ef0e18ea` | jstor-search-narkiewicz.html |
| https://pefmath.etf.rs/ | 2026-11-24T11:38:43Z | 000（TLS：证书主机名不匹配） | — | 无（未生成文件） |
| https://eudml.org/search/page?q=sc.general*op.AND*l_0*c_0author_0eq%253A1.Narkiewicz&qt=SEARCH | 2026-11-24T11:38:44Z | 000（TLS：证书过期） | — | 无（未生成文件） |
| https://mathscinet.ams.org/mrlookup?au=Narkiewicz&ti=Gupta&format=bibtex | 2026-11-24T11:39:02Z | 200 | `4e13ec1775bd71fddb07f05486fd11b477008fd73e989ee9fbc7b183cca2f7de` | mrlookup-narkiewicz-gupta.html |

另外重新读了已有的 `arxiv-math0512006.pdf`（Lagarias，sha256 见 literature.md 附录 A），用 `pdftotext` 抽取 §1、§1.3、§1.6、§3 和参考文献 [12]、[18]。
