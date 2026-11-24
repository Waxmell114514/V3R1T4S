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
