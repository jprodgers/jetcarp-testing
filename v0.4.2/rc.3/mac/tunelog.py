#!/usr/bin/env python3
"""One line from `jetcarp host status --json` on stdin: screen 0's item, cells and cell size, tuned, and the tuning state."""
import json, sys, time
d = json.load(sys.stdin)
s = (d.get("screens") or [{}])[0]
st = s.get("stage") or {}
tu = d.get("tuning") or {}
px = round(st.get("cell_px") or 0, 1)
print(time.strftime("%H:%M:%S"), f"{st.get('label')} {st.get('cells')}c@{px}px tuned {st.get('tuned')}",
      f"| tuning running {tu.get('running')} auto {tu.get('auto')} here {tu.get('here')} last {tu.get('last')}",
      f"| mem {d.get('memory_mb')} MB | log {d.get('log', [])[-1:]}")
