# v0.4.2-rc.4 on the Acer

| Step | Result | Notes |
|---|---|---|
| Upgrade from rc.3 | pass | Zip, installer, wheel match `SHA256SUMS`; rc.4's 70 files over rc.3's in `~/jetcarp-rc-042c/bin`; `jetcarp 0.4.2-rc.4`; rc.3's library and jobs open; `host start` refused (no answer in rc.3's settings) |
| R4 #96 | CLI/MCP pass; app with Jimmie | Every start/show command refused with the warning (exit 1), MCP too; `host serve --saver` refused on the command line, no box; desktop unchanged; `photosensitivity.json` (answer, date, version, via); then the headless host and MCP work |
| R4 #112 | CLI/MCP pass; pane, A-8 to come | No `tune` in help or MCP; `host tune` refused; rc.1's saved 16 px ignored, each scene at its own 3 px. Small finding: `host tune --help` still prints Fit's help |
| R4 #87 | pass | Minimised 60 s: 30 polls, 30.0 gens/s, slowest 0.72 s, 4% of a core |
| R4 #116 | pass | "7.54 of 30 generations a second"; `measured_speed` 7.54 |
| R4 #84, #85 | pass | GPU off: "not used, and not tested"; `paths` and `--json` list the runtime folder |
| R4 #117 | pass | Released installer: one-line refusals, exit 1, no error block, no temp folder. Small finding: `-Uninstall` after `-NoModifyPath` says "took it off your PATH" |
| R4 #122 | pass | start/stop/start ten rounds, every start worked; host.rs serial ×10 straight after the RTX suite: 10 of 10 (15 passed, 3 ignored each, 41–45 s) |
| R4 #104 | **pass in Windows Terminal; FAIL in conhost** | Lines fitted to 59 columns; in conhost (VT off) `ESC[2K` shows as `←[2K` and every redraw leaves a row behind |
| R4 (private) part 4.2 | pass | |
| 1.1 parity | pass | Release build: 371/371 CPU and GPU on RTX and UHD × Vulkan and DX12; 6.7–18.8 min. On RTX DX12 one scene (133) found no RTX and ran on the UHD, its hash matching (rc.3: the same, scene 115) |
| 1.2 parity | pass | 40/40 at 5,000 gens on all four; 2.2–3.6 min |
| 1.3 suite on the tag | pass | `v0.4.2-rc.4` (cf5cbdf): RTX 1043 passed, 0 failed, 41 ignored, 21 min; UHD the same, 13 min; no message boxes |
| R4 #96 app | pass | Fresh folder: the warning before setup; "may have a seizure disorder" leads to Quit first, Continue at my own risk second; Quit quits (exit 0, no answer saved); Continue saves `at_risk` via app; the blue answer saves `no_disorder` via app, then setup |
| R4 #96 desktop | pass | Default folders: `wallpaper on`, `login on`, `saver install` refused before the answer; after it, the live wallpaper (own picture back after), the HKCU Run value (gone after `login off`), the screen saver (removed after) |
| R4 #120 | pass | Windows started `JETCARP.scr /s` itself (60 s idle) with the answer set aside: a JETCARP box with the whole warning, on the Screen-saver desktop; Preview the same (Jimmie) |
| R4 #112 pane | pass | Desktop background pane: no Fit button, cards or limits (Jimmie) |
| R4 #114 | pass | Copy on `jetcarp mcp --app` = the clipboard; a rule copied in Notepad pasted into the Rule box (`B36/S23` applied); footer says private link |
| R4 #88 | pass | Jump 4096 from generation 0: 4096 |
| R4 #90 | pass | Save straight after typing: the scene file holds the new rule (verify passes); typing then switching windows applied `B368/S245` |
| R4 #100–102 | pass | rc.4's book (mdBook 0.5.4, localhost): three commands copied with the copy buttons ran as pasted, output as the book's (hunt counts exact); `claude mcp add --scope user` connected in three other folders, then removed |
| 1.5 soak | pass | 8 h, 04:24–12:24, "Classics, hourly" (Jimmie's choice), wallpaper on, UHD: alive 97 of 97 (one pid), no stalls, all 7 classics at full speed (30/30, the ants 240/240), private bytes following the scene (426–480 MB, no climb), handles ~455; 9 pictures right; 8 pushes; Jimmie: "still looks right"; `host stop` gave Jimmie's picture back. The ant bounces at its dead edge and winds itself back, so it never restarts (checked after) |
| A-7, A-8 | with Jimmie | A-8 needs the AOC plugged in |

Details: `notes.md`.
