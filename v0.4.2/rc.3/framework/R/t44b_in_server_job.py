"""F9 4.4b: a search on the MCP server's own thread (no detach) when the server exits on end of input.
The book: "The job runs on a thread of this server, so it stops when the server exits (it stays resumable)"."""
import subprocess, time, mcpc
out = open(f"{mcpc.R}/4.4b-in-server-job.txt", "w")
def cli(*a):
    p = subprocess.run([mcpc.J, *a], env=mcpc.env(), capture_output=True, text=True, timeout=60)
    s = f"$ jetcarp {' '.join(a)}\n{p.stdout.rstrip()}\n{p.stderr.rstrip()}\nexit {p.returncode}"
    print(s); out.write(s + "\n")
m = mcpc.Mcp(f"{mcpc.R}/4.4b-in-server-job.jsonl")
m.init()
err, txt, _ = m.call("search_start", {"hunt": {"rules": ["B3/S23"], "soups": 50000000}, "threads": 8, "label": "f9-in-server"})
out.write(f"== search_start (no detach) -> {txt}\n")
import re; job = int(re.search(r'"job":\s*(\d+)', txt).group(1))
time.sleep(5)
t = time.strftime("%H:%M:%S")
rc = m.close()
out.write(f"== MCP stdin closed at {t}; server exit {rc}\n")
time.sleep(10)
cli("--json", "jobs", "status", str(job))
cli("jobs", "list")
cli("jobs", "wait", str(job), "--timeout", "5")
out.close()
