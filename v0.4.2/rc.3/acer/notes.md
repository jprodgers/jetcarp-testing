# v0.4.2-rc.3 Phase 1 on the Acer (2026-11-15/16)

- **Scripts:** `phase1.ps1` ran 19:13–01:08 EST (0, 1.6, 1.1, 1.2, 1.3 with #52's 60 runs, 1.4). `phase1b.ps1`
  ran afterwards: 30 more UHD recovery runs with `--test-threads=1`, to name the test that hangs. Log times are
  local (UTC−5).
- **Machine:** on mains, AC power plan never sleeps; 12 threads; RTX 3050 6GB Laptop (546.18) and Intel UHD
  (31.0.101.4146).
- **Test folder:** `C:\Users\jimmi\jetcarp-rc-042c`, with `JETCARP_CONFIG_DIR`, `JETCARP_DATA_DIR`,
  `JETCARP_OUT` **and `JETCARP_RUNTIME_DIR`** pointed there. The plan allows the default folders on the laptops;
  a scratch folder kept job numbers predictable and this library apart from Phase 2.
- **Everyday copy:** Scoop's 0.4.1 untouched (`where.exe jetcarp` is still its shim). The desktop state
  (wallpaper, screen saver, Run values) was the same at the start, after 1.3 and at the end.
  - `%LOCALAPPDATA%\jetcarp\host.lock` was there before and after: a stale file from rc.2's test hosts (A-5's
    finding). No host ran; with `JETCARP_RUNTIME_DIR` set, nothing here wrote to it.
- **Not committed:** the four `jobs runs` CSVs (128 MB stage 1, 2.4 MB stage 2, on each side) and the 42.7 MB
  pack. Their counts and the row comparison are in `phase1.log`; the files stay in the test folder.

## 0 Unpack: pass

- The zip's sha256 `002e42d2…74ec9e39` matches `SHA256SUMS` and the start note; `--version` says
  `jetcarp 0.4.2-rc.3`.
- doctor: 12.4 s the first time (self-tests ran, `gpu-checks.json` written), 0.8 s the second ("kept from
  before": display UHD Vulkan 495 ms, compute RTX Vulkan 323 ms).

## 1.6 Hunt determinism: pass

Hunt job 1: 1,783 distinct, 760,892 objects (ships 51,012, osc 236,468, still 473,412) in 17 s, the same as
every machine on rc.2 and rc.3. `1.6-status.json`.

## 1.1 Parity on every adapter: pass ×4

371/371 on the CPU and the GPU every time, all 300 generations on the GPU in 334, no MISMATCH line.

| Adapter | Time | rc.2 |
|---|---|---|
| RTX Vulkan | 7.6 min | 7.4 |
| RTX DX12 | 17.6 min | 17.5 |
| UHD Vulkan | 6.8 min | 6.8 |
| UHD DX12 | 18.7 min | 18.7 |

**Small finding (new since rc.2): with `JETCARP_GPU=RTX` and `WGPU_BACKEND=dx12`, one process of 335 didn't find
the RTX and ran on the UHD.**
- Scene 115 (`rule:B25678/S5678`): `gpu_backend` = "gpu (Intel(R) UHD Graphics (31.0.101.4146), Dx12; no RTX
  adapter was found, so the best one)". Its hash matched.
- The other 334 rows of that run name the RTX on DX12. rc.2 had none like it in 335.
- So a DX12 enumeration can miss the RTX now and then (Optimus may be powering the dGPU up). JETCARP says so in
  the backend note, but carries on silently on the wrong adapter. The CSV is `1.1-rtx-dx12.csv`.

## 1.2 Long parity: pass ×4

40/40 at 5,000 generations, all on the GPU. RTX Vulkan 2.3 min, RTX DX12 3.3, UHD Vulkan 2.3, UHD DX12 3.9.

## 1.3 The test suite: pass ×2

