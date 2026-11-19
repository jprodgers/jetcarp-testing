#!/usr/bin/env bash
# R5 on the Framework (rc.5's release build), the rows that are the Framework's:
# #125 (host_control: an unknown action; resume before the warning), #126 (book pages over MCP),
# #128 (host tune --help) and #124 (login on with JETCARP_* folders set). Each in its own scratch home.
set -u
D=$(cd "$(dirname "$0")" && pwd)
W5=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc5
rm -rf $W5/homes/r5a $W5/homes/r5b
. "$D/lib.sh" r5a
export J R H
echo "R5 on the Framework, $(ts); $($J --version)"
echo
echo "######## #128: host tune's help says only that Fit is held back"
run "\$J host tune --help"
run "\$J host help tune"
run "\$J host tune"
echo "######## #126: book pages over MCP read <id> and L<level>, no &lt;"
run "cd \$D && python3 mcall.py \$R/R5-126-mcp.jsonl '[[\"help\",{\"page\":\"reference/mcp\"}]]' --maxlog 300 | grep -o -E 'L&lt;level>|L<level>|find:&lt;id>|find:<id>' | sort | uniq -c"
run "cd \$D && python3 mcall.py \$R/R5-126-res.jsonl '[]' --resource jetcarp://docs/reference/mcp --maxlog 300 | head -4"
run "cd \$D && python3 - <<'PY'
import json, mcpc
m = mcpc.Mcp('$R/R5-126-read.jsonl', maxlog=300); m.init()
t = m.request('resources/read', {'uri': 'jetcarp://docs/reference/mcp'})['result']['contents'][0]['text']
print('L<level>:', t.count('L<level>'), ' find:<id>:', t.count('find:<id>'), ' &lt; left:', t.count('&lt;'))
PY"
echo "######## #125: host_control, the warning not yet answered (a fresh settings folder), no host running"
run "cd \$D && python3 mcall.py \$R/R5-125-mcp.jsonl '[[\"host_control\",{\"action\":\"start\"}],[\"host_control\",{\"action\":\"wallpaper\"}],[\"host_control\",{\"action\":\"resume\"}]]' --maxlog 400"
run "\$J host resume"
echo "######## #125 again with the warning answered"
run "\$J setup --seizure-warning no-disorder"
run "cd \$D && python3 mcall.py \$R/R5-125b-mcp.jsonl '[[\"host_control\",{\"action\":\"start\"}],[\"host_control\",{\"action\":\"wallpaper\"}]]' --maxlog 400"
echo "######## #124: host login on with the JETCARP_* folders set (the entry goes to this home's XDG folder)"
run "\$J host login on"
run "ls \$XDG_CONFIG_HOME/autostart/"
run "\$J host login off"
echo "(done $(ts))"
