# v0.4.2-rc.5 on the Mac

MacBook Pro M2 Max, macOS 27.2.1, on mains, the built-in display only. The wave in `v0.4.2-rc.5.md` ("The wave"), as
NOTES 2026-11-17 (7:32 AM EST) gives the Mac's part. The pre-release `v0.4.2-rc.5` (c0db1ab) was published at 7:30 AM.
The unattended parts started at 2:59 PM, on Jimmie's go ("Go ahead with rc.5's unattended parts"), after the rc.4
soak (`results/v0.4.2-rc4/mac/soak/`). Jimmie was signed in from 2:57 PM.

- **Downloads** (`~/jetcarp-rc5/dl/rc5/`): the macOS archive (aarch64), the installer and `SHA256SUMS`. Both files
  are OK against `SHA256SUMS`. The archive's `jetcarp` says `jetcarp 0.4.2-rc.5`; sha256 ee21fcd6…, ad hoc signed.
- **Folders:** the rows run the archive's own `jetcarp` (unpacked in `~/jetcarp-rc5/rel`). Each runs in a test folder
  of its own, `~/jetcarp-rc5/homes/<row>`, with every `JETCARP_*` folder variable set (`R5-scripts/lib.sh`, rc.4's).
  The exception is #134, which is about the default folders. It unsets them, and two of its three cases use a scratch
  `HOME` (JETCARP's folders follow `HOME`: `jetcarp paths` puts all five under it).
- **Installed:** rc.5, with its own installer (`~/.local/lib/jetcarp`, linked from `~/.local/bin/jetcarp`), at the
  end of #134. Nothing else of JETCARP's is set up in the default folders: no settings, no login item, no host.

## R5 #128, `host tune --help`: pass (`R5-cli.txt`)

`host tune --help` and `host help tune` each print only "Fit to this computer isn't in JETCARP 0.4.2: it returns,
faster, in 0.4.3. Each scene shows at its own size." (exit 0). `host tune` refuses with the same sentence (exit 1).

## R5 #124, `host login on` with the `JETCARP_*` folders set: pass (`R5-cli.txt`)

- With all five variables set (and the warning answered in that test folder):
  ```
  note: the login item starts the host with the default folders; JETCARP_CONFIG_DIR, JETCARP_DATA_DIR, JETCARP_RUNTIME_DIR, JETCARP_LIBRARY, JETCARP_OUT are not passed on to it
  "$J" host serve --login starts at login
  registered with launchd, which runs the host with the default folders, not this run's
  ```
  No pid this time. That is the fix: the host launchd started is the default folders' (pid 96393, `launchctl print`:
  running; the plist `$J host serve --login`, `RunAtLoad`).
- **What the note warns of, seen:** that host was waiting, held, because the default folders hadn't had the warning
  answered: "waiting: the photosensitive seizure warning has not been accepted". The test folder had no host. So an
  answer given in this run's folders doesn't reach the login item, as the note says.
- **The control** (no variable set; the default folders' warning answered first): no note, and "registered with
  launchd, which started the host (pid 96530)", as in rc.4.
- **Clean-up**, each time: the default host stopped first, then `login off`. `launchctl print` exit 113 at once, no
  plist, no host.
- **The first run** (`R5-cli-1-warning-unanswered.txt`) left out the test folder's answer to the warning. `login on`
  then refused ("JETCARP won't start the background host at login until its photosensitive seizure warning has been
  accepted", with the warning) and registered nothing: #96 working.
- **Seen in passing** (`R5-cli-2-gpu.txt`): a login host with the wallpaper off shows nothing ("window, not shown
  (started at login)"). It stays at "starting", so it never opens the GPU. Its status then reads "GPU none" and
  "simulation: CPU: GPU simulation unavailable: no GPU", on an M2 Max. With the warning answered it's the same, and
  so it isn't the lock screen: Jimmie had signed in. A plain `host start` in a test folder opens the M2 Max at once,
  with the wallpaper off or on, and runs 30 gens/s on the GPU. Cosmetic (question 1).

## R5 #134, the installer's `--uninstall` after `jetcarp uninstall --settings --data`: pass (`R5-134-uninstall.txt`)

rc.5's own installer. On macOS its `--uninstall` looks at `~/Library/Application Support/jetcarp` and
`~/Pictures/JETCARP`.

| Case | Folders still there | The installer's last line |
|---|---|---|
| (a) scratch `HOME`: install, setup, `--uninstall` | the settings folder | "kept your settings, data and pictures in $H/kept/home/Library/Application Support/jetcarp; delete them by hand if you want them gone" |
| (b) **the real `HOME`, the tester's way**: install (from GitHub), setup, `jetcarp uninstall --yes --settings --data`, `--uninstall` | `~/Pictures/JETCARP` (three pictures from rc.3's testing) | "kept your settings, data and pictures in ~/Pictures/JETCARP; …" |
| (c) scratch `HOME`, nothing left: as (b) | none | none: the last line is "removed …/.local (empty, made by the install)" |

- Each removed the program, its link and the folders the install made, and only those.
- In (b), `jetcarp uninstall` said "done: delete the settings folder" (the data folder is inside it and was never
  made) and "Your pictures and exports in ~/Pictures/JETCARP are never deleted". The pictures are still there.
- rc.4's installer, in the same spot, said it kept the settings it had just deleted (rc.4 #103), so #134 is fixed.
- **A wording point:** in (b) the line still begins "kept your settings, data and pictures" while naming only the
  pictures folder (question 2).
- (d) Then rc.5 was installed again (`jetcarp --version`: 0.4.2-rc.5), with no settings folder.

## (private) part 4.2: pass

## Parity on Metal with the release build: pass (`long.sh`, `long-summary.txt`)

The release archive's `jetcarp` (sha256 ee21fcd6…, the installed one too), in a test folder of its own:
- **1.1:** 371 scenes at 300 generations: CPU matches 371, GPU matches 371, all on the GPU in 334; no MISMATCH; 74 s.
- **1.2:** 40 scenes at 5,000 generations: CPU matches 40, GPU matches 40, all on the GPU; no MISMATCH; 64 s.
- The same as rc.4 (75 s and 64 s).

## The suite on the tag: pass (`1.3-tests.txt`, `1.3-ignored.txt`, `1.3-131-debug.txt`)

- `~/jetcarp-rc-042c/src` at **c0db1ab** (`v0.4.2-rc.5`), `cargo test --release --workspace --no-fail-fast`, with a
  scratch HOME and no `JETCARP_*` variables.
- **1,065 passed, 0 failed, 41 ignored, in 143 test binaries**; exit 0, 10 min 47 s; no warnings.
- Against rc.4's 1,058 / 0 / 41: seven more, all passing (rc.5's fixes' tests), and the same 41 ignored. The
  Framework's count is the same, 1,065 / 0 / 41.
- **#131's unit test**, `app::menu::tests::cmd_m_minimises_through_appkit_not_egui`:
  - ok in the release run;
  - ok again in a debug build (`cargo test -p jetcarp-app cmd_m_minimises`, as the plan writes it; 65 s), where it
    panicked on `rc5-fixes` before 8e4b345 (`results/v0.4.2-rc5-pre/mac/`).

## R5 #131, ⌘M then a restore: pass (`131-cmdm.txt`, `.json`, `.jsonl`)

From 4:23 PM, on Jimmie's go ("Ready for #131, start it"), with Jimmie at the Mac. rc.5's release build, `--control`,
in `homes/app131`. The script is the rc5-pre check's (`R5-scripts/t131_cmdm.py`). It runs a 512 x 512 Life world at
speed 30 and polls every 2 s: `world_status` through `jetcarp mcp --app`, the window's on-screen flag and the app's CPU.
While the window is back, it captures the window by its id every 2 s and compares each capture with the one before.

| Cycle | Minimised | After the restore |
|---|---|---|
| In view, before the first ⌘M | | 76 polls, 0 errors, 30.0 gens/s, CPU 53% of a core |
| 1. **⌘M**, the world running, 26 s, restored from the Dock | 13 polls, all answered, 30.1 gens/s, CPU 3% | the window drew at once: 2 of 2 later captures changed (cells and the toolbar's generation), 30.2 gens/s, CPU 45% |
| 2. **The yellow button**, 20 s | 10 polls, 29.9 gens/s, CPU 5% | the same: 9 of 9 changed, 30 gens/s until the script paused the world (14 s after this restore), CPU 47% |
| 3. **⌘M**, the world paused, 42 s | 21 polls, 0 gens/s, CPU 0% | a zoom (0–10 s after the restore) and a pan (22–28 s) both drew; generation 6,544 throughout |

- **The toolbar's generation matches `world_status`:** the capture 4 s after the first restore shows "▶ running gen
  5467" (`131-r1-004s.jpg`). `world_status` said 5,462 just before it, at 30 a second. On rc.4, the toolbar stayed
  at the generation of the ⌘M.
- **Paused, the pixels** (`imgdiff`, each capture against the one before):
  - the zoom and the pan changed the whole world area, 0.6 to 1.1 million pixels a step (`131-r3-010s.jpg` zoomed in,
    `131-r3-028s.jpg` panned);
  - between them (10–20 s), and after the pan, only the toolbar's fps figure changed, 150–330 pixels. So the paused
    world was redrawn only when Jimmie moved it.
  - That's why every capture counts as "CHANGED" in the script's tally, in the rc5-pre check too.
- **The yellow button** behaved like ⌘M, as before: the world kept going while minimised, and the window drew again
  at once.
- **Seen in passing, not part of #131:** before the first ⌘M (140–150 s), the window was still on screen, but the
  app's CPU fell from 53% to 4% while the world kept 30 gens/s. It came back as the window came to the front for the
  ⌘M. Jimmie had moved the window to read the instructions, so another window was most likely over it, and macOS
  doesn't draw a covered window.
- The same result as the rc5-pre check on c976627, now on the tag's release build. Together with the unit test
  above, R5's #131 row passes.

Captures: four kept as JPEG (`131-r1-004s`, `131-r2-004s`, `131-r3-010s`, `131-r3-028s`), each JETCARP's window only.
Every capture's sha256 is in `131-captures.sha256`.

## rc.5 on the Mac: done

Every row of the Mac's part of the wave passes: the downloads, #128, #124, #134, the private row, parity 1.1 and 1.2,
the suite on the tag, and #131 (the unit test and the hands-on cycles). rc.5 stays installed (`~/.local/bin/jetcarp`),
with no settings, no login item and no host.

## Questions (recorded, not asked; the run carried on)

1. **The login host's GPU line:** a host started at login with the wallpaper off reports "GPU none" and "GPU simulation
   unavailable: no GPU" on a Mac with an M2 Max, because it hasn't opened the GPU. Something like "GPU: not opened
   yet (nothing shown)" would say what's true. 0.4.3?
2. **#134's wording:** after `jetcarp uninstall --settings --data`, the installer says "kept your settings, data and
   pictures in ~/Pictures/JETCARP". It names only the folder still there, as the fix intends, but the sentence still
   speaks of settings and data. 0.4.3?
