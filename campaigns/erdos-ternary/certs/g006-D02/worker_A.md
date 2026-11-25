# g006-D02 worker A run record (relayed by message from session_01UnC7uWTGsRvSakG2bW9jfg, received 2026-11-25T06:04Z)
Data reported by the worker session; not independently verified here (proposals/0003 condition 3: sampled re-check).

- Environment: date -u Wed Nov 25 05:15:31 UTC 2026; HEAD daad90e7d5ad427cf653fd2458966733de265d65; nproc 4; 16087 MB RAM; 60G free disk
- Lean: 4.36.0 (commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9); setup total 198 s
- sha256: Shard0..3, ETNative.lean, CheckerWord.lean all match certs/g006-D02/sources.sha256
- Builds (LEAN_NUM_THREADS=1, nice -n 10, two at a time: 0+1 then 2+3), each "Build completed successfully (2149 jobs)", exit 0:

| shard | start | end | wall s | peak VmHWM kB |
|---|---|---|---|---|
| 0 | 05:19:23 | 05:42:21 | 1378 | 1964504 |
| 1 | 05:19:23 | 05:39:38 | 1215 | 1964436 |
| 2 | 05:42:21 | 06:01:24 | 1143 | 1955700 |
| 3 | 05:42:21 | 06:03:17 | 1256 | 1952964 |
