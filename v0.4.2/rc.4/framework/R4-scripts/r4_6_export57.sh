#!/usr/bin/env bash
# R4-6 (#57): `pack export` of a running search is refused, and leaves nothing beside the target:
# neither the --to folder nor the hidden store (.<name>.store). Then, as a control, the same export
# once the search has stopped makes both.
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc4/homes/export57
. "$D/lib.sh" export57
echo "R4-6 #57 a refused export leaves nothing behind, Framework, $(ts)"
echo "fresh home \$H = homes/export57; the settings' pack folder (the rc.3 test publisher's key) copied from rc.3's test settings"
echo
cp -a /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc3/config/pack "$H/config/pack"
mkdir -p "$H/exp"
run "\$J search hunt --rules B3/S23 --tilings square --soups 300 --cpu --quiet | tail -2"
run "\$J search explore --families jaca --detach --minutes 5 --cpu --threads 4 --label r57"
sleep 5
run "\$J jobs list"
JOB=$("$J" jobs list --label r57 --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); d=d if isinstance(d,list) else d.get("jobs",[]); print(d[0]["job"] if d else "")')
echo "the running search: job $JOB"
run "ls -a \$H/exp"
echo "#### The export while the search runs"
run "\$J pack export --to \$H/exp/p57 --feed r57 --no-media"
run "ls -a \$H/exp"
run "\$J pack export --to \$H/exp/p57b --feed r57 --no-media --json"
run "ls -a \$H/exp; ls -a \$H | grep -i -E 'p57|store' || echo 'nothing named p57 or store in \$H either'"
echo "#### Stop the search, then the same export (control: it makes the folder and the hidden store)"
run "\$J jobs stop $JOB"
run "\$J jobs wait $JOB --timeout 120 | tail -2"
run "\$J jobs list"
run "\$J pack export --to \$H/exp/p57 --feed r57 --no-media | tail -4"
run "ls -a \$H/exp"
