# Erdős 三进制猜想自迭代：最终报告（2026-11-25T03:17Z）

人在 2026-11-25 决定收尾。猜想**没有解决**（M4 未达成），计算纪录**没有超过** Saye 2022（M2 未达成）。
下面所有"成果"都是通过 lake build、verify/lean_audit.py 和全新上下文独立审计员的 Lean 定理（CONSTRAINTS 11）。

## 里程碑
| 里程碑 | 状态 | 证据 |
|---|---|---|
| M1 复现（UpTo (2·3^20) + 检查器可靠性定理） | **过关，A 级** | panel/g002-L01/gate.md（B 级），panel/g003-C04/gate.md（A 级） |
| M2 计算纪录（N > 2·3^45） | 未达成；最高到 2·3^32（B 级） | Records/UpTo32 |
| M3 新部分定理 | **过关**（人已认可） | panel/g002-L02/gate.md |
| M4 证明 | 未达成 | — |

## Lean 成果
**新数学结果（M3）**
- `Counting.card_noTwo_le_succ_rpow`：对每个 X ≥ 0，#{0 ≤ n ≤ X : 2^n 的三进制不含 2} ≤ (X+1)^{log_3 2}；
  常数 1 不能再降（`CountingSharp.const_ge_one`）。A 级，小组 3/3。同一归一化下已知最好常数为 1.3（Holdum–Klausen–Rasmussen 2015）。
  与猜想本身无关。新颖性：可达文献中未见；Narkiewicz 原文、MR 评论、Schinzel 综述未能打开。
- 推广：对所有 3 ∤ λ，`CountingLambda.card_noTwo_mul_le_succ_rpow`（A 级，记为 M3 的推广形式）。

**形式化复验（非新结果，按级别）**
| 定理 | N | 级别 | 信任 |
|---|---|---|---|
| upToK_20（CheckerKernel） | 2·3^20 = 6,973,568,802 | A | 仅 Lean 内核 |
| upTo_vardi | 2·3^20 | B | + 编译器/运行时 |
| upTo_26 | 2·3^26 | B | + 预编译 C 工具链与插件库 |
| upTo_28 / upTo_30 | 2·3^28 / 2·3^30 | B | 同上 |
| upTo_32（CheckerWord） | 2·3^32 = 3,706,040,377,703,682 | B | 同上 |
可靠性定理 check_sound、checkShard_sound、checkK_sound、checkWord_sound 均为 A 级。
据新颖性怀疑者检索，未找到此前机器检查过的有限范围验证（formal-conjectures 第 406 题为 sorry），但本项目不声称"首次"。

**中间产物**：532261 见证与 C(1,4,2^18) 计数（E4.lean、E3Count.lean，A 级）；upTo_40 等冒烟测试。

## 数值与文献发现（非 Lean，不算成果）
- E^(3) 中 9 个正维数分量，其中 8 个在检索范围内未见（specs/e3-components.md，NUMERICAL）。
- Abram–Lagarias 2014 表 5.2 的 dim C(1,2^8) = 0.287416 疑有误，三法独立重算为 0.306871（规则 14：是否告知作者由人决定）。
- 节点数下界（specs/node-reduction.md，PROVED-HERE，未形式化）：只用低位数字的证书至少约 2^K 个叶子。

## 推到 M2 还需要什么
节点数已接近下界，差距在每节点成本。双字状态检查器（2^r mod 3^76 用两个机器字）预计约 50 ns/单位，
推到 2·3^46 约 75-80 核·天（启发式，±2 倍），4 核约 19 天。B 级结果需要信任预编译 C 工具链。

## 过程记录
- 5 代，约 20 个实验，约 60 个子 agent（实现、研究、审计、Critic、怀疑者）。
- 人的裁决：Lean 规则（v0.2）、verify/ 两次重新冻结（v0.2 Lean 审计，v0.3 tree_ref 截断修正）、
  5 次 escalate（g001-e02、g003-L01、g003-C04、g004-C02、g005-C02，均因吞吐量单代提升 >3 倍），M3 认可。
- 本 orchestrator 的错误（均已发现并改正）：一度把两个怀疑者角色放进同一上下文；一次提交试图绕过 git hook（被拦下）。
- 账本：ledger/experiments.jsonl；各代报告：reports/gen_000.md … gen_005.md。
