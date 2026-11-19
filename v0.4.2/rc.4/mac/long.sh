#!/bin/bash
# rc.4 wave on the Mac: parity 1.1 (371 x 300) and 1.2 (40 x 5,000) on Metal with the release's own build, then the
# whole suite on the tag v0.4.2-rc.4 (cf5cbdf). (The pre-check's pre.sh, these steps only.) No commits from here.
# Run as: caffeinate -is bash long.sh
REPO=/Users/Jimmie/Documents/GitHub/jetcarp-rc
R="$REPO/results/v0.4.2-rc4/mac"
P="$HOME/jetcarp-rc4/homes/long"
J="$HOME/jetcarp-rc4/rel/jetcarp-0.4.2-rc.4-aarch64-apple-darwin/jetcarp"
SRC="$HOME/jetcarp-rc-042c/src"
export JETCARP_CONFIG_DIR="$P/config" JETCARP_DATA_DIR="$P/data" JETCARP_OUT="$P/out" JETCARP_RUNTIME_DIR="$P/runtime"
unset JETCARP_GPU WGPU_BACKEND JETCARP_LIBRARY
rm -rf "$P"; mkdir -p "$P"; cd "$P" || exit 1
L="$R/long.log"; SUM="$R/long-summary.txt"; : > "$SUM"
log() { echo "$(date -u +%FT%TZ) $*" >> "$L"; }
res() { echo "$1: $2" >> "$SUM"; log "RESULT $1: $2"; }
now() { date +%s; }
log "== start; $("$J" --version); sha256 $(shasum -a 256 "$J" | cut -c1-16)…; source $(git -C "$SRC" log --oneline -1) ($(git -C "$SRC" describe --tags))"
"$J" setup --yes --seizure-warning no-disorder < /dev/null >> "$L" 2>&1
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
# ---------------------------------------------------------------- 1.3 The whole suite on the tag (a scratch HOME, no JETCARP_* variables)
log "== 1.3 cargo test --release --workspace --no-fail-fast, at $(git -C "$SRC" rev-parse --short HEAD)"
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
warn=$(grep -c '^warning' "$R/1.3-tests.txt")
nf=$(echo "$tot" | awk '{print $3}')
v=FAIL; [ $rc -eq 0 ] && [ "$nf" = "0" ] && v=pass
res "1.3 suite" "$v: commit $(git -C "$SRC" rev-parse --short HEAD); $tot; exit $rc, $(( secs/60 )) min $(( secs%60 )) s; $warn warning lines${failed:+; failed: $failed}${crashed:+; crashed: $crashed}"
log "== done"
