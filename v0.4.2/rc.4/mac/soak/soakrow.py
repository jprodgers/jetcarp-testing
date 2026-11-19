"""One CSV row of the soak from `host status --json` (argv[1]) and the process figures passed after it.

python3 soakrow.py status.json <time> <elapsed_min> <pid> <ps_cpu> <top_cpu> <rss_mb> <footprint_mb> <gpu_pct>
python3 soakrow.py --header
Per screen: rotation, item number/count, label, generation, cells, cell size, frame rate, speed, measured speed, paused,
hidden; for the host: memory_mb, paused/why, held/why.
"""
import csv
import json
import sys

COLS = ["time", "elapsed_min", "pid", "alive", "ps_cpu", "top_cpu", "rss_mb", "footprint_mb", "gpu_pct", "memory_mb",
        "paused", "paused_why", "held", "held_why", "screens"]
w = csv.writer(sys.stdout)
if sys.argv[1] == "--header":
    w.writerow(COLS)
    sys.exit()
t, el, pid, pc, tc, rss, fp, gpu = sys.argv[2:10]
try:
    d = json.load(open(sys.argv[1]))
    alive = bool(d.get("running", True)) and bool(d.get("pid"))
except Exception:
    d, alive = {}, False


def speed(st, s):
    for k in ("measured_speed",):
        if k in st:
            return st[k]
        if k in s:
            return s[k]
    return ""


scr = []
for i, s in enumerate(d.get("screens", [])):
    st = s.get("stage") or {}
    scr.append(f"s{i} '{st.get('rotation')}' {st.get('number')}/{st.get('count')} '{st.get('label')}' gen {st.get('generation')} "
               f"{st.get('cells')}c@{round(st.get('cell_px') or 0, 2)}px fps {st.get('frame_rate')} speed {st.get('speed')} "
               f"measured {speed(st, s)} paused {st.get('paused')} hidden {s.get('hidden')}")
w.writerow([t, el, pid, alive, pc, tc, rss, fp, gpu, d.get("memory_mb", ""), d.get("paused", ""),
            "; ".join(map(str, d.get("paused_why") or [])), d.get("held", ""), "; ".join(map(str, d.get("held_why") or [])),
            " || ".join(scr)])
