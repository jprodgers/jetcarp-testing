"""rc.4 wave on the Mac, R4 #87 (covered) and #89 (Keep awake), unattended, with rc.4's release build.

Run from R4-scripts/lib.sh's environment (test folder ~/jetcarp-rc4/homes/app87, the warning answered and setup done
there first):  . R4-scripts/lib.sh app87 && python3 R4-scripts/t87_89_app.py

#87: starts the app (`jetcarp --control`), makes a 512 x 512 Life world through `jetcarp mcp --app` and plays it at
speed 30, then polls world_status every 2 s: 20 s in view, 60 s covered by an opaque window of this script's (the
`cover` tool, above the app's window and a margin round it), 20 s in view again. Each poll logs the answer time, the
generation, the window's frame and on-screen flag (`winframe`), and the app's CPU (from `ps -o time`). Minimising
needs the Accessibility permission, which this session hasn't, so it is left for Jimmie (⌘M).
#89: app_display keep_awake on, then `pmset -g assertions` (JETCARP's lines); off, then again. (The View menu's
item is the same setting; Jimmie clicks it in the hands-on round.)
The app is closed at the end. The Acer's t87_minimise.py, for the Mac.
"""
import json
import os
import re
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mcpc  # noqa: E402

B = os.path.expanduser("~/jetcarp-rc4/bin")
OUT = os.path.join(mcpc.R, "87-89-app.txt")
out = open(OUT, "w", encoding="utf-8")


def say(s):
    s = mcpc.sub(s)
    print(s, flush=True)
    out.write(s + "\n")
    out.flush()


def cpu_s(pid):
    t = subprocess.run(["ps", "-o", "time=", "-p", str(pid)], capture_output=True, text=True).stdout.strip()
    if not t:
        return None
    parts = [float(x) for x in t.split(":")]
    s = 0.0
    for x in parts:
        s = s * 60 + x
    return s


def frame(pid):
    r = subprocess.run([f"{B}/winframe", str(pid)], capture_output=True, text=True).stdout.split()
    return [int(x) for x in r] if len(r) == 5 else None


def assertions():
    t = subprocess.run(["pmset", "-g", "assertions"], capture_output=True, text=True).stdout
    return [ln.strip() for ln in t.splitlines() if "jetcarp" in ln.lower()]


H = mcpc.H
for d in ("cwd", "logs"):
    os.makedirs(os.path.join(H, d), exist_ok=True)
say(f"R4 #87 (covered) and #89 (Keep awake), the Mac, {time.strftime('%Y-%m-%d %I:%M:%S %p %Z')}; test folder $H = homes/app87")
say(f"app: $J --control  [{time.strftime('%H:%M:%S')}]")
app = subprocess.Popen([mcpc.J, "--control"], cwd=os.path.join(H, "cwd"),
                       stdout=open(os.path.join(H, "logs", "app.out"), "w"), stderr=subprocess.STDOUT)
f = None
for _ in range(60):
    time.sleep(1)
    f = frame(app.pid)
    if f:
        break
say(f"app pid {app.pid}, window frame {f}")
time.sleep(5)  # let AI control record its port and token

m = None
err = txt = None
for attempt in range(10):
    m = mcpc.Mcp(os.path.join(mcpc.R, "87-89-app.jsonl"), args=["--app"], maxlog=1200)
    m.init()
    err, txt, _ = m.call("world_new", {"tiling": "square", "width": 512, "height": 512, "cas": [{"rule": "Life", "seed": "random:0.3"}]}, timeout=30)
    if err is False:
        break
    say(f"(attempt {attempt + 1}: world_new -> {err}: {txt[:200]}; stderr {m.stderr[-2:]})")
    m.close()
    time.sleep(3)
say(f"world_new -> isError={err}: {txt.splitlines()[0] if txt else ''}")
err, txt, _ = m.call("app_display", {"playing": True, "speed": 30})
say(f"app_display playing speed 30 -> isError={err}{(': ' + txt[:200]) if err else ''}")

