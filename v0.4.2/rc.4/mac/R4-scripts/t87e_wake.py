"""rc.4 wave on the Mac, R4 #87, runs 5 and 6, the main session's checks (NOTES 4:36 AM): what wakes the frozen window?
  python3 t87e_wake.py run5    the world running; after the restore the script covers the window for 4 s by itself
                               (+6 to +10 s); Jimmie clicks in the Scene pane's empty space at +20 s, resizes the
                               window by its corner at +30 s.
  python3 t87e_wake.py run7    the world running; Jimmie minimises with the window's yellow button, not ⌘M (the main
                               session's confirming check, NOTES 4:45 AM), restores from the Dock and leaves it.
  python3 t87e_wake.py run6    the world paused (app_display playing false, 10 s in); after the restore Jimmie
                               zooms with a scroll over the grid at +10 s and pans at +20 s.
Captured every 2 s after the restore and compared with the capture before (the PNG files' bytes). Run 3's text follows.
Run 3: does anything wake the window after a restore from the Dock? Jimmie: front,
⌘M for about 15 s, restore; then, counted from the restore: at 10 s the mouse moved over the grid (no click), at 20 s
a click on the title bar, at 30 s ⌘Tab to another app and back. Every 2 s after the restore the window is captured
and compared with the capture before (the PNG files' bytes). Otherwise as t87b_minimise.py (runs 1 and 2).

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
RUN = sys.argv[1] if len(sys.argv) > 1 else "run5"

B = os.path.expanduser("~/jetcarp-rc4/bin")
OUT = os.path.join(mcpc.R, f"87e-{RUN}.txt")
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


def capture(pid, name):
    """The app's own window (layer 0, the largest) captured by id, no shadow; returns (file, sha256 of its pixels)."""
    rows = subprocess.run([os.path.expanduser("~/jetcarp-rc4-pre/bin/hostwin"), str(pid)], capture_output=True, text=True).stdout.split("\n")
    wid = next((r.split()[0] for r in rows if len(r.split()) == 4 and r.split()[1] == "0"), None)
    if not wid:
        return None, None
    f = os.path.join(mcpc.R, name)
    subprocess.run(["screencapture", "-x", "-o", "-t", "png", "-l", wid, f])
    # (Run 2 hashed sips' BMP output here, which differs from run to run, so it called two identical captures
    # different. The PNG files themselves are compared now: 87b-captures.sha256 has run 2's.)
    import hashlib
    return name, hashlib.sha256(open(f, "rb").read()).hexdigest()[:16]


def assertions():
    t = subprocess.run(["pmset", "-g", "assertions"], capture_output=True, text=True).stdout
    return [ln.strip() for ln in t.splitlines() if "jetcarp" in ln.lower()]


H = mcpc.H
for d in ("cwd", "logs"):
    os.makedirs(os.path.join(H, d), exist_ok=True)
say(f"R4 #87 {RUN}: " + {"run5": "the world running; after the restore the script covers the window +6 to +10 s; Jimmie clicks in the Scene pane at +20 s, resizes at +30 s", "run6": "the world paused; after the restore Jimmie zooms at +10 s and pans at +20 s", "run7": "the world running; minimised with the yellow button (not ⌘M), restored from the Dock, left alone"}[RUN] + ", the Mac, {time.strftime('%Y-%m-%d %I:%M:%S %p %Z')}; test folder $H = homes/app87")
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
    m = mcpc.Mcp(os.path.join(mcpc.R, f"87e-{RUN}.jsonl"), args=["--app"], maxlog=1200)
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

