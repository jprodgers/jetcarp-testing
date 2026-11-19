#!/bin/bash
# Every 30 s, capture each of the app's windows as a 1400-px JPEG in ~/jetcarp-rc-042c/autoshots (not committed),
# until ~/jetcarp-rc-042c/autoshot.stop appears.
WL=/private/tmp/claude-502/-Users-Jimmie-Documents-GitHub-jetcarp-rc/SESSION/scratchpad/winlist
D="$HOME/jetcarp-rc-042c/autoshots"; STOP="$HOME/jetcarp-rc-042c/autoshot.stop"; rm -f "$STOP"; mkdir -p "$D"
while [ ! -e "$STOP" ]; do
    p=$(pgrep -fx "${APP:-$HOME/jetcarp-rc-042c/bin/jetcarp}" | head -1)
    if [ -n "$p" ]; then
        t=$(date -u +%H%M%S); k=0
        "$WL" "$p" | while read -r id size title; do
            f="$D/$t-$k.jpg"; screencapture -x -o -t jpg -l "$id" "$f" 2>/dev/null && sips -Z 1400 "$f" >/dev/null 2>&1
            k=$((k+1))
        done
    fi
    sleep 30
done
