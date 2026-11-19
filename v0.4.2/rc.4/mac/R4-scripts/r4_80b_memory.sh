#!/usr/bin/env bash
# R4 #80, second pass: the same job resumed for 3 minutes (`jobs resume 1 --minutes 3 --detach`), sampled every 3 s:
# jobs status's memory (progress.rss_gb) and the time the job last wrote its status ("updated"), against
# footprint's phys_footprint and phys_footprint_peak and ps's RSS, for the process running the job.
set -u
D=$(cd "$(dirname "$0")" && pwd)
. "$D/lib.sh" mem80
echo "R4 #80b, the Mac, $(ts); test folder \$H = homes/mem80; MB = MiB, as footprint and ps count them; status GB x 1024 = its MiB"
echo "time,status updated,status MiB,phys_footprint MiB,phys_footprint_peak MiB,RSS MiB,pid"
while :; do
  pid=$(pgrep -f "$J jobs resume 1 " | head -1)
  [ -z "$pid" ] && break
  st=$("$J" jobs status 1 --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["updated"][11:19] if "updated" in d else d.get("jobs",[{}])[0].get("updated","")[11:19], "%.0f" % (d["progress"]["rss_gb"] * 1024), sep=",")' 2>/dev/null)
  fp=$(footprint -p "$pid" 2>/dev/null | awk '/phys_footprint:/ {f=$2" "$3} /phys_footprint_peak:/ {p=$2" "$3} END {print f "," p}')
  rss=$(ps -o rss= -p "$pid" | awk '{printf "%.0f", $1/1024}')
  echo "$(date +%T),$st,$fp,$rss,$pid"
  sleep 3
done
echo "(the job's process has ended)"
run "\$J jobs status 1 | head -3"
