# g001-r04 文献地图：Erdős 三进制猜想的部分结果（Researcher）

写于 2026-11-24（UTC），所有抓取记录见文末附录 A（URL、`date -u` 时间、HTTP 状态、`sha256sum`）。
原始文件按抓取原样保存在 `specs/sources/`。级别标记遵循 CONSTRAINTS.md 第 3 条；
"未核实" = 本人没有打开一手原文，仅凭记忆或二手转述。

记号：N(X) := #{0 ≤ n ≤ X : 2^n 的三进制展开不含数字 2}；α0 := log_3 2 ≈ 0.63093；
Σ := {λ ∈ Z_3 : 3-adic 展开只用 0、1}；C(M1,…,Mk) := {λ ∈ Z_3 : M_i λ ∈ Σ, 所有 i}。

---

## 1. 问题状态

- **erdosproblems.com #406**（打开，HTTP 200）。原文："Is it true that there are only finitely many powers of $2$
  which have only the digits $0$ and $1$ when written in base $3$?"；附注引用 Saye [Sa22]
  （"$2^n$ contains every possible ternary digit for $16\leq n \leq 5.9\times 10^{21}$"）与
  Narkiewicz [Na80] "$N(x)\leq 1.62 x^{\log_32}$"；"Proof claims (0)"，"This page was last edited 13 April 2026"，
  "Formalised statement? Yes"。页面 HTML 中没有找到明文的 "OPEN"/"SOLVED" 状态字（问题框的 CSS id 为
  `neutral`），因此状态写作：**按页面措辞与 0 个证明声明判断为未解决；明文状态字 PENDING STATUS CHECK**。
- 2026-09-30 的 arXiv:2610.03789（见 §8）原文："The problem is still open in 2026 [10]"（[10] = erdosproblems #406）。

## 2. Lagarias, "Ternary expansions of powers of 2"（arXiv:math/0512006v4, 2008-07-11；J. London Math. Soc. 79 (2009) 562–588）KNOWN

打开了 PDF 全文。精确陈述（引自原文）：

- **Narkiewicz 的结果（经 Lagarias 转述）**："In 1980 Narkiewicz [18] showed that the number N1(X) := #{n ≤ X : the
  ternary expansion (2^n)_3 omits the digit 2} has N1(X) ≤ 1.62 X^{α0} with α0 = log3 2"。
  [18] = W. Narkiewicz, *A note on a paper of H. Gupta concerning powers of 2 and 3*, Univ. Beograd Publ. Elektrotehn.
  Fak. Ser. Mat. Fiz. No. 678–715 (1980), 173–174, MR 0623247。**Narkiewicz 原文未打开**（期刊无开放链接），
  常数 1.62 与指数 log_3 2 有两个独立二手来源（Lagarias、erdosproblems #406）互相印证；X 的取值范围
  （所有 X 还是充分大的 X）以及 1.62 的推导方式：未核实。
- Gupta [12]（1978）："found by a sieving procedure that there are no other solutions for n < 4374"。
- **Theorem 1.1**（截断实系统）：对每个 λ > 0，N_λ(X) := #{1 ≤ n ≤ X : (⌊λ2^n⌋)_3 omits 2} ≤ 25 X^{0.9725}，对 X ≥ n0(λ)。
  方法：只看 2^n 的最高约 log_3 X 位（通过 n·log_3 2 mod 1 的分布，用 Simons–de Weger/Rhin 的
  |α0 − p/q| ≥ 1/(1200 q^{14.3}) 型无理性度量，Lemma 2.2）。
- **Theorem 1.2/1.3**：存在不可数多个 λ 使 ⌊λ2^n⌋ 对无穷多 n 不含 2；截断实例外集 dim_H = log_3 2。
- **Conjecture A**：实例外集 E(R) 的 Hausdorff 维数为 0。
- **Theorem 1.4**（3-adic，推广 Narkiewicz，"using essentially the same proof"）：对每个非零 λ ∈ Z_3 及 X ≥ 2，
  Ñ_λ(X) := #{n ≤ X : (λ2^n)_3 omits 2} ≤ 2X^{α0}。证明：2 是模 3^k 的原根；取 2·3^{k−2} < X ≤ 2·3^{k−1}，
  一个完整周期内恰有 2^{k−1} 个 n 使低 k 位不含 2，故 Ñ ≤ 2^{k−1} ≤ 2X^{α0}。
- **Theorem 1.5**：dim_H E^{(1)}(Z_3) = α0；(1/2)α0 ≤ dim_H E^{(2)} ≤ 1/2；(1/6)α0 ≤ dim_H E^{(3)}。
  其中 E^{(k)}(Z_3) = {λ : 至少 k 个 λ2^n 不含 2}，E(Z_3) = {λ : 无穷多个}。
- **Conjecture B**：dim_H E(Z_3) = 0。原文："we do not know much about this exceptional set, except that it contains 0."
- **Theorem 1.6**：M 非 3 的幂时 dim_H C(1,M) ≤ 1/2；dim_H C(1,7) = log_3((1+√5)/2) ≈ 0.438。
- **Theorem 1.7**：若存在正整数 N ∈ Σ 使所有 N·M_i ∈ Σ，则 dim_H C(M1,…,Mk) ≥ log_3 2 / ⌈log_3(N M_k)⌉。
  原文："This result gives a possible approach to obtaining a nonzero lower bound for dimH(E^{(k)}(Z3)) for k = 4 or larger".
