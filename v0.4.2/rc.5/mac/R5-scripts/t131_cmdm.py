"""R5 #131 on the Mac (v0.4.2-rc.5.md, R5's #131 row), with rc.5's release build: the rc5-pre check's t131_cmdm.py again
(results/v0.4.2-rc5-pre/mac/). Run from R5-scripts/lib.sh's environment, test folder homes/app131 (the warning answered there):
  . R5-scripts/lib.sh app131 && python3 R5-scripts/t131_cmdm.py

The app (--control) with a 512 x 512 Life world at speed 30. Jimmie, three cycles: (1) ⌘M about 30 s, restore from
the Dock; (2) the yellow button about 15 s, restore; (3) ⌘M about 15 s, restore, then a zoom (+10 s) and a pan
(+20 s). The script pauses the world 14 s after the second restore, so cycle 3 is paused. Every 2 s: world_status
(generation), the window's on-screen flag (minimised = off screen), the app's CPU; while the window is on screen
after a restore, a capture of the window by its id, compared with the one before (the PNG files' bytes), with the
generation world_status gave just before. Ends 30 s after the third restore, or after 7 minutes.
"""
import hashlib
import json
import os
import re
import subprocess
import sys
import time

sys.path.insert(0, os.path.expanduser("~/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc5/mac/R5-scripts"))
import mcpc  # noqa: E402

B = os.path.expanduser("~/jetcarp-rc4/bin")
R = mcpc.R
out = open(os.path.join(R, "131-cmdm.txt"), "w", encoding="utf-8")


def say(s):
    s = mcpc.sub(s)
    print(s, flush=True)
    out.write(s + "\n")
    out.flush()


def cpu_s(pid):
    t = subprocess.run(["ps", "-o", "time=", "-p", str(pid)], capture_output=True, text=True).stdout.strip()
    if not t:
        return None
    s = 0.0
    for x in t.split(":"):
        s = s * 60 + float(x)
    return s


def frame(pid):
    r = subprocess.run([f"{B}/winframe", str(pid)], capture_output=True, text=True).stdout.split()
    return [int(x) for x in r] if len(r) == 5 else None


def capture(pid, name):
    rows = subprocess.run([os.path.expanduser("~/jetcarp-rc4-pre/bin/hostwin"), str(pid)], capture_output=True, text=True).stdout.split("\n")
    wid = next((r.split()[0] for r in rows if len(r.split()) == 4 and r.split()[1] == "0"), None)
    if not wid:
        return None
    f = os.path.join(R, name)
    subprocess.run(["screencapture", "-x", "-o", "-t", "png", "-l", wid, f])
    return hashlib.sha256(open(f, "rb").read()).hexdigest()[:16] if os.path.exists(f) else None


H = mcpc.H
os.makedirs(os.path.join(H, "cwd"), exist_ok=True)
ver = subprocess.run([mcpc.J, "--version"], capture_output=True, text=True).stdout.strip()
say(f"R5 #131, the Mac, {time.strftime('%Y-%m-%d %I:%M:%S %p %Z')}; $J = rc.5's release build ({ver}, c0db1ab); test folder $H = homes/app131")
app = subprocess.Popen([mcpc.J, "--control"], cwd=os.path.join(H, "cwd"), stdout=open(os.path.join(H, "app.out"), "w"), stderr=subprocess.STDOUT)
f = None
for _ in range(60):
    time.sleep(1)
    f = frame(app.pid)
    if f:
        break
say(f"app pid {app.pid}, window frame {f}")
time.sleep(5)
for attempt in range(10):
    m = mcpc.Mcp(os.path.join(R, "131-cmdm.jsonl"), args=["--app"], maxlog=1200)
    m.init()
    err, txt, _ = m.call("world_new", {"tiling": "square", "width": 512, "height": 512, "cas": [{"rule": "Life", "seed": "random:0.3"}]}, timeout=30)
    if err is False:
        break
    m.close()
    time.sleep(3)
