# The rc.4 wave on the Acer (NOTES, 2026-11-16 9:50 PM EST; `v0.4.2-rc.4.md`, "The wave")

The Acer: on mains, 12 threads, RTX 3050 6 GB Laptop GPU and Intel UHD Graphics, Windows 11 Home. Started
22:04 EST with Jimmie about. rc.4 from the release (`v0.4.2-rc.4`, cf5cbdf, published 21:48 EST).

Scripts, all here:
- `t0_quick.ps1` (the upgrade, then R4's command-line rows), with `t0_mcp.py` (MCP's `host_control`);
- `t87_minimise.py` (#87); `t117_installer.ps1` (#117); `t104_narrow.ps1` and `t104_read.ps1` (#104);
- `t42c_planted.py` ((private) part 4.2);
- `t1_long.ps1` (parity, then the suite on the tag, using `t1_suite_rerun.ps1` and `t1_host_x10.ps1` from the
  pre-check).

Each check has its own folder under `~/jetcarp-rc4`, with every `JETCARP_*` folder set, `JETCARP_RUNTIME_DIR`
included. The everyday 0.4.1 (Scoop) and the default folders are untouched.

## 0. The upgrade from rc.3: pass

- **The download** (`gh release download`): the Windows zip, the installer, the wheel and `SHA256SUMS`, each
  matching `SHA256SUMS` (zip `0caf81ff…2e4f53a9`).
- **rc.4 in place of rc.3** (`0-upgrade.txt`): rc.3's zip was unpacked into `~/jetcarp-rc-042c/bin` in Phase 1.
  - Each of rc.4's 70 files was copied over rc.3's at the same place. None differs from the zip, and nothing
    of rc.3's is left over (the two zips list the same files).
  - `jetcarp --version`: `jetcarp 0.4.2-rc.4`.
- **rc.4 on rc.3's own settings and library** (Phase 1's test folders):
  - `paths` lists the runtime folder;
  - doctor passes, its self-tests "kept from before";
  - `jobs list` shows rc.3's hunt 1 and explore 2 (564,350 runs, 1,953 confirmed), and `library list` 1,454 patterns;
  - `setup --status`: "not run yet" (Phase 1 never ran setup);
  - `host start` is refused with the whole seizure warning, exit 1, since rc.3's settings hold no answer.
  - The desktop is unchanged: no JETCARP Run value, no `SCRNSAVE.EXE`, the same wallpaper picture.

## R4

### #96 The seizure warning: the command line and MCP pass; the app's part waits for Jimmie

Fresh settings folder `f96` (`96-warning.txt`, `96-mcp-refuse.txt`, `96-mcp-accepted.txt`).
- **Refused before the answer, each exit 1 and naming the warning:**
  - `host start`, `host start --headless`;
  - `host wallpaper on` ("won't show the desktop background until…");
  - `host login on` ("…start the background host at login…");
  - `host saver install` ("…install the screen saver…").
- `host start --saver` is a usage error: `host start` has no `--saver` (exit 2). What a screen saver runs,
  `host serve --saver --seconds 1`, is refused on the command line ("won't run the screen saver until…"), exit 1 in
  0.1 s, with no message box (#120).
- **MCP `host_control`** (no host running): resume, next, previous, rotation, `wallpaper` on and `login` on are each
  refused with the whole warning. status and pause say "not running".
- The desktop state (JETCARP Run values, `SCRNSAVE.EXE`, the wallpaper picture, `JETCARP.scr`) is the same before and
  after.
- `setup --seizure-warning no-disorder` writes `photosensitivity.json`:
  `{"version": 1, "answer": "no_disorder", "date": "2026-11-17T03:07:03Z", "jetcarp": "0.4.2-rc.4", "via": "setup"}`.
- **After the answer:** `host start --headless` works. MCP status, resume, next, previous and rotation work on it, and
  `host stop` stops it.
- **Left for the sitting with Jimmie:** the app's warning (Quit first, Continue at my own risk second, Quit
  quits). Also `wallpaper on`, `login on` and `saver install` after the answer: they change the desktop and the
  registry.