Tag 400d41d, `cargo test --release --workspace --no-fail-fast` in a scratch environment.
- **RTX:** 1,018 passed, 0 failed, 33 ignored, 135 test binaries; exit 0 in 24 min (with the build).
- **UHD:** 1,018 passed, 0 failed, 33 ignored; exit 0 in 13 min.
- The 33 ignored are the same names as rc.2's (listed in `phase1.log`).

## 1.3 #52, the GPU recovery test: RTX pass, UHD fail (1 hang in 30)

`cargo test --release -p jetcarp-gpu --test recovery`, built first with `--no-run` (1.3 min) so no run
included a build. Each run had 2 minutes. Outputs: `1.3-52/`, table `1.3-52-runs.csv`.
- **RTX: 30 of 30 ok**, no crash; median 10.7 s.
- **UHD: 29 of 30 ok, 1 hung** (run 4, 21:00:53, killed at 120 s); median 9.1 s.
  - The hung run printed "running 2 tests" and nothing more: the same signature as rc.2's UHD hang.
  - So the hardening's 60 s give-up on GPU waits didn't end it within 2 minutes.
- No 0xC0000005 crash in 60 runs (rc.2: 1 in 9 on the RTX).
- **Follow-up (`phase1b.ps1`):** see the section at the end.

## 1.4 A long search with a crash in the middle (240 min): every check passes

**Start.** `search explore --minutes 240 --label long --detach`: explore job 2 at 21:06:55. `jetcarpw.exe`
started `jetcarp.exe jobs resume 2 … --quiet --minutes 240`, on the RTX (Vulkan).

**The kill.** At 60 min (22:07:00), `Stop-Process -Force` on that `jetcarp.exe`.

**#49: pass.** `jobs status --json` gave `stale: true` at +1.1 s, and at +3, 5, 10, 20 and 30 s.
- The JSON keeps `"status": "running"` with `"stale": true` and `resumable: true`. The text form says
  "status stale" and "stale: marked running, but no process is running it (its process crashed, was killed,
  or stopped answering)".
- `jobs list` at +30 s: `stale` (text), `stale: true` (JSON). `jobs wait 2 --timeout 180` exited 6 at once
  (rc.2: after 45 s).
- (The script's summary says "killed: False": a `.Count` slip on a single CIM object. The kill did happen:
  "killing 11168" is in the log, and the job read stale 1.1 s later.)

**#50: pass.** `jobs resume 2 --detach` exited 0 in 3.2 s. `jobs wait 2 --timeout 2` straight after exited
**5**: "explore search 2 is still running after 2 s".

**#51: pass.** The resume said: "explore search 2 keeps the budget it was started with: 2 h 59 min left of its
4 h 0 min of running (give this run a budget of its own to change that)".
- It ended by itself 179.9 min later (01:07:32), at **239.0 min** of search in all.
- `jobs wait` exited 3, "explore search 2 is paused". So a search that has used its budget ends `paused`.

**Runs.** 574,607: 564,350 screened plus 10,257 confirmation runs. 40,020 elites in 18,608 niches, 1,953
confirmed; 344 of 1,359 tilings.
- Rate: 243 probes, median **39/s** (rc.2: 36/s).
- 0/s three times. Two are opening lines (#22): the first probe, and 2 s after the resume.
- **One is mid-run:** at 7.4 min the count sat at 14,335 for about a minute (20/s at 6.5 min, 0/s at 7.4,
  20/s at 8.4). Confirmed elites jumped from 106 to 155 in that minute, so screening seems to have waited on
  confirmation. A small #22-style note; rc.2's Acer had none mid-run.

**Memory** (`1.4-memory.csv` every 5 min; `1.4-progress.txt` every minute). Windows has no #53 fix (it's
`malloc_trim`, Linux only), so this is for comparison.

