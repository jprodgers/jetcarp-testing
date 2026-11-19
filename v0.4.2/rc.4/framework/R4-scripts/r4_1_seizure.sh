#!/usr/bin/env bash
# R4-1 (#96): the photosensitive seizure warning, in a fresh scratch home.
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc4/homes/seizure
. "$D/lib.sh" seizure
export J R H
echo "R4-1 #96 the photosensitive seizure warning, Framework, $(ts)"
echo "fresh home \$H = homes/seizure"
echo
echo "#### Before the warning is answered"
run "ls -A \$H/config; test -e \$H/config/photosensitivity.json && echo present || echo 'no photosensitivity.json'"
run "\$J setup --status"
run "\$J host start --headless"
run "\$J host wallpaper on"
run "\$J host login on"
run "\$J host saver install"
echo "(host serve --saver runs with DISPLAY and WAYLAND_DISPLAY unset, so that it couldn't open a full-screen window on the real desktop were it not refused; the refusal comes before any window in the code)"
run "nodisp \$J host serve --saver --seconds 1"
run hosts
echo "#### Nothing was left by the refusals"
run "ls -A \$H/config \$H/xdg/config; ls -A \$H/xdg/config/autostart 2>&1 | head -3"
echo "#### MCP host_control (jetcarp mcp): tools/list, then the actions that start or show scenes"
echo "(host_control has no 'start' action in its schema; it is called anyway. 'open_app' is not called: it opens the app)"
run "python3 \$R/R4-scripts/mcall.py \$R/R4-1-mcp.jsonl '[[\"host_control\",{\"action\":\"start\"}],[\"host_control\",{\"action\":\"wallpaper\",\"on\":true}],[\"host_control\",{\"action\":\"login\",\"on\":true}],[\"host_control\",{\"action\":\"resume\"}],[\"host_control\",{\"action\":\"next\"}],[\"host_control\",{\"action\":\"rotation\",\"name\":\"A classic a day\"}],[\"host_control\",{\"action\":\"status\"}]]' --tool-schema host_control"
echo "#### Answer it: setup --yes --seizure-warning no-disorder (no profile: only the answer is saved)"
run "\$J setup --yes --seizure-warning no-disorder"
run "ls -lA \$H/config"
run "cat \$H/config/photosensitivity.json"
run "\$J setup --status | head -20"
echo "#### Now the host starts"
run "\$J host start --headless"
sleep 3
run "\$J host status"
run hosts
run "\$J host stop"
sleep 2
run hosts
run "\$J host status"
echo "#### MCP host_control after the answer (no host running): the warning no longer refuses; the call reaches for the host"
run "python3 \$R/R4-scripts/mcall.py \$R/R4-1-mcp-after.jsonl '[[\"host_control\",{\"action\":\"next\"}]]'"
echo "(wallpaper on, login on and saver install after the answer are not run here: the Framework's rules allow them only where a refusal is expected)"
