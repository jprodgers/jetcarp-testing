#!/bin/bash
# F-1 (rc.4): rc.4's app on Jimmie's real GNOME session. Every JETCARP folder, HOME and the XDG
# config, data, cache and state folders are scratch (env.sh f1), and a gsettings guard on PATH
# refuses any change to the real GNOME settings. Start: flatpak-spawn --host bash app.sh [args]
W4=$W4
. $W4/env.sh f1 >/dev/null
export PATH=$W4/f1/guard:$PATH
for k in settings data output runtime; do
  $J paths | grep "^$k:" | grep -q "$W4/homes/f1/" || { echo "ABORT: $k is not under homes/f1"; $J paths; exit 4; }
done
[ "$(command -v gsettings)" = "$W4/f1/guard/gsettings" ] || { echo "ABORT: the gsettings guard is not first on PATH"; exit 5; }
echo "f1: every JETCARP folder in homes/f1, the guard on; starting $($J --version)"
exec $J "$@"