| | status `rss_gb` | working set | private bytes |
|---|---|---|---|
| 1 h (at the kill) | 1.14 GB | 1,042 MB at 50 min | 1,934 MB at 50 min |
| 2 h | 0.94 GB | 908 MB | 1,780 MB |
| end (236 min) | 1.25 GB (text: 1.29 GB) | 1,451 MB | 2,950 MB |
| peak | | 1,984 MB (215 min) | 3,450 MB (215 min) |

- Private bytes, mean per hour: 1.85, 1.86, 2.36, 2.50 GB. That's slow growth over the last two hours, not a
  runaway. `rss_gb` tracks the working set.
- **No #81-style peak after the resume:** private bytes were 369 MB a minute after it and climbed back over
  the next hour. The top reading was late, at 215 min.
- rc.2's Acer ran only 2 h: 0.81 GB at 1 h, 1.19 GB at 2 h, peak working set 1,557 MB.

**#35, the pack with no `jobs seal`: pass.**
- Export: exit 0 in 6.9 s, "sealed its newest 574,607 runs first, so the pack carries every run"; 42.7 MB.
- `pack check`: 0.
- Import into a fresh library: 0 (4.9 s).
- The imported job has 564,350 stage-1 and 10,257 stage-2 rows, the same as the source. The stage-1 rows
  (rule, tiling, rng, score) are identical after sorting.

**#54: pass.** Confirmed elites 1,953 in the search and 1,953 in the import.

## Script slips (results unaffected)

- PowerShell 5.1 read the BOM-less script as ANSI, so "…" became "â€¦" in the logs. In one log line this also
  swallowed `$NOTE_HEAD` into a longer variable name. The hash check itself compared plain ASCII and passed.
  Next time: write `.ps1` files with a BOM, or keep them ASCII.
- "killed: False" in the #49 line: see above.

## #52 follow-up: 30 UHD runs with `--test-threads=1`

`phase1b.ps1`, 01:10–01:15 EST: `cargo test --release -p jetcarp-gpu --test recovery -- --test-threads=1` with
`JETCARP_GPU=UHD`, same build and scratch folders. With one thread, libtest names each test before running it, so
a hang would show which test. On a hang, the script would also have sampled the process's CPU time to tell
spinning from blocked.

- **30 of 30 ok**, 8.7–12.3 s each. No hang to name. Outputs: `1.3-52b/`, `1.3-52b-runs.csv`, `phase1b.log`.
- So far the UHD hang has come only with **both tests in flight at once**:
  - rc.3: 1 hang in 30 parallel runs, 0 in 30 serial;
  - rc.2: 1 hang in 4 parallel runs; the RTX's 3 serial runs passed.
- That's suggestive, not proof: at 1 in 30, a clean set of 30 comes about a third of the time anyway. It points
  at two GPU devices or steppers on the same adapter at once in one process.

# Phase 2, sitting A-6: Parts 4 and 5, MCP in depth and robustness (2026-11-16, 11:21–11:48 EST)

**Set-up.** The Mac's M-6 scripts (the Framework's rc.2 F9 ones), ported to Windows in `A6/`: `mcpc.py` with
Windows paths, and every MCP server started in `$W\cwd`, so a relative path that escaped would land there, not in
the repository. Every folder is under `C:\Users\jimmi\jetcarp-rc-042c\a6` (`$W`): `JETCARP_CONFIG_DIR`, `_DATA_DIR`,
`_OUT`, `_LIBRARY`, `_RUNTIME_DIR`. No `JETCARP_GPU`.
- What changed from the Mac's scripts:
  - A publisher key made first (`0-pack-key.txt`), so the pack tools get past "no key" and are exercised. On the
    Mac, `pack publish` stopped there.
  - The odd files are made before anything reads them (`t5_prep.py`).
  - A read-only folder gets an icacls deny rule (Windows ignores chmod 555). Peak memory comes from
    `K32GetProcessMemoryInfo`.
  - `t5_cli.sh` and `r_cli.sh` are rewritten in Python (`t5_cli.py`, `r_cli.py`).
  - New: an "other-signer" pack (its signature file replaced by a valid SSH signature from another key).
  - New: 5.3's largest world on both GPUs, and the 64-million-cell host world.
