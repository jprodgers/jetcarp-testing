#!/bin/bash
# rc.5 on the Framework, run on the host (the VS Code sandbox lost the GPU after the 7:33 session switch):
# the suite on the tag in a scratch home, then both parity sets with the release build.
W5=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc5
S=$1
export CARGO_HOME=/home/jimmie/.cargo RUSTUP_HOME=/home/jimmie/.rustup
export PATH=/home/jimmie/.cargo/bin:/usr/bin:/bin
. $W5/env.sh suite-host >/dev/null
$J doctor 2>&1 | grep -A1 "^  compute" | head -2
cd /home/jimmie/Documents/GitHub/jetcarp
echo "suite on $(git log --oneline -1) from $(date +%T)"
timeout 3000 cargo test --workspace --release --no-fail-fast > $S/suite-rc5-host.log 2>&1
echo "suite exit $?"
grep -E "^test result" $S/suite-rc5-host.log | awk '{p+=$4; f+=$6; i+=$8} END {print "passed", p, "failed", f, "ignored", i}'
echo "warnings: $(grep -c '^warning' $S/suite-rc5-host.log)"
grep -E "FAILED|panicked" $S/suite-rc5-host.log | head -5
echo "parity from $(date +%T)"
bash $W5/parity.sh
echo "parity exit $?"
