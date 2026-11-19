#!/bin/bash
# R4 #96, the command line and MCP, in a fresh settings folder (~/jetcarp-rc4/w96): each command refused before the
# answer, naming the warning; nothing started, registered or installed. Then setup's answer, and each command again.
J="$HOME/.local/lib/jetcarp/jetcarp"; W="$HOME/jetcarp-rc4/w96"; R="$(dirname "$0")"
rm -rf "$W"; mkdir -p "$W"
export JETCARP_CONFIG_DIR="$W/config" JETCARP_DATA_DIR="$W/data" JETCARP_OUT="$W/out" JETCARP_RUNTIME_DIR="$W/runtime"
PL="$HOME/Library/LaunchAgents/com.jimmieprodgers.jetcarp.host.plist"
state() { echo "  [state: default host pid $(pgrep -f '\.local/bin/jetcarp host serve' | tr '\n' ' '); test-folder hosts $(pgrep -f "jetcarp host serve" | wc -l | tr -d ' ') in all; plist md5 $(md5 -q "$PL" | cut -c1-8); screen savers: $(ls "$HOME/Library/Screen Savers" 2>/dev/null | tr '\n' ' ')]"; }
run() { echo "\$ $*   [$(date +%T)]"; "$@" 2>&1 | sed 's/^/  /'; echo "  exit ${PIPESTATUS[0]}"; }
echo "# R4 #96, fresh settings folder $W ($(jetcarp --version 2>&1)): before the answer"
state
run "$J" setup --status
for c in "host start" "host wallpaper on" "host login on" "host saver install" "host start --saver" "host serve --saver --seconds 3"; do
    run "$J" $c; state
done
echo "\$ MCP host_control (jetcarp mcp), wallpaper on, login on, status"
python3 "$R/mcpcall.py" "$J" call host_control '{"action":"wallpaper","on":true}' call host_control '{"action":"login","on":true}' call host_control '{"action":"status"}' 2>&1 | sed 's/^/  /'
state
echo "  config folder: $(ls "$W/config" 2>/dev/null | tr '\n' ' ')"
echo
echo "# the answer"
run "$J" setup --seizure-warning no-disorder
run cat "$W/config/photosensitivity.json"
echo
echo "# after the answer: each again"
run "$J" host wallpaper on; state
run "$J" host start; sleep 3; state
run "$J" host status
run "$J" host login on; sleep 3; state
run "$J" host saver install; state
run "$J" host start --saver
run "$J" host serve --saver --seconds 3; state
echo "\$ MCP host_control (jetcarp mcp), wallpaper on, login on"
python3 "$R/mcpcall.py" "$J" call host_control '{"action":"wallpaper","on":true}' call host_control '{"action":"login","on":true}' 2>&1 | sed 's/^/  /'
state
echo
echo "# undone: the saver removed, the test host stopped; the default host and login item as before"
run "$J" host saver remove
run "$J" host stop; sleep 2; state
run launchctl print "gui/$UID/com.jimmieprodgers.jetcarp.host" 2>&1 | grep -E 'job state|pid =|program ='
