"""rc.4 wave on the Acer, R4 #87 (A: minimised for 60 s), with rc.4's release build: the pre-check's script with
~\\jetcarp-rc-042c\\bin\\jetcarp.exe and its own folder ~\\jetcarp-rc4\\a87 (the warning answered there first).

Starts the app (jetcarp.exe --control) with that folder, makes a 512 x 512 Life
world through `jetcarp mcp --app` and plays it at speed 30, then polls world_status every 2 s: 20 s in view,
60 s minimised by this script (ShowWindow(h, 6)), restored (ShowWindow(h, 9)), 20 s in view again. Each poll logs
the answer time, the generation, whether the window is minimised (IsIconic), and the app's CPU. Then the app is
closed. A-6's mcpc.py (rc.3) with the branch build and the scratch folder put in.

  python -X utf8 -B t87_minimise.py
"""
import ctypes
import ctypes.wintypes as wt
import json
import os
import re
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "v0.4.2-rc.3", "acer", "A6"))
import mcpc  # noqa: E402

T2 = os.path.join(os.path.expanduser("~"), "jetcarp-rc4", "a87")
mcpc.W = T2
mcpc.J = os.path.join(os.path.expanduser("~"), "jetcarp-rc-042c", "bin", "jetcarp.exe")
mcpc.R = HERE
u32 = ctypes.windll.user32
k32 = ctypes.windll.kernel32
u32.ShowWindow.argtypes = [wt.HWND, ctypes.c_int]
u32.IsIconic.argtypes = [wt.HWND]
out = open(os.path.join(HERE, "87-minimise.txt"), "w", encoding="utf-8")


def say(s):
    s = s.replace(T2, "~\\jetcarp-rc4\\a87")
    print(s, flush=True)
    out.write(s + "\n")
    out.flush()


def env():
    e = mcpc.env()
    e["JETCARP_RUNTIME_DIR"] = os.path.join(T2, "runtime")
    return e


def cpu_s(h):
    a, b, kt, ut = wt.FILETIME(), wt.FILETIME(), wt.FILETIME(), wt.FILETIME()
    k32.GetProcessTimes(h, ctypes.byref(a), ctypes.byref(b), ctypes.byref(kt), ctypes.byref(ut))
    f = lambda t: ((t.dwHighDateTime << 32) | t.dwLowDateTime) / 1e7
    return f(kt) + f(ut)


def main_window(pid):
    found = []
    PROC = ctypes.WINFUNCTYPE(wt.BOOL, wt.HWND, wt.LPARAM)

    def cb(hwnd, _):
        p = wt.DWORD()
        u32.GetWindowThreadProcessId(hwnd, ctypes.byref(p))
        if p.value == pid and u32.IsWindowVisible(hwnd):
            n = u32.GetWindowTextLengthW(hwnd)
            buf = ctypes.create_unicode_buffer(n + 1)
            u32.GetWindowTextW(hwnd, buf, n + 1)
            if buf.value:
                found.append((hwnd, buf.value))
        return True

    u32.EnumWindows(PROC(cb), 0)
    return found[0] if found else (None, None)


# The app, with AI control on
for d in ("config", "data", "out", "library", "runtime", "cwd", "logs"):
    os.makedirs(os.path.join(T2, d), exist_ok=True)
say(f"app: {mcpc.J.replace(os.path.expanduser('~'), '~')} --control  [{time.strftime('%H:%M:%S')}]")
app = subprocess.Popen([mcpc.J, "--control"], env=env(), cwd=os.path.join(T2, "cwd"),
                       stdout=open(os.path.join(T2, "logs", "app87.out"), "w"), stderr=subprocess.STDOUT)
hwnd = title = None
for _ in range(60):
    time.sleep(1)
    hwnd, title = main_window(app.pid)
    if hwnd:
        break
say(f"app pid {app.pid}, window {title!r}")
h = k32.OpenProcess(0x1000, False, app.pid)
time.sleep(5)  # let AI control record its port and token

