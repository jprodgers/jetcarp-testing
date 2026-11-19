"""M-6 on the Mac: Part 4.1's three tools the Framework skipped (host_control, app_display, use_app), and the app-hidden
checks, in phases run one at a time with Jimmie (the host and the app both run with mcpc's $W folders).

  python3 t41b_app_host.py host     host_control on the test host (it must be running: `jetcarp host start` with env.sh)
  python3 t41b_app_host.py app      use_app attach=true, app_display, and world tools on the app's world (AI control on)
  python3 t41b_app_host.py hidden   with the app minimised: an app-world call (rc.3 waits: #87) and a standalone
                                    MCP search that keeps going (jobs status from the command line follows it)
"""
import json
import subprocess
import sys
import time

import mcpc

phase = sys.argv[1]
out = open(f"{mcpc.R}/4.1b-{phase}.txt", "w", encoding="utf-8")


def say(s):
    s = s.replace(mcpc.W, "$W")
    print(s)
    out.write(s + "\n")
    out.flush()


def call(m, name, args, timeout=120, cut=700):
    t0 = time.time()
    err, txt, _ = m.call(name, args, timeout)
    say(f"== {name} {json.dumps(args)[:200]}  ->  isError={err}  ({time.time() - t0:.1f} s)\n   {txt[:cut]}")
    return err, txt


def cli(*args, timeout=60):
    p = subprocess.run([mcpc.J, *args], env=mcpc.env(), capture_output=True, text=True, timeout=timeout)
    say(f"$ jetcarp {' '.join(args)}   [{time.strftime('%H:%M:%S')}]\n{p.stdout.rstrip()[:900]}\n{p.stderr.rstrip()[:400]}\nexit {p.returncode}")
    return p


if phase == "host":
    m = mcpc.Mcp(f"{mcpc.R}/4.1b-host.jsonl")
    m.init()
    for args in ({}, {"action": "status"}, {"action": "next"}, {"action": "pause"}, {"action": "resume"},
                 {"action": "rotation", "name": "Until it settles"}, {"action": "scene"}, {"action": "rotation"},
                 {"action": "bogus"}):
        call(m, "host_control", args)
        time.sleep(1)
    m.close()

elif phase == "app":
    m = mcpc.Mcp(f"{mcpc.R}/4.1b-app.jsonl")
    m.init()
    call(m, "app_display", {})                       # before attaching: is it offered?
    call(m, "use_app", {"attach": True})
    call(m, "app_display", {})
    call(m, "world_new", {"tiling": "square", "width": 128, "height": 96, "cas": ["Life"]})
    call(m, "world_step", {"gens": 50})
    call(m, "world_status", {})
    call(m, "app_display", {"playing": True, "speed": 30})
    time.sleep(4)
    call(m, "world_status", {})
    call(m, "app_display", {"playing": False})
    call(m, "use_app", {"attach": False})
    call(m, "world_status", {})                      # the private world again
    m.close()

elif phase == "hidden":
    say(f"#### the app minimised by Jimmie before this ran  [{time.strftime('%H:%M:%S')}]")
    a = mcpc.Mcp(f"{mcpc.R}/4.1b-hidden-app.jsonl")
    a.init()
    call(a, "use_app", {"attach": True}, timeout=20)
    call(a, "world_status", {}, timeout=20)
    a.close()
    say("#### a standalone MCP server (its own world and jobs): a detached hunt, then the server closes")
    s = mcpc.Mcp(f"{mcpc.R}/4.1b-hidden-standalone.jsonl")
    s.init()
    err, txt = call(s, "search_start", {"hunt": {"rules": ["B3/S23"], "soups": 2000000}, "detach": True, "threads": 8,
                                         "label": "m6-hidden"})
    s.close()
    import re
    mm = re.search(r"job (\d+)", txt)
    job = mm.group(1) if mm else None
    for _ in range(4):
        time.sleep(15)
        cli("jobs", "status", job) if job else say("no job id")
    if job:
        cli("jobs", "stop", job)
        cli("jobs", "wait", job, "--timeout", "60")
