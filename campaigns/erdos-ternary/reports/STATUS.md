# STATUS（每代覆盖写）

- 状态：**第 1 代完成，等人**：e01、e02 被 Critic 判 escalate（吞吐量单代跳升 > 3 倍），按规则停下。见 reports/gen_001.md
- 阶段 0 完成；verify/ 已按 v0.2 重新冻结（含 Lean 审计）。规则：所有成果必须是审计通过的 Lean 定理。
- Lean 成果：upTo_40、exceptions_have_no_two（A 级，独立审计 pass，冒烟测试，非新成果）
- 第 1 代结果（Critic：escalate，reports/gen_001/critic.md）：
  - g001-e01 C 引擎（通用乘模）：1.225e7 事件/秒/核，T0 pass。补丁 reports/gen_001/patches/0001-*.patch（基于 de763cf）
  - g001-e02 C 引擎（短乘法+移位加）：6.85e7 事件/秒/核，T0 pass。补丁 reports/gen_001/patches/0002-*.patch
    吞吐量跳升 466 倍，按规则须 escalate
  - g001-r03 specs/saye2022.md，g001-r04 specs/literature.md 已提交
- 待决：verify/tree_ref.c 在 P_k > 2^125（约第 80 层以后）截断，可能与 CERT.md 的哈希定义冲突（未实测）
- Critic 已确认截断问题属实，只影响摘要：proposals/0002-tree-ref-saturation.md
- 需要人：config.budget.max_wall_hours、max_spend 未填；是否恢复
