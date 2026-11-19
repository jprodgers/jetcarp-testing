"""F9 4.4: searches started through MCP that keep running after the MCP process ends.

A hunt with detach: true, and an explore search with no detach (explore detaches by default where it
can). The MCP server is closed, then `jetcarp jobs status` (a separate process) follows them; then
one is stopped from a new MCP session and the other from the command line.
"""
import json
import re
import subprocess
import time

import mcpc

out = open(f"{mcpc.R}/4.4-long-job.txt", "w", encoding="utf-8")


def say(s):
    print(s)
    out.write(s + "\n")
    out.flush()


def cli(*args, timeout=60):
    p = subprocess.run([mcpc.J, *args], env=mcpc.env(), capture_output=True, text=True, timeout=timeout)
    say(f"$ jetcarp {' '.join(args)}\n{p.stdout.rstrip()}\n{p.stderr.rstrip()}\nexit {p.returncode}")
    return p


def job_of(txt):
    m = re.search(r'"job":\s*(\d+)', txt) or re.search(r"job (\d+)", txt)
    return int(m.group(1)) if m else None


m = mcpc.Mcp(f"{mcpc.R}/4.4-long-job-a.jsonl")
m.init()
err, txt, _ = m.call("search_start", {"hunt": {"rules": ["B3/S23"], "soups": 50000000}, "detach": True, "threads": 8, "label": "f9-detached-hunt"})
say(f"== search_start hunt detach=true -> isError={err}\n{txt}")
hunt = job_of(txt)
err, txt, _ = m.call("search_start", {"explore": {"tilings": "hex", "families": "life_like"}, "budget": {"minutes": 4}, "threads": 16, "label": "f9-detached-explore"})
say(f"== search_start explore (no detach given) -> isError={err}\n{txt}")
explore = job_of(txt)
time.sleep(3)
err, txt, _ = m.call("job_status", {"job": hunt})
say(f"== job_status {hunt} (inside the session) -> {txt[:600]}")
t0 = time.time()
rc = m.close()
say(f"== MCP server closed at {time.strftime('%H:%M:%S')}: exit {rc}, stderr: {m.stderr}")

time.sleep(5)
cli("jobs", "list")
cli("jobs", "status", str(hunt))
cli("jobs", "status", str(explore))
ps = subprocess.run(["pgrep", "-af", "jetcarp jobs resume"], capture_output=True, text=True)
say(f"$ pgrep -af 'jetcarp jobs resume'\n{ps.stdout.rstrip()}")
time.sleep(20)
say(f"== 25 s after the MCP server exited:")
cli("jobs", "status", str(hunt))
cli("jobs", "status", str(explore))

# Stop the hunt from a new MCP session, the explore from the command line
m = mcpc.Mcp(f"{mcpc.R}/4.4-long-job-b.jsonl")
m.init()
err, txt, _ = m.call("job_stop", {"job": hunt})
say(f"== new MCP session: job_stop {hunt} -> isError={err}\n{txt}")
err, txt, _ = m.call("job_status", {"job": hunt, "wait_s": 60}, timeout=90)
say(f"== job_status {hunt} wait_s 60 -> isError={err}\n{txt[:800]}")
m.close()
cli("jobs", "stop", str(explore))
cli("jobs", "wait", str(explore), "--timeout", "90", timeout=120)
cli("jobs", "list")
ps = subprocess.run(["pgrep", "-af", "jetcarp jobs resume"], capture_output=True, text=True)
say(f"$ pgrep -af 'jetcarp jobs resume'\n{ps.stdout.rstrip()}")
out.close()
