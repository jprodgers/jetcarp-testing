"""The soak's summary from soak.csv (and soak-95.csv). The first line goes in summary.txt.

python3 soaksum.py soak.csv [soak-95.csv]
"""
import csv
import re
import statistics as st
import sys

rows = list(csv.DictReader(open(sys.argv[1])))
if not rows:
    print("FAIL: no samples")
    sys.exit()


def num(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return None


def screens(r):
    out = []
    for part in (r["screens"] or "").split(" || "):
        m = re.search(r"s(\d) '([^']*)' (\S+)/(\S+) '([^']*)' gen (\S+) (\S+)c@(\S+)px fps (\S+) speed (\S+) measured (\S*) paused (\S+) hidden (\S+)", part)
        if m:
            out.append(dict(zip(["s", "rot", "num", "count", "label", "gen", "cells", "px", "fps", "speed", "measured", "paused", "hidden"], m.groups())))
    return out


alive = sum(r["alive"] == "True" for r in rows)
pids = sorted({r["pid"] for r in rows if r["pid"]})
mins = [num(r["elapsed_min"]) or 0 for r in rows]

# Does the screen keep changing? Between two samples, screen 0's item or generation moved.
moved = stuck = 0
labels = set()
stuck_at = []
for a, b in zip(rows, rows[1:]):
    sa, sb = screens(a), screens(b)
    if not sa or not sb:
        stuck += 1
        stuck_at.append(b["time"])
        continue
    labels.add(sb[0]["label"])
    if (sa[0]["label"], sa[0]["num"], sa[0]["gen"]) != (sb[0]["label"], sb[0]["num"], sb[0]["gen"]):
        moved += 1
    else:
        stuck += 1
        stuck_at.append(b["time"])

held = [r for r in rows if r["held"] not in ("", "False", "[]", "None")]
held_why = sorted({r["held_why"] for r in held if r["held_why"]})
fp = [(m, num(r["footprint_mb"])) for m, r in zip(mins, rows) if num(r["footprint_mb"]) is not None]
mem = [(m, num(r["memory_mb"])) for m, r in zip(mins, rows) if num(r["memory_mb"]) is not None]
rss = [num(r["rss_mb"]) for r in rows if num(r["rss_mb"]) is not None]
cpu = [num(r["top_cpu"]) for r in rows if num(r["top_cpu"]) is not None]
gpu = [num(r["gpu_pct"]) for r in rows if num(r["gpu_pct"]) is not None]


def slope(pts):   # MB per hour, least squares
    if len(pts) < 3:
        return None
    xs = [p[0] / 60 for p in pts]
    ys = [p[1] for p in pts]
    mx, my = st.mean(xs), st.mean(ys)
    den = sum((x - mx) ** 2 for x in xs)
    return sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / den if den else None


def hour(pts, first):
    end = max(p[0] for p in pts)
    sel = [p[1] for p in pts if (p[0] <= 60 if first else p[0] >= end - 60)]
    return st.median(sel) if sel else None


def f(x, d=1):
    return "-" if x is None else f"{x:.{d}f}"


fs, ms = (slope(fp) if fp else None), (slope(mem) if mem else None)
fp1, fp9 = (hour(fp, True), hour(fp, False)) if fp else (None, None)
ok = alive == len(rows) and len(pids) == 1 and stuck <= len(held) and fs is not None and fs < 5
print(f"{'pass' if ok else 'CHECK'} (automatic): {len(rows)} samples over {f(mins[-1] / 60)} h; alive {alive}/{len(rows)}, "
      f"pid {', '.join(pids)}; screen 0 moved in {moved} of {moved + stuck} intervals ({len(labels)} items seen); "
      f"footprint {f(fp1)} MB (first hour) -> {f(fp9)} MB (last hour), max {f(max(p[1] for p in fp) if fp else None)}, "
      f"{f(fs, 2)} MB/h; status memory {f(mem[0][1] if mem else None, 0)} -> {f(mem[-1][1] if mem else None, 0)} MB "
      f"({f(ms, 2)} MB/h); RSS {f(min(rss) if rss else None, 0)}-{f(max(rss) if rss else None, 0)} MB; "
      f"CPU (top) median {f(st.median(cpu) if cpu else None)}%; whole GPU median {f(st.median(gpu) if gpu else None, 0)}%; "
      f"held in {len(held)} samples{(' (' + ' | '.join(held_why) + ')') if held_why else ''}")
print(f"items seen on screen 0: {sorted(labels)}")
if stuck_at:
    print(f"samples where screen 0 hadn't moved: {stuck_at}")
speeds = sorted({(s["speed"], s["measured"]) for r in rows for s in screens(r)})
print(f"(speed, measured speed) pairs seen: {speeds[:20]}")

if len(sys.argv) > 2:
    print("\n#95 (pmset displaysleepnow, then caffeinate -u):")
    for r in csv.DictReader(open(sys.argv[2])):
        s = screens(r)
        print(f"  {r['time']} {r['elapsed_min']:>12}: held {r['held']} {r['held_why'] or ''} | paused {r['paused']} "
              f"{r['paused_why'] or ''} | " + "; ".join(f"s{x['s']} '{x['label']}' gen {x['gen']} hidden {x['hidden']}" for x in s)
              + f" | cpu {r['top_cpu']}% footprint {r['footprint_mb']} MB")
