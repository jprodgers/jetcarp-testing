#!/usr/bin/env bash
# R5 #134 on the Mac: rc.5's installer's --uninstall names only the settings, data and picture folders still there
# (on macOS it looks at ~/Library/Application Support/jetcarp and ~/Pictures/JETCARP). No JETCARP_* variable is set,
# so JETCARP's folders follow HOME (`jetcarp paths` with a scratch HOME: all under it).
#   (a) a scratch HOME, the settings kept: install, setup, then --uninstall: names the settings folder only.
#   (b) the real HOME, the tester's way: install (downloading from GitHub), setup, `jetcarp uninstall --yes --settings
#       --data`, then --uninstall: names only ~/Pictures/JETCARP (three pictures kept from rc.3's testing).
#   (c) a scratch HOME, nothing left: as (b): no "kept" line at all.
#   (d) the real HOME: rc.5 installed again, for the rest of the wave.
# The installer is rc.5's own, checked against SHA256SUMS ($DL). The scratch installs take the release files from $DL.
# Run:  bash R5-scripts/r5_134_uninstall.sh > R5-134-uninstall.txt
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf ~/jetcarp-rc5/homes/i134
. "$D/lib.sh" i134      # run, sub, ts; then every JETCARP_* variable unset
unset JETCARP_CONFIG_DIR JETCARP_DATA_DIR JETCARP_OUT JETCARP_LIBRARY JETCARP_RUNTIME_DIR
DL=$HOME/jetcarp-rc5/dl/rc5
INST=$DL/jetcarp-installer.sh
AS="$HOME/Library/Application Support/jetcarp"
SETUP="setup --seizure-warning no-disorder --profile blank-slate --quickstart-minutes 0 --quiet"
echo "R5 #134 on the Mac, $(ts); rc.5's installer, sha256 $(shasum -a 256 "$INST" | cut -c1-16)…; no JETCARP_* variable set"
echo

echo "######## (a) a scratch HOME (\$H/kept/home), the settings kept"
K=$H/kept/home; mkdir -p "$K"
run "HOME=$K sh $INST --url $DL"
run "HOME=$K $K/.local/bin/jetcarp $SETUP | tail -1"
run "ls -A '$K/Library/Application Support/jetcarp'; ls -d $K/Pictures/JETCARP 2>&1"
run "HOME=$K sh $INST --uninstall"
run "ls -A $K; ls -A $K/.local 2>&1"

echo "######## (b) the real HOME, the tester's way"
run "ls -d ~/.local/lib/jetcarp ~/.local/bin/jetcarp \"$AS\" ~/Pictures/JETCARP 2>&1; ls -A \"$AS\" 2>&1"
run "sh $INST"
run "command -v jetcarp; jetcarp --version"
run "jetcarp $SETUP | tail -1"
run "jetcarp paths"
run "jetcarp uninstall --yes --settings --data"
run "ls -d ~/.local/lib/jetcarp ~/.local/bin/jetcarp \"$AS\" ~/Pictures/JETCARP 2>&1"
run "sh $INST --uninstall"
run "ls -d ~/.local/lib/jetcarp ~/.local/bin/jetcarp \"$AS\" 2>&1; ls ~/Pictures/JETCARP"

echo "######## (c) a scratch HOME (\$H/none/home), nothing left"
N=$H/none/home; mkdir -p "$N"
run "HOME=$N sh $INST --url $DL"
run "HOME=$N $N/.local/bin/jetcarp $SETUP | tail -1"
run "HOME=$N $N/.local/bin/jetcarp uninstall --yes --settings --data"
run "ls -A $N; ls -A $N/Library 2>&1"
run "HOME=$N sh $INST --uninstall"
run "ls -A $N; ls -A $N/.local 2>&1"

echo "######## (d) the real HOME: rc.5 installed again"
run "sh $INST --url $DL"
run "command -v jetcarp; jetcarp --version; ls -A \"$AS\" 2>&1"
echo "(done $(ts))"