- **Lemma 4.1**：M ≡ 2 (mod 3) ⇒ C(1,M) = {0}；M ≡ 1 (mod 3) ⇒ C(1,M) 无穷。C(1,49) 可数无穷，C(1,7) 不可数。
- **Problem 1/2**：估计 M_C = {M : ∃ N1,N2 ∈ Σ∩Z, N1 M = N2} 和 M_H = {M : dim_H C(1,M) > 0} 在 [1,X] 中的个数；M_C ⊊ M_H。
- **Conjecture E**：p、q 乘法无关时，任一有限数字块从某个 n 起都出现在 (p^n)_q 中。
- **§1.6 明确开放问题**（原文）："It seems a challenging problem to find a method that effectively combines the two
  approaches to find better upper bounds on N1(X) than that given by Narkiewicz. Can one obtain an upper bound of
  O(X^β) for some β < log3 2 in this way? Can one show that the high order digits and the low order digits in the
  ternary expansion (2^n)_3 are "uncorrelated" in some quantifiable way?"
  另："It is not clear whether dimH(E^{(k)}(Z3)) > 0 for all k ≥ 1."
  这一句为 g0-baseline 中"已知障碍"提供了出处：两种方法分别只用最高、最低约 log_3 X 位，中间的数字完全没用上。

## 3. Abram–Lagarias（arXiv:1308.3133v1, 2013；J. Fractal Geometry 1 (2014) 349–390）KNOWN

打开了 PDF 全文（v1）。
- **Theorem 1.6**：C(1,M1,…,Mn) 由一个可算法构造的有限自动机描述（顶点数 ≤ ∏(1+⌊M_i/2⌋)），
  dim_H = log_3 β，β 是邻接矩阵的 Perron 特征值（实代数整数，1 ≤ β ≤ 2）。
- **Theorem 1.7**：L_k = (1^k)_3 时 dim_H C(1,L_k) = log_3 β_k，β_k 为 λ^k − λ^{k−1} − 1 的实根 > 1，且 → 0（约 log_3 k / k）。
- **Theorem 1.8**：N_k = 3^k + 1 时 dim_H C(1,N_k) = log_3 φ ≈ 0.438018，与 k 无关。
- **Theorem 1.9**：广义例外集 E⋆ 的 dim_H ≥ (1/2) log_3 2，因此"把 2^m 换成任意整数 M"的放宽方法不可能证明 Conjecture B。
- **Theorem 5.2**：dim_H E^{(2)}(Z_3) ≥ log_3 φ ≈ 0.438018；dim_H E^{(3)}(Z_3) ≥ log_3 β1 ≈ 0.228392（β1 为 λ^6 − λ^5 − 1 的根），
  由 C(1, 2^2, 2^8) 得到。
- **Table 5.2**（数值）：C(1,2^2,2^4)、C(1,2^2,2^6)、C(1,2^2,2^10)、C(1,2^4,2^6)、…、C(1,2^2,2^8,2^12)、C(1,2^2,2^8,2^14)、
  C(1,2^2,2^8,2^16) 的维数都是 0。
- **明确开放**（原文）："It is unclear whether dimH(E^{(k)}(Z3)) is positive for any k ≥ 4. Currently C(1, 2^2, 2^8) is
  the only component of E^{(3)}(Z3) known to have positive Hausdorff dimension. At present we do not know of any set
  C(1, 2^{m1}, 2^{m2}, 2^{m3}) that has positive Hausdorff dimension."
- §1.6 转述 Stewart："a quantitative version of this assertion follows from results of C. L. Stewart [20, Theorem 1]"。
- 注意：arXiv 摘要页当前元数据的摘要写的是 "It has been shown that this set has Hausdorff dimension 0"，
  而 v1 PDF 摘要写的是 "at most 1/2 and it has been conjectured that it has Hausdorff dimension 0"，
  2015 年的续篇（§4）仍然写 "It is conjectured that it has Hausdorff dimension 0"。以 PDF 和续篇为准：
  **dim_H E(Z_3) = 0 仍未证明**；摘要页的写法看作元数据错误。

## 4. Abram–Bolshakov–Lagarias, Part II（arXiv:1508.05967v2, 2015；Experimental Math. 26 (2017) 468–489）KNOWN

打开了 PDF 全文。
- Q_k = (2^k 0^{k−1} 1)_3 = 3^{2k} − 3^k + 1：dim_H C(1,Q_k) = log_3 φ 对所有 k ≥ 2 成立（Theorem 2.4），而 Q_k 的非零数字个数 → ∞。
- **Theorem 2.6/6.2**：对所有 k ≥ 2，α_k = log_3 φ（α_n := sup{dim_H C(1,M) : M 至少有 n 个非零三进制数字}）。
  **推论 (1.10)**：dim_H E(Z_3) ≤ Γ ≤ Γ⋆⋆ ≤ log_3 φ ≈ 0.438018。这是目前已知最好的上界（就我检索到的范围而言）。
