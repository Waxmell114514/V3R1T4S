"""Frozen certificate checker.
python3 verify/check_cert.py <cert_dir> [--recheck-fraction F] [--min-rechecked K] [--seed S]
Checks: all shards 0..m-1 present, same N/m/d0, exceptions subset of {0,2,8} (else reports COUNTEREXAMPLE
CANDIDATE), and independently recomputes a random sample of shards with verify/tree_ref.c.
Prints a final line 'CERT: PASS N=<N> shards=<m> rechecked=<k>' or 'CERT: FAIL <reason>'."""
import argparse, json, pathlib, random, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import tree_ref, tree_py

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cert_dir")
    ap.add_argument("--recheck-fraction", type=float, default=0.0005)
    ap.add_argument("--min-rechecked", type=int, default=5)
    ap.add_argument("--seed", type=int, default=None)
    a = ap.parse_args()
    files = sorted(pathlib.Path(a.cert_dir).glob("shard_*.json"))
    if not files:
        print("CERT: FAIL no shard files"); return 1
    certs = [json.loads(f.read_text()) for f in files]
    Ns = {c["N"] for c in certs}; ms = {c["shard"].split("/")[1] for c in certs}; d0s = {c["d0"] for c in certs}
    if len(Ns) != 1 or len(ms) != 1 or len(d0s) != 1:
        print("CERT: FAIL mixed N, m or d0"); return 1
    N = int(Ns.pop()); m = int(ms.pop()); d0 = d0s.pop()
    if d0 != tree_py.d0_for(m):
        print("CERT: FAIL wrong d0"); return 1
    idx = sorted(int(c["shard"].split("/")[0]) for c in certs)
    if idx != list(range(m)):
        print(f"CERT: FAIL shards present {len(idx)} of {m} (missing or duplicate)"); return 1
    exc = sorted({int(x) for c in certs for x in c["exceptions"]})
    if any(x not in (0, 2, 8) for x in exc):
        print(f"CERT: FAIL COUNTEREXAMPLE CANDIDATE {exc} -- stop everything, verify with verify/brute.py"); return 2
    if N >= 8 and exc != [0, 2, 8]:
        print(f"CERT: FAIL known exceptions missing: {exc}"); return 1
    rng = random.Random(a.seed)
    k = min(m, max(a.min_rechecked, int(round(a.recheck_fraction * m))))
    sample = sorted(set([0] + rng.sample(range(m), k)))[:max(k, 1)] if m > 1 else [0]
    by = {int(c["shard"].split("/")[0]): c for c in certs}
    for i in sample:
        ref = tree_ref.run(N, i, m)
        got = by[i]
        for key in ("depth_counts", "exceptions", "events", "leaf_digest"):
            if ref[key] != got[key]:
                print(f"CERT: FAIL shard {i}/{m} field {key} differs from reference"); return 1
        print(f"rechecked shard {i}/{m}: ok ({ref['wall_s']} s)")
    print(f"CERT: PASS N={N} shards={m} rechecked={len(sample)}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
