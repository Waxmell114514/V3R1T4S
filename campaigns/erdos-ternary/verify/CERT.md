# Certificate rules (frozen in phase 0)

## Tree
P_k = 2*3^(k-1) for k >= 1. A *candidate* at level k is a pair (k, r) with 0 <= r < P_k.
Level-1 candidates: r = 0 and r = 1.
Each candidate is classified, in this order:
1. `N` (code 1): r > N. Terminal.
2. `D` (code 0): trit number k-1 (0-based, least significant first) of 2^r is 2. Terminal.
3. otherwise the candidate is *alive*. If additionally 3^k > 2^r (all trits of 2^r are known, none is 2) and
   r + P_k > N (the class meets [0, N] only in r), emit event `E` (code 2) for (k, r): r is an exception, and the
   node is terminal (no children).

Children of every other alive node (k, r): candidates (k+1, r + j*P_k) for j = 0, 1, 2.
(Note: the class of an exception r keeps other members r + t*P_k, so it is expanded until it meets [0, N] only in r.)
Every n with 0 <= n <= N lies in exactly one candidate class per level until its class terminates, so
"no `E` event other than r in {0, 2, 8}" proves: for every 0 <= n <= N with n not in {0,2,8}, 2^n has a digit 2.

`depth_counts[k-1]` = number of alive nodes at level k (terminal `E` nodes included); trailing zeros are dropped,
and lists of different lengths are summed with zero padding.

## Event hash
mix(x) = splitmix64 finalizer on 64-bit words:
  z = x + 0x9E3779B97F4A7C15; z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9;
  z = (z ^ (z >> 27)) * 0x94D049BB133111EB; return z ^ (z >> 31)   (all mod 2^64)
h(k, r, code) = mix( mix( mix(r mod 2^64) ^ (r >> 64) ) ^ (4*k + code) )
Over all events (N, D and E) of a shard: count, S = sum h mod 2^64, X = xor h.
`leaf_digest` = sha256 of the ASCII string `events=<count>;sum=<S as 16 lowercase hex>;xor=<X as 16 lowercase hex>`.
Digests of shards are not combined; each shard is compared on its own.

## Shards
For m shards, d0 = max(12, ceil(log2(16*m)) + 2). Shard 0 owns every event and alive count at levels <= d0.
The alive nodes at level d0 are sorted by r ascending; node number t (0-based) belongs to shard t mod m, which owns
every event and alive count strictly below that node (levels > d0). Summing all shards' `depth_counts`
element-wise and their event counts gives the unsharded totals.

## Shard certificate JSON
{"N": "<decimal>", "shard": "i/m", "d0": d0, "depth_counts": [...], "exceptions": [decimal strings, sorted],
 "events": count, "leaf_digest": "<sha256 hex>", "wall_s": float}
A certificate set for bound N is complete when shards 0..m-1 are all present with the same N, m and d0.
