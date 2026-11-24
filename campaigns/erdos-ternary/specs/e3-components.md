# g003-R03：E^(3) 正维分支的新颖性核查 + C(1,2^8) 维数差异（Researcher）

写于 2026-11-24（UTC）。抓取记录见附录 A。级别标记按 CONSTRAINTS.md 第 3 条；"未核实" = 本人没有打开原文。
本文件只做文献核查和独立数值复算，不是成果（第 11 条）。

## 1. 结论摘要

- P04 报告的 9 个 E^(3) 正维分支中，只有 C(1,2^2,2^8) 在文献中出现过（KNOWN，Abram–Lagarias 2014）。
  其余 8 个在已打开的文献里 **NOT FOUND**。检索覆盖有缺口：Semantic Scholar 对 ABL 的查询返回 429，arXiv API 返回 429，
  三篇引用文献只看到标题，没有打开全文。所以只能写"在已检索范围内未见"，不能写"新"。
- "C(1,2^2,2^8) 是唯一已知的正维 E^(3) 分支"这句话 **只出现在 arXiv:1308.3133v1**（§5.2 末尾）。
  期刊版（J. Fractal Geom. 1 (2014)）§6.3 删掉了这句话，只保留"It is unclear whether dimH(E^(k)(Z3)) is positive for any k ≥ 4"。
- 独立复算（自写脚本，不用项目代码）：dim_H C(1,2^8) = log_3 1.4009249900 = **0.306871**，与 P04 一致。
  Abram–Lagarias 表中的 0.287416（arXiv Table 5.2 与期刊 Table 6.1 两个版本都是这个值）应是错的。见 §3。

## 2. 任务 1：9 个分支逐项核查

已打开的来源：arXiv:1308.3133v1（Table 5.2、§5.2），期刊版 JFG 1 (2014) 349–390（Table 6.1、§6.3，本次抓取），
arXiv:1508.05967v2（ABL Part II，全文 grep），arXiv:2610.03789（Idowu 2026，引用 AL2014，全文 grep），
以及 specs/sources 中已有的 2511.03861、2405.06220v2、2601.09510v1、2202.13256、2105.06440（全文 grep）。

引用 AL2014 的文献（OpenAlex filter=cites:W1995307021，共 8 条；S2 citations 4 条，二者一致）：
ABL Part II (2017)；Abram–Lagarias–Slonim, "Decimation and interleaving operations…" (AAM 2021, arXiv:2010.15215)；
Abram–Lagarias–Slonim, "Interleaving of path sets" (arXiv:2101.02441)；Deng–Li–Qiu (Nonlinearity 2023, arXiv:2206.08559)；
Idowu (arXiv:2610.03789)；另有 Abram–Lagarias 自己的两篇 2014 path-set 论文（按年份看早于或同于 AL2014，属于互引）。
引用 ABL2017 的文献（OpenAlex，3 条）：AL2014 本身和上面两篇 ALS 论文。
ALS 两篇和 Deng–Li–Qiu **未打开全文**（arXiv API 已 429，按规则停止）→ PENDING。从标题看，它们讲的是符号动力学运算和自仿射集，
不太可能列出 E^(3) 分支（SPECULATION，未核实）。

| (a,b) | P04 dim | 本人复算 dim（§3 方法 B） | 文献状态 |
|---|---|---|---|
| (2,8) | 0.228391 | 0.228391 | **KNOWN**：AL2014 Thm 5.2 / Thm 6.4（期刊）：log_3 β1 ≈ 0.228392，β1 是 λ^6−λ^5−1 的根 |
| (2,18) | 0.103480 | 0.103480 | NOT FOUND |
| (2,24) | 0.083861 | 0.083861 | NOT FOUND |
| (2,32) | 0.074977 | 0.074977 | NOT FOUND |
| (2,38) | 0.069649 | 0.069649 | NOT FOUND |
| (16,18) | 0.087278 | 0.087278 | NOT FOUND |
| (22,24) | 0.067684 | 0.067684 | NOT FOUND |
| (24,26) | 0.067080 | 0.067080 | NOT FOUND |
| (28,30) | 0.067489 | 0.067489 | NOT FOUND |

AL 原文中已算过、结果为 0 的组合：arXiv 版 Table 5.2 中指数 ≤ 10 的所有对，以及 C(1,2^2,2^8,2^{12,14,16})。
期刊版正文另有："we computed the Hausdorff dimensions of C(1, 2^6, 2^{2k}) for 8 ≤ 2k ≤ 14 and of C(1, 2^2, 2^8, 2^{2k})
for 10 ≤ 2k ≤ 16 and found these dimensions to be 0 in all cases."（引自期刊 PDF 的文本）
本人复算 C(1,2^6,2^{8,10,12,14}) 也都是 0，与原文一致。

