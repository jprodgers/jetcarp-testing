# v0.4.2-rc.5 on the Mac

| Step | Result | Notes |
|---|---|---|
| Downloads | pass | the macOS archive and the installer match `SHA256SUMS`; `jetcarp 0.4.2-rc.5`, sha256 ee21fcd6… |
| R5 #128 | pass | `host tune --help` and `host help tune`: only "Fit to this computer isn't in JETCARP 0.4.2: …" (exit 0); `host tune` refuses with it |
| R5 #124 | pass | with `JETCARP_*` set: the note names all five; "registered with launchd, which runs the host with the default folders, not this run's" (no pid); that host waited for the default folders' warning; control without the variables: no note, "which started the host (pid …)"; launchd's job gone each time (113). Seen: a login host with the wallpaper off says "GPU none … no GPU" (question 1) |
| R5 #134 | pass | the installer's `--uninstall` names only the folders still there: the settings folder when kept; only `~/Pictures/JETCARP` after `uninstall --settings --data`; nothing when none is left. Wording: "kept your settings, data and pictures in ~/Pictures/JETCARP" (question 2). rc.5 installed again after |
| (private) part 4.2 | pass | |
| 1.1 Parity (Metal) | pass | 371/371 CPU and GPU; 334 all on the GPU; 74 s; release build |
| 1.2 Long-run parity (Metal) | pass | 40/40 at 5,000 gens, all on the GPU; 64 s |
| 1.3 Suite (Metal), on the tag | pass | c0db1ab: 1,065 passed, 0 failed, 41 ignored, in 143 binaries; 10 min 47 s; no warnings (rc.4: 1,058; the same 41 ignored) |
| R5 #131 unit test | pass | `cmd_m_minimises_through_appkit_not_egui` ok, in the release suite and in a debug build |
| R5 #131 ⌘M, yellow button, paused pan | pass | ⌘M 26 s with the world running: drew again at once, the toolbar's "gen 5467" against `world_status`'s 5,462; the yellow button the same; ⌘M while paused, then a zoom and a pan: both drew, only the fps figure changing between them |
