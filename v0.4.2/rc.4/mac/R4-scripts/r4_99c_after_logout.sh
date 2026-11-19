#!/usr/bin/env bash
# R4 #99 (part 3), after logout 3: launchd's job is gone and no host started at login. Default folders.
set -u
D=$(cd "$(dirname "$0")" && pwd)
. "$D/lib.sh" --default
cd ~
PL=~/Library/LaunchAgents/com.jimmieprodgers.jetcarp.host.plist
LBL=gui/$UID/com.jimmieprodgers.jetcarp.host
echo "R4 #99 after logout 3, the Mac, $(ts)"
echo
run "last -5 \$USER | head -5"
run "launchctl print $LBL > /dev/null 2>&1; echo \"launchctl print exit \$?\""
run "ls -l $PL 2>&1"
run "pgrep -fl 'jetcarp host serve' || echo 'no host process running'"
run "jetcarp host status 2>&1 | head -2"
run "jetcarp doctor | sed -n '/^Desktop/,/^\$/p'"
