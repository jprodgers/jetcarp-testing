"""The private shell's monitors: `state` lists them; `only N` keeps only monitor N; `all` puts every
monitor side by side (org.gnome.Mutter.DisplayConfig, temporary configuration)."""
import sys, gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
P = ("org.gnome.Mutter.DisplayConfig", "/org/gnome/Mutter/DisplayConfig", "org.gnome.Mutter.DisplayConfig")
serial, monitors, logical, props = bus.call_sync(*P, "GetCurrentState", None, None, 0, -1, None).unpack()
mons = []
for (conn, vendor, product, ser), modes, mprops in monitors:
    cur = next((m for m in modes if m[6].get("is-current")), modes[0])
    mons.append((conn, cur[0], cur[1], cur[2]))
if sys.argv[1] == "state":
    print("monitors:", [(c, f"{w}x{h}") for c, _, w, h in mons])
    print("logical:", [(x, y, [m[0] for m in ms]) for x, y, sc, tr, pr, ms, p in logical])
    sys.exit(0)
keep = [mons[int(sys.argv[2])]] if sys.argv[1] == "only" else mons
lms, x = [], 0
for i, (conn, mode, w, h) in enumerate(keep):
    lms.append((x, 0, 1.0, 0, i == 0, [(conn, mode, {})]))
    x += w
bus.call_sync(*P, "ApplyMonitorsConfig",
              GLib.Variant("(uua(iiduba(ssa{sv}))a{sv})", (serial, 1, lms, {})), None, 0, -1, None)
print("applied:", [(c, f"{w}x{h}") for c, _, w, h in keep])