- The unattended part is `run_a6.py` (`run_a6.log`, 6 min). The parts with Jimmie are `t41b_app_host.py`
  (host, big, app, hidden, standalone) and `t52_two_programs.py`. `shot.ps1` takes PrintWindow pictures of one
  JETCARP window only.

### 4.1 Every tool once: pass
- `4.1-every-tool.txt`: 53 calls over every tool but three. 52 succeed.
  - The one error is the script's: `job_stop {"job": null}`, from failing to read a JSON reply's job id, the same
    as on the Mac and the Framework.
  - With the key made, the whole pack chain works: publish, info, check ("signed by its publisher"), export,
    site, and import.
  - The explore picked the RTX by itself (Vulkan, 69 runs/s). `resources/list`: 116.
- **`host_control`** (`4.1b-host.txt`), on a test host from `$W`, its screen a window (the desktop untouched).
  Every action took effect:
  - status;
  - next: *A classic a day* item 5 → 6;
  - pause: `paused` true, the generation frozen at 22; then resume;
  - rotation *Until it settles*: item 1 of 3;
  - scene: Life 426 × 240 at 3 px;
  - previous: wrapped round to 3 of 3;
  - reload;
  - the refusals: "`rotation` needs `name`" and "unknown action "bogus"";
  - quit, which stopped the host (in the big phase below).