"唯一已知"一句的原文（arXiv:1308.3133v1，引自 PDF 文本）：
> "It is unclear whether dimH (E (k) (Z3 )) is positive for any k ≥ 4. Currently C(1, 22 , 28 ) is the only component
> of E (3) (Z3 ) known to have positive Hausdorff dimension. At present we do not know of any set C(1, 2m1 , 2m2 , 2m3 )
> that has positive Hausdorff dimension."

期刊版只保留了第一句。ABL Part II 和 Idowu 2026 都没有讨论具体的 E^(3) 分支（grep "E (3)"、"positive Hausdorff"、
"only component" 只命中定义）。Google Scholar 没有尝试（自动请求会触发验证页）→ PENDING。

## 3. 任务 2：C(1,2^8) 的差异

**构造**（AL2014 Thm 3.1 / Thm 1.6，KNOWN）：顶点是进位 c（起点 c = 0）；λ 的数字 a ∈ {0,1}；
当 (c + M a) mod 3 ∈ {0,1} 时允许这条边，下一个进位是 ⌊(c + M a)/3⌋；dim_H C(1,M) = log_3 β，β 是可达图邻接矩阵的 Perron 根。

**独立实现**（scratch：`al_dim.py`，sha256 f635949f…；`pairs.py` b3d99d5a…；`brute.py` e52235de…；`val.py` 806f3793…；`scan2.py` e7c144e6…）。
方法 A：对可达图稠密矩阵用 numpy 求特征值。方法 B：从起点精确（big-int）或归一化地迭代路径计数 R_k，k 取到 3000 或 20000，取增长率。
方法 C：对 M = 256、k ≤ 18 直接穷举 {0,1}^k，检查 256λ mod 3^k 的数字。

| M | 顶点 | β | dim（本人） | 文献值 |
|---|---|---|---|---|
| 4 | 2 | 1.6180339887 | 0.438018 | AL 0.438018 |
| 16 | 5 | 1.3247179572 | 0.255959 | AL 0.255960；ABL T7.1 β 1.324718 |
| 64 | 14 | 1.3571928950 | 0.278004 | AL 0.278002；ABL T7.1：14 顶点，β 1.357193，0.278004 |
| **256** | 35 | **1.4009249900** | **0.306871** | AL **0.287416** |
| 1024 | 77 | 1.2667051888 | 0.215198 | AL 0.215201 |
| 4096 | 181 | 1.3074251870 | 0.243998 | AL 0.244002 |
| 16384 | 442 | 1.3410468804 | 0.267110 | AL 0.267112 |
| 94 = (10111)_3 | 19 | 1.4285687209 | 0.324658 | — |
| 19；(7,19)；(4,256) | 8；6；10 | 1.465571；1.465571；1.285199 | 0.347934；0.347934；0.228391 | AL (3.4) 0.347934；Thm 5.2 0.228392 |

本人代码还逐项复现了 ABL Table 2.1（P_1…P_8）、Table 7.1（20 个 M）和 Table 8.1（L_1…L_9）的顶点数，β 全部吻合到 6 位小数。
（ABL 少数 dim 列的末位与 log_3 β 不符，例如 P_7：log_3 1.392067 = 0.301098，表中写 0.301010。这说明他们的表里确实有转写或换算误差。）

M = 256 时，三种方法给出的 β 互相一致（方法 B：1.40092499）。穷举 R_k（k = 1..18）：2, 3, 4, 6, 9, 12, 17, 25, 36, 51, 74, 107,
154, 218, 305, 424, 590, 824，与图路径计数逐项相等（P04 给出的 k = 6..14 也一致）。

**哪个值对**：0.306871（β ≈ 1.400925）。依据：同一套代码对 AL 和 ABL 表中其他 40 多个条目都对得上，三种独立方法互相一致，
而且穷举数列在 k = 14..18 的相邻比值为 1.390–1.399，与 3^0.287416 = 1.371299 不符。

