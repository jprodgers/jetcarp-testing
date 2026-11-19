#!/usr/bin/env python3
"""Audit re-run of the published parity set on this machine's CPU (and, optionally, a software GPU).
Usage: parity_run.py JETCARP PARITY_DIR OUT.csv [--gens N] [--gpu]"""
import csv, json, os, subprocess, sys, time
B, D, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
G = int(sys.argv[sys.argv.index("--gens") + 1]) if "--gens" in sys.argv else 300
modes = ["cpu"] + (["gpu"] if "--gpu" in sys.argv else [])
rows = list(csv.DictReader(open(os.path.join(D, "expected.csv"))))
out = []
for r in rows:
    f = os.path.join(D, "scenes", f"{r['n']}.json")
    rec = {"n": r["n"], "id": r["id"], "expected": r["hash"]}
    for m in modes:
        t = time.time()
        p = subprocess.run([B, "run", f, "--gens", str(G), "--json", f"--{m}"], capture_output=True, text=True)
        try:
            d = json.loads(p.stdout); h = d.get("hash"); b = str(d.get("backend", ""))
        except Exception:
            h, b = "ERROR", (p.stderr or p.stdout).strip().replace("\n", " ")[:160]
        rec[m] = h; rec[m + "_ok"] = (h == r["hash"]); rec[m + "_s"] = round(time.time() - t, 3); rec[m + "_backend"] = b[:120]
    out.append(rec)
    if not all(rec[m + "_ok"] for m in modes):
        print("MISMATCH", rec, flush=True)
with open(OUT, "w", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=list(out[0].keys())); w.writeheader(); w.writerows(out)
for m in modes:
    print(f"{m}: {sum(x[m+'_ok'] for x in out)} of {len(out)} scenes match expected.csv after {G} generations; total {sum(x[m+'_s'] for x in out):.0f} s")
