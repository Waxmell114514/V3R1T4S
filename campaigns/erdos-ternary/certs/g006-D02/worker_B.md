# g006-D02 worker B run record (relayed by message from session_01UnC7uXBKxUreWdXZcfez4C, received 2026-11-25T06:03Z)
Data reported by the worker session; not independently verified here (proposals/0003 condition 3: sampled re-check).

- Environment: date -u Wed Nov 25 05:15:19 UTC 2026; HEAD daad90e7d5ad427cf653fd2458966733de265d65; nproc 4; 16087 MB RAM; 60G free disk
- Lean: 4.36.0 (commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9); lake exe cache get 1m37s; lake build ErdosTernary.CheckerWord 1m43s; setup ≈ 3m35s
- sha256: Shard4..7, ETNative.lean, CheckerWord.lean all match certs/g006-D02/sources.sha256
- Builds (LEAN_NUM_THREADS=1, nice -n 10, two at a time: 4+5 then 6+7), each "Build completed successfully (2149 jobs)", exit 0:

| shard | start | end | wall s | peak RSS KB |
|---|---|---|---|---|
| 4 | 05:19:31 | 05:42:11 | 1359.76 | 1969052 |
| 5 | 05:19:31 | 05:41:36 | 1324.31 | 1969176 |
| 6 | 05:42:11 | 06:00:11 | 1080.27 | 1975120 |
| 7 | 05:42:11 | 06:02:26 | 1214.99 | 1974596 |

Only warnings: Mathlib module-system import advisories on Checker.lean and verify/Statement.lean.
