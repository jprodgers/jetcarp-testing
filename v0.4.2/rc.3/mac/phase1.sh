#!/bin/bash
# v0.4.2-rc.3, Phase 1 on the Mac (unattended): 0 (doctor on the fresh folder; the archive is already checked and
# unpacked: 0-unpack.txt), then 1.6, 1.1, 1.2, 1.3, 1.4 (240 min; kill -9 at ~1 h; a resume with no --minutes;
# the pack with no jobs seal; an import into a fresh library).
# 1.4 also saves footprint and vmmap --summary of the search's process at ~1 h (before the kill), 2 h, 3 h and the
# end (#53 on macOS), and logs memory every 5 minutes.
# Each step carries on if one before failed. Everything is logged under $R; the summary is $R/summary.txt.
# Run as: caffeinate -is bash phase1.sh
# To adopt a running 1.4 search (after the script was stopped): P1_JOB=<job> P1_T0=<epoch of its start> caffeinate -is bash phase1.sh
#   skips 0 to 1.3 and the explore's start, keeps summary.txt and 1.4's logs, and goes on with 1.4 on the search's clock.

export T="$HOME/jetcarp-rc-042c"
export JETCARP_CONFIG_DIR="$T/config" JETCARP_DATA_DIR="$T/data" JETCARP_OUT="$T/out" JETCARP_RUNTIME_DIR="$T/runtime"
unset JETCARP_GPU WGPU_BACKEND JETCARP_LIBRARY
J="$T/bin/jetcarp"
TAG=v0.4.2-rc.3; COMMIT=400d41d
REPO=/Users/Jimmie/Documents/GitHub/jetcarp-rc
R="$REPO/results/v0.4.2-rc.3/mac"
RC2="$REPO/results/v0.4.2-rc.2/mac"
P1="python3 $R/p1.py"
L="$R/phase1.log"; SUM="$R/summary.txt"
mkdir -p "$R"; cd "$T" || exit 1
[ -z "$P1_JOB" ] && : > "$SUM"

log() { echo "$(date -u +%FT%TZ) $*" >> "$L"; }
res() { echo "$1: $2" >> "$SUM"; log "RESULT $1: $2"; }
now() { date +%s; }
everyday() { find "$HOME/Library/Application Support/jetcarp" -type f -print0 2>/dev/null | xargs -0 stat -f '%Sm %N' -t '%Y-%m-%d %H:%M:%S' | sort | tail -1; }
procs() { pgrep -fl 'bin/jetcarp' | tr '\n' ';'; }
median() { sort -n | awk '{a[NR]=$1} END {if (NR) print a[int((NR+1)/2)]; else print ""}'; }

EVERY0="$(everyday)"
if [ -z "$P1_JOB" ]; then
log "== Phase 1 starts: $("$J" --version), macOS $(sw_vers -productVersion), $(pmset -g batt | head -1)"
log "folders: CONFIG $JETCARP_CONFIG_DIR, DATA $JETCARP_DATA_DIR, OUT $JETCARP_OUT, RUNTIME $JETCARP_RUNTIME_DIR"
log "everyday folder newest file: $EVERY0"
log "jetcarp processes at start: $(procs)"
res "0 unpack" "pass: sha256 2125d411…ba39daac (SHA256SUMS and the start note), $("$J" --version) (0-unpack.txt)"

# ---------------------------------------------------------------- 0. Doctor on the fresh test folder
log "== 0 doctor"
s=$(now); "$J" doctor > "$R/0-doctor-first.txt" 2>&1; rc1=$?; d1=$(( $(now)-s ))
s=$(now); "$J" doctor > "$R/0-doctor-second.txt" 2>&1; rc2=$?; d2=$(( $(now)-s ))
st1=$(grep -m1 'self-test' "$R/0-doctor-first.txt" | sed 's/^ *//'); st2=$(grep -m1 'self-test' "$R/0-doctor-second.txt" | sed 's/^ *//')
log "config: $(ls "$T/config" | tr '\n' ' ')"
res "0 doctor" "first exit $rc1 in $d1 s ($st1); second exit $rc2 in $d2 s ($st2)"
rm -rf "$T/parity"; cp -R "$REPO/parity" "$T/parity"