- 原文："our state of ignorance is such that we do not know whether E(Z3) = {0} or not"；
  "The third author raised the question in [12] whether Γ = 0 … This question is currently unanswered."
- **Theorem 6.1**（他们对 Stewart 的转述）："for m ≥ 25, n3(2^m) > log m/(log log m + c) − 3, where c > 0 is an
  effectively computable constant"。注意：原文同时写 "n3(n) denotes the sum of the base 3 digits of n"，
  而证明中说的是 "counts the number of nonzero ternary digits"，两者不一致；**Stewart 原文未打开**，确切说法 PENDING。
- §7 的统计量：b3(M) = 非零数字块的个数，s3(M) = 相同数字的极大连续段个数（"intermittency"）。
  原文："it is not currently known whether b3(2^n) → ∞ holds as n → ∞ or whether s3(2^n) → ∞ holds as n → ∞."
  他们又说 dim_H C(1,M) 是否随 b3(M) → ∞ 而 → 0 是开放的（"extremely limited data"）。

## 5. Stewart 1980（J. reine angew. Math. 319 (1980) 63–72）

- **一手原文 PENDING**：MathOverflow 答案给出的作者主页 PDF 链接现在跳转到系主页（HTTP 200 但内容是 HTML，
  已存为 `stewart-1980-crelle-redirect.html`）；DOI 10.1515/crll.1980.319.63 返回 HTTP 202 和空内容；
  OpenAlex 标记为 closed access。
- 二手转述（都已打开）：
  - MO 30357，Mike Bennett 的答案："for fixed bases a and b for which log a/log b is irrational, that the sum of the
    number of nonzero digits in the base a and base b digits of an integer n exceeds (essentially) log log n/ log log log n."
  - Dimitrov–Howe 脚注 1："Stewart's Theorem 1 shows that the largest x for which 3^x has at most 22 bits equal to 1
    satisfies 23 > (log log 3^x)/(C + log log log 3^x) for some positive constant C"；他们只能通过取 C = 0 得到
    "B(22) > 4.9×10^46"，以及对 2^x 的 "larger than 5.4×10^54"。由此看来，**Stewart 的常数 C 在已发表文献里似乎没有显式数值**
    （推断，未核实）。
  - ABL II Theorem 6.1（见 §4）。
- Senge–Straus（Period. Math. Hungar. 3 (1973) 93–100）：非零数字个数 → ∞（无效）。只经 ABL/DH 二手转述，原文未打开。
- **关于"2^n 至少有 f(n) 个数字 2"**：我没有找到任何文献给出 f → ∞，连 f ≥ 1 对所有大 n 也没有（这就是猜想本身）。
  Stewart 型结果只控制**非零**数字的个数（如果 Stewart 允许"不等于 α 的数字"，也可能控制不等于 1 的数字个数；未核实）。
  "数字 2 的个数"的有效下界因此**并不存在**，它至少和 Erdős 猜想一样难。

## 6. Dupuy–Weirich, "Bits of 3^n in binary, Wieferich primes and a conjecture of Erdős"（J. Number Theory 158 (2016) 268–280, doi:10.1016/j.jnt.2015.05.022）

- **一手原文 PENDING**：doi.org 跳到 Elsevier 的 JS 重定向页；ScienceDirect 返回 **HTTP 403**，按规则停止。
  arXiv API 按作者和标题检索都没有结果。OpenAlex 记录只有标题、作者、年份，没有摘要。
- 二手（arXiv:2610.03789 原文）："Dupuy and Weirich obtained average digit-equidistribution results whose non-averaged
  analogue would imply the weak Erdős conjecture"；"average equidistribution is accessible, whereas a sufficiently strong
  non-averaged statement would imply the Erdős conjecture"。
- 凭记忆（**未核实**）：他们研究 3^n 的二进制低位、2-adic 版本以及 Wieferich 素数条件下的类比。不要引用任何具体定理。

## 7. Dimitrov–Howe, "Powers of 3 with few nonzero bits and a conjecture of Erdős"（arXiv:2105.06440v4, 2023；Rocky Mountain J. Math. 55 (2025) 45–61，期刊信息据 2610.03789 的参考文献）KNOWN

打开了 PDF 全文。**Theorem 1.2**（原文）："The only powers of 2 that can be written as the sum of twenty-five or fewer
distinct powers of 3 are: 2^0 = 3^0, 2^2 = 3^0+3^1, 2^8 = 3^0+3^1+3^2+3^5."
这对所有 x 成立，没有上界。方法：沿一串模数 M_1 | M_2 | … 做同余筛（Magma 程序），完全初等。
Theorem 1.1 是对偶结果（3^x 至多 22 个二进制 1 ⇔ x ≤ 25）。n 为奇数（> 1）时方程 2^x = Σ 3^{a_i} 无解（奇偶性）。
Table 3 的运行时间（Thm 1.1 的 n = 22）为 743737 秒，每增加一项大约慢 3–5 倍。

## 8. 近 24 个月（2024-11 → 2026-11）检索结果

