#!/bin/bash
# F-1 #87 under GNOME: ask the app (AI control on) for world_status every 2 s for N seconds, printing
# the time, how long the answer took, the generation and the speed; the app's CPU from ps.
W4=$W4
. $W4/env.sh f1 >/dev/null
N=${1:-60}
app=$(pgrep -f "$W4/bin/.*/jetcarp( |$)" | head -1)
echo "app pid ${app:-none}; polling ${N}s"
prev=""; t0=$(date +%s.%N)
end=$(( $(date +%s) + N ))
while [ "$(date +%s)" -lt "$end" ]; do
  s=$(date +%s.%N)
  out=$($J app call world_status 2>&1)
  e=$(date +%s.%N)
  gen=$(printf '%s' "$out" | grep -o '"generation": *[0-9]*' | head -1 | grep -o '[0-9]*$')
  [ -z "$gen" ] && gen=$(printf '%s' "$out" | grep -o -i 'generation[^0-9]*[0-9,]*' | head -1 | tr -dc '0-9')
  cpu=$(ps -o %cpu= -p "$app" 2>/dev/null | tr -d ' ')
  rate=""; [ -n "$prev" ] && [ -n "$gen" ] && rate=$(awk -v a="$gen" -v b="$prev" -v t="$s" -v u="$pt" 'BEGIN{printf "%.1f", (a-b)/(t-u)}')
  printf '%6.1f s  answer %.2f s  generation %s  %s gens/s  app CPU %s%%\n' "$(awk -v a="$s" -v b="$t0" 'BEGIN{print a-b}')" "$(awk -v a="$e" -v b="$s" 'BEGIN{print a-b}')" "${gen:-?}" "${rate:--}" "${cpu:-?}"
  prev=$gen; pt=$s
  sleep 2
done
