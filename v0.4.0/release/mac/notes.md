# v0.4.0 on the Mac (Homebrew): notes

System: `00-system.txt` (MacBook Pro Mac14,6, M2 Max, 64 GB; macOS 27.0.1, build 26A434; on mains,
battery 80%). Not run as root. The Mac comes to this wave from rc3's after-wave state: JETCARP
uninstalled, rc3's settings and the library kept.

## H1. Before installing: pass

Files: `01-before.txt`, `01-library-before.txt`.

1. **No `jetcarp` anywhere:** `which -a jetcarp` finds nothing; no `~/.local/bin/jetcarp`,
   `~/.local/lib/jetcarp`, `/opt/homebrew/bin/jetcarp` or `/usr/local/bin/jetcarp`.
2. **Homebrew 7.0.12** at `/opt/homebrew` (prefix `/opt/homebrew`). No taps (`brew tap` lists
   nothing), and no jetcarp formula installed.
3. **What rc3 left** in `~/Library/Application Support/jetcarp/`: `app.json`, `host.json`,
   `setup.json`, `paths.json`, `data/` (the library) and `wallpaper-store-before-saver-remove.plist`
   (rc3 M3's backup of the wallpaper store, not JETCARP's). There is **no `desktop-pictures/`**.
   `paths.json` says `"data_dir": "/Users/Jimmie/Documents/jetcarp-data"`, which **doesn't exist**
   (it went to the Trash after rc3; the known finding). No JETCARP LaunchAgent;
   `~/Library/Screen Savers` is empty; no moved-aside `jetcarp-rc*` folders.
   - **The library** (`data/library.sqlite`, WAL 0 bytes) is rc1's: 64 patterns, 1 rating,
     3 jobs (0 manual, 1 pile, 2 hunt), and **364 built-in Quick Start entries with no atlas and
     no pack entries**, since rc3's builds went to the Researcher folder, now in the Trash. So in
     H3 every atlas entry will be the new build's. (`meta`: created by 0.4.0-rc.1, builtin
     version 0.4.0-rc.3, schema 3.)

Before H2, the tap's formula (`jprodgers/homebrew-jetcarp`, one commit `d6a4cf2`, "jetcarp 0.4.0",
10:02 UTC) was read: it installs the release archive (`bin/jetcarp`,
`lib/jetcarp/libjetcarp_saver.dylib` on macOS, `share/jetcarp/packs`, docs and licences), compiles
nothing, has no post-install step, and its four checksums match the release's `SHA256SUMS`
(aarch64-apple-darwin `bdd9c6e4…4448`).

## H2. Install with Homebrew: pass (two findings for 0.4.1, one Homebrew side effect)

Files: `02-brew-install.txt`, `03-checks.txt`, `04-brew-audit.txt`, `05-doctor.txt`.