# ---------------------------------------------------------------- #87, covered
rows = []
t0 = time.time()
last_t, last_g, last_c = None, None, cpu_s(app.pid)
phase = "in view"
covered_at = uncovered_at = None
cover = None
say("   t(s)  phase      answer(s)  generation  gens/s  frame (x y w h on-screen)  app-CPU(% of a core)")
while time.time() - t0 < 100:
    el = time.time() - t0
    if covered_at is None and el >= 20:
        fx = frame(app.pid) or f
        x, y, w, h = fx[0] - 40, fx[1] - 40, fx[2] + 80, fx[3] + 80
        cover = subprocess.Popen([f"{B}/cover", str(x), str(y), str(w), str(h), "60"], stdout=subprocess.PIPE, text=True)
        covered_at = el
        phase = "covered"
        say(f"  -- cover {x} {y} {w} {h} 60 at {el:.1f} s: {cover.stdout.readline().strip()}")
    if uncovered_at is None and covered_at is not None and cover.poll() is not None:
        uncovered_at = el
        phase = "in view again"
        say(f"  -- the cover window gone at {el:.1f} s (exit {cover.returncode})")
    ts = time.time()
    err, txt, _ = m.call("world_status", {}, timeout=30)
    ans = time.time() - ts
    g = re.search(r'"generation":\s*(\d+)', txt or "")
    g = int(g.group(1)) if g else None
    now = time.time()
    rate = (g - last_g) / (now - last_t) if (g is not None and last_g is not None) else None
    c = cpu_s(app.pid)
    cpu = 100 * (c - last_c) / (now - last_t) if (last_t and c is not None and last_c is not None) else None
    last_t, last_g, last_c = now, g, c
    fr = frame(app.pid)
    rows.append({"t": round(now - t0, 1), "phase": phase, "answer_s": round(ans, 2), "generation": g, "gens_per_s": rate,
                 "frame": fr, "cpu_pct_core": cpu, "error": err})
    say(f"  {now - t0:5.1f}  {phase:13}  {ans:6.2f}  {str(g):>10}  {('%.1f' % rate) if rate is not None else '-':>6}  "
        f"{str(fr):>26}  {('%.0f' % cpu) if cpu is not None else '-':>6}" + (f"  error {txt[:80]}" if err else ""))
    time.sleep(max(0, 2 - (time.time() - ts)))
json.dump(rows, open(os.path.join(mcpc.R, "87-89-app.json"), "w"), indent=0)


def seg(name):
    r = [x for x in rows if x["phase"] == name]
    g = [x for x in r if x["generation"] is not None]
    cpu = sorted(x["cpu_pct_core"] for x in r if x["cpu_pct_core"] is not None)
    rate = (g[-1]["generation"] - g[0]["generation"]) / (g[-1]["t"] - g[0]["t"]) if len(g) > 1 else None
    worst = max(x["answer_s"] for x in r) if r else None
    gaps = [b["t"] - a["t"] for a, b in zip(r, r[1:])]
    say(f"{name}: {len(r)} polls, {sum(1 for x in r if x['error'])} errors, {('%.1f' % rate) if rate else '-'} gens/s, "
        f"slowest answer {worst} s, longest gap between answers {max(gaps) if gaps else '-':.1f} s, "
        f"app CPU median {cpu[len(cpu) // 2] if cpu else '-':.0f}% of a core (range {cpu[0] if cpu else 0:.0f} to {cpu[-1] if cpu else 0:.0f})")


say("")
for name in ("in view", "covered", "in view again"):
    seg(name)

# ---------------------------------------------------------------- #89, Keep awake
say("")
say("#89 Keep awake, through app_display (the View menu's setting)")
say(f"  before: JETCARP's assertions: {assertions() or 'none'}")
err, txt, _ = m.call("app_display", {})
k = re.search(r'"keep_awake":\s*(true|false)', txt or "")
say(f"  app_display state: keep_awake {k.group(1) if k else '?'}")
err, txt, _ = m.call("app_display", {"keep_awake": True})
say(f"  app_display keep_awake true -> isError={err}{(': ' + txt[:200]) if err else ''}")
time.sleep(4)
on = assertions()
say(f"  on, 4 s later: JETCARP's assertions: {on or 'none'}")
for ln in subprocess.run(["pmset", "-g", "assertions"], capture_output=True, text=True).stdout.splitlines():
    if ln.strip().startswith(("PreventUserIdleDisplaySleep", "PreventUserIdleSystemSleep", "NoDisplaySleepAssertion")):
        say(f"    summary line: {ln.strip()}")
err, txt, _ = m.call("app_display", {"keep_awake": False})
say(f"  app_display keep_awake false -> isError={err}{(': ' + txt[:200]) if err else ''}")
time.sleep(4)
off = assertions()
say(f"  off, 4 s later: JETCARP's assertions: {off or 'none'}")
k2 = re.search(r'"keep_awake":\s*(true|false)', m.call("app_display", {})[1] or "")
say(f"  app_display state: keep_awake {k2.group(1) if k2 else '?'}")
say(f"#89: {'pass' if any('NoDisplaySleep' in x or 'PreventUserIdleDisplaySleep' in x for x in on) and not off else 'CHECK'}")

m.call("app_display", {"playing": False})
m.close()
app.terminate()
try:
    app.wait(15)
except subprocess.TimeoutExpired:
    app.kill()
say(f"the app closed (exit {app.returncode})")
