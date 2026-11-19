#!/usr/bin/env bash
# R5 on the Mac (rc.5's release build), unattended: #128 (host tune's help) and #124 (host login on with the
# JETCARP_* folders set), in a test folder of its own (homes/r5cli).
# #124 registers with launchd, which starts a host with the DEFAULT folders (rc.4's #103 row: "registered with launchd,
# which started the host"). Each time, that host is stopped first and login then turned off, so the job goes at once
# (rc.4's #99: it stays loaded until logout only when login goes off with the host running). A control without the
# variables follows. `dflt CMD` runs CMD with no JETCARP_* variable, so in the default folders.
# Run:  bash R5-scripts/r5_cli.sh > R5-cli.txt
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf ~/jetcarp-rc5/homes/r5cli
. "$D/lib.sh" r5cli
LA=gui/$(id -u)/com.jimmieprodgers.jetcarp.host
PL=$HOME/Library/LaunchAgents/com.jimmieprodgers.jetcarp.host.plist
dflt() { env -u JETCARP_CONFIG_DIR -u JETCARP_DATA_DIR -u JETCARP_OUT -u JETCARP_LIBRARY -u JETCARP_RUNTIME_DIR "$@"; }
job() {
  launchctl print "$LA" > "$H/job.txt" 2>&1; local rc=$?
  grep -E '^\s*(state|pid|program|runs|last exit code|job state) = ' "$H/job.txt" | head -8
  echo "launchctl print $LA: exit $rc"
}
echo "R5 on the Mac, #128 and #124, $(ts); $($J --version); test folder \$H = homes/r5cli"
echo

echo "######## #128: host tune's help says only that Fit is held back"
run "\$J host tune --help"
run "\$J host help tune"
run "\$J host tune"

echo "######## #124: host login on with the JETCARP_* folders set"
run "env | grep '^JETCARP_' | sort"
echo "the warning answered in this test folder first (the first run left it out, and login on refused, naming the warning: R5-cli-1-warning-unanswered.txt)"
run "\$J setup --seizure-warning no-disorder --profile blank-slate --quickstart-minutes 0 --quiet"
echo "before: no login item, no host"
run "job; hosts; ls \$HOME/Library/LaunchAgents | grep -i jetcarp || echo 'no JETCARP plist'"
run "\$J host login on"
sleep 3
run "job; hosts"
run "plutil -p $PL"
echo "the host launchd started, seen with the default folders (dflt), and this test folder's (none):"
run "dflt \$J host status"
run "\$J host status"
echo "cleanup: the default host stopped first, then login off"
run "dflt \$J host stop"
run "\$J host login off"
sleep 3
run "job; hosts; ls $PL 2>&1"

echo "######## #124, control: host login on with no JETCARP_* variable (the default folders): no note expected"
run "dflt \$J setup --seizure-warning no-disorder --profile blank-slate --quickstart-minutes 0 --quiet"
run "dflt \$J host login on"
sleep 3
run "job; hosts"
run "dflt \$J host stop"
run "dflt \$J host login off"
sleep 3
run "job; hosts; ls $PL 2>&1"
echo "what launchd's default host left in the default settings folder (#134 runs next, and deletes it):"
run "ls -A \"\$HOME/Library/Application Support/jetcarp\" 2>&1"
echo "(done $(ts))"
