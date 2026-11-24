# STATUS（每代覆盖写）

- 阶段：0 完成，verify/ 已冻结（verify.lock，tools/check_lock.py 校验）
- 里程碑：M1 复现条件已满足（N = 2·3^20 与参考实现一致），待 Critic 确认后进入 M2/M3
- 已验证 N（本项目）：2·3^20；公开纪录：2·3^45（Saye 2022，已核实）
- 最佳吞吐：1.47e5 事件/秒/核（g0，纯 Python）
- 已确认新命题：0
- 需要人：proposals/0001-lean.md（是否允许安装 Lean）；config.budget.max_wall_hours 与 max_spend 未填
