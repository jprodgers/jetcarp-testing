# v0.4.2-rc.2 on the Acer

| Step | Result | Notes |
|---|---|---|
| 0 unpack | pass | Hash `aa024bba…` matches; `jetcarp 0.4.2-rc.2`. doctor took 11.0 s, then 0.9 s with the self-tests kept (#17) |
| 1.1 RTX Vulkan | pass | 371/371 CPU and GPU; all 300 generations on the GPU in 334; 7.4 min |
| 1.1 RTX DX12 | pass | Same; 17.5 min |
| 1.1 UHD Vulkan | pass | Same; 6.8 min |
| 1.1 UHD DX12 | pass | Same; 18.7 min |
| 1.2 RTX Vulkan | pass | 40/40 at 5,000 generations, all on the GPU; 2.3 min |
| 1.2 RTX DX12 | pass | Same; 3.3 min |
| 1.2 UHD Vulkan | pass | Same; 2.4 min |
| 1.2 UHD DX12 | pass | Same; 3.8 min |
| 1.3 RTX | FAIL | 986 passed, 0 failed, 33 ignored. `jetcarp-gpu` `tests\recovery.rs` crashed with 0xC0000005; 8 reruns of it passed |
| 1.3 UHD | pass | 988 passed, 0 failed, 33 ignored. Later, 1 of 3 reruns of `recovery.rs` hung (killed after 10 min) |
| 1.4 | pass except step 3 | 261,392 runs in 2 h, never at 0/s (median 36/s). The export (19.7 MB) sealed every run, and the import has all 261,392. After a hard kill, `jobs status` still said `running` at 2 min (`jobs wait` said gone) |
| 1.5 | not run | Not part of the batch; Jimmie starts it |
| 1.6 | pass | 1,783 distinct, 760,892 objects: the same as the Framework |
| 2.0 | pass | Hash right; `jetcarp 0.4.2-rc.2`. #17: the first doctor (10.4 s) says "passed (521 ms)" and "(639 ms)" and writes `gpu-checks.json`; the second (0.8 s) says "kept from before". #21, #26 and #40 pass |
| 2.G1 | pass | All 5 tested fresh (cache emptied before each): RTX Vulkan 230 ms, RTX DX12 2,659 ms, UHD Vulkan 392 ms, UHD DX12 2,880 ms (and UHD GL 632 ms in 2.0), each "59 world rules and 33 explore batches". `off`: "not used, and not tested". Auto and RTX again: "kept from before" |
| 2.1 | pass | Job 1 names the RTX with no `--gpu`: 32,598 runs (48/s), 286 confirmed. No 0/s after the first line (#22: median 47/s); "(N of them confirmed)" in every line (#24). Jimmie: usable, no lag |
| 2.2 | pass | 30/30 GPU-screened runs replay on the CPU to 6 decimals; 5/5 hashes the same on the CPU, `--gpu` and no flag. Side note: `penrose-rhomb` asked for 16,000 cells gives 35,000 |
| 2.3 | pass | 66 confirmation runs, 18 confirmed. `jobs wait` gave exit 3 2.0 s after `jobs stop`, with the process gone; the resume straight after was accepted (#16) |
| 2.4 | pass | "parents: 500 JACA runs of explore job 2 (its best ones: it has no reviews …)" at the start and in `jobs status` (#25). 13,236 runs; all 7 origins, with random at 29.2%; `sign_*` filled |
| 2.5 | pass (finding) | `--sample 48` gives 48 clips (#29). Keys, reload, Save, light/dark all fine; "works better than the Claude.ai page". `review` counts right and adds nothing the second time; `--reviewed any` shows `[keep ★]`, `[maybe]` and `[drop]` (#33). Finding: 20 of the 48 were "Frozen at once" (12% of the job), all dropped; 40 of 48 dropped in all |
| 2.6 | pass | The first refit refused clearly (2 keeps; it needs 5). After a second round of 48 best-scored clips (11 keeps): held-out AUC 0.850. The rescore rewrote job 3's confirmed count (92 → 67) and its status names the model (#36, #30). The scored search and `jobs status 4` name the model. CSV: 9,510 rows = runs, `sign_*` present (no Excel) |
| 2.7 | pass | Exit codes 0, 3 and 6 as expected; the killed hunt shows as gone in 43.8 s and resumes. #31: "the GPU was asked for, but JETCARP_GPU=off: running on the processor". #32: one line during a 44 s wait (rc.1: 9 repeats) |
| 2.8 | pass | V rules run as edge-neighbourhood Generations rules; `B4v7/S2` says where the V goes; the bad rules file is refused before any job, naming line 3; "30/30 soups in each of 6 groups" |
| 2.9 | pass | Each rebuilt soup produces its ship: glider by 400 generations, HWSS/LWSS 800–1,600, MWSS 2,000–2,500 (as rc.1; #34). `--best 3` gives the same three soups as rc.1; the JACA example matches rc.1 |
| 2.10 | pass (gap) | No `jobs seal`: "sealed its newest 13,524 runs first"; the import has every run (13,236 + 288, identical rows) (#35); "not run here yet" (#37). A running search with 2,112 runs is refused ("stop it first"), but one with no runs stored yet exports silently. `A10-pack.zip` (1.21 MB) committed; the Mac's and the Framework's packs aren't there yet to import |
| 2.APP 1 | pass (2 findings) | Every menu item, tool window and pane, each popped out and back: no crash. `a3-scene.json` and both PNG exports pass `verify`. Findings: the HashLife jump in place needs a power-of-two wrap grid, which the GUI can't make (no width × height; #58); there's no GUI to choose the GPU adapter (#59). "Connections 0" reads oddly (#60) |
| 2.APP 2 | pass | AI control on → listens on 127.0.0.1:47811 and serves (21 tools); pop-out fine; Quit closes the port. Restarted with no world: the window opens, off, and serves once ticked |
| 2.APP 3–4 | pass | Every shortcut in the help; light and dark; very small and very large windows |
| 2.APP 5 | pass (finding) | Quick Start entries from each category and both filters; edit, save, reopen: `verify` ok both times. Finding: the Rule box shows a typed rule that isn't applied until Enter, with no sign of it (#61) |
| 2.APP 6 | pass (gap) | PNG done. GIF only from the Hunts window's Render media, which appears only once a hunt is picked: 40 GIFs, all valid, one opened. No WebP from the GUI (auto format, no choice); the CLI's `--format webp` works and plays (#62) |
| 2.APP 7 | pass | All 7 scripting examples run; hexw3-atlas writes 19,683 PNGs in 136 s |
| 2.APP 8 | pass | A 4-million-cell JACA world for 65 min: 12.2–12.7 gens/s in every 10 minutes, private memory flat at 655–663 MB |
| 2.11 | pass (finding) | JACA's signs easy to tell apart (−1 Koi, cream → orange); nothing worse than 0.4.1. Finding: the app simulates on the Intel UHD, slower than the CPU on a 4-million-cell Life world (21 vs 27 gens/s) and no faster for JACA |
| 2.D 1 | pass | Show just this scene: the desktop switched; a rotation is saved in `rotations\` (with its profile); the screen saver's choice is unchanged (#41) |
| 2.D 2 | pass (small finding) | New, Save ("easy to find") and Edit work, and the desktop shows the rotation. A Quick Start entry is added only by typing its id (no picker) |
| 2.D 3 | pass | Life 60 fps = 60 gens/s, and the blinkers are "even and steady" (#42). Langton's ant 60 fps for 240 gens/s (UHD 38%), 144 fps with `max-fps refresh` (UHD 78%). Low power: Life 30 fps = 30 gens/s, UHD 50% → 27% |
| 2.D 4 | FAIL (timing) | The sweep works: 3 scenes × 8 sizes, 16 → 1 px, from the pane and `host tune --json`. Recommended = the finest within limits; the cards are right (plus a stale row from an automatic fit). But `gpu_timing` is "submission", not "timestamps": the GPU shares are 3–10× Windows' and aren't judged, so the GPU limit isn't applied (2 px uses 31% of the UHD against 25%) |
| 2.D 5 | pass | `--pick 4`, `--pick own` (= 3 px) and `--pick 2` place every scene; the pane's "Use the scenes' own sizes" puts them back (#39). Each pick re-runs the 50 s sweep |
| 2.D 6 | pass (gap) | Off, On, Follow and shared Off all take effect (host CPU 14–18% when off), and doctor is right each time. `host status` keeps its start-up note and never shows the override |
| 2.D 7 | pass | A busy processor (a CPU hunt), a full-screen video in Chrome, and battery each pause the host, and it resumes after each |
| 2.D 8 | pass | Sleep (S3, 53 s) and wake: the host held "the screen is locked or off" before sleeping and on the sign-in screen, and resumed 2 s after sign-in; same process, no error ("live again") |
| 2.D 9 | pass | Win+L: held while locked, resumed on unlock. The lock screen shows Windows' picture (`host lock` is GNOME only) |
| 2.D 10 | pass | In Jimmie's account with the default folders (his choice): `host login on` → after signing out and in, the host started with the saved "Classics, hourly". Windows ran the entry 97 s after sign-in, after the 30 s waits on another program and another program. `host login off` removes it |
| 2.D 11 | pass | `host saver install --rotation "Wolfram series"` (Jimmie ran it): the screen saver showed the Wolfram series. `saver remove` with Settings open refuses clearly; after closing it: removed, `SCRNSAVE.EXE` empty again |
| 2.D 12 | pass (note) | A hard kill leaves the user's own wallpaper, and `host start` brings it back live. With `host still on`, a crash still leaves the own picture (no still); a clean `host stop` leaves the still, and `still off` restores the own picture |
| 5.4 | inconclusive | Win+Ctrl+Shift+B: the second try beeped (no flash). Host and app kept running on the UHD with no gap or note, so no device loss was seen and the recovery path wasn't exercised |

Details: `notes.md`. Most raw logs were lost to a mistake of mine; see notes.md, "Lost logs".

Phase 2 runs on empty settings and an empty library (Phase 1's are in `jetcarp-rc-042b\phase1\`). Jobs 1–3 are
2.1, 2.3 and 2.4's searches.

Jobs 4–10 come from A-2 (job 10 is the paused `running-export` search); job 11 is 2.D 7's busy-processor hunt.
Still open from 2.10: importing the Framework's pack (`framework/F10-pack.zip`, committed) and the Mac's, which isn't
committed yet.

2.APP 4's second monitor is 2.MM, sitting A-8. 2.12 (A12, a copy of the everyday library) isn't in any sitting yet.

**Next:** Phase 2, sitting A-6 (Parts 4 and 5: MCP and robustness; 5.4 was done in A-5). Mostly the session,
with Jimmie answering the checks.
