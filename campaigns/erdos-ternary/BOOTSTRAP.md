BOOTSTRAP.md — Erdős 三进制猜想 · 自动迭代包 v0.2
你是本项目的 orchestrator。
第一步：把下方每个 "=== FILE: 路径 ===" 段落原样写入对应路径（路径相对于本文件所在目录
campaigns/erdos-ternary/；可用 python3 tools/unpack.py 完成），然后从 MISSION.md 的阶段 0 开始执行。
本文件和 CONSTRAINTS.md 你无权修改。想改规则，写到 proposals/ 等人处理。
本仓库的 AGENTS.md 与 kit/RULES.md 同样约束你；二者与本包冲突时以 kit/RULES.md 为准，并写 proposals/。
修订记录：v0.2（2026-11-24，由人提出）——所有成果必须是 Lean 4 定理，经 lake build 编译通过、
经 verify/lean_audit.py 公理审计通过、并经独立审计员（全新上下文）审计通过，才算成果。
C 或 Python 程序的输出、Markdown 证明稿都只算中间产物，不算成果。

=== FILE: MISSION.md ===
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

=== FILE: CONSTRAINTS.md ===
以下规则任何角色不得违反，违反的提交一律作废。

1. 不得伪造。每个数字、时间、哈希、计数都来自命令的实际输出。没有运行的计算不得写结果。
没有打开过的文献不得引用；凭记忆写的出处必须标"未核实"。
2. 计算轨道的结论只能是"对 0 ≤ n ≤ N 无反例"，N 必须由完整、无上限截断的覆盖得出。
有任何未完成、超时或被跳过的分片，N 不得更新。
3. 草稿中的每个命题必须标级别：LEAN-VERIFIED（已满足第 11 条）、PROVED-HERE（纸面完整证明，尚未形式化）、
SKETCH、HEURISTIC、SPECULATION、KNOWN（附出处）。只有 LEAN-VERIFIED 算成果。
Lean 文件中出现 sorry、admit、新 axiom 或改动冻结陈述的，一律不算证明。
4. 启发式论证（"数字随机，所以概率为零"）不得写成证明。概率模型只能标 HEURISTIC。
5. 除阶段 0 外，任何角色不得写 verify/。冻结陈述 verify/Statement.lean 不得被改写或绕开。
6. 状态词只降不升。只有三怀疑者小组全部通过才能写 CONFIRMED_*；单一上下文最多写 PROMISING。
不得写"解决""突破""首次""世界纪录"，除非 M4 已经小组确认且人已认可。
7. 不对外行动：不发邮件、不发帖、不开 issue、不向期刊或 arXiv 投稿。对外由人决定。
推送只推到本会话指定的工作分支。
8. 计算只在本容器内进行，nice 运行，记录 PID，只结束自己启动的进程，禁止 pkill/killall。
并行任务的内存总和不超过空闲内存的一半。
9. 不得修改 verify/ 的检查器来让结果通过。检查器不通过就是不通过。
10. 引用前人：用到的结果、数据和代码写明作者和链接（Erdős、Vardi、Lagarias、Narkiewicz、Saye 等）。
11. 所有成果都必须是 Lean 定理：lake build 通过、verify/lean_audit.py 通过、独立审计员通过。
未满足三者的任何东西（C 程序输出、证明稿、数值实验）不得写成成果，不得计入里程碑主指标。
12. 不得修改 verify/Statement.lean 中冻结的定义，不得在 lean/ 中重新定义同名概念来"替换"它；
成果定理必须直接使用冻结的定义（审计员核对）。
13. native_decide 只允许用于对具体数值求值，且成果须标为 B 级；不得用 native_decide 证明含自由变量的一般命题。

=== FILE: VERIFY.md ===
verify/ 内容（阶段 0 准备，此后冻结）

* verify/brute.py：直接用 Python 大整数把 2^n 转三进制，返回 n ∈ [a, b] 中不含 2 的 n。
* verify/tree_ref.py：树搜索的独立参考实现（与 search/ 代码不共享任何源码），
给定 N 和分片，输出每层存活计数、例外列表、leaf_digest。必须与 search/ 输出逐项一致。
* verify/CERT.md：分片划分规则（按深度 d0 的存活前缀均分）、leaf_digest 的定义
（按层遍历序把每个被剪枝或终止节点的 (k, r, 原因) 序列化后取 sha256）、证书 JSON 格式。
* verify/check_cert.py：读一组分片证书，检查覆盖完整、计数一致、例外集合，按抽查比例调用 tree_ref.py 重算。
* verify/test_T0.py：T0 测试（见下）。
* verify/Statement.lean：Lean 4 冻结定义（不含证明）：
def ErdosTernary.Statement : Prop := ∀ n : ℕ, 8 < n → 2 ∈ Nat.digits 3 (2 ^ n)
def ErdosTernary.UpTo (N : ℕ) : Prop := ∀ n : ℕ, n ≤ N → 8 < n → 2 ∈ Nat.digits 3 (2 ^ n)
lean/lakefile.toml 以 lean_lib Frozen（srcDir = "../verify"）引入它。
* verify/lean_audit.py：python3 verify/lean_audit.py <模块> <定理> [--expect Statement|UpTo:<N>]：
lake build 该模块；扫描源文件禁用词；#print axioms 判定 A/B 级；--expect 时检查定理类型
与冻结定义一致（用 example : <冻结命题> := <定理>）。末行 LEAN_AUDIT: PASS tier=A|B 或 LEAN_AUDIT: FAIL。

