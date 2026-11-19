#!/bin/bash
# 2.3 (M3): a CPU-only JACA explore; after ~5 min, jobs stop from another process, time jobs wait, resume at once
# (#16: it must be accepted straight away) for 4 more minutes, then status. The Acer's 2.3-steps.ps1, for the Mac.
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
LOG="$R/2.3-log.txt"; : > "$LOG"
ts() { python3 -c 'import time; print(f"{time.time():.3f}")'; }
lg() { echo "$(date -u +%T) $*" | tee -a "$LOG"; }
lg "start: search explore --cpu --families jaca --minutes 10 --label cpu-jaca"
"$J" search explore --cpu --families jaca --minutes 10 --label cpu-jaca > "$R/2.3-explore.out" 2> "$R/2.3-explore.err" &
ex=$!
sleep 300
lg "explore still running: $(kill -0 $ex 2>/dev/null && echo yes || echo no)"
t0=$(ts)
out=$("$J" jobs stop 2 2>&1); lg "jobs stop 2 -> exit $?: $out"
out=$("$J" jobs wait 2 --timeout 60 2>&1); rc=$?; t1=$(ts)
lg "jobs wait 2 --timeout 60 -> exit $rc after $(python3 -c "print(f'{$t1-$t0:.2f}')") s from the stop: $(echo "$out" | tail -2 | tr '\n' ' ')"
lg "explore process had exited when wait returned: $(kill -0 $ex 2>/dev/null && echo no || echo yes)"
"$J" jobs resume 2 --minutes 4 > "$R/2.3-resume.txt" 2>&1; rc=$?
lg "jobs resume 2 --minutes 4 -> exit $rc: $(head -3 "$R/2.3-resume.txt" | tr '\n' ' ')"
wait $ex; lg "first explore process: exit $?"
if [ $rc -ne 0 ] && grep -qi already "$R/2.3-resume.txt"; then
    lg "refused (#16 not fixed?); waiting 10 s and resuming again"; sleep 10
    "$J" jobs resume 2 --minutes 4 >> "$R/2.3-resume.txt" 2>&1; lg "second resume -> exit $?"
fi
"$J" jobs status 2 > "$R/2.3-status.txt" 2>&1; lg "jobs status 2 -> exit $?"
"$J" jobs status 2 --json > "$R/2.3-status.json" 2>&1
lg "done"
