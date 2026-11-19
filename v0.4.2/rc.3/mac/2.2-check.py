#!/usr/bin/env python3
"""2.2 (M2): GPU-screened explore runs replay the same on the CPU (the Acer's 2.2-check.ps1, for the Mac).

For 20 JACA and 10 Life-like runs of job 1 (`jobs runs … --measures all --format json`): save each scene,
run it on the CPU for the run's gens, and compare measures.density with the replay's population
(sum of fields[].population) / cells, to 6 decimals. Then five of the scenes on the CPU, on the GPU world
path and with no flag: the hashes must agree.

Usage: python3 2.2-check.py <jetcarp> <results folder> <work folder>   (JETCARP_* set as in env2.sh)
"""
import csv, json, os, subprocess, sys

J, R, W = sys.argv[1], sys.argv[2], sys.argv[3]
JOB = "1"
os.makedirs(f"{W}/2.2", exist_ok=True)


def jet(*args):
    p = subprocess.run([J, *args], capture_output=True, text=True)
    if p.returncode != 0:
        raise SystemExit(f"jetcarp {' '.join(args)} -> exit {p.returncode}: {p.stderr.strip()}")
    return p.stdout


runs = []
for fam, n, f in (("jaca", 20, "2.2-jaca.json"), ("life_like", 10, "2.2-life.json")):
    out = jet("jobs", "runs", JOB, "--family", fam, "--limit", str(n), "--measures", "all", "--format", "json")
    open(f"{R}/{f}", "w").write(out)
    d = json.loads(out)
    runs += d["runs"] if isinstance(d, dict) else d

rows = []
for run in runs:
    scene = f"{W}/2.2/{run['id']}.json"
    jet("jobs", "scene", JOB, str(run["id"]), "--save", scene)
    x = json.loads(jet("run", scene, "--gens", str(run["gens"]), "--json", "--cpu"))
    pop = sum(f["population"] for f in x["fields"])
    replay = pop / x["cells"]
    stored = float(run["measures"]["density"])
    rows.append(dict(run=run["id"], family=run["family"], rule=run["rule"], tiling=run.get("tiling"), gens=run["gens"],
                     cells=run["cells"], replay_cells=x["cells"], population=pop, stored=round(stored, 6),
                     replay=round(replay, 6), diff=abs(stored - replay), ok=abs(stored - replay) <= 5e-7,
                     cells_same=run["cells"] == x["cells"], backend=x.get("backend")))

with open(f"{R}/2.2-replays.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0]))
    w.writeheader(); w.writerows(rows)
bad = [r for r in rows if not r["ok"]]
print(f"{len(rows)} runs: {len(rows) - len(bad)} match to 6 decimals")
for r in bad:
    print(f"MISMATCH run {r['run']} ({r['family']} {r['rule']}): stored {r['stored']}, replay {r['replay']} "
          f"({r['population']} / {r['replay_cells']})")
print(f"backends of the replays: {sorted(set(r['backend'] for r in rows))}")
diffcells = [r for r in rows if not r["cells_same"]]
print(f"runs whose stored cells differ from the replay's: {len(diffcells)}"
      + "".join(f"\n  run {r['run']} ({r['family']} {r['rule']} on {r['tiling']}): stored {r['cells']}, replay {r['replay_cells']}"
                for r in diffcells))

five = [r for r in rows if r["family"] == "jaca"][:3] + [r for r in rows if r["family"] == "life_like"][:2]
hashes = []
for r in five:
    scene = f"{W}/2.2/{r['run']}.json"
    c = json.loads(jet("run", scene, "--gens", str(r["gens"]), "--json", "--cpu"))
    g = json.loads(jet("run", scene, "--gens", str(r["gens"]), "--json", "--gpu"))
    d = json.loads(jet("run", scene, "--gens", str(r["gens"]), "--json"))
    hashes.append(dict(run=r["run"], family=r["family"], gens=r["gens"], cells=r["cells"], cpu=c["hash"], gpu=g["hash"],
                       default=d["hash"], same=c["hash"] == g["hash"] == d["hash"], gpu_backend=g.get("backend"),
                       default_backend=d.get("backend")))
with open(f"{R}/2.2-hashes.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(hashes[0]))
    w.writeheader(); w.writerows(hashes)
print(f"{sum(h['same'] for h in hashes)} of {len(hashes)} scenes: the same hash on --cpu, --gpu and no flag")
for h in hashes:
    print(f"  run {h['run']} ({h['family']}, {h['gens']} gens): cpu {h['cpu']} gpu {h['gpu']} default {h['default']}"
          f" | --gpu -> {h['gpu_backend']}; no flag -> {h['default_backend']}")
