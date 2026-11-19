#!/bin/bash
# 2.D 6 (the Acer's gpuwatch.ps1 for the Mac): when the desktop background's own GPU choice (host.json "gpu") or the
# shared setting (gpu.json) changes, wait 4 s, then log host status's screen line, doctor's lines for the app and the
# desktop background, the host's CPU and the GPU's utilisation. Until $T/gpuwatch.stop appears. Output: $R/2.D-6-gpu.txt
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
O="$R/2.D-6-gpu.txt"; STOP="$T/gpuwatch.stop"; rm -f "$STOP"; prev=""
state() { echo "host.json gpu=$(python3 -c 'import json; print(json.load(open("'$T'/config/host.json")).get("gpu"))' 2>/dev/null) | gpu.json=$(tr -d ' \n' < "$T/config/gpu.json" 2>/dev/null)"; }
log() {
    sleep 4
    { echo "== $(date -u +%T) $(state)"
      "$J" host status 2>&1 | grep -E '^screen|^note'
      "$J" doctor 2>&1 | grep -E '^GPU:|the app:|the desktop background:'
      hp=$("$J" host status --json 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["pid"])' 2>/dev/null)
      c=""; for k in 1 2 3; do c="$c $(ps -o %cpu= -p "$hp" | tr -d ' ')"; sleep 1; done
      echo "host cpu:$c% | gpu $(ioreg -r -d 1 -w 0 -c IOAccelerator | grep -oE '"Device Utilization %"=[0-9]+' | head -1 | cut -d= -f2)%"
    } >> "$O"
}
: > "$O"; prev=$(state); echo "start: $prev" >> "$O"; log
while [ ! -e "$STOP" ]; do
    s=$(state); if [ "$s" != "$prev" ]; then prev=$s; log; fi
    sleep 2
done
