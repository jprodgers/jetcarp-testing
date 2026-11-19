#!/bin/bash
# Every second for up to 3 minutes: the probe's line, ioreg's console lock flag, and the host's held state.
R=/Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac; source $R/env2.sh
P=/private/tmp/claude-502/-Users-Jimmie-Documents-GitHub-jetcarp-rc/SESSION/scratchpad/95probe
B="$T/src/target/release/jetcarp"; O="$R/95-probe.txt"; : > "$O"; slept=0; lock_at=""; unlock_at=0; end=$(( $(date +%s) + 180 ))
while [ $(date +%s) -lt $end ]; do
    io=no; ioreg -n Root -d1 -a | grep -q CGSSessionScreenIsLocked && io=yes
    if [ $io = yes ] && [ -z "$lock_at" ]; then lock_at=$(date +%s); fi
    if [ -n "$lock_at" ] && [ $slept -eq 0 ] && [ $(( $(date +%s) - lock_at )) -ge 5 ]; then echo "$(date -u +%T) == pmset displaysleepnow" >> "$O"; pmset displaysleepnow; slept=1; fi
    if [ $io = no ] && [ $slept -eq 1 ] && [ $unlock_at -eq 0 ]; then unlock_at=$(date +%s); fi
    [ $unlock_at -gt 0 ] && [ $(( $(date +%s) - unlock_at )) -ge 10 ] && break
    h=$("$B" host status --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); print("gen", d["screens"][0]["stage"]["generation"], "held", d["held"])' 2>/dev/null)
    echo "$(date -u +%T) ioreg locked=$io | $($P) | $h" >> "$O"
    sleep 1
done
pmset -g log | grep -E "Display is turned (on|off)" | tail -2 >> "$O"
