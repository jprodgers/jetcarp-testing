"""A screenshot of the private headless shell: own the media-keys name the shell's Screenshot
interface allows, on this (private) session bus, then ask for the picture."""
import sys, time, gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
bus.call_sync("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "RequestName",
              GLib.Variant("(su)", ("org.gnome.SettingsDaemon.MediaKeys", 4)), None, 0, -1, None)
ctx = GLib.MainContext.default()
t = time.time()
while time.time() - t < 1.0:
    ctx.iteration(False); time.sleep(0.05)
r = bus.call_sync("org.gnome.Shell.Screenshot", "/org/gnome/Shell/Screenshot", "org.gnome.Shell.Screenshot",
                  "Screenshot", GLib.Variant("(bbs)", (False, False, sys.argv[1])), GLib.VariantType("(bs)"), 0, 20000, None)
print("screenshot:", r.unpack())
