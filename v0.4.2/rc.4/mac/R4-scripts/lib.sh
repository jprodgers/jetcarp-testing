# R4 on the Mac (rc.4): recording helpers. Usage, in bash:  . lib.sh <test-folder-name>   (or --default)
# Sets every JETCARP folder under ~/jetcarp-rc4/homes/<name> (never the default folders), then
# `run "<command>"` prints the command and its output with the paths written as $H (the test folder),
# $J (rc.4's release build), $R (the results folder) and ~, then its exit code and wall time.
J=$HOME/jetcarp-rc4/rel/jetcarp-0.4.2-rc.4-aarch64-apple-darwin/jetcarp
R=$HOME/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc4/mac
if [ "${1:-}" = "--default" ]; then   # the default folders: no JETCARP_* variable; commands as `jetcarp` through the PATH link
  H=/nonexistent-test-folder
  unset JETCARP_CONFIG_DIR JETCARP_DATA_DIR JETCARP_OUT JETCARP_LIBRARY JETCARP_RUNTIME_DIR
else
  H=$HOME/jetcarp-rc4/homes/${1:-main}
  mkdir -p "$H"
  export JETCARP_CONFIG_DIR=$H/config JETCARP_DATA_DIR=$H/data JETCARP_OUT=$H/out JETCARP_LIBRARY=$H/library JETCARP_RUNTIME_DIR=$H/run
fi
export J R H
unset JETCARP_GPU
sub() { sed -e "s#$J#\$J#g" -e "s#$H#\$H#g" -e "s#$R#\$R#g" -e "s#$HOME#~#g"; }
ts() { date '+%Y-%m-%d %I:%M:%S %p %Z'; }
now() { python3 -c 'import time; print(time.time())'; }
run() {
  echo "\$ $*" | sub
  local t0 t1 rc
  t0=$(now)
  eval "$@" 2>&1 | sub
  rc=${PIPESTATUS[0]}
  t1=$(now)
  awk -v a="$t0" -v b="$t1" -v rc="$rc" 'BEGIN { printf "[exit %s, %.2f s]\n\n", rc, b - a }'
  return "$rc"
}
# JETCARP host processes now running: the default one (launchd's) and any test folder's.
hosts() { local o; o=$(pgrep -fl "jetcarp host serve"); if [ -n "$o" ]; then echo "$o" | sub; else echo "no host process running"; fi; }