# ---------------------------------------------------------------- 1.6 The deterministic hunt (job 1)
log "== 1.6 deterministic hunt"
s=$(now)
"$J" search hunt --rules B3/S23,B36/S23,B2/S34 --tilings square,hex --soups 20000 --seed 4242 --label det --json > "$R/1.6-hunt.json" 2> "$R/1.6-hunt.err"
rc=$?; hs=$(( $(now)-s ))
hj=$($P1 get "$R/1.6-hunt.json" job); [ -z "$hj" ] && hj=1
"$J" jobs status "$hj" --json > "$R/1.6-status.json" 2>&1
"$J" jobs status "$hj" > "$R/1.6-status.txt" 2>&1
line=$($P1 get "$R/1.6-status.json" line)
want="760,892 objects (ships 51,012, osc 236,468, still 473,412), 1,783 distinct"
same=$($P1 samefinds "$R/1.6-status.json" "$RC2/1.6-status.json")
v=FAIL; case "$line" in *"$want"*) case "$same" in True*) v=pass;; esac;; esac
res "1.6 hunt" "$v: job $hj, exit $rc, $hs s; $(echo "$line" | grep -oE '[0-9,]+ soups/s|[0-9,]+ objects \(.*\), [0-9,]+ distinct' | tr '\n' ' '); against rc.2's Mac: $same"

# ---------------------------------------------------------------- 1.1 and 1.2 Parity, Metal
for part in "1.1|$T/parity|300|371 scenes: CPU matches 371, GPU matches 371" "1.2|$T/parity/long|5000|40 scenes: CPU matches 40, GPU matches 40"; do
    IFS='|' read -r step dir gens wantp <<< "$part"
    log "== $step parity, $gens generations, Metal"
    s=$(now); python3 "$T/parity/parity.py" "$J" "$dir" "$R/$step-metal.csv" --gens "$gens" > "$R/$step-metal.txt" 2>&1; rc=$?
    last=$(grep 'scenes: CPU matches' "$R/$step-metal.txt" | tail -1); mism=$(grep -c '^MISMATCH' "$R/$step-metal.txt")
    v=FAIL; case "$last" in "$wantp"*) [ "$mism" -eq 0 ] && [ $rc -eq 0 ] && v=pass;; esac
    res "$step parity" "$v: $last; $mism MISMATCH lines; exit $rc, $(( $(now)-s )) s"
done

# ---------------------------------------------------------------- 1.3 The whole test suite (the tag's source; a scratch HOME, no JETCARP_* variables)
log "== 1.3 cargo test --release --workspace --no-fail-fast ($TAG)"
rm -rf "$T/src"
git clone -q --depth 1 -b "$TAG" https://github.com/jprodgers/jetcarp "$T/src" >> "$L" 2>&1; crc=$?
head=$(git -C "$T/src" rev-parse --short HEAD 2>/dev/null); log "clone exit $crc, commit $head"
[ "${head:0:7}" != "$COMMIT" ] && log "WARNING: the clone is not at $COMMIT"
rm -rf "$T/test-home"; mkdir -p "$T/test-home"
s=$(now)
( cd "$T/src" && env -u JETCARP_CONFIG_DIR -u JETCARP_DATA_DIR -u JETCARP_OUT -u JETCARP_RUNTIME_DIR \
    HOME="$T/test-home" CARGO_HOME="$HOME/.cargo" RUSTUP_HOME="$HOME/.rustup" \
    cargo test --release --workspace --no-fail-fast ) > "$R/1.3-tests.txt" 2>&1
rc=$?; secs=$(( $(now)-s ))
tot=$(grep -E '^test result' "$R/1.3-tests.txt" | awk '{p+=$4; f+=$6; i+=$8} END {print p " passed, " f " failed, " i " ignored, in " NR " test binaries"}')
failed=$(grep -E '^test .* FAILED' "$R/1.3-tests.txt" | sed 's/^test //; s/ \.\.\. FAILED//' | sort -u | tr '\n' ' ')
crashed=$(grep -E "process didn't exit successfully|signal: " "$R/1.3-tests.txt" | head -3 | tr '\n' ' ')
grep -E '^test .* ignored' "$R/1.3-tests.txt" | sort -u >> "$L"
nf=$(echo "$tot" | awk '{print $3}')
v=FAIL; [ $rc -eq 0 ] && [ "$nf" = "0" ] && v=pass
res "1.3 suite" "$v: commit $head; $tot; exit $rc, $(( secs/60 )) min${failed:+; failed: $failed}${crashed:+; crashed: $crashed}"
log "everyday folder newest file: $(everyday)"
fi

