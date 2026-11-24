# Critic: g002-L02（commit 1399d42，父 4b4d3c7）

**Verdict: ACCEPT**（作为 PROMISING 的 M3 候选，送三怀疑者小组；独立审计员一项尚未做）

## 1. 改动范围
- `git diff --stat 4b4d3c7 1399d42`：只有 4 个文件：`lean/ErdosTernary.lean`（+1 行 import）、
  `lean/ErdosTernary/Counting.lean`（+392）、`proofs/g002-L02.md`（+91）、`proofs/g002-L02_num.py`（+73）。
  都对应假设（加上 orchestrator 中途改定的目标 (c)），没有夹带无关改动。
- verify/ 未改：`git diff --stat 4b4d3c7 1399d42 -- campaigns/erdos-ternary/verify` 输出为空；worktree 中
  `python3 tools/check_lock.py` → `LOCK: OK`。
- `grep -nE "sorry|admit|axiom|native_decide"` 在 Counting.lean 中只命中第 2 行注释（"Tier A: no native_decide"）。
  `card_tree_zero` 用的是 `decide`（内核求值），不是 native_decide。
- 冻结定义：Statement.lean 只冻结了 `Statement` 和 `UpTo`，没有冻结的计数函数。三条成果定理把谓词
  `2 ∉ Nat.digits 3 (2 ^ n)` 直接写在陈述里，与 `Statement` 的写法一样，没有重新定义同名概念
  （第 12 条没有问题；仍请审计员核对）。辅助定义 `tree`、`low` 只出现在证明内部，不在陈述里。

## 2. Lean 重跑（一次）
`export PATH=$HOME/.elan/bin:$PATH; python3 verify/lean_audit.py ErdosTernary.Counting ErdosTernary.Counting.card_noTwo_le_succ_rpow`
（在 worktree 中运行，real 3.7 s）最后一行：

    LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']

（前面输出 `Build completed successfully (4215 jobs).`）其余两条定理没有重跑，用的是 Worker 报告的结果。

## 3. 数学核查：定理 3，A(X) ≤ (X+1)^α，α = log_3 2
Lean 定义 `low k Y = #{r < Y : 2^r 的低 k+1 位 trit 都 ≠ 2}`，周期 P = 2·3^k。我逐步核了引理 E（`low_le_rpow`：Y ≤ 2·3^k ⇒ L_k(Y) ≤ Y^α）：
- k = 0：T_0 = {0}（2^0 = 1，2^1 = 2），L_0(0) = 0，L_0(1) = L_0(2) = 1 ≤ Y^α。成立。
- 情况 1（Y ≤ 2·3^k）：L_{k+1} ≤ L_k（条件更多，`low_succ_le`），再用归纳假设。成立。
- 情况 2（3^{k+1} ≤ Y ≤ 2·3^{k+1}）：L_{k+1}(Y) ≤ |T_{k+1}| ≤ 2^{k+1} = (3^{k+1})^α ≤ Y^α。成立。
- 情况 3（2·3^k < Y < 3^{k+1}，Y = P + s，0 < s < 3^k）：
  - **计数**：L_{k+1}(Y) ≤ L_k(P+s)（丢掉第 k+1 位）。由于低 k+1 位只依赖 r mod P（引理 C，`good_iff_mod`），
    L_k(P+s) = |T_k| + L_k(s) ≤ 2^k + L_k(s)（Lean 中是 `low_add_le`，用并集加 image 证明，给的是 ≤，够用）。
    再用归纳假设 L_k(s) ≤ s^α（s < 3^k ≤ 2·3^k，在适用范围内）。**成立：count ≤ 2^k + (s 的计数)。**
  - **优超**：c = s，b = 3^k，a = Y = 2·3^k + s，d = 3^{k+1}。有 0 ≤ c ≤ b ≤ a ≤ d（a ≤ d 因为 s < 3^k），
    且 a + b = 3^{k+1} + s = c + d。所以 (c, d) 优超 (a, b)，凹函数满足 f(c) + f(d) ≤ f(a) + f(b)。
    `concave_two_point` 正是这一步：把 a、b 写成 c、d 的凸组合，系数为 λ = (d−a)/(d−c) 及其互换，两次用凹性后相加。
    x ↦ x^α（0 ≤ α ≤ 1）在 [0, ∞) 上凹（`Real.concaveOn_rpow`）。
    得到 s^α + 2^{k+1} ≤ Y^α + 2^k，即 **2^k + s^α ≤ Y^α**。**不等式正确。**
  - 补充核验（手算）：s → 3^k 时上式变成 2^k + 2^k ≤ (3^{k+1})^α = 2^{k+1}，取等号，与 X = 2 处的紧性一致。
