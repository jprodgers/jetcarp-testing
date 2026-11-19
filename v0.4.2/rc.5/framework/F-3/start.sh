#!/bin/bash
# Start F-3 on the host, with the private session's environment (see inner.sh).
G=/home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc5/f3
exec env -i MINUTES=${MINUTES:-480} HOME=$G/home USER=jimmie PATH=/usr/bin:/bin TZ=America/New_York XDG_CURRENT_DESKTOP=GNOME XDG_SESSION_TYPE=wayland XDG_CONFIG_HOME=$G/config XDG_DATA_HOME=$G/data XDG_CACHE_HOME=$G/cache XDG_STATE_HOME=$G/state XDG_RUNTIME_DIR=$G/run dbus-run-session -- bash $G/inner.sh
