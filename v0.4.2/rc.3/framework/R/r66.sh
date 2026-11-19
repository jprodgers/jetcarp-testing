#!/usr/bin/env bash
# R on the Framework (rc.3): #66 alone, after r_cli.sh's explores ended.
set -u
. "$(dirname "$0")/env.sh"
cd "$W/cli"
{
echo "#### jobs first (none may be running)"; "$J" jobs list 2>&1 | head -4
echo "#### #66 a signed pack, then a tampered copy and an unsigned copy"
"$J" pack export --to "$W/cli/good66" --feed r66 --no-media > export66.txt 2>&1; echo "export exit $?"; tail -2 export66.txt
cp -a "$W/cli/good66" "$W/cli/onebyte66"; cp -a "$W/cli/good66" "$W/cli/unsigned66"
python3 - "$W/cli/onebyte66/pack.json" <<'PY'
import sys; p=sys.argv[1]; b=bytearray(open(p,"rb").read()); j=b.find(b'"r66"'); assert j>0; b[j+3]=ord("7"); open(p,"wb").write(b)
PY
find "$W/cli/unsigned66/sigs" -type f -delete
for n in good66 onebyte66 unsigned66; do echo "-- pack info $n"; "$J" pack info "$W/cli/$n" 2>&1 | head -8; echo "exit ${PIPESTATUS[0]}"; done
for n in onebyte66 unsigned66; do echo "-- pack import $n"; "$J" pack --library "$W/cli/imp-$n.sqlite" import "$W/cli/$n" 2>&1 | tail -3; echo "exit ${PIPESTATUS[0]}"; done
} > "$(dirname "$0")/r-66.txt" 2>&1
