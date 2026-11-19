#!/bin/bash
# R4 #89: JETCARP's power assertions every 2 s (JETCARP's lines only), a line when they change. Ends on the stop file.
OUT="$1"; STOP="$1.stop"; prev="-"
echo "# pmset -g assertions, JETCARP's lines, every 2 s; started $(date +%T)" > "$OUT"
while [ ! -e "$STOP" ]; do
    now=$(pmset -g assertions | grep -i jetcarp | sed 's/^ *//; s/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]  *//' | sort | tr '\n' '|')
    [ "$now" != "$prev" ] && echo "$(date +%T) ${now:-(none)}" >> "$OUT" && prev="$now"
    sleep 2
done
echo "# ended $(date +%T)" >> "$OUT"; rm -f "$STOP"
