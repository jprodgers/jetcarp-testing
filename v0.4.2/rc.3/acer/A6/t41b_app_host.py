"""A-6 on the Acer: Part 4.1's host and app tools (host_control, app_display, use_app), 5.3's 64-million-cell world
on the host, and the app with its window minimised or covered (the Mac's #87: does the app go on behind a hidden
window on Windows?). Phases run one at a time with Jimmie; the host and the app run with mcpc's $W folders.

  python t41b_app_host.py host        host_control on the test host (started first: `jetcarp host start`, $W folders)
  python t41b_app_host.py big         5.3: a rotation of one 8000 x 8000 Life scene (64,000,000 cells) on the host;
                                      host status and the host process's memory every 5 s; then back, and quit
  python t41b_app_host.py app         use_app attach=true, app_display, and world tools on the app's world (AI control on)
  python t41b_app_host.py hidden      `jetcarp mcp --app`: a running world, world_status every 2 s for 180 s while Jimmie
                                      leaves the app in view, minimises it, restores it and covers it; each poll logs the
                                      answer time, the generation, whether the window is minimised, which program is in
                                      front, and the app's CPU
  python t41b_app_host.py standalone  with the app minimised: a standalone MCP server's detached hunt, followed by
                                      `jobs status` (another process), then stopped
"""
import ctypes
import ctypes.wintypes as wt
import json
import os
import re
import subprocess
import sys
import time

import mcpc

phase = sys.argv[1]
W = mcpc.W
out = open(os.path.join(mcpc.R, f"4.1b-{phase}.txt"), "w", encoding="utf-8")
u32 = ctypes.windll.user32
k32 = ctypes.windll.kernel32


def say(s):
    s = s.replace(W, "$W").replace(W.replace("\\", "\\\\"), "$W")
    print(s, flush=True)
    out.write(s + "\n")
    out.flush()


def call(m, name, args, timeout=120, cut=700):
    t0 = time.time()
    err, txt, _ = m.call(name, args, timeout)
    say(f"== {name} {json.dumps(args)[:200]}  ->  isError={err}  ({time.time() - t0:.1f} s)  [{time.strftime('%H:%M:%S')}]\n   {txt[:cut]}")
    return err, txt


def cli(*args, timeout=60, cut=900):
    p = subprocess.run([mcpc.J, *args], env=mcpc.env(), capture_output=True, text=True, encoding="utf-8",
                       errors="replace", timeout=timeout, cwd=os.path.join(W, "cwd"))
    say(f"$ jetcarp {' '.join(args)}   [{time.strftime('%H:%M:%S')}]\n{p.stdout.rstrip()[:cut]}\n{p.stderr.rstrip()[:400]}\nexit {p.returncode}")
    return p


def pids_named(*names):
    ps = ("Get-CimInstance Win32_Process | Where-Object { @('" + "','".join(names) + "') -contains $_.Name } | "
          "ForEach-Object { \"$($_.ProcessId)|$($_.Name)|$($_.CommandLine)\" }")
    p = subprocess.run(["powershell", "-NoProfile", "-Command", ps], capture_output=True, text=True)
    rows = []
    for line in p.stdout.splitlines():
        parts = line.split("|", 2)
        if len(parts) == 3:
            rows.append((int(parts[0]), parts[1], parts[2]))
    return rows


class PMC(ctypes.Structure):
    _fields_ = [("cb", wt.DWORD), ("PageFaultCount", wt.DWORD), ("PeakWorkingSetSize", ctypes.c_size_t),
                ("WorkingSetSize", ctypes.c_size_t), ("QuotaPeakPagedPoolUsage", ctypes.c_size_t),
                ("QuotaPagedPoolUsage", ctypes.c_size_t), ("QuotaPeakNonPagedPoolUsage", ctypes.c_size_t),
                ("QuotaNonPagedPoolUsage", ctypes.c_size_t), ("PagefileUsage", ctypes.c_size_t),
                ("PeakPagefileUsage", ctypes.c_size_t), ("PrivateUsage", ctypes.c_size_t)]


def proc_handle(pid):
    return k32.OpenProcess(0x1000 | 0x0400 | 0x0010, False, pid)  # query limited + query + vm read


def proc_mem(h):
    c = PMC()
    c.cb = ctypes.sizeof(PMC)
    k32.K32GetProcessMemoryInfo(h, ctypes.byref(c), c.cb)
    return c.WorkingSetSize, c.PrivateUsage


def proc_cpu_s(h):
    a, b, kt, ut = wt.FILETIME(), wt.FILETIME(), wt.FILETIME(), wt.FILETIME()
    k32.GetProcessTimes(h, ctypes.byref(a), ctypes.byref(b), ctypes.byref(kt), ctypes.byref(ut))
    f = lambda t: ((t.dwHighDateTime << 32) | t.dwLowDateTime) / 1e7
    return f(kt) + f(ut)


