"""Frozen Lean audit.
python3 verify/lean_audit.py <Module> <Theorem> [--expect Statement | --expect UpTo:<lean nat expr>]
1. verify/Statement.lean hash must match verify.lock.
2. `lake build <Module>` in lean/ must succeed.
3. Every .lean file under lean/ErdosTernary/ (and lean/ErdosTernary.lean) is scanned, comments stripped, for
   forbidden tokens (FAIL) and meaning-changing constructs (WARN, for the human-style auditor to inspect).
4. `#print axioms <Theorem>`: tier A = only propext, Classical.choice, Quot.sound;
   tier B = additionally Lean.ofReduceBool / Lean.trustCompiler or native_decide's auxiliary axioms. Else: FAIL.
5. With --expect, `example : <frozen Prop> := @<Theorem>` must elaborate.
Last line: `LEAN_AUDIT: PASS tier=A|B` or `LEAN_AUDIT: FAIL <reason>`."""
import argparse, hashlib, os, pathlib, re, subprocess, sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
LEAN = ROOT / "lean"
TIER_A = {"propext", "Classical.choice", "Quot.sound"}
TIER_B = TIER_A | {"Lean.ofReduceBool", "Lean.trustCompiler"}
FORBIDDEN = [r"\bsorry\b", r"\badmit\b", r"\baxiom\b", r"\bunsafe\b", r"implemented_by", r"\bextern\b",
             r"skipKernelTC", r"\bopaque\b", r"\bcsimp\b", r"ofReduceBool", r"trustCompiler",
             r"\bpartial\b", r"debug\.", r"\b(def|abbrev|structure|inductive|class)\s+\S*(UpTo|Statement)\b", r"^\s*import\s+Lean\.Elab"]
WARN = [r"\bmacro\b", r"\bsyntax\b", r"\bnotation\b", r"\belab\b", r"\binstance\b", r"set_option",
        r"attribute\s*\[", r"\bnative_decide\b", r"\bdecide\s*:=\s*true"]

def fail(msg):
    print(f"LEAN_AUDIT: FAIL {msg}")
    sys.exit(1)

def strip_comments(s):
    s = re.sub(r"/-.*?-/", " ", s, flags=re.S)
    return re.sub(r"--[^\n]*", " ", s)

def env():
    e = dict(os.environ)
    e["PATH"] = str(pathlib.Path.home() / ".elan" / "bin") + os.pathsep + e.get("PATH", "")
    return e

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("module"); ap.add_argument("theorem"); ap.add_argument("--expect", default=None)
    a = ap.parse_args()
    if not re.fullmatch(r"[A-Za-z_][\w.]*", a.module) or not re.fullmatch(r"[A-Za-z_][\w.']*", a.theorem):
        fail("bad module or theorem name")
    # 1. frozen statement hash
    lock = {l.split()[1]: l.split()[0] for l in (ROOT / "verify.lock").read_text().splitlines() if l.strip()}
    if hashlib.sha256((HERE / "Statement.lean").read_bytes()).hexdigest() != lock.get("Statement.lean"):
        fail("verify/Statement.lean does not match verify.lock")
    # 2. build
    b = subprocess.run(["lake", "build", a.module], cwd=LEAN, env=env(), capture_output=True, text=True)
    print("\n".join((b.stdout + b.stderr).strip().splitlines()[-3:]))
    if b.returncode != 0 or re.search(r"^error", b.stdout + b.stderr, re.M):
        fail("lake build failed")
    # 3. scan sources
    files = sorted((LEAN / "ErdosTernary").rglob("*.lean")) + [LEAN / "ErdosTernary.lean"]
    bad, warns = [], []
    for f in files:
        if not f.exists(): continue
        src = strip_comments(f.read_text())
        for pat in FORBIDDEN:
            for m in re.finditer(pat, src, re.M):
                bad.append(f"{f.relative_to(LEAN)}: {m.group(0).strip()}")
        for pat in WARN:
            for m in re.finditer(pat, src, re.M):
                warns.append(f"{f.relative_to(LEAN)}: {m.group(0).strip()}")
    for w in sorted(set(warns)):
        print("WARN", w)
    if bad:
        fail("forbidden tokens: " + "; ".join(sorted(set(bad))[:10]))
    # 4/5. axioms and expected type
    audit_dir = LEAN / ".audit"; audit_dir.mkdir(exist_ok=True)
    chk = audit_dir / "Check.lean"
    body = f"import {a.module}\nimport Statement\n#print axioms {a.theorem}\n"
    if a.expect:
        if a.expect == "Statement":
            body += f"example : ErdosTernary.Statement := @{a.theorem}\n"
        elif a.expect.startswith("UpTo:") and re.fullmatch(r"[0-9*^+() ]+", a.expect[5:]):
            body += f"example : ErdosTernary.UpTo ({a.expect[5:]}) := @{a.theorem}\n"
        else:
            fail("bad --expect")
    chk.write_text(body)
    r = subprocess.run(["lake", "env", "lean", str(chk)], cwd=LEAN, env=env(), capture_output=True, text=True)
    out = r.stdout + r.stderr
    print(out.strip())
    if r.returncode != 0 or "error" in out:
        fail("check file did not elaborate (wrong type, missing theorem, or error)")
    if "does not depend on any axioms" in out:
        axioms = set()
    else:
        m = re.search(r"depends on axioms: \[([^\]]*)\]", out)
        if not m:
            fail("could not read #print axioms output")
        axioms = {x.strip() for x in m.group(1).split(",") if x.strip()}
    # Lean >= 4.2x: native_decide adds an auxiliary axiom `<decl>._native.native_decide.ax_<i>_<j>` (tier B).
    # Hand-written axioms are impossible here because the source scan forbids the `axiom` keyword.
    native = {x for x in axioms if re.fullmatch(r"[\w.']+\._native\.native_decide\.ax(_\d+)+", x)}
    if axioms <= TIER_A:
        tier = "A"
    elif (axioms - native) <= TIER_B:
        tier = "B"
    else:
        fail(f"disallowed axioms: {sorted(axioms - TIER_B)}")
    print(f"LEAN_AUDIT: PASS tier={tier} axioms={sorted(axioms)}")

if __name__ == "__main__":
    main()
