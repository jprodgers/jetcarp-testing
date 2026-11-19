#!/bin/bash
# rc.4 wave on the Mac, 1.5: the desktop soak on rc.4's release build (the archive's jetcarp), 8 hours, unattended.
#   The pre-check's soak.sh (results/v0.4.2-rc4-pre/mac/) with rc.4's host from a test folder of its own ($P), the
#   warning answered there, wallpaper on, the rotation "Classics, hourly" (Jimmie's choice for the Acer's soak, so the
#   soak covers scene changes: the pre-check's question 4), default pacing. Jimmie away, on mains.
#   Every 5 min: host status --json (soak-status.jsonl), and a row in soak.csv (generation, scene, memory, held, measured
#   speed per screen; ps and top CPU; RSS; footprint; ioreg's whole-GPU %). Every hour: a capture of the host's own
#   desktop window (nothing else on screen) and a commit and push.
#   After 8 h, #95: pmset displaysleepnow, samples every 15 s for 3 min, the display woken (caffeinate -u), 90 s more.
#   Then host stop, the summary, a last push.
# Run as: nohup caffeinate -is bash soak.sh &
export P="$HOME/jetcarp-rc4/homes/soak"
export JETCARP_CONFIG_DIR="$P/config" JETCARP_DATA_DIR="$P/data" JETCARP_OUT="$P/out" JETCARP_RUNTIME_DIR="$P/runtime"
unset JETCARP_GPU WGPU_BACKEND JETCARP_LIBRARY
J="$HOME/jetcarp-rc4/rel/jetcarp-0.4.2-rc.4-aarch64-apple-darwin/jetcarp"
ROT="Classics, hourly"
REPO="$HOME/Documents/GitHub/jetcarp-rc"
R="$REPO/results/v0.4.2-rc4/mac/soak"
L="$R/soak.log"; SUM="$R/summary.txt"; CSV="$R/soak.csv"; JL="$R/soak-status.jsonl"
HOURS="${SOAK_HOURS:-8}"; EVERY=300
mkdir -p "$P/bin"; cd "$P" || exit 1

