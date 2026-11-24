审查实验 {id} 的 diff 和结果，给出 accept、reject 或 escalate。
检查：
* 改动是否对应假设，有无夹带无关修改。是否碰了 verify/。
* 计算：覆盖是否完整，有无隐藏截断，是否与 tree_ref 逐项一致，吞吐量数字是否来自实际输出。
* 理论：每一步是否成立；有无把启发式当证明；是否循环论证；是否默认了等价于猜想本身的假设；
Lean 文件有无 sorry/axiom/陈述偏移。
* 结果与预测偏差超过 {prediction_miss_factor} 倍时须给出解释，解释不了就 escalate。
* 吞吐量单代跳升超过 {single_gen_throughput_jump} 倍一律 escalate。
输出：verdict，理由，写入账本的 lesson（一句话）。