arXiv API 检索词（见附录 A）：ternary∧powers of 2、ternary∧Erdos、"powers of two"∧ternary、"base 3"∧"powers of 2"、
"3-adic Cantor"、"ternary digits"、"distinct powers of 3"、作者 Abram∧Lagarias、Dimitrov∧Howe、Dupuy。相关命中：
- **arXiv:2610.03789**（M. A. Idowu, 2026-09-30，"Repunit Coordinates for the Erdős Ternary-Digit Problem"），已打开全文。
  内容是重新表述：n = 2s，2^{2s} = 3R_s(4) + 1；Φ_m : s mod 3^m ↦ R_s(4) mod 3^m 是置换；每层"三个提升中恰两个可行"；
  一个 Z_3 同胚把 x ↦ x+1 共轭为 y ↦ 4y+1。原文："No proof of the Erdős conjecture is claimed"；
  "the recursive fact that there are three exponent lifts … exactly two avoid the digit 2 is already embodied in Saye's
  construction"。这里没有新的部分结果（与 g0 的引理 1–3 等价）。
- **arXiv:2511.03861**（Roettger–Ren, 2025-11-05，"Ternary Digits of Powers of Two"）：只有计算证据（n ≤ 10^6 的块频率；
  log_3 2 的前 10^6 位三进制数字），没有定理。
- Aliyev, NNTDM 29(3) (2023) 474–485（摘要页已打开）："prove that the sizes of these blocks of 0s and 2s are unbounded"（"阶梯"图案）。
  2023 年发表，不在 24 个月窗口内；与本问题只是边缘相关。
- MathOverflow：30357（2010，非零数字下界，答案指向 Stewart）、172826（2014，等价问题，答案："This is an old unsolved problem"）。
  StackExchange API 检索没有找到 2024–2026 年的新问题。
- **结论**：在我检索到的范围内，近 24 个月没有新的部分定理；最强的已知部分结果仍然是 Narkiewicz 1980（计数上界）、
  ABL 2015（dim_H E(Z_3) ≤ log_3 φ）、Dimitrov–Howe 2021/2025（≤ 25 个 1）、Saye 2022（n ≤ 2·3^45）。
  检索范围的局限：没有查 zbMATH/MathSciNet（无访问），也没有做全文搜索。

## 9. Saye 2022（JIS 25, Article 22.3.4；arXiv:2202.13256）KNOWN（简述）

JIS 摘要页已打开："we verify both conjectures for all 2^n with n ≤ 2·3^45 ≈ 5.9×10^21"（Erdős 和 Sloane 的"含 0"猜想）；
方法是"a simple recursive construction of numbers 2^n having prescribed patterns in their trailing ternary digits"。
状态见 specs/status.md。

---

## 10. 候选子问题（给理论轨道；按 2026-11-24 规则更新，可形式化程度为首要排序标准）

规则更新（orchestrator 转达，由人决定）：每个结果都必须是能编译的 Lean 4 + Mathlib 定理（v4.36.0，`lean/`），
并通过 `verify/lean_audit.py` 和独立审计。我检查了 `verify/lean_audit.py`：`native_decide`、`decide := true`、
`ofReduceBool`、`sorry`、`axiom` 都在禁用名单里，所以**大规模计算证书只能交给内核 `decide`/`norm_num`**，实际只适用于小规模。
本地 Mathlib 里我用 grep 确认**存在**的部件：`Nat.digits`（Data/Nat/Digits）、`padicValNat`、
LTE（`Int.emultiplicity_pow_sub_pow`，NumberTheory/Multiplicity.lean）、`orderOf`/`ZMod`、`PadicInt`（ℤ_[p]）、
`dimH`（Topology/MetricSpace/HausdorffDimension.lean，只有一般理论）。
**没有找到**：Perron–Frobenius 定理、中三分 Cantor 集的维数计算、S-单位方程/子空间定理、Baker 线性对数型。

### 排名 1：Narkiewicz 常数的初等改进，N(X) ≤ (X+1)^{log_3 2}（SPECULATION，需理论轨道证明）

- **陈述（草案）**：对所有整数 X ≥ 0，#{0 ≤ n ≤ X : 2^n 的三进制数字 ⊂ {0,1}} ≤ (X+1)^{log_3 2}。
  中间步骤（Lean 友好）：(a) 计数 ≤ A(⌊X/2⌋)，其中 A(Y) := #{0 ≤ m ≤ Y : m 的三进制数字 ⊂ {0,1}}；
  (b) A(Y) ≤ (2Y+1)^{log_3 2}，在 Y = (3^L − 1)/2 时取等号（此时 A = 2^L）。
- **为什么可能成立**（SKETCH，未检查）：取 P_k > X。由 g0 引理 1–3，存活类 S_k ⊂ [0,P_k) 构成一棵树，每个节点的三个提升
  r + jP_i（j = 0,1,2）中恰有两个存活；S_1 = {0}，所以 n 都是偶数，n = 2m。对树归纳（计数函数单调）可知，
  "保留 j ∈ {0,1}"的树使 #(S_k ∩ [0,X]) 最大，而这个最大值就是 A(⌊X/2⌋)。小例子：X = 2 时为 2 ≤ 3^{α0} = 2（取等号）；
  X = 8 时为 3 ≤ 9^{α0} = 4。
