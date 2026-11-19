# The rc.4 pre-check on the Mac (NOTES, 2026-11-16 12:30 PM EST)

MacBook Pro M2 Max, macOS 27.2.1, on mains, the built-in display only (the Q3277 went back to the Framework after
M-8). Unattended, Jimmie out. The branch `release-0.4.2` at **af07766** ("host status gives the speed a screen reaches
when it falls short of its scene's (#116)"), built in `~/jetcarp-rc-042c/src` and copied to
`~/jetcarp-rc4-pre/bin/jetcarp`. Everything ran in a fresh test folder, `~/jetcarp-rc4-pre` (`JETCARP_CONFIG_DIR`,
`_DATA_DIR`, `_OUT`, `_RUNTIME_DIR`), which leaves rc.3's `~/jetcarp-rc-042c/config` (its fitted `host.json`) for
rc.4's #112 row. Scripts: `pre.sh` (build, warning, doctor, parity, suite), then `soak.sh` (1.5); `summary.txt` has
one line per step.

## Build, the seizure warning, doctor: pass

- `cargo build --release -p jetcarp`: exit 0 in 81 s, no warnings (`build.txt`). `--version` still says
  `jetcarp 0.4.2-rc.3`, as the branch's crates do.
- `jetcarp setup --seizure-warning no-disorder` (no `--yes`, no terminal): "saved your answer to the photosensitive
  seizure warning: no epilepsy or seizure disorder", exit 0; the config folder holds only `photosensitivity.json`.
- `doctor`: exit 0, "self-test: passed (187 ms): 59 world rules and 33 explore batches matched the CPU".

## 1.1 and 1.2, parity on Metal: pass

- **1.1:** 371 scenes at 300 generations: CPU matches 371, GPU matches 371, all on the GPU in 334; no MISMATCH; 74 s.
- **1.2:** 40 scenes at 5,000 generations: CPU matches 40, GPU matches 40, all on the GPU; no MISMATCH; 63 s.
- The same as rc.3's Phase 1 (73 s and 64 s).

## 1.3, the whole suite on Metal: pass

`cargo test --release --workspace --no-fail-fast` (a scratch HOME, no `JETCARP_*` variables): **1,058 passed, 0
failed, 39 ignored, in 143 test binaries**; exit 0, 10 min (`1.3-tests.txt`). rc.3's tag gave 1,027 / 0 / 33 in 141.
The six newly ignored are expected (`1.3-ignored.txt`):
- three Fit tests, "ignored, Fit to this computer is switched off in 0.4.2 (#112); back with Fit in 0.4.3 (#113)":
  `a_tuned_size_is_applied_and_recorded`, `host_tune_sweeps_off_screen_with_no_host`,
  `the_host_sweeps_its_own_screen_and_shows_the_recommended_size`;
- three new app screenshot tests, ignored like the rest of `app::shots`: `a_rule_being_typed_applies_before_save`,
  `jump_field_takes_typing`, `shots_photosensitivity_warning`.

## 1.5, the 8-hour desktop soak: pass; #95 pass

- Started **18:03:32 UTC** (1:03 PM EST); 97 samples, one every 5 min (0 to 8 h), to 02:03 UTC; then the #95 check
  below; then `host stop`. `soak.csv` (one row a sample), `soak-status.jsonl` (each `host status --json`), an hourly capture
  of the host's own desktop window (`soak-shot-NNh-w0.jpg`: nothing else is in it), and a commit and push each hour.
- **The start:** `host wallpaper on` with no host running says "saved; the host is not running" (exit 0) and starts
  nothing, so the script ran `host start` (pid 44732). The default rotation is **"A classic a day"**, starting at
  "Quick Start turmite-llrr (5 of 7)": 170,648 cells of 8 px, 60 fps, 240 generations a second, on the CPU
  ("automatic, and the world is too small to be worth the GPU").
- **The first sample:** status memory 209 MB = `footprint` 209 MB (#80: the status gives the footprint now), RSS 112
  MB; CPU 56% (`top`); measured speed 240.0 of 240; not held.
- **Sleep:** on mains, system sleep prevented (powerd and `caffeinate -is`), and **display sleep is set to never** on
  this Mac (`displaysleep 0`, no screen saver: `idleTime 0`), so the display stays on and the host should run the
  whole 8 hours. To see #95 anyway, the script ends with `pmset displaysleepnow`: 3 minutes of samples every 15 s, then
  the display woken (`caffeinate -u`) and 90 s more (`soak-95.csv`).

### The result (`soak-summary.txt`)

- **Alive throughout:** 97 of 97 samples, the one host (pid 44732) from start to end, up 29,156 s. Never held, never
  paused, no errors. `host stop` at the end: "stopped", exit 0.
- **Memory steady by footprint (#80):** 211 MB in 94 of 97 samples (209 and 210 MB at the start); first hour's median
  211 MB, last hour's 211 MB; slope −0.06 MB/h. One sample read 233 MB (20:03:34, the 2-hour mark), and the next
  read 211 MB again. Status memory followed the footprint: 209 → 210 MB (−0.11 MB/h). RSS 111–113 MB.
- **The screen keeps changing:** screen 0's generation moved in all 96 intervals, from 0 to 6,974,838 at the end
  (240 a second); between the hourly captures, 66% of the pixels changed in the first hour and 84–93% in each hour
  after (the turmite filling the world). The captures hold only the host's window.
- **Speed:** measured speed 239.5–240.4 of 240 in every sample (#116).
- **Load:** CPU (`top`) median 64.5% of a core, the simulation being on the CPU; whole-GPU use median 13%.
- **One scene all 8 hours:** "A classic a day" changes its scene once a day, so the soak stayed on "Quick Start
  turmite-llrr (5 of 7)". It covered a long run of one scene, not the change between scenes, and the simulation on
  the CPU, not the GPU (question 4).

### #95: the display put to sleep, then woken (`soak-95.csv`)

- 02:03:40 UTC: `pmset displaysleepnow`. **Within 15 s the host was held**: `held` ["covered", "dark"], "windows
  cover the desktop; the screen is locked or off", then from 02:04:36 ["dark"], "the screen is locked or off". The
  generation stood at 6,920,542 for the whole time it was held; CPU 0.1–1.3%; the footprint fell from 211 MB to 51 MB.
  `paused` stayed false (held is separate from pause), and the screen's `hidden` stayed false.
- **The hold ended at the sign-in.** By the next sample (02:05:29) the host was running again: not held, 240
  generations a second, footprint 210 MB, CPU 62%. The samples the script labels "asleep+90s" to "+180s" were taken
  with the display on, and the script's own `caffeinate -u` (02:07:15) had nothing left to wake.
- **What the display did** (`95-display-log.txt`, from `pmset -g log`; the main session asked at 9:10 PM, since the hold
  ended before the script woke the display). In EST; the system itself never slept:
  - 21:03:43 off (the script); 21:03:47 on, from "Bluetooth LE HID Activity" (Jimmie bumped the mouse by accident), at the lock screen; 21:04:17 off (30 s
    idle at the lock screen). The two "covered + dark" samples fall in that 30 s: the lock screen covers the desktop.
  - 21:05:09 on, from a mouse event (Jimmie, back at the Mac); the 21:05:11 sample was still held ("dark": locked).
  - 21:05:17 loginwindow: Jimmie signed in. The host ran again by 21:05:29.
  - So the host stayed held while the display was off and while it was on at the lock screen, and let go only after
    the sign-in.
- **#95: pass.** The NOTES step 3 repeat (for a display that stayed off the whole time) isn't needed.

## Questions (recorded, not asked; the run carried on)

1. **Display sleep is "never" here**, so the soak can't show #95 by itself. I added the `displaysleepnow` check at the
   end. If the Mac locks when its display sleeps, the host stays held at the lock screen until Jimmie signs in; the
   script stops the host afterwards anyway. (It did lock; Jimmie signed in 97 s into the check, which was enough: `95-display-log.txt`.)
2. **`host wallpaper on` with no host starts nothing** ("saved; the host is not running"). Is that intended? A newcomer
   might expect "on" to show it. `host start` is the next step either way.
3. **My script's first push failed** after parity: its log, inside the repo, was being written while
   `git pull --rebase --autostash` ran, which stopped the rebase ("Your local changes … would be overwritten"). The
   commits stayed local; I pushed them by hand, and the soak's pushes now keep git's messages outside the repo. All
   ten of the soak's pushes went through.
4. **The default soak covers one scene, on the CPU.** "A classic a day" keeps a scene all day, and its scene that day
   (turmite-llrr, 170,648 cells) runs on the CPU ("the world is too small to be worth the GPU"). So the 8 hours tested
   neither a scene change nor GPU simulation over time. Is that the soak wanted, or should rc.4's 1.5 also run a
   rotation that changes often, or a scene big enough for the GPU?
