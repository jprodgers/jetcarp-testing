# R4 on the Framework (rc.5): recording helpers. Usage, in bash:  . lib.sh <home-name>
# Sources the rc.5 env.sh (every JETCARP folder, HOME and XDG folder under a scratch home), then
# `run "<command>"` prints the command and its output with the scratch paths written as $H, $J
# and $R, then its exit code and wall time.
. /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc5/env.sh "${1:-main}"
W5=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc5
case "$HOME" in "$W5"/homes/*) ;; *) echo "ABORT: HOME is not a scratch home: $HOME"; return 2 2>/dev/null || exit 2;; esac
sub() { sed -e "s#$J#\$J#g" -e "s#$H#\$H#g" -e "s#$R#\$R#g" -e "s#$W5#\$W5#g"; }
ts() { TZ=America/New_York date '+%Y-%m-%d %I:%M:%S %p %Z'; }
run() {
  echo "\$ $*" | sub
  local t0 t1 rc
  t0=$(date +%s.%N)
  eval "$@" 2>&1 | sub
  rc=${PIPESTATUS[0]}
  t1=$(date +%s.%N)
  awk -v a="$t0" -v b="$t1" -v rc="$rc" 'BEGIN { printf "[exit %s, %.2f s]\n\n", rc, b - a }'
  return "$rc"
}
# The display's variables unset, for a command that would open a window if it weren't refused.
nodisp() { env -u DISPLAY -u WAYLAND_DISPLAY "$@"; }
# The rc.5 host processes now running (the parity runs are `$J run`, never `host serve`).
hosts() { local o; o=$(pgrep -a -f "$J host serve"); if [ -n "$o" ]; then echo "$o" | sub; else echo "no rc.5 host process running"; fi; }
