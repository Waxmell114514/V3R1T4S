#!/usr/bin/env python3
"""Write each '=== FILE: path ===' section of BOOTSTRAP.md to its path (relative to the campaign root)."""
import pathlib, re, sys
root = pathlib.Path(__file__).resolve().parent.parent
text = (root / "BOOTSTRAP.md").read_text(encoding="utf-8")
parts = re.split(r"^=== FILE: (.+?) ===\n", text, flags=re.M)
force = "--force" in sys.argv
for path, body in zip(parts[1::2], parts[2::2]):
    p = root / path.strip()
    if p.exists() and not force:
        print("skip (exists):", path); continue
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(body.rstrip("\n") + "\n", encoding="utf-8")
    print("wrote", path)