# ---------------------------------------------------------------- #87, minimised by Jimmie
# The phase is read from the window: on screen (in view) or not (minimised). Ends 30 s after the window is back (captured twice at +5 s),
# or after 240 s.
rows = []
t0 = time.time()
last_t, last_g, last_c = None, None, cpu_s(app.pid)
seen_min = back_at = shots = shots0 = covered = None
paused = False
say("   t(s)  phase      answer(s)  generation  gens/s  frame (x y w h on-screen)  app-CPU(% of a core)")
while time.time() - t0 < 240:
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
    on = bool(fr and fr[4])
    if not on and seen_min is None:
        seen_min = now - t0
        say(f"  -- minimised (off screen) by {seen_min:.1f} s")
    if on and seen_min is not None and back_at is None:
        back_at = now - t0
        say(f"  -- back on screen by {back_at:.1f} s")
    phase = "in view" if seen_min is None else ("minimised" if back_at is None else "in view again")
    rows.append({"t": round(now - t0, 1), "phase": phase, "answer_s": round(ans, 2), "generation": g, "gens_per_s": rate,
                 "frame": fr, "cpu_pct_core": cpu, "error": err})
    say(f"  {now - t0:5.1f}  {phase:13}  {ans:6.2f}  {str(g):>10}  {('%.1f' % rate) if rate is not None else '-':>6}  "
        f"{str(fr):>26}  {('%.0f' % cpu) if cpu is not None else '-':>6}" + (f"  error {txt[:80]}" if err else ""))
    if RUN == "run6" and not paused and now - t0 > 10:
        e2, t2, _ = m.call("app_display", {"playing": False})
        paused = True
        say(f"  -- app_display playing false at {now - t0:.1f} s -> isError={e2}")
    if RUN == "run5" and back_at is not None and covered is None and now - t0 > back_at + 6:
        fx = frame(app.pid)
        covered = subprocess.Popen([f"{B}/cover", str(fx[0] - 40), str(fx[1] - 40), str(fx[2] + 80), str(fx[3] + 80), "4"], stdout=subprocess.PIPE, text=True)
        say(f"  -- +{now - t0 - back_at:4.1f} s: the script's cover window over it for 4 s: {covered.stdout.readline().strip()}")
    if back_at is not None:
        k = len([x for x in rows if x["phase"] == "in view again"])
        name = f"87e-{RUN}-after-{k:02d}.png"
        cap = capture(app.pid, name)
        prev = shots[-1] if shots else None
        shots = (shots or []) + [cap]
        say(f"  -- +{now - t0 - back_at:4.1f} s after the restore: {name} {cap[1]}: "
            + ("first" if prev is None else ("CHANGED: drawing" if cap[1] != prev[1] else "the same as before: still")))
    elif seen_min is None and now - t0 > 12 and shots0 is None:
        a = capture(app.pid, f"87e-{RUN}-before-1.png"); time.sleep(2); b = capture(app.pid, f"87e-{RUN}-before-2.png")
        shots0 = (a, b)
        say(f"  -- before: {a} and {b}: {'CHANGED: drawing' if a[1] != b[1] else 'the same: still'}")
    if back_at is not None and now - t0 > back_at + 44:
        break
    time.sleep(max(0, 2 - (time.time() - ts)))
json.dump(rows, open(os.path.join(mcpc.R, f"87e-{RUN}.json"), "w"), indent=0)


def seg(name):
    r = [x for x in rows if x["phase"] == name]
    if not r:
        say(f"{name}: no polls"); return
    g = [x for x in r if x["generation"] is not None]
    cpu = sorted(x["cpu_pct_core"] for x in r if x["cpu_pct_core"] is not None)
    rate = (g[-1]["generation"] - g[0]["generation"]) / (g[-1]["t"] - g[0]["t"]) if len(g) > 1 else None
    gaps = [b["t"] - a["t"] for a, b in zip(r, r[1:])]
    say(f"{name}: {len(r)} polls over {r[-1]['t'] - r[0]['t']:.0f} s, {sum(1 for x in r if x['error'])} errors, "
        f"{('%.1f' % rate) if rate else '-'} gens/s, slowest answer {max(x['answer_s'] for x in r)} s, "
        f"longest gap {max(gaps) if gaps else 0:.1f} s, app CPU median {cpu[len(cpu) // 2] if cpu else 0:.0f}% of a core "
        f"(range {cpu[0] if cpu else 0:.0f} to {cpu[-1] if cpu else 0:.0f})")


say("")
for name in ("in view", "minimised", "in view again"):
    seg(name)
m.call("app_display", {"playing": False})
m.close()
app.terminate()
try:
    app.wait(15)
except subprocess.TimeoutExpired:
    app.kill()
say(f"the app closed (exit {app.returncode})")
