"""F9 5.2: two programs on one library at once (the app part skipped).

A CLI explore (`jetcarp search explore`, its own process) and an MCP search (a hunt on the MCP
server's own thread) on the same library at the same time; `jobs list` from each; then each job is
stopped from the other process: the CLI explore by MCP job_stop, the MCP hunt by `jetcarp jobs stop`.
"""
import json
import re
import subprocess
import time

import mcpc

out = open(f"{mcpc.R}/5.2-two-programs.txt", "w", encoding="utf-8")


def say(s):
    print(s)
    out.write(s.replace(mcpc.W, "$W") + "\n")
    out.flush()


def cli(*args, timeout=60):
    p = subprocess.run([mcpc.J, *args], env=mcpc.env(), capture_output=True, text=True, timeout=timeout)
    say(f"$ jetcarp {' '.join(args)}   [{time.strftime('%H:%M:%S')}]\n{p.stdout.rstrip()}\n{p.stderr.rstrip()}\nexit {p.returncode}")
    return p


# 1. The CLI explore, in its own process
exp_log = open(f"{mcpc.R}/5.2-cli-explore.log", "w")
exp = subprocess.Popen(
    [mcpc.J, "search", "explore", "--tilings", "square,hex", "--families", "life_like,generations", "--minutes", "4", "--threads", "8", "--gpu", "--label", "f9-5.2-cli"],
    env=mcpc.env(), stdout=exp_log, stderr=subprocess.STDOUT,
)
say(f"started CLI explore, pid {exp.pid}  [{time.strftime('%H:%M:%S')}]")
time.sleep(8)

# 2. The MCP search, on the server's thread
m = mcpc.Mcp(f"{mcpc.R}/5.2-mcp.jsonl", maxlog=2500)
m.init()
err, txt, _ = m.call("search_start", {"hunt": {"rules": ["B36/S23", "B3/S23"], "soups": 20000000}, "threads": 8, "label": "f9-5.2-mcp"})
say(f"== MCP search_start hunt (server thread) -> isError={err}\n{txt}")
mcp_job = int(re.search(r'"job":\s*(\d+)', txt).group(1))
time.sleep(5)

# 3. jobs list from each
p = cli("jobs", "list", "--status", "running") if False else cli("jobs", "list")
err, txt, _ = m.call("job_status", {"status": "running"})
say(f"== MCP job_status {{status: running}} -> isError={err}\n{txt}")
cli_job = None
for j in json.loads(txt).get("jobs", []):
    if j.get("label") == "f9-5.2-cli":
        cli_job = j["job"]
say(f"(the CLI explore is job {cli_job}, the MCP hunt job {mcp_job})")
time.sleep(10)

# 4. Stop each from the other process
err, txt, _ = m.call("job_stop", {"job": cli_job})
say(f"== MCP job_stop {cli_job} (the CLI's explore) -> isError={err}\n{txt}")
cli("jobs", "stop", str(mcp_job))
t0 = time.time()
try:
    rc = exp.wait(120)
    say(f"CLI explore process exited {rc} {time.time() - t0:.1f} s after MCP's job_stop")
except subprocess.TimeoutExpired:
    say("CLI explore process still running 120 s after MCP's job_stop; killed")
    exp.kill()
err, txt, _ = m.call("job_status", {"job": mcp_job, "wait_s": 60}, timeout=90)
say(f"== MCP job_status {mcp_job} wait_s 60 (after the CLI's jobs stop) -> isError={err}\n{txt[:700]}")
cli("jobs", "list")
err, txt, _ = m.call("job_status", {"limit": 3})
say(f"== MCP job_status listing -> {txt[:1500]}")
m.close()
exp_log.close()
say("== the CLI explore's own output (last lines):\n" + "".join(open(f"{mcpc.R}/5.2-cli-explore.log").readlines()[-12:]))
cli("jobs", "list")
out.close()
