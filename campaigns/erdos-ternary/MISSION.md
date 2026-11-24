目标
解决 Erdős 三进制猜想（Erdős 1979）：对所有 n > 8，2^n 的三进制展开至少含一个数字 2。
等价地：使 2^n 的三进制展开只含 0 和 1 的 n 恰为 0、2、8。
"解出"只有两种：(a) 一个完整证明，经冻结的形式化陈述在 Lean 4 中通过内核检查，
或经三怀疑者小组全部通过并由人（T5）认可；(b) 一个反例 n > 8，由 verify/ 的独立检查器确认。
在此之前，舰队通过两条轨道持续产出中间成果。

成果的唯一形式（v0.2，人定）：一个 Lean 4 + Mathlib 定理，同时满足
(1) 在 lean/ 工程中 lake build 编译通过；
(2) python3 verify/lean_audit.py 判 PASS：无 sorry/admit/新 axiom/unsafe/implemented_by/extern 等，
    #print axioms 只含允许的公理；
(3) 独立审计员（roles/lean_auditor.md，全新上下文，只看 Lean 源文件和非形式陈述）判定
    Lean 陈述忠实表达了声称的命题，且没有利用定义漏洞；
(4) 里程碑级成果还需三怀疑者小组通过。
公理分级：A 级只用 propext、Classical.choice、Quot.sound；B 级另含 Lean.ofReduceBool / Lean.trustCompiler
（即用了 native_decide，信任 Lean 编译器）。每条成果必须标明级别，B 级成果必须在报告中写明所信任的内容。
C/Python 搜索、Markdown 证明稿只是探索工具和草稿，本身不是成果。

计算轨道 C：得到 Lean 定理 ErdosTernary.UpTo N（verify/Statement.lean 中冻结的定义），N 推过公开纪录。
可行路线：在 Lean 中写树搜索检查器，用 Lean 证明其可靠性（返回 true ⇒ UpTo N），再对具体 N 求值
（小 N 用 decide 达 A 级；大 N 用 native_decide 达 B 级）。C 引擎用于探索、调度和交叉核对。
理论轨道 P：在 Lean 中证明文献中没有的部分结果（引理、计数上界、3-adic 结构命题）。
现状（阶段 0 须按一手来源复核，读不到就写 PENDING STATUS CHECK）：
Saye 2022（arXiv:2202.13256，JIS vol. 25）：16 ≤ n ≤ 2·3^45 时 2^n 三进制含全部三种数字。
更早 Vardi：n ≤ 2·3^20 无反例。Lagarias 2009（arXiv:math/0512006）给出 3-adic 动力系统框架。
这些是本项目的起点和新颖性门槛，不是本项目的成果。

目录
search/ 可写。计算轨道代码：树搜索、分片调度、证书生成。C/C++/Python 均可
lean/ 可写（lean/ErdosTernary/ 下）。全部成果的 Lean 源文件。Lake 工程，Mathlib 版本见 lean/lakefile.toml
proofs/ 可写。非形式证明草稿（只作草稿，不是成果）
specs/ Researcher 写。文献摘录、公式、已知结果与出处
verify/ 阶段 0 建好后冻结，只读。独立检查器、T0 测试、冻结的形式化陈述
certs/ 只追加。计算证书（分片清单、计数、哈希），大文件只存清单与哈希
ledger/ 只追加。experiments.jsonl
reports/ 每代一份报告，外加 STATUS.md
panel/ 三怀疑者小组的独立审查记录
proposals/ 你想改规则时写这里
tools/ 解包等辅助脚本，非成果代码

计算轨道接口（固定，不得更改）
python3 search/run.py --N <上界> --shard <i>/<m> --out certs/<id>/shard_<i>.json
输出 JSON：{"N", "shard", "depth_counts": [每层存活节点数], "exceptions": [找到的全展开无 2 的 n],
"leaf_digest": 按 verify/CERT.md 规定算出的 sha256, "wall_s"}。
同一输入必须逐字节可复现（wall_s 除外）。全部分片的并集须覆盖 0 ≤ n ≤ N。

数学背景（Planner 与 Implementer 共用，Researcher 负责核实）
3^k 的模 2 乘法阶为 P_k = 2·3^(k-1)（k ≥ 1）。2^n mod 3^k 只依赖 n mod P_k。
节点 (k, r)：0 ≤ r < P_k，且 2^r mod 3^k 的低 k 位三进制数字无 2。
子节点 r + j·P_k（j = 0,1,2）：由于 2^(P_k) ≡ 1 + c·3^k (mod 3^(k+1)) 且 3 ∤ c，
三个子节点的第 k 位恰好取遍 0、1、2，每个节点恰有 2 个存活子节点。
剪枝：类的最小代表 r > N 则剪掉；若 3^k > 2^r（数字已全部确定）而 r 仍存活，r 是例外，须报告；
该类在 r + P_k ≤ N 时仍含其他成员，必须继续展开（阶段 0 校准曾因漏掉这一点而失败，见 reports/calibration.md）。
精确规则以 verify/CERT.md 为准。
对 N ≈ 3^K，访问节点数约 3·2^K。2·3^45 对应约 2^46 量级节点。

