#!/usr/bin/env bash
# R4 #99 (part 2): `jetcarp host login off` with the host running: the host is left running, and launchd's job is
# gone after the next logout (logout 3, Jimmie; checked by r4_99c_after_logout.sh). Default folders, through the PATH link.
set -u
D=$(cd "$(dirname "$0")" && pwd)
. "$D/lib.sh" --default
cd ~
PL=~/Library/LaunchAgents/com.jimmieprodgers.jetcarp.host.plist
LBL=gui/$UID/com.jimmieprodgers.jetcarp.host
echo "R4 #99 login off with the host running, the Mac, $(ts); $(jetcarp --version)"
echo
run "jetcarp host status | head -2"
run "launchctl print $LBL | grep -E '^\s+(state|pid|program) =|job state' ; echo \"launchctl print exit \${PIPESTATUS[0]}\""
run "ls -l $PL; grep -c 'Registered with launchd' $PL"
echo "#### login off, the host running"
run "jetcarp host login off"
sleep 3
run "jetcarp host status | head -2"
run "pgrep -fl 'jetcarp host serve' || echo 'no host process running'"
run "launchctl print $LBL 2>&1 | grep -E '^\s+(state|pid|program) =|job state|Could not find' ; echo \"launchctl print exit \${PIPESTATUS[0]}\""
run "ls -l $PL 2>&1"
