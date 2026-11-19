# v0.4.2-rc.3 on the Mac

Test folder `~/jetcarp-rc-042c` (`$T`), with `JETCARP_CONFIG_DIR`, `JETCARP_DATA_DIR`, `JETCARP_OUT` and
`JETCARP_RUNTIME_DIR` in it. Homebrew's 0.4.1 and its folder untouched.

| Step | Result | Notes |
|---|---|---|
| 0 Unpack, doctor | pass | tar.gz sha256 2125d411…ba39daac matches `SHA256SUMS` and the start note; `jetcarp 0.4.2-rc.3`; doctor "passed (191 ms)", then "kept from before" |
| 1.6 Deterministic hunt | pass | 1,783 distinct, 760,892 objects (ships 51,012, osc 236,468, still 473,412); every group identical to rc.2; 12 s (10,519 soups/s) |
| 1.1 Parity (Metal) | pass | 371/371 CPU and GPU; 334 all on the GPU; 73 s |
| 1.2 Long-run parity (Metal) | pass | 40/40 CPU and GPU at 5,000 gens, all on the GPU; 64 s |
| 1.3 Test suite (Metal) | pass | tag 400d41d, `cargo test --release --workspace --no-fail-fast`: 1,027 passed, 0 failed, 33 ignored in 141 binaries; 11 min |
| 1.4 Long search (240 min), kill, resume, pack | pass | 1,142,553 + 17,664 runs; 0/s once (first probe after the resume), median 78/s. #49 stale at 1.2 s; #50 exit 5; #51 ended by itself at 239.6 min; #35 pack 86 MB, import has every row; #54 confirmed 3,327 = 3,327. #53: RSS 8.6 GB at the end, footprint 1.6 GB (7.9 GB reclaimable Malloc Small). The script was restarted at 00:44 adopting the search (my bash 3.2 bug; see notes.md) |
| 1.5 Desktop overnight | not run | needs 8 idle hours; Jimmie starts it |
| **Phase 2** | | Empty settings and library from here; Phase 1's in `$T/phase1/`. `env2.sh` |
| 2.0 Unpack and check | pass | fresh download identical to `bin`; #17 (passed, then kept), #21, #26, #40 all as expected; R #47 pass. Small: `paths` doesn't name the runtime folder |
| 2.G1 Self-test | pass | 59 world rules and 33 explore batches: automatic, `JETCARP_GPU=M2`, `Apple` + `WGPU_BACKEND=metal`. Finding: `JETCARP_GPU=off` says "not tested" but tests and writes `gpu-checks.json` |
| 2.1 GPU explore (M1) | pass | 57,109 runs (103/s) on Metal with no `--gpu`, 419 confirmed; 0/s only in the opening line (#22); "(N of them confirmed)" everywhere (#24); Jimmie: "Usable, no lag" |
| 2.2 Replays (M2) | pass | 30/30 match to 6 decimals; 5/5 hashes equal on `--cpu`, `--gpu`, no flag; penrose-rhomb 35,000 cells (#55) |
| 2.3 CPU confirms, stop, resume (M3) | pass | 21 confirmed, 90 confirmation runs; `jobs wait` exit 3 1.15 s after the stop, process gone; resume accepted at once (#16) |
| 2.4 Smart JACA (M4) | pass | #25's parents line at start and in status; all 7 origins, random 28.4%; `sign_*` filled for every JACA run |
| 2.5 Rating page (M5) | pass | 48 clips; R #56: "categories: Battles 48", no Frozen/Quick deaths/Static/Quiet slots. Safari: keys, reload, Save to Downloads, light and dark all fine; Chrome fine (no Save). Review recorded once (second time adds nothing); #33's `[keep ★]` etc. Jimmie: 4 keep, 15 maybe, 29 drop ("Lots of static") |
| 2.6 Refit, score (M6) | pass | First refit refused clearly (4 keeps). Rounds 2 (top 48: 0 keeps) and 3 (144 broad: 3 keeps). Refit on 239 ratings: held-out AUC 0.806 (built-in score 0.468). Rescore: 243 → 173 confirmed, status names the model (#30, #36); scored search names it; CSV 12,840 rows, 41 fields |
| 2.7 Wait and caps (M7) | pass | exit 0, 3, 6; killed hunt stale at 0.1 s and `jobs wait` 6 at once (#49); resumed; #31's note |
| 2.8 Rules (M8) | pass | V rules edge-neighbourhood; `B4v7` error says where V goes; bad rules file refused before any job, line 3; "in each of 6 groups" |
| 2.9 Soup and scripts (M9) | pass | 6 ships each rebuilt and found at the Acer's generations; `--best 3` = soups 4526, 7794, 9324; JACA script as before |
| 2.10 Packs (M10) | pass | unsealed export carries every run (#35); import identical rows, "not run here yet" (#37); R #54: 173 = 173; R #57: both running exports refused (empty and 4,096 runs), no `--to` folder, but an empty hidden `.store` left (known, fixed for rc.4); `M10-pack.zip` committed; the Acer's and the Framework's rc.2 packs import |
| 2.APP 1 Every menu, pane, pop-out | pass | 3 rounds from the menu table (10 menus, 15 tool windows, 12 panes); saved scene and PNGs pass `verify`. Findings: Keep awake not on macOS (fixed on the branch, #89) |
| R #58 Width × height, HashLife in place | pass | 256 × 256 wrap; Jump ahead (HashLife) 1,000 in place, live cells equal 1,000 plain steps. Finding: the Jump field closes on click (fixed on the branch, #88) |
| 2.APP 2 AI control | pass | on, pop-out, quit (port closed), restart off and opens; R #60 "Open connections 2". **Finding: a hidden app (minimised, covered, other Space) stopped: no answers, no simulation** (fixed on the branch, #87) |
| 2.APP 3–4 Shortcuts, light/dark, sizes | pass | Findings: ⌘H hides the app (macOS), F11 shows the desktop (macOS) |
| 2.APP 5 Quick Start, edit, save, reopen | pass | R #61: click on the grid applies, Esc restores (one unexplained first try: maybe a click outside the app) |
| 2.APP 6 PNG, GIF, WebP | pass | R #62: File → Export animation makes a GIF and a WebP; both play |
| 2.APP 7 Script examples | pass | all 7 run (hexw3-atlas: 19,683 PNGs in about 2 min) |
| 2.11 JACA colours, GPU | pass | Koi vs Tide easy to tell; Life 2048 × 2048: GPU 330 gens/s, CPU 40; JACA Cairo 4M: GPU 130, CPU 17. R #59: GPU adapter menu |
| 2.APP 8 An hour of JACA | pass | 4M Cairo cells, 127.3 gens/s for 61 min (125–128 each 10 min), memory flat 557–576 MB |
| 5fcef69 check (#87, #88, #89) | pass | minimised and covered: answers every 2 s, 15 gens/s (covered: ≈ 99% CPU); `2^20` typed and jumped; Keep awake's assertion on and off |
| 2.D 1 Show just this scene | pass | desktop switched to the hat; rotation and profile saved; screen saver's choice unchanged |
| 2.D 2 Make a rotation | pass | "My rotation" saved, shown, order swapped; R #74: Quick Start added from the search box |
| 2.D 3 Every generation | pass | Life 60 fps = 60 gens/s, blinkers even; turmite 60 fps, 120 with `max-fps refresh`; low power 30 = 30, host CPU halved |
| 2.D 4 Fit to this computer | pass, with gaps | 3 scenes × 9 sizes, 32 → 2 px (1 px never tried); Recommended = finest within limits (CPU only), flips between sweeps at 4 px; GPU not measured (plain note), but Activity Monitor puts the host at 30% (limit 25%). R #69 pass (162 MB after 6 sweeps). R #73 passes in M-8 (2.MM). Jimmie saw a fit "restarting"; not confirmed in the host |
| 2.D 5 Picks | pass | `--pick 4`, `3`, `own` and "Use the scenes' own sizes" all place every scene; each pick re-runs the sweep |
| 2.D 6 GPU overrides | pass | R #75: `host status` names each screen's simulation and reason after each change; doctor agrees; the host really moves to the CPU |
| 2.D 7 Pauses | pass | busy CPU, full-screen video, battery: each held and resumed; R #76: "held: … (resumes by itself)" |
| 2.D 8 Sleep and wake | pass | held before sleeping and on the sign-in screen, resumed 11 s after waking; same process |
| 2.D 9 Lock screen | pass, with a finding | held while locked; macOS's own lock picture; live after. **Finding: when the display turns off while locked, the host runs (≈ 63 gens/s) until the screen comes back** |
| 2.D 12 Host crash | pass | `kill -9` leaves the own wallpaper; `host start` live in 1.2 s; `still on` + crash leaves the own picture; `still on` + clean stop sets a still; `still off` puts the own picture back |
| 2.D 11 Screen saver | pass | (default folders) `saver install` builds JETCARP.saver; it showed the Wolfram series; `saver remove` works with System Settings open, puts the old saver back |
| 2.D 10 Start at login | pass | (default folders) a LaunchAgent; the host started 1 s after login with "Classics, hourly"; `login off` removes it (launchd keeps the job loaded until logout). **Finding: a host in the default folders runs rc.3's built-in sync on the everyday library** (restored from backup) |
| 7e1bbc3 check (#95) | **fail** | locked + display asleep: macOS reports asleep (CGDisplayIsAsleep 1) and locked (CGSSessionScreenIsLocked 1), yet the host drops its hold and runs; see notes |
| 67a08a6 check (#95 again) | pass | locked + display asleep: held (`dark`) throughout, generation unchanged until unlock; the monitor disappears while the display sleeps, as the main session thought |
| 4.1 Every tool | pass | 53 calls (pack publish needs `pack key`, as designed); host_control, app_display, use_app with the app: all work (the app's world runs and pauses over MCP) |
| (private) part 4.2 | pass | `4.2*` files |
| 4.3 Bad input | pass | R #68: argument errors name the argument |
| 4.4 Long jobs | pass | MCP jobs run on after the server closes; R #64: the server's own hunt left paused; **with the app minimised a standalone MCP search runs on (2,244 soups/s)**; the app's world waits (rc.3's #87, fixed on the branch). Finding: ⌘M does nothing in the app |
| 5.1 Odd files | pass | every odd scene and damaged pack refused clearly; R #66 pass |
| 5.2 Two programs | pass | CLI explore + MCP hunt on one library with the app open; each stopped from the other |
| 5.3 Limits | pass | 256M cells: Metal 4.0 s / 3.36 GB, CPU 22 s; over-limit refused; R #63 pass. 64M-cell host world not run |
| 5.5 No room to write | pass | R #65: "Permission denied" in every writing tool; R #67 pass |
| R #47, #57 | pass | #57: refused, no folder; empty `.store` left (fixed for rc.4) |
| 3.2 Upgrade from 0.4.1 | pass, with a finding | 0.4.1 used (desktop-art, a hunt, ratings, wallpaper + login), rc.3 put in its place; nothing lost (every count, ratings, settings). **Finding: the first login after the upgrade kills the host (Launch Constraint Violation, code signing); the second login works** |
| 3.1 Newcomer's first hour | pass, with findings | installer, setup (Desktop art), hunt, library, MCP (world, picture, search, app) and uninstall all work. Findings on the book: the RC section is far down, no "how to open the app", no icon, command blocks can't be copied (≈ 80 lines), `claude mcp add` is per folder, `uninstall` keeps the program, the uninstall table's command can't be copied, Claude's registration left behind |
| 2.MM 1 Two screens, one per monitor | pass | Retina (scale 2, 120 Hz) and Q3277 (scale 1, 60 Hz), each its own rotation; Jimmie: "both crisp". The app opens on the built-in at its last place |
| 2.MM 2 Fit with two monitors | pass, with findings | each screen its own sweep, but **0 of 67 sizes fit**: the CPU limit is split (5% a screen), and the Retina's frames are 17–20 ms at every size with the Q3277 attached (6.5 ms alone in M-4). Built-in left at 32 px ("blocky"). Host memory 147 → 399 MB |
| 2.MM 3 Unplug, plug back | pass | no crash, one process; screen 1 moved onto the built-in while unplugged; an automatic fit 16 s later; both screens back on their monitors. **Finding: the Fit cards don't scroll sideways** (the selected card can't be seen) |
| R #73 Cards only the shown rotation | pass | after the automatic fit and after fitting "Wolfram series" alone, each screen's fit holds only its own rotation. **Jimmie: a series should be fitted on one rule** (it sampled 40 of 256, 12.3 min) |
| 2.MM 4 Resolution change | pass, with a finding | screen 1 refilled each time; the automatic fit began 13 s after the change but **sweeps every screen**, the unchanged built-in's 40 Wolfram rules first (47 scenes), so the Q3277 wasn't reached ("it did not refit"). Footprint 781 MB at the end |

Next: the external monitor goes back to the Framework. The Mac's Phase 2 (M-1 to M-8) is done. (1.5 is in rc.4's wave.)
