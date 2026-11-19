# Notes between sessions: the 0.4.0 cycle

Newest last. Date each note and name the machine.

## 2026-11-11, Framework (main session)

Repository created. `rc1.md` will appear here once `v0.4.0-rc.1` is built. Until then there is
nothing to run.

## 2026-11-11 (late), Framework (main session)

`v0.4.0-rc.1` is published: https://github.com/jprodgers/jetcarp/releases/tag/v0.4.0-rc.1
(a pre-release with archives for five targets, five wheels, both installers and SHA256SUMS). The
shell installer was checked end to end on Linux. **The PowerShell installer has never been run
before: the Acer is its first real test**, so record exactly what it prints.

Order: the **Acer first** (`rc1.md`, section "Acer"), then the Mac. Push results after each section.

## 2026-11-12 (00:20), Acer

rc1 on the Acer: A1, A2 and A3 checks 1-10 are done and pushed (`rc1.md` table rows A1, A2;
details in `results/rc1/acer/notes.md`). Main findings so far: the PowerShell installer rewrites
the user PATH as REG_SZ (expanding `%PNPM_HOME%`); the app crashed silently on close once
(0xC0000005 in `nvoglv64.dll_unloaded`); the host caption sits under the taskbar; one still for
two monitors; `saver remove` fails while the Screen Saver Settings dialog is open; `host start`
hands its stdout pipe to the host. `host stop` printed no connection error (twice).

**Paused at A3 check 11 for a real sign-out.** `jetcarp host login on` is set (Run key `JETCARP`
= `"...\jetcarpw.exe" host serve`; Jimmie ran it himself, because Claude Code's auto mode blocks
it). Jimmie is signing out and back in, which ends the Claude session. Next, in this order:

1. `jetcarp host status`: did the host start by itself? Ask Jimmie whether a console window
   appeared at sign-in. Check the processes (`jetcarpw.exe` → `jetcarp.exe host serve`).
2. Check 12: `jetcarp host login off` (if auto mode blocks it too, Jimmie runs it); check that the
   Run value is gone; `jetcarp host stop`; fill in the A3 row; commit and push.
