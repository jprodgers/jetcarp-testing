#!/bin/bash
# 2.10 (M10): packs with schema-2 runs. No jobs seal (#35); the imported line (#37); the same confirmed elites (R #54);
# exports that take a running search, with nothing stored and with runs stored, both refused and leaving no folder
# (R #57); M10-pack.zip for the other machines; the Acer's and the Framework's rc.2 packs imported here.
source /Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/env2.sh
STEP=2.10; SHOW=16; source "$R/lib2.sh"
REPO=/Users/Jimmie/Documents/GitHub/jetcarp-rc; P1="python3 $R/p1.py"; W="$T/2.10"; rm -rf "$W"; mkdir -p "$W"
JC 60 jobs status 3 --json; cp "$O/$n.out" "$W/src-status.json"
uuid=$($P1 get "$W/src-status.json" spec.uuid); folder=$($P1 get "$W/src-status.json" progress.folder)
L "job 3: uuid $uuid; .folder '$($P1 get "$W/src-status.json" folder)', progress.folder $folder; screened $($P1 get "$W/src-status.json" progress.screened) + confirmed $($P1 get "$W/src-status.json" progress.confirmed); confirmed elites $($P1 get "$W/src-status.json" progress.confirmed_elites)"
L "job 3's folder before the export: $(cd "$folder" && find . -type f -exec stat -f '%N %z' {} \; | tr '\n' ';')"
JC 300 jobs runs 3 --limit 0 --format csv --out "$W/src-1.csv"; JC 300 jobs runs 3 --stage 2 --limit 0 --format csv --out "$W/src-2.csv"
L "job 3 runs: stage 1 $(rows "$W/src-1.csv"), stage 2 $(rows "$W/src-2.csv")"
JC 60 pack key --name "RC tester (Mac)"
JC 600 pack export --to "$T/M10-pack" --feed rc-mac --title "rc.3 test, Mac" --search "$uuid" --no-media
L "pack: $(du -sk "$T/M10-pack" | cut -f1) KiB in $(find "$T/M10-pack" -type f | wc -l | tr -d ' ') files"
L "job 3's folder after the export: $(cd "$folder" && find . -type f -exec stat -f '%N %z' {} \; | tr '\n' ';')"
JC 600 pack check "$T/M10-pack"; cp "$O/$n.out" "$R/2.10-check.txt"; cat "$O/$n.err" >> "$R/2.10-check.txt"
mkdir -p "$W/import"
JC 600 pack import "$T/M10-pack" --library "$W/import/library.sqlite"; cat "$O/$n.out" "$O/$n.err" > "$R/2.10-import.txt"
JC 60 jobs list --library "$W/import/library.sqlite"; cp "$O/$n.out" "$R/2.10-import-jobs.txt"
JC 60 jobs list --library "$W/import/library.sqlite" --json; ij=$($P1 listjob "$O/$n.out" explore); L "imported explore job: $ij"
JC 60 jobs status "$ij" --library "$W/import/library.sqlite"
JC 60 jobs status "$ij" --library "$W/import/library.sqlite" --json; cp "$O/$n.out" "$W/imp-status.json"
JC 60 jobs runs "$ij" --library "$W/import/library.sqlite" --measures sign_balance,sign_sorted --limit 5
JC 300 jobs runs "$ij" --library "$W/import/library.sqlite" --limit 0 --format csv --out "$W/imp-1.csv"
JC 300 jobs runs "$ij" --library "$W/import/library.sqlite" --stage 2 --limit 0 --format csv --out "$W/imp-2.csv"
L "imported runs: stage 1 $(rows "$W/imp-1.csv"), stage 2 $(rows "$W/imp-2.csv")"
L "same rows (all columns but the id): stage 1 $($P1 samerows "$W/src-1.csv" "$W/imp-1.csv"); stage 2 $($P1 samerows "$W/src-2.csv" "$W/imp-2.csv")"
L "R #54: confirmed elites, search $($P1 get "$W/src-status.json" progress.confirmed_elites), import $($P1 get "$W/imp-status.json" progress.confirmed_elites)"

# R #57: a running search with nothing stored yet, then with runs stored: both refused, no --to folder left.
JC 60 search explore --families life_like --minutes 3 --detach --label running-export; rj=$(jobid); L "running search: job $rj"
JC 60 jobs status "$rj" --json; ru=$($P1 get "$O/$n.out" spec.uuid)
L "job $rj at once: status $($P1 get "$O/$n.out" status), runs $($P1 get "$O/$n.out" progress.screened)"
JC 120 pack export --to "$T/M10-running-empty" --feed rc-mac-running --search "$ru" --no-media
L "M10-running-empty exists afterwards: $([ -e "$T/M10-running-empty" ] && echo yes || echo no)"
sleep 40
JC 60 jobs status "$rj" --json; L "job $rj at +40 s: status $($P1 get "$O/$n.out" status), runs $($P1 get "$O/$n.out" progress.screened)"
JC 120 pack export --to "$T/M10-running" --feed rc-mac-running --search "$ru" --no-media
L "M10-running exists afterwards: $([ -e "$T/M10-running" ] && echo yes || echo no)"
JC 60 jobs stop "$rj"; JC 150 jobs wait "$rj" --timeout 120

# The zip for the other machines, unzipped again and checked.
rm -f "$R/M10-pack.zip"; ( cd "$T" && zip -qr "$R/M10-pack.zip" M10-pack )
L "M10-pack.zip $(du -k "$R/M10-pack.zip" | cut -f1) KiB, sha256 $(shasum -a 256 "$R/M10-pack.zip" | cut -d' ' -f1)"
rm -rf "$W/unzip"; mkdir -p "$W/unzip"; unzip -q "$R/M10-pack.zip" -d "$W/unzip"
JC 300 pack check "$W/unzip/M10-pack"

# The other machines' packs (rc.2's), each into its own fresh library.
for z in acer/A10-pack framework/F10-pack; do
    m=${z%%/*}; d=${z##*/}; zz="$REPO/results/v0.4.2-rc.2/$z.zip"
    rm -rf "$W/$m"; mkdir -p "$W/$m"; unzip -q "$zz" -d "$W/$m"
    pk=$(find "$W/$m" -name pack.json -maxdepth 3 | head -1); pk=${pk%/pack.json}; L "$m's pack ($zz): $pk"
    JC 300 pack check "$pk"
    JC 600 pack import "$pk" --library "$W/$m/library.sqlite"
    JC 60 jobs list --library "$W/$m/library.sqlite"
    JC 60 jobs list --library "$W/$m/library.sqlite" --json; mj=$($P1 listjob "$O/$n.out" explore)
    [ -n "$mj" ] && JC 60 jobs runs "$mj" --library "$W/$m/library.sqlite" --measures sign_balance,sign_sorted --limit 3
done
L "done"
