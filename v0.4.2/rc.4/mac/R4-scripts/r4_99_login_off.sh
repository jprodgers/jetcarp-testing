#!/usr/bin/env bash
# R4 #99 (part): `jetcarp host login off` with the host stopped: launchd's job goes at once
# (`launchctl print` exits 113). The default folders, through the PATH link, as a tester would.
# (The host-running half needs a logout; it is left for a sitting with Jimmie.)
set -u
D=$(cd "$(dirname "$0")" && pwd)
. "$D/lib.sh" --default
cd ~
PL=~/Library/LaunchAgents/com.jimmieprodgers.jetcarp.host.plist
LBL=gui/$UID/com.jimmieprodgers.jetcarp.host
echo "R4 #99 login off with the host stopped, the Mac, $(ts); $(jetcarp --version)"
echo
run "jetcarp host status | head -2"
run "launchctl print $LBL | grep -E '^\s+(state|pid|program) =' ; echo \"launchctl print exit \${PIPESTATUS[0]}\""
run "ls -l $PL; plutil -p $PL; head -3 $PL"
echo "#### the host stopped"
run "jetcarp host stop"
sleep 3
run "jetcarp host status | head -2"
run "pgrep -fl 'jetcarp host serve' || echo 'no host process running'"
run "launchctl print $LBL | grep -E '^\s+(state|pid|program) =|job state' ; echo \"launchctl print exit \${PIPESTATUS[0]}\""
echo "#### login off"
run "jetcarp host login off"
run "launchctl print $LBL > /dev/null 2>&1; echo \"launchctl print exit \$?\""
run "launchctl print $LBL 2>&1 | head -3"
run "ls -l $PL 2>&1"
run "jetcarp host status | head -3"
run "pgrep -fl 'jetcarp host serve' || echo 'no host process running'"
sleep 5
run "launchctl print $LBL > /dev/null 2>&1; echo \"launchctl print exit \$? (5 s later)\"; pgrep -fl 'jetcarp host serve' || echo 'no host process running'"
