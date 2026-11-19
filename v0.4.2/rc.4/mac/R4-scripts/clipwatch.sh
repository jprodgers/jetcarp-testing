#!/bin/bash
# R4 #114: the clipboard, every second, a line when it changes. Only text that mentions jetcarp or is a rule
# (B…/S…) is written down; anything else is logged as "something else, not recorded". Ends on the stop file.
OUT="$1"; STOP="$1.stop"; prev="$(pbpaste 2>/dev/null | shasum | cut -c1-12)"
echo "# the clipboard, every second; started $(date +%T) (what was on it then isn't recorded)" > "$OUT"
while [ ! -e "$STOP" ]; do
    now="$(pbpaste 2>/dev/null)"; h="$(printf '%s' "$now" | shasum | cut -c1-12)"
    if [ "$h" != "$prev" ]; then
        if printf '%s' "$now" | grep -q -i jetcarp || printf '%s' "$now" | grep -q -E '^[[:space:]]*B[0-9]*/S[0-9]*[[:space:]]*$'; then
            printf '%s %d bytes: %s\n' "$(date +%T)" "$(printf '%s' "$now" | wc -c)" "$(printf '%s' "$now" | sed "s#$HOME#~#g" | od -c | head -3 | tr -s ' ' | tr '\n' ' ')" >> "$OUT"
            printf '    as text: [%s]\n' "$(printf '%s' "$now" | sed "s#$HOME#~#g")" >> "$OUT"
        else
            echo "$(date +%T) something else, not recorded" >> "$OUT"
        fi
        prev="$h"
    fi
    sleep 1
done
echo "# ended $(date +%T)" >> "$OUT"; rm -f "$STOP"
