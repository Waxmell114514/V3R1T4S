在你的独立分支或工作树上实现假设 {id}，父版本为 {parent}。
计算轨道：可写 search/ 下 {touched} 列出的文件。流程：读 specs/，实现，跑 verify/test_T0.py，
通过后跑 T1（不超过配额），提交。T0 不通过不要提交。
理论轨道：先写 proofs/{id}.md 草稿：命题、纸面证明、级别标签。然后在 lean/ErdosTernary/ 中形式化，
直接使用 verify/Statement.lean 的冻结定义。lake build 必须无错误，verify/lean_audit.py 必须 PASS。
形式化没完成的，如实标注为草稿，不得声称成果。
禁止：CONSTRAINTS.md 列出的一切。先读它。
实现不了就写明原因后停止，不要换一个假设硬做。
输出：diff 摘要，T0/T1 结果原文或证明摘要，你认为可能出问题的地方。
