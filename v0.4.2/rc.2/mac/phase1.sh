#!/bin/bash
# v0.4.2-rc.2, Phase 1 on the Mac (unattended): 0 (first doctor), 1.1, 1.2, 1.3, 1.6, then 1.4.
# Each step carries on if the one before failed. Everything is logged under $R.
# Run as: caffeinate -is bash phase1.sh   (the archive is already unpacked in $T/bin: 0-unpack.txt)

export T="$HOME/jetcarp-rc-042b"
export JETCARP_CONFIG_DIR="$T/config" JETCARP_DATA_DIR="$T/data" JETCARP_OUT="$T/out"
J="$T/bin/jetcarp"
REPO=/Users/Jimmie/Documents/GitHub/jetcarp-rc
R="$REPO/results/v0.4.2-rc.2/mac"
L="$R/phase1.log"
cd "$T" || exit 1

log() { echo "$(date -u +%FT%TZ) $*" | tee -a "$L"; }
now() { date +%s; }
jget() { python3 -c 'import json,sys
d=json.load(open(sys.argv[1]))
for k in sys.argv[2].split("."):
    d=d.get(k) if isinstance(d,dict) else None
print("" if d is None else d)' "$1" "$2" 2>/dev/null; }
everyday() { find "$HOME/Library/Application Support/jetcarp" -type f -print0 | xargs -0 stat -f '%Sm %N' -t '%Y-%m-%d %H:%M:%S' | sort | tail -1; }

log "== Phase 1 starts: $("$J" --version), $(sw_vers -productVersion), $(pmset -g batt | head -1)"
log "everyday folder newest file: $(everyday)"

# ---- 0. A first doctor on the fresh folder (kept for 2.0's #17 check; Phase 1 fills the settings folder)
log "== 0 doctor, first run on the fresh test folder"
s=$(now); "$J" doctor > "$R/0-doctor-first.txt" 2>&1; log "doctor exit $?, $(( $(now)-s )) s; $(grep -m1 'self-test' "$R/0-doctor-first.txt" | sed 's/^ *//')"
s=$(now); "$J" doctor > "$R/0-doctor-second.txt" 2>&1; log "doctor again exit $?, $(( $(now)-s )) s; $(grep -m1 'self-test' "$R/0-doctor-second.txt" | sed 's/^ *//')"
ls "$T/config" >> "$L" 2>&1

# ---- 1.1 Parity, 371 scenes, Metal
log "== 1.1 parity, 371 scenes, Metal"
rm -rf "$T/parity"; cp -R "$REPO/parity" "$T/parity"
s=$(now); python3 "$T/parity/parity.py" "$J" "$T/parity" "$R/1.1-metal.csv" > "$R/1.1-metal.txt" 2>&1
log "1.1 exit $?, $(( $(now)-s )) s"; tail -2 "$R/1.1-metal.txt" | tee -a "$L"

# ---- 1.2 Long-run parity, 40 scenes x 5000 generations, Metal
log "== 1.2 long parity, 40 scenes x 5000, Metal"
s=$(now); python3 "$T/parity/parity.py" "$J" "$T/parity/long" "$R/1.2-metal.csv" --gens 5000 > "$R/1.2-metal.txt" 2>&1
log "1.2 exit $?, $(( $(now)-s )) s"; tail -2 "$R/1.2-metal.txt" | tee -a "$L"

# ---- 1.3 The whole test suite on the M2 Max (the tag's source; a scratch HOME, no JETCARP_* variables)
log "== 1.3 cargo test --release --workspace --no-fail-fast (tag v0.4.2-rc.2)"
rm -rf "$T/src"
git clone -q --depth 1 -b v0.4.2-rc.2 https://github.com/jprodgers/jetcarp "$T/src" >> "$L" 2>&1
log "clone exit $?, commit $(git -C "$T/src" rev-parse --short HEAD 2>/dev/null)"
mkdir -p "$T/test-home"
s=$(now)
( cd "$T/src" && env -u JETCARP_CONFIG_DIR -u JETCARP_DATA_DIR -u JETCARP_OUT \
    HOME="$T/test-home" CARGO_HOME="$HOME/.cargo" RUSTUP_HOME="$HOME/.rustup" \
    cargo test --release --workspace --no-fail-fast ) > "$R/1.3-tests.txt" 2>&1
rc=$?
log "1.3 exit $rc, $(( $(now)-s )) s"
grep -E '^test result' "$R/1.3-tests.txt" | awk '{p+=$4; f+=$6; i+=$8} END {print "1.3 totals: " p " passed, " f " failed, " i " ignored, in " NR " test binaries"}' | tee -a "$L"
grep -E '^test .* (FAILED|ignored)' "$R/1.3-tests.txt" | sort -u | tee -a "$L"
grep -E 'error(\[|:)' "$R/1.3-tests.txt" | head -5 | tee -a "$L"
log "everyday folder newest file: $(everyday)"

# ---- 1.6 The deterministic hunt (job 1)
log "== 1.6 deterministic hunt"
s=$(now)
"$J" search hunt --rules B3/S23,B36/S23,B2/S34 --tilings square,hex --soups 20000 --seed 4242 --label det --json > "$R/1.6-hunt.json" 2> "$R/1.6-hunt.err"
log "hunt exit $?, $(( $(now)-s )) s"
hj=$(jget "$R/1.6-hunt.json" job); [ -z "$hj" ] && hj=1
"$J" jobs status "$hj" --json > "$R/1.6-status.json" 2>&1
"$J" jobs status "$hj" > "$R/1.6-status.txt" 2>&1
log "hunt job $hj: $(head -1 "$R/1.6-status.txt")"

# ---- 1.4 A 2-hour explore, killed hard at about an hour, resumed to the end, packed unsealed, imported
log "== 1.4 explore, 120 minutes, detached"
"$J" search explore --minutes 120 --label long --detach --json > "$R/1.4-start.json" 2> "$R/1.4-start.err"
log "explore start exit $?"
job=$(jget "$R/1.4-start.json" job); [ -z "$job" ] && job=2
t0=$(now)
PAT="jetcarp jobs resume $job "
sleep 15
log "explore job $job; its processes: $(pgrep -fl "$PAT" | tr '\n' ';')"
W="$R/1.4-watch.txt"
watch() {
    { echo "== $(date -u +%FT%TZ) (+$(( ($(now)-t0)/60 )) min)"
      for p in $(pgrep -f "$PAT"); do ps -o pid=,rss=,%cpu= -p "$p"; done
      "$J" jobs status "$job" 2>&1 | head -3; } >> "$W"
}
# Until about an hour: a sample a minute
while [ $(( $(now)-t0 )) -lt 3600 ]; do
    watch
    if ! pgrep -f "$PAT" > /dev/null; then log "the explore process is gone before the kill"; break; fi
    sleep 60
done
"$J" jobs status "$job" > "$R/1.4-status-before-kill.txt" 2>&1
log "before the kill: $(head -1 "$R/1.4-status-before-kill.txt")"
log "kill -9: $(pgrep -f "$PAT" | tr '\n' ' ')"
pkill -9 -f "$PAT"; tk=$(now)
"$J" jobs wait "$job" --timeout 180 > "$R/1.4-wait-after-kill.txt" 2>&1; rc=$?
log "jobs wait after the kill: exit $rc after $(( $(now)-tk )) s (6 = gone)"
"$J" jobs status "$job" > "$R/1.4-status-after-kill.txt" 2>&1
"$J" jobs status "$job" --json > "$R/1.4-status-after-kill.json" 2>&1
log "after the kill: $(head -2 "$R/1.4-status-after-kill.txt" | tr '\n' ' ') | resumable=$(jget "$R/1.4-status-after-kill.json" resumable) stale=$(jget "$R/1.4-status-after-kill.json" stale)"
"$J" jobs resume "$job" --detach --json > "$R/1.4-resume.json" 2> "$R/1.4-resume.err"
log "resume exit $?"
sleep 15
# To the end: wait a minute at a time, a sample each time
while :; do
    "$J" jobs wait "$job" --timeout 60 --quiet > /dev/null 2>&1; rc=$?
    if [ $rc -eq 5 ] || pgrep -f "$PAT" > /dev/null; then
        watch
        if [ $(( $(now)-t0 )) -gt 14400 ]; then log "over 4 hours: jobs stop"; "$J" jobs stop "$job" >> "$L" 2>&1; fi
        [ $rc -ne 5 ] && sleep 30
        continue
    fi
    break
done
log "jobs wait at the end: exit $rc (0 = done), $(( ($(now)-t0)/60 )) min after the start"
"$J" jobs status "$job" > "$R/1.4-status-end.txt" 2>&1
"$J" jobs status "$job" --json > "$R/1.4-status-end.json" 2>&1
log "end: $(head -2 "$R/1.4-status-end.txt" | tr '\n' ' ')"
ns=$(jget "$R/1.4-status-end.json" progress.screened); nc=$(jget "$R/1.4-status-end.json" progress.confirmed)
"$J" jobs runs "$job" --limit 0 --format csv --out "$T/1.4-runs-search.csv" > /dev/null 2>&1
log "search runs: screened $ns + confirmed $nc; jobs runs csv: $(( $(wc -l < "$T/1.4-runs-search.csv") - 1 )) rows"

log "== 1.4 pack export (no jobs seal) and import into a fresh library"
"$J" pack key --name "rc.2 test publisher" > "$R/1.4-key.txt" 2>&1; log "pack key exit $?"
rm -rf "$T/rc2-long" "$T/import"
s=$(now); "$J" pack export --to "$T/rc2-long" --feed rc2-long --no-media > "$R/1.4-export.txt" 2>&1
log "export exit $?, $(( $(now)-s )) s; size $(du -sh "$T/rc2-long" | cut -f1) ($(du -sk "$T/rc2-long" | cut -f1) KiB)"
grep -i 'seal' "$R/1.4-export.txt" | tee -a "$L"
"$J" pack check "$T/rc2-long" > "$R/1.4-check.txt" 2>&1; log "pack check exit $?"
mkdir -p "$T/import"
s=$(now); "$J" pack import "$T/rc2-long" --library "$T/import/library.sqlite" > "$R/1.4-import.txt" 2>&1
log "import exit $?, $(( $(now)-s )) s"
"$J" jobs list --library "$T/import/library.sqlite" > "$R/1.4-import-jobs.txt" 2>&1
"$J" jobs list --library "$T/import/library.sqlite" --json > "$R/1.4-import-jobs.json" 2>&1
ij=$(python3 -c 'import json,sys
d=json.load(open(sys.argv[1])); d=d.get("jobs",d) if isinstance(d,dict) else d
print(next((j.get("job",j.get("id")) for j in d if j.get("kind")=="explore"),""))' "$R/1.4-import-jobs.json" 2>/dev/null)
log "imported explore job: ${ij:-not found}"
cat "$R/1.4-import-jobs.txt" >> "$L"
if [ -n "$ij" ]; then
    "$J" jobs runs "$ij" --library "$T/import/library.sqlite" --limit 0 --format csv --out "$T/1.4-runs-import.csv" > /dev/null 2>&1
    log "imported runs: $(( $(wc -l < "$T/1.4-runs-import.csv") - 1 )) rows (search: screened $ns + confirmed $nc)"
fi
log "everyday folder newest file: $(everyday); which jetcarp: $(which jetcarp) ($(jetcarp --version))"
log "jetcarp processes left: $(pgrep -lx jetcarp | tr '\n' ';')"
log "== Phase 1 ends"
