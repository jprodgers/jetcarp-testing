#!/usr/bin/env bash
# R4-5 (#86): JACA clips. A short JACA-only explore, then `jobs clips --sample 48`: runs that settled
# are Static, not Battles. On the CPU with 8 threads, as the parity runs use the GPU meanwhile.
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc4/homes/jaca
. "$D/lib.sh" jaca
echo "R4-5 #86 JACA clips, Framework, $(ts)"
echo "fresh home \$H = homes/jaca"
echo
run "\$J search explore --families jaca --minutes 3 --cpu --threads 8 --label jaca86 --quiet"
run "\$J jobs list"
JOB=$("$J" jobs list --label jaca86 --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); d=d if isinstance(d,list) else d.get("jobs",[]); print(d[0]["job"] if d else "")')
echo "job: $JOB"
run "\$J jobs status $JOB | head -20"
run "\$J jobs clips $JOB --sample 48 --out \$H/out/clips86"
run "ls \$H/out/clips86 | head; ls \$H/out/clips86 | wc -l"
echo "#### The manifest's categories, against each run's fate"
run "python3 - \$H/out/clips86/manifest.json <<'PY'
import json, sys, collections
m = json.load(open(sys.argv[1]))
clips = m if isinstance(m, list) else (m.get('clips') or m.get('runs') or m.get('items') or [])
print('manifest keys:', list(m)[:20] if isinstance(m, dict) else 'list')
print('clips:', len(clips))
if clips: print('first clip:', json.dumps(clips[0])[:700])
def g(c, *ks):
    for k in ks:
        if k in c: return c[k]
    return None
cat = collections.Counter(g(c, 'category', 'cat', 'bucket') for c in clips)
print('categories:', dict(cat))
x = collections.Counter((g(c, 'category', 'cat', 'bucket'), g(c, 'fate')) for c in clips)
print('category x fate:')
for (k, f), n in sorted(x.items(), key=lambda t: str(t)): print(f'   {k!s:16} {f!s:10} {n}')
fam = collections.Counter(g(c, 'family', 'fam') for c in clips)
print('families:', dict(fam))
bad = [c for c in clips if g(c, 'category', 'cat', 'bucket') == 'Battles' and g(c, 'fate') not in ('running', 'capped')]
print('Battles whose run settled (should be none):', len(bad))
PY"
