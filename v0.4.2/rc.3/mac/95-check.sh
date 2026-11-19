#!/bin/bash
# #95's check on the Mac: log the branch host's held state and generation every second; 5 s after the screen locks
# (CGSSessionScreenIsLocked in ioreg), put the display to sleep with `pmset displaysleepnow`. Ends 30 s after unlock,
# or after 6 minutes. Output: $R/95-check.txt
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
B="$T/src/target/release/jetcarp"; O="$R/95-check.txt"; : > "$O"
locked() { ioreg -n Root -d1 -a | grep -q CGSSessionScreenIsLocked; }
slept=0; unlock_at=0; end=$(( $(date +%s) + 360 ))
while [ $(date +%s) -lt $end ]; do
    l=no; locked && l=yes
    if [ $l = yes ] && [ $slept -eq 0 ]; then
        [ -z "$lock_at" ] && { lock_at=$(date +%s); echo "$(date -u +%T) == locked" >> "$O"; }
        if [ $(( $(date +%s) - lock_at )) -ge 5 ]; then echo "$(date -u +%T) == pmset displaysleepnow" >> "$O"; pmset displaysleepnow; slept=1; fi
    fi
    if [ $l = no ] && [ $slept -eq 1 ] && [ $unlock_at -eq 0 ]; then unlock_at=$(date +%s); echo "$(date -u +%T) == unlocked" >> "$O"; fi
    [ $unlock_at -gt 0 ] && [ $(( $(date +%s) - unlock_at )) -ge 30 ] && break
    "$B" host status --json 2>/dev/null | python3 -c 'import json,sys
d=json.load(sys.stdin); s=d["screens"][0]["stage"]
print(sys.argv[1], "locked", sys.argv[2], "| gen", s["generation"], "| held", d["held"], d["held_why"])' "$(date -u +%T)" "$l" >> "$O"
    sleep 1
done
echo "$(date -u +%T) == end" >> "$O"
pmset -g log | grep -E "Display is turned (on|off)" | tail -4 >> "$O"
