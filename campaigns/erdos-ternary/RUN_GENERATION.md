# 每代续跑提示词（定时任务每次触发时执行）

你是 campaigns/erdos-ternary/ 的 orchestrator。没有人在键盘前：不要提问，需要人的事写进
reports/STATUS.md 的"需要人"和 proposals/。

1. `git fetch origin claude/dreamy-curie-mcxq35` 并合并到本地同名分支（只用这个分支）。若容器是新的，
   先确认 campaigns/erdos-ternary/ 存在；不存在就停下报告。
   若 ~/.elan/bin/lake 不存在：下载 https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh ，
   sh elan-init.sh -y --default-toolchain none；然后在 lean/ 下 lake exe cache get 与 lake build。
   lean/ 不能编译就停下报告（MISSION.md 停止条件）。
2. 读 AGENTS.md、kit/RULES.md，然后读本目录的 CONSTRAINTS.md、MISSION.md、VERIFY.md、config.yaml、
   reports/STATUS.md、最近一份 reports/gen_NNN.md、ledger/experiments.jsonl 最后 50 行、proposals/ 中人的答复。
3. `python3 tools/check_lock.py` 必须打印 LOCK: OK，否则立即停止并报告。
4. 检查"停止并等人"条件（MISSION.md）：escalate 未处理、疑似反例、M4 声称、stall、预算
   （config.budget.max_generations 等）。任一成立：写 STATUS.md 后停止，不开新一代。
5. 检查长跑：certs/ 下进行中的分片（PID 记录在 certs/<id>/RUNNING.md）。容器若已被回收，进程不在了，
   从断点重新排队未完成分片。完成的分片证书提交。
6. 按 MISSION.md 阶段 1 跑一代：Planner（roles/planner.md）→ 需要时 Researcher → Implementer 并行
   （Agent 工具，isolation=worktree，同时不超过 config.budget.max_parallel_workers）→ T0/T1 →
   Critic（roles/critic.md，用一个新的子 agent，只给它 diff 和结果）→ 种群 → 账本 → 报告。
   预测必须在评估之前写进账本。
   声称为成果的，必须是 Lean 定理：lake build 通过、verify/lean_audit.py PASS，并由一个新的子 agent
   按 roles/lean_auditor.md 独立审计通过（CONSTRAINTS.md 第 11 条）。
7. 写 reports/gen_NNN.md（按 reports/TEMPLATE.md）、覆盖写 reports/STATUS.md，提交并
   `git push -u origin claude/dreamy-curie-mcxq35`（网络错误最多重试 4 次）。
8. 结束本次触发。不要等待长跑结束；长跑在后台按 nice、timeout、断点继续。
