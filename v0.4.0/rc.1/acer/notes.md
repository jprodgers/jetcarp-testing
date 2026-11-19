# rc1 on the Acer: notes

System: `00-system.txt` (Windows 11 Home 26H2, build 26300.9974; RTX 3050 6GB Laptop + Intel UHD;
internal 1920x1080 panel at 100% scaling; on mains). Not run as administrator.

## A1. Install with the PowerShell installer — pass, with one installer bug

Output: `01-install.txt`, `02-version.txt`, `03-paths.txt`, `04-doctor.txt`.

1. **Finished without errors** (exit 0, 14 s) and said where: `installed jetcarp 0.4.0-rc.1 in
   C:\Users\jimmi\AppData\Local\Programs\jetcarp`, then `added ... to your user PATH`. The folder
   holds `.jetcarp-installer`, `jetcarp.exe` (74.9 MB), `jetcarpw.exe`, the licences and README;
   no `packs`. The files have no Zone.Identifier (no Mark of the Web) and are not Authenticode-signed.
2. **doctor lists both adapters**, `*` on `NVIDIA GeForce RTX 3050 6GB Laptop GPU (Vulkan,
   DiscreteGpu, NVIDIA 546.18)`. It also lists the Dx12 and GL views of each, and Microsoft Basic
   Render Driver as a software adapter it doesn't use.