- 最后一步：取 k = X，X + 1 ≤ 2·3^X；A(X) ≤ L_X(X+1)（引理 A：digits 中没有 2 ⇒ 每一位 trit ≠ 2）。成立。
- 没有启发式，没有循环论证，没有用到与猜想等价的假设。证明只用了 |T_k| ≤ 2^k 和周期性，与纸面证明的说法一致。
- 值得指出：因为 (X+1)^α/X^α → 1，定理 3 给出 limsup A(X)/X^α ≤ 1，**渐近**上严格好于 2^{1−α} ≈ 1.2915 和 1.3；
  而在"对所有 X"的意义下，(X+1)^α 形式的常数 1 已经最优（X = 0、2 取等号，见 specs §5）。

## 4. 级别标签（第 3 条）
- 引理 A–E 及定理 1、推论 2、定理 3 标 LEAN-VERIFIED，与 Lean 文件一致。
- 定理 1 标"数学上 KNOWN"，引 Narkiewicz（经 Lagarias Thm 1.4 转述）和 Holdum–Klausen–Rasmussen 2015 Lemma 2.12，
  并注明"本人未打开原文"（第 1、10 条：正确）。推论 2 标"KNOWN 的推论"（Lagarias 证明中隐含 2^{1−α}）：正确。
- 定理 3 写的是"Researcher 在文献中未找到，待独立判断"，没有写"新"或"首次"：措辞诚实。
- |T_k| = 2^k 的等号标 PROVED-HERE，并注明只形式化了上界：正确。"评述"一段标 HEURISTIC/事实陈述，
  并说明不触及猜想本身：正确。数字与 `g002-L02_num.py` 的输出一致（脚本没有重跑）。
- 小问题（不影响结论）：纸面证明没有把 Holdum Thm 2.13（S(a) ≤ 1.3·a^α，即 A(X) ≤ 1.3(X+1)^α）列为 (c) 的直接比较对象。
  建议在文中补一句"(c) 把 Holdum 等 2015 的常数 1.3 改为最优的 1"，让小组一眼看清改进幅度。

## 5. 新颖性
- specs/narkiewicz1980.md §6：(a)(b)(d) 是 KNOWN；(c) 在打开过的来源中 NOT FOUND。已发表的最好常数是 Holdum 等
  2015 的 1.3（(X+1)^α 形式）。(c) 把它改到 1，是一个**不大的改进**：只改常数，对 Erdős 猜想本身没有影响（真实的 A(X) = 3）。
- 保留：Narkiewicz 原文、Hardy 的 MR 评论、Schinzel 2008 综述都没有打开，所以"文献中没有"只是"检索范围内没找到"。
  另外，论证初等（周期性加凹性优超），有被视为 folklore 的风险。小组应当把这两点当作主要质疑对象。
- 所以它满足 M3 的字面条件（至少一条文献中没找到的命题、tier A、审计 PASS），但分量不大，状态最多写 PROMISING。

## 6. 预测
预测 +1 条 tier-A 定理；实际 3 条 tier-A（1 条新，2 条 KNOWN）。偏差远小于 prediction_miss_factor = 5，不需要解释。

## 7. 结论
- verdict：**accept**。
- 是 M3 的合格候选：可以送三怀疑者小组。送之前要做完第 11 条第三项（独立审计员）；小组重点审新颖性
  （Holdum 1.3 → 1，以及未打开的 Narkiewicz 原文和 Schinzel 综述）。
- lesson：只用剩余类个数的论证，常数卡在 2^{1−α}；再加一层"一个周期加一段短尾巴"的递归和凹性优超，
  就能把 (X+1)^α 形式的常数压到最优的 1。这个技巧便宜、可以在 Lean 中完成，但只改进常数。