# ---------------------------------------------------------------- 1.4 A long search with a crash in the middle (240 min)
W="$R/1.4-watch.txt"; M="$R/1.4-memory.csv"; RATES="$T/1.4-rates.txt"
job=""; t0=$(now); lastmem=0; peak_fp=0; peak_rss=0
if [ -z "$P1_JOB" ]; then
    log "== 1.4 explore, 240 minutes, detached"
    echo "time,wall_min,phase,elapsed_min,status,status_rss_gb,pid,ps_rss_mb,footprint_mb,cpu_pct" > "$M"; : > "$RATES"
fi
worker() { pgrep -f "jetcarp jobs resume $job --library" | head -1; }
# probe <phase> [save-as]: status JSON, the worker's RSS, CPU and footprint; a watch line each time, a memory row every 5 min
probe() {
    local phase="$1" save="$2" js="$T/probe.json" p rss="" cpu="" fp="" st el
    "$J" jobs status "$job" --json > "$js" 2>/dev/null
    [ -n "$save" ] && cp "$js" "$R/$save.json"
    p=$(worker)
    if [ -n "$p" ]; then
        read -r rss cpu <<< "$(ps -o rss=,%cpu= -p "$p")"; rss=$(( ${rss:-0} / 1024 ))
        footprint -f bytes --noCategories "$p" > "$T/fp.txt" 2>&1; fp=$($P1 footprint "$T/fp.txt")
        [ "${fp:-0}" -gt "$peak_fp" ] && peak_fp=$fp; [ "$rss" -gt "$peak_rss" ] && peak_rss=$rss
    fi
    local out; out=$($P1 status "$js")
    IFS='|' read -r PSTATUS PSTALE PRES PEL PRSS PRATE PLINE <<< "$out"
    case "$phase" in run|resumed) [ -n "$PRATE" ] && echo "$PRATE" >> "$RATES";; esac
    echo "$(date -u +%T) +$(( ($(now)-t0)/60 )) min [$phase] pid ${p:--} rss ${rss:--} MB fp ${fp:--} MB cpu ${cpu:--} | status $PSTATUS, stale $PSTALE, resumable $PRES, elapsed $PEL min, rss $PRSS GB | $PLINE" >> "$W"
    if [ -n "$save" ] || [ $(( $(now)-lastmem )) -ge 295 ]; then
        lastmem=$(now)
        echo "$(date -u +%FT%TZ),$(( ($(now)-t0)/60 )),$phase,$PEL,$PSTATUS,$PRSS,${p},${rss},${fp},${cpu}" >> "$M"
    fi
}
# capture <tag>: footprint (by category) and vmmap --summary of the worker, kept only if both read it
capture() {
    local tag="$1" p; p=$(worker); [ -z "$p" ] && { log "capture $tag: no worker"; return 1; }
    local hdr="== $(date -u +%FT%TZ), +$(( ($(now)-t0)/60 )) min wall, search elapsed $PEL min, pid $p"
    { echo "$hdr"; footprint "$p"; } > "$T/cap-fp.txt" 2>&1; local a=$?
    { echo "$hdr"; vmmap --summary "$p"; } > "$T/cap-vm.txt" 2>&1; local b=$?
    if [ $a -eq 0 ] && [ $b -eq 0 ] && grep -q 'Physical footprint' "$T/cap-vm.txt"; then
        mv "$T/cap-fp.txt" "$R/1.4-footprint-$tag.txt"; mv "$T/cap-vm.txt" "$R/1.4-vmmap-$tag.txt"
        [ "$tag" != end ] && log "capture $tag: $(grep -m1 'Footprint:' "$R/1.4-footprint-$tag.txt" | sed 's/.*Footprint:/footprint/; s/ (.*//'), $(grep -m1 'Physical footprint:' "$R/1.4-vmmap-$tag.txt" | tr -s ' ')"
        return 0
    fi
    log "capture $tag failed (footprint exit $a, vmmap exit $b)"; return 1
}
el_ge() { awk -v a="${PEL:-0}" -v b="$1" 'BEGIN {exit !(a+0 >= b)}'; }

