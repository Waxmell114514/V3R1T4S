# verify/ 重新冻结（v0.3，2026-11-24T11:15Z）

依据：人批准 proposals/0002（修正 tree_ref.c 的 P_k 截断并重新冻结）。
改动：
- verify/tree_ref.c：P_k 按 2^128 取模精确保存，新增 PkBig[k]（真实 P_k > 2^120 > N）标志；j > 0 且 PkBig 时子节点直接判 N 事件。
  CERT.md 未改。
- verify/test_T0.py：新增深层测试，N = 2·3^30 分 4096 片的第 754、1115 片（到达第 98、82 层），
  比对 tree_py 与 tree_ref.c，以及引擎与参考实现。
对照（命令输出）：同一分片 754/4096，旧版 tree_ref "events 2097526 704b3baa32fdf3c7 17e8f0fd89c2a8d7"，
新版 "events 2097526 082cdf634e5e7c67 74544485458336e9"；新版与 tree_py 一致（T0 深层项 ok）。
完整 T0（含 n ≤ 20000 暴力）：T0: PASS。新的 verify.lock 已生成，LOCK: OK。
同时按人的决定：g001-e02 合入主分支，删除其兼容旧截断的 --ref-sat 开关。