阶段 0：搭台（只做一次）
0.1 预检。检查 git、Python、C 编译器、CPU 核数、内存、磁盘、能否联网装包、
能否安装 Lean 4 + Mathlib（elan），你能否并行派生子 agent（Agent 工具、远程会话或 claude -p）。
记录本容器会被回收：所有状态必须提交并推送到工作分支，长计算必须可断点续跑。
结果写 reports/preflight.md。不能并行就串行扮演各角色。
0.2 按 VERIFY.md 建验证器和 T0 测试。
0.3 校准。用验证器跑已知事实：n ≤ 20000 暴力展开，例外集合必须恰为 {0, 2, 8}；
小深度存活计数必须与暴力枚举一致；对一个人为构造的错误证书必须判不通过。
写 reports/calibration.md。任何一项不符就停下。复核 Saye 纪录的一手来源，写入 specs/status.md。
0.4 冻结。对 verify/ 全部文件算 SHA-256 写入 verify.lock，去掉写权限。
config.auto_freeze 为 false 时在此停下等人确认。
为 true 时须满足 config.freeze_checks 的全部条件才可继续，否则停下。
0.5 种子。search/ 下写最简树搜索（纯 Python 大整数，单分片）作为 g0；
proofs/ 下写 proofs/g0-baseline.md，整理已知的初等事实（周期 P_k、恰 2 子节点引理及其证明）。
g0 通过 T0 后写入账本和种群。

阶段 1：迭代循环（每代）
1. 校验 verify.lock。哈希不符立即停止并报告。
2. 读 reports/STATUS.md、最近 50 条账本、certs/ 进度、proposals/ 的人类答复。
3. Planner 出 k 个假设，计算轨道和理论轨道各至少 config.generation.min_per_track 个。
4. 需要规格的假设先交 Researcher（文献核实、公式、已知结果）。
5. k 个 Implementer 并行，各自一个分支或工作树，只实现一个假设。
计算假设：通过 T0 后跑 T1 基准（固定预算），报吞吐量（节点/秒）和外推的完成时间；
涉及 Lean 检查器的，另报 Lean 中的吞吐量与可靠性定理的状态。
理论假设：写出证明稿，然后在 lean/ErdosTernary/ 中形式化；lake build 与 verify/lean_audit.py 都通过才可提交。
6. Critic 逐个审查，给出 accept、reject 或 escalate。声称为成果的，另派独立审计员（roles/lean_auditor.md）
在全新上下文中审计；审计不通过的只能作为中间产物入种群，不得计入主指标。
7. 接受的版本进种群，按 Pareto 前沿（吞吐量、已验证 N、已证引理数）保留 population_size 个。
8. 前沿最优的计算版本继续推进长跑（见下"长跑"）。
9. 追加账本，写 reports/gen_NNN.md，覆盖写 reports/STATUS.md，提交并推送。

长跑
扩展纪录的计算可能持续数天。按分片执行，每片 nice、timeout、断点文件、记录 PID。
每代结束前把完成的分片证书提交推送。验证器按 config.verify.recheck_fraction 随机抽查已完成分片，
抽中分片由 verify/ 的独立实现重算，计数和 leaf_digest 必须逐项一致。
已验证 N 只在全部分片完成且抽查全部通过后更新。

里程碑
M1 复现 主指标 Lean 中已证的 UpTo N。过关：Lean 定理 UpTo (2·3^20)（A 或 B 级），审计通过；
   并有 Lean 证明的检查器可靠性定理
M2 计算纪录 主指标 Lean 中已证的 N。过关：Lean 定理 UpTo N，N > 2·3^45（严格超过 Saye），B 级即可，
   审计通过，三怀疑者小组通过
M3 部分定理 主指标 经确认的新 Lean 定理数。过关：至少 1 条文献中没有的命题，Lean 证明审计通过，
   小组 CONFIRMED_PARTIAL
M4 证明 主指标 无，二值。过关：Lean 定理 ErdosTernary.Statement 的证明，A 级，审计通过，小组通过，人认可
M1 之后，M2 与 M3 并行推进；M4 永远开放，任何一代都可以提交 M4 尝试。
过关后由三怀疑者小组复核（roles/skeptic.md），通过才进入下一里程碑。
前一里程碑的指标自动转为约束：吞吐量退步超过 5% 的计算版本不接受。

停止并等人
* verify.lock 校验失败
* Critic 给出 escalate
* 找到疑似反例（立即停所有长跑，保存现场，三怀疑者复核，不对外公开）
* 声称完成 M4（不论信心多高）
* lean/ 工程无法编译，或 verify/lean_audit.py 自身无法运行
* 连续 stall_generations 代所有轨道主指标都无提升（先写一份原因分析）
* 任一预算上限触发
* 你认为某条约束妨碍进展（写 proposals/，不要自行绕过）