log() { echo "$(date -u +%FT%TZ) $*" >> "$L"; }
res() { echo "$1: $2" >> "$SUM"; log "RESULT $1: $2"; }
now() { date +%s; }
push() {   # git's messages go outside the repo while it runs (a log in the repo, written mid-rebase, stops the rebase)
    local out="$P/push.out" ok=1
    ( cd "$REPO" && git add "results/v0.4.2-rc4/mac/soak" && \
      { git commit -q -m "$1

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" || true; } && \
      git pull -q --rebase --autostash && git push -q ) > "$out" 2>&1 || ok=0
    [ -s "$out" ] && sed 's/^/  git: /' "$out" >> "$L"
    [ $ok = 1 ] && log "pushed: $1" || log "push: failed (above)"
}
hpid() { python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("pid") or "")' "$1" 2>/dev/null; }
mb() { python3 -c '
import re, sys
m = re.search(r"Footprint:\s+([\d.]+)\s*(KB|MB|GB)", sys.stdin.read())
print("" if not m else round(float(m.group(1)) * {"KB": 1/1024, "MB": 1, "GB": 1024}[m.group(2)], 1))'; }
sample() {   # sample <csv> <elapsed label>: one status, one row
    local js="$P/soak-now.json" hp pc tc rss fp gpu
    "$J" host status --json > "$js" 2>/dev/null
    python3 -c 'import json,sys,time
try: d=json.load(open(sys.argv[1]))
except Exception: d=None
print(json.dumps({"t": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "status": d}))' "$js" >> "$JL"
    hp=$(hpid "$js"); pc=""; tc=""; rss=""; fp=""
    if [ -n "$hp" ] && kill -0 "$hp" 2>/dev/null; then
        read -r pc rss <<< "$(ps -o %cpu=,rss= -p "$hp")"; rss=$(( rss / 1024 ))
        tc=$(top -l 2 -s 2 -pid "$hp" -stats cpu 2>/dev/null | tail -1 | tr -d ' ')
        fp=$(footprint "$hp" 2>/dev/null | mb)
    fi
    gpu=$(ioreg -r -d 1 -w 0 -c IOAccelerator | grep -oE '"Device Utilization %"=[0-9]+' | head -1 | cut -d= -f2)
    python3 "$R/soakrow.py" "$js" "$(date -u +%T)" "$2" "$hp" "$pc" "$tc" "$rss" "$fp" "$gpu" >> "$1"
}
shot() {   # the host's desktop-level windows only
    local hp n=0; hp=$(pgrep -f "$J host serve" | head -1); [ -z "$hp" ] && return
    "$P/bin/hostwin" "$hp" > "$P/hostwin.txt" 2>/dev/null
    while read -r id layer size on; do
        [ "$on" = 1 ] && [ "$layer" -lt 0 ] || continue
        screencapture -x -o -l "$id" -t jpg "$P/shot.jpg" 2>> "$L" && sips -Z 960 "$P/shot.jpg" --out "$R/soak-shot-$1-w$n.jpg" > /dev/null 2>&1
        n=$((n + 1))
    done < "$P/hostwin.txt"
    log "shot $1: $n window(s): $(tr '\n' ';' < "$P/hostwin.txt")"
}

# ---------------------------------------------------------------- start
swiftc -O -o "$P/bin/hostwin" "$R/hostwin.swift" >> "$L" 2>&1 || log "hostwin: build failed"
log "== soak start: $HOURS h, every $EVERY s; $("$J" --version 2>&1)"
pmset -g | grep -E 'displaysleep|^ sleep|AC Power' >> "$L"; pmset -g batt | head -2 >> "$L"
{ echo "\$ jetcarp setup --seizure-warning no-disorder --profile blank-slate --quickstart-minutes 0 --quiet"; "$J" setup --seizure-warning no-disorder --profile blank-slate --quickstart-minutes 0 --quiet < /dev/null 2>&1; echo "exit $?"
  echo "\$ jetcarp host wallpaper on"; "$J" host wallpaper on 2>&1; echo "exit $?"; } > "$R/soak-start.txt"
sleep 5
if ! "$J" host status --json 2>/dev/null | python3 -c 'import json,sys; sys.exit(0 if json.load(sys.stdin).get("pid") else 1)'; then
    { echo "\$ jetcarp host start   (wallpaper on left no host)"; "$J" host start 2>&1; echo "exit $?"; } >> "$R/soak-start.txt"
fi
sleep 5
{ echo "\$ jetcarp host rotation \"$ROT\""; "$J" host rotation "$ROT" 2>&1; echo "exit $?"; } >> "$R/soak-start.txt"
sleep 20
{ echo; echo "\$ jetcarp host status   [$(date -u +%T)]"; "$J" host status 2>&1; } >> "$R/soak-start.txt"
python3 "$R/soakrow.py" --header > "$CSV"; : > "$JL"
t0=$(now); n=$(( HOURS * 3600 / EVERY ))
res "1.5 soak start" "$(date -u +%T) UTC, $HOURS h, a sample every $(( EVERY / 60 )) min ($n); host pid $(pgrep -f "$J host serve" | head -1)"
shot 00h
push "Mac: rc.4 soak (1.5): started, \"Classics, hourly\""

# ---------------------------------------------------------------- every 5 minutes
for i in $(seq 0 "$n"); do
    target=$(( t0 + i * EVERY )); while [ "$(now)" -lt "$target" ]; do sleep 5; done
    sample "$CSV" "$(( ($(now) - t0) / 60 ))"
    if [ "$i" -gt 0 ] && [ $(( i % 12 )) -eq 0 ]; then
        h=$(printf '%02dh' $(( i / 12 ))); shot "$h"
        push "Mac: rc.4 soak (1.5) at $h"
    fi
done

# ---------------------------------------------------------------- #95: the display put to sleep, then woken
C95="$R/soak-95.csv"; python3 "$R/soakrow.py" --header > "$C95"
log "== #95: pmset displaysleepnow"
sample "$C95" "before"
pmset displaysleepnow >> "$L" 2>&1
for k in $(seq 1 12); do sleep 15; sample "$C95" "asleep+$(( k * 15 ))s"; done
log "== #95: caffeinate -u -t 2 (the display woken)"
caffeinate -u -t 2 >> "$L" 2>&1
for k in $(seq 1 6); do sleep 15; sample "$C95" "awake+$(( k * 15 ))s"; done

# ---------------------------------------------------------------- the end
{ echo; echo "\$ jetcarp host status   [$(date -u +%T)]"; "$J" host status 2>&1; echo; echo "\$ jetcarp host stop"; "$J" host stop 2>&1; echo "exit $?"; } > "$R/soak-end.txt"
python3 "$R/soaksum.py" "$CSV" "$C95" > "$R/soak-summary.txt" 2>&1
res "1.5 soak" "$(head -1 "$R/soak-summary.txt")"
push "Mac: rc.4 soak (1.5): the 8 hours done"
log "== soak done"
