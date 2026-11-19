#!/usr/bin/env python3
"""Poll the app's world over one `jetcarp mcp --app` connection (the Acer's mcppoll.ps1, for the Mac).

world_status every EVERY seconds, one log line each: time, generation, gens/s since the last poll, cells, playing,
tiling, rules, population, scene, and the app's RSS and footprint. Stops after SECONDS, or when STOPFILE appears.
The first reply is also saved whole (OUT + ".first.json"), to see what world_status carries.

Usage: python3 mcppoll.py <jetcarp> <out.txt> <app pid> [seconds=900] [every=5] [stopfile]
(JETCARP_* set as in env2.sh; the app's AI control must be on.)
"""
import json, os, re, subprocess, sys, time

J, OUT, PID = sys.argv[1], sys.argv[2], sys.argv[3]
SECONDS = float(sys.argv[4]) if len(sys.argv) > 4 else 900
EVERY = float(sys.argv[5]) if len(sys.argv) > 5 else 5
STOP = sys.argv[6] if len(sys.argv) > 6 else OUT + ".stop"

p = subprocess.Popen([J, "mcp", "--app"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                     text=True, bufsize=1)


def log(s):
    with open(OUT, "a") as f:
        f.write(time.strftime("%H:%M:%S ") + s + "\n")


def send(obj):
    p.stdin.write(json.dumps(obj) + "\n")
    p.stdin.flush()


def recv(i):
    while True:
        line = p.stdout.readline()
        if not line:
            return None
        try:
            m = json.loads(line)
        except ValueError:
            continue
        if m.get("id") == i:
            return m


def mem():
    try:
        rss = int(subprocess.run(["ps", "-o", "rss=", "-p", PID], capture_output=True, text=True).stdout.strip()) // 1024
    except ValueError:
        return "app gone"
    fp = subprocess.run(["footprint", "-f", "bytes", "--noCategories", PID], capture_output=True, text=True).stdout
    m = re.search(r"phys_footprint:\s+(\d+) B", fp)
    return f"rss {rss} MB footprint {int(m.group(1)) // 2**20 if m else '?'} MB"


send({"jsonrpc": "2.0", "id": 1, "method": "initialize",
      "params": {"protocolVersion": "2025-06-18", "capabilities": {}, "clientInfo": {"name": "rc3-mac-poll", "version": "1"}}})
init = recv(1)
si = (init or {}).get("result", {}).get("serverInfo", {})
log(f"start: server {si.get('name')} {si.get('version')}; every {EVERY} s for {SECONDS} s")
send({"jsonrpc": "2.0", "method": "notifications/initialized"})
end = time.time() + SECONDS
i = 10
prev = None
first = True
while time.time() < end and not os.path.exists(STOP) and p.poll() is None:
    i += 1
    t0 = time.time()
    send({"jsonrpc": "2.0", "id": i, "method": "tools/call", "params": {"name": "world_status", "arguments": {}}})
    r = recv(i)
    if not r:
        log("no reply")
        break
    try:
        txt = r["result"]["content"][0]["text"]
        w = json.loads(txt)
        if first:
            open(OUT + ".first.json", "w").write(json.dumps(w, indent=2))
            first = False
        gen = int(w.get("generation", 0))
        rate = f"{(gen - prev[0]) / (t0 - prev[1]):.1f}" if prev and gen >= prev[0] else "-"
        prev = (gen, t0)
        pop = sum(f.get("population", 0) for f in w.get("fields", []) or [])
        rules = " + ".join(str(c.get("rule")) for c in w.get("cas", []) or [])
        host = w.get("host", {}) or {}
        tiling = (w.get("tiling") or {}).get("id")
        log(f"gen {gen} rate {rate}/s cells {w.get('cells')} playing {host.get('playing')} tiling {tiling} "
            f"rules '{rules}' pop {pop} scene '{host.get('scene_name')}' sim '{host.get('simulation', host.get('sim', ''))}' {mem()}")
    except Exception as e:  # keep polling
        log(f"parse error: {e!r}: {str(r)[:300]}")
    wait = EVERY - (time.time() - t0)
    if wait > 0:
        time.sleep(wait)
p.stdin.close()
try:
    p.wait(10)
except subprocess.TimeoutExpired:
    p.kill()
log(f"end; mcp exit {p.returncode}; stderr: {p.stderr.read().strip()[:500]}")