- **新颖性**：Narkiewicz 原文没有打开，**不能排除 1.62 正是这个论证的某种粗糙版本，也不能排除原文已经有更好的结果**。
  已发表的常数是 1.62（Narkiewicz）和 2（Lagarias Thm 1.4，任意 λ）。在开始工作之前，应该先把 Narkiewicz 原文找来
  （Univ. Beograd Publ. Elektrotehn. Fak.，两页）。我把它标为 PENDING。
- **可形式化程度：高**。需要的部件：`Nat.digits`、`ZMod (3^k)` 里的 `orderOf 2 = 2·3^(k-1)`（用 LTE 证）、
  Finset 计数、`Real.rpow`/`Real.logb`。不需要测度或维数。估计 1–3 周（Lean 专家）。冻结陈述是可判定的有限命题族加一个实数不等式，审计清楚。
- **阻碍**：(b) 的证明需要对 Y 的三进制展开做归纳（标准，但要处理首位为 2 的情形）。它对猜想本身的意义较小：
  只是常数改进，指数仍是 α0（Lagarias 的 β < α0 问题没有解决）。

### 排名 2：3-adic 例外集 E^{(4)} 的有限版本（PROMISING-方向，SPECULATION）

- **背景**：Abram–Lagarias 2014 原文："At present we do not know of any set C(1, 2^{m1}, 2^{m2}, 2^{m3}) that has positive
  Hausdorff dimension"；dim_H E^{(k)} > 0 对 k ≥ 4 是开放的。
- **目标 A（计算 + 证书）**：找正整数 N 和 0 < a < b < c（偶数），使 N, N·2^a, N·2^b, N·2^c 的三进制数字都在 {0,1} 中
  （Lagarias Thm 1.7 的假设），从而 dim_H E^{(4)}(Z_3) ≥ log_3 2/⌈log_3(N 2^c)⌉ > 0。随机模型启发（HEURISTIC）：
  长度为 L 的这种 N 的期望个数约为 (16/27)^L 乘以 m 的组合数，所以只可能有小解，搜索结果很可能是否定的；
  否定结果只是证据，本身不能证明任何东西。
- **目标 B（Lean 版本，避开 Hausdorff 维数）**：证明"对所有 j，C(1,2^a,2^b,2^c) 在模 3^{jL} 下至少有 2^j 个剩余类"
  （一个 Cantor 型计数下界）。或者反方向：对具体的三元组（例如 Table 5.2 中维数为 0 的三元组）证明集合可数，即剩余类个数有多项式上界。
- **可形式化程度：中**。具体的数字检验用 `Nat.digits` + `decide`/`norm_num` 可以做（数字不大时）；"dim_H > 0"这一结论需要
  ℤ_[3] 上 Cantor 集的 Hausdorff 维数，Mathlib 里没有现成结果（要从 `dimH` 的一般理论自己建，估计要几个月）。
  所以 Lean 里应该只做目标 B 的计数版本，dim_H 的推论标为 KNOWN（引 Lagarias Thm 1.7）+ 人工论证。
- **阻碍**：目标 A 可能无解；自动机方法（AL Thm 1.6）需要 Perron 特征值，Mathlib 没有；`native_decide` 被禁，大规模证书无法通过内核。

### 排名 3：s3(2^n) → ∞（相同数字连续段个数趋于无穷）（SKETCH，数学上可能容易，Lean 上很难）

- **背景**：ABL II 原文："it is not currently known whether b3(2^n) → ∞ … or whether s3(2^n) → ∞"。
- **论证草图**（SKETCH，未经审查）：若 2^n 有 s 段，每段数字为 d，占位置 [a,b)，则 2^{n+1} = Σ_{j=0}^{s} c_j 3^{e_j}，
  其中 0 = e_0 < … < e_s，c_j ∈ {±1, ±2}（相邻段数字不同，所以系数非零）。由于 3 ∤ c_j，任何不含 2^{n+1} 的子和的 3-adic
  赋值等于其中最小的 e_j，因此不为零；含 2^{n+1} 的真子和也不能为零（否则余下部分为零）。所以这是一个**非退化**的
  {2,3}-单位方程，项数有界、系数取自有限集；由 Evertse / van der Poorten–Schlickewei 的 S-单位定理，只有有限多个解。
  这个结果是无效的（不给出界）；Stewart 的 Baker 方法看起来可以推广到系数有界的情形，从而得到有效版本（未核实）。
- **意义**：结合 ABL 的框架，Conjecture B 会归结为"dim_H C(1,M) → 0 当 s3(M) → ∞"。注意 Q_k = (2^k 0^{k−1} 1)_3 的 s3 = 3，
  不构成反例；但这个归结后的问题本身是开放的，而且可能不成立。
- **新颖性**：ABL II（2015）说未知；我没有检索到之后的结果。草图越简单，越要担心它已经被别人写出过，或者有漏洞。
- **可形式化程度：很低**。Mathlib 没有 S-单位定理或子空间定理，也没有 Baker 定理；全部形式化需要几个月到几年。
  只能形式化"给定 s 段 ⇒ 方程形式与非退化性"这一组合约化部分（容易，用 `Nat.digits`、`padicValInt`）。
  按新规则，它不能作为单独结果。