3. A4: skip (neither uv nor pipx is installed; don't install without asking).
4. A5: uninstall. The output folder here is `C:\Users\jimmi\OneDrive\Pictures\JETCARP` (Pictures
   is in OneDrive), so check there as well as `$env:USERPROFILE\Pictures\JETCARP`. Afterwards,
   compare the user PATH with `results/rc1/acer/00-user-path-before.txt`; the original raw value
   is in the first session's scratchpad,
   `C:\Users\jimmi\AppData\Local\Temp\claude\SESSION\SESSION\scratchpad\user-path-raw-before.txt`.
   Ask Jimmie whether to put it back (REG_EXPAND_SZ with `%PNPM_HOME%\bin`); it's a registry edit.

## 2026-11-12 (00:40), Acer

**The Acer section of rc1 is done** (`rc1.md` table; details and evidence in
`results/rc1/acer/notes.md`). A1 pass, A2 pass, A3 pass except checks 3 and 10, A4 skip (no uv or
pipx), A5 pass. Start at login was tested with a real reboot. `host stop` printed no connection
error in three stops. For the main session, most important first:

1. **The app crashed silently on close once**: 0xC0000005 in `nvoglv64.dll_unloaded` (NVIDIA
   OpenGL/Vulkan driver 31.0.15.4618), exception data 8 (executing code in the unloaded DLL), after
   an 18-minute session that used the GPU. Not reproduced in two shorter sessions; CLI GPU runs
   exit cleanly. WER details in `11-app-exit-crash.txt`.
2. **`saver remove` fails while the Screen Saver Settings dialog is open** (`Access is denied`,
   because the dialog's preview runs from the `.scr`). It deselects the saver but leaves the file,
   and then `saver status` says "another one is selected". `saver install` opens that dialog, so
   install-then-remove hits it.
3. **The PowerShell installer rewrites the user PATH** as REG_SZ with `%VAR%` entries expanded
   (install and `-Uninstall`). Jimmie's PATH has been restored by hand.
4. **`host wallpaper off` saves screens as windows**, so the next login opened them as ordinary
   windows over the desktop.
5. **The host caption sits under the taskbar** (placed against the monitor, not its work area).
6. **The still is one picture for all monitors** (screen 0's), so a second monitor shows screen 0.
7. **`jetcarp host start` passes its stdout/stderr to the host**: piping or capturing its output
   hangs until the host stops.
8. Smaller: the app window opened partly under the taskbar; the status bar says "Running" while
   paused; an opened scene starts running at once; `jetcarp.exe` has no version resource;
   `uninstall`'s Windows hint says `--uninstall`; it leaves a 0-byte `host.lock` and empty folders;
   the plan's Pictures path is wrong where Pictures is in OneDrive.

Settings and data are kept on the Acer on purpose, so rc2 can test opening rc1's library and
settings. **Next: the Mac section.**

## 2026-11-12 (01:55), Mac

rc1 on the Mac: M1, M2 and M3 checks 1-10 are done and pushed (`rc1.md` rows M1, M2; details
in `results/rc1/mac/notes.md`). Main findings so far: one still for both monitors (as on the
Acer); `saver remove` leaves macOS's screen saver selection pointing at the deleted
`JETCARP.saver`; the saver animates a hidden view for a while after it's chosen; the Dock says
`jetcarp` (lowercase), and the host's Dock icon is the generic "exec" icon; `host status` names
monitors by product ID (`Monitor #41041`). The app quit cleanly twice (no crash on close).

**Paused at M3 check 11 for a real reboot.** `jetcarp host login on` is set: it wrote
`~/Library/LaunchAgents/com.jimmieprodgers.jetcarp.host.plist` (`~/.local/bin/jetcarp host serve`,
`RunAtLoad`); macOS showed a notification (Jimmie clicked it before reading it; it opened System
Settings, where jetcarp is listed under background app activity). `wallpaper on` is saved for both
screens (screen 0 → monitor 0, the laptop; screen 1 → monitor 1, the AOC Q3277 to its left,
rotation "Classics, hourly"). Auto mode did **not** block `login on` here; it **did** block
`curl ... | sh` (and running the downloaded script), so Jimmie ran the install line. Next, in
this order:

1. `jetcarp host status`: did the host start by itself? Ask Jimmie: did a Terminal window
   appear, any notification, and does the live wallpaper show on both monitors (if the AOC is
   attached)? Check the process (`ps -axo pid,ppid,etime,command | grep jetcarp`: parent should
   be launchd) and `launchctl print gui/$(id -u)/com.jimmieprodgers.jetcarp.host`.
2. Check 12: `jetcarp host login off`; check the plist is gone and System Settings no longer
   lists jetcarp in the background items; `jetcarp host stop`; ask Jimmie whether the normal
   wallpaper is back; fill in the M3 row (pass except 6's one still for both monitors; 10 with
   the dangling selection); commit and push.
3. M4: skip (neither uv nor pipx is installed; don't install without asking).
4. M5: uninstall as the plan says. Auto mode will probably block the installer's
   `curl ... | sh -s -- --uninstall`, so give Jimmie the line (with `| tee` into
   `results/rc1/mac/25-installer-uninstall.txt`). Compare the wallpaper with
   `results/rc1/mac/12-wallpaper-choices-before.txt` (Jimmie's picture is
   `~/Pictures/own-picture.png`, sha256 `40dfaec9...79ffd6`). Look for
   leftovers in `~/Library/Application Support/jetcarp`, `~/Library/Caches/jetcarp`,
   `~/.cache/jetcarp`, `~/Pictures/JETCARP`, `~/Library/LaunchAgents`, `~/Library/Screen Savers`.

Known state that isn't rc1's to fix: `~/Library/Application Support/cart/` and one Space whose
desktop picture is a deleted CART still (shows a cached Wolfram picture); the screen saver
selection is a blank "custom" (Jimmie may choose one again; idle time is back to Never). Tips:
`log` is a zsh builtin here, use `/usr/bin/log`; Claude Code has no Screen Recording or
Accessibility permission, so no screenshots; send `host start`'s output to a file, not a pipe.

## 2026-11-12 (02:10), Mac

**The Mac section of rc1 is done** (`rc1.md` table; details and evidence in
`results/rc1/mac/notes.md`). M1 pass, M2 pass except the Dock name, M3 pass (with findings),
M4 skip (no uv or pipx), M5 pass. Start at login was tested with a real reboot. `host stop`
printed no error in four stops. The app quit cleanly with Cmd+Q and with the red button (no
crash on close). The GPU sandpile (11,583,796,400 topplings) and the soup hunt (213,586 objects,
64 distinct) gave **exactly the Acer's numbers**, at about twice the speed. For the main session,
most important first:

1. **The still is one picture for all monitors** (screen 0's, at the laptop's pixel size), now
   seen on macOS as on Windows: the AOC showed the laptop's ant instead of its own scene. On macOS
   it is also written only to the Space showing on each display; `still off` put Jimmie's
   picture back everywhere it had gone.
2. **`saver remove` leaves macOS's screen saver selection pointing at the deleted
   `JETCARP.saver`** (every display and Space, in the wallpaper store); System Settings shows a
   blank "custom" tile, and the user's earlier choice isn't put back. System Settings, if open,
   keeps listing JETCARP until it's reopened. (Unlike the Acer, removing works with it open.)
3. **The saver animates a hidden view**: right after JETCARP was chosen, macOS made a full-screen
   view ahead of time and the saver drew about 3,700 frames at 4112x2658 on the GPU for two
   minutes before the saver really started (`20-saver-system-log.txt`).
4. **Names and icons on macOS**: the app shows as `jetcarp` (lowercase) in the Dock and menu bar
   (no bundle name); the host's Dock icon is the generic "exec" icon (the app has the hexagon);
   `host status` names monitors by product ID in decimal (`Monitor #41041` = the built-in
   display, `#12919` = AOC Q3277) instead of macOS's display names.
5. **Export PNG frames the whole tiling, not the view** (Jimmie noticed it's tighter than the
   window; the Acer's export was framed the same way).
6. Confirmed from the Acer: `wallpaper off` turns screens into windows; an opened scene starts
   running at once.
7. Smaller: `login off` deletes the LaunchAgent plist but doesn't unload the job (it stays in
   `launchctl` until logout, not running); the installer leaves an empty `~/.local/lib`;
   uninstall leaves a 0-byte `~/.cache/jetcarp/host.lock` and empty folders; doctor looks for
   packs in `~/.local/lib/share/jetcarp/packs`; the installer repeats the version in "such as
   0.4.0-rc.1 or 0.4.0-rc.1"; Langton's ant on the wallpaper runs its highway into the edge of
   a finite board; one screen was sluggish for a few seconds after login (load average 15 at
   boot).

What worked well: caption in the lower left, clear of the menu bar, notch and Dock; the live
wallpaper on every Space and in Mission Control, with no JETCARP window in it; battery pause;
the saver on both monitors; no Gatekeeper dialog (no quarantine mark). Auto mode blocked
`curl ... | sh` (Jimmie ran the installer both times) but not `login on`.

Settings and data are kept on the Mac on purpose, as on the Acer, for rc2. Not rc1's: the old
CART build's `~/Library/Application Support/cart/` and a Space showing a deleted CART still.
**Next: the Framework checklist (Jimmie, by hand), then rc2.**

## 2026-11-12 (early), Framework (main session)

RC1 is complete on both laptops: thank you. Before rc2, **the Acer has one debugging task**:
`debug-host-start.md` (about 20 minutes, building from source). rc2's plan is in `rc2.md`; it
starts once `v0.4.0-rc.2` is published (not yet).

## 2026-11-12 (04:55), Acer

`debug-host-start.md` is done, on jetcarp main at `c5a58fc`. Results are in `results/rc2-debug/acer/`.
**The new launch code isn't the cause: keep it.** CI's host dies because Windows' software
renderer crashes on the default rotation's Life scene, however the host was started.

1. On the Acer's real GPUs everything passes. The test passed once plus 10 repeats; the host
   lived when started by hand with `--headless` (Intel UHD), without `--headless` (RTX 3050,
   window and tray) and through `jetcarpw.exe` with `Start-Process`. `host stop` ended each host
   with exit code 0, so the exit crash fix holds here. With `host start`'s output on pipes, it
   returned in 2.8 s and its pipes closed with it, so the rc1 hang is gone.
2. CI has no GPU, so wgpu uses WARP ("Microsoft Basic Render Driver"). jetcarp can't be told to
   pick it, so the throwaway clone got a two-line debug switch (`07-debug-switch.diff`,
   `force_fallback_adapter`; not pushed). On WARP the step 1 test **fails exactly as on CI**
   (10054, `alive: Some(false)`). The host crashes with **0xC0000005 in `d3d10warp.dll`
   10.0.26100.9818, offset `0x3aabfd`**, the same in all 7 crashes, about 2 to 5 s after start.
3. What decides it, on WARP (`08-warp-matrix.txt`): rotation "A classic a day" (the default,
   profile Life) crashes whether started by `host start`, `jetcarpw.exe` or directly, at
   1280x720 or 160x120, with pause rules on or off. "Wolfram series" lives, and every direct host
   test on CI uses it. The Life scene lives with `"gpu": false` in `host.json`. So the crash is
   in WARP while the host steps Life on the GPU. CI's `host start` test is the only one on the
   default rotation.
4. Suggestions: give that test `--rotation "Wolfram series"` (or test Life on WARP on purpose);
   look at the GPU Life stepping on WARP, or don't step on the GPU when the adapter is the
   fallback/CPU type, since a real user without a GPU would hit this. No debugger is installed
   here, so there's no symbolized stack. Smaller: `jetcarpw.exe` returns `code.clamp(0, 255)`,
   so a host crash (negative i32) comes out as exit code 0 (from reading the code).

Cleaned up: the clone, `jetcarp-debug-home` and the build log are deleted. The real rc1 settings
and library weren't touched (last written during rc1). The CI run for `c5a58fc` was still in its
Windows Test step at 04:55.

## 2026-11-12 (morning), Framework (main session)

Thank you for the debugging run: it found the WARP crash, and main now refuses WARP for GPU
stepping and touches nothing on the GPU at exit. CI is green on all three systems.

**`v0.4.0-rc.2` is published:** https://github.com/jprodgers/jetcarp/releases/tag/v0.4.0-rc.2.
It has the setup wizard, the starter pack (79 entries), the rc1 fixes and the WARP fix. The shell
installer was checked end to end on Linux: `bundled:` shows the starter pack.

Follow `rc2.md`, **the Acer first**, then the Mac. The Mac-only fixes are not in rc2 (they come in
rc3).

## 2026-11-12 (06:58), Acer

rc2 A1 is done and pushed (`rc2.md` row A1; details in `results/rc2/acer/notes.md`). **Microsoft
Defender blocked the documented install line** (`powershell -ExecutionPolicy Bypass -c "irm
.../v0.4.0-rc.2/jetcarp-installer.ps1 | iex"`) as `Trojan:Win32/Commando.B!ml` and `.C!ml`,
Severe: it flags the command line itself (cloud ML, FastPath), before the script runs. rc1's same
line had no detection. The same script saved and run with `-File` installed with no alert, and the
PATH fix works (ExpandString and `%PNPM_HOME%\bin` kept). Jimmie allowed `Commando.C!ml` on the
device; undo it after the wave. rc1's settings are in `%APPDATA%\jetcarp-rc1-settings`. Next: A2,
the wizard.

## 2026-11-12 (08:00), Acer

rc2 A2 and A3 checks 1-11 are done and pushed (`rc2.md` rows A2, A3; details in
`results/rc2/acer/notes.md`). Main findings so far: the Explorer build took 17.5 min against
"about 11" (one 12-minute search step, progress frozen, 10.5 of 12 cores busy); 57 built-in
examples are hidden once the atlas exists (dedupe by rule only: 34 sandpiles, Langton's ant...);
Help → Setup… shows only the done page (Close) for the rest of the session in which setup ran;
rc1's pile jobs read as empty. The rc1 fixes checked so far all hold (no crash on close in three
GPU sessions; caption above the taskbar; one still per monitor; `saver remove` with the dialog
open; `host start | tee`).

**Paused at A3 check 12 for a real reboot.** State: `host wallpaper off` (both screens saved as
`"place": "window"` in `host.json`, and shown as full-monitor windows), then Jimmie ran
`jetcarp host login on` (auto mode blocks it): Run value
`JETCARP = "...\jetcarpw.exe" host serve --login`. The AOC is attached. Next, in this order:

1. Ask Jimmie, one at a time: did any JETCARP windows open at sign-in? A console flash? Is the
   host's icon in the tray (notification area, maybe under the ^ overflow)? Then check
   `jetcarp host status`, the processes (`jetcarpw.exe host serve --login` → `jetcarp.exe`;
   parent Explorer) and that `host.json` still says `"window"`.
2. `jetcarp host login off` (Jimmie runs it if auto mode blocks it); the Run value gone;
   `jetcarp host stop`; fill in check 12 and the A3 row; commit and push.
3. A4, MCP with Claude Code, as `rc2.md` says. Jimmie runs `claude mcp add jetcarp -- jetcarp mcp`
   and the new Claude Code session in a separate terminal; save the trimmed tool calls to
   `results/rc2/acer/mcp-session.md`; then `claude mcp remove jetcarp`.
4. A5, uninstall: `jetcarp uninstall --yes`; then the installer's `-Uninstall`, **as a file**
   (`irm | iex` is blocked by Defender and by auto mode): the checked rc2 installer is at
   `C:\Users\jimmi\AppData\Local\Temp\claude\SESSION\SESSION\scratchpad\installer\jetcarp-installer.ps1`
   (sha256 `3ecf341a...25cc5`; download again if Temp was cleaned), so
   `powershell -ExecutionPolicy Bypass -File <that> -Uninstall` (Jimmie may need to run it).
   Compare the PATH with `results/rc2/acer/00-path-before.txt` (expect the trailing `;` to be
   dropped; ask Jimmie before writing it back). Leftovers: `%APPDATA%\jetcarp`,
   `%LOCALAPPDATA%\jetcarp`, `%LOCALAPPDATA%\Programs\jetcarp`, `OneDrive\Pictures\JETCARP`.
5. After the wave, ask Jimmie about: removing Defender's *Allow* for `Commando.C!ml` (Windows
   Security → Virus & threat protection → Protection history / Allowed threats); putting rc1's
   settings back from `%APPDATA%\jetcarp-rc1-settings` (or deleting them); the registry
   `WallPaper` now names `...\Themes\TranscodedWallpaper` instead of `img20.jpg` (same picture);
   `OneDrive\Desktop\testscene.json` (Jimmie's A3 scene).

Tips: in Git Bash use the full path `/c/Users/jimmi/AppData/Local/Programs/jetcarp/jetcarp.exe`
(VS Code's PATH predates the install); in PowerShell rebuild PATH from the registry. Auto mode
blocked `irm | iex`, `host saver install` and `host login on`; Jimmie ran them.

## 2026-11-12 (08:10), Framework (main session)

Thanks for A1-A3 so far. Fixed on main for rc3:
- Windows install: save then run (in the book and README).
- 57 hidden built-ins: the menu now shows every entry.
- Help → Setup… after a setup: it reopens at Welcome, and the done page has *Set up again*.
- Repeated atlas titles: they now read "Rule 150", "Ant RRL" and so on.
- The imported hunts in the Hunts window: they say "Imported from pack …".
- The job count includes job 0: fixed.
- The small pack description font.
- The source-file tooltip on JACA cards.
- Previews restarting when you come back to the Quick Start: they now keep going from where they
  were.

rc2 was tagged a few minutes **before** the fix that makes a build end on time (8d3dd33), so
the 17.5-minute build is rc2's. rc3 re-times it on both laptops. The Mac plan's M2 step 2 now says
to restart the app before Help → Setup…, and expects an overrun. **Acer: carry on as your notes
above say (check 12, then A4 and A5).**

## 2026-11-12 (08:35), Acer

**The Acer section of rc2 is done** (`rc2.md` table; details and evidence in
`results/rc2/acer/notes.md`). A1 fail at step 2 (Defender; the install as a file passes), A2 pass
except check 5, A3 pass, A4 pass with one finding, A5 pass. Your 08:10 note already covers the
Defender install line, the hidden built-ins, Help → Setup…, the atlas titles, the imported hunts,
the job count, the pack font, the JACA tooltip, the restarting previews and the build overrun.
New since then, or not on that list, most important first:

1. **MCP in Claude Code: the user never sees a rendered picture** (A4). The model called
   `world_render` without `save_path`, so no file was written, and Claude Code's terminal doesn't
   show a tool's image, yet its answer said "the picture above". Tutorial 6 says the assistant
   "shows it to you", which holds for Claude Desktop. Otherwise A4 was clean: 9 calls, no errors,
   and **the Brian's Brain hash `c38568895709dcc6` and every 20,000-soup count match the tutorial
   exactly** on Windows.
2. **The library's write-ahead log is left behind** (A5): `library.sqlite-wal` (5.5 MB) and `-shm`
   stay after everything has exited; `library.sqlite` was last written at 07:22, so the last hour
   (app sessions, the MCP hunt) is only in the WAL. Fine while the files stay together, but a copy
   of `library.sqlite` alone loses it. It was already there before the MCP session, so the app or
   the host closes the library without a checkpoint.
3. **`host wallpaper off` still opens both screens as full-monitor windows at once** (rc1 finding,
   unchanged). Login after it is fixed: on a real reboot nothing opened and the host sat in the
   tray; its *Show on the desktop* brought the live wallpaper back on both monitors and saved them
   as `"wallpaper"`.
4. Smaller, new: `still off` now leaves the registry's `WallPaper` naming Windows' cached
   `TranscodedWallpaper` instead of the original file (same picture); `host start`'s first reply
   calls both monitors "(not connected)" (`status` 10 s later names them); WER logged
   RADAR_PRE_LEAK_64 during the build (working set about 1.1 GB); rc1's pile jobs read as empty in
   rc2; the installer appends `;;` when the PATH ends in `;` (`-Uninstall` then drops the original
   trailing `;`).
5. Smaller, from rc1 and unchanged: `uninstall`'s Windows hint still says `--uninstall`, and it
   doesn't mention the kept settings folder; rc1's 0-byte `host.lock` is still there; the empty
   `desktop-pictures` folder stays.

The rc1 fixes all hold on the Acer: no crash on close (3 GPU sessions, exit 0), pause in both bars,
scenes open paused, the window's place, the Quick Start order, the badge, the caption above the
taskbar, one still per monitor, `saver remove` with the dialog open, `host start | tee` (0.7 s),
`host status`, and the PATH keeps `ExpandString` and `%PNPM_HOME%\bin` through install and
uninstall. Auto mode blocked `irm | iex`, `host saver install`, `host login on` and
`uninstall --yes` (Jimmie ran them), but not `host login off`.

State left on the Acer: rc2's settings in `%APPDATA%\jetcarp` (both screens `"wallpaper"`), rc1's
in `%APPDATA%\jetcarp-rc1-settings`, the library (rc1 + rc2) in `%LOCALAPPDATA%\jetcarp`, the piles
in `OneDrive\Pictures\JETCARP`. Defender's *Allow* for `Commando.C!ml` is removed (checked).
**Next: the Mac section of rc2.**

## 2026-11-12 (afternoon), Framework (main session)

Thank you for the Acer's rc2 wave (A1-A5 all done). **`v0.4.0-rc.3` is published:**
https://github.com/jprodgers/jetcarp/releases/tag/v0.4.0-rc.3. Its plan is `rc3.md`.

**The Mac skips rc2** and runs rc3's Mac section, which carries rc2's Mac-only steps: Desktop art,
a second setup into its own data folder, and MCP with Claude Desktop (optional). Jimmie's usage is
short, so keep each step brief. M3 (the Mac fixes) and M4 (uninstall) matter most.

What changed since rc2, for context:
- **Builds end on time.** CPU runs are capped, a GPU batch is given up at the end, progress is
  written every 2 s, and two cores are left free (`jobs status` shows a *threads:* line).
- **The Quick Start** shows every entry again; atlas titles read like *Rule 150*; previews keep
  going while you're in a world.
- **Setup:** Help → Setup… reopens at Welcome, and the done page has *Set up again*.
- **The host's window screens** are ordinary windows, not full-screen (`wallpaper off`).
- **The library** is checkpointed when the app quits (no `library.sqlite-wal` with data).
- **`uninstall`** names the settings folder it kept.
- **`world_render`** tells the model to save the picture when the user wants it.
- **The Mac fixes from rc1** (in rc3 for the first time): the JETCARP name in the menus, no host
  icon in the Dock, macOS's monitor names, the saver's hidden animation, `saver remove` putting
  back your choice, and *Export the view as PNG…*.

The Acer's short rc3 wave (`rc3.md`, section Acer) can come any time after the Mac's.

## 2026-11-13 (early), Framework (main session)

Mac M1 and M2: thank you. Two answers and one request:
- "2 jobs" where the table has 3 rows is intended: job 0 holds the patterns added by hand and isn't
  counted.
- Atlas titles: changed on main (for 0.4.0). A short rule notation now names a card (*Battle JACA
  +B3/S23 -B37/S23*, *Fractal HexW3 5033*); rc3 doesn't have this yet.
- **Request, when convenient (a minute):** `setup --status` left out the build (job 2), and the
  main session can't reproduce that. Please save these three outputs to
  `results/rc3/mac/10-setup-jobs.txt`:
  - `jetcarp setup --status --json`
  - `cat ~/Library/Application\ Support/jetcarp/setup.json`
  - `jetcarp jobs status 2 --json | head -c 3000`

  Then carry on with M3.

## 2026-11-13 (00:25), Mac

rc3 M1, M2 and M3 are done and pushed (`rc3.md` rows; details in `results/rc3/mac/notes.md`).
**Your request:** `results/rc3/mac/10-setup-jobs.txt`. **Sorry: the missing build was my mistake.**
I had cut `setup --status` with `head -12`, which ended just before job 2. The full output, text
and JSON, lists both jobs (pack import 1 and the Quick Start build 2). Nothing to fix there.
Thanks for the answers on the job count and the titles. M4 (uninstall) is next; M5 (MCP with
Claude Desktop) depends on Jimmie's time.

## 2026-11-13 (00:50), Mac

**The Mac section of rc3 is done** (`rc3.md` table; details and evidence in
`results/rc3/mac/notes.md`). M1 pass, M2 pass, M3 pass except the Dock name, M4 pass, M5 pass with
one finding. The rc3 fixes hold on the Mac: the build ends on time (**10 min 42 s** for a 10-minute
search: 10 min plus 40 s publishing 1,070 atlas entries; progress never stuck; *threads:* "(2 left
free)", peak 10.4 of 12 cores); *Set up again* without a restart; Sandpiles has its 39 built-ins;
previews resume where they were; *imported from pack* in Hunts; JETCARP in the menu bar, About and
Quit; no host icon in the Dock; `Built-in Retina Display` / `Q3277`; `wallpaper off` gives one
ordinary movable window; **the saver drew 1 frame after being chosen (rc1: about 3,700)** and still
starts and animates; **`saver remove` put Flurry back** (wallpaper store identical to before);
*Export the view* is the window's close-up and *Export the world* the whole tiling; the library's WAL
is 0 bytes after quitting; `uninstall` names both kept folders; MCP in Claude Desktop gives
`c38568895709dcc6` and every 20,000-soup count exactly; AI control drives the window.

Findings, most important first:
1. **Tutorial 6's first prompt doesn't reach the tools in Claude Desktop** (5.1231.2): *"Run Brian's
   Brain on a 120 by 80 square grid for 200 generations and show me."* got an artifact with the
   model's own simulation and no tool call. "Use the JETCARP tools to …" worked at once. Also, this
   Claude Desktop lists servers under *Settings → Customize*, not *Settings → Developer → Edit
   Config*. The bare `jetcarp` command works (it passes the login shell's PATH).
2. **The Dock still says `jetcarp`** when you hover over the app (the menus are fixed).
3. **`saver install` with System Settings already open**: it isn't listed until System Settings is
   quit and reopened (that one had been open since rc1). `install` could say so, as `remove` now does.
4. Atlas titles: elementary (*Rule N*) and turmites are named, but *Battle JACA* x60, *Forest fire*
   x59, *Fractal Layered* x56, *Fractal Hexagonal elementary* x46 repeat (your note says main has
   changed this).
5. Smaller: the Hunts window's status section says "0 soups" for an imported hunt (the job line
   is right); the first return to the Quick Start after the build came back in a different order
   (once; later kept); `host start` while running exits 1 ("already running"); `jetcarp verify`
   can't read an exported PNG (it expects scene JSON); after uninstall, the kept `paths.json` names
   the Researcher folder the plan then deletes; rc1's pile job still reads as empty.

State left on the Mac: rc3's settings and the library (rc1's entries) in
`~/Library/Application Support/jetcarp/`; `~/Pictures/JETCARP` (rc1's pile, M5's picture and
scene). After the wave, with Jimmie's agreement: rc1's moved-aside settings (and the untouched copy
of rc1's library) went to the Trash, and the empty `~/.local/lib` was removed; the Researcher
folder is in the Trash too. Jimmie chose Flurry
as the screen saver for the test (the selection had pointed at rc1's deleted saver). Claude
Desktop's config is as before. **The Acer's rc3 section can go next.**

## 2026-11-13 (01:55), Acer

**The Acer section of rc3 is done** (`rc3.md` table; details and evidence in
`results/rc3/acer/notes.md`). A1 pass, A2 pass with findings, A3 pass, A4 pass. The fixes hold on
Windows:
- **Install:** the README's save-then-run lines raised no Defender or SmartScreen alert; the PATH
  stays ExpandString with `%PNPM_HOME%\bin` and **no `;;`** (the trailing `;` was put back first so
  this was a real test).
- **The build ends on time: 11 min 11 s** Start to done for "about 11 minutes" (rc2: 17.5): 10 min
  of search, then 64 s publishing 900 atlas entries. The minutes rose every 10 s with no stall;
  *threads:* "(2 left free)"; the laptop stayed usable (Jimmie). Set up again and Help → Setup… open
  on Welcome; Sandpiles has its 39 built-ins; the four classics are back; previews carry on.
- **The desktop:** no "(not connected)" in `host start`'s reply with two screens bound to the two
  monitors; `wallpaper off` gives ordinary 1280x720 windows, movable, inside the work area; *Export
  the view* is exactly the window's world area (only the outlines' anti-aliasing differs) and
  *Export the world* the whole tiling, both with a scene that verifies.
- **Uninstall:** names the kept settings folder and `-Uninstall`; removed rc1's stale `host.lock`
  and the empty job-locks folder; no empty folders left; **`library.sqlite-wal` 0 bytes** after the
  app quit (exit 0 after 40 minutes on the GPU).

Findings, most important first:
1. **A finished build's entries don't show in the Quick Start until you open a world and come
   back.** The menu said 1,321 entries / Atlas 879 after the build was done, after Later and after
   Help → Setup…, though the done page says "New entries are in the Quick Start". Returning from a
   card reloaded it (2,221, Atlas 1,779).
2. **A new build adds to an older build's atlas without retitling or replacing it**
   ("900 new, 0 updated, 0 removed"). rc2's 879 entries keep their old titles (43 *Fractal
   Elementary*, 48 *Agents*), so Jimmie saw "still many generic" titles. rc3's own 900 are better
   (no *Fractal Elementary*, 11 *Agents*, 151 distinct titles) but repeat some as on the Mac
   (*Battle JACA* x60, *Fractal Hexagonal elementary* x43); your note says main has changed this.
3. **The imported hunt's row in the Hunts list still says "0 soups", "0 s run"**, with an empty
   *What* column; the detail below is fixed (*"Imported from pack sha256:a78bbe8d…: its finds came
   with the pack, and nothing ran here"*). It names the pack by hash, not "JETCARP starter pack".
4. Smaller: publishing the atlas used up to **10.6 of 12 cores** for its minute (the search averaged
   6.8, peak 10.4), slightly more than "2 left free"; Jimmie felt the build "took longer than
   expected" although it matched the estimate, perhaps because the line sits at "10 of 10 min" while
   publishing.

State left on the Acer: rc3's settings and the library (rc1-rc3) are kept, along with the piles.
rc1's and rc2's moved-aside settings and the downloaded installer are deleted. The PATH has no
trailing `;` (Jimmie: leave it). Defender allows no threats. **Next: nothing for the Acer until
the next build.**

## 2026-11-13 (12:40 UTC), main session

**JETCARP 0.4.0 is released** (published 10:01 UTC): the GitHub release (marked latest), PyPI
(`pip install jetcarp`), crates.io (all 12 crates; `cargo install jetcarp` works), Zenodo (DOI
10.5281/zenodo.24191765 for every version, 10.5281/zenodo.24191766 for 0.4.0), and a Homebrew tap
and a Scoop bucket made today. The tap and the bucket are now written automatically when a release
is published.

Since rc3 the release has these fixes, which neither laptop has seen: the Quick Start shows a
finished build's entries about a second later on any screen (the Acer's finding 1); the Hunts list
shows a pack's hunt as imported, from a pack, with no run time, and its detail names the pack's
feed (the Acer's finding 3; the Mac's "0 soups"); untitled atlas cards carry a short rule notation
(the Mac's finding 4); `jetcarp verify` and the other scene commands read a PNG JETCARP exported;
`host saver install` on macOS says to reopen System Settings if it was open.

**Next wave: `v0.4.0.md`,** the release installed with Homebrew (Mac) and Scoop (Acer), plus the
fixes above and whether the recorded paths survive a package manager's upgrade. One machine at a
time, in either order; Jimmie runs them one after the other. Nothing here can change 0.4.0: record
failures exactly, and they go into 0.4.1. Known and not to re-test: a kept `paths.json` can name a
folder that was deleted (H1/H2 only record what happens); older builds' atlas entries keep their old
titles; the macOS Dock tooltip says *jetcarp* (needs an app bundle).

## 2026-11-13 (09:30), Mac

**The Mac section of v0.4.0 is done** (`v0.4.0.md` table; details and evidence in
`results/v0.4.0/mac/notes.md`). H1 pass, H2 pass, H3 pass (titles only partly), H4 pass, H5 done.
Homebrew works and the fixes since rc3 hold on the Mac:
- **Install:** `brew install jprodgers/jetcarp/jetcarp` (Homebrew 7.0.12) tapped and installed in
  **8 s**, exit 0; `/opt/homebrew/bin/jetcarp`, `jetcarp 0.4.0`; `brew test` passes; the saver
  dylib is in `lib/jetcarp`; the formula's checksums match `SHA256SUMS`. No Gatekeeper dialog.
- **The build:** Explorer with a 2-minute search, **2 min 24 s** Start to done, 713 atlas entries,
  and **the Quick Start showed them (Atlas 713) after *Later* without opening a world.**
- **Hunts:** the pack's hunt row says *imported*, *–*, *from a pack*; the detail names the feed.
- **`jetcarp verify` reads both exported PNGs** (view and world): `ok: generation 39 hash
  3a01f78fa4521000`.
- **Paths that survive `brew upgrade`:** the LaunchAgent runs `/opt/homebrew/bin/jetcarp host serve
  --login`; `host-program` says `/opt/homebrew/bin/jetcarp host serve`; `saver install` found the
  saver's code and wrote a self-contained bundle naming no Homebrew path; `saver remove` left
  Flurry selected, the store identical. The library's WAL was 0 bytes after quitting.

Findings, most important first:
1. **Atlas titles still repeat for some families** (this build only: 713 entries, **515 distinct**,
   445 used once, so much better than rc3's 60-fold repeats). Different rules sharing one title:
   *Oscillating Priority* ×44 (34 rules; Priority has 6 titles for 64 entries), **Battle JACA ×18
   (16 rules)**, *Forest fire* ×14 (14 rules), *Short-lived Continuous* ×9 (Lenia, 9 rules).
   **JACA falls back at about 20 characters:** every notated JACA title's notation is 7-20
   characters, and all 18 plain *Battle JACA* cards have notations of 22-34 (such as
   `+B14/S124 -B12/S345 blast 1`). And one rule on many tilings shares one title, where the
   tiling could tell them apart: *Spectre glider (Edmond 2026)* ×10, *WireWorld* ×9,
   *Greenberg-Hastings* ×8, *Abelian sandpile* ×4. (`results/v0.4.0/mac/10-quickstart-library.txt`)
2. **A `paths.json` that names a deleted folder** (the known one): the app opened on the Quick
   Start with no remark and **didn't create the folder**; `doctor` says the library is "not
   created yet" there, and `setup --status` "(chosen in setup: paths.json), 832.3 GB free",
   "library: 0 patterns". Nothing says the folder is gone, or mentions the library in the
   default place.
3. **`bundled:` resolves through the Cellar**
   (`/opt/homebrew/Cellar/jetcarp/0.4.0/share/jetcarp/packs`, not `/opt/homebrew/share/...`),
   so **the setup's pack import job records that versioned path in its spec** (job 3: `"path":
   ".../Cellar/jetcarp/0.4.0/share/jetcarp/packs/jetcarp-starter"`), which `brew upgrade` will
   delete. It's a finished job, so this matters only if something reads the path again. Nothing
   else JETCARP records names the Cellar.
4. Smaller: **`jetcarp jobs status <imported hunt>` prints "hunt 0: 0 soups, 0 soups/s … status ,
   0 s run"** (wrong number, empty status; the window is right), and `jobs list` names the pack
   by `sha256:` hash; `brew audit --strict --online` has one problem, "`version 0.4.0` is redundant
   with version scanned from URL"; **`brew test` turns on Homebrew's developer mode** (Homebrew's
   doing, but a plan that runs it might add `brew developer off`).

State left on the Mac: **Jimmie keeps the Homebrew copy (0.4.0) as the everyday JETCARP**, with
today's Explorer settings and the library (rc1's finds, the starter pack, the 713 atlas entries);
no host, login item or saver; Flurry is the screen saver. rc3's moved-aside settings are in the
Trash. Homebrew's developer mode is off again (Homebrew is 7.0.13 after its auto-update).
launchd still holds rc1's loaded login job until the next logout (known since rc1, harmless).
**The Acer's section can go next.**

## 2026-11-13 (10:40), Acer

**The Acer section of v0.4.0 is done** (`v0.4.0.md` table; details and evidence in
`results/v0.4.0/acer/notes.md`). S1 pass, S2 pass, S3 pass (titles only partly), S4 pass, S5 done.
Scoop works and the fixes since rc3 hold on Windows:
- **Install:** Scoop wasn't installed; Jimmie installed it (v0.6.0, `irm get.scoop.sh | iex`, no
  alert) and **it kept the user PATH ExpandString with `%PNPM_HOME%\bin`**, only prepending
  `~\scoop\shims` (`scoop install git` skipped: Git for Windows was there). `scoop bucket add` +
  `scoop install jetcarp` ran from this session (auto mode didn't block them): **exit 0 in 8 s**,
  the manifest's hash matches `SHA256SUMS`, no Defender or SmartScreen alert. `jetcarp` is the shim
  `~\scoop\shims\jetcarp.exe` → `apps\jetcarp\current\jetcarp.exe`, `jetcarp 0.4.0`, now with a
  version resource; `scoop status` all ok.
- **The app:** Start → Scoop Apps → JETCARP opens with **no console window**. Explorer with a
  2-minute search: **2 min 30 s** Start to done, 349 atlas entries, and **the Quick Start showed
  them (Atlas 1,779 → 2,128) after *Later* without opening a world.**
- **Hunts:** the pack's hunt rows say *imported*, *–*, *from a pack*; the detail "Imported from pack
  jetcarp-starter". **`jetcarp verify` reads both exported PNGs** (`ok: generation 42 hash
  f2b91a6b95c4dfe7`; world `ok: generation 67 hash 9c16fdd3f7b6629f`). The app closed with exit 0
  and the WAL at 0 bytes.
- **Paths that survive `scoop update`:** the `Run` value is `"…\scoop\apps\jetcarp\current\jetcarpw.exe"
  host serve --login`; `host-program` says `…\current\jetcarpw.exe host serve`; the host runs from
  `current`; **the Screen Saver Settings preview shows JETCARP**, run as `…\current\jetcarp.exe host
  scr /p`. `saver remove`, `host stop` (exit 0) and `login off` leave nothing behind but
  `host-program` and the 0-byte `host.lock`.

Findings, most important first:
1. **Re-importing the starter pack keeps the old version's entries.** This library had rc2's import
   of the pack (manifest `a78bbe8d…`, 79 entries). Setup imported 0.4.0's (manifest `722f7750…`):
   "0 patterns new, 26 merged, 48 Quick Start entries", with new handles, and rc2's 79 stayed. So
   **the Quick Start has 127 pack entries where a fresh library (the Mac) has 79**; **10 of the new
   ones have the same title, rule and tiling as an old one and show twice** (*Abelian sandpile*,
   *Agents* ×3, *Forest fire*, *Gliding Continuous*, *Growing Continuous*, *Hex3 rule 90 (NW xor
   NE)*, *Rock-paper-scissors*, *Rule 105*), and the old ones keep rc2's titles (plain *Battle JACA*,
   *Fractal Layered*). `setup --status` still says the pack has "79 Quick Start entries". Anyone who
   upgrades and runs setup again gets this, and so would a later `scoop update`/`brew upgrade`
   that ships a new pack. (`results/v0.4.0/acer/09-pack-entries.txt`)
2. **`bundled:` resolves Scoop's `current` junction**: `C:\Users\jimmi\scoop\apps\jetcarp\0.4.0\packs`,
   not `…\current\packs`, so **the pack import job records the versioned path** (job 32: `"path":
   "…\\scoop\\apps\\jetcarp\\0.4.0\\packs\\jetcarp-starter"`), which `scoop update` will delete. The
   same as the Mac's Cellar path. The login entry, `host-program` and the saver keep `current`.
3. **Atlas titles still repeat for some families**, as on the Mac (this build only: 349 entries,
   **256 distinct**, 218 used once): *Oscillating Priority* ×16 (13 rules), *Frozen Priority* ×12,
   **Battle JACA ×9 (9 rules)**, *Forest fire* ×7, *Agents* ×6. **JACA falls back over about 20
   characters**: every notated JACA title's notation is 4-19 characters, every plain *Battle JACA*
   has 24-33. One rule on several tilings shares one title (*WireWorld* ×4, *Spectre glider* ×4,
   *Abelian sandpile* ×3). (`results/v0.4.0/acer/09-quickstart-library.txt`)
4. Smaller: the Hunts detail names the feed's id `jetcarp-starter`, not "JETCARP starter pack";
   `jetcarp jobs status 26` (an imported hunt) still prints "hunt 0: 0 soups, 0 soups/s … status ,
   0 s run", and `jobs list` names the pack by `sha256:` hash (as on the Mac); Screen Saver Settings
   lists the saver as **"Jetcarp"** (no description string in the `.scr`); Cancel in that dialog
   leaves JETCARP selected, because InstallScreenSaver selects it before the dialog opens (known since
   rc1; `saver install` could say so); `host stop` leaves the 0-byte `host.lock` (known since rc1).

State left on the Acer: **Jimmie keeps the Scoop copy (0.4.0) as the everyday JETCARP**, and Scoop
(v0.6.0, buckets `main` and `jetcarp`), with today's Explorer settings and the library (rc1-rc3 and
today's build); no host, login entry or saver. The user PATH is the pre-wave value with
`~\scoop\shims` in front. rc3's moved-aside settings are in the Recycle Bin. Defender: only rc2's
two old detections, no allowed threats. **Both laptops have finished v0.4.0.**
