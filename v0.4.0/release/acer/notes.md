# v0.4.0 on the Acer (Scoop): notes

System: `00-system.txt` (Windows 11 Home 26H2, build 26300.9974; i5-13420H, 12 threads; RTX 3050
6GB Laptop + Intel UHD; internal 1920x1080 panel at 100%, work area 1920x1032; on mains). Not run as
administrator. The Acer comes to this wave from rc3's after-wave state: JETCARP uninstalled, rc3's
settings and the library kept.

## S1. Before installing: pass

Files: `00-system.txt`, `00-path-before.txt`, `00-path-type-before.txt`, `01-before.txt`,
`02-scoop-install.txt`, `02-path-after-scoop.txt`, `02-path-type-after-scoop.txt`.

1. **No `jetcarp` anywhere:** `Get-Command jetcarp -All` finds nothing (PATH rebuilt from the
   registry); no `%LOCALAPPDATA%\Programs\jetcarp`; no JETCARP `Run` value, no jetcarp processes.
2. **The user PATH:** ExpandString, 18 entries, `%PNPM_HOME%\bin` unexpanded, no trailing `;` (as
   rc3 left it).
3. **Scoop wasn't installed.** With Jimmie's agreement, Jimmie installed it at 09:55 in a new
   Windows PowerShell window (not as administrator) with `irm get.scoop.sh | iex`, under
   `Start-Transcript`. The execution policy was already `RemoteSigned` for CurrentUser, so that line
   was skipped. **`scoop install git` was skipped** (Jimmie's choice): Git for Windows 2.52 is on the
   machine PATH and Scoop used it to clone itself.
   - Before the run, the installer was downloaded separately and read (sha256 `94f983b1…2f512`, 787
     lines): it reads the user PATH with `DoNotExpandEnvironmentNames` and writes it back as
     ExpandString when it contains `%`.
   - **Installed in 9 s, no Defender or SmartScreen alert** (Jimmie; Defender's history unchanged).
     Scoop v0.6.0 (2026-09-30), the `main` bucket, `C:\Users\jimmi\scoop`.
   - **Check: the PATH stays ExpandString with `%PNPM_HOME%\bin` unexpanded: pass.** The new value
     is exactly the old one with `C:\Users\jimmi\scoop\shims;` in front.
4. **What rc3 left** (`01-before.txt`): `%APPDATA%\jetcarp` has rc3's `app.json`, `host.json` and
   `setup.json` (no `paths.json`, `host-program` or `desktop-pictures`); `%LOCALAPPDATA%\jetcarp`
   has the library (10.6 MB, WAL 0 bytes): 98 patterns, 32 jobs, and Quick Start rows atlas 1,779
   (879 from rc2's build, 900 from rc3's), builtin 364, pack 79. **The starter pack is already
   imported** (rc2's job 4), so S3's setup probably won't run an import, and this wave can't show
   whether an import job records Scoop's versioned path (as the Mac's job 3 recorded the Cellar).
   Also: `%LOCALAPPDATA%\JETCARP`, where `saver install` puts `JETCARP.scr`, is the library's own
   folder (Windows paths ignore case).

## S2. Install with Scoop: pass (one finding for 0.4.1)

Files: `03-scoop-install-jetcarp.txt`, `04-checks.txt`, `05-path-after-install.txt`,
`05-path-type-after-install.txt`, `06-doctor.txt`.

The bucket's manifest (`jprodgers/scoop-jetcarp`, one commit `9a8ef62`, "jetcarp 0.4.0", 10:02 UTC)
was read first: it installs the release's Windows zip, whose hash `84324c6d…b490` matches the
release's `SHA256SUMS`; `bin` is `jetcarp.exe`; one shortcut, *JETCARP* → `jetcarpw.exe`; notes
say to run `jetcarp uninstall` before `scoop uninstall`; `checkver`/`autoupdate` from GitHub and
`SHA256SUMS`. No `persist`, no installer script.

`scoop bucket add` and `scoop install jetcarp`, run by Claude at 09:56:46 (auto mode didn't block
them): **exit 0 in 1.1 s and 8.2 s.** It downloaded 26.1 MB, checked the hash, extracted, linked
`~\scoop\apps\jetcarp\current => ~\scoop\apps\jetcarp\0.4.0`, made the `jetcarp` shim and the
*JETCARP* shortcut, and printed the notes.

1. **No Defender or SmartScreen alert: pass.** Jimmie saw none; `Get-MpThreatDetection` still has
   only rc2's two detections, no Defender events since 09:50, no allowed threats. The files have
   no Mark of the Web.
2. **The command: pass.** `(Get-Command jetcarp).Source` is `C:\Users\jimmi\scoop\shims\jetcarp.exe`
   (the shim says `path = "C:\Users\jimmi\scoop\apps\jetcarp\current\jetcarp.exe"`);
   `jetcarp --version` says `jetcarp 0.4.0`. `jetcarp.exe` now has a version resource (FileVersion
   0.4.0, ProductName JETCARP; rc1 found none).
3. **`bundled:` names the starter pack under `scoop\apps\jetcarp\`: pass, but through the versioned
   folder:** `bundled:  C:\Users\jimmi\scoop\apps\jetcarp\0.4.0\packs`, not `...\current\packs`,
   although the shim and the shortcut both run `...\current\...`. So JETCARP resolves the `current`
   junction to its target, as on the Mac (`Cellar/jetcarp/0.4.0/share/...`). `scoop update` deletes
   `0.4.0` later; anything that records this path (a pack import's spec) would then name a missing
   folder. See S4 for what the host and the saver record.
4. **`scoop info` / `scoop status`: pass.** Version 0.4.0 from the bucket `jetcarp`, installed
   0.4.0, binaries `jetcarp.exe`, shortcut JETCARP; `scoop status`: "Scoop is up to date. Everything
   is ok!"
5. **The PATH: pass.** Unchanged since Scoop's own install (still ExpandString, `%PNPM_HOME%\bin`);
   JETCARP added nothing to the user or machine PATH (Scoop's shim does it).
6. **`jetcarp doctor`:** exit 0; the four folders (bundled as above, 1.5 MB), the library 10.6 MB;
   the RTX 3050 starred, WARP marked "software adapter: the GPU simulation does not use it"; host
   not running, no login entry, no saver. Neither `paths` nor `doctor` touched the settings folder.

The Start-menu shortcut is `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Scoop Apps\JETCARP.lnk`
→ `C:\Users\jimmi\scoop\apps\jetcarp\current\jetcarpw.exe`, working folder `...\current`.

## S3. A first run with the Scoop copy: pass (titles only partly; two findings for 0.4.1)

Files: `07-wizard-welcome.png`, `08-build-poll.txt` (every 10 s: the app's CPU in cores, working
set, GPU, and the build job's status lines), `08-wizard-1005-publishing.png`,
`08-quick-start-1005-after-later.png`, `09-quickstart-library.txt`, `09-pack-entries.txt` (read-only
library queries), `10-jobs-after-setup.txt`, `11-hunts-imported.png`, `12-export-view.png`,
`12-export-world.png`, `12-verify-png.txt`, `12-window-at-export.png`, `13-after-close.txt`.

1. **rc3's settings moved aside** at 09:59:07: `%APPDATA%\jetcarp` (`app.json`, `host.json`,
   `setup.json`) → `%APPDATA%\jetcarp-rc3-settings`. The library stayed.
2. **Start → Scoop Apps → JETCARP opened with no console window: pass** (Jimmie; 10:01:12).
   Processes: `explorer.exe` → `...\scoop\apps\jetcarp\current\jetcarpw.exe` →
   `...\current\jetcarp.exe` (with a hidden `conhost.exe`, as for any console program started
   without a window). The window opened at (163,93), 1402x932, inside the work area. **The wizard
   opened by itself** on Welcome over a Quick Start of **2,221 entries (Packs 79, Atlas 1,779,
   Built-in 363)**. Starting the app created `%APPDATA%\jetcarp\app.json`.
3. **The build.** Jimmie chose Explorer, kept the starter pack and set the search to 2 minutes;
   Start at 10:02:50 (job 32's `created`).
   - **The starter pack was imported again** (job 32, 10:02:50-10:02:54), although rc2 had
     imported it into this library: 0.4.0's pack is a new manifest (`sha256:722f7750…`, rc2's was
     `a78bbe8d…`). "0 patterns new, 26 merged, 48 Quick Start entries, 0 ant runs." The Quick Start
     showed **Packs 127** during the build (10:04:59), without a reload.
   - **Start to done: 2 min 30 s** (job 33: created 10:02:52, finished 10:05:22; the job's own
     count 2 min 28 s). "349 atlas entries published (349 new, 0 updated, 0 removed)"; 3,238 runs,
     1,078 elites in 603 niches, 6 confirmed, 8 of 1,359 tilings, on the RTX 3050 (Vulkan).
     *threads:* "6 for runs on the processor and 4 for the GPU's batches, of 12 cores (2 left
     free)". The app's CPU peaked at **10.5 cores** (search and publishing; rc3: 10.6), working set
     up to about 1.3 GB.
   - **Check: the new entries show without opening a world: pass.** At 10:05:14 the wizard was
     still on "publishing its atlas into the Quick Start" (Atlas 1,779); at 10:05:29 Jimmie had
     pressed *Later* and the Quick Start already said **2,618 entries, Atlas 2,128** (= 1,779 +
     349), with no card opened. Jimmie: "Atlas went up to 2128". (rc3: only after a world was
     opened and closed.)
   - **Check: this build's titles: partly** (`09-quickstart-library.txt`; only the 349 rows created
     after 15:00 UTC). **256 distinct titles, 218 used once**; elementary (*Rule N*), Generations,
     Life-like, GH, Cyclic, Hodgepodge, RPS, Layered and turmites carry their notation. But, as on
     the Mac, different rules still share plain titles: *Oscillating Priority* ×16 (13 rules),
     *Frozen Priority* ×12 (10), **Battle JACA ×9 (9 rules)**, *Forest fire* ×7 (6), *Agents* ×6
     (5), *Short-lived Priority* ×6, *Short-lived Continuous* ×5 (Lenia). **JACA falls back over
     about 20 characters:** every notated JACA title's notation is 4-19 characters, every plain
     *Battle JACA* has 24-33 (such as `+B1236/S9,11,12 -B236/S9,11,12`). And one rule on several
     tilings shares one title: *WireWorld* ×4, *Spectre glider (Edmond 2026)* ×4, *Abelian
     sandpile* ×3, *Greenberg-Hastings* ×2. Priority has 5 titles for 37 entries.
   - **Finding: re-importing the starter pack keeps the old version's entries**
     (`09-pack-entries.txt`). rc2's 79 pack entries stay (old manifest, rc2's titles such as plain
     *Battle JACA*, *Fractal Layered*, *Fractal Hexagonal elementary*) and 0.4.0's import added 48
     with new handles, so **the Quick Start has 127 pack entries where a fresh library (the Mac) has
     79**, and **10 of the new ones have the same title, rule and tiling as an old one**, so they
     show twice (*Abelian sandpile*, *Agents* ×3, *Forest fire*, *Gliding Continuous*, *Growing
     Continuous*, *Hex3 rule 90 (NW xor NE)*, *Rock-paper-scissors*, *Rule 105*). `setup --status`
     still says the pack has "79 Quick Start entries". A user who upgrades and runs setup again
     gets this; so would a later `scoop update`/`brew upgrade` with a new pack.
   - **Finding (as on the Mac): the pack import job records Scoop's versioned path.** Job 32's spec
     says `"path": "C:\\Users\\jimmi\\scoop\\apps\\jetcarp\\0.4.0\\packs\\jetcarp-starter"`, which
     `scoop update` will delete (rc2's job 4 already names the deleted
     `...\Programs\jetcarp\packs\jetcarp-starter`). A finished job, so it matters only if something
     reads the path again.
   - `setup.json` lists jobs 32 and 33, `data_dir` the default `%LOCALAPPDATA%\jetcarp`.
4. ***Tools → Hunts…*: pass.** The pack's hunt rows (#6-#26) say **Hunt · done · *from a pack* ·
   *imported* · – · –** (Jimmie, and `11-hunts-imported.png`). With #14 selected the detail says
   "**Imported from pack jetcarp-starter**: its finds came with the pack, and nothing ran here", with
   its two finds (p17 oscillator 13c) shown. No `sha256:` hash. (It names the feed's id
   `jetcarp-starter`, not the title "JETCARP starter pack".) The window's header counts 33 jobs.
   Still as the Mac found, in the terminal: `jobs status 26` prints "hunt 0: 0 soups, 0 soups/s …
   status , 0 s run", and `jobs list` names the pack by `sha256:a78bbe8d…` hash.
5. ***Export the view as PNG…* and `jetcarp verify`: pass.** Jimmie opened *Four-colour turmite
   LLRR* and exported the view (1062x850) and the world (2400x2400) into this folder.
   `jetcarp verify 12-export-view.png` → **`ok: generation 42 hash f2b91a6b95c4dfe7`**;
   `jetcarp verify 12-export-world.png` → **`ok: generation 67 hash 9c16fdd3f7b6629f`**, both exit 0.
   (rc3: "stream did not contain valid UTF-8".)
6. **Closed with the window's X: clean.** `jetcarp.exe` and `jetcarpw.exe` both **exit code 0** at
   10:14:16 after 13 min (1,530 s of CPU); no WER reports; no jetcarp processes left;
   **`library.sqlite-wal` 0 bytes**. A new empty `library.sqlite-jobs` folder (job locks) stays.

## S4. Paths that must survive `scoop update`: pass

Files: `14-host-login-on.txt`, `15-host-start.txt`, `16-host-paths.txt`, `17-saver-install.txt`,
`17-saver-dialog.png`, `18-saver-remove.txt`, `19-host-stop-login-off.txt`.

1. **`login on` and `host start`: pass.** Jimmie ran `jetcarp host login on` in his PowerShell
   window (auto mode blocks this session from writing a login entry): `"…\current\jetcarpw.exe" host
   serve --login starts at login`. Claude ran `jetcarp host start` through the shim at 10:22:51
   (output to a file): exit 0 at once, "running, pid 16988, up 2.0s, 207 MB, GPU NVIDIA GeForce RTX
   3050 … screen 0: A classic a day · Quick Start langtons-ant (2 of 7) · starting · window". With
   no `host.json` (rc3's was moved aside), the host shows its screen as an ordinary window.
   - **The `Run` value names `current`:** `JETCARP REG_SZ
     "C:\Users\jimmi\scoop\apps\jetcarp\current\jetcarpw.exe" host serve --login`.
   - **`host-program` names `current`:** `C:\Users\jimmi\scoop\apps\jetcarp\current\jetcarpw.exe`,
     `host`, `serve` (one per line).
   - The host runs from the link: `…\current\jetcarpw.exe host serve` → `…\current\jetcarp.exe
     host serve`. So the host and the login entry keep the path they were started with, while
     `bundled:` and the pack import (S2, S3) resolve the junction to `0.4.0`.
2. **`saver install`: pass.** Jimmie ran it (auto mode blocks it): "copied to
   C:\Users\jimmi\AppData\Local\JETCARP\JETCARP.scr; Screen Saver Settings is opening". The `.scr` is
   a copy of `jetcarpw.exe` (243,712 bytes), in the library's own folder (`%LOCALAPPDATA%\jetcarp`;
   case doesn't matter). `rundll32 desk.cpl,InstallScreenSaver` set `SCRNSAVE.EXE` to it before the
   dialog appeared.
   - **The dialog's preview shows JETCARP, moving** (Jimmie). Its processes: `JETCARP.scr /p 461360`
     → **`C:\Users\jimmi\scoop\apps\jetcarp\current\jetcarp.exe host scr /p 461360`**, so the `.scr`
     found `jetcarp.exe` through `host-program`'s `current` path. (The PrintWindow capture,
     `17-saver-dialog.png`, shows the desktop inside the little monitor: it can't draw the GPU
     preview.)
   - Small: the dialog's list names it **"Jetcarp"**, not "JETCARP" (Windows title-cases the file
     name when the `.scr` has no description string).
   - Jimmie pressed Cancel. That doesn't deselect it: InstallScreenSaver had already selected it
     (`saver status`: "JETCARP is the selected screen saver"; known since rc1). Then Claude ran
     **`saver remove`: "removed", exit 0**; `saver status`: "not installed"; `SCRNSAVE.EXE` gone,
     `JETCARP.scr` deleted, ScreenSaveActive 1 and timeout 60 as before the wave.
3. **`host stop` and `login off`: pass.** `stopped`, exit 0; the host (`jetcarp.exe`) and its
   launcher (`jetcarpw.exe`) both exit code 0; `login off`: "the host no longer starts at login",
   and **the `Run` value is gone**; `host status`: "not running"; no jetcarp processes; no WER
   reports. Left behind: `host-program` (still naming `current`) and a 0-byte `host.lock`.

## S5. Clean up: done

File: `20-after-wave.txt`.

1. **Jimmie keeps the Scoop copy** (JETCARP 0.4.0 from the bucket `jetcarp`) as the everyday
   JETCARP, with today's Explorer settings (`app.json`, `setup.json`, `host-program`) and the
   library (rc1-rc3 and today's 349 atlas entries; WAL 0 bytes); no host, login entry or screen
   saver; *JETCARP* in Start → Scoop Apps. `scoop status`: everything ok.
2. **Scoop stays** (v0.6.0; buckets `main` and `jetcarp`). The user PATH is the value from before
   the wave with `C:\Users\jimmi\scoop\shims;` in front, still ExpandString with `%PNPM_HOME%\bin`.
   **rc3's moved-aside settings went to the Recycle Bin** (10:35:46), with Jimmie's agreement.
   Defender: still only rc2's two detections, no allowed threats.
3. `NOTES.md` has the dated note.