if [ -z "$P1_JOB" ]; then
    "$J" search explore --minutes 240 --label long --detach --json > "$R/1.4-start.json" 2> "$R/1.4-start.err"
    rc=$?; job=$($P1 get "$R/1.4-start.json" job); [ -z "$job" ] && job=2
    t0=$(now)
    sleep 10
    log "explore start exit $rc; job $job; processes: $(procs)"
else
    job=$P1_JOB; t0=$P1_T0
    peak_rss=$(awk -F, 'NR>1 && $8+0>m {m=$8+0} END {print m+0}' "$M"); peak_fp=$(awk -F, 'NR>1 && $9+0>m {m=$9+0} END {print m+0}' "$M")
    log "== 1.4 adopted: explore job $job, started $(date -u -r "$t0" +%T) UTC ($(( ($(now)-t0)/60 )) min ago); processes: $(procs)"
fi

# Phase A: run for about an hour, a probe a minute, then footprint and vmmap, then kill -9.
while [ $(( $(now)-t0 )) -lt 3600 ]; do
    probe run
    [ -z "$(worker)" ] && { log "the search's process is gone before the kill"; break; }
    sleep 55
done
probe "before kill" 1.4-status-before-kill
mem1h="$PRSS GB (status), ps rss ${peak_rss} MB peak so far"
capture 1h; fp1h=$(grep -m1 'Footprint:' "$R/1.4-footprint-1h.txt" 2>/dev/null | sed 's/.*Footprint: //; s/ (.*//')
"$J" jobs status "$job" > "$R/1.4-status-before-kill.txt" 2>&1
"$J" jobs list --json > "$R/1.4-list-before-kill.json" 2>&1
victims=$(pgrep -f "jetcarp jobs resume $job --library" | tr '\n' ' ')
log "before the kill: $(head -1 "$R/1.4-status-before-kill.txt"); kill -9: $victims ($(procs))"
pkill -9 -f "jetcarp jobs resume $job --library"; tk=$(now); tkf=$(python3 -c 'import time; print(time.time())')
# #49: status should say stale within seconds.
obs=""; first_stale=""
for at in 1 3 5 10 20 30; do
    while python3 -c "import sys,time; sys.exit(0 if time.time()-$tkf < $at else 1)"; do sleep 0.2; done
    sec=$(python3 -c "import time; print(f'{time.time()-$tkf:.1f}')")
    probe "after kill +$at s" "1.4-status-kill-$at"
    if [ -z "$first_stale" ] && { [ "$PSTALE" = "True" ] || [[ "$PSTATUS" == *stale* ]]; }; then first_stale=$sec; fi
    obs="$obs +$sec s: status $PSTATUS, stale $PSTALE, resumable $PRES /"
done
"$J" jobs list --json > "$R/1.4-list-after-kill.json" 2>&1
"$J" jobs list > "$R/1.4-list-after-kill.txt" 2>&1
listrow=$($P1 listrow "$R/1.4-list-after-kill.json" "$job")
"$J" jobs status "$job" > "$R/1.4-status-after-kill.txt" 2>&1
"$J" jobs wait "$job" --timeout 180 > "$R/1.4-wait-after-kill.txt" 2>&1; wk=$?
log "after the kill:$obs jobs list: $listrow; jobs wait exit $wk at +$(( $(now)-tk )) s"
v=FAIL; [ -n "$first_stale" ] && awk -v s="$first_stale" 'BEGIN {exit !(s <= 10)}' && v=pass
res "1.4 #49 stale" "$v: first stale at ${first_stale:-never in 30 s}${first_stale:+ s};$obs jobs list after 30 s: $listrow; jobs wait exit $wk (6 = gone)"

