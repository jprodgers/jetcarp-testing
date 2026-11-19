#!/usr/bin/env bash
# R4 #112, a follow-up: rc.3's host.json has a screen 1 for the Q3277, not connected now. Is it stepped?
# The fit test folder's host on the desktop for 40 s: screen 1's generation, every 10 s, and the host's CPU.
set -u
D=$(cd "$(dirname "$0")" && pwd)
. "$D/lib.sh" fit
echo "R4 #112b the not-connected monitor's screen, the Mac, $(ts); test folder \$H = homes/fit (rc.3's host.json)"
run "\$J host start"
for i in 0 1 2 3 4; do
  sleep 10
  pid=$(pgrep -f "$J host serve" | head -1)
  echo "$(date +%T) +$(( (i + 1) * 10 ))s  cpu $(ps -o %cpu= -p $pid)%  $("$J" host status --json | python3 -c '
import json, sys
d = json.load(sys.stdin)
for s in d.get("screens", []):
    print("| screen", s.get("index", "?"), "gen", s.get("generation"), "monitor", s.get("monitor"), s.get("monitor_name", ""), "connected" if s.get("connected", True) else "NOT connected", "rate", s.get("measured_speed") or s.get("speed"), end=" ")
')"
done
run "\$J host status --json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(json.dumps(d[\"screens\"][1], indent=1)[:1800])'"
run "\$J host stop"
sleep 2
run hosts
