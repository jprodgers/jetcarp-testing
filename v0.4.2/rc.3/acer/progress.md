# v0.4.2-rc.3 on the Acer

| Step | Result | Notes |
|---|---|---|
| 0 unpack | pass | Hash `002e42d2…74ec9e39` matches `SHA256SUMS` and the start note; `jetcarp 0.4.2-rc.3`. doctor 12.4 s, then 0.8 s with the self-tests kept |
| 1.1 RTX Vulkan | pass | 371/371 CPU and GPU; all 300 generations on the GPU in 334; 7.6 min |
| 1.1 RTX DX12 | pass (finding) | Same; 17.6 min. One scene (115) found no RTX on DX12 and ran on the UHD ("no RTX adapter was found, so the best one"); its hash matched |
| 1.1 UHD Vulkan | pass | Same; 6.8 min |
| 1.1 UHD DX12 | pass | Same; 18.7 min |
| 1.2 ×4 | pass | 40/40 at 5,000 generations, all on the GPU; 2.3 / 3.3 / 2.3 / 3.9 min |
| 1.3 RTX | pass | 1,018 passed, 0 failed, 33 ignored; 24 min |
| 1.3 UHD | pass | 1,018 passed, 0 failed, 33 ignored; 13 min |
| 1.3 #52 RTX | pass | 30 of 30 ok, no crash, no hang; median 10.7 s |
| 1.3 #52 UHD | FAIL | 29 of 30 ok; run 4 hung after "running 2 tests" (killed at 120 s), as in rc.2. Follow-up: 30 of 30 ok with `--test-threads=1` (the hang has come only with both tests in flight) |
| 1.4 | pass | 574,607 runs in 240 min, median 39/s; 0/s once mid-run (7.4 min). #49 stale at +1.1 s; #50 exit 5; #51 ended by itself at 239.0 min; #35 every row in the 42.7 MB pack; #54 1,953 = 1,953. Memory: 1.14 GB at 1 h, 0.94 at 2 h, 1.25 at the end (private bytes up to 3.45 GB) |
| 1.5 | not run | Needs 8 idle hours; Jimmie starts it |
| 1.6 | pass | 1,783 distinct, 760,892 objects: the same everywhere |
| A-6 4.1 | pass | 53 calls, every tool but three (the one error is the script's). With a key made first, the whole pack chain works. `host_control` drove a test host (a window): next, pause, resume, rotation, scene, previous, reload, quit; clear refusals. `use_app` ran a world in the app (Jimmie saw it); `app_display` refused clearly before attaching |
| A-6 (private) part 4.2 | pass | Its files: `A6/4.2*` |
| A-6 4.3 | pass | 124 cases + 8 protocol oddities, no crash; the same 10 accepted as the Mac. R #68 pass |
| A-6 4.4 | pass | Detached MCP hunt and explore outlive the server; stopped from a new MCP session and the CLI. R #64 pass (left paused) |
| A-6 app hidden | **FAIL (finding)** | **Minimised, rc.3's app stops: no answer for 30 s, 721 → 749 generations over ≈40 s (#87, fixed on the branch but checked only on the Mac).** Fully covered it keeps 30 gens/s, at ≈1.6× the CPU of in view. A standalone `jetcarp mcp` hunt runs fine with the app minimised (≈1,480 soups/s) |
| A-6 5.1 | pass | Odd scenes and damaged packs refused clearly (CLI and MCP); a new other-signer pack names the other key. R #66 pass |
| A-6 5.2 | pass | CLI explore and MCP hunt on one library with the app's Hunts window open; each stopped from the other; the window followed |
| A-6 5.3 | pass | Over 256M refused. 16000×16000 × 20 gens: RTX 6.3 s, UHD 12.7 s, CPU 41 s, same hash. R #63 pass. **64M cells on the host:** UHD, 3.9 gens/s, `host status` 1.45 GB (small finding: it says "30 generations a second") |
| A-6 5.4 | done on rc.2 | Driver reset, A-5 |
| A-6 5.5 | pass | Write-denied output: every tool names the path ("Access is denied"). Read-only library: reads, refuses writes clearly. R #65, #67 pass (run 1's icacls slip: rerun) |
| A-6 R #47, #57 | pass | #57: refused, no folder; the empty `.p57.store` straggler (fixed for rc.4) |

Details: `notes.md`. Test folders: `C:\Users\jimmi\jetcarp-rc-042c` (Phase 1), `…\a6` (A-6), each with
`JETCARP_RUNTIME_DIR`.

**Next:** A-7 (Part 3 in a separate account), A-8 (two monitors) and the rest of R on rc.3; 1.5 when the Acer
has 8 idle hours.