def windows_of(pid):
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
    return found


def front_pid():
    p = wt.DWORD()
    u32.GetWindowThreadProcessId(u32.GetForegroundWindow(), ctypes.byref(p))
    return p.value


def app_process():
    """The app: a jetcarp.exe or jetcarpw.exe with a visible window, not a host, MCP server or job."""
    for pid, name, cmd in pids_named("jetcarp.exe", "jetcarpw.exe"):
        if any(w in cmd for w in (" host ", " mcp", " jobs ", " search ")):
            continue
        wins = windows_of(pid)
        if wins:
            return pid, wins[0][0], wins[0][1]
    return None, None, None


if phase == "host":
    m = mcpc.Mcp(os.path.join(mcpc.R, "4.1b-host.jsonl"))
    m.init()
    for args in ({}, {"action": "status"}, {"action": "next"}, {"action": "pause"}, {"action": "status"},
                 {"action": "resume"}, {"action": "rotation", "name": "Until it settles"}, {"action": "scene"},
                 {"action": "previous"}, {"action": "reload"}, {"action": "rotation"}, {"action": "bogus"},
                 {"action": "status"}):
        call(m, "host_control", args)
        time.sleep(1.5)
    m.close()

elif phase == "big":
    big = os.path.join(W, "big")
    os.makedirs(big, exist_ok=True)
    scene = {"format": 1, "name": "64M Life", "tiling": {"family": "square", "size": {"rect": {"w": 8000, "h": 8000}}, "boundary": "wrap"},
             "rng_state": 11, "cas": [{"id": 1, "name": "Life", "rule": "B3/S23", "seed": {"random": {"density": 0.3}}}]}
    json.dump(scene, open(os.path.join(big, "life-64m.json"), "w"), indent=1)
    rot_dir = os.path.join(W, "config", "rotations")
    os.makedirs(rot_dir, exist_ok=True)
    rot = {"name": "Big 64M", "description": "A-6 5.3: one 8000 x 8000 Life scene", "order": "in_order", "default_minutes": None,
           "look": {"refill": False},
           "items": [{"source": {"kind": "scene", "path": os.path.join(big, "life-64m.json")}}]}
    json.dump(rot, open(os.path.join(rot_dir, "big-64m.json"), "w"), indent=1)
    say(f"rotation file $W\\config\\rotations\\big-64m.json -> scene $W\\big\\life-64m.json (8000 x 8000 = 64,000,000 cells, refill off)")
    hosts = [r for r in pids_named("jetcarp.exe", "jetcarpw.exe") if " host serve" in r[2]]
    say(f"host processes: {[(p, n) for p, n, _ in hosts]}")
    h = proc_handle(hosts[0][0]) if hosts else None
    cli("host", "status")
    if h:
        ws, pv = proc_mem(h)
        say(f"before: host working set {ws / 2**20:.0f} MB, private {pv / 2**20:.0f} MB, CPU {proc_cpu_s(h):.1f} s")
    m = mcpc.Mcp(os.path.join(mcpc.R, "4.1b-big.jsonl"))
    m.init()
    call(m, "host_control", {"action": "rotation", "name": "Big 64M"}, cut=1500)
    t0 = time.time()
    last_cpu = proc_cpu_s(h) if h else 0
    while time.time() - t0 < 90:
        time.sleep(5)
        p = subprocess.run([mcpc.J, "host", "status", "--json"], env=mcpc.env(), capture_output=True, text=True,
                           encoding="utf-8", errors="replace", timeout=30)
        gens = re.findall(r'"generation":\s*(\d+)', p.stdout)
        cells = re.findall(r'"cells":\s*(\d+)', p.stdout)
        rss = re.findall(r'"(?:rss_mb|memory_mb|rss_bytes|memory_bytes)":\s*([\d.]+)', p.stdout)
        line = f"+{time.time() - t0:4.0f} s: generation {gens[:1]}, cells {cells[:1]}, status memory {rss[:2]}"
        if h:
            ws, pv = proc_mem(h)
            c = proc_cpu_s(h)
            line += f"; host working set {ws / 2**20:.0f} MB, private {pv / 2**20:.0f} MB, CPU {100 * (c - last_cpu) / 5 / os.cpu_count():.0f}% of the machine"
            last_cpu = c
        say(line)
    cli("host", "status", cut=2500)
    p = cli("host", "status", "--json", cut=200)
    open(os.path.join(mcpc.R, "4.1b-big-status.json"), "w", encoding="utf-8").write(p.stdout.replace(W.replace("\\", "\\\\"), "$W"))
    call(m, "host_control", {"action": "scene"}, cut=600)
    call(m, "host_control", {"action": "rotation", "name": "A classic a day"})
    time.sleep(5)
    if h:
        ws, pv = proc_mem(h)
        say(f"5 s after switching back: host working set {ws / 2**20:.0f} MB, private {pv / 2**20:.0f} MB")
    call(m, "host_control", {"action": "quit"})
    m.close()
    time.sleep(3)
    say(f"host processes after quit: {[(p, n) for p, n, c in pids_named('jetcarp.exe', 'jetcarpw.exe') if ' host serve' in c]}")

