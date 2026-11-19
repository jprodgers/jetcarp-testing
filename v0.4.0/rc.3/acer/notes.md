# rc3 on the Acer: notes

System: `00-system.txt` (Windows 11 Home 26H2, build 26300.9974; i5-13420H, 12 threads; RTX 3050
6GB Laptop + Intel UHD; internal 1920x1080 panel at 100%, work area 1920x1032; on mains). Not run as
administrator.

Before install:
- rc2's settings folder `%APPDATA%\jetcarp` (app.json, host.json, setup.json, empty
  desktop-pictures) was moved aside to `%APPDATA%\jetcarp-rc2-settings` at 01:00, so the wizard sees
  a first run. rc1's are still in `%APPDATA%\jetcarp-rc1-settings`.
- The library in `%LOCALAPPDATA%\jetcarp` was kept (rc1 + rc2: 98 patterns, 30 jobs, rc2's 879
  atlas entries), with the 5.5 MB `library.sqlite-wal` rc2 left behind and rc1's stale 0-byte
  `host.lock`.
- **The user PATH's trailing `;` was put back**, with Jimmie's OK, so check 2 tests the `;;` fix
  (`00-path-before-trailing-semicolon-restored.txt`). rc2's `-Uninstall` had dropped it; the value
  is now exactly the one from before rc1 (ExpandString, `%PNPM_HOME%\bin`).

## A1. Install with the documented command — pass

Files: `01-install-raw.txt`, `00-path-before.txt`, `01-path-after-install.txt` (and the `-type-`
files), `02-version-paths-doctor.txt`.

