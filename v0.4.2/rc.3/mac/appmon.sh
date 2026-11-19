#!/bin/bash
# Log the app's process every 5 s (pid, %CPU, RSS, threads; footprint every 30 s) to $R/2.APP-app-mon.csv
# until the stop file appears. The app is the test bin's jetcarp with no arguments.
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
M="${MON:-$R/2.APP-app-mon.csv}"; STOP="$T/appmon.stop"; rm -f "$STOP"
[ -f "$M" ] || echo "time,pid,cpu_pct,rss_mb,threads,footprint_mb" > "$M"
k=0
while [ ! -e "$STOP" ]; do
    p=$(pgrep -fx "${APP:-$T/bin/jetcarp}" | head -1)
    if [ -n "$p" ]; then
        read -r cpu rss <<< "$(ps -o %cpu=,rss= -p "$p")"
        th=$(( $(ps -M -p "$p" 2>/dev/null | wc -l) - 1 ))
        fp=""; if [ $((k % 6)) -eq 0 ]; then fp=$(footprint -f bytes --noCategories "$p" 2>/dev/null | sed -n 's/.*phys_footprint: \([0-9]*\) B.*/\1/p' | head -1); fp=$(( ${fp:-0} / 1048576 )); fi
        echo "$(date -u +%T),$p,$cpu,$(( ${rss:-0} / 1024 )),$th,$fp" >> "$M"
    else
        echo "$(date -u +%T),,,,," >> "$M"
    fi
    k=$((k+1)); sleep 5
done