# Phase B: resume detached with no --minutes (#51), and jobs wait straight after (#50 wants 5).
s=$(now); "$J" jobs resume "$job" --detach > "$R/1.4-resume.txt" 2>&1; rrc=$?; rsecs=$(( $(now)-s ))
"$J" jobs wait "$job" --timeout 2 > "$R/1.4-wait-after-resume.txt" 2>&1; w50=$?
rs=$(now)
says=$(tr -s ' \n' ' ' < "$R/1.4-resume.txt")
log "resume exit $rrc in $rsecs s, says: $says; jobs wait --timeout 2 straight after: exit $w50; processes: $(procs)"
v=FAIL; [ $w50 -eq 5 ] && v=pass
res "1.4 #50 wait" "$v: jobs wait --timeout 2 straight after jobs resume --detach exited $w50 (want 5); the resume exited $rrc in $rsecs s"
sleep 5
endrc=""; capped=0; got2h=0; got3h=0; lastcap=0
while [ $(( $(now)-rs )) -lt 12000 ]; do
    probe resumed
    if [ -n "$(worker)" ]; then
        if [ $got2h -eq 0 ] && el_ge 120; then capture 2h && got2h=1; fi
        if [ $got3h -eq 0 ] && el_ge 180; then capture 3h && got3h=1; fi
        # the end: every minute from 230 min of search, else every 5 minutes, so the last is close to the end
        if el_ge 230 || [ $(( $(now)-lastcap )) -ge 295 ]; then capture end && lastcap=$(now); fi
    fi
    "$J" jobs wait "$job" --timeout 60 --quiet > /dev/null 2>&1; wr=$?
    [ $wr -eq 5 ] && continue
    if [ $wr -eq 6 ] && [ -n "$(worker)" ]; then log "jobs wait said gone (6) while a worker runs: $(procs)"; sleep 30; continue; fi
    endrc=$wr; break
done
if [ -z "$endrc" ]; then
    capped=1; log "still running 200 min after the resume: jobs stop"
    capture end; "$J" jobs stop "$job" >> "$L" 2>&1; "$J" jobs wait "$job" --timeout 300 > /dev/null 2>&1; endrc="cut ($?)"
fi
tend=$(now)
probe end 1.4-status-end
"$J" jobs status "$job" > "$R/1.4-status-end.txt" 2>&1
log "1.4 ended: wait exit $endrc, $(( (tend-rs)/60 )) min after the resume, $(( (tend-t0)/60 )) min after the start; processes: $(procs)"
log "end capture: $(head -1 "$R/1.4-footprint-end.txt" 2>/dev/null) $(grep -m1 'Footprint:' "$R/1.4-footprint-end.txt" 2>/dev/null | sed 's/.*Footprint:/footprint/; s/ (.*//')"
F="$R/1.4-status-end.json"
el=$($P1 get "$F" progress.elapsed_s); elmin=$(awk -v e="${el:-0}" 'BEGIN {printf "%.1f", e/60}')
ns=$($P1 get "$F" progress.screened); nc=$($P1 get "$F" progress.confirmed); sce=$($P1 get "$F" progress.confirmed_elites)
"$J" jobs runs "$job" --limit 0 --format csv --out "$T/1.4-runs-search-1.csv" > /dev/null 2>&1
"$J" jobs runs "$job" --stage 2 --limit 0 --format csv --out "$T/1.4-runs-search-2.csv" > /dev/null 2>&1
s1=$(( $(wc -l < "$T/1.4-runs-search-1.csv") - 1 )); s2=$(( $(wc -l < "$T/1.4-runs-search-2.csv") - 1 ))
nrates=$(wc -l < "$RATES" | tr -d ' '); zero=$(grep -cx '0' "$RATES"); med=$(median < "$RATES")
m2=$(awk -F, 'NR>1 && $9!="" && $4!="" {d=$4-120; if (d<0) d=-d; if (best=="" || d<best) {best=d; row=$4" min: status "$6" GB, ps rss "$8" MB, footprint "$9" MB"}} END {print row}' "$M")
mend=$(awk -F, 'NR>1 && $9!="" && $4!="" {row=$4" min: status "$6" GB, ps rss "$8" MB, footprint "$9" MB"} END {print row}' "$M")
res "1.4 run" "$((ns+nc)) runs (screened $ns + confirmation $nc; csv $s1 + $s2); $nrates probes, $zero at 0/s, median ${med}/s; status $($P1 get "$F" status), elapsed $elmin min"
res "1.4 #53 memory" "at the kill: $mem1h, footprint ${fp1h:-?}; at ~2 h: $m2; at the end: $mend; peaks: ps rss $peak_rss MB, footprint $peak_fp MB (rc.2's Mac: 5.5 GB at the kill, 7.5 GB at the end)"
v=FAIL; [ $capped -eq 0 ] && awk -v e="$elmin" 'BEGIN {exit !(e >= 228 && e <= 252)}' && v=pass
res "1.4 #51 budget" "$v: the resume ended by itself: $([ $capped -eq 0 ] && echo yes || echo no) (wait exit $endrc), $(( (tend-rs)/60 )) min after it; search time in all $elmin min (want ~240); the resume said: $says"

