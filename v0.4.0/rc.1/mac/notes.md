# rc1 on the Mac: notes

System: `00-system.txt` (MacBook Pro Mac14,6, M2 Max with 38-core GPU, 64 GB; macOS 27.0.1, build
26A434; built-in Liquid Retina XDR panel, "looks like" 2056x1329 at 120 Hz; on mains, battery 80%).
Not run as root.

Before rc1, this Mac already had `~/Library/Application Support/cart/` from an old development build
(CART, before the JETCARP name), and one Space's desktop picture points at a still from that folder,
which no longer exists. Neither comes from rc1; both are left alone.

## M1. Install with the shell installer — pass

Output: `01-install.txt`, `02-version.txt`, `03-paths.txt`, `04-doctor.txt`.

**Jimmie ran the install line himself**, because Claude Code's auto mode blocks `curl ... | sh`
(and running the downloaded script with `sh`). Claude read the script first: it matches the
release's `SHA256SUMS` (`5021c330...d554fa`) and touches no shell startup files.

1. **Installed into `~/.local/lib/jetcarp`, link in `~/.local/bin`**: `~/.local/bin/jetcarp ->
   ~/.local/lib/jetcarp/jetcarp`. The folder holds `.jetcarp-installer` (`JETCARP 0.4.0-rc.1
   aarch64-apple-darwin`), `jetcarp` (55.9 MB, arm64), `libjetcarp_saver.dylib` (12.5 MB), the
   licences and README; no `packs`. `~/.local/bin` was already on the `PATH`, so the installer
   printed no PATH hint. The shell startup files are unchanged (same hashes before and after).
2. **Nothing was blocked; no dialog.** The installed files have no `com.apple.quarantine`
   attribute (no extended attributes at all). `jetcarp` is ad-hoc signed only (`Signature=adhoc`,
   no Team ID), so `spctl --assess` says `rejected`; that matters only for files with a quarantine
   mark, such as a download from a browser.
3. **doctor shows the M2 Max**: `* Apple M2 Max (Metal, IntegratedGpu)`, the only adapter.
   12 threads.
4. **`bundled:` none**: `paths` says `(no packs came with the program)`, doctor says `none`.

Smaller:
- doctor looks for bundled packs in `~/.local/lib/share/jetcarp/packs` as well as the install
  folder. That's the program's folder's parent plus `share/jetcarp/packs`, which only makes sense
  when the program is in a `bin` folder. The Acer shows the same thing.
- Installer wording, line 77: "such as 0.4.0-rc.1 or 0.4.0-rc.1", the same repeated version as
  the PowerShell installer.

## M2. The app — pass (checks 1–8); check 9 passes except the name

Files: `05-app-terminal.txt`, `07-scene.json`, `07-scene-verify.txt`, `08-export.png`,
`08-export-embedded-scene.json`, `08-export-png.txt`, `09-large-sandpile-*` (from
`~/Pictures/JETCARP/piles/2026-11-12_01-09-24_square-1000000/`), `10-hunt-and-library.txt`.
No screenshots: this Claude session has no Screen Recording permission.

1. **Quick Start, previews animate** (Jimmie). The library has 364 entries, as on the Acer.
2. **Each runs and pauses with Space** (Jimmie). Opened *Life on the square grid* (`life`),
   *B2/S34 on the hat* (`hat-b2s34`) and *Sandpile on Cairo pentagons* (`sandpile-cairo`);
   `quickstart_usage` records one open of each.
3. **Right-click menu with five stars and Hide.** Jimmie rated *Brian's Brain on Penrose rhombs*
   5 stars (`ratings`: quickstart, `penrose-rhomb-brain`, rater `user`, 5.0) and hid *Spectre
   glider* (`spectre-glider`, `hidden = 1`; 363 left). It stayed hidden after coming back.
4. **Save / open scene: same state.** Saved *Layered parity on the Spectre* at generation 25;
   `jetcarp verify 07-scene.json`: `ok: generation 25 hash 98ed8ecdae3d246c`. As on the Acer,
   **the opened scene starts running at once**, so Jimmie couldn't read the generation before it
   moved on; it looked right.