m = None
for attempt in range(10):
    m = mcpc.Mcp(os.path.join(HERE, "87-minimise.jsonl"), args=["--app"], maxlog=1200, extra_env={"JETCARP_RUNTIME_DIR": os.path.join(T2, "runtime")})
    m.init()
    err, txt, _ = m.call("world_new", {"tiling": "square", "width": 512, "height": 512, "cas": [{"rule": "Life", "seed": "random:0.3"}]}, timeout=30)
    if err is False:
        break
    say(f"(attempt {attempt + 1}: world_new -> {err}: {txt[:200]}; stderr {m.stderr[-2:]})")
    m.close()
    time.sleep(3)
say(f"world_new -> isError={err}: {txt.splitlines()[0] if txt else ''}")
err, txt, _ = m.call("app_display", {"playing": True, "speed": 30})
say(f"app_display playing speed 30 -> isError={err}")

rows = []
t0 = time.time()
last_t, last_g, last_c = None, None, cpu_s(h)
phase = "in view"
minimised_at = restored_at = None
say("   t(s)  phase      answer(s)  generation  gens/s  minimised  app-CPU(% of a core)")
while time.time() - t0 < 100:
    el = time.time() - t0
    if minimised_at is None and el >= 20:
        u32.ShowWindow(hwnd, 6)
        minimised_at = el
        phase = "minimised"
        say(f"  -- ShowWindow(h, 6) at {el:.1f} s")
    if restored_at is None and minimised_at is not None and el >= minimised_at + 60:
        u32.ShowWindow(hwnd, 9)
        restored_at = el
        phase = "restored"
        say(f"  -- ShowWindow(h, 9) at {el:.1f} s")
    ts = time.time()
    err, txt, _ = m.call("world_status", {}, timeout=30)
    ans = time.time() - ts
    g = re.search(r'"generation":\s*(\d+)', txt or "")
    g = int(g.group(1)) if g else None
    now = time.time()
    rate = (g - last_g) / (now - last_t) if (g is not None and last_g is not None) else None
    c = cpu_s(h)
    cpu = 100 * (c - last_c) / (now - last_t) if last_t else None
    last_t, last_g, last_c = now, g, c
    icon = bool(u32.IsIconic(hwnd))
    rows.append({"t": round(now - t0, 1), "phase": phase, "answer_s": round(ans, 2), "generation": g, "gens_per_s": rate,
                 "minimised": icon, "cpu_pct_core": cpu, "error": err})
    say(f"  {now - t0:5.1f}  {phase:9}  {ans:8.2f}  {str(g):>10}  {('%.1f' % rate) if rate is not None else '-':>6}  "
        f"{str(icon):>9}  {('%.0f' % cpu) if cpu is not None else '-':>6}" + (f"  error {txt[:80]}" if err else ""))
    time.sleep(max(0, 2 - (time.time() - ts)))
m.call("app_display", {"playing": False})
m.close()
json.dump(rows, open(os.path.join(HERE, "87-minimise.json"), "w"), indent=0)


def seg(name):
    r = [x for x in rows if x["phase"] == name]
    g = [x for x in r if x["generation"] is not None]
    cpu = [x["cpu_pct_core"] for x in r if x["cpu_pct_core"] is not None]
    rate = (g[-1]["generation"] - g[0]["generation"]) / (g[-1]["t"] - g[0]["t"]) if len(g) > 1 else None
    worst = max(x["answer_s"] for x in r) if r else None
    say(f"{name}: {len(r)} polls, {('%.1f' % rate) if rate else '-'} gens/s, slowest answer {worst} s, "
        f"app CPU mean {('%.0f' % (sum(cpu) / len(cpu))) if cpu else '-'}% of a core")


for p in ("in view", "minimised", "restored"):
    seg(p)
app_closed = False
try:
    u32.PostMessageW(hwnd, 0x0010, 0, 0)  # WM_CLOSE
    app.wait(20)
    app_closed = True
except Exception:
    app.kill()
say(f"app closed: {'by WM_CLOSE' if app_closed else 'killed after 20 s'} (exit {app.returncode})")
out.close()
