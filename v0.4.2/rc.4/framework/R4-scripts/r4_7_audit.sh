#!/usr/bin/env bash
# R4-7: from rc.3's book audit (bdc8730). (a) `host status` for a screen a hold froze says held, and
# the reason isn't doubled; (b) `jobs resume --detach` of a stopped job answers once its process
# has the job, with timings.
set -u
D=$(cd "$(dirname "$0")" && pwd)
W4=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc4
rm -rf $W4/homes/held $W4/homes/resume
. "$D/lib.sh" held
echo "R4-7 from rc.3's audit (bdc8730), Framework, $(ts)"
echo
echo "#### (a) A host held by the unanswered seizure warning: fresh home \$H = homes/held"
echo "(host start is refused there, so the host runs as \`host serve --headless\` in the background, which holds every screen until the warning is answered)"
run "test -e \$H/config/photosensitivity.json && echo answered || echo 'warning not answered'"
( cd "$H" && nohup "$J" host serve --headless > "$H/serve.log" 2>&1 & )
sleep 4
run "\$J host status"
run "\$J host status --json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(\"held:\", d[\"held\"], \"| held_why:\", d[\"held_why\"], \"| paused:\", d[\"paused\"], \"| paused_why:\", d[\"paused_why\"]); s=d[\"screens\"][0][\"stage\"]; print(\"screen 0 stage paused:\", s[\"paused\"], \"generation:\", s[\"generation\"])'"
sleep 3
run "\$J host status | sed -n 2p"
echo "(the generation stays put while held: compare the two screen lines)"
run "\$J host status | grep -o -i 'held' | wc -l; \$J host status | grep -i -E 'held|warning'"
echo "### Paused by hand as well, then the pause taken off"
run "\$J host pause"
run "\$J host status | head -4"
run "\$J host resume"
run "\$J host status | head -4"
run "\$J host stop"
sleep 2
run hosts
run "cat \$H/serve.log"

. "$D/lib.sh" resume
echo "#### (b) jobs resume --detach of a stopped job: fresh home \$H = homes/resume"
run "\$J search explore --families jaca --detach --minutes 10 --cpu --threads 4 --label r7b"
sleep 4
JOB=$("$J" jobs list --label r7b --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); d=d if isinstance(d,list) else d.get("jobs",[]); print(d[0]["job"] if d else "")')
for round in 1 2 3; do
  echo "### round $round"
  run "\$J jobs stop $JOB"
  run "\$J jobs wait $JOB --timeout 120 | head -1"
  run "\$J jobs status $JOB | head -2"
  run "\$J jobs resume $JOB --detach"
  run "\$J jobs status $JOB | head -2; \$J jobs status $JOB --json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(\"status:\", d[\"status\"], \"| stale:\", d[\"stale\"], \"| updated:\", d[\"updated\"])'; pgrep -a -f \"\$J (jobs|search)\" | sub"
  sleep 4
done
run "\$J jobs stop $JOB"
run "\$J jobs wait $JOB --timeout 120 | head -1"
run "\$J jobs list"
run "pgrep -a -f \"jobs resume $JOB\" || echo 'no resumed process left'"