**表值为什么不同**（排查结果）：
- 不是 M = 94（(10111)_3，原文 §5.2 写错的 256 展开）：dim 0.324658。
- 对所有 M < 6000、M ≢ 2 (mod 3)，没有任何 dim C(1,M) 落在 0.287416 ± 5·10^-5 内（scan2.py）。所以不是"录入了另一个 M"。
- 在 35 顶点的图里删掉任意一条边或一个顶点，也得不到 1.371299（最接近的是删边 117→39，dim 0.287169）。
- 不是 log 换算错误：log_3 1.400925 = 0.306871，与 0.287416 的差远大于末位误差。
- 期刊版 Table 6.1 仍写 0.287416，所以这个值在定稿时也没有被更正。附近值 ABL Table 2.1 C(1,P_5) = 0.287191（β 1.370957）接近但不相等。
- 结论：原因不明，最可能是原作者当年对 M = 256 的计算或转写出错（HEURISTIC）。同一段里的 "256 = (10111)_3" 也是错的（正确是 (100111)_3），
  这说明该段对 2^8 的处理不仔细（SPECULATION）。这个错误不影响他们的定理（Thm 5.2 用的是 C(1,2^2,2^8)，值正确）。

## 附录 A：抓取记录（每页一次请求；时间来自 `date -u`，哈希来自 `sha256sum`；文件在 specs/sources/）

| URL | UTC 时间 | HTTP | sha256 | 文件 |
|---|---|---|---|---|
| https://api.semanticscholar.org/graph/v1/paper/arXiv:1308.3133/citations?fields=title,year,externalIds,authors&limit=100 | 2026-11-24T13:18:07Z | 200 | `2558579118744902fdb05432d940ea1140473ad728b2d70da2db0720ff6d8d71` | s2-citations-1308.3133.json |
| https://api.semanticscholar.org/graph/v1/paper/arXiv:1508.05967/citations?fields=title,year,externalIds,authors&limit=100 | 2026-11-24T13:18:10Z | **429** → PENDING，已停止对 S2 的请求 | `65ab993d12c5c2cc9b68e6da2bb79b326930283e520363ffcdc145f88cd5a148` | s2-citations-1508.05967.json（错误页） |
| https://api.openalex.org/works?filter=doi:10.4171/JFG/11 | 2026-11-24T13:18:10Z | 200 | `e3db01fddbd7396d9ec78bc98bd4dca4f2dabe9328ccbc9ee4755f76c53bedc7` | openalex-al2014.json |
| https://api.openalex.org/works?filter=cites:W1995307021&per-page=100 | 2026-11-24T13:18:27Z | 200 | `16f9691a63900bfde85de01ba57dd772d5d438b1ba00224b4eb3a655f0e01199` | openalex-citing-al2014.json |
| https://api.openalex.org/works?search=Intersections%20of%20multiplicative%20translates%20of%203-adic%20Cantor%20sets%20II&per-page=10 | 2026-11-24T13:18:27Z | 200 | `217323c86cb4c35374cdacf74fd66ec1c3073eb801f9cc0db06fed8676771253` | openalex-search-abl.json |
| https://api.openalex.org/works?filter=cites:W1925720072&per-page=100 | 2026-11-24T13:18:36Z | 200 | `0777e99dae6a48b74877a644840c7f552aa525199b1b8ef4e80d4745509b0a12` | openalex-citing-abl2017.json |
| https://export.arxiv.org/api/query?search_query=all:%22C(1,%202%5E2,%202%5E8)%22%20OR%20abs:%22multiplicative%20translates%22&max_results=50 | 2026-11-24T13:18:36Z | **429** → PENDING，已停止对 arXiv 的请求 | `467622e2f17f01d302d6c790b13078569f17d71cd83910558535019a594e07c1` | arxiv-api-mult-translates.xml（错误页） |
| https://ems.press/content/serial-article-files/45216 | 2026-11-24T13:20:03Z | 200 | `fda6ae4b339eb95bd5020493897cc2d6e106c89b900cdac335bb37985f93c502` | 抓错了文章（URL 是猜的，内容是 Elem. Math. 58 (2003)）；已删除，未使用 |
| http://www.ems-ph.org/journals/show_pdf.php?issn=2308-1309&vol=1&iss=4&rank=1（OpenAlex 给出的 OA 地址） | 2026-11-24T13:20:17Z | 200 | `f16a7c9ee048d2f13ff3cb2d0789cb90ffb43e2179808e3cea9629c7188ecf41` | jfg-2014-al.pdf（期刊版 AL2014） |

沿用已有文件（g001-r04 的抓取记录见 literature.md 附录 A）：arxiv-1308.3133.pdf `9cdebcbd…`，arxiv-1508.05967.pdf `5162b18c…`，
arxiv-2610.03789.pdf `a53e00f1…`。

PENDING：ALS 2021 两篇和 Deng–Li–Qiu 2023 的全文；S2 上 ABL 的引用列表；Google Scholar 检索。
