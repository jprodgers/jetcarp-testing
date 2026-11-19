#!/bin/bash
# 2.4 (M4): the smart JACA search, parents from job 2 (no reviews, so its best runs: #25); its status at ~13 s and
# at the end; the runs by origin; the sign_* measures filled for JACA runs.
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
"$J" search explore --gpu --families jaca --parents-from 2 --reviewed keep,maybe --minutes 6 --label smart-jaca > "$R/2.4-explore.out" 2> "$R/2.4-explore.err" &
ex=$!
sleep 13
"$J" jobs status 3 > "$R/2.4-status-13s.txt" 2>&1
wait $ex; echo "explore exit $?" >> "$R/2.4-explore.out"
"$J" jobs status 3 > "$R/2.4-status.txt" 2>&1
"$J" jobs status 3 --json > "$R/2.4-status.json" 2>&1
"$J" jobs runs 3 --limit 0 --format csv --out "$T/2.4-runs.csv" > /dev/null 2>&1
"$J" jobs runs 3 --limit 0 --measures all --format csv --out "$T/2.4-runs-measures.csv" > /dev/null 2>&1
python3 - "$T/2.4-runs.csv" "$T/2.4-runs-measures.csv" > "$R/2.4-origins.txt" <<'EOF'
import csv, sys
from collections import Counter
rows = list(csv.DictReader(open(sys.argv[1])))
c = Counter(r["origin"] for r in rows)
print(f"{len(rows)} runs by origin:")
for k, v in c.most_common():
    print(f"  {k:18} {v:6}  {100 * v / len(rows):5.1f}%")
m = list(csv.DictReader(open(sys.argv[2])))
sign = [k for k in (m[0].keys() if m else []) if k.startswith("sign_")]
jaca = [r for r in m if r["family"] == "jaca"]
filled = {k: sum(1 for r in jaca if r[k] not in ("", None)) for k in sign}
print(f"sign_* columns with --measures all: {sign}")
print(f"JACA runs: {len(jaca)}; filled per column: {filled}")
EOF