分层
T0 正确性（确定性单测，全部通过才计后续分数）
* 暴力：n ≤ 20000 的例外集合恰为 {0, 2, 8}
* 恰 2 子节点引理在 k ≤ 40 上逐层数值成立
* search/run.py 与 verify/tree_ref.py 在 N ∈ {10^3, 10^5, 2·3^12} 上计数、例外、leaf_digest 全一致
* 分片：m ∈ {1, 3, 7} 时各分片计数之和等于不分片结果
* 人为篡改一个分片证书（改计数或删一个分片）时 check_cert.py 必须判失败
T1 吞吐量：固定 N = 2·3^24，单核和全核各跑一次，报节点/秒和总耗时，3 次取均值和标准差
T2 规模：外推到 N = 2·3^46 的预计 CPU 小时数（由 T1 吞吐量和 3·2^K 节点模型计算）
T3 纪录：已验证 N（只在全部分片完成且抽查通过后更新）
T4 Lean：每条成果的 lake build 结果、lean_audit 级别、独立审计结论、新颖性检索记录、小组结论
T5 人：M4 和 M3 的最终认可由人完成，不在自动循环内

规则
* 吞吐量差距小于 2 倍标准差视为无差异。
* 每个计算实验的 T1 运行次数上限见 config.eval_quota_per_experiment。
* 抽查不得由产生该分片的同一份代码完成。

=== FILE: config.yaml ===
problem: erdos-ternary-powers-of-two
record_to_beat: "2*3^45"   # Saye 2022；阶段 0.3 复核一手来源后确认，此后不改
auto_freeze: true
freeze_checks:
  brute_exceptions_exactly_0_2_8: true
  tree_ref_matches_brute_up_to: 20000
  tampered_cert_rejected: true
generation:
  k_hypotheses: 6
  min_per_track: 2
  min_targeting_bottleneck: 2   # 针对当前最大瓶颈（吞吐量或最弱引理）
  min_exploratory: 1
  population_size: 8
  stall_generations: 6
benchmark:
  T1_N: "2*3^24"
  repeats: 3
eval_quota_per_experiment: 2
verify:
  recheck_fraction: 0.0005      # 长跑分片的独立抽查比例（参考实现约 6e6 事件/秒，校准后定）
  min_rechecked_shards: 5
long_run:
  max_shard_wall_hours: 2
  nice: 15
gates:
  M1_reproduce_N: "2*3^20"
  M1_count_match_depth: 30
  M2_verified_N_min_exclusive: "2*3^45"
  M3_confirmed_new_statements_min: 1
escalate:
  single_gen_throughput_jump: 3.0   # 吞吐量单代提升超过 3 倍一律 escalate 复查
  prediction_miss_factor: 5
budget:
  max_generations: 200
  max_wall_hours: 24     # 人定（2026-11-24）：自动续跑总时长上限
  generation_interval_hours: 2   # 人定：每 2 小时触发一代
  max_parallel_workers: 4
  max_spend: null        # 人定（2026-11-24）：不设花费上限，只按墙钟 max_wall_hours 控制

=== FILE: ledger/SCHEMA.md ===
experiments.jsonl 每行一条，只追加：
{
"id": "g012-e07",
"parent": "g011-e03",
"track": "C | P",
"milestone": "M2",
"hypothesis": "一句话，只含一个机制",
"prediction": {"metric": "T1.nodes_per_s", "delta": "+40%"},
"touched": ["search/kernel.c"],
"result": {"T0": "pass", "T1.nodes_per_s": 2.1e8, "std": 3e6},
"claim_level": "仅理论轨道：PROVED-HERE | SKETCH | HEURISTIC | SPECULATION | KNOWN",
"verdict": "accept | reject | escalate | failed_T0 | not_implemented",
"lesson": "一句话",
"cost": {"wall_min": 42}
}
prediction 必须在运行评估之前写入。

=== FILE: roles/planner.md ===
你负责为第 {gen} 代提出 {k} 个实验假设。
输入：当前里程碑和主指标，种群各版本分数，最近 50 条账本记录，certs/ 长跑进度，specs/ 已知结果。
要求：
* 每个假设只改一个机制，写明预测影响的指标、方向和幅度。
* 计算轨道和理论轨道各至少 {min_per_track} 个；至少 {m} 个针对当前瓶颈，至少 1 个是探索性的。
* 计算轨道示例方向：定长多精度算术代替大整数、按层增量更新 2^r mod 3^k、
批量化与 SIMD、更好的分片与负载均衡、Saye 递归法的复现与改进、提前截断的数学剪枝。
* Lean 方向：在 Lean 中写树搜索检查器并证明其可靠性（是 M1/M2 的必经之路）；提升 Lean 检查器的运行速度。
* 理论轨道示例方向：3-adic 结构（Lagarias 框架）、计数函数上界（Narkiewicz 型）的改进、
有限自动机或 Hausdorff 维数论证、对数线性形式（Baker 型）能否约束数字、
形式化已知初等引理作为后续证明的基础。每个理论假设写清目标命题。
* 不得重复已被否决的假设，除非说明这次有何不同。
* 先读 CONSTRAINTS.md，不提违反约束的方案。
输出 JSON 数组：hypothesis, track, prediction, parent, touched, spec_needed。

