#!/usr/bin/env bash
# R4 #99 (last bullet) and #103: login on, the host running; `jetcarp uninstall` shows its plan; `--yes --settings
# --data` stops the host first, so launchd's job goes at once, deletes the folders without FAILED, and names the one
# command that removes the program; then rc.4's own installer (~/jetcarp-rc4/dl/rc4, checked against SHA256SUMS at the
# start of the wave) with --uninstall says what it removed. Default folders, through the PATH link.
set -u
D=$(cd "$(dirname "$0")" && pwd)
. "$D/lib.sh" --default
cd ~
PL=~/Library/LaunchAgents/com.jimmieprodgers.jetcarp.host.plist
LBL=gui/$UID/com.jimmieprodgers.jetcarp.host
SET="$HOME/Library/Application Support/jetcarp"
echo "R4 #99 and #103, uninstall, the Mac, $(ts); $(jetcarp --version); installed at $(readlink ~/.local/bin/jetcarp)"
echo
echo "#### login on: the host running, as a tester has it"
run "jetcarp host login on"
sleep 3
run "jetcarp host status | head -2; launchctl print $LBL > /dev/null 2>&1; echo \"launchctl print exit \$?\""
run "ls -A \"$SET\"; ls -A \"$SET/data\" 2>/dev/null | head; ls -A ~/.cache/jetcarp 2>/dev/null"
echo "#### jetcarp uninstall (the plan only)"
run "jetcarp uninstall"
echo "#### jetcarp uninstall --yes --settings --data"
run "jetcarp uninstall --yes --settings --data"
run "launchctl print $LBL > /dev/null 2>&1; echo \"launchctl print exit \$? (at once)\"; ls -l $PL 2>&1; pgrep -fl 'jetcarp host serve' || echo 'no host process running'"
run "ls -A \"$SET\" 2>&1; ls -A ~/.cache/jetcarp 2>&1; ls -A ~/Pictures/JETCARP 2>&1 | head -5"
run "ls -l ~/.local/bin/jetcarp ~/.local/lib/jetcarp 2>&1 | head -4; which jetcarp; jetcarp --version"
echo "#### rc.4's installer, --uninstall"
run "sh ~/jetcarp-rc4/dl/rc4/jetcarp-installer.sh --uninstall"
run "ls -l ~/.local/bin/jetcarp ~/.local/lib/jetcarp 2>&1; which jetcarp || echo 'jetcarp: not on the PATH'"
run "ls -A ~/.local/lib 2>&1 | head; ls -A ~/.local/bin 2>&1 | head"
echo "#### the installer's --uninstall again, with nothing installed"
run "sh ~/jetcarp-rc4/dl/rc4/jetcarp-installer.sh --uninstall"
