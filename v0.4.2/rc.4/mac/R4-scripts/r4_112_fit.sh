#!/usr/bin/env bash
# R4 #112: Fit to this computer is hidden in 0.4.2. (The Framework's r4_2_fit.sh, for the Mac, plus a run
# on the real desktop.) rc.3's own host.json from this Mac (~/jetcarp-rc-042c/config/host.json: a Fit
# sweep's saved sizes for the built-in display, canvas 4112x2658, and for the Q3277, 2560x1440) is copied
# into a test folder.
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf ~/jetcarp-rc4/homes/fit
. "$D/lib.sh" fit
RC3=~/jetcarp-rc-042c/config/host.json
echo "R4 #112 Fit hidden, the Mac, $(ts); test folder \$H = homes/fit; the default host is stopped"
echo
echo "#### The command line"
run "\$J host --help | grep -i -n -E 'tune|fit' || echo 'no tune or fit in host --help'"
run "\$J host tune"
run "\$J host tune --json"
run "\$J host help tune | head -12"
run "\$J host tune --help | head -12"
echo "#### MCP: tools/list's host_control, and tune called anyway"
run "python3 \$R/R4-scripts/mcall.py \$R/112-mcp.jsonl '[[\"host_control\",{\"action\":\"tune\"}],[\"host_control\",{\"action\":\"tune\",\"pick\":\"recommended\"}],[\"host_control\",{\"action\":\"tune_stop\"}]]' --tool-schema host_control | grep -v -E '^\s+\"(description|title)\"'"
run "grep -c -i 'tune' \$R/112-mcp.jsonl; grep -o '\"enum\": *\[[^]]*\]' \$R/112-mcp.jsonl | head -3"
echo "#### rc.3's host.json, with the warning accepted"
run "\$J setup --yes --seizure-warning no-disorder"
mkdir -p "$H/config"; cp "$RC3" "$H/config/host.json"
shasum -a 256 "$H/config/host.json" > "$H/host.json.sha256"
run "python3 -c 'import json,sys; d=json.load(open(sys.argv[1]))
for i, s in enumerate(d[\"screens\"]):
    t = s[\"tuning\"]; print(\"screen\", i, \"monitor\", s[\"monitor\"], s[\"rotation\"], \"place\", s[\"place\"], \"tuning canvas\", t[\"canvas\"], len(t[\"scenes\"]), \"scenes\")
    for x in t[\"scenes\"][:12]: print(\"  %-30s own %-6s saved Fit %-10s\" % (x[\"scene\"], str(x[\"design_px\"]) + \" px\", \"%.2f px\" % x[\"cell_px\"]))
    if len(t[\"scenes\"]) > 12: print(\"  ... and\", len(t[\"scenes\"]) - 12, \"more; saved Fit sizes in all:\", sorted(set(round(x[\"cell_px\"], 2) for x in t[\"scenes\"])), \"own:\", sorted(set(x[\"design_px\"] for x in t[\"scenes\"])))' \$H/config/host.json"
cycle() {   # status line 2 now, then `host next` 7 times
  for i in 1 2 3 4 5 6 7 8; do
    run "\$J host status | sed -n 2p"
    [ $i -lt 8 ] && run "\$J host next >/dev/null; sleep 2"
  done
}
echo "### (a) host start --headless (its canvas: 1280x720)"
run "\$J host start --headless"
sleep 3
cycle
run "\$J host status --json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(json.dumps(d, indent=1)[:2500])'"
echo "(host_control tune with a host running)"
run "python3 \$R/R4-scripts/mcall.py \$R/112-mcp-running.jsonl '[[\"host_control\",{\"action\":\"tune\"}],[\"host_control\",{\"action\":\"status\"}]]'"
run "\$J host stop"
sleep 2
echo "### (b) host serve --headless --canvas 4112x2658 (the canvas screen 0's sizes were saved for), in the background"
( cd "$H" && nohup "$J" host serve --headless --canvas 4112x2658 > "$H/serve-4112.log" 2>&1 & )
sleep 5
cycle
run "\$J host stop"
sleep 2
run "cat \$H/serve-4112.log"
echo "### (c) host start on the desktop: screen 0 is the built-in display (3456x2234), as in rc.3's file"
run "\$J host start"
sleep 6
cycle
run "\$J host status"
run "\$J host stop"
sleep 2
run hosts
echo "#### host.json after: was it rewritten, and are rc.3's saved sizes still in it (for 0.4.3)?"
run "shasum -a 256 -c \$H/host.json.sha256 2>&1; python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print([(i, bool(s.get(\"tuning\")), len((s.get(\"tuning\") or {}).get(\"scenes\", []))) for i, s in enumerate(d[\"screens\"])])' \$H/config/host.json"
echo "(Not checked here: a monitor change starts no fit; it needs Jimmie to change the display's resolution.)"
