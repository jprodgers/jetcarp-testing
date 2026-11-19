"""F9 4.3b: follow-ups to 4.3: numbers as text (forgiven), out-of-range cells on a dead-edge world."""
import json, mcpc
out = open(f"{mcpc.R}/4.3b-followups.txt", "w")
m = mcpc.Mcp(f"{mcpc.R}/4.3b-followups.jsonl", maxlog=1500)
m.init()
for name, args in [
    ("world_new", {"tiling": "square", "width": "40", "height": "20", "boundary": "dead", "cas": [{"rule": "Life", "seed": "empty"}]}),
    ("world_edit", {"cells": {"cells": [[1000, 1000]]}}),
    ("world_edit", {"cells": {"cells": [[-1, -1]]}}),
    ("world_edit", {"cells": {"pattern": "OOO", "x": 39, "y": 19}}),
    ("world_read", {"format": "list"}),
    ("world_read", {"cell": {"x": 1000, "y": 1000}}),
    ("world_read", {"cell": {"x": -5, "y": 3}}),
    ("world_read", {"cell": {"index": 99999}}),
    ("world_read", {"x": 500, "y": 500, "width": 10, "height": 10}),
    ("world_step", {"generations": "5"}),
    ("world_status", {"scene": "true"}),
]:
    err, txt, _ = m.call(name, args)
    s = f"== {name} {json.dumps(args)} -> isError={err}\n   " + txt[:500].replace("\n", "\n   ")
    print(s); out.write(s + "\n")
m.close(); out.close()
