# 提案 0002：修正 verify/tree_ref.c 的 P_k 截断（需人批准重新冻结）

发现：g001-e02 的 Implementer 提出，Critic 复核确认（reports/gen_001/critic.md）。
- tree_ref.c 在第 80 层起把 P_k 截到 2^125；CERT.md 与 tree_py.py 用真实 r（取模 2^128）计算哈希。
- 影响：第 81 层及以上的 "r > N" 事件的 leaf_digest 不一致。计数、事件数、例外不受影响，覆盖的正确性不受影响。
- 实测：N = 2·3^30 分 4096 片，第 754、1115、2721 片到达第 98、82、81 层，引擎与 tree_ref 只在摘要上不同；
  tree_py 与两个引擎一致。第 1206 片（79 层）处处一致。
- 后果：check_cert.py 只用 tree_ref 抽查，N 接近纪录时多数诚实证书会被误判失败。T0 不到第 80 层，没测出来。
修正方案（Critic 建议）：tree_ref.c 中 P_k 按 2^128 取模精确保存，另设 "P_k > N" 标志；CERT.md 不变；
T0 增加 N = 2·3^30、4096 片中第 754、1115 片与 tree_py 的比对；之后删除 search/c2 的 --ref-sat。
按 CONSTRAINTS 第 5 条，代理不得改 verify/，需要人批准后由 orchestrator 执行并重新冻结。
说明：按 v0.2 规则，计算成果必须是 Lean 定理，所以这个修正只影响探索工具的交叉核对，不影响成果判定。