- **`app_display`, `use_app`** (`4.1b-app.txt`), with the app open from `$W` and AI control on:
  - before attaching, `app_display` is refused clearly ("only available in the JETCARP app: start the app with AI
    control on …");
  - `use_app` attach=true worked. A 128 × 96 Life world was made in the app, stepped 50, and played at speed 30:
    generation 50 → 179 in 4 s. Jimmie: "Yes, it ran". Then it paused, and a picture was saved;
  - attach=false went back to the private world ("a private world inside this MCP server").

### (private) part 4.2: pass (its files: `A6/4.2*`, summary in `A6/4.2-summary.txt`)

### 4.3 Bad input: pass; R #68 pass
`4.3-bad-input.txt`, `4.3b-followups.txt`: 124 cases and 8 protocol oddities. No crash, and every refusal can be
acted on. The 10 accepted cases are the same as on the Mac: a wrapped coordinate, clamped limits, a resume. **R #68:**
"search_start: `threads` must be at least 0 (got -1)", "help: `topic` must be text (got 5)".

### 4.4 Long jobs: pass; R #64 pass
- `4.4-long-job.txt`: a detached hunt (job 6) and an explore (job 7) started through MCP. The server closed at
  11:23:49.
  - `jetcarp jobs status`, another process, followed both still running: hunt 6 went from 10,498 to 31,487 soups
    in 21 s.
  - Each ran in its own `jetcarpw.exe` → `jetcarp.exe jobs resume N` pair.
  - Hunt 6 was stopped from a new MCP session, and explore 7 from the command line (`jobs wait` exit 3). No
    process was left.
- **R #64** (`4.4b-in-server-job.txt`): the MCP server's own hunt (job 8) was left **paused** (`stale: false`)
  when the server exited.

### 4.1b The app with its window hidden: **finding: on Windows too, rc.3's app stops while minimised (#87)**
`4.1b-hidden.txt`, `4.1b-hidden-poll.json`: one `jetcarp mcp --app` link polled `world_status` every 2 s for 180 s.
A 512 × 512 Life world was playing at speed 30. Each poll logs whether the app's window is minimised (IsIconic) and
whether it is in front.

| Phase | Polls | Generations a second | Answer | App CPU (% of a core) |
|---|---|---|---|---|
| in view (4–24 s) | 11 | 30.5 | 0.01–0.32 s | 25 (20–33) |
| **minimised (≈25–64 s)** | 1 | **0: 721 → 749 over ≈40 s** | **no answer in 30 s; the next answered 8.6 s later, once restored** | 1 |
| fully covered (69–179 s), Jimmie: "Fully covered" | 56 | 29.9 | 0.01–0.63 s | 41 (27–62) |

- So minimised, the app's world stops and AI control waits, as on the Mac. Covered, it carries on, but uses about
  1.6 times the CPU it does in view (the Mac, covered: about 99% of a core against 50%).
- #87's fix (5fcef69, bf6f64f) was checked only on the Mac, so it needs checking on Windows.
- **A standalone `jetcarp mcp` is fine with the app minimised** (`4.1b-standalone.txt`): a detached hunt (job 12)
  ran at 1,456–1,502 soups/s on the RTX for a minute after its server closed, and stopped when asked (exit 3).

### 5.1 Odd files: pass; R #66 pass
- **Scenes** (`5.1-scenes-cli.txt`, `5.1-mcp-odd.txt`): a truncated scene, an unknown rule, an unknown rule name, a
  future format, a format number too large and an empty file. Each fails clearly, on the command line (exit 1) and
  through MCP, with the same messages as the Mac. No crash.
- **Packs** (`5.1-packs-cli.txt`, `5.1-mcp-odd.txt`; copies of the Framework's rc.2 pack):
  - a truncated part, a truncated manifest, and a byte changed in the manifest or in a part: each refused by
    `check` and `import` ("is altered or truncated", "manifest: not JSON", "a signature on this version does not
    verify");
  - unsigned: "not signed by its publisher …; to import it anyway, allow unsigned packs", and imported with
    `--allow-unsigned`;
  - **other-signer (new):** "a signature on this version does not verify: ….sig is signed by SHA256:5E4v…",
    naming the other key.
- **R #66** (`r-cli.txt`): on a tampered pack, `pack info` says "signed, but a signature does not verify: the version
  was changed after it was signed, or the signature is damaged", and its import is refused (exit 1). The unsigned
  import's refusal names "--allow-unsigned on the command line, allow_unsigned through MCP".

### 5.2 Two programs on one library: pass
`5.2-two-programs.txt`, with the app open on the same library and its Hunts window in view
(`5.2-app-hunts-running.png`, `5.2-app-hunts-after.png`).
- A command-line explore (job 13) and an MCP hunt on the server's thread (job 14) ran at once, and `jetcarp jobs
  list` and MCP `job_status` each listed both running.
- MCP's `job_stop` paused the command line's explore, whose process exited 6.8 s later. `jetcarp jobs stop` paused
  the MCP hunt.
- The Hunts window showed #13 and #14 running, then both paused, with Resume/Continue buttons.

### 5.3 Limits: pass; R #63 pass; the 64-million-cell host world
- **One cell over** (`5.3-over-limit.txt`): 16,001 × 16,000 and 37 × 6,918,919 are refused ("grid is larger than
  256 million cells"). `{"cells": 256000001}` rounds to a size within the limit, as on the Mac.
- **The largest world, 16,000 × 16,000 (256,000,000 cells), 20 generations** (`5.3-max-world.txt`). doctor's
  limits: 4 GiB buffers on both, with 2 GiB storage bindings on the RTX and 1023 MiB on the UHD.

  | Simulator | Wall time | Peak working set | Peak private | Hash |
  |---|---|---|---|---|
  | RTX (Vulkan) | 6.3 s | 2.82 GB | 5.89 GB | `cc44c111d4811d0e` |
  | UHD (Vulkan) | 12.7 s | 5.14 GB | 5.87 GB | `cc44c111d4811d0e` |
  | CPU, 12 threads | 41.0 s | 1.92 GB | 1.92 GB | `cc44c111d4811d0e` |

  The same hash as the Framework's rc.2 GPU and CPU runs.
- **MCP's limits** (`5.3-mcp-limits.txt`): 2000 × 2000 is accepted, and 501 generations of it are refused (the
  2-billion cell-update cap). 4,000,001 cells and 1545 × 2589 are refused.
- **R #63** (`5.3b-mcp-over-limit.txt`): "4096 x 4096 on square is 16,777,216 cells, over the limit of 4,000,000
  cells (try 2000 x 2000)", and trihex "50,331,648 cells (3 in each unit cell) … (try 1154 x 1154)".
- **The host with 64,000,000 cells** (`4.1b-big.txt`, `4.1b-big-status.json`, `4.1b-host-window-64m.png`): a
  rotation file of one 8000 × 8000 Life scene with `refill` off, chosen with `host_control rotation`.
  - The host stepped it on the UHD (GPU), at 3.9 generations a second: 29 → 376 in 90 s.
  - `host status`: 1,697 MB at 5 s, then 1,453 MB throughout (404 MB at the start, 454 MB on the 102,240-cell Life
    before).
  - The window drew a 320 × 180-cell corner at 4 px.
  - Switched back to *A classic a day*, then `quit` stopped the host.
  - **Small finding:** `host status` says "30 fps, 30 generations a second" (`speed` 30) while the world advanced
    3.9 a second. It reports the speed asked for, not the speed reached, so a world that can't keep up reads as
    keeping up.
  - (My per-process memory reading there sampled `jetcarpw.exe`, the launcher, at 4 MB: a slip. `host status`'s
    figure stands.)

### 5.4 The graphics driver reset: done on rc.2 in A-5 (not repeated).

### 5.5 No room to write: pass; R #65 pass; R #67's read-only library pass
- **Run 1 was my slip:** icacls' `(W)` right includes SYNCHRONIZE, so the deny rule also blocked listing the folder,
  and the scripts stopped before removing it. JETCARP's refusals there were right, but `files_list`'s came from my
  rule. Rerun with `(WD,AD,WEA,WA)`. Run 1's files are kept as `*-run1*`.
- **R #65** (`5.5-readonly-mcp.txt`, `5.5-readonly-cli.txt`): with a write-denied output folder, every tool that
  writes names the path with Windows' "Access is denied. (os error 5)". That held through MCP:
  - `world_status`, `world_render` and its wallpaper;
  - `run_script` (twice);
  - a pile;
  - `media_render`, a `search_runs` csv;
  - `pack publish`, now past the key; `pack site`.

  On the command line: `script` (twice), `pile`, `wallpaper` (twice), `media render` and `run --png`.
  `files_list` reads the empty folder, and nothing was left in it.
- **The read-only library** (`library.sqlite` read-only, its folder write-denied):
  - `library list` and MCP `library_query` read its 101 patterns.
  - `search hunt`, `library_curate` and `search_start` refuse: "… is read-only (its file or its folder cannot be
    written), so nothing can be saved in it; use a copy you can write …".
  - `media_render` reports the denied media folder (cosmetic: "$W\ro-lib\media/7d", mixed slashes).
- **R #67** (`r-cli.txt`): "bad-rule.json: CA 1 'Lifeish': rule 'B3/S23/Q9 Frobnicate': …", naming the CA and the
  file. A read-only (attribute) copy of the library lists its patterns.

### R's command-line rows
- **#47:** pass ("An explore search checks it between steps, so it finishes the step").
- **#57** (`r-cli.txt`): pass, with the known straggler. A running search is refused both with nothing stored and
  with runs ("explore job 10 is running, and the pack would leave out every run it stores from now on"), and no
  `--to` folder is left. An empty hidden `.p57.store` is left beside it (rc.3's straggler, fixed for rc.4 in
  efe1a03).
  - The `.store` beside a *successful* export (e.g. Phase 1's `.P14-pack.store`) is by design: the packs guide
    says the export keeps it so the same export can run again.

### Put back
The test host stopped (`host_control quit`), the app closed, and no JETCARP process left. The test links and the
deny rules are removed. Everything else stays in `$W`.