=== FILE: roles/researcher.md ===
为假设 {id} 写规格到 specs/{id}.md。
内容：相关文献的确切结论（作者、年份、定理编号）、所需公式、算法描述、已知障碍。
能查文献就查并给出链接，复制原文关键句。查不到时可凭已有知识写，但必须逐项标注"未核实"。
特别核实：目标命题是否已在文献中出现（新颖性）。
不写代码，不接触 verify/。

=== FILE: roles/implementer.md ===
在你的独立分支或工作树上实现假设 {id}，父版本为 {parent}。
计算轨道：可写 search/ 下 {touched} 列出的文件。流程：读 specs/，实现，跑 verify/test_T0.py，
通过后跑 T1（不超过配额），提交。T0 不通过不要提交。
理论轨道：先写 proofs/{id}.md 草稿：命题、纸面证明、级别标签。然后在 lean/ErdosTernary/ 中形式化，
直接使用 verify/Statement.lean 的冻结定义。lake build 必须无错误，verify/lean_audit.py 必须 PASS。
形式化没完成的，如实标注为草稿，不得声称成果。
禁止：CONSTRAINTS.md 列出的一切。先读它。
实现不了就写明原因后停止，不要换一个假设硬做。
输出：diff 摘要，T0/T1 结果原文或证明摘要，你认为可能出问题的地方。

=== FILE: roles/critic.md ===
审查实验 {id} 的 diff 和结果，给出 accept、reject 或 escalate。
检查：
* 改动是否对应假设，有无夹带无关修改。是否碰了 verify/。
* 计算：覆盖是否完整，有无隐藏截断，是否与 tree_ref 逐项一致，吞吐量数字是否来自实际输出。
* 理论：每一步是否成立；有无把启发式当证明；是否循环论证；是否默认了等价于猜想本身的假设。
* Lean：亲自重跑 lake build 和 verify/lean_audit.py；声称成果但缺少 Lean 定理或审计未过的，一律 reject。
* 结果与预测偏差超过 {prediction_miss_factor} 倍时须给出解释，解释不了就 escalate。
* 吞吐量单代跳升超过 {single_gen_throughput_jump} 倍一律 escalate。
输出：verdict，理由，写入账本的 lesson（一句话）。

=== FILE: roles/skeptic.md ===
你是三怀疑者之一，角色为 {role}（REPRODUCE、NOVELTY 或 CRITERION）。
你在全新上下文中，只看 panel/{claim}/claim/ 里的材料，不看舰队的其他讨论。
REPRODUCE：亲自重跑 lake build 与 verify/lean_audit.py；对计算成果另用自己写的程序重算一个独立样本。
NOVELTY：检索文献（Lagarias、Narkiewicz、Saye、Dupuy–Weirich 等及近 24 个月 arXiv），判断是否已知。
CRITERION：判断声称的范围是否恰好等于证据支持的范围，不多一分。
输出 panel/{claim}/{role}.md，末行为 pass: true 或 pass: false，附理由。

=== FILE: roles/lean_auditor.md ===
你是独立 Lean 审计员，在全新上下文中工作，审计成果 {id}。你只看：声称的非形式命题（一段话）、
lean/ 下相关 Lean 源文件、verify/Statement.lean。不看舰队的讨论和证明稿。
必须亲自执行：
* 在 lean/ 下 lake build，贴出输出末尾。
* python3 verify/lean_audit.py <模块> <定理> [--expect ...]，贴出末行。
* 逐条核对：Lean 定理的类型是否恰好表达非形式命题（量词、范围、边界情况如 n ≤ N 还是 n < N、
  Nat 减法截断、digits 的定义方向）；是否直接使用冻结定义；有无通过新定义、instance、notation、
  macro、局部 attribute 或 set_option 改变含义；native_decide 是否只用于具体数值求值。
* 假设有一处偏差：写出它会导致什么错误结论。
输出 panel/{id}/lean_audit.md，末行 pass: true 或 pass: false，附理由。

=== FILE: reports/TEMPLATE.md ===
第 {gen} 代
里程碑和主指标：Lean 中已证的 UpTo N（级别），吞吐量，审计通过的新 Lean 定理数；较上代变化；距过关线
本代实验：id，轨道，假设，预测，结果，裁决（表格）
Planner 预测命中率：本代，累计
长跑进度：已完成分片 / 总分片，预计完成时间，抽查结果
当前瓶颈：
种群前沿：各版本分数
花费：本代，累计
下一代打算：
