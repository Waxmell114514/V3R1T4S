# STATUS（每代覆盖写）

- 状态：自动续跑中（人于 2026-11-24 裁决 g003 的两个 escalate 后恢复）。定时任务 trig_01LRQJuCMqkLvc7je2jDipD8，
  cron 16 */2 * * * UTC，截止 2026-11-25T11:16:02Z。
- 规则：所有成果必须是审计通过的 Lean 定理（CONSTRAINTS 11-13）。verify/ 为 v0.3 冻结。
- 里程碑：M1 过关，证据已升为 A 级（panel/g003-C04/gate.md）；M3 过关（人已认可，panel/g002-L02/gate.md）；M2、M4 未达成。
- Lean 成果（均为形式化复验，除标注外非新结果）：
  - UpTo (2·3^20)：A 级（CheckerKernel，Records/CheckerKernelUpTo20），也有 B 级版本
  - UpTo (2·3^26)：B 级（CheckerShard，默认编译）；UpTo (2·3^28)：B 级（Records/UpTo28）
  - A(X) ≤ (X+1)^{log_3 2}，常数 1 最优：A 级，M3 新结果
  - E^(3)：532261 见证；C(1,4,2^18) 中 ≥2^J 个 < 3^(24J) 的整数（中间产物）
- 第 3 代完成：reports/gen_003.md。第 4 代由下一次定时触发开始。
- 需要人：Abram–Lagarias 表 5.2 疑似错误是否对外告知（见 reports/gen_003.md）
