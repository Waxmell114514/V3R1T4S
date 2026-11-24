# STATUS（每代覆盖写）

- 状态：**已暂停**（人中止了第 2 代的小组审查，2026-11-24）。定时任务 trig_01LRQJuCMqkLvc7je2jDipD8 已于 2026-11-24T12:17Z 在其触发时读到本状态后停用（enabled=false）；恢复时需重新启用。
  原状态：自动续跑中。人定预算：每 2 小时一代，总时长上限 24 小时（config.yaml）。
  定时任务 trig_01LRQJuCMqkLvc7je2jDipD8（"erdos-ternary 每 2 小时一代"，cron 16 */2 * * * UTC），
  起点 2026-11-24T11:16:02Z，截止 2026-11-25T11:16:02Z；首次触发 2026-11-24T12:16Z。
- 规则：所有成果必须是审计通过的 Lean 定理（CONSTRAINTS 11-13）。verify/ 为 v0.3 冻结（reports/refreeze_v0.3.md）。
- Lean 成果：upTo_40、exceptions_have_no_two（A 级，独立审计 pass，冒烟测试，非新成果）
- 最佳探索引擎：g001-e02（search/c2，6.85e7 事件/秒/核，4 片 2.05e8/s），人已确认 escalate 后合入
- 种群：g000-e00、g001-e01（对照，补丁）、g001-e02、g000-lean
- 第 2 代：**进行中**（2026-11-24T11:33Z 开始，reports/gen_002/plan.json，4 个子 agent）。方向：Lean 中的树搜索检查器与可靠性定理（目标 UpTo (2·3^20)）；Narkiewicz 原文核实与计数上界形式化
- 需要人：无（max_spend 按人的决定不设，只看墙钟）

## 第 2 代暂停时的位置
- 已合入主分支：g002-L01（Checker.lean：check_sound A 级，upTo_small UpTo(2·3^12) A 级，upTo_vardi UpTo(2·3^20) B 级），
  g002-L02（Counting.lean：A(X) ≤ (X+1)^{log_3 2}，A 级），g002-P04（E4.lean：532261 见证，A 级），
  CountingSharp.lean（最优性引理，A 级，orchestrator 所写，独立审计未完成）
- 独立 Lean 审计 pass：L01、L02、P04；Critic accept：L01、L02（P04 无 Critic）
- L02 小组：REPRODUCE pass；CRITERION 第一轮有条件 pass，已出 Revision 2；CRITERION 复查与 NOVELTY 被中止，需重跑
- L01 小组：REPRODUCE 被中止，NOVELTY 与 CRITERION 未开始
- reports/gen_002.md 未写；状态均为 PROMISING，尚无 CONFIRMED
