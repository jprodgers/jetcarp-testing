#!/bin/bash
# FD (v0.4.2-rc.4): the desktop background on GNOME 51 in a private headless GNOME Shell, with
# screenshots for Jimmie's look, and a monitor change. The XDG folders and the D-Bus session come from
# dbus-run-session's own environment (env -i by the caller), so dconf writes land in $G/config.
G=$W4/fd
J=$W4/bin/jetcarp-0.4.2-rc.4-x86_64-unknown-linux-gnu/jetcarp
[ "$XDG_CONFIG_HOME" = "$G/config" ] || { echo "ABORT: XDG_CONFIG_HOME is not the test's"; exit 2; }
[ "$XDG_DATA_HOME" = "$G/data" ] || { echo "ABORT: XDG_DATA_HOME is not the test's"; exit 2; }
[ "$XDG_RUNTIME_DIR" = "$G/run" ] || { echo "ABORT: XDG_RUNTIME_DIR is not the test's"; exit 2; }
case "${DBUS_SESSION_BUS_ADDRESS:-}" in ""|*"/run/user/"*) echo "ABORT: not a private bus: ${DBUS_SESSION_BUS_ADDRESS:-none}"; exit 2;; esac
unset WAYLAND_DISPLAY DISPLAY JETCARP_GPU
export JETCARP_CONFIG_DIR=$G/config/jetcarp JETCARP_DATA_DIR=$G/data/jetcarp JETCARP_OUT=$G/out JETCARP_LIBRARY=$G/data/library JETCARP_RUNTIME_DIR=$G/run/jetcarp
for k in settings data output runtime; do
  $J paths | grep "^$k:" | grep -q "$G/" || { echo "ABORT: $k is not under the test folder"; $J paths; exit 4; }
done
say() { echo "$(date '+%H:%M:%S') $*"; }
say "every JETCARP folder is under the test folder: ok"
$J --version
$J setup --seizure-warning no-disorder 2>&1 | tail -1
gsettings set org.gnome.shell enabled-extensions "['jetcarp@jimmieprodgers.com']"
sleep 1
[ -f "$G/config/dconf/user" ] || { echo "ABORT: the setting did not land in the test's dconf"; exit 3; }
say "settings land in the test's own dconf: ok"
say "== install the extension"; $J host gnome install 2>&1 | tail -2
info() { gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Extensions.GetExtensionInfo jetcarp@jimmieprodgers.com 2>&1 | grep -o "'state': <[0-9.]*>\|'version-name': <'[^']*'>" | tr '\n' ' '; echo; }
gnome-shell --headless --wayland --no-x11 --virtual-monitor 1920x1080 --virtual-monitor 1280x720 --wayland-display jt-wl > $G/shell.log 2>&1 & SH=$!
sleep 10; say "shell up; extension: $(info)"
python3 $G/mon.py state
export WAYLAND_DISPLAY=jt-wl
$J host serve > $G/host.log 2>&1 & HOST=$!; sleep 8
say "== wallpaper on"; $J host wallpaper on 2>&1 | tail -2; sleep 10
$J host status > $G/status-1.txt 2>&1; $J host status --json > $G/status-1.json 2>&1; cat $G/status-1.txt
python3 $G/shot.py $G/shots/1-two-monitors.png; sleep 5; python3 $G/shot.py $G/shots/2-five-seconds-later.png
say "== a monitor change: only the first monitor"; python3 $G/mon.py only 0; sleep 12
python3 $G/mon.py state
$J host status > $G/status-2-one.txt 2>&1; $J host status --json > $G/status-2-one.json 2>&1; cat $G/status-2-one.txt
python3 $G/shot.py $G/shots/3-one-monitor.png
say "== both monitors again"; python3 $G/mon.py all; sleep 12
python3 $G/mon.py state
$J host status > $G/status-3-both.txt 2>&1; $J host status --json > $G/status-3-both.json 2>&1; cat $G/status-3-both.txt
python3 $G/shot.py $G/shots/4-both-again.png
say "fit or tune lines in the host's log: $(grep -c -i -E 'tune|fit|sweep' $G/host.log)"
say "== stop"; $J host stop 2>&1 | tail -1; sleep 3
say "picture after stop: $(gsettings get org.gnome.desktop.background picture-uri)"
python3 $G/shot.py $G/shots/5-after-stop.png
kill $HOST 2>/dev/null
kill $SH; wait $SH 2>/dev/null
say "shell log error lines: $(grep -c -i 'error\|exception' $G/shell.log)"
say "== done"