3. **`bundled:` none**: `paths` says `(no packs came with the program)`, doctor says `none`.
4. **No SmartScreen or Defender warning** (Jimmie watched; Defender's log has no detections).

The commands ran in a new PowerShell process with `PATH` rebuilt from the registry (machine + user),
as a new window would have it.

### Bug: the installer rewrites the user PATH (type and `%VAR%` entries)

Before install, `HKCU\Environment\Path` was REG_EXPAND_SZ with 18 entries, one of them
`%PNPM_HOME%\bin` (`00-user-path-before.txt`). After install it is **REG_SZ**, and that entry is
the literal `C:\Users\jimmi\AppData\Local\pnpm\bin` (`01-user-path-after-install.txt`). It still
works today, but no longer follows `PNPM_HOME`, and any `%VAR%` entry another tool adds later
won't expand, because the value is no longer an expandable string.

Cause: `Get-UserPath` uses `[Environment]::GetEnvironmentVariable("Path", "User")`, which returns
the value already expanded, and line 172 writes it back with `[Environment]::SetEnvironmentVariable`,
which stores REG_SZ. `Remove-FromUserPath` (used by `-Uninstall`) does the same. Fix idea: read
with `(Get-Item HKCU:\Environment).GetValue("Path", $null, "DoNotExpandEnvironmentNames")` and
write with `Set-ItemProperty HKCU:\Environment Path $new -Type ExpandString`, then broadcast
`WM_SETTINGCHANGE` (for example by setting and clearing a throwaway variable with
`[Environment]::SetEnvironmentVariable`, which broadcasts it).

The original raw value is saved outside the repository so the PATH can be put back after the wave,
if Jimmie wants.

### Smaller things

- **Output folder follows OneDrive.** `output:` is `C:\Users\jimmi\OneDrive\Pictures\JETCARP`,
  because Pictures is redirected to OneDrive here. That is right (it follows the Known Folder),
  but pictures will sync to OneDrive, and A5 step 3's `dir "$env:USERPROFILE\Pictures\JETCARP"`
  looks in the wrong place on this machine.
- doctor looks for bundled packs in `C:\Users\jimmi\AppData\Local\Programs\share\jetcarp\packs`
  as well as the install folder: a Unix-layout path outside JETCARP's own folder on Windows.
- Installer wording, line 54: "such as 0.4.0-rc.1 or 0.4.0-rc.1" (the version is repeated).

## A2. The app — pass (all 8 checks), with one silent crash on close

Files: `05-app-terminal.txt`, `05-quick-start.png`, `06-*.png`, `07-*` (scene), `08-*` (PNG export),
`09-*` (large sandpile), `10-hunt-and-library.txt`, `11-app-exit-crash.txt`.

1. **Quick Start, previews animate.** 364 entries. In 1.5 s, 9 of 15 sampled cards changed (up
   to 77% of their pixels); the others are sparse or slow patterns.
2. **Each runs and pauses with Space.** Opened, per the library's `quickstart_usage`:
   `rule:B3/S23` (Life), `penrose-rhomb-brain`, `sandpile-cairo`, `turmite-llrr`, `hex-wolfram`,
   and the hat (`B2/S34 on the hat`, check 4).
3. **Right-click menu with five stars and Hide.** Jimmie rated *Sandpile on Cairo pentagons* 5
   stars (`ratings`: quickstart, sandpile-cairo, rater `user`, 5.0) and hid *Morley* (`B368/S245`,
   `hidden = 1`; 363 left). The hidden card stayed gone.
4. **Save / open scene: same state.** Saved the hat at generation 41, hash `331637905fbdc519`
   (`07-hat_scene.json`); `jetcarp verify` on it: `ok: generation 41 hash 331637905fbdc519`.
   Jimmie couldn't check it in the app: **an opened scene starts running at once**, so the
   generation it was saved at is gone before you can read it. Opening paused would make this
   checkable (and is probably what people expect from a saved state).
5. **Export PNG looks right.** 2400x2396 RGBA of the hat (`08-export.png`), crisp outlines; its
   iTXt chunks carry version, generation 105, hash `0c27770b6d4a49b8` and the scene, and that
   embedded scene verifies: `ok: generation 105 hash 0c27770b6d4a49b8`.
6. **Large sandpile, 1,000,000 grains on square, on the GPU: 8.2 s** (`wall_seconds` 8.234;
   every step on `gpu (NVIDIA GeForce RTX 3050 6GB Laptop GPU (NVIDIA), Vulkan)`), 729x729,
   1.158e10 topplings. The picture is the expected rounded-square mandala with four-fold mirror
   symmetry (`09-large-sandpile-preview.png`). It went to `OneDrive\Pictures\JETCARP\piles\`.
7. **Soup hunt, defaults: finds in the pattern library.** The defaults are 10,000 soups, which
   finished in 7.4 s (1,352 soups/s), long before the minute: 213,586 objects, 64 distinct, all
   new, including glider, LWSS/MWSS/HWSS, pulsar, beacon, toad, block (66,308), blinker (61,353).
8. **Resize, maximise, close normal; text sharp** at 100%. But the window **first opened partly
   off-screen**: at (189,182), 1402x932, so its bottom 80 px were under the taskbar on the
   1920x1080 panel (Jimmie confirmed). The jetcarpw launch later opened at (137,31) and fitted.
   The window's size, position and maximised state aren't remembered between runs.

**jetcarpw.exe** (double-clicked in Explorer): the app opened with no console window, not even a
flash. `jetcarpw.exe` stays running as the parent of `jetcarp.exe` and exits with it (both 0).

### Crash on close (once): access violation in NVIDIA's driver

At the end of the first session (about 18 minutes, all of the checks above), Jimmie closed the
window with the X. It looked normal, but `jetcarp.exe` exited with **0xC0000005**, and Windows
logged Application Error 1000 and a WER report (BEX64):

    Faulting module name: nvoglv64.dll_unloaded, version: 31.0.15.4618
    Exception code: 0xc0000005   Fault offset: 0x0000000000e4e5a2   Exception data: 8

`nvoglv64.dll` is NVIDIA's OpenGL and Vulkan driver (here the Vulkan device for the GPU
simulation, and maybe the window's GL). Exception data 8 means the CPU tried to execute code at
an address in the DLL after it had been unloaded, so something (a driver thread or a callback
the app registered) ran after the Vulkan or GL teardown at exit. It did **not** recur in two
shorter sessions (open and close; a GPU sandpile and close), and three command-line GPU sandpiles
exit cleanly. The WER report folder is
`C:\ProgramData\Microsoft\Windows\WER\ReportArchive\AppCrash_jetcarp.exe_bbf5478b...`; the dump
wasn't kept.

### Smaller things

- **The status bar says "Running" while paused**: the top-right says `|| paused gen 42`, the
  bottom-left still `Running` (`06-paused-status-mismatch.png`).
- **The Quick Start order changes** when you come back to it (Featured sort), so a card you saw
  a moment ago may have moved.
- **`jetcarp.exe` has no version resource** (no FileVersion, ProductName, description): WER
  reports it as 0.0.0.0, and Explorer's Properties > Details is blank.
- A Quick Start badge reads "Classics" on every card (the built-in source), and there is also a
  "Classics" category (285), which is confusing when a card in "Sandpiles" says "Classics".
- The Large sandpile dialog keeps the last grain count (1,000,000) rather than its default.

## A3. The desktop

Before: `12-desktop-before.txt` (wallpaper `c:\windows\web\wallpaper\themea\img20.jpg`, Fill; no
screen saver selected, ScreenSaveActive 1, timeout 60; no JETCARP startup entries).

1. **Live picture under the icons; icons readable and clickable** (Jimmie). `host start` took
   1.7 s; the host runs on the RTX 3050 (`13-host-start.txt`). The wallpaper registry value is
   untouched while the live wallpaper shows.
2. **`host next` changes the scene**: Life (1 of 7) → langtons-ant (2 of 7) (`14-host-next.txt`).
   The reply to `next` pairs the new name with the old scene's generation and cell count (3079,
   230,400); the next `status` shows the new scene's (22, 129,600).
3. **Caption: shows, but behind the taskbar and cut off** (Jimmie: "It's readable, but it's
   behind the menu bar and cut off"). Bottom-left is placed against the monitor's full bounds,
   not its work area (1920x1032 above a 48 px taskbar). `caption off` works. `host status` doesn't
   say whether the caption is on.
4. **Two monitors: the picture covers both, then each its own screen.** The AOC Q3277
   (2560x1440, `\.\DISPLAY5`) sits *left* of the laptop at x = -2560, and still worked. `status`
   listed `monitors: 0: \.\DISPLAY1, 1: \.\DISPLAY5`; after `--screen 0 --monitor 0` and
   `--screen 1 --monitor 1 --rotation "Classics, hourly"`, the laptop showed ForestFire and the
   AOC Langton's ant (`16-host-two-monitors.txt`). `status` doesn't say which monitor each screen
   is on.
5. **Battery: pauses within 3 s, carries on within 2 s** (`17-host-battery.txt`): unplugged
   00:06:25, `paused` on both screens by 00:06:28; plugged in 00:07:07, running at 00:07:09.
   Status says `paused`, not why (battery).
6. **Still left as the desktop picture: yes, but one for both monitors.** `still on` + `host
   stop` set the wallpaper to `%APPDATA%\jetcarp\desktop-pictures\still-1794460056513.png`, a
   1920x1080 still of screen 0 only (`18-still-left-by-host.png`). With one wallpaper path and
   Fill, the AOC showed the laptop's forest fire, not its own screen (Jimmie). `still off` with the
   host stopped: `saved; the host is not running` / `put the desktop's own picture back`, the
   registry is back to `img20.jpg` and the still file deleted (`18-host-still.txt`). On Windows 8+,
   `IDesktopWallpaper::SetWallpaper(monitorId, path)` sets one picture per monitor.
7. **Normal wallpaper back; `host stop` prints no connection error.** I restarted the host so
   there was one to stop, then `wallpaper off` and `host stop`: `stopped`, exit 0; `host status`
   then `Error: the JETCARP background host is not running`; no jetcarp processes left
   (`19-host-wallpaper-off-stop.txt`). Same at check 6's stop. Jimmie: normal on both monitors.
8. **Screen saver dialog with JETCARP chosen; preview animates; Preview runs and the mouse ends
   it** (Jimmie). `saver install` (127 ms) copied **`jetcarpw.exe`** to
   `%LOCALAPPDATA%\JETCARP\JETCARP.scr` (240 KB) and ran `rundll32 desk.cpl,InstallScreenSaver`,
   which set `SCRNSAVE.EXE` (`20-saver-install.txt`).
9. **Starts after 1 minute idle; a mouse move ends it** (`20-saver-idle-log.txt`). The first
   timeout start (00:12:36) lasted about a second; Jimmie isn't sure whether he bumped the mouse.
   The second (00:13:51) ran until he moved the mouse (00:14:18).
10. **`saver remove` fails while the Screen Saver Settings dialog is open**
    (`21-saver-status-remove.txt`):

        > jetcarp host saver remove
        Error: C:\Users\jimmi\AppData\Local\JETCARP\JETCARP.scr: Access is denied. (os error 5)

    It cleared `SCRNSAVE.EXE` but left the `.scr`, because the dialog's preview (`JETCARP.scr /p`,
    and `jetcarp.exe host scr /p`) was still running from it; "and stop it from running" didn't
    stop the preview. Then `saver status` said `...but another one is selected`, though none was.
    `saver install` opens that dialog itself, so install-then-remove hits this unless the dialog is
    closed first. After Jimmie closed the dialog (Cancel): `removed`, the `.scr` gone, `saver
    status`: `not installed`, and JETCARP gone from the dialog's list with (None) selected.
    The screen saver settings are back as before.

