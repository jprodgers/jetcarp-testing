#!/bin/bash
# 2.9 (M9): library soup and the scripts. Each spaceship's rebuilt soup is run and its census read at
# 50–2,500 generations, looking for the ship's id in the census (the Acer's check).
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
STEP=2.9; SHOW=14; source "$R/lib2.sh"
mkdir -p "$R/2.9-soups"
JC 60 library list --class spaceship --limit 10; cp "$O/$n.out" "$R/2.9-list.txt"
JC 60 library list --class spaceship --limit 10 --json; cp "$O/$n.out" "$R/2.9-list.json"
ids=$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); d=d.get("patterns", d.get("items", d)) if isinstance(d,dict) else d; print(" ".join(str(x.get("id")) for x in d))' "$R/2.9-list.json")
L "spaceships: $ids"
for id in $ids; do JC 120 library soup "$id" --save "$R/2.9-soups/${id:0:8}.json"; done
python3 - "$J" "$R/2.9-soups" $ids > "$R/2.9-scan.txt" 2>&1 <<'PY'
import json, subprocess, sys
J, D, ids = sys.argv[1], sys.argv[2], sys.argv[3:]
for i in ids:
    seen = []
    for g in (50, 100, 200, 400, 800, 1200, 1600, 2000, 2500):
        p = subprocess.run([J, "objects", f"{D}/{i[:8]}.json", "--gens", str(g), "--json"], capture_output=True, text=True)
        txt = p.stdout
        seen.append(f"{g}:{'yes' if i[:16] in txt or i[:8] in txt else 'no'}")
    print(i[:8], " ".join(seen))
PY
cat "$R/2.9-scan.txt" >> "$LOG"
first=$(echo $ids | awk '{print $1}')
mws=$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); d=d.get("patterns", d.get("items", d)) if isinstance(d,dict) else d; m=[x for x in d if "MWSS" in json.dumps(x)]; print((m or d)[0]["id"])' "$R/2.9-list.json")
L "--best 3 on $mws"
JC 600 library soup "$mws" --best 3 --save "$R/2.9-best.json"; ls "$R"/2.9-best*.json >> "$LOG"
( cd "$T" && rm -rf 2.9-script && mkdir 2.9-script && cd 2.9-script && "$J" script --example jaca-territories > "$R/2.9-jaca-territories.txt" 2>&1; echo "script exit $?" >> "$R/2.9-jaca-territories.txt"; ls >> "$R/2.9-jaca-territories.txt" )
cat "$R/2.9-jaca-territories.txt" >> "$LOG"
L "done"
