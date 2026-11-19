#!/bin/bash
# rc.4 pre-check on the Mac (NOTES, 2026-11-16 12:30 PM EST), unattended:
#   build release-0.4.2 (af07766), answer the seizure warning, parity 1.1 (371 × 300) and 1.2 (40 × 5,000) on Metal,
#   the whole suite on Metal, then soak.sh (1.5, 8 h). Each step carries on if one before failed.
#   Commits and pushes results/v0.4.2-rc4-pre/mac after each step.
# Run as: caffeinate -is bash pre.sh
export P="$HOME/jetcarp-rc4-pre"
export JETCARP_CONFIG_DIR="$P/config" JETCARP_DATA_DIR="$P/data" JETCARP_OUT="$P/out" JETCARP_RUNTIME_DIR="$P/runtime"
unset JETCARP_GPU WGPU_BACKEND JETCARP_LIBRARY
SRC="$HOME/jetcarp-rc-042c/src"
J="$P/bin/jetcarp"
REPO=/Users/Jimmie/Documents/GitHub/jetcarp-rc
R="$REPO/results/v0.4.2-rc4-pre/mac"
L="$R/pre.log"; SUM="$R/summary.txt"
mkdir -p "$P/bin" "$P/config" "$P/data" "$P/out" "$P/runtime"; cd "$P" || exit 1
: > "$SUM"

log() { echo "$(date -u +%FT%TZ) $*" >> "$L"; }
res() { echo "$1: $2" >> "$SUM"; log "RESULT $1: $2"; }
now() { date +%s; }
push() {   # commit and push this folder; never fails the script
    ( cd "$REPO" && git add "results/v0.4.2-rc4-pre/mac" && \
      git commit -q -m "$1

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" && \
      git pull -q --rebase --autostash && git push -q ) >> "$L" 2>&1 || log "push: failed (see above)"
}
lim() { perl -e 'alarm shift; exec @ARGV' "$@"; }   # lim <seconds> cmd...

# ---------------------------------------------------------------- build
log "== build $(git -C "$SRC" log --oneline -1)"
s=$(now); ( cd "$SRC" && cargo build --release -p jetcarp ) > "$R/build.txt" 2>&1; rc=$?
cp -f "$SRC/target/release/jetcarp" "$J"
warn=$(grep -c '^warning' "$R/build.txt")
res "build" "commit $(git -C "$SRC" rev-parse --short HEAD); exit $rc in $(( $(now)-s )) s, $warn warning lines; $("$J" --version 2>&1); sha256 $(shasum -a 256 "$J" | cut -c1-16)…"

# ---------------------------------------------------------------- the seizure warning's answer, then doctor
log "== setup --seizure-warning no-disorder"
{ echo "\$ jetcarp setup --seizure-warning no-disorder"; lim 60 "$J" setup --seizure-warning no-disorder < /dev/null 2>&1; echo "exit $?"; } > "$R/setup.txt"
src=$(tail -1 "$R/setup.txt")
if [ "$src" != "exit 0" ]; then
    { echo; echo "\$ jetcarp setup --yes --seizure-warning no-disorder   (the first didn't exit 0)"; lim 60 "$J" setup --yes --seizure-warning no-disorder < /dev/null 2>&1; echo "exit $?"; } >> "$R/setup.txt"
fi
res "setup" "$(grep -E '^exit' "$R/setup.txt" | tr '\n' ' '); config: $(ls "$P/config" | tr '\n' ' ')"
lim 120 "$J" doctor > "$R/doctor.txt" 2>&1; rc=$?
res "doctor" "exit $rc; $(grep -m1 -i 'self-test' "$R/doctor.txt" | sed 's/^ *//'); $(grep -m1 -iE 'gpu|adapter' "$R/doctor.txt" | sed 's/^ *//')"
push "Mac: rc.4 pre-check: the branch built (af07766), the seizure warning answered"

# ---------------------------------------------------------------- 1.1 and 1.2 Parity, Metal
rm -rf "$P/parity"; cp -R "$REPO/parity" "$P/parity"
for part in "1.1|$P/parity|300|371 scenes: CPU matches 371, GPU matches 371" "1.2|$P/parity/long|5000|40 scenes: CPU matches 40, GPU matches 40"; do
    IFS='|' read -r step dir gens wantp <<< "$part"
    log "== $step parity, $gens generations, Metal"
    s=$(now); python3 "$P/parity/parity.py" "$J" "$dir" "$R/$step-metal.csv" --gens "$gens" > "$R/$step-metal.txt" 2>&1; rc=$?
    last=$(grep 'scenes: CPU matches' "$R/$step-metal.txt" | tail -1); mism=$(grep -c '^MISMATCH' "$R/$step-metal.txt")
    v=FAIL; case "$last" in "$wantp"*) [ "$mism" -eq 0 ] && [ $rc -eq 0 ] && v=pass;; esac
    res "$step parity" "$v: $last; $mism MISMATCH lines; exit $rc, $(( $(now)-s )) s"
done
push "Mac: rc.4 pre-check: parity 1.1 and 1.2 on Metal"

# ---------------------------------------------------------------- 1.3 The whole suite (a scratch HOME, no JETCARP_* variables)
log "== 1.3 cargo test --release --workspace --no-fail-fast"
rm -rf "$P/test-home"; mkdir -p "$P/test-home"
s=$(now)
( cd "$SRC" && env -u JETCARP_CONFIG_DIR -u JETCARP_DATA_DIR -u JETCARP_OUT -u JETCARP_RUNTIME_DIR \
    HOME="$P/test-home" CARGO_HOME="$HOME/.cargo" RUSTUP_HOME="$HOME/.rustup" \
    cargo test --release --workspace --no-fail-fast ) > "$R/1.3-tests.txt" 2>&1
rc=$?; secs=$(( $(now)-s ))
tot=$(grep -E '^test result' "$R/1.3-tests.txt" | awk '{p+=$4; f+=$6; i+=$8} END {print p " passed, " f " failed, " i " ignored, in " NR " test binaries"}')
failed=$(grep -E '^test .* FAILED' "$R/1.3-tests.txt" | sed 's/^test //; s/ \.\.\. FAILED//' | sort -u | tr '\n' ' ')
crashed=$(grep -E "process didn't exit successfully|signal: " "$R/1.3-tests.txt" | head -3 | tr '\n' ' ')
grep -E '^test .* ignored' "$R/1.3-tests.txt" | sort -u > "$R/1.3-ignored.txt"
nf=$(echo "$tot" | awk '{print $3}')
v=FAIL; [ $rc -eq 0 ] && [ "$nf" = "0" ] && v=pass
res "1.3 suite" "$v: commit $(git -C "$SRC" rev-parse --short HEAD); $tot; exit $rc, $(( secs/60 )) min${failed:+; failed: $failed}${crashed:+; crashed: $crashed}"
push "Mac: rc.4 pre-check: the suite on Metal"

# ---------------------------------------------------------------- 1.5 the soak
log "== soak.sh"
exec bash "$R/soak.sh"
