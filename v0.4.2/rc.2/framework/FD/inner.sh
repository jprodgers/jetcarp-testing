#!/bin/bash
# FD (v0.4.2-rc.2): the desktop background on GNOME 51 in a private headless GNOME Shell.
# The XDG folders and the D-Bus session come from dbus-run-session's own environment (env -i by the
# caller), so dconf writes land in $G/config and never in the real ~/.config.
G=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc2/fd2
J=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc2/bin/jetcarp-0.4.2-rc.2-x86_64-unknown-linux-gnu/jetcarp
[ "$XDG_CONFIG_HOME" = "$G/config" ] || { echo "ABORT: XDG_CONFIG_HOME is not the test's"; exit 2; }
[ "$XDG_DATA_HOME" = "$G/data" ] || { echo "ABORT: XDG_DATA_HOME is not the test's"; exit 2; }
case "${DBUS_SESSION_BUS_ADDRESS:-}" in ""|*"/run/user/"*) echo "ABORT: not a private bus: ${DBUS_SESSION_BUS_ADDRESS:-none}"; exit 2;; esac
unset WAYLAND_DISPLAY DISPLAY JETCARP_RUNTIME_DIR JETCARP_DATA_DIR JETCARP_CONFIG_DIR JETCARP_LIBRARY JETCARP_GPU
export JETCARP_OUT=$G/out
for k in settings data output; do
  $J paths | grep "^$k:" | grep -q "$G/" || { echo "ABORT: $k is not under the test folder"; $J paths; exit 4; }
done
echo "every JETCARP folder is under the test folder: ok"
say() { echo "$(date '+%H:%M:%S') $*"; }
gsettings set org.gnome.shell enabled-extensions "['jetcarp@jimmieprodgers.com']"
sleep 1
[ -f "$G/config/dconf/user" ] || { echo "ABORT: the setting did not land in the test's dconf"; exit 3; }
say "settings land in the test's own dconf: ok ($(ls -la $G/config/dconf/user | awk '{print $5}') bytes)"
$J paths
say "== install the extension"; $J host gnome install 2>&1 | tail -3
ls $XDG_DATA_HOME/gnome-shell/extensions/
info() { gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Extensions.GetExtensionInfo jetcarp@jimmieprodgers.com 2>&1 | grep -o "'state': <[0-9.]*>\|'version-name': <'[^']*'>" | tr '\n' ' '; echo; }
gnome-shell --headless --wayland --no-x11 --virtual-monitor 1920x1080 --wayland-display jt-wl > $G/shell.log 2>&1 & SH=$!
sleep 8; say "shell up; extension: $(info)"
export WAYLAND_DISPLAY=jt-wl
$J host serve > $G/host.log 2>&1 & HOST=$!; sleep 8
say "== wallpaper on"; $J host wallpaper on 2>&1 | tail -2; sleep 8
$J host status > $G/status-1.txt 2>&1; $J host status --json > $G/status-1.json 2>&1
sleep 10; $J host status --json > $G/status-2.json 2>&1
cat $G/status-1.txt
say "== #42 every generation"; $J host pacing every-generation 2>&1 | tail -1; sleep 6; $J host status > $G/status-everygen.txt 2>&1; head -12 $G/status-everygen.txt
$J host max-fps refresh 2>&1 | tail -1; sleep 6; $J host status > $G/status-maxfps-refresh.txt 2>&1; grep -i "fps\|frame\|generation" $G/status-maxfps-refresh.txt | head -4
$J host max-fps 60 2>&1 | tail -1
$J host pacing low-power 2>&1 | tail -1; sleep 8; $J host status > $G/status-lowpower.txt 2>&1; grep -i "fps\|frame\|generation\|power" $G/status-lowpower.txt | head -5
$J host pacing every-generation 2>&1 | tail -1
say "== #38 #43 #44 #45 tune"; mkdir -p $G/crops
$J host tune --trial-seconds 1 --crops $G/crops --json > $G/tune.json 2> $G/tune.err; say "tune exit $?"
ls $G/crops | wc -l
$J host status > $G/status-tuned.txt 2>&1; head -14 $G/status-tuned.txt
say "== #39 picks"; $J host tune --pick own --trial-seconds 1 --json > $G/tune-own.json 2> $G/tune-own.err; say "pick own exit $?"
$J host status > $G/status-own.txt 2>&1; head -8 $G/status-own.txt
$J host tune --pick 3 --trial-seconds 1 --json > $G/tune-3.json 2> $G/tune-3.err; say "pick 3 exit $?"
$J host status > $G/status-3px.txt 2>&1; head -8 $G/status-3px.txt
say "== busy pause"; $J host busy 50 2>&1 | tail -1
$J search explore --cpu --threads 32 --minutes 1 --label busy > $G/busy-search.txt 2>&1 & BS=$!
sleep 40; $J host status > $G/status-busy.txt 2>&1; head -6 $G/status-busy.txt
wait $BS; sleep 15; $J host status > $G/status-after-busy.txt 2>&1; head -4 $G/status-after-busy.txt
$J host busy 80 2>&1 | tail -1
say "== crash: kill -9 the host"; kill -9 $HOST; sleep 5
$J host status > $G/status-after-kill.txt 2>&1; head -3 $G/status-after-kill.txt
say "picture after the kill: $(gsettings get org.gnome.desktop.background picture-uri)"
say "extension after the kill: $(info)"
$J host start > $G/host-start.txt 2>&1; tail -2 $G/host-start.txt; sleep 10
$J host status > $G/status-restarted.txt 2>&1; head -4 $G/status-restarted.txt
say "== stop"; $J host stop 2>&1 | tail -1; sleep 3
say "picture after stop: $(gsettings get org.gnome.desktop.background picture-uri)"
pkill -f "$J host serve" 2>/dev/null
kill $SH; wait $SH 2>/dev/null
grep -c -i "error\|exception" $G/shell.log | sed 's/^/shell log error lines: /'
say "== done"
