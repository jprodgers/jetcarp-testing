#!/bin/bash
# 2.8 (M8): rules, names and progress (the Acer's 2.8-steps.ps1 in bash).
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
STEP=2.8; SHOW=14; source "$R/lib2.sh"
JC 120 search try --tiling square --rule "B47/S13568V/4"
JC 120 search try --tiling square --rule "B3/S23V/C4"
JC 120 search try --tiling square --rule "B4v7/S2"
# The two V rules again, saved, to read the neighbourhood from the scene.
JC 120 search try --tiling square --rule "B47/S13568V/4" --json --save "$R/2.8-B47_S13568V_4.json"
JC 120 search try --tiling square --rule "B3/S23V/C4" --json --save "$R/2.8-B3_S23V_C4.json"
for f in 2.8-B47_S13568V_4.json 2.8-B3_S23V_C4.json; do
    L "  $f cas: $(python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1])).get("cas"), separators=(",",":")))' "$R/$f" 2>&1)"
done
printf 'B3/S23\nB36/S23\nB4x/S2\nB2/S\n' > "$R/2.8-rules.txt"
JC 120 jobs list --json; before=$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); d=d.get("jobs",d) if isinstance(d,dict) else d; print(max(j["job"] for j in d))' "$O/$n.out")
JC 120 search hunt --rules "" --rules-file "$R/2.8-rules.txt" --soups 20
JC 600 search hunt --rules B3/S23,B36/S23,B2/S34 --tilings square,hex --soups 30 --label groups; g=$(jobid)
L "newest job before the bad rules file: $before; the groups hunt is job $g (so the refused hunt made no job: $([ "$g" = "$((before+1))" ] && echo yes || echo no))"
L "groups progress lines: $(tr '\r' '\n' < "$O/$n.err" | grep groups | tail -2 | tr '\n' '|')"
JC 60 jobs list
L "done"