elif phase == "app":
    m = mcpc.Mcp(os.path.join(mcpc.R, "4.1b-app.jsonl"))
    m.init()
    call(m, "app_display", {})  # before attaching: is it offered?
    call(m, "use_app", {"attach": True})
    call(m, "app_display", {})
    call(m, "world_new", {"tiling": "square", "width": 128, "height": 96, "cas": ["Life"]})
    call(m, "world_step", {"generations": 50})
    call(m, "world_status", {})
    call(m, "app_display", {"playing": True, "speed": 30})
    time.sleep(4)
    call(m, "world_status", {})
    call(m, "app_display", {"playing": False})
    call(m, "world_render", {"max_side": 256, "save_path": "a6/app-world.png"})
    call(m, "use_app", {"attach": False})
    call(m, "world_status", {})  # the private world again
    m.close()

elif phase == "hidden":
    secs = int(sys.argv[2]) if len(sys.argv) > 2 else 180
    pid, hwnd, title = app_process()
    say(f"the app: pid {pid}, window '{title}'")
    h = proc_handle(pid) if pid else None
    m = mcpc.Mcp(os.path.join(mcpc.R, "4.1b-hidden-poll.jsonl"), args=["--app"], maxlog=1200)
    m.init()
    call(m, "world_new", {"tiling": "square", "width": 512, "height": 512, "cas": [{"rule": "Life", "seed": "random:0.3"}]}, cut=300)
    call(m, "app_display", {"playing": True, "speed": 30}, cut=300)
    rows = []
    t0 = time.time()
    last_t, last_g, last_c = None, None, proc_cpu_s(h) if h else 0
    say("   t(s)  answer(s)  generation  gens/s  minimised  in-front  app-CPU(% of a core)")
    while time.time() - t0 < secs:
        ts = time.time()
        err, txt, _ = m.call("world_status", {}, timeout=30)
        ans = time.time() - ts
        g = re.search(r'"generation":\s*(\d+)', txt or "")
        g = int(g.group(1)) if g else None
        now = time.time()
        rate = (g - last_g) / (now - last_t) if (g is not None and last_g is not None) else None
        icon = bool(u32.IsIconic(hwnd)) if hwnd else None
        front = (front_pid() == pid) if pid else None
        c = proc_cpu_s(h) if h else 0
        cpu = 100 * (c - last_c) / (now - last_t) if last_t else None
        last_t, last_g, last_c = now, g, c
        rows.append({"t": round(now - t0, 1), "answer_s": round(ans, 2), "generation": g, "gens_per_s": rate,
                     "minimised": icon, "in_front": front, "cpu_pct_core": cpu, "error": err})
        say(f"  {now - t0:5.1f}  {ans:8.2f}  {str(g):>10}  {('%.1f' % rate) if rate is not None else '-':>6}  "
            f"{str(icon):>9}  {str(front):>8}  {('%.0f' % cpu) if cpu is not None else '-':>6}" + (f"  error {txt[:80]}" if err else ""))
        time.sleep(max(0, 2 - (time.time() - ts)))
    call(m, "app_display", {"playing": False}, cut=200)
    m.close()
    json.dump(rows, open(os.path.join(mcpc.R, "4.1b-hidden-poll.json"), "w"), indent=0)

elif phase == "standalone":
    pid, hwnd, title = app_process()
    say(f"#### the app: pid {pid}, minimised: {bool(u32.IsIconic(hwnd)) if hwnd else None}  [{time.strftime('%H:%M:%S')}]")
    s = mcpc.Mcp(os.path.join(mcpc.R, "4.1b-standalone.jsonl"))
    s.init()
    err, txt = call(s, "search_start", {"hunt": {"rules": ["B3/S23"], "soups": 2000000}, "detach": True, "threads": 8, "label": "a6-hidden"})
    s.close()
    say(f"(the standalone server closed  [{time.strftime('%H:%M:%S')}])")
    mm = re.search(r"job (\d+)", txt) or re.search(r'"job":\s*(\d+)', txt)
    job = mm.group(1) if mm else None
    for _ in range(4):
        time.sleep(15)
        cli("jobs", "status", job) if job else say("no job id")
    say(f"(the app still minimised: {bool(u32.IsIconic(hwnd)) if hwnd else None})")
    if job:
        cli("jobs", "stop", job)
        cli("jobs", "wait", job, "--timeout", "60")
out.close()
