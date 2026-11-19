"""F9 5.3 (MCP): the MCP tools' own limit of 4,000,000 cells and 2 billion cell updates per world_step."""
import json, mcpc
out = open(f"{mcpc.R}/5.3-mcp-limits.txt", "w")
m = mcpc.Mcp(f"{mcpc.R}/5.3-mcp-limits.jsonl", maxlog=1500)
m.init()
for name, args in [
    ("world_new", {"tiling": "square", "width": 2000, "height": 2000, "cas": ["Life"]}),
    ("world_step", {"generations": 500}),
    ("world_step", {"generations": 501}),
    ("world_new", {"tiling": "square", "width": 1545, "height": 2589, "cas": ["Life"]}),
    ("world_new", {"tiling": "square", "cells": 4000000, "cas": ["Life"]}),
    ("world_new", {"tiling": "square", "cells": 4000001, "cas": ["Life"]}),
    ("world_new", {"tiling": "trihex", "width": 1200, "height": 1200, "cas": ["Life"]}),
    ("run_script", {"script": 'let w = world(#{ tiling: "square", size: [1545, 2589] }); print(w.cells());'}),
    ("run_script", {"script": 'let w = world(#{ tiling: "square", size: [2000, 2000] }); w.add_ca("Life", #{ seed: "random:0.3" }); w.step(20); print(`${w.cells()} cells, hash ${w.hash()}`);', "max_seconds": 60}),
]:
    err, txt, _ = m.call(name, args, timeout=200)
    s = f"== {name} {json.dumps(args)} -> isError={err}\n   " + "\n   ".join(l for l in txt[:900].split("\n") if not l.strip().startswith(('"', '{', '}', '[', ']')))
    print(s); out.write(s + "\n")
m.close(); out.close()
