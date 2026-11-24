"""g1 search driver (experiment g001-e02): compiles and runs the C engine in search/c2/, see verify/CERT.md.
python3 search/run.py --N <N> --shard i/m --out <file>
N is decimal or a*3^b. The binary is built into build/ (gitignored) on first use, keyed by the source hash.
Output JSON has exactly the fields and layout of g0: N, shard, d0, depth_counts, exceptions, events, leaf_digest,
wall_s."""
import argparse, hashlib, json, os, pathlib, subprocess, sys, time

HERE = pathlib.Path(__file__).resolve().parent
SRC = HERE / "c2"
BUILD = HERE.parent / "build"
CFLAGS = ["-O3", "-march=native", "-Wall"]


def parse_N(s):
    s = s.replace(" ", "")
    if "*3^" in s:
        a, b = s.split("*3^")
        return int(a) * 3 ** int(b)
    if s.startswith("3^"):
        return 3 ** int(s[2:])
    return int(s)


def binary():
    h = hashlib.sha256()
    for name in ("engine.c", "core.inc"):
        h.update((SRC / name).read_bytes())
    h.update(" ".join(CFLAGS).encode())
    exe = BUILD / f"c2_engine_{h.hexdigest()[:16]}"
    if not exe.exists():
        BUILD.mkdir(exist_ok=True)
        tmp = exe.with_suffix(f".tmp{os.getpid()}")
        subprocess.run(["gcc", *CFLAGS, "-o", str(tmp), str(SRC / "engine.c")], check=True)
        os.replace(tmp, exe)
    return exe


def search(N, i, m):
    if N < 0 or N >= 1 << 120:
        sys.exit(f"run.py: N out of supported range [0, 2^120): {N}")
    exe = binary()
    cmd = [str(exe), str(N), str(i), str(m)]
    t = time.time()
    p = subprocess.run(cmd, capture_output=True, text=True)
    wall = time.time() - t
    if p.returncode != 0:
        sys.stderr.write(p.stderr)
        sys.exit(f"run.py: engine failed with exit code {p.returncode}")
    d0 = counts = ev = None
    exc = []
    for line in p.stdout.split("\n"):
        f = line.split()
        if not f:
            continue
        if f[0] == "d0": d0 = int(f[1])
        elif f[0] == "counts": counts = [int(x) for x in f[1:]]
        elif f[0] == "E": exc.append(int(f[1]))
        elif f[0] == "events": ev = (int(f[1]), f[2], f[3])
    if d0 is None or counts is None or ev is None:
        sys.exit("run.py: incomplete engine output")
    dig = hashlib.sha256(f"events={ev[0]};sum={ev[1]};xor={ev[2]}".encode()).hexdigest()
    res = {"N": str(N), "shard": f"{i}/{m}", "d0": d0, "depth_counts": counts,
           "exceptions": [str(x) for x in sorted(exc)], "events": ev[0], "leaf_digest": dig}
    return res, wall


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--N", required=True); ap.add_argument("--shard", default="0/1"); ap.add_argument("--out", required=True)
    a = ap.parse_args()
    i, m = (int(x) for x in a.shard.split("/"))
    res, wall = search(parse_N(a.N), i, m)
    res["wall_s"] = round(wall, 3)
    with open(a.out, "w") as f:
        json.dump(res, f)
