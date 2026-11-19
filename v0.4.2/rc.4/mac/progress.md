# v0.4.2-rc.4 on the Mac

| Step | Result | Notes |
|---|---|---|
| Downloads | pass | rc.4's and rc.3's macOS archives and installers match their `SHA256SUMS` |
| 0 rc.3 back in place | done | its installer; desktop on, start at login on; logout 1: launchd started rc.3's host |
| 0 The upgrade (#99) | pass | rc.4's installer; the app opened once re-registered the login item, and the new host waited (held, generation 0) until Jimmie answered the warning, then ran; logout 2: the host came back as rc.4, no code-signing kill |
| R4 #96 | pass | CLI and MCP refused before the answer, nothing started or registered; setup's file has answer, date, version, via; then all work. App: warning first; Quit then Continue; Quit quits. (`host start --saver` isn't an option: `host serve --saver`) |
| R4 #99 login off, host stopped | pass | `launchctl print` exit 113 at once, plist gone. Left: with the host running (logout 3), and `uninstall` |
| R4 #84 | pass | GPU off: "not used, and not tested", no self-test |
| R4 #85 | pass | `paths` and `--json` list the runtime folder |
| R4 #112 | pass (monitor change: Jimmie) | no tune in help or MCP; `host tune` refused; rc.3's own `host.json`: each scene at its own size (8 px, 170,648 cells), never the saved 12 to 32 px. Seen: a screen for a monitor not connected still runs (question 2) |
| R4 #122 | pass | 10 of 10 |
| R4 #80 | pass | the status's memory matched `phys_footprint` within 2% each time it changed, never the RSS; but it is refreshed only now and then (question 1) |
| R4 #104 | pass | 60 columns: every redraw 59 wide, one row; rc.3's build leaves rows |
| R4 #92 | as on the Framework | the book's source escapes all 11 placeholders; served over MCP with `&lt;` (#126) |
| (private) part 4.2 | pass | |
| R4 #87 covered | pass | 60 s covered: 32 of 32 answers, 30.0 gens/s, app CPU 4% (46% in view). Minimised: Jimmie (⌘M) |
| R4 #87 minimised | pass; FINDING #131 | 88 s minimised (Jimmie): 44 of 44 answers, 30.0 gens/s, CPU 3%. But after ⌘M and a restore the window never draws again (nothing wakes it); after the yellow button it does, and rc.3 does: #131 (⌘M, #98), milestone v0.4.2 |
| R4 #89 | pass (app_display); menu click: Jimmie | on: `NoDisplaySleepAssertion` "JETCARP is showing cellular automata"; off: gone |
| 1.1 Parity (Metal) | pass | 371/371 CPU and GPU; 334 all on the GPU; 75 s; release build |
| 1.2 Long-run parity (Metal) | pass | 40/40 at 5,000 gens, all on the GPU; 64 s |
| 1.3 Suite (Metal), on the tag | pass | cf5cbdf: 1,058 passed, 0 failed, 41 ignored, in 143 binaries; 11 min; no warnings (2 new ignores: screenshot tests) |
| R4 #112 pane | pass | no Fit button, cards or limits (`112-desktop-pane.jpg`) |
| R4 #91/#98 | pass | ⌘⇧H Quick Start, ⌃⌘F full screen, ⌘H Hide; ⌘M minimises (but #131) |
| R4 #89 menu | pass | View → Keep awake: the assertion for 10 s, then gone |
| R4 #114 | pass, with a finding | Copy: `jetcarp mcp --app` on the system clipboard; footer: private link. Paste: the rule is taken, but the box shows it only at the next key or save (question 4) |
| R4 #90 | pass | typed `B34/S34` saved at once: the scene reopens as B34/S34; on ⌘Tab: applied |
| R4 #88 | pass | Jump 4096: 4,340 → 8,436 |
| R4 #112 monitor change | pass | resolution changed and back: the canvas followed, no fit, `host.json` unchanged; ~2 s of the old picture each time (cosmetic) |
| R4 #100 | pass | three commands copied with the book's copy buttons (the tag's book, served locally): ran as pasted, output as the page |
| R4 #102 | pass | `claude mcp add --scope user`: ✔ Connected from three other folders; removed after |
| R4 #99 login off, host running | pass | the host left running; after logout 3 the job is gone (`launchctl print` 113), no host |
| R4 #99 uninstall | pass | `uninstall --yes` stopped the host first: the job gone at once |
| R4 #103 | pass | `uninstall` says what it does, names the installer's one command; the data step "done", no FAILED; the installer's `--uninstall` lists what it removed. Small: it says it kept the settings just deleted; `~/.cache/jetcarp/app-endpoint.json` left |
| 1.5 Soak, 8 h | pass | 5:54 AM–1:54 PM EST, rc.4's release build, "Classics, hourly": alive 97/97, one pid, never held or paused; all seven classics at full speed (30 of 30 on the GPU, the ants 240 of 240 on the CPU); footprint follows the scene, 261–314 MB, Life 265 → 269 MB first to last hour; nine hourly pictures right; all pushes through (`soak/`) |
| #95 on rc.4 | pass | `displaysleepnow`, display off 3 min 31 s with nothing waking it: held (`dark`) within 15 s, generation still, CPU 0.1%, footprint 182 → 54 MB; at the lock screen with the display on: still held; `host stop` while locked, exit 0 (the resume at sign-in: the pre-check's) |
