#!/usr/bin/env bash
# R4-8 (#104): progress lines fit a 60-column terminal. A 30-second hunt (the case #104 reported), a
# 1-minute explore and a pack import (rc.3's 159 MB export of its 2-hour explore, copied into the
# scratch home), each in a 60x40 pseudo-terminal under `script`; the typescripts are kept. rc.3's
# build runs the same hunt as a control, to show the replay catches wrapped redraws.
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc4/homes/progress
. "$D/lib.sh" progress
J3=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc3/bin/jetcarp-0.4.2-rc.3-x86_64-unknown-linux-gnu/jetcarp
export J H R J3
echo "R4-8 #104 progress lines in a 60-column terminal, Framework, $(ts)"
echo "fresh home \$H = homes/progress; \$J3 = rc.3's release build"
echo
cp -a --reflink=auto /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc3/pack-long "$H/pack-long"
run "du -sh \$H/pack-long; \$J pack info \$H/pack-long | head -8"
echo "#### (a) rc.4: a 30-second hunt in 60 columns (B3/S23 on square and hex, CPU, 4 threads)"
run "script -qfec 'stty cols 60 rows 40; \$J search hunt --rules B3/S23 --tilings square,hex --soups 2000000 --minutes 0.5 --cpu --threads 4 --label h104' \$R/R4-8-hunt-rc4.typescript > /dev/null"
run "python3 \$R/R4-scripts/term60.py \$R/R4-8-hunt-rc4.typescript 60 | head -50"
echo "#### (b) rc.4: a 1-minute explore in 60 columns (JACA, CPU, 4 threads)"
run "script -qfec 'stty cols 60 rows 40; \$J search explore --families jaca --minutes 1 --cpu --threads 4 --label p104' \$R/R4-8-explore-rc4.typescript > /dev/null"
run "python3 \$R/R4-scripts/term60.py \$R/R4-8-explore-rc4.typescript 60 | head -50"
echo "#### (c) rc.4: pack import in 60 columns (it prints each step on a line of its own: no redraws)"
run "script -qfec 'stty cols 60 rows 40; \$J pack import --allow-unsigned \$H/pack-long' \$R/R4-8-import-rc4.typescript > /dev/null"
run "python3 \$R/R4-scripts/term60.py \$R/R4-8-import-rc4.typescript 60"
echo "#### (d) control: rc.3's build, the same hunt in 60 columns (its own library file)"
run "script -qfec 'stty cols 60 rows 40; \$J3 search hunt --library \$H/rc3-control.sqlite --rules B3/S23 --tilings square,hex --soups 2000000 --minutes 0.5 --cpu --threads 4 --label h104' \$R/R4-8-hunt-rc3-control.typescript > /dev/null"
run "python3 \$R/R4-scripts/term60.py \$R/R4-8-hunt-rc3-control.typescript 60 | head -50"
