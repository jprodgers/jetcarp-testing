"""rc.4 wave on the Acer, the sitting with Jimmie: one call to the open app through `jetcarp mcp --app`
(AI control on in the app), in the sitting's folder ~\\jetcarp-rc4\\s1. Each call is appended to
s1-mcp.txt; the whole exchange to s1-mcp-<n>.jsonl.

  python -X utf8 -B s1_mcp.py "<label>" <tool> '<json arguments>'
  python -X utf8 -B s1_mcp.py "<label>" tools        (lists the tools)
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "v0.4.2-rc.3", "acer", "A6"))
import mcpc  # noqa: E402

HOME = os.path.expanduser("~")
mcpc.W = os.path.join(HOME, "jetcarp-rc4", "s1")
mcpc.J = os.path.join(HOME, "jetcarp-rc-042c", "bin", "jetcarp.exe")
mcpc.R = HERE

label, tool = sys.argv[1], sys.argv[2]
args = json.loads(sys.argv[3]) if len(sys.argv) > 3 else {}
n = 1
while os.path.exists(os.path.join(HERE, f"s1-mcp-{n}.jsonl")):
    n += 1
m = mcpc.Mcp(os.path.join(HERE, f"s1-mcp-{n}.jsonl"), args=("--app",), maxlog=6000)
m.init()
if tool == "tools":
    r = m.request("tools/list")
    txt = ", ".join(t["name"] for t in r.get("result", {}).get("tools", []))
    err = False
else:
    err, txt, _ = m.call(tool, args, timeout=120)
m.close()
line = f"== {time.strftime('%H:%M:%S')} {label}: {tool} {json.dumps(args)} -> isError={err} (s1-mcp-{n}.jsonl)\n{txt}"
line = line.replace(HOME, "~").replace(HOME.replace("\\", "\\\\"), "~")
with open(os.path.join(HERE, "s1-mcp.txt"), "a", encoding="utf-8") as f:
    f.write(line + "\n")
print(line)
