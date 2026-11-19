#!/bin/bash
# #95 again (67a08a6): every second, the probe, ioreg's lock flag, the host's held state, and host status's screen, monitors and wallpaper lines.
R=/Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac; source $R/env2.sh
P=/private/tmp/claude-502/-Users-Jimmie-Documents-GitHub-jetcarp-rc/SESSION/scratchpad/95probe
B="$T/src/target/release/jetcarp"; O="$R/95b-probe.txt"; : > "$O"; slept=0; lock_at=""; unlock_at=0; end=$(( $(date +%s) + 180 ))
while [ $(date +%s) -lt $end ]; do
    io=no; ioreg -n Root -d1 -a | grep -q CGSSessionScreenIsLocked && io=yes
    if [ $io = yes ] && [ -z "$lock_at" ]; then lock_at=$(date +%s); fi
    if [ -n "$lock_at" ] && [ $slept -eq 0 ] && [ $(( $(date +%s) - lock_at )) -ge 5 ]; then echo "$(date -u +%T) == pmset displaysleepnow" >> "$O"; pmset displaysleepnow; slept=1; fi
    if [ $io = no ] && [ $slept -eq 1 ] && [ $unlock_at -eq 0 ]; then unlock_at=$(date +%s); fi
    [ $unlock_at -gt 0 ] && [ $(( $(date +%s) - unlock_at )) -ge 10 ] && break
    h=$("$B" host status --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); print("gen", d["screens"][0]["stage"]["generation"], "held", d["held"])' 2>/dev/null)
    txt=$("$B" host status 2>&1 | grep -E "^screen|^monitors|^wallpaper" | sed -E "s/ · generation [0-9]+//" | tr "\n" "~")
    echo "$(date -u +%T) ioreg locked=$io | $($P) | $h | $txt" >> "$O"
    sleep 1
done
pmset -g log | grep -E "Display is turned (on|off)" | tail -2 >> "$O"
