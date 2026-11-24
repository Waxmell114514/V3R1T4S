# 阶段 0.1 预检（2026-11-24T10:06Z，数值均来自命令输出）

| 项 | 结果 |
|---|---|
| git | 2.43.0 |
| Python | 3.13.18，NumPy 2.5.3；无 SciPy、gmpy2、Numba（可 pip 装，PyPI 返回 200） |
| C 编译器 | gcc 13.3.0；libgmp.so.10 存在但无 gmp.h 头文件 |
| CPU / 内存 / 磁盘 | 4 核 / 16087 MB（空闲约 15.6 GB）/ 60 GB 可用 |
| 网络 | arxiv.org 200，pypi.org 200，raw.githubusercontent.com 200 |
| Lean 4 / Mathlib | 起初被权限策略拒绝；人同意 proposals/0001 后已安装：elan 4.4.0，Lean v4.36.0，Mathlib v4.36.0（见 reports/refreeze_v0.2.md）。新容器需重装：见 RUN_GENERATION.md 第 1 步 |
| 并行子 agent | 可用（Agent 工具，独立工作树 isolation=worktree）；本机还有 claude CLI |
| 容器 | 云端临时容器，会被回收：所有状态提交并推送到 claude/dreamy-curie-mcxq35；长跑必须分片、可续跑 |

结论：可以并行；Lean 可用；按 v0.2 规则，所有成果都必须是通过 lean_audit 和独立审计的 Lean 定理。
