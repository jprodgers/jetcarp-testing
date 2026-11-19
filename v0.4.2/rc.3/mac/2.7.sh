#!/bin/bash
# 2.7 (M7): jobs wait exit codes, a memory cap, a detached hunt killed with kill -9, the no-GPU note (#31), and jobs
# wait printing only changed lines (#32). The Acer's 2.7-steps.ps1 in bash; job ids are read from the output.
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
STEP=2.7; source "$R/lib2.sh"

# 1. A detached hunt that finishes; jobs wait -> 0.
JC 0 search hunt --soups 3000 --detach --label wait-done; j1=$(jobid); L "job: $j1"
JC 0 jobs wait "$j1"; L "lines printed by jobs wait: $(grep -c . "$O/$n.err")"

# 2. A memory-capped hunt (foreground): it should pause; jobs wait --timeout 5 -> 3.
JC 600 search hunt --soups 2000000 --max-rss-gb 0.05 --label capped; j2=$(jobid); L "job: $j2"
JC 0 jobs status "$j2"
JC 0 jobs wait "$j2" --timeout 5

# 3. A detached hunt killed with kill -9; jobs wait --timeout 120 -> 6 (rc.3, #49: at once).
JC 0 search hunt --soups 2000000 --detach --label to-kill; j3=$(jobid); L "job: $j3"
sleep 10
pgrep -fl 'bin/jetcarp' | sed 's/^/  process /' >> "$LOG"
victim=$(pgrep -f "bin/jetcarp jobs resume $j3 " | head -1)
L "killing $victim with kill -9"; tk=$(ts); kill -9 "$victim"
JC 0 jobs status "$j3"; L "  status $(python3 -c "import time; print(f'{time.time()-$tk:.1f}')") s after the kill"
JC 0 jobs wait "$j3" --timeout 120; L "  (killed $(python3 -c "import time; print(f'{time.time()-$tk:.1f}')") s before wait returned)"
JC 0 jobs wait "$j3" --timeout 2
pgrep -fl 'bin/jetcarp' | sed 's/^/  left: /' >> "$LOG"

# 4. Resume the killed job for a minute.
JC 300 jobs resume "$j3" --minutes 1
JC 0 jobs status "$j3"

# 5. GPU off, a hunt asked for --gpu: it runs on the CPU and says so (#31).
export JETCARP_GPU=off
JC 600 search hunt --gpu --soups 500 --label no-gpu; j4=$(jobid)
unset JETCARP_GPU
JC 0 jobs status "$j4"
L "jobs: wait-done $j1, capped $j2, to-kill $j3, no-gpu $j4"
L "done"