### 排名 4：把 Dimitrov–Howe 的 25 推到 26–31 个 1（计算，KNOWN 方法）

- 目标：2^x 是至多 K 个不同 3 的幂之和 ⇒ x ∈ {0,2,8}，K > 25（只需 K 为偶数的情形）。检验方法清楚（模数链证书）。
- **可形式化程度：低**。证书检验要枚举大量元组（Thm 1.1 的 n = 22 用了约 7.4×10^5 秒 Magma），内核 `decide` 做不到，
  而 `native_decide` 被禁。小 K（例如 K ≤ 6）的 Lean 版本可行，但那是已知结论，价值很小。
- 阻碍：运行时间按大约每项 3–5 倍增长。

### 排名 5：Stewart 下界的显式常数（数字非零个数）

- 目标：给出显式的 c，使 #{2^m 的非零三进制数字} > log m/(log log m + c) − 3。按 DH 脚注，c 的显式值在文献中似乎没有（未核实）。
- **可形式化程度：几乎为零**（需要 Matveev/Laurent 型线性对数型下界，Mathlib 没有）。
- 另外，"数字 2 的个数"的下界被阻断：它蕴含猜想本身（见 §5）。

### 不推荐

- 用 Archimedean（高位）和 3-adic（低位）信息联合得到 β < α0（Lagarias §1.6 问题）：粗略计算（SKETCH，本人估算）表明，
  即使 log_3 2 的无理性度量为最优值 2，"Erdős–Turán 差异 + 剩余类"的朴素组合也恰好回到指数 α0，没有改进；
  用目前的无理性度量（约 14.3，Lagarias Lemma 2.2）则更差。因此需要新的想法，几周内做不到，Lean 上也不可行（需要差异理论）。
- 直接证明 dim_H E(Z_3) = 0（Conjecture B）或 E(Z_3) ≠ {0}：文献明确说未知；没有可行的途径。

---

## 附录 A：抓取记录（每页一次请求；时间来自 `date -u`，哈希来自 `sha256sum`）