Also in A3:

- **`jetcarp host start` hands its stdout to the host.** `jetcarp host start ... | tee log` in
  Git Bash never finished, though every command had exited; it ended the moment the host stopped
  (twelve minutes later). The host (`jetcarp.exe host serve`, parent `jetcarpw.exe`) inherits the
  caller's stdout/stderr pipe, so anything that captures `host start`'s output (a pipe, `$(...)`,
  a CI step, a subprocess with `capture_output`) hangs. Spawning the host with null standard
  handles (or without handle inheritance) would fix it.
- "A classic a day" moved on by itself from langtons-ant to ForestFire within about three minutes
  (00:02 to 00:05), and a restarted host began again at Life (1 of 7). Maybe items end early (the
  ant reaching the edge?); worth checking what "a day" means there.
- `host status`'s uptime looked stuck (`up 2.0s` in three calls over 3 s), but it does update.
11. **Start at login: works (tested with a real reboot).** Auto mode blocked the session from
    running `jetcarp host login on`, so Jimmie ran it: `"...\jetcarpw.exe" host serve starts at
    login`. It writes one value, `HKCU\...\Run\JETCARP = "...\jetcarpw.exe" host serve`, and doesn't
    start the host now (`22-host-login.txt`). Jimmie rebooted rather than signing out. No JETCARP
    console window (a flash was another program's). Second boot at 00:27:53: Explorer started
    `jetcarpw.exe host serve` at 00:29:04, which started `jetcarp.exe host serve`; status
    `running ... wallpaper: showing` on both monitors.
    **But on the first boot the screens opened as ordinary windows**, and Jimmie had to switch
    them back to the desktop by hand. Cause: `host wallpaper off` (step 7) saves `"place"` as a
    window for every screen in `host.json`, so the next host start, here at login, opens windows
    over the desktop. In step 7 the host was stopped half a second later, so nobody saw it. It
    follows from the setting, but at login it's a surprise: someone who turned the wallpaper off
    and left login on gets windows at every sign-in. Perhaps `wallpaper off` should leave screens
    hidden, or login should start only screens placed on the desktop.
12. **`host login off`**: `the host no longer starts at login`; the Run value is gone and the
    other Run entries are as before; doctor says `starts at login: no`. The host keeps running;
    `host stop` (the third, again no connection error) then put the normal wallpaper back.

## A4. pipx or uv — skip

Neither is installed: `uv` and `pipx` aren't on the PATH, and `python -m pipx` says `No module
named pipx` (`23-uv-pipx.txt`). Not installed without asking, per the plan.

## A5. Uninstall — pass

1. **`jetcarp uninstall` lists, `--yes` removes; your desktop picture is yours**
   (`24-uninstall.txt`). With A3 already undone, the plan was one item, `forget the recorded host
   command`; `--yes` did it, and a second run says `Nothing to undo`. The wallpaper registry value,
   style and `TranscodedWallpaper` hash are as before A3, and so are the screen saver settings.
   Wording: it says it kept the data folder (add `--data`) but doesn't mention the settings folder
   it also keeps (`--settings`); and on Windows it says to run "the installer again with
   `--uninstall`", which is the shell installer's flag. The PowerShell installer takes `-Uninstall`,
   and only through the scriptblock form the plan uses, not through `irm | iex`.
2. **The installer's `-Uninstall`**: `removed C:\Users\jimmi\AppData\Local\Programs\jetcarp and took
   it off your PATH (your settings, data and pictures are kept)`, exit 0. In a new shell `jetcarp` is
   not found (`25-installer-uninstall.txt`). It also prints a reminder to run `jetcarp uninstall`
   first, which is right.
3. **What remains** (`26-leftovers.txt`):
   - `%APPDATA%\jetcarp`: `app.json`, `host.json` and an empty `desktop-pictures` folder;
   - `%LOCALAPPDATA%\jetcarp`: `library.sqlite` (1 MB), a **stale 0-byte `host.lock`**, and an empty
     `library.sqlite-jobs` folder;
   - `%USERPROFILE%\Pictures\JETCARP` doesn't exist; the pictures are in
     `%USERPROFILE%\OneDrive\Pictures\JETCARP` (two 1,000,000-grain piles, 50 files, 1 MB), kept on
     purpose. The plan's `dir` looks in the wrong place on a machine whose Pictures is in OneDrive.
   - The user PATH is the original with `%PNPM_HOME%\bin` expanded, the trailing `;` dropped, and
     the value REG_SZ instead of REG_EXPAND_SZ (the A1 bug: install and uninstall both rewrite it).

### After the wave

- With Jimmie's OK, the user PATH was written back to its original value and type (REG_EXPAND_SZ,
  `%PNPM_HOME%\bin`, trailing `;`); it now matches `00-user-path-before.txt` (sha256 8563c814...).
- Kept, at Jimmie's choice, so rc2 can test opening rc1's files: `%APPDATA%\jetcarp` (settings,
  `host.json` with two screens placed as wallpaper) and `%LOCALAPPDATA%\jetcarp` (library: 64 hunt
  finds, one rating, Morley hidden). Also kept: `OneDrive\Pictures\JETCARP\piles` and the two files
  Jimmie saved on the Desktop (`hat_scene.json`, `jetcarp.png`).
