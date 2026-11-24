"""g0 search engine (seed): plain-Python DFS of the trailing-ternary-digit tree, see verify/CERT.md.
python3 search/run.py --N <N> --shard i/m --out <file>
Deliberately simple and slow; later generations replace it."""
import argparse, hashlib, json, math, time

MASK = (1 << 64) - 1

def splitmix(z):
    z = (z + 0x9E3779B97F4A7C15) & MASK
    z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & MASK
    z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & MASK
    return z ^ (z >> 31)

def parse_N(s):
    s = s.replace(" ", "")
    if "*3^" in s:
        a, b = s.split("*3^")
        return int(a) * 3 ** int(b)
    return int(s)

def search(N, i, m):
    d0 = max(12, math.ceil(math.log2(16 * m)) + 2)
    counts, exc = [], []
    cnt = tot = xr = 0
    def emit(k, r, code):
        nonlocal cnt, tot, xr
        hv = splitmix(splitmix(splitmix(r & MASK) ^ (r >> 64)) ^ (4 * k + code))
        cnt += 1; tot = (tot + hv) & MASK; xr ^= hv
    def alive(k):
        while len(counts) < k: counts.append(0)
        counts[k - 1] += 1
    # node = (k, r, v, e) with v = 2^r mod 3^(k+1) (one extra trit for the children test), e = exception flag
    def candidate(k, r, v_mod_k1, record):
        """v_mod_k1 = 2^r mod 3^(k) is enough to test trit k-1; returns (alive, e)."""
        if r > N:
            if record: emit(k, r, 1)
            return False, False
        if v_mod_k1 // 3 ** (k - 1) == 2:
            if record: emit(k, r, 0)
            return False, False
        e = r < 2 * k and 3 ** k > (1 << r) and r + 2 * 3 ** (k - 1) > N
        if record:
            alive(k)
            if e: emit(k, r, 2); exc.append(r)
        return True, e
    def children(k, r, e, record, out):
        if e: return  # terminal exception node
        P = 2 * 3 ** (k - 1); M = 3 ** (k + 1)
        base = pow(2, r, M); g = pow(2, P, M)
        v = base
        for j in range(3):
            if j: v = v * g % M
            ok, ee = candidate(k + 1, r + j * P, v, record)
            if ok: out.append((k + 1, r + j * P, ee))
    level = []
    for r in (0, 1):
        ok, e = candidate(1, r, pow(2, r, 3), i == 0)
        if ok: level.append((1, r, e))
    while level and level[0][0] < d0:
        nxt = []
        for k, r, e in level:
            children(k, r, e, i == 0, nxt)
        level = nxt
    roots = sorted(level, key=lambda t: t[1])
    stack = [t for idx, t in enumerate(roots) if idx % m == i]
    while stack:
        k, r, e = stack.pop()
        children(k, r, e, True, stack)
    while counts and counts[-1] == 0: counts.pop()
    dig = hashlib.sha256(f"events={cnt};sum={tot:016x};xor={xr:016x}".encode()).hexdigest()
    return {"N": str(N), "shard": f"{i}/{m}", "d0": d0, "depth_counts": counts,
            "exceptions": [str(x) for x in sorted(exc)], "events": cnt, "leaf_digest": dig}

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--N", required=True); ap.add_argument("--shard", default="0/1"); ap.add_argument("--out", required=True)
    a = ap.parse_args()
    i, m = (int(x) for x in a.shard.split("/"))
    t = time.time()
    res = search(parse_N(a.N), i, m)
    res["wall_s"] = round(time.time() - t, 3)
    with open(a.out, "w") as f:
        json.dump(res, f)