5. **Export PNG looks right** (Jimmie, and Claude looked at it): 1929x2400 RGBA, sharp; its iTXt
   chunks carry version, generation 80, hash `bea0a7c7ef71a0fc`, `dead_boundary` and the scene,
   and the embedded scene verifies: `ok: generation 80 hash bea0a7c7ef71a0fc`. Jimmie noticed that
   **the export isn't the view**: it frames the whole tiling patch (long side 2400 px), tighter
   than what the window showed, ignoring the scene's zoom (0.958) and centre. The Acer's export
   (2400x2396 of the hat) was framed the same way. Worth deciding which one people should get, or
   offering both.
6. **Large sandpile, 1,000,000 grains on square, on the GPU: 4.2 s** (`wall_seconds` 4.221;
   every step on `gpu (Apple M2 Max, Metal)`), 729x729, **11,583,796,400 topplings, the same
   count as the Acer's RTX 3050** (8.2 s). The expected rounded-square mandala with four-fold
   mirror symmetry (`09-large-sandpile-preview.png`).
7. **Soup hunt, defaults: finds in the pattern library** (Jimmie). 10,000 soups in 4.6 s
   (Acer: 7.4 s); 213,586 objects (oscillators 62,009, spaceships 18,987, still lifes 132,590),
   64 distinct, all new: **identical counts to the Acer**. The library holds the 64 patterns.
8. **Resize, full screen, zoom: normal; text sharp** on the Retina panel (Jimmie).
9. **In the Dock, and quits cleanly, but named `jetcarp`.** The Dock and the menu bar both say
   `jetcarp` (lowercase), not JETCARP: a bare program has no bundle to give it a display name
   (`CFBundleName`), so macOS uses the file name. The icon is a hexagon with a partial cross in
   the middle. Cmd+Q: exit 0 after a 26-minute session with GPU work, no dialog, no crash report.
   A second start, closed with the window's red button: the app quit completely (exit 0), as on
   Windows and Linux rather than staying open without a window, as Mac apps usually do. **No crash on close** in
   either, unlike the Acer's one crash in `nvoglv64.dll`. The terminal printed nothing.

## M3. The desktop

Files: `12-desktop-before.txt`, `13-host-start.txt`, `14-host-next.txt`, `15-host-caption.txt`,
`16-host-two-monitors.txt`, `17-host-battery.txt`, `18-host-still.txt`,
`18-still-left-by-host.png` (reduced copy), `19-host-wallpaper-off-stop.txt`.

`host start` returned at once (with its output sent to a file, not a pipe, because of the Acer's
hang); the host runs as `~/.local/bin/jetcarp host serve` with `launchd` as its parent.

1. **Live picture behind the desktop; icons readable and clickable; menu bar normal** (Jimmie).
   Turning the wallpaper on restarted the scene at the screen's size (generation 297, 25,560 cells
   → generation 73, 303,455 cells three seconds later).
2. **`host next` changes the scene** (Jimmie): Life → `Quick Start langtons-ant (2 of 7)`. Jimmie:
   it's a single ant whose highway runs to the edge of the board, comes back, and starts again.
   The board is finite, so on a wallpaper the highway always reaches the edge; maybe a scene that
   suits a desktop less well than the others.
3. **Caption in the lower left, not hidden** by the menu bar, notch or Dock (Jimmie; the Dock is
   at the bottom and hides itself). Unlike the Acer, where it sat under the taskbar.
4. **Two monitors.** The AOC Q3277 (2560x1440 at 60 Hz) to the left of the laptop.
   - `host status` lists them as `0: Monitor #41041, 1: Monitor #12919`: these are the displays'
     product IDs in decimal (0xA051 = the built-in Color LCD, 0x3277 = Q3277), not the names
     macOS has for them.
   - Before any `--screen`, screen 0 was shown on both monitors, cropped to each (Jimmie).
   - `wallpaper on --screen 0 --monitor 0` and `--screen 1 --monitor 1 --rotation "Classics,
     hourly"`: **each monitor showed its own screen**, the ant on the laptop and Life on the AOC,
     each filling its monitor (Jimmie).
   - **Spaces and Mission Control**: the live picture stays on every Space, on both monitors;
     Mission Control shows it behind the windows, with no JETCARP window among them; an app going
     full screen and back changes nothing (Jimmie).
