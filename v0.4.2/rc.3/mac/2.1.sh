#!/bin/bash
# 2.1 (M1): a 10-minute explore of four families with no --gpu (the GPU is the default); progress to a file,
# the search process's CPU, RSS and footprint every 10 s; then status and the runs CSV.
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
S="$R/2.1-sample.csv"; echo "time,pid,cpu_pct,rss_mb,footprint_mb" > "$S"
"$J" search explore --families life_like,generations,jaca,cyclic --minutes 10 --label gpu-mix > "$R/2.1-explore.out" 2> "$R/2.1-explore.err" &
ex=$!
sleep 3
while kill -0 $ex 2>/dev/null; do
    p=$(pgrep -f "bin/jetcarp search explore --families" | head -1)
    if [ -n "$p" ]; then
        read -r rss cpu <<< "$(ps -o rss=,%cpu= -p "$p")"
        fp=$(footprint -f bytes --noCategories "$p" 2>/dev/null | sed -n 's/.*phys_footprint: \([0-9]*\) B.*/\1/p' | head -1)
        echo "$(date -u +%T),$p,$cpu,$(( ${rss:-0}/1024 )),$(( ${fp:-0}/1048576 ))" >> "$S"
    fi
    sleep 10
done
wait $ex; echo "explore exit $?" >> "$R/2.1-explore.out"
"$J" jobs status 1 > "$R/2.1-status.txt" 2>&1
"$J" jobs status 1 --json > "$R/2.1-status.json" 2>&1
"$J" jobs runs 1 --limit 0 --format csv --out "$T/2.1-runs.csv" > /dev/null 2>&1
echo "runs csv rows: $(( $(wc -l < "$T/2.1-runs.csv") - 1 ))" >> "$R/2.1-explore.out"
