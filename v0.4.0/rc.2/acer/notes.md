# rc2 on the Acer: notes

System: `00-system.txt` (Windows 11 Home 26H2, build 26300.9974; RTX 3050 6GB Laptop + Intel UHD;
internal 1920x1080 panel at 100% scaling, work area 1920x1032; on mains). Not run as administrator.

Before install: rc1's settings folder `%APPDATA%\jetcarp` (app.json, host.json) was moved aside to
`%APPDATA%\jetcarp-rc1-settings`, so the wizard sees a first run (`setup.json` there is what marks
setup as done). rc1's library in `%LOCALAPPDATA%\jetcarp` (64 hunt finds, one rating, Morley hidden,
a stale 0-byte `host.lock`) was kept, so rc2 opens rc1's library.

## A1. Install, and the PATH — fail at step 2 (Defender); checks 1-3 pass

Files: `00-path-before.txt`, `01-defender-block.txt`, `01-install-file-raw.txt`,
`01-path-after-install.txt`, `02-version-paths.txt`, `03-version-resources.txt`,
`04-doctor-setup-status.txt`.

### Microsoft Defender blocks the plan's install line as a trojan

Auto mode blocked the session from running `irm ... | iex` (as it blocks `curl | sh` on the Mac),
so Jimmie ran the plan's line in a new Windows PowerShell window. **Defender stopped it before the
installer printed anything**, and nothing was installed (`01-defender-block.txt`):

    Trojan:Win32/Commando.B!ml   (ID 2147852719, Severe)  06:51:17
    Trojan:Win32/Commando.C!ml   (ID 2147981340, Severe)  06:51:18
    Path: CmdLine:_C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass
          -c irm https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.2/jetcarp-installer.ps1 | ie
    Detection Type: FastPath; Action: Remove; security intelligence 1.463.261.0

What is flagged is the **command line** (`-ExecutionPolicy Bypass -c irm <url> | iex`), by Defender's
cloud machine-learning signatures (`!ml`), not a downloaded file: the script never ran. In rc1 the
same line with the `v0.4.0-rc.1` URL ran without any detection (run then from this session's
PowerShell). It is the same shape as uv's and others' documented install lines, so it may depend on
the URL's reputation (a new, little-downloaded GitHub release) and on the day's cloud model; it may
pass for others and fail again. Either way, **a user who copies the documented line can get a
"Severe: Trojan" alert**, which is about the worst first impression an installer can make.

Jimmie chose *Allow on device* for the second alert in Windows Security, so `Commando.C!ml` is now
allowed on this laptop (`ThreatIDDefaultAction 2147981340 = 6`). To be undone after the wave.

Ideas for the main session: document a second way that doesn't run a downloaded string through
`iex`, such as saving the script and running it as a file (what worked here):

    irm https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.2/jetcarp-installer.ps1 -OutFile jetcarp-installer.ps1
    powershell -ExecutionPolicy Bypass -File .\jetcarp-installer.ps1

