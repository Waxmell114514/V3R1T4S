# 阶段 0.1 预检（2026-11-24T10:06Z，数值均来自命令输出）

| 项 | 结果 |
|---|---|
| git | 2.43.0 |
| Python | 3.13.18，NumPy 2.5.3；无 SciPy、gmpy2、Numba（可 pip 装，PyPI 返回 200） |
| C 编译器 | gcc 13.3.0；libgmp.so.10 存在但无 gmp.h 头文件 |
| CPU / 内存 / 磁盘 | 4 核 / 16087 MB（空闲约 15.6 GB）/ 60 GB 可用 |
| 网络 | arxiv.org 200，pypi.org 200，raw.githubusercontent.com 200 |
| Lean 4 / Mathlib | **未安装**：安装 elan 的命令被本会话的权限策略拒绝。verify/Statement.lean 只冻结陈述文本。需要人决定是否放行（见 proposals/0001-lean.md） |
| 并行子 agent | 可用（Agent 工具，独立工作树 isolation=worktree）；本机还有 claude CLI |
| 容器 | 云端临时容器，会被回收：所有状态提交并推送到 claude/dreamy-curie-mcxq35；长跑必须分片、可续跑 |

结论：可以并行；计算轨道可在本机跑；理论轨道的形式化检查暂不可用，理论命题只能走三怀疑者小组。
