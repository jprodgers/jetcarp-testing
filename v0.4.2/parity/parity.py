#!/usr/bin/env python3
"""Run every parity scene on this machine's CPU and GPU and compare with the Framework's CPU hashes.
Usage: python3 parity.py JETCARP_BINARY PARITY_FOLDER OUT.csv [--gens N]
(PARITY_FOLDER holds scenes/ and expected.csv; set JETCARP_GPU first to choose an adapter. --gens:
the generations each scene runs, default 300; parity/long/ uses 5000.)"""
import csv, json, os, re, subprocess, sys, time
B, D, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
G = int(sys.argv[sys.argv.index("--gens") + 1]) if "--gens" in sys.argv else 300
rows = list(csv.DictReader(open(os.path.join(D, "expected.csv"))))
res = []
for r in rows:
    f = os.path.join(D, "scenes", f"{r['n']}.json")
    got = {}
    for mode in ("cpu", "gpu"):
        t = time.time()
        p = subprocess.run([B, "run", f, "--gens", str(G), "--json", f"--{mode}"], capture_output=True, text=True)
        try:
            d = json.loads(p.stdout); h, b = d.get("hash"), str(d.get("backend", ""))
        except Exception:
            h, b = "ERROR", (p.stderr or p.stdout).strip().replace("\n", " ")[:200]
        got[mode] = (h, b, round(time.time() - t, 3))
    b = got["gpu"][1]; m = re.search(r"(\d+) of (\d+) generations on the cpu", b)
    gpu_gens = (int(m.group(2)) - int(m.group(1))) if m else (G if b.startswith("gpu") else 0)
    res.append({"n": r["n"], "id": r["id"], "expected": r["hash"], "cpu": got["cpu"][0], "gpu": got["gpu"][0],
                "cpu_ok": got["cpu"][0] == r["hash"], "gpu_ok": got["gpu"][0] == r["hash"],
                "gpu_gens": gpu_gens, "cpu_s": got["cpu"][2], "gpu_s": got["gpu"][2], "gpu_backend": b[:160]})
    if not (res[-1]["cpu_ok"] and res[-1]["gpu_ok"]):
        print("MISMATCH", res[-1], flush=True)
with open(OUT, "w", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=list(res[0].keys())); w.writeheader(); w.writerows(res)
bad_cpu = sum(not x["cpu_ok"] for x in res); bad_gpu = sum(not x["gpu_ok"] for x in res)
on_gpu = sum(x["gpu_gens"] == G for x in res)
print(f"{len(res)} scenes: CPU matches {len(res)-bad_cpu}, GPU matches {len(res)-bad_gpu}; all {G} generations on the GPU in {on_gpu}")
print("adapter:", next((x["gpu_backend"] for x in res if x["gpu_gens"] == G), "none"))
