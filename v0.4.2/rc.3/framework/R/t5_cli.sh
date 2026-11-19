#!/usr/bin/env bash
# F9 part 5, the command-line steps as they were run (5.1 odd files, 5.3 limits, 5.5 read-only output).
# The MCP sides are the t5*.py scripts. Every folder is under $W (env.sh); the original F10-pack is only copied.
set -u
. "$(dirname "$0")/env.sh"

## 5.1 odd scenes
mkdir -p "$W/odd"; cd "$W/odd"
cat > good.json <<'EOF'
{
  "format": 1,
  "name": "F9 good scene",
  "tiling": {"family": "square", "size": {"rect": {"w": 64, "h": 64}}, "boundary": "wrap"},
  "rng_state": 9,
  "cas": [{"id": 1, "name": "Life", "rule": "B3/S23", "seed": {"random": {"density": 0.3}}}]
}
EOF
"$J" run good.json --gens 100 --save good-saved.json
head -c 400 good-saved.json > truncated.json
python3 - <<'EOF'
import json
s = json.load(open("good-saved.json")); s["cas"][0]["rule"] = "B3/S23/Q9 Frobnicate"; s["name"] = "unknown rule"; s.pop("record", None); s["commands"] = []
json.dump(s, open("unknown-rule.json", "w"), indent=1)
s = json.load(open("good-saved.json")); s["cas"][0]["rule"] = "Frobnicator"; s.pop("record", None); s["commands"] = []
json.dump(s, open("unknown-rule-name.json", "w"), indent=1)
s = json.load(open("good-saved.json")); s["format"] = 2; s["jetcarp_version"] = "9.0.0"
json.dump(s, open("future-format.json", "w"), indent=1)
s["format"] = 99999999999
json.dump(s, open("future-format-huge.json", "w"), indent=1)
EOF
: > empty.json
for f in truncated unknown-rule unknown-rule-name future-format future-format-huge empty; do
  "$J" run $f.json --gens 10; echo "exit $?"; "$J" verify $f.json; echo "exit $?"
done > "$R/5.1-scenes-cli.txt" 2>&1

## 5.1 damaged packs: copies of f10/F10-pack (never the original)
P0=$HOME/Documents/jetcarp-dev/work/0.4.2-rc2/f10/F10-pack
mkdir -p "$W/packs"
for n in good truncated onebyte unsigned truncated-manifest onebyte-part; do cp -a "$P0" "$W/packs/$n"; done
cd "$W/packs"
f=truncated/searches/39fd769d-bfa3-492f-bcb3-1ffd617e203e/runs/part-000001.parquet; truncate -s $(( $(stat -c %s $f) / 2 )) $f
truncate -s 300 truncated-manifest/pack.json
python3 - <<'EOF'
b = bytearray(open("onebyte/pack.json", "rb").read()); j = b.find(b'"title":"rc.2') + len(b'"title":"rc.'); b[j] = ord("3"); open("onebyte/pack.json", "wb").write(b)
p = "onebyte-part/tables/rules/part-000001.parquet"; b = bytearray(open(p, "rb").read()); b[len(b) // 2] ^= 1; open(p, "wb").write(b)
EOF
# unsigned: publish always signs (it makes a key in an empty settings folder: 5.1-unsigned-publish.txt),
# so the unsigned pack is a copy whose sigs/ folder was emptied. other-signer: sigs/ holds only a
# signature by the F9 test key (ssh-keygen -Y sign -n jetcarp-manifest), not the publisher's.
find unsigned/sigs -type f -delete
# (then: pack info / check on each -> 5.1-packs-check.txt, 5.1-packs-unsigned-nosigs.txt;
#  pack --library $W/import-lib/library.sqlite import on each -> 5.1-packs-import.txt)

## 5.3 limits: doctor's 2 GiB buffers / 4 bytes = 536,870,912 cells; the program's lattice limit is 256,000,000
mkdir -p "$W/limits"; cd "$W/limits"
mk() { python3 -c "
import json,sys
json.dump({'format':1,'name':sys.argv[1],'tiling':{'family':'square','size':json.loads(sys.argv[2]),'boundary':'wrap'},'rng_state':5,'cas':[{'id':1,'name':'Life','rule':'B3/S23','seed':{'random':{'density':0.3}}}]}, open(sys.argv[1]+'.json','w'), indent=1)
" "$1" "$2"; }
mk max-16000x16000 '{"rect":{"w":16000,"h":16000}}'
mk over-16001x16000 '{"rect":{"w":16001,"h":16000}}'
mk over-37x6918919 '{"rect":{"w":37,"h":6918919}}'     # the smallest rect over 256M (256,000,001 is prime)
mk over-cells-256000001 '{"cells":256000001}'
for f in over-16001x16000 over-37x6918919 over-cells-256000001; do "$J" run $f.json --gens 1 --gpu; echo "exit $?"; done > "$R/5.3-over-limit.txt" 2>&1
python3 "$R/rss.py" "$J" run max-16000x16000.json --gens 20 --gpu
python3 "$R/rss.py" "$J" run max-16000x16000.json --gens 20 --cpu --threads 16

## 5.5 a read-only output folder
RO=$W/ro-out; mkdir -p "$RO"; chmod 555 "$RO"
export JETCARP_OUT=$RO
"$J" script tiny.rhai; "$J" script --example hexw-all; "$J" pile --grains 1000
"$J" wallpaper good.json --size 320x200; "$J" wallpaper life --size 320x200
"$J" media render --scene good.json --gens 5; "$J" run good.json --gens 5 --png "$RO/x.png"
chmod 755 "$RO"