5. **Battery pause works**: unplugged, both screens paused within seconds (`· paused`, generations
   frozen; `pmset`: Battery Power); plugged back in, both carried on (Jimmie).
6. **A still is left after `host stop`** (Jimmie), but, as on the Acer, **one still for every
   monitor**: the laptop's ant (`still-1794465108154.png`, 4112x2658, the laptop's pixel size) on
   both, so the AOC showed the ant instead of its own scene. On macOS each Space has its own
   desktop picture, and the still was written only to the Spaces showing at the time (one per
   display); the other Spaces kept Jimmie's own picture. `still off` (with the host stopped) put
   Jimmie's picture back on every Space and display that had the still, deleted the still and
   `desktop-picture.json` (Jimmie: the previous wallpaper is back).
   - The Space that shows a Wolfram picture is not rc1's: it points at the old CART build's still
     (`~/Library/Application Support/cart/desktop-pictures/still-1794302967475.png`, deleted), and
     macOS shows its cached copy. A desktop picture that outlives its file, on a Space that wasn't
     showing when the picture was put back, may be what an older build did here.
7. **`wallpaper off` then `host stop`: your own wallpaper is back** (Jimmie), and no JETCARP picture
   is left in the wallpaper settings. `host stop` printed `stopped` (no connection error, in both
   stops) and the host was gone. The host was started again first, because check 6 had already
   stopped it.
   - As on the Acer, **`wallpaper off` turns the screens into windows** (`host.json`: `"place":
     "window"` for both) while the host runs: one window per monitor, titled by its rotation
     (*A classic a day*, *Classics, hourly*). They closed with `host stop`.
   - **The host's Dock icon is the generic "exec" icon** (a Unix program's), with the name
     `jetcarp`; the app has the hexagon icon.

The screen saver (files: `20-saver-install.txt`, `20-saver-idle-log.txt`, `20-saver-system-log.txt`,
`21-saver-status-remove.txt`):

8. **System Settings opened with JETCARP listed; the preview animates; no warning** (Jimmie; the
   thumbnail is Life). `saver install` built `~/Library/Screen Savers/JETCARP.saver` (12 MB,
   `com.jimmieprodgers.jetcarp.saver`, version 0.4.0-rc.1, ad-hoc signed, `codesign --verify`
   ok) with the first screen's rotation, *A classic a day*, inside it.
9. **Started after 1 minute, on both monitors; a key press ended it** (Jimmie: Life on each).
   The saver logs to the system log: started 01:42:28 (60 s idle) at 4112x2658 on the laptop
   and 2560x1440 on the AOC; at 01:43:01 "macOS says the screen saver is stopping; ending this
   process". The key press led to the login screen because this Mac asks for the password
   at once (`screenLock delay is immediate`), not because of JETCARP.
   - **It animates a hidden view before it starts.** When JETCARP was chosen (01:40:22), macOS
     made a full-screen view ahead of time, and the saver called `startAnimation` on it 0.5 s
     later and drew about 3,700 frames at 4112x2658 on the GPU (`on screen as macOS sees it:
     false`) for two minutes, until the real start. The views macOS made after it ended
     weren't animated, so it may happen only right after choosing it.
