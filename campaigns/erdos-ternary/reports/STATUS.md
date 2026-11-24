# STATUS（每代覆盖写）

- 状态：**已暂停（人要求，2026-11-24）**。第 1 代未收尾：Critic 审查被中止，gen_001 报告未写。不要自动续跑。
- 阶段 0 完成；verify/ 已按 v0.2 重新冻结（含 Lean 审计）。规则：所有成果必须是审计通过的 Lean 定理。
- Lean 成果：upTo_40、exceptions_have_no_two（A 级，独立审计 pass，冒烟测试，非新成果）
- 第 1 代结果（待 Critic）：
  - g001-e01 C 引擎（通用乘模）：1.225e7 事件/秒/核，T0 pass。补丁 reports/gen_001/patches/0001-*.patch（基于 de763cf）
  - g001-e02 C 引擎（短乘法+移位加）：6.85e7 事件/秒/核，T0 pass。补丁 reports/gen_001/patches/0002-*.patch
    吞吐量跳升 466 倍，按规则须 escalate
  - g001-r03 specs/saye2022.md，g001-r04 specs/literature.md 已提交
- 待决：verify/tree_ref.c 在 P_k > 2^125（约第 80 层以后）截断，可能与 CERT.md 的哈希定义冲突（未实测）
- 恢复时：git am 补丁到各自工作树，重跑 Critic（roles/critic.md）审 e01/e02 与上述冲突，然后写 reports/gen_001.md
- 需要人：config.budget.max_wall_hours、max_spend 未填；是否恢复
