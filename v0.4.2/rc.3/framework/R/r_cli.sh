#!/usr/bin/env bash
# R on the Framework (rc.3): the command-line rows #47, #57, #66, #67. Every folder is under $W (env.sh).
set -u
. "$(dirname "$0")/env.sh"
mkdir -p "$W/cli"; cd "$W/cli"
say() { echo; echo "#### $*"; }
{
say "#47 explore --limit help"
"$J" search explore --help | grep -A2 -- '--limit'

say "#57 pack export refuses a running search; a refused export leaves no folder"
"$J" search hunt --rules B3/S23 --tilings square --soups 300 --quiet >/dev/null 2>&1; echo "hunt exit $?"
"$J" search explore --detach --minutes 3 --label r57 2>&1 | tail -1
sleep 5
"$J" jobs list 2>&1 | head -5
"$J" pack export --to "$W/cli/p57" --feed r57 --no-media; echo "export exit $?"
[ -e "$W/cli/p57" ] && echo "FOLDER LEFT: $(ls -a $W/cli/p57)" || echo "no p57 folder: ok"
ls -a "$W/cli" | grep -i p57 || echo "no .p57.store either: ok"
J57=$("$J" jobs list --label r57 --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); d=d if isinstance(d,list) else d.get("jobs",[]); print(d[0]["job"] if d else "")')
echo "stopping job $J57"; "$J" jobs stop "$J57" 2>&1 | tail -1; "$J" jobs wait "$J57" --timeout 60 >/dev/null 2>&1; echo "wait exit $?"

say "#57 b: a search paused, nothing stored yet (a fresh explore stopped at once)"
"$J" search explore --detach --minutes 1 --label r57b 2>&1 | tail -1
J57B=$("$J" jobs list --label r57b --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); d=d if isinstance(d,list) else d.get("jobs",[]); print(d[0]["job"] if d else "")')
"$J" pack export --to "$W/cli/p57b" --feed r57b --no-media; echo "export while running exit $?"
[ -e "$W/cli/p57b" ] && echo "FOLDER LEFT" || echo "no p57b folder: ok"
"$J" jobs stop "$J57B" 2>&1 | tail -1; "$J" jobs wait "$J57B" --timeout 60 >/dev/null 2>&1

say "#66 a signed pack, then a tampered copy and an unsigned copy"
"$J" pack export --to "$W/cli/good" --feed r66 --no-media 2>&1 | tail -1; echo "export exit $?"
rm -rf "$W/cli/onebyte" "$W/cli/unsigned"; cp -a "$W/cli/good" "$W/cli/onebyte"; cp -a "$W/cli/good" "$W/cli/unsigned"
python3 - "$W/cli/onebyte/pack.json" <<'PY'
import sys; p=sys.argv[1]; b=bytearray(open(p,"rb").read()); j=b.find(b'"r66"'); assert j>0; b[j+3]=ord("7"); open(p,"wb").write(b)
PY
find "$W/cli/unsigned/sigs" -type f -delete
for n in good onebyte unsigned; do echo "-- pack info $n"; "$J" pack info "$W/cli/$n" 2>&1 | head -8; echo "exit $?"; done
for n in onebyte unsigned; do echo "-- pack import $n"; "$J" pack --library "$W/cli/imp-$n.sqlite" import "$W/cli/$n" 2>&1 | tail -3; echo "exit $?"; done

say "#67 a malformed rule names its CA and file; a read-only library can be read"
cat > bad-rule.json <<'J2'
{"format":1,"name":"bad rule","tiling":{"family":"square","size":{"rect":{"w":32,"h":32}},"boundary":"wrap"},"rng_state":3,
 "cas":[{"id":1,"name":"Lifeish","rule":"B3/S23/Q9 Frobnicate","seed":{"random":{"density":0.3}}}]}
J2
"$J" run bad-rule.json --gens 5; echo "exit $?"
"$J" verify bad-rule.json; echo "exit $?"
cp "$W/library/library.sqlite" ro.sqlite 2>/dev/null || cp "$W/data/library.sqlite" ro.sqlite
chmod 444 ro.sqlite
"$J" library --library ro.sqlite list 2>&1 | head -4; echo "exit ${PIPESTATUS[0]}"
chmod 644 ro.sqlite
} > "$R/r-cli.txt" 2>&1
