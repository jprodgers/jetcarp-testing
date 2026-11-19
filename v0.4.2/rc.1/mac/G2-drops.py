#!/usr/bin/env python3
"""Sandpile drop scenes (parity 364-370): CPU against GPU at generations 1 and 300, with populations.
Usage: python3 G2-drops.py JETCARP_BINARY PARITY_FOLDER OUT.csv [first last]"""
import csv, json, os, subprocess, sys

B, D, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
first, last = (int(sys.argv[4]), int(sys.argv[5])) if len(sys.argv) > 5 else (364, 370)
ids = {r["n"]: r for r in csv.DictReader(open(os.path.join(D, "expected.csv")))}


def run(scene, gens, mode):
    p = subprocess.run([B, "run", scene, "--gens", str(gens), "--json", f"--{mode}"],
                       capture_output=True, text=True)
    try:
        d = json.loads(p.stdout)
        pop = sum(f.get("population", 0) for f in d.get("fields", []))
        return d.get("hash"), pop, str(d.get("backend", ""))
    except Exception:
        return "ERROR", None, (p.stderr or p.stdout).strip().replace("\n", " ")[:200]


rows = []
for n in range(first, last + 1):
    scene = os.path.join(D, "scenes", f"{n}.json")
    for gens in (1, 300):
        c, g = run(scene, gens, "cpu"), run(scene, gens, "gpu")
        row = {"n": n, "id": ids[str(n)]["id"], "gens": gens, "cpu": c[0], "gpu": g[0],
               "same": c[0] == g[0], "cpu_pop": c[1], "gpu_pop": g[1],
               "expected_300": ids[str(n)]["hash"] if gens == 300 else "", "gpu_backend": g[2][:120]}
        rows.append(row)
        print(row, flush=True)
with open(OUT, "w", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
    w.writeheader()
    w.writerows(rows)
