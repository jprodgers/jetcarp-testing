#!/usr/bin/env bash
# R4 #80: macOS memory is the physical footprint. During a 3-minute explore (test folder homes/mem80, started with
# `search explore --minutes 3 --detach --label m80`), every 15 s: `jobs status`'s memory (progress.rss_gb, shown
# as "N GB of memory"), against `footprint <pid>` and `ps -o rss` of the process running the job.
set -u
D=$(cd "$(dirname "$0")" && pwd)
. "$D/lib.sh" mem80
echo "R4 #80 jobs status memory against footprint and RSS, the Mac, $(ts); test folder \$H = homes/mem80"
echo "time,job status (GB),job status line,footprint (MB),footprint phys_footprint (bytes),RSS (MB),process"
while :; do
  pid=$(pgrep -f "$J jobs resume 1 " | head -1)
  [ -z "$pid" ] && break
  st=$("$J" jobs status 1 --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); print("%.4f" % d["progress"]["rss_gb"])' 2>/dev/null)
  line=$("$J" jobs status 1 2>/dev/null | grep -o '[0-9.]* GB of memory')
  fp=$(footprint -p "$pid" 2>/dev/null | awk '/phys_footprint:/ {print $2, $3; exit}')
  fpb=$(footprint -j /dev/stdout -p "$pid" 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); p=d["processes"][0]; print(p.get("footprint", ""))' 2>/dev/null)
  rss=$(ps -o rss= -p "$pid" | awk '{printf "%.1f", $1/1024}')
  echo "$(date +%T),$st,$line,$fp,$fpb,$rss,$pid"
  sleep 15
done
echo "(the job's process has ended)"
run "\$J jobs status 1 | head -3"
