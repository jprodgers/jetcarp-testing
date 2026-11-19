#!/usr/bin/env bash
# R4 #84 (doctor with the GPU off tests no adapter) and #85 (`jetcarp paths` names the runtime folder).
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf ~/jetcarp-rc4/homes/doctor
. "$D/lib.sh" doctor
echo "R4 #84 and #85, the Mac, $(ts); \$J = rc.4's release build ($($J --version)); test folder \$H = homes/doctor"
echo
echo "#### #84: JETCARP_GPU=off jetcarp doctor"
run "JETCARP_GPU=off \$J doctor"
run "JETCARP_GPU=off \$J doctor | grep -n -i -E 'adapter|metal|M2 Max|gpu|self-test'"
run "JETCARP_GPU=off \$J doctor --json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(json.dumps({k: v for k, v in d.items() if \"gpu\" in k.lower() or \"adapter\" in k.lower()}, indent=1)[:3000])'"
echo "#### for comparison: doctor with the GPU setting as it is (automatic)"
run "\$J doctor | grep -n -i -E 'adapter|metal|M2 Max|gpu|self-test'"
run "ls \$H/config 2>/dev/null; ls \$H/data 2>/dev/null"
echo "#### #85: jetcarp paths, in the test folder"
run "\$J paths"
run "\$J paths --json"
echo "#### #85: jetcarp paths, in the default folders (no JETCARP_* variable)"
run "env -u JETCARP_CONFIG_DIR -u JETCARP_DATA_DIR -u JETCARP_OUT -u JETCARP_LIBRARY -u JETCARP_RUNTIME_DIR \$J paths"
run "env -u JETCARP_CONFIG_DIR -u JETCARP_DATA_DIR -u JETCARP_OUT -u JETCARP_LIBRARY -u JETCARP_RUNTIME_DIR \$J paths --json"
