#!/usr/bin/env bash
# R4-0: upgrade from rc.3. A scratch home whose settings and data are copies of rc.3's test folders
# (as rc.3's Phase 1 used them: no JETCARP_LIBRARY, so the library is <data>/library.sqlite), then
# the rc.4 release build.
set -u
. "$(dirname "$0")/lib.sh" upgrade
unset JETCARP_LIBRARY
W3=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc3
echo "R4-0 upgrade from rc.3, Framework, $(ts)"
echo "home \$H = homes/upgrade; config and data copied from rc.3's work folder (\$W3 = \$W4/../0.4.2-rc3)"
echo
cp -a --reflink=auto "$W3/config/." "$H/config/"
cp -a --reflink=auto "$W3/data/." "$H/data/"
run "ls -a \$H/config \$H/data"
run "test -e \$H/config/photosensitivity.json && echo present || echo 'no photosensitivity.json (rc.3 never asked)'"
run "\$J --version"
run "\$J paths"
run "\$J doctor"
run "\$J library list | head -30"
run "\$J library list --json | python3 -c 'import json,sys; d=json.load(sys.stdin); d=d if isinstance(d,list) else d.get(\"patterns\", d.get(\"records\", d)); print(\"records listed:\", len(d))'"
run "\$J jobs list"
run "\$J host status"
run "\$J host status --json"
run "\$J host start --headless"
sleep 2
run "\$J host status"
run hosts
# In case it wasn't refused: stop it.
run "\$J host stop"
