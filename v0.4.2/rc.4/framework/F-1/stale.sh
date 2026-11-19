#!/bin/bash
# F-1: a search started detached on the host, in homes/f1, then killed outright, so the Hunts window
# has a stale run to show (rc.3 audit, bdc8730).
W4=$W4
. $W4/env.sh f1 >/dev/null
$J search explore --detach --minutes 10 --label f1-stale 2>&1 | tail -1
sleep 20
pid=$(pgrep -f "jetcarp jobs resume 1 --library $W4/homes/f1/library" | head -1)
echo "killing the search's process $pid"
kill -9 "$pid"
sleep 2
$J jobs status 1 2>&1 | head -3
