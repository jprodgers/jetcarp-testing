# FD on rc.4: the desktop background on GNOME 51, in a private headless shell (the Framework, 2026-11-17, 4:31 AM EST)

**Pass.** rc.4's release build (`jetcarp 0.4.2-rc.4`), GNOME Shell 51.1 headless with two virtual monitors (Meta-0 1920x1080, Meta-1 1280x720 to its right), on a private D-Bus session with every XDG folder, `XDG_RUNTIME_DIR` and every JETCARP folder in `$W4/fd`. `inner.sh` is the script, `run.log` its output (the D-Bus activation lines left out).

- **Jimmie's real GNOME settings are unchanged:** the real `enabled-extensions`, `picture-uri` and `picture-uri-dark` were read before and after, and match.
- **The warning:** `setup --seizure-warning no-disorder` first, then the host could start.
- **The extension:** installed into the test's data folder; the shell ran it (state 1, version-name `0.4.2-rc.4`).
- **The live desktop:** `host wallpaper on` showed "A classic a day", profile Penrose waves, 280,000 cells of 2.4 px (its own size), 30 fps and 30 generations a second on the Radeon, "wallpaper on every monitor". `shots/1-two-monitors.png` (the shell opens in its overview, with Fedora's welcome dialog from the fresh account) shows the scene on both monitors.
- **A monitor change** (`mon.py only 0`: Meta-1 taken out through `org.gnome.Mutter.DisplayConfig`): the host carried on ("monitors: 0: Meta-0", generation 882, the same 280,000 cells of 2.4 px), and no fit started (no tune, fit or sweep line in the host's log). `shots/3-one-monitor.png`.
- **Both monitors back** (`mon.py all`): "wallpaper on every monitor" again, the same size, generation 1,294. `shots/4-both-again.png`.
- **Stop:** "stopped", and the test session's picture went back to Fedora's default.
- **The shell's log:** one JavaScript error at the monitor change, in GNOME Shell's own overview (`workspace.js: monitor is undefined`, while the overview was open; `shell-js-error.txt`). It's GNOME's, not the extension's: no JETCARP line in the log.

The screenshots come from the shell's own Screenshot interface. `shot.py` owns the media-keys bus name the interface allows, which works only because the bus is the test's private one.