The installer was first downloaded separately and read in full: it matches the release's
`SHA256SUMS` (`e4471923...c89`); it unpacks into `%LOCALAPPDATA%\Programs\jetcarp`, writes the
user PATH as ExpandString from the unexpanded value, and now trims a trailing `;` before appending.
Then Jimmie ran the README's two lines in a new Windows PowerShell window, in Downloads (auto mode
blocks this session from running installers), the second piped to `Tee-Object` only to keep its
output: installed in a few seconds, exit clean. The file it saved is the same
(`e4471923...c89`), with no Mark of the Web (Invoke-WebRequest doesn't add one).

1. **No Defender or SmartScreen alert: pass.** Jimmie saw none; Defender's detection history still
   has only rc2's two `Commando` detections (2026-11-12 06:51), there are no Defender events
   since 01:00, and no threat is allowed.
2. **The PATH: pass.** Still `ExpandString`, `%PNPM_HOME%\bin` written that way, **no empty
   entry**: the new value is exactly the old one without its trailing `;`, plus
   `;C:\Users\jimmi\AppData\Local\Programs\jetcarp`. (rc2 made `...\.local\bin;;C:\...\jetcarp`.)
3. **`jetcarp --version`: pass.** `jetcarp 0.4.0-rc.3` in a new process with the PATH rebuilt from
   the registry; `paths` shows `bundled: ...\Programs\jetcarp\packs`; `setup --status`: not run
   yet, the starter pack listed, the library seen (98 patterns, 30 jobs, 364 built-in, 79 pack and
   879 search entries in the Quick Start); the Explorer profile now says *about 80 MB and 11
   minutes*. `doctor` stars the RTX 3050 and marks WARP as "software adapter: the GPU simulation
   does not use it". None of these created a settings folder.

## A2. Setup, timed — pass, with three findings

Files: `05-app-terminal.txt` (the app's console: nothing printed), `05-wizard-welcome.png`,
`06-build-poll.txt` (every 10 s: the app's CPU in cores, working set, GPU, and the build job's
status lines), `06-wizard-*.png` (PrintWindow captures of the app), `07-after-build.txt`,
`08-*.png`, `08-quickstart-library.txt` (read-only library queries), `09-*.png`, `10-*.png`.

The app was started with `jetcarp` from this session at 01:04:48 (PATH rebuilt from the registry).
**The wizard opened by itself** on Welcome, over a Quick Start of 1,321 entries (Packs 79, Atlas 879
from rc2's build, Built-in 363: every built-in but rc1's hidden Morley; rc2 showed 306). The window
opened at (163,93), 1402x932, above the taskbar. Starting the app created `%APPDATA%\jetcarp`.

1. **The build: on time.** Jimmie chose Explorer, kept the starter pack and the 10-minute search,
   and pressed Start at **01:06:56** (the job's `created`). No pack import ran: rc2 had already
   imported the starter pack into this library, so `setup.json` lists only job 31.
   - **Start to done: 11 min 11 s** (finished 01:18:07; the job's own count is 11 min 9 s),
     against the wizard's "about 11 minutes" (rc2: 17.5 minutes, one 12-minute step). The search's
     minutes ended at 01:17:03; publishing 900 atlas entries took the last 64 s.
   - **The progress line kept moving.** "N of 10 min" rose by 0.15-0.2 every 10 s from 0.1 to 10,
     never stuck (rc2 froze at 4.3 for 12 minutes). The run count moves in GPU batches of 1,024,
     so it held for up to 100 s at times (14,240-14,288 from 01:13:52 to 01:15:33) while the
     minutes rose. During publishing the line said *"10 of 10 min ... publishing its atlas into the
     Quick Start"* with a full bar for about 65 s (`06-wizard-0117-publishing.png`), then *"Explorer:
     all set"* with **Set up again** and **Close** (`06-wizard-0118-done.png`). Jimmie: "It took
     longer than expected", though it matched the estimate.
   - **The laptop stayed usable** (Jimmie: "didn't slow down the laptop"). Task Manager showed
     jetcarp at 10-90% CPU and at the top of the list. The poll agrees: 6.8 of 12 cores on average
     during the search (1.2 to 10.4), and 10.3 on average while publishing (up to **10.6**, so
     slightly more than "2 left free" for that minute); working set 0.6-1.3 GB; GPU often about
     100% in bursts. Idle with live previews the app uses about 1.1 cores.
   - **`jobs status 31` has the threads line**: *"threads: 6 for runs on the processor and 4 for the
     GPU's batches, of 12 cores (2 left free)"*. Also: *"this session: 49 runs on the processor
     stopped at their time cap (kept ...), 66 runs given up at a stop or the end (not kept)"*.
     17,408 runs, 4,240 elites in 2,328 niches, 216 confirmed, 25 of 1,359 tilings, **900 atlas
     entries published (900 new, 0 updated, 0 removed)**.
2. **Set up again: pass.** It went back to Welcome (`08-set-up-again-welcome.png`); Later closed the
   window.
3. **Help → Setup… opens on Welcome: pass** (Jimmie; the 15 s capture missed it). Closed.
4. **The Quick Start: pass for the built-ins; titles still mixed.**
   - **Sandpiles has its 39 built-ins** (Jimmie, with the Built-in filter; the library agrees).
   - **Langton's ant, WireWorld, Diamoeba and Rule 30 are there** (Jimmie, by search).
   - Atlas titles: Jimmie: **"still many generic"**. Two reasons, from the library
     (`08-quickstart-library.txt`): **rc2's 879 atlas entries are still in the library with their
     old titles** (43 *Fractal Elementary*, 48 *Agents*, 89 distinct titles), because rc3's build
     added its own beside them ("0 updated, 0 removed"), so the menu now shows 1,779 atlas entries;
     and rc3's own 900 are better but still repeat some titles: no *Fractal Elementary*, 11
     *Agents*, *Rule N* and *Turmite …* names, 151 distinct titles, but *Battle JACA* x60,
     *Fractal Hexagonal elementary* x43, *Oscillating Greenberg-Hastings* x41, *Turbulent
     Hodgepodge* x40, *Quiet Hexagonal elementary* x40 (main has changed titles again since rc3,
     per the 2026-11-13 note). Presumably a user who runs setup again after a later version
     changes the titles sees the same: old builds' entries keep their old titles.
   - **Finding: the build's entries don't appear until you open a world and come back.** The menu
     still said 1,321 entries / Atlas 879 after the build was done (01:18), after Later, and after
     Help → Setup… (`08-quick-start-0123-before-reload.png`), though the done page says "New entries
     are in the Quick Start". Opening a card and coming back reloaded it: 2,221 entries, Atlas 1,779,
     Sandpiles 58 (`09-quick-start-0127-after-entry.png`).
5. **The previews carry on: pass.** Jimmie opened the pack's *4.8.8: c/2 orthogonal p16 ship*, ran
   it, and came back: the previews went on from where they were. (That return also brought in the
   900 new entries, so cards moved, but Jimmie could still tell.)
6. **Hunts: pass, with one leftover.** For the pack's hunt #26 (jobs 6-26 are the starter pack's,
   imported in rc2) the detail says *"Imported from pack sha256:a78bbe8d…: its finds came with the
   pack, and nothing ran here"*, with its finds shown, and no "runs until stopped" or "0 soups"
   (`10-hunts-imported-26.png`). **But its row in the list still says "0 soups" and "0 s run"**,
   with an empty *What* column (rc2's pile rows #27-29 read correctly, "1,000,000 grains on Square,
   20 / 20"). Small: the detail names the pack by its hash, not "JETCARP starter pack".

## A3. The desktop fixes — pass

Files: `11-host-start.txt`, `12-host-wallpaper-off.txt`, `12-host-window-laptop.png`,
`13-export-view.png`, `13-export-world.png`, `13-export-embedded-scene.json`,
`13-window-at-export.png`, `13-window-vs-view-export-crop-x3.png`. `host` commands ran from Git
Bash by full path, stdin from `/dev/null`, output to a file. The AOC Q3277 was attached as
`\.\DISPLAY5`, 2560x1440 at x=-2560 (left), work area to y=1392.

1. **No "(not connected)": pass.** With the fresh settings, the first `host start` (01:35:45)
   gave one screen as a **window** on no particular monitor (rotation *A classic a day*, Langton's
   ant), so "(not connected)" couldn't arise there. To repeat rc2's case, screen 0 was put on
   monitor 0 and screen 1 on monitor 1 (`wallpaper on --screen 0 --monitor 0`, `--screen 1
   --monitor 1 --rotation "Classics, hourly"`, as in rc2), then `host stop` and `host start`
   (01:36:23). Its reply: *"screen 0: … · starting · wallpaper on monitor 0"*, *"screen 1: … ·
   starting · wallpaper on monitor 1"*, with no "(not connected)" (rc2's same sequence said
   "(not connected)" for both). At 1 s up it leaves the device names out; `status` 10 s later
   names `\.\DISPLAY1` and `\.\DISPLAY5`.
2. **`wallpaper off` gives ordinary windows: pass.** `host wallpaper on`, then `host wallpaper off`
   (01:37): both screens saved as `"place": "window"` and shown as two windows, *"JETCARP: A
   classic a day"* on the laptop at (71,64) and *"JETCARP: Classics, hourly"* on the AOC at
   (-2489,64), each with a **1280x720 client** (frame 1282x752), title bar, resizable,
   minimize/maximize, not topmost, inside the work area. Their worlds restarted at window size
   (57,600 cells, against 129,600 and 230,400 as wallpaper). Jimmie: ordinary windows he could drag,
   taskbar and his own wallpaper visible around them (they had moved, to (46,78) and (-2323,185), by
   the time of the capture). rc2 opened one full-monitor window per monitor, over the taskbar.
   `host stop`: "stopped", exit 0, no connection error; only the app left running. The registry's
   wallpaper is as before A3 (`TranscodedWallpaper`, sha256 `85ff3bb2…`).
3. **The PNG exports: pass.** In the app, Jimmie opened *JACA B1/S23 — catalog:k4-073* (a k4-073
   tiling, 64,020 cells), paused it at generation 104 and zoomed in.
   - *Export the view as PNG…* → `13-export-view.png`, **1062x850: the window's world area**. Found
     in the window capture at (339,49), right of the side panel, at the same scale; the cells
     match exactly, and the only differing pixels (about 10%) are the cell outlines, anti-aliased
     in the window and drawn aliased in the export (`13-window-vs-view-export-crop-x3.png`: window,
     export, difference in red). rc1 framed the whole tiling instead.
   - *Export the world as PNG…* → `13-export-world.png`, **2400x2393: the whole tiling**.
   - Jimmie: yes to both. Both PNGs carry `jetcarp:version` 0.4.0-rc.3, generation 104, hash
     `4e506491ab27b935` and the scene (identical in both); `jetcarp verify` on the extracted scene:
     `ok: generation 104 hash 4e506491ab27b935`, matching the window's `gen 104 hash 4e506491`.

## A4. Uninstall — pass

Files: `05-app-terminal.txt` (the app's exit), `14-uninstall-plan.txt`, `15-uninstall-yes.txt`,
`16-installer-uninstall.txt`, `17-path-after-uninstall.txt`, `18-leftovers.txt`.

**The app closed cleanly first**: Jimmie closed it with the X at 01:44:44, after a 40-minute session
that used the GPU (the build and the previews): **exit code 0** (read from the launcher holding
the process), no crash dialog, no Application event naming jetcarp. The host had been stopped in A3.

Auto mode blocked this session from running `uninstall --yes` (as in rc2), so the session ran the
plan (no `--yes`) and Jimmie ran both removal steps in a new Windows PowerShell window, in Downloads.

1. **`jetcarp uninstall --yes`: pass** (`15-uninstall-yes.txt`, same as the plan in
   `14-uninstall-plan.txt`). It removed **rc1's stale 0-byte `host.lock`** (dated 2026-11-11
   23:58, left by rc1 and rc2), the empty `library.sqlite-jobs` folder and the recorded host
   command. It **names the kept settings folder** (*"Kept the settings folder
   C:\Users\jimmi\AppData\Roaming\jetcarp; add --settings to delete it."*) as well as the data
   folder (39.1 MB) and the pictures folder, and says **"the installer again with `-Uninstall`"**
   (rc1 and rc2: `--uninstall`).
2. **The installer's `-Uninstall`, as a file: pass** (`16-installer-uninstall.txt`): *"removed
   C:\Users\jimmi\AppData\Local\Programs\jetcarp and took it off your PATH (your settings, data and
   pictures are kept)"*. It first reminds to run `jetcarp uninstall`. No alert.
3. **What is left** (`18-leftovers.txt`), all kept on purpose:
   - `%LOCALAPPDATA%\Programs\jetcarp`: **gone** (`Programs` itself predates the install and the
     marker recorded no folder as made by it).
   - **No 0-byte `host.lock` and no empty folders** anywhere: rc3's settings folder has no
     `desktop-pictures` folder (rc2's had an empty one), and the job-locks folder is gone.
   - `%APPDATA%\jetcarp`: `app.json`, `host.json` (both screens `"window"`, from A3), `setup.json`.
   - `%LOCALAPPDATA%\jetcarp`: `library.sqlite` (10.6 MB), the two search folders (rc2's and
     rc3's builds), `library.sqlite-shm` (32 KB) and **`library.sqlite-wal`, 0 bytes**.
   - `OneDrive\Pictures\JETCARP\piles`: the five piles from rc1 and rc2.
   - The desktop as before: no screen saver, timeout 60, no `JETCARP` Run value, wallpaper
     `TranscodedWallpaper` sha256 `85ff3bb2…`.
4. **The library's WAL: pass.** With the app closed, `library.sqlite-wal` is **0 bytes**
   (truncated at 01:44:43, the moment the app quit); `library.sqlite` grew from 6.1 to 10.6 MB and
   was written at the same moment, so rc2's 5.5 MB WAL and this session's changes are in the main
   file. (rc2 left 5.5 MB in the WAL with `library.sqlite` an hour stale.)
5. **The PATH: pass.** Still `ExpandString`, `%PNPM_HOME%\bin` written that way, no JETCARP entry,
   no empty entry; a new shell can't find `jetcarp`. It equals the value before install **without
   its trailing `;`**: the install trims a trailing `;` before appending (the `;;` fix, A1) and
   `-Uninstall` doesn't put it back. Harmless, and the same as after rc2.

### After the wave

- Microsoft Defender: nothing to undo. rc2's *Allow* for `Commando.C!ml` was removed in rc2, and
  rc3 raised no alert; at 01:50 no threat is allowed and the history has only rc2's two detections.
- The PATH stays without its trailing `;` (Jimmie: leave it off).
- Deleted with Jimmie's agreement: rc1's and rc2's moved-aside settings
  (`%APPDATA%\jetcarp-rc1-settings`, `-rc2-settings`: app.json, host.json, setup.json and an empty
  `desktop-pictures` each), and `Downloads\jetcarp-installer.ps1` (the checked rc3 installer).
- Kept: rc3's settings in `%APPDATA%\jetcarp` (host.json with both screens `"window"`), the library
  in `%LOCALAPPDATA%\jetcarp` (rc1 + rc2 + rc3, both builds' atlas entries), the piles in
  `OneDrive\Pictures\JETCARP`.
