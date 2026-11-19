"""F9 5.3b: MCP world_new with width and height whose product passes the 4,000,000-cell limit."""
import json, re, mcpc
out = open(f"{mcpc.R}/5.3b-mcp-over-limit.txt", "w")
m = mcpc.Mcp(f"{mcpc.R}/5.3b-mcp-over-limit.jsonl", maxlog=1500)
m.init()
for name, args in [
    ("world_new", {"tiling": "square", "width": 4096, "height": 4096, "cas": ["Life"]}),
    ("world_step", {"generations": 100}),
    ("world_render", {"max_side": 256}),
    ("world_new", {"tiling": "trihex", "width": 4096, "height": 4096, "cas": ["Life"]}),
    ("world_step", {"generations": 10}),
    ("world_status", {}),
]:
    err, txt, _ = m.call(name, args, timeout=300)
    cells = re.findall(r'"cells": (\d+)', txt)
    s = f"== {name} {json.dumps(args)} -> isError={err}; cells {cells[:1]}\n   " + "\n   ".join(l for l in txt[:700].split("\n") if not l.strip().startswith(('"', '{', '}', '[', ']')) and l.strip())
    print(s); out.write(s + "\n")
m.close(); out.close()
