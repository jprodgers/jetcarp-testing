#!/bin/bash
# Capture each on-screen window of the app (largest first) into $R/shots/<name>[-<n>].png, no shadow.
# Usage: shot.sh <name>     (winlist is built from winlist.swift into the scratchpad)
R=/Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac
WL=/private/tmp/claude-502/-Users-Jimmie-Documents-GitHub-jetcarp-rc/SESSION/scratchpad/winlist
mkdir -p "$R/shots"
p=$(pgrep -fx "${APP:-$HOME/jetcarp-rc-042c/bin/jetcarp}" | head -1); [ -z "$p" ] && { echo "no app"; exit 1; }
k=0
"$WL" "$p" | while read -r id size title; do
    f="$R/shots/$1$([ $k -gt 0 ] && echo "-$k").png"
    screencapture -x -o -l "$id" "$f" && echo "$f ($size, '$title')"
    k=$((k+1))
done