`brew install jprodgers/jetcarp/jetcarp`, run by Claude at 07:36:16: **exit 0 in 8.1 s**. It
auto-updated Homebrew, tapped `jprodgers/jetcarp` (1 formula), printed "Trusted formula
jprodgers/jetcarp/jetcarp" (no prompt), and installed `/opt/homebrew/Cellar/jetcarp/0.4.0: 73
files, 74.1MB`. The caveat about running `jetcarp uninstall` before `brew uninstall` was shown.

1. **pass.** `which jetcarp`: `/opt/homebrew/bin/jetcarp`, a link to
   `../Cellar/jetcarp/0.4.0/bin/jetcarp`. `jetcarp --version`: **`jetcarp 0.4.0`**. (`which -a`
   lists it twice only because this shell's PATH has `/opt/homebrew/bin` twice; not JETCARP's.)
2. **pass.** `brew test jetcarp`: exit 0 (runs `--version` and `paths`). **Side effect:** "test is a
   developer command, so Homebrew's developer mode has been automatically turned on" (`brew
   developer off` undoes it), and it installed 11 gems into Homebrew's own vendor folder; `brew
   audit` added 30 more. Ask Jimmie in H5 whether to turn developer mode off.
3. `jetcarp paths`, exactly:

       settings: /Users/Jimmie/Library/Application Support/jetcarp
       data:     /Users/Jimmie/Documents/jetcarp-data
       output:   /Users/Jimmie/Pictures/JETCARP
       bundled:  /opt/homebrew/Cellar/jetcarp/0.4.0/share/jetcarp/packs

   - **`bundled:` is Homebrew's packs folder, but through the versioned Cellar path**, not the
     stable `/opt/homebrew/share/jetcarp/packs` link (the program resolves its own link to
     `Cellar/.../bin/jetcarp` and goes `../share/jetcarp/packs` from there). Harmless while it's
     worked out on each run; H3/H4 check whether anything records it.
   - **`data:` names the missing folder with no remark.** `doctor` says `library:
     .../jetcarp-data/library.sqlite (not created yet)`; `setup --status` says "(chosen in setup:
     paths.json), 832.3 GB free" and "library: 0 patterns, 0 ant runs, 0 jobs". Nothing says the
     folder is gone, and rc1's library in `jetcarp/data/` (64 patterns) isn't mentioned. These
     read-only commands **didn't create** the folder.
4. **pass.** `/opt/homebrew/lib/jetcarp` (a link to the Cellar's) holds `libjetcarp_saver.dylib`
   (12.5 MB). `share/jetcarp/packs/jetcarp-starter` is there too.
5. `brew audit --strict --online`: **1 problem**, "Stable: `version 0.4.0` is redundant with version
   scanned from URL" (exit 1). (A `rubocop-md` "obsolete parameter" warning is Homebrew's own.)
   That's all Homebrew's collection would ask for, at least from the audit.
6. `jetcarp doctor`: JETCARP 0.4.0 on macos aarch64 (12 threads); bundled 1.5 MB; `Apple M2 Max
   (Metal, IntegratedGpu)`; host not running, not at login, saver not installed.

Also: the binary is ad-hoc signed (`spctl` rejects it, as expected for a Homebrew download that
isn't notarized) and carries no quarantine mark, only `com.apple.provenance`; so Gatekeeper
shouldn't stop it when started from a terminal (H3 checks for a dialog).

## H3. A first run with the Homebrew copy: pass, with findings on titles

Files: `06-app-terminal-rc3-settings.txt`, `07-paths-after-move.txt`, `08-app-terminal.txt`,
`09-build.txt`, `10-quickstart-library.txt`, `11-jobs-after-setup.txt`, `12-verify-png.txt`,
`12-jetcarp-view.png`, `12-jetcarp.png`, `13-after-quit.txt`.

1. **With rc3's settings in place: pass, with a finding.** `jetcarp` started from Claude's shell at
   07:37:52. **No Gatekeeper dialog** (Jimmie); the window opened on the **Quick Start, with no
   remark about the missing data folder** (Jimmie). Nothing printed in the terminal. It did **not
   create** `~/Documents/jetcarp-data` and didn't touch rc1's library in `jetcarp/data/`; it only
   rewrote `app.json` (4,342 → 4,339 bytes). Cmd+Q: exit 0 at 07:42:02. So a `paths.json` that names
   a deleted folder gives a Quick Start of built-ins with no word that the library is missing.
2. **Moved** to `~/Library/Application Support/jetcarp-rc3-settings/`: `app.json`, `host.json`,
   `setup.json`, `paths.json`, and rc3 M3's `wallpaper-store-before-saver-remove.plist` (not
   JETCARP's; moved so the folder looks like a first run). There was no `desktop-pictures/`.
   `data/` stayed. Then `paths` says `data: .../jetcarp/data` and `setup --status` "not run yet",
   library 64 patterns, 2 jobs, 364 built-in entries.
3. Started 07:43:01; **the wizard opened** (Jimmie), with no Atlas count visible before Start
   (the library had none). Jimmie chose **Explorer**, kept the starter pack, set **2 minutes**, and
   pressed Start at about 07:54:47. Pack import 3 took 3 s (26 patterns, 79 entries, 8 ant runs;
   it also made hunts 5-18, 20-25 and searches 16, 19, one per imported run). Explore 4 ran
   **2 min 24 s from Start to done**: 8,365 runs, 79 confirmed, 17 of 1,359 tilings, 1.24 GB,
   **713 atlas entries** (713 new). (Claude's poller had a quoting bug and logged nothing useful;
   the timing is from the jobs' timestamps; `09-build.txt`.)
   - **The Quick Start without opening a world: pass.** After *Later*, Jimmie saw the new entries
     there already, with **Atlas 713**. (rc3: only after opening and closing a world.)
   - **This build's titles: much better, not finished.** All 713 atlas entries are this build's.
     **515 distinct titles; 445 used once**, 70 repeated (45 twice, 12 three times).
     The notation is there for Life-like (*Living B4/S01234*), Generations (*Oscillating
     B16/S4569/C24*), Larger than Life (60 entries, 60 titles: *Frozen R3,C2,S22-46,B27-42*),
     Cyclic/GH/RPS (*Oscillating GH 14/1*, *Wave RPS 8/2*), Layered (*Fractal Layer 5/03*),
     Hodgepodge, and short JACA rules (*Battle JACA +B23/S8 -B3/S06*). Still repeated:
     - **Different rules, one title** (the rule has no short notation here):
       *Oscillating Priority* ×44 (34 rules; Priority has 6 titles for 64 entries),
       **Battle JACA ×18 (16 rules)**, *Forest fire* ×14 (14 rules), *Short-lived Continuous* ×9
       (9 rules), *Turbulent Priority* ×8. **JACA's cut-off is about 20 characters:** every
       notated JACA card's notation is 7-20 characters, and all 18 plain *Battle JACA* cards
       have notations of 22-34 (*+B14/S124 -B12/S345 blast 1*); `10-quickstart-library.txt`.
     - **One rule on different tilings** (a rule notation can't tell them apart; the tiling
       could): *Spectre glider (Edmond 2026)* ×10, *WireWorld* ×9, *Greenberg-Hastings* ×8,
       *Abelian sandpile* ×4, *Rock-paper-scissors* ×3.
4. **Hunts: pass.** The starter pack's hunt row says ***imported***, ***–*** for the time and ***from
   a pack***; its detail **names the feed**, not a hash (Jimmie). Smaller, in the terminal only:
   `jobs list` still says "imported from pack sha256:722f7750…" for each imported hunt, and
   **`jobs status 25` prints "hunt 0: 0 soups, 0 soups/s … status , 0 s run"** (wrong number, empty
   status, the old counts); `11-jobs-after-setup.txt`.
5. **`jetcarp verify` on an exported PNG: pass.** Jimmie opened *Battle JACA B24/S012 blast 1*
   (Penrose kites and darts) and exported the view (`12-jetcarp-view.png`, 2125×1700) and the
   world (`12-jetcarp.png`, 2395×2400). `jetcarp verify` on each: **`ok: generation 39 hash
   3a01f78fa4521000`**, exit 0. (rc3: "stream did not contain valid UTF-8".) Both carry the scene
   in iTXt chunks (`jetcarp:scene`, `:hash`, `:generation`, `:version` 0.4.0).
6. **Quit: pass.** Cmd+Q, exit 0 at 09:17:16; **`library.sqlite-wal` 0 bytes**.

**What this run recorded about Homebrew's paths** (`13-after-quit.txt`): no settings file names
`/opt/homebrew` or the Cellar (`setup.json` records the pack by name; there is no `host.json` or
`paths.json` now). **The library does:** pack import job 3's spec says `"path":
"/opt/homebrew/Cellar/jetcarp/0.4.0/share/jetcarp/packs/jetcarp-starter"`, which `brew upgrade`
will delete. The job is done, so this matters only if something reads that path again (a resume or
a re-import); it follows from `bundled:` naming the Cellar (H2).

## H4. Paths that must survive `brew upgrade`: pass

Files: `14-host-login-start.txt`, `15-saver-choices-before.txt`, `16-saver-install.txt`,
`17-saver-remove.txt`, `18-host-stop-login-off.txt`.

1. **The login item and the recorded host program name the stable link: pass.**
   - `jetcarp host login on`: `"/opt/homebrew/bin/jetcarp" host serve --login starts at login`.
     `~/Library/LaunchAgents/com.jimmieprodgers.jetcarp.host.plist` has `ProgramArguments`
     **`["/opt/homebrew/bin/jetcarp", "host", "serve", "--login"]`** (`RunAtLoad`, `ProcessType`
     Interactive).
   - `jetcarp host start`: running, pid 16338, `screen 0: A classic a day · Quick Start
     langtons-ant (2 of 7) · starting · window` (a window: there's no `host.json`), `monitors: 0:
     Built-in Retina Display`. The process is **`/opt/homebrew/bin/jetcarp host serve`** (parent
     launchd).
   - **`host-program`** (37 bytes): `/opt/homebrew/bin/jetcarp` / `host` / `serve`, one per line.
   - Nothing in the settings folder names the Cellar (the only `/opt/homebrew` is `host-program`'s
     link).
   - Known since rc1, not new: `launchctl print` still holds the job loaded at the last reboot
     (12 Nov 02:02, from rc1's plist): `program = /Users/Jimmie/.local/bin/jetcarp host serve`,
     not running. `login on` writes the plist without loading it, and `login off` deletes it
     without unloading it (rc1 M3 check 12: harmless, as the job only runs at load; launchd forgets
     it at the next logout). After `login off`, `launchctl list` still lists the label.
2. **The screen saver: pass.** System Settings was closed beforehand. `jetcarp host saver
   install`: `written to /Users/Jimmie/Library/Screen Savers/JETCARP.saver; choose JETCARP in System
   Settings, Wallpaper, Screen Saver… (opening; if it was open already, quit and reopen it to see
   JETCARP). Install again after changing its rotation`. **No "was not found"**: it found
   `lib/jetcarp/libjetcarp_saver.dylib` through Homebrew's layout. The bundle is self-contained
   (`Contents/MacOS/JETCARP` 12.5 MB, `Resources/jetcarp-saver.json`, thumbnails, a code
   signature) and **names no `/opt/homebrew` or Cellar path**, so an upgrade can't break it (it just
   keeps the older code until installed again). It also saved `screen-saver-before.plist` in the
   settings. **JETCARP was listed** in System Settings' screen savers, which opened by itself, and
   Flurry stayed selected (Jimmie). `jetcarp host saver remove`: `removed` / "System Settings, if it
   is open, may keep listing JETCARP until you quit and reopen it"; the bundle and
   `screen-saver-before.plist` are gone; the store's 14 Idle choices are **identical** to before
   (all `Flurry.appex`); after reopening System Settings, **Flurry is selected and JETCARP is gone**
   (Jimmie).
3. **Stop and login off: pass.** `host stop`: `stopped`; `host login off`: `the host no longer
   starts at login`; **the LaunchAgent plist is gone**; no JETCARP process; `doctor`: host not
   running, not at login, saver not installed. `host-program` stays (as before).

So all three things JETCARP records outside the library (the login item, `host-program`, the
saver) survive `brew upgrade`. The one versioned path is in the library: job 3's spec (H3).

## H5. Clean up: done

File: `19-after-wave.txt`.

1. **Jimmie keeps the Homebrew copy as the everyday JETCARP.** So `jetcarp uninstall` and `brew
   uninstall` were not run. Left: `jetcarp 0.4.0` from the tap `jprodgers/jetcarp` at
   `/opt/homebrew/bin/jetcarp`; settings `app.json`, `setup.json` (Explorer, 0.4.0) and
   `host-program`; the library in `jetcarp/data/` (rc1's 64 hunt finds plus the starter pack:
   90 patterns, 8 ant runs, 25 jobs; Quick Start 364 built-in, 79 from packs, 713 from the
   search), the search folder; no WAL or SHM left after the last command closed it. No host
   running, no login item, no saver; the screen saver is Flurry everywhere. `~/Pictures/JETCARP`
   as rc3 left it. No `~/.local` copy, no `~/Documents/jetcarp-data`.
2. **rc3's moved-aside settings went to the Trash** (Jimmie), with macOS's `trash` command, so
   Finder's Put Back works.
3. **Homebrew's developer mode is off again** (Jimmie, after asking what it does): `brew developer
   state`: disabled, "`brew update` will update to the latest stable tag". Homebrew's auto-update
   during `brew install` had moved it from 7.0.12 to **7.0.13**; the gems `brew test` and `brew
   audit` installed stay in Homebrew's vendor folder (Homebrew's own).
