# Shared by 2.7–2.10 (source after env2.sh, with STEP set, e.g. STEP=2.8). Each call's stdout, stderr and command
# line go to $R/$STEP-out/<n>.{out,err,cmd}; the log is $R/$STEP-log.txt.
LOG="$R/$STEP-log.txt"; : > "$LOG"; O="$R/$STEP-out"; rm -rf "$O"; mkdir -p "$O"; n=0
ts() { python3 -c 'import time; print(f"{time.time():.3f}")'; }
since() { python3 -c "import time; print(f'{time.time()-$1:.1f}')"; }
L() { echo "$(date -u +%T) $*" >> "$LOG"; }
# JC <timeout s, 0 = none> <args…>: run jetcarp with output to files; sets RC, SECS, OUT (stdout + stderr)
JC() {
    local to=$1; shift; n=$((n+1)); printf '%q ' "$@" > "$O/$n.cmd"; local t0; t0=$(ts)
    if [ "$to" -gt 0 ]; then
        "$J" "$@" > "$O/$n.out" 2> "$O/$n.err" & local p=$!
        ( sleep "$to"; kill -0 $p 2>/dev/null && kill $p ) > /dev/null 2>&1 & local w=$!
        wait $p; RC=$?; kill $w 2>/dev/null; wait $w 2>/dev/null
    else
        "$J" "$@" > "$O/$n.out" 2> "$O/$n.err"; RC=$?
    fi
    SECS=$(since "$t0")
    OUT="$(cat "$O/$n.out" "$O/$n.err" | tr '\r' '\n' | grep -v '^[[:space:]]*$')"
    L "jetcarp $* -> exit $RC in $SECS s ($n)"; echo "$OUT" | tail -"${SHOW:-12}" | sed 's/^/    /' >> "$LOG"
}
jobid() { echo "$OUT" | grep -oE '(hunt|explore) (search )?job [0-9]+' | head -1 | grep -oE '[0-9]+$'; }
rows() { [ -f "$1" ] && echo $(( $(wc -l < "$1") - 1 )) || echo -1; }
