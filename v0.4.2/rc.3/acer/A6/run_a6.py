"""A-6 on the Acer (rc.3), the unattended part: Parts 4 and 5's MCP scripts and command-line steps, then R's
command-line rows. Everything under ~/jetcarp-rc-042c/a6 ($W). Each script's output goes to <name>.stdout, and
this runner's log to run_a6.log. (The parts with Jimmie are t41b_app_host.py and t52_two_programs.py.)

Order: a publisher key first (so the pack tools get past "no key" and their folder checks are reached), then
t41 (which makes jobs 1-3 that later scripts use), t5_prep (the odd files 4.2 reads), 4.2, 4.3, 4.4, 5.3, 5.5,
the command-line steps, 5.1 through MCP, and R's rows.
"""
import os
import subprocess
import sys
import time

import mcpc

R, W, J = mcpc.R, mcpc.W, mcpc.J
LOG = open(os.path.join(R, "run_a6.log"), "a", encoding="utf-8")


def log(s):
    line = f"{time.strftime('%H:%M:%S')} {s}"
    print(line, flush=True)
    LOG.write(line + "\n")
    LOG.flush()


def pre(name, args):
    p = subprocess.run([J, *args], env=mcpc.env(), cwd=os.path.join(W, "cwd"), capture_output=True, text=True,
                       encoding="utf-8", errors="replace", timeout=300)
    with open(os.path.join(R, name), "w", encoding="utf-8") as f:
        f.write(f"$ jetcarp {' '.join(args)}\n{p.stdout}{p.stderr}exit {p.returncode}\n".replace(W, "$W"))
    log(f"{name}: exit {p.returncode}")


def script(name, timeout=900):
    log(name)
    t0 = time.time()
    with open(os.path.join(R, name + ".stdout"), "w", encoding="utf-8") as f:
        try:
            p = subprocess.run([sys.executable, "-X", "utf8", "-B", os.path.join(R, name + ".py")], cwd=R, stdout=f,
                               stderr=subprocess.STDOUT, timeout=timeout)
            rc = p.returncode
        except subprocess.TimeoutExpired:
            rc = "timeout"
    log(f"  exit {rc} ({time.time() - t0:.0f} s)")


os.makedirs(os.path.join(W, "cwd"), exist_ok=True)
log(f"=== A-6 unattended part starts ({J.replace(W, '$W')})")
pre("0-version.txt", ["--version"])
pre("0-doctor.txt", ["doctor"])
pre("0-pack-key.txt", ["pack", "key", "--name", "rc.3 A-6 test publisher"])
for name, t in [("t41_every_tool", 1500), ("t5_prep", 300), ("t42_folders", 1500), ("t42b_symlink", 300),
                ("t43_bad_input", 1200), ("t43b_followups", 300), ("t44_long_job", 900), ("t44b_in_server_job", 300),
                ("t53_mcp_limits", 900), ("t53b_mcp_over", 600), ("t55_readonly", 600), ("t5_cli", 2400),
                ("t51_mcp_odd", 1200), ("r_cli", 1200)]:
    script(name, t)
left = mcpc.procs("jetcarp")
log("jetcarp processes left: " + (left if left else "none"))
log("=== done")
