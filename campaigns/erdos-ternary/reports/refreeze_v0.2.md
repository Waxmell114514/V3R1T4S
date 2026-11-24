# verify/ 重新冻结（v0.2，2026-11-24T10:20Z）

起因：人同意 proposals/0001-lean.md（放行 Lean 安装），并要求"所有成果都必须是 Lean 形式，经 Lean 编译通过并经单独审计"。
已做：
- 安装 elan 4.4.0；Lean 工程 lean/（lean-toolchain leanprover/lean4:v4.36.0，Mathlib v4.36.0，lake 缓存已下载）。
- verify/Statement.lean 改为冻结定义 ErdosTernary.Statement 与 ErdosTernary.UpTo N（不含证明），lake build 通过。
- 新增 verify/lean_audit.py。校准（均为实际输出末行）：
  - 含 sorry 的定理：LEAN_AUDIT: FAIL forbidden tokens: ErdosTernary/AuditProbe.lean: sorry
  - 用 native_decide 的定理：LEAN_AUDIT: PASS tier=B（辅助公理 ..._native.native_decide.ax_1_1）
  - upTo_40 配 --expect UpTo:41 或 --expect Statement：LEAN_AUDIT: FAIL check file did not elaborate
  - upTo_40 配 --expect UpTo:40：LEAN_AUDIT: PASS tier=A axioms=['Classical.choice', 'Quot.sound', 'propext']
  - 中途发现：Lean 4.36 的 native_decide 不再显示 Lean.ofReduceBool，而是生成辅助公理；已据此修正 B 级判定后再冻结。
- 其余 verify/ 文件未改。新的 verify.lock 已生成，tools/check_lock.py 打印 LOCK: OK。
