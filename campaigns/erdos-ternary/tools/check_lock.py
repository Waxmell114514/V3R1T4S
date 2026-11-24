#!/usr/bin/env python3
"""Recompute sha256 of every file in verify/ and compare with verify.lock. Prints LOCK: OK or LOCK: MISMATCH."""
import hashlib, pathlib, sys
root = pathlib.Path(__file__).resolve().parent.parent
want = {}
for line in (root / "verify.lock").read_text().split("\n"):
    if line.strip():
        h, name = line.split(None, 1); want[name.strip()] = h
have = {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
        for p in (root / "verify").iterdir() if p.is_file() and p.suffix != ".pyc"}
bad = sorted(set(want) ^ set(have)) + sorted(n for n in want if n in have and want[n] != have[n])
print("LOCK: OK" if not bad else f"LOCK: MISMATCH {bad}")
sys.exit(1 if bad else 0)