say(f"world_new -> isError={err}")
err, txt, _ = m.call("app_display", {"playing": True, "speed": 30})
say(f"app_display playing speed 30 -> isError={err}")

rows = []
t0 = time.time()
last_t, last_g, last_c = None, None, cpu_s(app.pid)
was_on, restores, minimises, restored_at, paused = True, 0, 0, None, False
prev_hash = None
names = {0: "in view", 1: "after ⌘M 1", 2: "after the yellow button", 3: "after ⌘M 2 (paused)"}
say("   t(s)  phase                      gen     gens/s  on  CPU%  capture")
while time.time() - t0 < 420:
    ts = time.time()
    err, txt, _ = m.call("world_status", {}, timeout=30)
    g = re.search(r'"generation":\s*(\d+)', txt or "")
    g = int(g.group(1)) if g else None
    now = time.time()
    rate = (g - last_g) / (now - last_t) if (g is not None and last_g is not None) else None
    c = cpu_s(app.pid)
    cpu = 100 * (c - last_c) / (now - last_t) if (last_t and c is not None and last_c is not None) else None
    last_t, last_g, last_c = now, g, c
    fr = frame(app.pid)
    on = bool(fr and fr[4])
    if was_on and not on:
        minimises += 1
        say(f"  -- minimised ({minimises}) by {now - t0:.1f} s")
        prev_hash = None
    if not was_on and on:
        restores += 1
        restored_at = now
        say(f"  -- restored ({restores}) by {now - t0:.1f} s")
    was_on = on
    phase = ("minimised " + str(minimises)) if not on else names.get(restores, f"after restore {restores}")
    cap = ""
    if on and restores >= 1:
        name = f"131-r{restores}-{int(now - restored_at):03d}s.png"
        h = capture(app.pid, name)
        cap = f"{name} {h} " + ("first" if prev_hash is None else ("CHANGED" if h != prev_hash else "same"))
        prev_hash = h
    rows.append({"t": round(now - t0, 1), "phase": phase, "generation": g, "gens_per_s": rate, "on": on, "cpu": cpu, "capture": cap, "error": err})
    say(f"  {now - t0:5.1f}  {phase:24}  {str(g):>7}  {('%.1f' % rate) if rate is not None else '-':>6}  {int(on)}  {('%.0f' % cpu) if cpu is not None else '-':>4}  {cap}")
    if restores == 2 and not paused and now - restored_at > 14:
        e2, _, _ = m.call("app_display", {"playing": False})
        paused = True
        say(f"  -- app_display playing false at {now - t0:.1f} s -> isError={e2}")
    if restores >= 3 and now - restored_at > 30:
        break
    time.sleep(max(0, 2 - (time.time() - ts)))
json.dump(rows, open(os.path.join(R, "131-cmdm.json"), "w"), indent=0)
say("")
for ph in ["in view"] + [f"minimised {i}" for i in (1, 2, 3)] + [names[i] for i in (1, 2, 3)]:
    r = [x for x in rows if x["phase"] == ph]
    if not r:
        continue
    gg = [x for x in r if x["generation"] is not None]
    rate = (gg[-1]["generation"] - gg[0]["generation"]) / (gg[-1]["t"] - gg[0]["t"]) if len(gg) > 1 else None
    cp = sorted(x["cpu"] for x in r if x["cpu"] is not None)
    caps = [x["capture"] for x in r if x["capture"]]
    say(f"{ph}: {len(r)} polls, {sum(1 for x in r if x['error'])} errors, {('%.1f' % rate) if rate is not None else '-'} gens/s, "
        f"CPU median {cp[len(cp) // 2] if cp else 0:.0f}% of a core; captures: {len(caps)}, changed {sum('CHANGED' in x for x in caps)}, same {sum(x.endswith('same') for x in caps)}")
m.close()
app.terminate()
try:
    app.wait(15)
except subprocess.TimeoutExpired:
    app.kill()
say(f"the app closed (exit {app.returncode})")
