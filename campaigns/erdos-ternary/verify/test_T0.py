"""Frozen T0 tests. python3 verify/test_T0.py [--engine "python3 search/run.py"]  -> last line 'T0: PASS' or 'T0: FAIL'.
The engine must implement: <engine> --N <N> --shard i/m --out <file>."""
import argparse, json, pathlib, shlex, subprocess, sys, tempfile, shutil
HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(HERE))
import brute, tree_py, tree_ref

def brute_alive_counts(N, K):
    """alive(k,r) per verify/CERT.md, computed straight from the definition."""
    out = []
    for k in range(1, K + 1):
        P = 2 * 3 ** (k - 1); c = 0
        for r in range(0, min(N, P - 1) + 1):
            v = pow(2, r, 3 ** k)
            if any((v // 3 ** t) % 3 == 2 for t in range(k)): continue
            # excluded if some ancestor (kp, r mod P_kp), kp < k, was a terminal exception node
            term = False
            for kp in range(1, k):
                Pp = 2 * 3 ** (kp - 1); rp = r % Pp
                if rp < 2 * kp and 3 ** kp > 2 ** rp and rp + Pp > N:
                    term = True; break
            if term: continue
            c += 1
        out.append(c)
    while out and out[-1] == 0: out.pop()
    return out

def run_engine(engine, N, i, m, d):
    f = pathlib.Path(d) / f"s_{N}_{i}_{m}.json"
    subprocess.run(shlex.split(engine) + ["--N", str(N), "--shard", f"{i}/{m}", "--out", str(f)],
                   check=True, cwd=ROOT, capture_output=True, timeout=3600)
    return json.loads(f.read_text())

def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--engine", default="python3 search/run.py")
    ap.add_argument("--skip-brute", action="store_true", help="skip the slow n<=20000 brute force (references only)")
    a = ap.parse_args()
    fails = []
    def check(name, ok):
        print(("ok   " if ok else "FAIL ") + name)
        if not ok: fails.append(name)
    if not a.skip_brute:
        check("brute: exceptions for n<=20000 are exactly [0,2,8]", brute.exceptions(0, 20000) == [0, 2, 8])
    # two-children lemma numerically, k <= 40: 2^(P_k) = 1 + c*3^k mod 3^(k+1), 3 does not divide c
    ok = True
    for k in range(1, 41):
        M = 3 ** (k + 1); g = pow(2, 2 * 3 ** (k - 1), M)
        ok &= (g - 1) % 3 ** k == 0 and ((g - 1) // 3 ** k) % 3 != 0
    check("two-children lemma k<=40", ok)
    N = 3000
    check("tree_py alive counts == definition (N=3000)", tree_py.run(N)["depth_counts"] == brute_alive_counts(N, 40))
    check("tree_ref.c exceptions for N=20000 are [0,2,8]", tree_ref.run(20000)["exceptions"] == ["0", "2", "8"])
    for N in (10 ** 3, 10 ** 5, 2 * 3 ** 12):
        p = tree_py.run(N); c = tree_ref.run(N); c.pop("wall_s")
        check(f"tree_py == tree_ref.c (N={N})", p == c)
    # deep levels (>= 80, where P_k exceeds 2^125): proposals/0002. Shards 754 and 1115 of 4096 at N = 2*3^30
    # reach levels 98 and 82.
    Nd, md = 2 * 3 ** 30, 4096
    deep = {}
    for i in (754, 1115):
        p = tree_py.run(Nd, i, md); c = tree_ref.run(Nd, i, md); c.pop("wall_s"); deep[i] = c
        check(f"tree_py == tree_ref.c deep (N=2*3^30, shard {i}/{md}, levels {len(c['depth_counts'])})",
              p == c and len(c["depth_counts"]) > 80)
    d = tempfile.mkdtemp()
    try:
        for N in (10 ** 3, 10 ** 5, 2 * 3 ** 12):
            ref = tree_ref.run(N); ref.pop("wall_s")
            got = run_engine(a.engine, N, 0, 1, d); got.pop("wall_s", None)
            check(f"engine == reference (N={N}, unsharded)", got == ref)
            for m in (3, 7):
                tot = None; evs = 0; allok = True
                for i in range(m):
                    g = run_engine(a.engine, N, i, m, d); r = tree_ref.run(N, i, m)
                    allok &= all(g[k] == r[k] for k in ("depth_counts", "exceptions", "events", "leaf_digest", "d0"))
                    dc = g["depth_counts"]; evs += g["events"]
                    tot = dc if tot is None else [x + y for x, y in zip(tot + [0] * (len(dc) - len(tot)), dc + [0] * (len(tot) - len(dc)))]
                check(f"engine shards == reference shards (N={N}, m={m})", allok)
                check(f"shard sums == unsharded (N={N}, m={m})", tot == ref["depth_counts"] and evs == ref["events"])
        for i in (754, 1115):
            g = run_engine(a.engine, Nd, i, md, d); g.pop("wall_s", None)
            check(f"engine == reference deep (N=2*3^30, shard {i}/{md})", g == deep[i])
        # tamper tests on a fresh certificate set
        cd = pathlib.Path(d) / "certset"; cd.mkdir()
        N, m = 2 * 3 ** 12, 7
        for i in range(m):
            (cd / f"shard_{i}.json").write_text(json.dumps(tree_ref.run(N, i, m)))
        chk = lambda: subprocess.run([sys.executable, str(HERE / "check_cert.py"), str(cd), "--recheck-fraction", "1"],
                                     capture_output=True, text=True).stdout.strip().split("\n")[-1]
        check("check_cert passes an honest set", chk().startswith("CERT: PASS"))
        c3 = json.loads((cd / "shard_3.json").read_text()); c3["depth_counts"][-1] += 1
        (cd / "shard_3.json").write_text(json.dumps(c3))
        check("check_cert rejects a tampered count", chk().startswith("CERT: FAIL"))
        (cd / "shard_3.json").unlink()
        check("check_cert rejects a missing shard", chk().startswith("CERT: FAIL"))
    finally:
        shutil.rmtree(d)
    print("T0: PASS" if not fails else f"T0: FAIL ({len(fails)} failed)")
    return 0 if not fails else 1

if __name__ == "__main__":
    sys.exit(main())
