"""Frozen wrapper around verify/tree_ref.c: python3 verify/tree_ref.py N i m  -> certificate JSON on stdout."""
import hashlib, json, os, pathlib, subprocess, sys, time

HERE = pathlib.Path(__file__).resolve().parent
BUILD = HERE.parent / "build"

def binary():
    src = HERE / "tree_ref.c"
    tag = hashlib.sha256(src.read_bytes()).hexdigest()[:16]
    exe = BUILD / f"tree_ref_{tag}"
    if not exe.exists():
        BUILD.mkdir(exist_ok=True)
        subprocess.run(["gcc", "-O2", "-o", str(exe), str(src), "-lm"], check=True)
    return exe

def parse_N(s):
    s = s.replace(" ", "")
    if "*3^" in s:
        a, b = s.split("*3^"); return int(a) * 3 ** int(b)
    if s.startswith("3^"):
        return 3 ** int(s[2:])
    return int(s)

def run(N, i=0, m=1):
    t = time.time()
    out = subprocess.run([str(binary()), str(N), str(i), str(m)], check=True,
                         capture_output=True, text=True).stdout.split("\n")
    d0 = None; counts = []; exc = []; ev = None
    for line in out:
        p = line.split()
        if not p: continue
        if p[0] == "d0": d0 = int(p[1])
        elif p[0] == "counts": counts = [int(x) for x in p[1:]]
        elif p[0] == "E": exc.append(int(p[1]))
        elif p[0] == "events": ev = (int(p[1]), p[2], p[3])
    dig = hashlib.sha256(f"events={ev[0]};sum={ev[1]};xor={ev[2]}".encode()).hexdigest()
    return {"N": str(N), "shard": f"{i}/{m}", "d0": d0, "depth_counts": counts,
            "exceptions": [str(x) for x in sorted(exc)], "events": ev[0], "leaf_digest": dig,
            "wall_s": round(time.time() - t, 3)}

if __name__ == "__main__":
    print(json.dumps(run(parse_N(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]))))