# The pack, with no jobs seal, and an import into a fresh library (#35, #54).
log "== 1.4 pack export (no jobs seal) and import into a fresh library"
"$J" pack key --name "rc.3 test publisher" > "$R/1.4-key.txt" 2>&1; log "pack key exit $?"
rm -rf "$T/rc3-long" "$T/import"
s=$(now); "$J" pack export --to "$T/rc3-long" --feed rc3-long --no-media > "$R/1.4-export.txt" 2>&1; erc=$?
size="$(du -sh "$T/rc3-long" 2>/dev/null | cut -f1 | tr -d ' ')"
log "export exit $erc, $(( $(now)-s )) s; size $size"
sealmsg=$(grep -i -m1 'seal' "$R/1.4-export.txt")
"$J" pack check "$T/rc3-long" > "$R/1.4-check.txt" 2>&1; crc=$?
mkdir -p "$T/import"
s=$(now); "$J" pack import "$T/rc3-long" --library "$T/import/library.sqlite" > "$R/1.4-import.txt" 2>&1; irc=$?
log "pack check exit $crc; import exit $irc, $(( $(now)-s )) s"
"$J" jobs list --library "$T/import/library.sqlite" > "$R/1.4-import-jobs.txt" 2>&1
"$J" jobs list --library "$T/import/library.sqlite" --json > "$R/1.4-import-jobs.json" 2>&1
ij=$($P1 listjob "$R/1.4-import-jobs.json" explore)
log "imported explore job: ${ij:-not found}"; cat "$R/1.4-import-jobs.txt" >> "$L"
i1=-1; i2=-1; ice=""; samer="not compared"
if [ -n "$ij" ]; then
    "$J" jobs runs "$ij" --library "$T/import/library.sqlite" --limit 0 --format csv --out "$T/1.4-runs-import-1.csv" > /dev/null 2>&1
    "$J" jobs runs "$ij" --library "$T/import/library.sqlite" --stage 2 --limit 0 --format csv --out "$T/1.4-runs-import-2.csv" > /dev/null 2>&1
    i1=$(( $(wc -l < "$T/1.4-runs-import-1.csv") - 1 )); i2=$(( $(wc -l < "$T/1.4-runs-import-2.csv") - 1 ))
    "$J" jobs status "$ij" --library "$T/import/library.sqlite" --json > "$R/1.4-import-status.json" 2>&1
    "$J" jobs status "$ij" --library "$T/import/library.sqlite" > "$R/1.4-import-status.txt" 2>&1
    ice=$($P1 get "$R/1.4-import-status.json" progress.confirmed_elites)
    samer="stage 1 $($P1 samerows "$T/1.4-runs-search-1.csv" "$T/1.4-runs-import-1.csv"); stage 2 $($P1 samerows "$T/1.4-runs-search-2.csv" "$T/1.4-runs-import-2.csv")"
fi
v=FAIL; [ $erc -eq 0 ] && [ $crc -eq 0 ] && [ $irc -eq 0 ] && [ "$s1" -gt 0 ] && [ "$i1" = "$s1" ] && [ "$i2" = "$s2" ] && [[ "$samer" == "stage 1 True; stage 2 True" ]] && v=pass
res "1.4 pack #35" "$v: pack $size, export exit $erc ('$sealmsg'), check $crc, import $irc; runs: search $s1 + $s2, import $i1 + $i2; same rows: $samer"
v=FAIL; [ -n "$sce" ] && [ "$sce" = "$ice" ] && v=pass
res "1.4 #54 confirmed" "$v: confirmed elites, search $sce, import ${ice:-?}"

log "everyday folder newest file: $(everyday) (at the start: $EVERY0); which jetcarp: $(which jetcarp) ($(jetcarp --version 2>&1))"
log "jetcarp processes left: $(procs)"
EVERY1="$(everyday)"; v=FAIL; [ "$EVERY1" = "$EVERY0" ] && v=pass
res "everyday folder" "$v: newest file $EVERY1 (at the start: $EVERY0); jetcarp left running: $(procs | tr -d ';' | wc -w | tr -d ' ') processes"
log "== Phase 1 ends"
cat "$SUM" >> "$L"
