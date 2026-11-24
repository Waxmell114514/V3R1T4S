# STATUS（每代覆盖写）

- 状态：自动续跑中。人定预算：每 2 小时一代，总时长上限 24 小时（config.yaml）。
  定时任务 trig_01LRQJuCMqkLvc7je2jDipD8（"erdos-ternary 每 2 小时一代"，cron 16 */2 * * * UTC），
  起点 2026-11-24T11:16:02Z，截止 2026-11-25T11:16:02Z；首次触发 2026-11-24T12:16Z。
- 规则：所有成果必须是审计通过的 Lean 定理（CONSTRAINTS 11-13）。verify/ 为 v0.3 冻结（reports/refreeze_v0.3.md）。
- Lean 成果：upTo_40、exceptions_have_no_two（A 级，独立审计 pass，冒烟测试，非新成果）
- 最佳探索引擎：g001-e02（search/c2，6.85e7 事件/秒/核，4 片 2.05e8/s），人已确认 escalate 后合入
- 种群：g000-e00、g001-e01（对照，补丁）、g001-e02、g000-lean
- 第 2 代：**进行中**（2026-11-24T11:33Z 开始，reports/gen_002/plan.json，4 个子 agent）。方向：Lean 中的树搜索检查器与可靠性定理（目标 UpTo (2·3^20)）；Narkiewicz 原文核实与计数上界形式化
- 需要人：无（max_spend 按人的决定不设，只看墙钟）
