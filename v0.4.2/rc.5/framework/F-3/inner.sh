#!/bin/bash
# F-3 (v0.4.2-rc.5): the 8-hour soak (1.5) of the desktop background on GNOME 51, in a private headless
# GNOME Shell on one virtual 2560x1440 monitor, rotation "Classics, hourly", as on the laptops. A sample
# every 5 minutes (the host's status and its process), a screenshot every hour. The XDG folders and the
# D-Bus session come from dbus-run-session's environment (env -i by the caller), so nothing reaches
# Jimmie's real settings.
G=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc5/f3
J=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc5/bin/jetcarp-0.4.2-rc.5-x86_64-unknown-linux-gnu/jetcarp
MINUTES=${MINUTES:-480}
[ "$XDG_CONFIG_HOME" = "$G/config" ] || { echo "ABORT: XDG_CONFIG_HOME is not the test's"; exit 2; }
[ "$XDG_DATA_HOME" = "$G/data" ] || { echo "ABORT: XDG_DATA_HOME is not the test's"; exit 2; }
[ "$XDG_RUNTIME_DIR" = "$G/run" ] || { echo "ABORT: XDG_RUNTIME_DIR is not the test's"; exit 2; }
case "${DBUS_SESSION_BUS_ADDRESS:-}" in ""|*"/run/user/"*) echo "ABORT: not a private bus"; exit 2;; esac
unset WAYLAND_DISPLAY DISPLAY JETCARP_GPU
export JETCARP_CONFIG_DIR=$G/config/jetcarp JETCARP_DATA_DIR=$G/data/jetcarp JETCARP_OUT=$G/out JETCARP_LIBRARY=$G/data/library JETCARP_RUNTIME_DIR=$G/run/jetcarp
for k in settings data output runtime; do
  $J paths | grep "^$k:" | grep -q "$G/" || { echo "ABORT: $k is not under the test folder"; exit 4; }
done
say() { echo "$(TZ=America/New_York date '+%Y-%m-%d %I:%M:%S %p %Z') $*"; }
say "F-3 start; $($J --version); every JETCARP folder under the test folder"
$J setup --seizure-warning no-disorder 2>&1 | tail -1
gsettings set org.gnome.shell enabled-extensions "['jetcarp@jimmieprodgers.com']"; sleep 1
[ -f "$G/config/dconf/user" ] || { echo "ABORT: the setting did not land in the test's dconf"; exit 3; }
$J host gnome install 2>&1 | tail -1
gnome-shell --headless --wayland --no-x11 --virtual-monitor 2560x1440 --wayland-display jt-f3 > $G/shell.log 2>&1 & SH=$!
sleep 10
export WAYLAND_DISPLAY=jt-f3
$J host serve > $G/host.log 2>&1 & HOST=$!; sleep 8
$J host rotation "Classics, hourly" 2>&1 | tail -1
$J host wallpaper on 2>&1 | tail -1; sleep 10
$J host status | head -4
echo "time,elapsed_min,host_pid,alive,rss_mb,cpu_pct,status_mb,scene,number,generation,cells,cell_px,speed,measured,simulation,held,paused" > $G/soak.csv
start=$(date +%s); end=$((start + MINUTES * 60)); n=0
while [ "$(date +%s)" -lt "$end" ]; do
  now=$(date +%s); el=$(( (now - start) / 60 ))
  pid=$(pgrep -f "^$J host serve" | head -1)
  alive=False; rss=""; cpu=""
  if [ -n "$pid" ]; then alive=True; rss=$(( $(awk '/VmRSS/ {print $2}' /proc/$pid/status) / 1024 )); cpu=$(top -b -n 2 -d 1 -p $pid | awk -v p=$pid '$1==p {c=$9} END {print c}'); fi
  $J host status --json 2>/dev/null > $G/status-last.json
  python3 - "$G/status-last.json" "$TZ" >> $G/soak.csv <<PY
import json, sys, datetime
try:
    v = json.load(open(sys.argv[1]))
except Exception:
    v = {}
s = (v.get("screens") or [{}])[0]
st = s.get("stage", {})
sim = s.get("simulation", {})
row = [datetime.datetime.now().strftime("%H:%M:%S"), "$el", "$pid", "$alive", "$rss", "$cpu", str(v.get("memory_mb", "")),
       '"%s"' % st.get("label", ""), str(st.get("number", "")), str(st.get("generation", "")), str(st.get("cells", "")),
       str(round(st.get("cell_px", 0), 2)), str(st.get("speed", "")), str(round(st.get("measured_speed", 0) or 0, 2)),
       '"%s"' % sim.get("on", ""), '"%s"' % ";".join(v.get("held_why", []) if isinstance(v.get("held_why"), list) else []), str(st.get("paused", ""))]
print(",".join(row))
PY
  if [ $((n % 12)) -eq 0 ]; then python3 $G/shot.py $G/shots/f3-$(printf %02d $((el / 60)))h.png > /dev/null 2>&1; say "hour $((el / 60)): $(tail -1 $G/soak.csv)"; fi
  n=$((n + 1)); left=$((end - $(date +%s))); [ $left -gt 300 ] && left=300; [ $left -gt 0 ] && sleep $left
done
say "== $MINUTES minutes done"; $J host status | head -4
$J host stop 2>&1 | tail -1; sleep 3
kill $HOST 2>/dev/null; kill $SH; wait $SH 2>/dev/null
say "shell log error lines: $(grep -c -i 'error\|exception' $G/shell.log); host log lines: $(wc -l < $G/host.log)"
say "== F-3 done"