10. **`saver remove` works with System Settings open** (unlike the Acer): `removed`, the bundle
   is gone, `saver status` says not installed. But:
   - **System Settings, already open, kept listing JETCARP (selected)** until it was quit and
     reopened; then it was gone (Jimmie).
   - **The selection is left pointing at the deleted saver**: macOS's wallpaper store still
     has `JETCARP.saver` as the screen saver on every display and Space, and System Settings
     shows a blank tile called "custom". Jimmie's earlier choice (the desktop picture) isn't put
     back. (Windows' `remove` deselects it.)
   Jimmie set "start screen saver when inactive" back to Never.

Start at login (file: `22-host-login.txt`): before `login on`, `wallpaper on` was saved with the
host stopped, so the login would start the live wallpaper rather than the two windows that
`wallpaper off` had saved (the Acer's finding, not tested again). `login on` printed
`"/Users/Jimmie/.local/bin/jetcarp" host serve starts at login` and wrote
`~/Library/LaunchAgents/com.jimmieprodgers.jetcarp.host.plist` (`RunAtLoad`, `ProcessType`
Interactive, no `KeepAlive`), not loaded now. Auto mode did not block it on this Mac.

11. **The host started by itself after a real reboot, with no Terminal window** (Jimmie: nothing
    strange; both screens as expected). Booted 02:02:05; `launchd` started `jetcarp host serve`
    at 02:02:30 (pid 738, parent launchd, `runs = 1`); `host status` showed both screens as
    wallpaper. Jimmie: **one screen was sluggish for a few seconds, then ran at normal speed**;
    the load average was 15 two minutes after boot, so probably start-up load. macOS's
    notification when `login on` ran opened System Settings, where jetcarp appeared under
    background app activity.
12. **`login off` works**: `the host no longer starts at login`; the plist is gone, and System
    Settings no longer lists jetcarp in the background items (Jimmie). `login off` deletes the
    plist but doesn't unload the job, so `launchctl` keeps it (`state = not running`) until the
    next logout; harmless, because it only runs at load. `host stop`: `stopped`, it stayed
    stopped (`last exit code = 0`, no `KeepAlive`), and Jimmie's wallpaper is back on both
    monitors (all desktop pictures are Jimmie's screenshot again, apart from the CART Space).

## M4. pipx, uv or Homebrew — skip

Neither `uv` nor `pipx` is installed (`23-uv-pipx.txt`); not installed, as the plan says.
Homebrew isn't published for candidates.

## M5. Uninstall — pass

Files: `24-uninstall.txt`, `25-installer-uninstall.txt`, `26-leftovers.txt`.

1. **`jetcarp uninstall` showed its plan, and `--yes` did it.** With the host stopped, login off
   and the saver removed in M3, the only step left was `forget the recorded host command`
   (`host-program`); a second run says `Nothing to undo`. It keeps the data folder (1.1 MB)
   unless `--data`, and the settings unless `--settings`; kept on purpose, as on the Acer, so
   rc2 can open rc1's library and settings. **Jimmie's desktop picture is still his**: every
   Space and display shows `~/Pictures/own-picture.png` (same hash),
   apart from the old CART Space, as before rc1. The screen saver selection is still the
   blank "custom" left by `saver remove` (M3 check 10).
2. **The installer's `--uninstall` removed the folder and the link** (Jimmie ran it, because auto
   mode blocks `curl | sh`): `removed ~/.local/bin/jetcarp`, `removed ~/.local/lib/jetcarp`;
   it first reminds you to run `jetcarp uninstall`. `jetcarp` is no longer on the `PATH` (a new
   Terminal: command not found). It leaves **`~/.local/lib` empty**: the installer made it
   (it didn't exist before rc1) and doesn't remove it.
3. **What's left:**
   - `~/Library/Application Support/jetcarp`: `app.json`, `host.json`, `data/library.sqlite`
     (1.06 MB), an empty `data/library.sqlite-jobs/`, an empty `desktop-pictures/`.
   - `~/.cache/jetcarp/host.lock` (0 bytes, from the first `host start`). The cache is under
     `~/.cache`, not `~/Library/Caches`, and `jetcarp paths` doesn't mention it.
   - `~/Pictures/JETCARP/piles/2026-11-12_01-09-24_square-1000000/` (kept on purpose).
   - Nothing in `~/Library/LaunchAgents`, `~/Library/Screen Savers`, `~/Library/Caches`,
     `~/Library/Preferences` or Saved Application State.
