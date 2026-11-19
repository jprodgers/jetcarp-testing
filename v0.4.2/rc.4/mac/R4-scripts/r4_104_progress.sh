#!/usr/bin/env bash
# R4 #104: progress lines fit a 60-column terminal. (The Framework's r4_8_progress.sh, for the Mac.) A 30-second
# hunt (the case #104 reported), a 1-minute explore and a pack import (rc.3's M-10 pack, copied), each in a 60x40
# pseudo-terminal (pty60.py); the typescripts are kept. rc.3's build runs the same hunt as a control, to show the
# replay catches wrapped redraws.
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf ~/jetcarp-rc4/homes/progress
. "$D/lib.sh" progress
J3=~/jetcarp-rc-042c/bin/jetcarp
echo "R4 #104 progress lines in a 60-column terminal, the Mac, $(ts)"
echo "test folder \$H = homes/progress; rc.3's build: $($J3 --version)"
echo
cp -R ~/jetcarp-rc-042c/M10-pack "$H/pack-m10"
run "du -sh \$H/pack-m10; \$J pack info \$H/pack-m10 | head -8"
P="python3 $D/pty60.py"
echo "#### (a) rc.4: a 30-second hunt in 60 columns (B3/S23 on square and hex, CPU, 4 threads)"
run "$P \$R/104-hunt-rc4.typescript 60 40 -- bash -c 'stty size; \$J search hunt --rules B3/S23 --tilings square,hex --soups 2000000 --minutes 0.5 --cpu --threads 4 --label h104'"
run "python3 $D/term60.py \$R/104-hunt-rc4.typescript 60 | head -50"
echo "#### (b) rc.4: a 1-minute explore in 60 columns (JACA, CPU, 4 threads)"
run "$P \$R/104-explore-rc4.typescript 60 40 -- bash -c 'stty size; \$J search explore --families jaca --minutes 1 --cpu --threads 4 --label p104'"
run "python3 $D/term60.py \$R/104-explore-rc4.typescript 60 | head -50"
echo "#### (c) rc.4: pack import in 60 columns"
run "$P \$R/104-import-rc4.typescript 60 40 -- bash -c 'stty size; \$J pack import --allow-unsigned \$H/pack-m10'"
run "python3 $D/term60.py \$R/104-import-rc4.typescript 60"
echo "#### (d) control: rc.3's build, the same hunt in 60 columns (its own library file)"
run "$P \$R/104-hunt-rc3-control.typescript 60 40 -- bash -c 'stty size; $J3 search hunt --library \$H/rc3-control.sqlite --rules B3/S23 --tilings square,hex --soups 2000000 --minutes 0.5 --cpu --threads 4 --label h104'"
run "python3 $D/term60.py \$R/104-hunt-rc3-control.typescript 60 | head -50"
