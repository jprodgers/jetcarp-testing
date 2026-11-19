#!/usr/bin/env bash
# R4-2 (#112): Fit to this computer is hidden in 0.4.2.
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc4/homes/fit
. "$D/lib.sh" fit
export J R H
CARDS=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc3/cards/config/jetcarp/host.json
echo "R4-2 #112 Fit hidden, Framework, $(ts)"
echo "fresh home \$H = homes/fit"
echo
echo "#### The command line"
run "\$J host --help | grep -i -n -E 'tune|fit' || echo 'no tune or fit in host --help'"
run "\$J host tune"
run "\$J host tune --json"
run "\$J host help tune"
echo "#### MCP: tools/list's host_control, and tune called anyway"
run "python3 \$R/R4-scripts/mcall.py \$R/R4-2-mcp.jsonl '[[\"host_control\",{\"action\":\"tune\"}],[\"host_control\",{\"action\":\"tune\",\"pick\":\"recommended\"}],[\"host_control\",{\"action\":\"tune_stop\"}],[\"host_control\",{\"action\":\"tune_events\"}],[\"host_control\",{\"action\":\"tuning\"}]]' --tool-schema host_control | grep -v -E '^\s+\"(description|title)\"'"
run "grep -c -i 'tune' \$R/R4-2-mcp.jsonl; grep -o '\"enum\": *\[[^]]*\]' \$R/R4-2-mcp.jsonl | head -3"
echo "#### rc.3's cards host.json (a Fit sweep's saved sizes, canvas 2560x1440), with the warning accepted"
run "\$J setup --yes --seizure-warning no-disorder"
cp "$CARDS" "$H/config/host.json"
sha256sum "$H/config/host.json" > "$H/host.json.sha256"
run "python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); s=d[\"screens\"][0]; t=s[\"tuning\"]; print(\"screen 0:\", s[\"rotation\"], \"place\", s[\"place\"], \"tuning canvas\", t[\"canvas\"]); [print(\"  %-38s own %-9s saved Fit %-9s\" % (x[\"scene\"], str(x[\"design_px\"])+\" px\", str(x[\"cell_px\"])+\" px\")) for x in t[\"scenes\"]]' \$H/config/host.json"
echo "### (a) host start --headless (its canvas: 1280x720)"
run "\$J host start --headless"
sleep 3
for i in 1 2 3 4 5 6 7; do
  run "\$J host status | sed -n 2p"
  run "\$J host next >/dev/null; sleep 2"
done
run "\$J host status"
run "\$J host status --json"
echo "(host_control tune with a host running)"
run "python3 \$R/R4-scripts/mcall.py \$R/R4-2-mcp-running.jsonl '[[\"host_control\",{\"action\":\"tune\"}],[\"host_control\",{\"action\":\"start\"}],[\"host_control\",{\"action\":\"status\"}]]'"
run "\$J host stop"
sleep 2
echo "### (b) host serve --headless --canvas 2560x1440 (the canvas the sizes were saved for), in the background"
( cd "$H" && nohup "$J" host serve --headless --canvas 2560x1440 > "$H/serve-2560.log" 2>&1 & )
sleep 5
for i in 1 2 3 4 5 6 7; do
  run "\$J host status | sed -n 2p"
  run "\$J host next >/dev/null; sleep 2"
done
run "\$J host status --json"
run "\$J host stop"
sleep 2
run hosts
run "cat \$H/serve-2560.log"
echo "#### host.json after: was it rewritten, and are rc.3's saved sizes still in it (for 0.4.3)?"
run "sha256sum -c \$H/host.json.sha256 2>&1; python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); t=d[\"screens\"][0].get(\"tuning\"); print(\"tuning kept:\", bool(t), \"scenes:\", len(t[\"scenes\"]) if t else 0)' \$H/config/host.json"
echo "(Not checked here: a monitor change starts no fit; it needs a desktop.)"
