#!/bin/bash
# 2.D's monitor (the Acer's dmon.ps1 for the Mac): every 5 s, one line: the host's state per screen (rotation, item,
# generation, cells and cell size, fps, speed, simulation, paused/held and why), its memory, the host process's CPU and
# RSS, the app's CPU, and the GPU's whole-device utilisation (ioreg; macOS has no per-process GPU share without sudo).
# Until $T/dmon.stop appears. Output: $R/2.D-monitor.txt
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
OUT="${DMON_OUT:-$R/2.D-monitor.txt}"; STOP="$T/dmon.stop"; rm -f "$STOP"
while [ ! -e "$STOP" ]; do
    "$J" host status --json > "$T/dmon.json" 2>/dev/null
    hp=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("pid",""))' "$T/dmon.json" 2>/dev/null)
    hc=""; hr=""; [ -n "$hp" ] && read -r hc hr <<< "$(ps -o %cpu=,rss= -p "$hp" 2>/dev/null)"
    ap=$(pgrep -fx "${APP:-$T/bin/jetcarp}" | head -1); ac=""; [ -n "$ap" ] && ac=$(ps -o %cpu= -p "$ap" | tr -d ' ')
    gpu=$(ioreg -r -d 1 -w 0 -c IOAccelerator | grep -oE '"Device Utilization %"=[0-9]+' | head -1 | cut -d= -f2)
    line=$(python3 - "$T/dmon.json" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    print("host: not running"); sys.exit()
parts = []
for i, s in enumerate(d.get("screens", [])):
    st = s.get("stage") or {}
    sim = s.get("simulation") or {}
    parts.append(f"s{i} {s.get('place')} '{st.get('rotation')}' {st.get('number')}/{st.get('count')} '{st.get('label')}' "
                 f"gen {st.get('generation')} {st.get('cells')}c@{st.get('cell_px')}px fps {st.get('frame_rate')} speed {st.get('speed')} "
                 f"tuned {st.get('tuned')} sim {sim.get('on')} ({sim.get('why')}) paused {st.get('paused')} hidden {s.get('hidden')}")
print(f"mem {d.get('memory_mb')} MB | paused {d.get('paused')} why {d.get('paused_why')} held {d.get('held')} held_why {d.get('held_why')} | " + " || ".join(parts))
PY
)
    echo "$(date -u +%T) host cpu ${hc:-?}% rss $(( ${hr:-0} / 1024 )) MB | app cpu ${ac:--}% | gpu ${gpu:-?}% | $line" >> "$OUT"
    sleep "${DMON_EVERY:-5}"
done