### #112 Fit is hidden: the command line and MCP pass

`112-fit.txt`.
- `host --help` lists no `tune`. `host tune` and `host tune --dry-run` refuse, exit 1: "Fit to this computer isn't
  in JETCARP 0.4.2: it returns, faster, in 0.4.3. Each scene shows at its own size."
- **MCP:** `host_control`'s schema has no tune action and no `fps` or `pick`. The calls tune, tune_stop,
  tune_events and tuning are refused with the same sentence, with or without a host.
- **Saved sizes:** this laptop has no rc.3 `host.json` with saved sizes (no Fit ran here under rc.3). rc.1's
  (`~/jetcarp-rc-042`, 2026-11-14) saved 16 px for the three scenes of "Until it settles" (design 3 px). A copy was
  run on a window host, with the screen's rotation set to that one. Each scene shows at its own size:
  - "102240 cells of 3 px" for rule:B3/S23, B36/S23 and B368/S245 (16 px would be 8,040 cells);
  - the saved tuning stays in `host.json`.
- **Small finding:** `jetcarp host tune --help` still prints Fit's whole help, as if it worked ("Fit the desktop
  background to this computer: run each scene…", every option), exit 0.
- **Left for later:**
  - the Desktop background pane, with Jimmie;
  - "a monitor change starts no fit", in A-8.

### #87 The app goes on minimised: pass

`87-minimise.txt`, `.json`. rc.4's app with `--control`: a 512 × 512 Life world at speed 30, `world_status` polled
every 2 s, the window minimised by script for 60 s.

| | polls | gens/s | slowest answer | app CPU (% of a core) |
|---|---|---|---|---|
| in view | 10 | 30.4 | 0.48 s (the first) | 22 |
| minimised | 30 | 30.0 | 0.72 s | 4 |
| restored | 10 | 29.5 | 0.33 s | 34 |

The app closed on WM_CLOSE, exit 0. rc.3 stopped dead when minimised (A-6).

### #116 The speed a screen reaches (UHD): pass

`116-measured-speed.txt`. A-6's 8000 × 8000 Life scene on a window host (the UHD, Vulkan).
- The text says "64000000 cells of 4 px · 30 fps, **7.54 of 30 generations a second**".
- The JSON has `"measured_speed": 7.54` (7.46 at 60 s) beside `"speed": 30`.
- rc.3 said "30 generations a second" here.

### #84, #85: pass

`84-85.txt`.
- **#84:** with `JETCARP_GPU=off`, doctor lists both adapters as "not used, and not tested: the GPU simulation is
  off", and runs no self-test.
- **#85:** `paths` lists `runtime: …\run`, and `paths --json` has `"runtime"`.

### #117 The installer's refusals: pass

`117-installer.txt`, with the released `jetcarp-installer.ps1` (sha256 `71fbb090…`; its default version
0.4.2-rc.4). Parser errors: 0.
- **Refusals:** install into a folder it didn't make, and `-Uninstall` where nothing is installed: each is one line,
  exit 1, with no PowerShell error block.
  - The two refusals inside the download step (an empty folder; SHA256SUMS but no zip) are two lines each, the
    progress line first.
  - No `jetcarp-*` folder is left in `%TEMP%` by any run, and no install folder is made.
- An install with `-NoModifyPath` from the downloaded zip, then `-Uninstall`, leave the user PATH unchanged (value
  and type).
- **For #103 (A-7 checks it):** the uninstall says what it removed and that settings, data and pictures were kept.
  It names `~\OneDrive\Pictures\JETCARP`, this laptop's real pictures folder.
  - **Small finding:** after a `-NoModifyPath` install it says "removed … and took it off your PATH", although that
    folder was never on the PATH.

### #122 start, stop, start: ten times: pass

`122-start-stop.txt`: `host start --headless; host stop; host start --headless; host stop`, ten rounds. Every start
worked (exit 0, 1.2–1.6 s at most), and no process was left.

The busy half, `1-host-rs-tag-x10.txt`: `cargo test --release -p jetcarp --test host -- --test-threads=1` ten
times on the tag, straight after the RTX suite. 10 of 10 passed, each 15 passed and 3 ignored in 41–45 s.