| URL | UTC 时间 | HTTP | sha256 | 本地文件（specs/sources/） |
|---|---|---|---|---|
| https://arxiv.org/abs/2202.13256（前代抓取，见 status.md） | 2026-11-24 10:05 | 200 | `4254f10b99bb5abde709f0dde060d34f636bed8d0a592b1067932d83f3187ee1` | arxiv-2202.13256-abs.html |
| https://arxiv.org/abs/math/0512006 | 2026-11-24T10:11:26Z | 200 | `2642b39d679987259a76a18c204051ecc95517c13e9b2bf7c9ec49c4384771e8` | arxiv-math0512006-abs.html |
| https://arxiv.org/pdf/math/0512006 | 2026-11-24T10:11:29Z | 200 | `565446e1a1ad3a57f5adb20d500997fb45a2716c98b517c34f8f2d354587370c` | arxiv-math0512006.pdf |
| https://export.arxiv.org/api/query?search_query=all:%22ternary%22+AND+all:%22powers+of+2%22&max_results=50&sortBy=submittedDate&sortOrder=descending | 2026-11-24T10:11:32Z | 200 | `705fc6590f6e1ea4681587cf84806ec03c0abc13249cdb8641ff30f71a32567f` | arxiv-api-ternary-powers2.xml |
| https://export.arxiv.org/api/query?search_query=au:Lagarias+AND+au:Abram&max_results=20 | 2026-11-24T10:13:04Z | 200 | `2f5d7c574742889bcada48fcc2e8179eacfdb2bb764e47d0d5e9131ff8afb000` | arxiv-api-abram-lagarias.xml |
| https://export.arxiv.org/api/query?search_query=au:Dupuy+AND+au:Weirich&max_results=20 | 2026-11-24T10:13:09Z | 200 | `1049ac264b0dad00f760115ffdd7f8582ed10e6e32e0623219c16b10cca11035` | arxiv-api-dupuy-weirich.xml |
| https://export.arxiv.org/api/query?search_query=abs:%22ternary%22+AND+abs:%22Erdos%22&max_results=50&sortBy=submittedDate&sortOrder=descending | 2026-11-24T10:13:13Z | 200 | `cfe436a617dabf40162b1b4b645d65f43867aedd45abf171d4c343c12ea896ab` | arxiv-api-ternary-erdos.xml |
| https://export.arxiv.org/api/query?search_query=au:Dupuy&max_results=40 | 2026-11-24T10:13:25Z | 200 | `07da0d09f0bc4e33266d9a6717bec29d34521b77fc6bf2984f46c635c2675a7a` | arxiv-api-dupuy.xml |
| https://export.arxiv.org/api/query?search_query=abs:%22powers+of+two%22+AND+abs:%22ternary%22&max_results=50&sortBy=submittedDate&sortOrder=descending | 2026-11-24T10:13:30Z | 200 | `782ce96c7b3cbeed7bf42aa2ef136f02f5866596e51727d21700418b64a95c80` | arxiv-api-powersoftwo-ternary.xml |
| https://export.arxiv.org/api/query?search_query=abs:%22base+3%22+AND+abs:%22powers+of+2%22&max_results=50&sortBy=submittedDate&sortOrder=descending | 2026-11-24T10:13:34Z | 200 | `df0d7bd5f80dddef2124a8c92cd24cb18cef8f4bb10d726586ab640ab4fa820a` | arxiv-api-base3-powers2.xml |
| https://arxiv.org/abs/2610.03789 | 2026-11-24T10:13:49Z | 200 | `0d9a9076b82bba016b91339ec2d2f91c5dfcc578cd0df6c04ab8cca0cf71e6cf` | arxiv-2610.03789-abs.html |
| https://arxiv.org/pdf/2610.03789 | 2026-11-24T10:13:53Z | 200 | `a53e00f1dbbdfe338643d32a5116ee91f3c3445f11fc193c37b66744751f123f` | arxiv-2610.03789.pdf |
| https://export.arxiv.org/api/query?search_query=ti:%22Wieferich%22+AND+ti:%22Erdos%22&max_results=20 | 2026-11-24T10:13:57Z | 200 | `aaf3bcf8f0a139ef678c518002bb59fe690453ac9c817764a1e7116c24c27228` | arxiv-api-wieferich-erdos.xml |
| https://www.erdosproblems.com/406 | 2026-11-24T10:14:28Z | 200 | `544f9536b8d6cbe4828f64cd990c18e5073118f329ea2805e270deceb974e39d` | erdosproblems-406.html |
| https://export.arxiv.org/api/query?search_query=au:Dimitrov+AND+au:Howe&max_results=20 | 2026-11-24T10:14:33Z | 200 | `8375bd395449902c931663ce64a22d7c7d524ed580770fd23b994529627ab5a2` | arxiv-api-dimitrov-howe.xml |
| https://arxiv.org/abs/1308.3133 | 2026-11-24T10:14:37Z | 200 | `14060dc905dd167af3b431c24b905782d27e7a705953a6037d045469b7478702` | arxiv-1308.3133-abs.html |
| https://arxiv.org/pdf/1308.3133 | 2026-11-24T10:14:41Z | 200 | `9cdebcbd27a21d9edf2a21615abfba248098fd43f909e0fecb4d1277497a667a` | arxiv-1308.3133.pdf |
| https://arxiv.org/abs/1508.05967 | 2026-11-24T10:14:45Z | 200 | `b8924d42c2c5ce1995ad633f7828d50358223698e5afcc3ef48a6da75db9ca43` | arxiv-1508.05967-abs.html |
| https://arxiv.org/abs/2105.06440 | 2026-11-24T10:15:25Z | 200 | `9fddfc7be2fda9a7504f40dfdd65c5182bf45cfa08da9cf4141ec46d879ffec6` | arxiv-2105.06440-abs.html |
| https://arxiv.org/pdf/2105.06440 | 2026-11-24T10:15:29Z | 200 | `29dd17c6cd6bf16d7bc55fbf5686ae9d4a1c1c955ee71edc1b174e3e980c5794` | arxiv-2105.06440.pdf |
| https://arxiv.org/pdf/1508.05967 | 2026-11-24T10:15:33Z | 200 | `5162b18c9219b196c367ffa40837b9a2544b2e23770535ba95cfa499292e1eb7` | arxiv-1508.05967.pdf |
| https://export.arxiv.org/api/query?search_query=abs:%223-adic+Cantor%22&max_results=50&sortBy=submittedDate&sortOrder=descending | 2026-11-24T10:16:59Z | 200 | `72034286da32f39755fbd8be8b56015777b14d7c66c5bf2ba7f3a63dd56528ab` | arxiv-api-3adic-cantor.xml |
| https://export.arxiv.org/api/query?search_query=abs:%22ternary+digits%22&max_results=50&sortBy=submittedDate&sortOrder=descending | 2026-11-24T10:17:04Z | 200 | `effe8dd861a3d3e1613e009175775d2624d4127d44c614e89d2eb7f9ed1d3e0e` | arxiv-api-ternary-digits.xml |
| https://export.arxiv.org/api/query?search_query=abs:%22sum+of+distinct+powers+of+3%22+OR+abs:%22distinct+powers+of+three%22&max_results=50&sortBy=submittedDate&sortOrder=descending | 2026-11-24T10:17:13Z | 200 | `0899bd1186de97538fd3aee827ed4e7acaa54d36bc46c96e0612846aad0d324e` | arxiv-api-distinct-powers3.xml |
| https://export.arxiv.org/api/query?search_query=abs:Erdos+AND+abs:%22powers+of+2%22+AND+abs:digit&max_results=50&sortBy=submittedDate&sortOrder=descending | 2026-11-24T10:17:20Z | 200 | `5a0b07fac68176a4eb722f915ba017fec81f4cf30f5f30e070a4b6abe0f8a9bf` | arxiv-api-erdos-powers2-digit.xml |
| https://arxiv.org/abs/2511.03861 | 2026-11-24T10:17:33Z | 200 | `5ee3a0d865e2d7ae9d0b708ff1c4831d85726fd1b837816b47d4d0d7a7e9a21f` | arxiv-2511.03861-abs.html |
| https://arxiv.org/pdf/2511.03861 | 2026-11-24T10:17:38Z | 200 | `2e473328a1646ed2ad0382be5f685be132fc2f9ade5b269109d9e7aa1bc7f07b` | arxiv-2511.03861.pdf |
| https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=activity&q=powers%20of%202%20ternary&site=mathoverflow&pagesize=50 | 2026-11-24T10:17:54Z | 200 | `ae1d600165e78b31c7e08bf0ff1db2b1e58b9694e0660231da8e6d6d55d863c9` | mo-search-powers2-ternary.json |
| https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=activity&q=Erdos%20base%203%20powers%20of%20two&site=mathoverflow&pagesize=50 | 2026-11-24T10:17:59Z | 200 | `24b56926ac311b2b9a0c00457409a16f71f57a0f69f5bde21a3f4636b1427695` | mo-search-erdos-base3.json |
| https://cs.uwaterloo.ca/journals/JIS/VOL25/Saye/saye3.html | 2026-11-24T10:18:03Z | 200 | `75698c16bc2f158550e704c5968dc4ad5734f4e51320cee1a1f32922b0424233` | jis-saye3.html |
| https://doi.org/10.1016/j.jnt.2015.05.022 | 2026-11-24T10:18:07Z | 200 | `defc56de509292fdb1334293bccce775c3b00a33296503aec9b7240840d823ac` | doi-dupuy-weirich.html |
| https://www.sciencedirect.com/science/article/pii/S0022314X15002139 | 2026-11-24T10:18:40Z | 403 | `384a72eec624cedfe7b8ac59a6512beab2c5cbb4f9de5547f5937f91a4a1d01f` | sciencedirect-dupuy-weirich.html |
| https://export.arxiv.org/api/query?search_query=ti:Bits+AND+ti:binary+AND+ti:Wieferich&max_results=20 | 2026-11-24T10:18:45Z | 200 | `28c6d1688e727b6e4bd31772ce27ca8f33f1fafb8b5c6e14a92150a07b6be7ca` | arxiv-api-bits-wieferich.xml |
| https://api.stackexchange.com/2.3/questions/30357?site=mathoverflow&filter=withbody | 2026-11-24T10:18:50Z | 200 | `2b3031ea697aa24155f1e00e36779b8698d3b99ecabbd28cc708cabfb98d1958` | mo-30357-question.json |
| https://api.stackexchange.com/2.3/questions/30357/answers?site=mathoverflow&filter=withbody&order=desc&sort=votes | 2026-11-24T10:18:54Z | 200 | `9d3623c1cd77e176a3988c92fee16c7e8b5773955a9e10564b380e5d37e428f4` | mo-30357-answers.json |
| http://www.math.uwaterloo.ca/PM_Dept/Homepages/Stewart/Jour_Books/J-reine-ange-Math-1980.pdf | 2026-11-24T10:19:10Z | 200 | `5333748205b96dc477858962a6b955e8af4314928e381df219e74e24fa03d584` | stewart-1980-crelle-redirect.html (saved as .pdf, renamed: content is HTML) |
| https://doi.org/10.1515/crll.1980.319.63 | 2026-11-24T10:19:15Z | 202 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | doi-stewart-1980.html |
| https://doi.org/10.7546/nntdm.2023.29.3.474-485 | 2026-11-24T10:19:20Z | 200 | `3a17d3b025e9ca338b12b8a7b77c6e5884cc011f906d2b4a6bf35007b17fc9f0` | doi-aliyev-2023.html |
| https://api.openalex.org/works/doi:10.1016/j.jnt.2015.05.022 | 2026-11-24T10:19:47Z | 200 | `9812a9ca09ab03f6daebc6e86b6269b9beb7d7210d38bcfa874ac010363c0926` | openalex-dupuy-weirich.json |
| https://api.openalex.org/works/doi:10.1515/crll.1980.319.63 | 2026-11-24T10:19:52Z | 200 | `15f206949c8b2226a5d8501b4e4a7c444451f87c7719e0e2d91235b60f26b5bc` | openalex-stewart-1980.json |
| https://api.stackexchange.com/2.3/questions/172826?site=mathoverflow&filter=withbody | 2026-11-24T10:20:06Z | 200 | `22dc35727110593e6310c27a9703cd8e57ee61d441124d9f9c3bc01ca2b8d818` | mo-172826-question.json |
| https://api.stackexchange.com/2.3/questions/172826/answers?site=mathoverflow&filter=withbody&order=desc&sort=votes | 2026-11-24T10:20:10Z | 200 | `29db35f41cb0bb74c74e3562d9f8a10e97374a6bca97683bd96ae72906ea2f8f` | mo-172826-answers.json |

PENDING 汇总：ScienceDirect（Dupuy–Weirich）HTTP 403，已停止；Stewart 1980 的 DOI 返回 HTTP 202 且内容为空，作者主页链接已失效；
Narkiewicz 1980 原文没有找到在线来源（未请求）；erdosproblems #406 的明文状态字没有找到。