or the zip by hand; longer term, a signed MSI/MSIX, winget or Scoop. Submitting the URL and script
to Microsoft as a false positive (https://www.microsoft.com/wdsi/filesubmission) may also help.

### The same installer, run as a file

The rc2 `jetcarp-installer.ps1` (sha256 `3ecf341a...25cc5`, matching the release's SHA256SUMS) was
saved with curl and read in full first. Jimmie ran
`powershell -ExecutionPolicy Bypass -File <that file>`: **no Defender or SmartScreen alert**, exit 0
in 21 s (`01-install-file-raw.txt`):

    jetcarp-installer: installed jetcarp 0.4.0-rc.2 in C:\Users\jimmi\AppData\Local\Programs\jetcarp
    jetcarp-installer: the starter pack is in C:\Users\jimmi\AppData\Local\Programs\jetcarp\packs
    jetcarp-installer: added C:\Users\jimmi\AppData\Local\Programs\jetcarp to your user PATH; ...

Checks:

1. **The PATH keeps its type and `%VAR%` entries: pass.** Still `ExpandString`; `%PNPM_HOME%\bin`
   still written that way; the old value is an exact prefix of the new one, and the only addition
   is the JETCARP folder at the end. Small thing: the old value ended in `;`, and the installer
   appends `;<dir>`, so there is now an empty entry: `...\.local\bin;;C:\Users\jimmi\AppData\Local\Programs\jetcarp`.
   Harmless, but `"$UserPath;$InstallDir"` could trim a trailing `;` first. (`-Uninstall` drops
   empty entries, so it will probably also drop the original trailing `;`; see A5.)
2. **`jetcarp --version` and `paths`: pass** (new PowerShell process, PATH rebuilt from the
   registry). `jetcarp 0.4.0-rc.2`; `bundled:  C:\Users\jimmi\AppData\Local\Programs\jetcarp\packs`.
   `setup --status` lists the starter pack there: *26 patterns, 79 Quick Start entries, 8 ant runs,
   1.5 MB*, and `setup: not run yet`. It sees rc1's library: *64 patterns, 0 ant runs, 4 jobs;
   Quick Start entries: 364 built in*. doctor: `bundled: ... (1.5 MB)` and the RTX 3050 starred
   (it found the packs, so it no longer lists where it looked; rc1's list included
   `...\Programs\share\jetcarp\packs`). `doctor` and `setup --status` created no settings folder.
3. **Version resources: pass.** Both exes: product name `JETCARP`, product version `0.4.0-rc.2`,
   file version `0.4.0.0`, company `Jimmie Rodgers`, copyright `Jimmie Rodgers. Free to use under
   the Unlicense or the MIT licence`; descriptions *JETCARP: cellular automata on tilings of the
   plane* and *JETCARP, started without a console window* (`03-version-resources.txt`, read with
   the same Shell columns Explorer's Details tab shows). Not Authenticode-signed; no Mark of the Web.

The installer's version wording is fixed: "such as 0.4.0 or 0.4.0-rc.2".

## A2. The setup wizard (Explorer) — pass except check 5, with findings

Files: `05-app-terminal.txt` (the app's console; nothing printed), `05-wizard-*.png`,
`06-wizard-*.png`, `06-hunts-build-stuck-0721.png`, `06-build-watch.txt`, `07-after-build.txt`,
`08-quick-start-after-setup.png`, `08-quick-start-sources.txt`, `09-help-setup-reopened.png`.
The app was started with `jetcarp` from a fresh environment at 06:59:44; a background PrintWindow
capture of its window saved every change of the wizard's area (at most one frame per 20 s while
something kept changing).

**The wizard opened by itself** as an in-app window, *Set up JETCARP*, over the Quick Start. The
Quick Start behind it showed **363 entries**: rc1's library opened with Morley still hidden, and
the cards' badge says **Built-in** (an rc1 fix, A3 check 6). The window opened at (241,93),
1402x932, so its bottom edge is at y=1025, above the taskbar (work area 1032; A3 check 4).

1. **Pages read fine: pass** (Jimmie, and the captures). Welcome; *What for* with the five
   profiles, none chosen and Next greyed until one is; *Packs* with the starter pack ticked (26
   patterns, 79 Quick Start entries, 8 ant runs, 1.5 MB) and a paragraph describing it; *Summary*:
   data `C:\Users\jimmi\AppData\Local\jetcarp` (1.9 TB free), the pack, *Search for 10 min ... On
   the GPU: NVIDIA GeForce RTX 3050 6GB Laptop GPU*, *About 83 MB and 11 minutes*. Nit: the Packs
   page's description of the starter pack is in a very small font.
2. **Progress bars move, *Continue in the background* works: pass, but the build's progress
   stalls for long stretches and the laptop is sluggish.** Start was pressed at **07:05:15** (pack
   import job 4 at 12:05:15 UTC, explore job 5 at 12:05:17). The import finished within 2 s. The
   build's line then read *"Starting the search: its first results take a minute or so to arrive.
   0 of 10 min, 0 runs"* for at least 85 s (`06-wizard-5-*.png`). Jimmie continued in the
   background and ran two Quick Start cards (*JACA starry rainbow*, *JACA blocky city*); "my laptop
   keeps slowing down during the search", so he stopped running worlds.
   **Then one search step ran for 12 minutes.** The record froze at *"4.3 of 10 min, 14,471
   runs"* from 07:09:35 (the step's end: 07:05:17 + 4.3 min) to 07:21:33; the search's
   `search.sqlite-wal` was not written in between, and *Tools → Hunts…* showed the timer standing
   still (Jimmie). Meanwhile the app used **10.5 of 12 cores** (two groups of 12 threads, about 65%
   and 18% each) and **5% of the GPU**. When the step ended the record jumped to *"10 of 10 min,
   46,311 runs (44/s)"*, so the search did work throughout, but nothing reported it.
   From the source (`jetcarp-search` `jobs/explore.rs`, `explore/job.rs`): a step is meant to last
   `STEP_S` = 2 s, but "a round under way runs to its end": each CPU candidate (`cpu_eval`) runs
   all its generations once started, and every fourth CPU round confirms elites on 64,000 cells for
   4,096 generations with 3 seeds; GPU batches continue while the CPU round is busy. Progress
   (`elapsed_s`, runs) is written only when a step ends, so one slow CPU round (probably a slow
   family on a confirmation grid) freezes the displayed progress, holds the build past its
   minutes, and keeps every core busy. Ideas: check the deadline inside long CPU evaluations
   (or cap their work), report progress during a step, and leave a core or two for the user.
3. **Timing: 17.5 minutes against the wizard's "about 11 minutes".** Start 07:05:15; the search's
   minutes were spent at 07:21:33 (16 min 16 s); publishing the atlas took until between 07:22:37
   and 07:23:07. `jobs status 5`: *"17 min 32 s run over every session"*, 46,311 runs, 1,758
   confirmation runs, 9,881 elites in 5,144 niches, 501 confirmed, 33 of 1,359 tilings, 0.74 GB;
   **879 atlas entries published**. The app's CPU fell to 0.1 cores afterwards.
4. **The Quick Start's three kinds; three starter-pack entries run: pass, with two findings.**
   1,264 entries: *Packs 79, Atlas 879, Built-in 306* (`08-quick-start-after-setup.png`). Opened
   (and recorded in `quickstart_usage`): *ULL2L2UL2 highway on Hexagon*, *Labyrinth
   Rock-paper-scissors* (one of the pack's atlas pictures) and *4.8.8: c/2 orthogonal p24 ship*:
   all three ran and looked right (Jimmie).
   - **The featured built-ins are not first.** The Featured sort puts the featured built-ins in
     the same first band as the best atlas and pack entries of every category and shuffles them
     together (`menu.rs` `shuffle`), so the top row was an atlas *Growing Continuous*, an atlas
     *Turbulent Hodgepodge*, the built-in *Sandpile on the Spectre*, an atlas *Spectre glider*
     and the pack's *Labyrinth Rock-paper-scissors*. That is the code's design; the plan expected
     built-ins first. Built-in and pack cards carry badges (*Built-in*, *Packs*); atlas cards none.
   - **57 built-in examples disappeared from the menu.** `items_of` leaves out every non-featured
     built-in whose rule an atlas entry has, matching on the rule alone. Sandpiles, ants,
     WireWorld and the Spectre glider name their rule without the tiling, so 3 atlas sandpiles
     (on *Any triangle*, k6-225, k6-235) hide **34 built-in sandpiles on 34 other tilings** (the
     Sandpiles category went from 39 to 16), and two atlas ants hide the built-in *Langton's ant*
     on the square grid. Also gone: *Diamoeba*, *Oils*, *Xtasy*, *Spirals*, *WireWorld*, *Rule 30*
     and others (16 Classics, 6 Fractals & rows): hand-made, named examples replaced by atlas runs
     with generic titles. Full list in `08-quick-start-sources.txt`. Matching on rule *and*
     tiling (or on the scene) would keep them.
   - **Atlas titles repeat a lot**: 879 entries, 89 distinct titles, 436 distinct title-and-tiling
     pairs; 43 cards are *Fractal Elementary* on *Square* and 39 are *Agents* on *Any triangle*.
5. **Help → Setup… does not offer Later: fail.** It reopened on the last page, *"Explorer: all
   set"*, both jobs done, with only **Close** (`09-help-setup-reopened.png`). From
   `setup_ui.rs`: `show_again` goes back to Welcome only when the wizard hasn't applied a setup in
   this session (`self.applied.is_none()`), and `close()` doesn't clear it, so **for the rest of
   the session the app can't start setup again or choose another profile**; the done page has no
   Back or "Set up again". The docs say "Run setup again, from Help → Setup… … and choose another
   profile", and the Mac's M2 step 2 does exactly that after step 1. After a restart it should open
   at Welcome (checked in A3, below).

### Opening rc1's library

rc1's library opened without complaint: its 64 hunt finds, rating and hidden Morley are there, and
the starter pack imported into it (90 patterns). But **rc1's two pile jobs read as empty**:
`jobs list` shows *"pile 1: 0 grains on , step 0/0 (0 grains), 0.000e0 topplings, 0.0 s"* where rc1
showed *"pile 1: 1000000 grains on square, step 20/20 (1000000 grains), 1.158e10 topplings, 8.2 s"*
(`results/rc1/acer/10-hunt-and-library.txt`), and the Hunts window shows *"1,000,000 grains on
Square, 0 doubling steps, 0 s run"*: rc2 reads rc1's pile progress records with a different
layout. Smaller: `setup --status` says *27 jobs* where `jobs list` lists 26; the pack's imported
hunts show as *"runs until stopped"* with 0 soups in the Hunts window; the p24 ship's title says
*B2/S3* while its scene runs *B2/S34* (its description explains why).

## A3. The rc1 fixes — pass, with findings

1. **Crash on close: pass** (`16-crash-on-close.txt`). Three sessions (36, 6.5 and 4 minutes), each
   with a 1,000,000-grain sandpile on the GPU (11.3 s, 7.4 s, 7.8 s; 11,583,796,400 topplings each
   time, as in rc1 on both laptops), closed with the X: **exit code 0 every time**, read from a
   watcher holding the process handle, and no Application Error event for any process. The only
   event naming jetcarp is WER's **RADAR_PRE_LEAK_64** at 07:08:24, during the Quick Start build:
   Windows' resource-exhaustion detector thought the app might be leaking memory (working set about
   1.1 GB at 07:15). Not a crash; worth a look alongside the build's long step.
2. **Pause state: pass.** *GH 20/2 — trihex* paused: the menu bar says `|| paused gen 87` and the
   status bar `Paused` (`12-paused.png`).
3. **Opening a scene: pass.** Saved at generation 87 (`13-testscene.json`), run on, then *File →
   Open scene…*: it opened **paused at generation 87, hash b3f463b5** (`13-scene-opened.png`);
   `jetcarp verify` on the file: `ok: generation 87 hash b3f463b50ce2245d`.
4. **The window's place: pass.** First launch at (241,93), 1402x932, fully above the taskbar
   (bottom 1025 of a 1032 work area). Jimmie moved and shrank it, closed the app: `app.json` saved
   `"window": {"pos": [14,21], "size": [800,500], "maximized": false}`, and the next launch opened
   there (frame (21,21), 802x532; Jimmie: yes). He then maximised it and closed; the next launch
   opened maximised (and kept the restore size).
   After the restart, **Help → Setup… opened on Welcome with Later** (Jimmie), so A2 check 5's
   problem is limited to the session in which setup ran.
5. **The Quick Start order: pass.** After opening *Turbulent Hodgepodge* and coming back, all 28
   cards on screen were in the same places with the same titles (`15-quick-start-order-1.png`,
   `-2-after-entry.png`); *Shuffle* changed them (`-3-shuffled.png`). But every live preview
   restarts when you come back, so the grid *looks* different: Jimmie's first answer was "It is
   not the same", and on asking it was the pictures. Keeping the previews' state (or not
   restarting them) would make the kept order visible.
6. **The badge: pass.** Built-in cards say *Built-in* (and pack cards *Packs*; atlas cards have
   none). Small: a built-in card's tooltip names a source file, *"Source: jaca_search
   (crates/jetcarp-search/examples/jaca_search.rs)"*.

Desktop before checks 7-12: `17-desktop-before.txt` (wallpaper `img20.jpg`, style 10, no screen
saver, timeout 60, no JETCARP Run entry). `host` commands ran from Git Bash with output to a file
and stdin from `/dev/null`, except check 10.

7. **The caption: pass.** `host start`, `host wallpaper on`, `host caption on`
   (`18-host-caption.txt`): Jimmie: the caption is **fully visible above the taskbar** (rc1: behind
   it). `host status` now reports `caption: on, bottom left, 20 pt`.
8. **One still per monitor: pass.** The AOC Q3277 attached as `\\.\DISPLAY5`, 2560x1440 at x=-2560
   (left). `--screen 0 --monitor 0` and `--screen 1 --monitor 1 --rotation "Classics, hourly"`
   put Life on the laptop and Hodgepodge on the AOC (`19-host-two-monitors.txt`). `still on` and
   `host stop` (`stopped`, exit 0, no connection error) left **two stills**, `still-...-0.png`
   1920x1080 (Life) and `still-...-1.png` 2560x1440 (Hodgepodge) (`20-stills-aoc-left-laptop-right.png`,
   a quarter-size copy); Jimmie: each monitor shows its own screen's still, filling it. `still off`
   with the host stopped: `put the desktop's own picture back`; Jimmie: his wallpaper is back on
   both; the stills are deleted (`20-host-still.txt`). One difference from rc1: the registry's
   `WallPaper` is now `C:\Users\jimmi\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper`
   (Windows' cached copy) instead of `c:\windows\web\wallpaper\themea\img20.jpg`. The picture is the
   same (TranscodedWallpaper sha256 `85ff3bb2...` before and after), but the value no longer names
   the original file; rc1's `still off` put back the `img20.jpg` path. Probably a side effect of
   setting pictures per monitor (`IDesktopWallpaper`) and restoring through it.
9. **`saver remove` with the dialog open: pass** (`21-saver-*.txt`). Auto mode blocked the session
   from running `saver install`, so Jimmie ran it (`copied to ...\JETCARP.scr; Screen Saver Settings
   is opening`). With the dialog open and its preview running (`JETCARP.scr /p` → `jetcarp.exe host
   scr /p`), `saver remove`:

       Error: C:\Users\jimmi\AppData\Local\JETCARP\JETCARP.scr is in use, most likely by the preview in
       Screen Saver Settings. Close that dialog, then run `jetcarp host saver remove` again. Nothing was changed.

   exit 1, and indeed nothing changed (`SCRNSAVE.EXE` still JETCARP's, `.scr` present, `saver status`:
   *JETCARP is the selected screen saver*). After Jimmie cancelled the dialog: `removed`,
   `SCRNSAVE.EXE` cleared, `.scr` deleted, `saver status`: *not installed*; timeout and
   ScreenSaveActive as before.
10. **`host start` in a pipe: pass.** `jetcarp host start | tee host.txt` in Git Bash returned in
    **722 ms**, exit 0 (`22-host-start-pipe.txt`); rc1's hung until the host stopped. Its reply
    said each screen's monitor was *"(not connected)"* (at `up 0.0s`, both monitors attached);
    10 s later `host status` named both (`\\.\DISPLAY1`, `\\.\DISPLAY5`). A misleading word in the
    first reply only.
11. **`host status`: pass** (`23-host-status*.txt`). It names each screen's monitor and the caption;
    with the charger out it adds `· paused` to each screen and **`paused: on battery`**. Paused
    within about 4-6 s of unplugging (power status 1 at 07:55:50, paused by 07:55:54) and running
    again by 07:56:13, right after plugging in.
12. **Login after `wallpaper off`: pass.** Before the reboot (`24-host-wallpaper-off.txt`,
    `25-host-login-on-raw.txt`). `host wallpaper off` still does what rc1 found: it saves both
    screens as `"place": "window"` in `host.json` **and opens them at once as full-monitor
    windows**, *"JETCARP: A classic a day"* at (0,0), 1920x1080 (over the laptop's taskbar too),
    and *"JETCARP: Classics, hourly"* filling the AOC, so turning the wallpaper off covers both
    screens with windows. Auto mode blocked `login on` again, so Jimmie ran it:
    `"...\jetcarpw.exe" host serve --login starts at login`; the Run value is
    `JETCARP = "C:\Users\jimmi\AppData\Local\Programs\jetcarp\jetcarpw.exe" host serve --login`
    (rc1's had no `--login`). The host (jetcarpw 22292 → jetcarp 16792) was left running with its
    two windows, the AOC attached, and Jimmie rebooted at about 08:00.

    After the reboot (boot 08:01:41, Explorer 08:02:01): Windows started the Run entry at 08:03:05,
    about a minute after Explorer (its usual delay for Run entries). **Nothing appeared at sign-in**
    (Jimmie: no JETCARP window, no console flash, his own wallpaper on both monitors), and the host's
    icon was in the tray: `jetcarpw.exe host serve --login` (pid 5260, parent Explorer 10896) →
    `jetcarp.exe host serve --login` (5372). `host.json` still said `"window"` for both screens until
    Jimmie ticked the tray's *Show on the desktop* (08:03:42): that rewrote both screens to
    `"wallpaper"` and put the live wallpaper on both monitors, behind the icons, no windows (Jimmie).
    At 08:07:16 `host status` showed both screens as `wallpaper on monitor` 0 and 1 and
    `wallpaper: showing`, both at generation 6310 after 251 s up, which is about 210 s at 30 fps: the
    worlds ran from when they were shown, not while hidden.
    `host login off` (`26-host-login-off.txt`): `the host no longer starts at login`, exit 0, run by
    this session (auto mode didn't block *off*); the Run value is gone, with nothing under
    `StartupApproved\Run`. `host stop`: `stopped`, exit 0, no connection error; both processes gone;
    Jimmie: his own wallpaper is back on both monitors. The tray's tick is saved, so `host.json` now
    says `"wallpaper"` for both screens.

## A4. MCP with Claude Code — pass, with one finding

The trimmed session is in `mcp-session.md`. Jimmie ran `claude mcp add jetcarp -- jetcarp mcp`
and a new Claude Code session (2.1.317) in a separate PowerShell window, in a new empty folder, and
typed tutorial 6's prompts: what the tools can do; Brian's Brain 120x80 for 200 generations "and
show me"; 20,000 Life soups and their spaceships; more about the LWSS.

1. **Every tool call worked: pass.** Nine JETCARP calls (`help`, `world_new`, `world_step`,
   `world_render`, `search_start`, `job_status`, `library_query` twice), no errors, no retries.
   The session was in auto mode, so no permission prompts came up and none was blocked.
2. **The results are the tutorial's, exactly.** Brian's Brain at generation 200: hash
   `c38568895709dcc6`, 690 live. The hunt: 430,384 objects (38,188 ships, 124,582 oscillators,
   267,614 still lifes), 50 distinct, 19,892 settled, 52 died, 56 exploded, in 13 s (1,577 soups/s).
   `search_start` with `wait_s` returned when the hunt ended, so there was no polling.
3. **Nothing confused it** (Jimmie: nothing odd). It called `help` first; it took the hunt's
   spaceship counts from the job report, not the library's lifetime `seen` totals; it read "new"
   as "new to this library", not a discovery.
4. **Finding: the user never sees the picture in Claude Code.** The model called `world_render`
   without `save_path`, so no file was written, and Claude Code's terminal doesn't show a tool's
   image. Its answer still said "the picture above". Jimmie: "No, I saw no picture." The tutorial
   says the assistant "shows it to you", which holds for Claude Desktop. Possible fixes: the
   tutorial tells Claude Code users to ask for the picture to be saved; or `world_render` saves a
   file by default, or says in its reply where to get one.

`claude mcp remove jetcarp` afterwards (Jimmie); `claude mcp list` no longer shows it. The hunt
added job 30 and 8 still lifes to the library. Auto mode stopped this session from copying the
rendered picture out of Claude Code's session folder into the repository, so there is no picture
file here; the hash fixes what it showed.

## A5. Uninstall — pass

Auto mode blocked this session from running `jetcarp uninstall --yes`, so Jimmie ran both removal
steps in a new PowerShell window. The session ran only the plan (no `--yes`) and the checks.

1. **`jetcarp uninstall`: pass** (`27-uninstall.txt` the plan, `28-uninstall-yes.txt`). With A3's
   host stopped and `login off` done, the plan was one item, `forget the recorded host command`;
   `--yes`: `done: forget the recorded host command` (the `host-program` file is gone). It kept
   the data folder (32.4 MB) and names the pictures folder correctly as
   `C:\Users\jimmi\OneDrive\Pictures\JETCARP`. **Two rc1 wording issues are unchanged:** on Windows
   it still says to run "the installer again with `--uninstall`" (the PowerShell installer takes
   `-Uninstall`), and it still doesn't say it kept the settings folder (`--settings`).
2. **The installer's `-Uninstall`, run as a file: pass** (`29-installer-uninstall.txt`). The rc2
   installer checked in A1 (sha256 `3ecf341a...25cc5`):
   `removed C:\Users\jimmi\AppData\Local\Programs\jetcarp and took it off your PATH (your settings,
   data and pictures are kept)`. No Defender alert.
3. **The PATH: pass** (`31-path-desktop-after.txt`). Still `ExpandString`, `%PNPM_HOME%\bin` still
   written that way, no JETCARP entry. It equals `00-path-before.txt` except for the trailing `;`,
   which `-Uninstall` drops along with A1's empty `;;` entry (it drops all empty entries).
   Harmless. A new shell with the PATH rebuilt from the registry: `jetcarp: not found`.
4. **The desktop: as before.** Wallpaper `TranscodedWallpaper` sha256 `85ff3bb2...` (as before A3),
   style 10; no screen saver selected, `ScreenSaveActive` 1, timeout 60; no `JETCARP` Run value; no
   `JETCARP.scr`. The `WallPaper` value still names the cached copy, not `img20.jpg` (A3 check 8).
5. **What is left** (`30-leftovers.txt`), all as designed (settings, data and pictures are kept)
   except the last two items:
   - `%LOCALAPPDATA%\Programs\jetcarp`: gone.
   - `%APPDATA%\jetcarp`: `app.json`, `host.json` (both screens `"wallpaper"`), `setup.json`, and an
     empty `desktop-pictures` folder.
   - `%LOCALAPPDATA%\jetcarp`: `library.sqlite` and its search database, an empty
     `library.sqlite-jobs` folder.
   - `OneDrive\Pictures\JETCARP\piles`: five 1,000,000-grain piles (rc1's two, rc2's three).
   - **rc1's stale 0-byte `host.lock`** (dated 2026-11-11 23:58) is still there: neither rc2's
     hosts nor `uninstall` removed it (rc1 finding, unchanged).
   - **The library's write-ahead log was left behind:** `library.sqlite-wal` (5.5 MB) and
     `library.sqlite-shm`. `library.sqlite` itself was last written at 07:22, so everything since
     (rc2's later app sessions, the MCP hunt, job 30) is only in the WAL. SQLite reads it back
     correctly while the two files sit together, but copying or backing up `library.sqlite` alone
     would lose that hour. The WAL already existed at 08:07 (last written 07:47), before the MCP
     session, so the app or the host closes the library without a checkpoint. (This session's
     read-only query at 08:24 touched the `-shm`, not the WAL.)

### After the wave

Jimmie's choices (08:32):
- Microsoft Defender's *Allow* for `Trojan:Win32/Commando.C!ml` (threat ID 2147981340, still
  allowed at 08:32): Jimmie removed it in Windows Security (*Allowed threats → Don't allow*);
  at 08:36 `Get-MpPreference` lists no allowed threat IDs.
- Kept as they are: rc2's settings in `%APPDATA%\jetcarp`, rc1's in `%APPDATA%\jetcarp-rc1-settings`,
  the library in `%LOCALAPPDATA%\jetcarp`, the piles in `OneDrive\Pictures\JETCARP`, and
  `OneDrive\Desktop\testscene.json`.
- Left as they are: the `WallPaper` value naming `TranscodedWallpaper` (same picture) and the
  PATH without its trailing `;`.
- Deleted: the empty `%USERPROFILE%\jetcarp-mcp-test` and the A4 session's Claude Code folder
  (its trimmed transcript is `mcp-session.md`).