### #104 Progress lines in a 60-column terminal: pass in Windows Terminal; FAIL in the old console window

`104-narrow-*.txt`. A window 60 columns wide runs `jetcarp pack import` (the starter pack) and a half-minute
`jetcarp search explore`. Its text is read row by row during the explore and at the end, with the console's output
mode (`t104_read.ps1`).

| Window | Shell | Output mode while JETCARP runs | The progress line |
|---|---|---|---|
| Windows Terminal 1.25 (Windows 11's default here) | cmd | 0x7 | one row, redrawn in place, cut to 59 columns with `…`: **pass** |
| Windows Terminal | PowerShell 5.1 | 0x7 | the same: **pass** |
| conhost (the old console window) | cmd | **0x3** | `←[2K` printed before each redraw; every redraw leaves a row behind: **FAIL** |
| conhost | PowerShell 5.1 | **0x3** | the same: **FAIL** |

- **The fit works:** the line is cut to 59 columns.
- **The erase code doesn't:** in conhost, the shell runs JETCARP with `ENABLE_VIRTUAL_TERMINAL_PROCESSING` off
  (mode 0x3; 0x7 before and after), and JETCARP never turns it on. So the `ESC[2K` it writes before each redraw
  shows as the four characters `←[2K`, which push the 59 columns to 63. The line wraps, and the carriage return
  leaves its first row behind, as before the fix.
- JETCARP's code has no `SetConsoleMode` call. A small program with the same `windows-sys` (`t104_conwidth.rs`)
  reads width 60 on stderr there.
- Windows Terminal turns VT processing on for the programs it hosts, so a tester on Windows 11's default terminal
  never sees this. Anyone with the old console window does: Windows 10, a default terminal set to Windows Console
  Host, or conhost started directly.
- The pack import's lines are plain lines and wrap normally.
- **My slip, not counted:** the first two tries called a bare `jetcarp.exe` after `cd` into rc.4's folder. This
  session sets `NoDefaultCurrentDirectoryInExePath`, so `cmd` ran Scoop's shim, that is 0.4.1. The process tree
  showed it, and those outputs were deleted. Every other check here names rc.4 by its full path.

### (private) part 4.2: pass

## 1.1, 1.2 Parity with the release build: pass

`t1_long.ps1`, 22:23–23:27, on mains, with rc.4's `jetcarp.exe` from the zip. `1-parity/` holds each run's CSV and
summary; `t1_long.log` is the whole run.

| Run | GPU, backend | Scenes | CPU matches | GPU matches | Every generation on the GPU | Time |
|---|---|---|---|---|---|---|
| 1.1 | RTX, Vulkan | 371 at 300 gens | 371 | 371 | 334 | 8.6 min |
| 1.1 | RTX, DX12 | 371 | 371 | 371 | 334 | 17.9 min |
| 1.1 | UHD, Vulkan | 371 | 371 | 371 | 334 | 6.7 min |
| 1.1 | UHD, DX12 | 371 | 371 | 371 | 334 | 18.8 min |
| 1.2 | RTX, Vulkan | 40 at 5,000 gens | 40 | 40 | 40 | 2.2 min |
| 1.2 | RTX, DX12 | 40 | 40 | 40 | 40 | 3.3 min |
| 1.2 | UHD, Vulkan | 40 | 40 | 40 | 40 | 2.3 min |
| 1.2 | UHD, DX12 | 40 | 40 | 40 | 40 | 3.6 min |

0 MISMATCH lines anywhere. The 37 scenes not all on the GPU are the CPU-only rules (Rule 30 and the like), as on rc.3.

- **As on rc.3:** on RTX DX12, one process of 335 (scene 133, `rule:B35/S234578`) found no RTX and ran on the UHD:
  "gpu (Intel(R) UHD Graphics (31.0.101.4146), Dx12; no RTX adapter was found, so the best one)". Its hash matched.
  rc.3 had the same on scene 115. The pre-check's RTX DX12 run had none.

## 1.3 The suite on the tag: pass

The source at `~/jetcarp-rc-042c/src`, moved from 29fea86 to `git checkout --detach v0.4.2-rc.4` (cf5cbdf, "Release
0.4.2-rc.4"), clean. `cargo test --release --workspace --no-fail-fast`, with a watcher to close any message box
(it closed none).

| `JETCARP_GPU` | Passed | Failed | Ignored | Test binaries | Time | Log |
|---|---|---|---|---|---|---|
| RTX | 1043 | 0 | 41 | 137 | 21 min (6 min of it the build) | `1-tests-rtx-tag.txt`, `1-rerun-rtx-tag.log` |
| UHD | 1043 | 0 | 41 | 137 | 13 min | `1-tests-uhd-tag.txt`, `1-rerun-uhd-tag.log` |

- The two runs list the same tests, and the same counts as 29fea86 in the pre-check.
- The RTX log's first line names `jetcarp 0.4.2-rc.3`. That is the pre-check's build at 29fea86, still in `target`
  when the line was written, before cargo rebuilt it at the tag. `target\release\jetcarp.exe` now says
  `0.4.2-rc.4`. The host ×10 and UHD logs name rc.4.
- **The build's only warning:** `unused import: stable_name` in `crates\jetcarp-core\tests\bundled_packs.rs:3`.
  It is in a test, so it doesn't matter; information only.

## The sitting with Jimmie (2026-11-17, 03:10–04:15): all pass

Jimmie: the Acer's JETCARP data and settings aren't sacred (test builds only), so no copies were kept.

### R4's app rows (`s1_app.ps1`, `s1-app.txt`; `s1_mcp.py`, `s1-mcp.txt`)

rc.4's app (`jetcarp.exe`, no subcommand) on the sitting's folder `~/jetcarp-rc4/s1`.
- **#96:** the warning shows before setup.
  - First open: Jimmie chose "may have a seizure disorder", then Continue at my own risk, then closed the window. The
    app saved `{"answer": "at_risk", "via": "app"}`, as Continue should.
  - Second open, a fresh folder: "may have a seizure disorder" leads to **Quit** first (the big button) and
    **Continue at my own risk** second (Jimmie). **Quit quit**: exit 0, and nothing but `app.json` saved.
  - Third open, the same folder: the warning again; the blue answer saved `no_disorder` via app, then setup ran
    (blank-slate, `setup.json`).
- **#112:** the Desktop background pane has no Fit button, cards or limits (Jimmie).
- **#114:**
  - AI control on; Copy on the `jetcarp mcp --app` row put exactly `jetcarp mcp --app` on the clipboard, and it
    pasted the same into a terminal (Jimmie);
  - the footer calls the address a private link, not HTTP (Jimmie);
  - `B36/S23` copied in Notepad and pasted into the CAs pane's Rule box: the app's CA became HighLife `B36/S23`
    (`world_status` through `jetcarp mcp --app`).
- **#88:** Run → Jump, Generations 4096, from a paused Life scene at generation 0: generation 4096.
- **#90:**
  - typed `B3678/S34678`, no Enter, and Ctrl+S straight away: the saved `rule90.json` (`s1-rule90.json`) records the
    rule change after the Jump, and `jetcarp verify` replays it to its hash;
  - typed `B368/S245`, no Enter, then Alt+Tab to Notepad: the app's CA became Morley `B368/S245`.

### #96 after the answer, and #120, in the default folders (`s2_desktop.ps1`, `s2-desktop.txt`)

What Windows starts (the login entry, the `.scr`) gets no `JETCARP_*` variables, so these ran in Jimmie's account on
the default folders, rc.4 by its full path.
- **Before the answer** (none there): `host wallpaper on`, `login on`, `saver install` each refused with the warning,
  exit 1; the desktop unchanged.
- `setup --seizure-warning no-disorder` saved the answer.
- **wallpaper:** `host start`, `wallpaper on`: "A classic a day", Penrose waves (6 of 7), 280,000 cells of 2.4 px,
  30 generations a second on the UHD's GPU. `wallpaper off`, `stop`: the wallpaper picture's hash as before.
- **login:** `login on` wrote the HKCU Run value `JETCARP` = `"~\jetcarp-rc-042c\bin\jetcarpw.exe" host serve --login`;
  `login off` removed it.
- **saver:** `saver install` copied `JETCARP.scr` to `%LOCALAPPDATA%\JETCARP`, set `SCRNSAVE.EXE` and opened Screen
  Saver Settings; `host-program` names rc.4's `jetcarpw.exe`. Then the answer was set aside (renamed).
- **#120: pass.** Nobody touched the laptop for a minute, so **Windows started the screen saver itself**
  (`JETCARP.scr /s` → `jetcarp.exe host scr /s`, 03:34:54, the 60 s timeout).
  - It showed a JETCARP message box: "JETCARP won't run the screen saver until its photosensitive seizure warning has
    been accepted.", the whole warning, and OK.
  - Windows runs a screen saver on its own desktop (`Screen-saver`), so the box was read there
    (`s2_saverdesk.ps1`: OpenDesktop and EnumDesktopWindows).
  - Jimmie clicked OK, then Preview in Screen Saver Settings, OK again, and closed the dialog.
- `saver remove`: removed, `SCRNSAVE.EXE` empty, the `.scr` gone; the answer put back.

### #100–102 The book: pass (`100-book.txt`, `102-claude-mcp.txt`)

- The online book is still 0.4.1's (its photosensitivity page is 404). The release branch is at the tag, so the latest
  book is rc.4's.
  - mdBook v0.5.4: Jimmie's download; its sha256 matches GitHub's digest for the release asset. Unpacked into
    `~/jetcarp-rc4/tools/mdbook`.
  - The book was built from a copy of the tag's `docs/` (84 pages) and served on 127.0.0.1:3000.
- **#100, the copy buttons:** Jimmie copied three commands from *Hunting for spaceships* with the copy buttons. They
  ran in PowerShell 5.1, with rc.4 first on the PATH and the sitting's folder:
  - `jetcarp search hunt --tilings k2-017 --soups 5000 --label k2-017`;
  - `jetcarp library list --class spaceship`;
  - `jetcarp library show 16bc37`.
  "All three ran as pasted, output matches the book." The hunt's counts match the book exactly: 3357 settled, 788
  died, 703 exploded, 152 unsettled, 13,674 objects, 20 distinct; ship 16bc37.
- **#102:** with Jimmie's OK, `claude mcp add --scope user jetcarp -- <rc.4's jetcarp.exe> mcp` (rc.4 by its full
  path; `jetcarp` on the PATH is Scoop's 0.4.1).
  - From three other folders, `claude mcp list` showed it "✔ Connected", and `claude mcp get` showed "Scope: User
    config (available in all your projects)".
  - Then `claude mcp remove jetcarp -s user`: gone.
- #92's third bullet (the MCP reference) is the Framework's (R4-9), as on the Mac.

## 1.5 The overnight soak: pass

`t15_soak.ps1` (with `t15_shot.ps1`), from 04:24 to 12:24 (8 h), in `~/jetcarp-rc4/soak`. The summary is in
`soak-summary.txt`, the samples in `soak.csv` and `soak-status.jsonl`, the log in `soak.log`, and the stop in
`soak-end.txt`.
- rc.4's host as the wallpaper on the rotation **"Classics, hourly"**, Jimmie's choice. The plan's default, "A classic
  a day", keeps one scene all day (the Mac's question 4); this covers scene changes, still on the UHD's GPU.
- A sample every 5 min (`soak.csv`, `soak-status.jsonl`):
  - `host status --json`;
  - the host's CPU, working set, private bytes and handles;
  - Windows' per-process GPU counters (engine use, dedicated and shared memory);
  - the power source.
- Each hour: a picture of the host's own wallpaper window (`soak-shot-NNh.jpg`), and a push.
- On mains; the power plan never sleeps and never turns the display off on mains; no screen saver set.

**The results:**
- **Alive in all 97 samples,** always the same host: `jetcarp.exe` 32428, under its windowless launcher
  `jetcarpw.exe` 25312.
  - Nothing stalled (a scene's generation always moved between samples).
  - Never held or paused; on mains throughout.
- **The scenes changed on the hour, 8 times,** and all seven classics were shown. Forest fire and Cyclic spirals came
  twice.

  | Scene | Samples | Cells | Simulation | Speed (of) | CPU, % of a core | GPU, % |
  |---|---|---|---|---|---|---|
  | Forest fire (Quick Start) | 20 | 518,400 of 2 px | UHD, Vulkan | 29.98–30.04 (30) | 52.9 | 23.8 |
  | Cyclic spirals | 17 | 230,400 of 3 px | UHD, Vulkan | 29.99–30.01 (30) | 25.7 | 15.0 |
  | Life | 12 | 230,400 of 3 px | UHD, Vulkan | 29.99–30.01 (30) | 24.9 | 15.0 |
  | Hodgepodge | 12 | 230,400 of 3 px | UHD, Vulkan | 29.99–30 (30) | 28.2 | 14.5 |
  | Langton's ant (Quick Start) | 12 | 129,600 of 4 px | CPU ("too small to be worth the GPU") | 239.95–240.08 (240) | 40.0 | 21.5 |
  | Penrose waves | 12 | 280,000 of 2.4 px | UHD, Vulkan | 29.99–30.01 (30) | 30.5 | 52.6 |
  | Turmite LLRR (Quick Start) | 12 | 129,600 of 4 px | CPU | 239.97–240.36 (240) | 43.0 | 22.1 |

  CPU and GPU are medians.
- **Memory didn't climb. Private bytes followed the scene:**
  - 426–430 MB on the first five scenes;
  - 480 MB on Penrose waves (a bigger grid), staying at 477 MB on the turmite after it;
  - 439 MB on Cyclic spirals at the end, against 426 MB on the same scene at hour 1.

  The summary's slope (+6.6 MB/h) comes from when Penrose waves came up. The working set (host status' `memory_mb`)
  fell from 459 MB to 213 MB at 1.5 h as Windows trimmed it, and ended at 237 MB.
  - Handles: 545 at the start, about 455 from hour 1. Threads: 27–30.
  - GPU memory: none dedicated (the UHD is integrated); shared 483.4–485.0 MB.
- **Nine hourly pictures** of the wallpaper window, each the scene its sample named (PrintWindow True, 1920×1080).
- **All eight pushes went through:** hourly at hours 1–7, and the final one (105a8ca).
- **Jimmie looked at the end (12:37):** "Still looks right, smooth and moving, nothing odd."
- **`host stop`:** exit 0, "stopped". Both processes and the `JetcarpDesktopSurface` window were gone, and Jimmie's own
  picture was drawn again. Its file (TranscodedWallpaper, 85FF3BB2371A) was unchanged throughout. `host status` then
  said "the JETCARP background host is not running" (exit 1).

**Langton's ant bounces, so it never restarts** (`t15_ant.ps1`, `soak-ant.txt`). The 05h picture showed a small,
early ant, while host status said generation 357,338 and had never reset. rotations.md says a finished item "starts
again from its beginning", with "Langton's ant has walked off the edge" as its example.
- So after the soak I skipped the host to the ant (`host next`, five times) and watched it for 3 minutes. Host status
  every 2 s, and a picture every 9 s.
- The generation rose steadily from 789 to 43,657, at 240 a second. In the pictures, the ant built its blob and
  diagonal highway, then wound all of it back: highway into blob, blob to nothing (t+27 s, t+150 s). Then it built a
  mirror image with the highway the other way (up and to the right at t+53 s, down and to the left at t+115 s).
- Langton's ant is reversible. The scene format's default `agent_edge` is `"bounce"` ("turn around"), so at the dead
  edge the ant turns round and retraces its path.
- So the item never ends, never restarts, and its generation is right to keep counting. The book's example is for an
  ant set to `fall_off`. Not a finding.

## Still to come

- **Phase 2:** A-7 (with #103) and A-8 (with #112's monitor change; the AOC must be plugged in).
- Clean-up at the end of the wave (mdBook in `~/jetcarp-rc4/tools`; Developer Mode: ask).
