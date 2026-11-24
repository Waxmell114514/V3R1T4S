# STATUS（每代覆盖写）

- 状态：**等人**（第 4 代：Critic 对 g004-C02 判 escalate——预编译后单节点提速约 4 倍，超过 single_gen_throughput_jump 3.0；见 reports/gen_004/critic_C02.md）。定时任务 trig_01LRQJuCMqkLvc7je2jDipD8 已停用；恢复时需重新启用。
  cron 16 */2 * * * UTC，截止 2026-11-25T11:16:02Z。
- 规则：所有成果必须是审计通过的 Lean 定理（CONSTRAINTS 11-13）。verify/ 为 v0.3 冻结。
- 里程碑：M1 过关，证据已升为 A 级（panel/g003-C04/gate.md）；M3 过关（人已认可，panel/g002-L02/gate.md）；M2、M4 未达成。
- Lean 成果（均为形式化复验，除标注外非新结果）：
  - UpTo (2·3^20)：A 级（CheckerKernel，Records/CheckerKernelUpTo20），也有 B 级版本
  - UpTo (2·3^26)：B 级（CheckerShard，默认编译）；UpTo (2·3^28)：B 级（Records/UpTo28）
  - A(X) ≤ (X+1)^{log_3 2}，常数 1 最优：A 级，M3 新结果
  - E^(3)：532261 见证；C(1,4,2^18) 中 ≥2^J 个 < 3^(24J) 的整数（中间产物）
- 第 4 代：**进行中**（2026-11-24T16:02Z 由定时任务开始，reports/gen_004/plan.json；只出 3 个假设：理论轨道缺少可行方向，偏离 min_per_track=2，已记录）
- 需要人：Abram–Lagarias 表 5.2 疑似错误是否对外告知（见 reports/gen_003.md）
