"""Frozen pure-Python reference for verify/CERT.md (small N only). Independent of tree_ref.c."""
import hashlib, math

M64 = (1 << 64) - 1

def mix(z):
    z = (z + 0x9E3779B97F4A7C15) & M64
    z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & M64
    z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & M64
    return z ^ (z >> 31)

def h(k, r, code):
    return mix(mix(mix(r & M64) ^ (r >> 64)) ^ (4 * k + code))

def d0_for(m):
    return max(12, math.ceil(math.log2(16 * m)) + 2)

def digest(count, s, x):
    return hashlib.sha256(f"events={count};sum={s:016x};xor={x:016x}".encode()).hexdigest()

def run(N, i=0, m=1):
    """Returns dict like a shard certificate (without wall_s)."""
    d0 = d0_for(m)
    counts = {}
    ev = [0, 0, 0]  # count, sum, xor
    exc = []
    def P(k):
        return 2 * 3 ** (k - 1)
    def classify(k, r, rec):
        if r > N:
            if rec: _ev(k, r, 1)
            return None
        if (pow(2, r, 3 ** k) // 3 ** (k - 1)) % 3 == 2:
            if rec: _ev(k, r, 0)
            return None
        isE = r < 2 * k and 3 ** k > 2 ** r and r + P(k) > N
        if rec:
            counts[k] = counts.get(k, 0) + 1
            if isE:
                _ev(k, r, 2); exc.append(r)
        return isE
    def _ev(k, r, code):
        v = h(k, r, code)
        ev[0] += 1; ev[1] = (ev[1] + v) & M64; ev[2] ^= v
    level = []
    for r in (0, 1):
        e = classify(1, r, i == 0)
        if e is not None:
            level.append((r, e))
    k = 1
    while level and k < d0:
        nxt = []
        for r, e in level:
            if e: continue
            for j in range(3):
                rr = r + j * P(k)
                ee = classify(k + 1, rr, i == 0)
                if ee is not None:
                    nxt.append((rr, ee))
        level = nxt; k += 1
    if k < d0:
        level = []
    level.sort()
    stack = [(d0, r, e) for t, (r, e) in enumerate(level) if t % m == i]
    while stack:
        k, r, e = stack.pop()
        if e: continue
        for j in range(3):
            rr = r + j * P(k)
            ee = classify(k + 1, rr, True)
            if ee is not None:
                stack.append((k + 1, rr, ee))
    top = max(counts) if counts else 0
    return {"N": str(N), "shard": f"{i}/{m}", "d0": d0,
            "depth_counts": [counts.get(t, 0) for t in range(1, top + 1)],
            "exceptions": [str(x) for x in sorted(exc)], "events": ev[0],
            "leaf_digest": digest(*ev)}
