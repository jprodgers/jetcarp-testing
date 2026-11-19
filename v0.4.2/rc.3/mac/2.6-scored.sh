source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
"$J" search explore --gpu --families jaca --score "$R/2.6-model.json" --minutes 3 --label scored > "$R/2.6-scored.out" 2> "$R/2.6-scored.err"; echo "exit $?" >> "$R/2.6-scored.out"
"$J" jobs status 4 > "$R/2.6-status-4.txt" 2>&1
"$J" jobs runs 4 --measures all --format csv --limit 0 --out "$T/2.6-all.csv" > /dev/null 2>&1
"$J" jobs runs 4 --measures all --format json --limit 5 > "$R/2.6-five.json" 2>&1
