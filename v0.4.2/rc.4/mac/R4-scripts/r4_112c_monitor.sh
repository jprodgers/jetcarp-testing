#!/bin/bash
# R4 #112: a monitor change starts no fit. The default host (launchd's), every second: its screen line, any status
# field about Fit or tuning, and host.json's hash; a line when something changes. Jimmie changes the built-in
# display's resolution and back. Ends on the stop file.
OUT="$1"; STOP="$1.stop"; HJ="$HOME/Library/Application Support/jetcarp/host.json"; prev=""
{ echo "# R4 #112 monitor change, the default host, every second; started $(date +%T)"
  echo "# display before: $(system_profiler SPDisplaysDataType 2>/dev/null | grep -E 'Resolution|UI Looks like' | sed 's/^ *//' | tr '\n' ' ')"
  echo "# host.json before: $(shasum -a 256 "$HJ" | cut -c1-16); keys: $(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sorted(d), [sorted(s) for s in d.get("screens", [])])' "$HJ")"; } > "$OUT"
while [ ! -e "$STOP" ]; do
  st=$(jetcarp host status --json 2>/dev/null | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print("no status"); sys.exit()
fit = sorted({k for k in json.dumps(d).replace("\"", " ").split() if any(w in k.lower() for w in ("tun", "fit", "sweep"))})
out = []
for s in d.get("screens", []):
    g = s.get("stage") or {}
    out.append("screen %s monitor %s canvas %s cells %s of %.2f px, %s" % (s.get("index", "?"), s.get("monitor"), g.get("canvas"), g.get("cells"), g.get("cell_px") or 0, g.get("label")))
lg = d.get("log") or []
last = lg[-1] if isinstance(lg, list) and lg else lg
print(" | ".join(out), "| pid", d.get("pid"), "| monitors", d.get("monitors"), "| fit/tune words:", fit or "none", "| held:", d.get("held"), d.get("held_why") or "", "| last log:", json.dumps(last)[:200])
' 2>/dev/null)
  h=$(shasum -a 256 "$HJ" 2>/dev/null | cut -c1-16)
  line="$st | host.json $h"
  [ "$line" != "$prev" ] && echo "$(date +%T) $line" >> "$OUT" && prev="$line"
  sleep 1
done
{ echo "# display after: $(system_profiler SPDisplaysDataType 2>/dev/null | grep -E 'Resolution|UI Looks like' | sed 's/^ *//' | tr '\n' ' ')"
  echo "# host.json after: $(shasum -a 256 "$HJ" | cut -c1-16)"; echo "# ended $(date +%T)"; } >> "$OUT"; rm -f "$STOP"
