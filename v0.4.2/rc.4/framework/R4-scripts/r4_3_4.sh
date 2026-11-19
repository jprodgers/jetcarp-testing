#!/usr/bin/env bash
# R4-3 (#84) doctor with the GPU off; R4-4 (#85) paths names the runtime folder.
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc4/homes/doctor
. "$D/lib.sh" doctor
{
echo "R4-3 #84 doctor with the GPU off, Framework, $(ts)"
echo "fresh home \$H = homes/doctor"
echo
run "JETCARP_GPU=off \$J doctor"
run "ls -A \$H/config; cat \$H/config/gpu-checks.json 2>/dev/null || echo 'no gpu-checks.json written'"
run "JETCARP_GPU=off \$J doctor --json | python3 -m json.tool | head -80"
echo "#### For comparison: the same fresh home's doctor with the GPU left on (its GPU section only)"
run "\$J doctor | sed -n '/^GPU/,/^Graphics/p'"
} > "$R/R4-3-doctor-gpu-off.txt" 2>&1
{
echo "R4-4 #85 paths names the runtime folder, Framework, $(ts)"
echo "home \$H = homes/doctor"
echo
run "\$J paths"
run "\$J paths --json"
run "\$J --json paths"
echo "#### With JETCARP_RUNTIME_DIR unset (the default runtime folder)"
run "env -u JETCARP_RUNTIME_DIR \$J paths | grep -i runtime; env -u JETCARP_RUNTIME_DIR \$J paths --json"
} > "$R/R4-4-paths.txt" 2>&1
