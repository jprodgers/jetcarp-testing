#!/usr/bin/env bash
# R4 #122: host start straight after host stop, ten rounds in a row in one test folder, no pause between
# commands. Every start and stop must succeed; timings recorded. (The Framework's r4_10_cycle.sh, for the Mac.)
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf ~/jetcarp-rc4/homes/cycle122
. "$D/lib.sh" cycle122
echo "R4 #122 host start straight after host stop, ten rounds, the Mac, $(ts)"
echo "test folder \$H = homes/cycle122, the warning accepted first; the default host is stopped"
echo
run "\$J setup --yes --seizure-warning no-disorder"
fails=0
TAB=""
for i in 1 2 3 4 5 6 7 8 9 10; do
  echo "### round $i"
  t0=$(now); out=$("$J" host start --headless 2>&1); rs=$?; t1=$(now)
  echo "\$ \$J host start --headless"; echo "$out" | head -2 | sub
  ds=$(awk -v a="$t0" -v b="$t1" 'BEGIN{printf "%.2f", b-a}'); echo "[exit $rs, $ds s]"
  t0=$(now); out=$("$J" host stop 2>&1); rp=$?; t1=$(now)
  echo "\$ \$J host stop"; echo "$out" | sub
  dp=$(awk -v a="$t0" -v b="$t1" 'BEGIN{printf "%.2f", b-a}'); echo "[exit $rp, $dp s]"
  [ $rs -eq 0 ] && [ $rp -eq 0 ] || fails=$((fails + 1))
  TAB="$TAB$(printf '%5s | %10s | %8s | %9s | %7s' "$i" "$rs" "$ds" "$rp" "$dp")"$'\n'
done
echo
echo "#### Summary"
printf '%5s | %10s | %8s | %9s | %7s\n' round "start exit" "start s" "stop exit" "stop s"
printf '%s' "$TAB"
echo "rounds with a failure: $fails of 10"
sleep 1
run hosts
run "\$J host status"
