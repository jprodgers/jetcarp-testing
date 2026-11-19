#!/usr/bin/env bash
# R4-5 control: rc.3's build makes clips of a copy of the same job (homes/jaca copied to homes/jaca-rc3).
set -u
D=$(cd "$(dirname "$0")" && pwd)
W4=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc4
rm -rf $W4/homes/jaca-rc3; cp -a --reflink=auto $W4/homes/jaca $W4/homes/jaca-rc3; rm -rf $W4/homes/jaca-rc3/out/clips86
. "$D/lib.sh" jaca-rc3
J3=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc3/bin/jetcarp-0.4.2-rc.3-x86_64-unknown-linux-gnu/jetcarp
echo
echo "#### Control: rc.3's build (\$J3), the same job copied (home \$H = homes/jaca-rc3), the same command"
run "\$J3 --version; \$J3 jobs clips 1 --sample 48 --out \$H/out/clips86-rc3"
run "python3 -c 'import json,sys,collections; m=json.load(open(sys.argv[1])); print(dict(collections.Counter((c[\"category\"], c[\"fate\"]) for c in m)))' \$H/out/clips86-rc3/manifest.json"
