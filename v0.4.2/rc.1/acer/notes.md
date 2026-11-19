# v0.4.2-rc.1 on the Acer: notes

System: `00-system.txt` (Windows 11 Home 26H2, build 26300.9974; i5-13420H, 12 threads; RTX 3050
6GB Laptop, driver 546.18 / 31.0.15.4618, + Intel UHD, driver 31.0.101.4146; the internal
1920x1080 panel only, no external monitor; on mains). Not run as administrator. Rust is installed
(cargo 1.99.1), so the optional GPU tests can run.

State before the wave: the everyday JETCARP is Scoop's **0.4.1** (`~\scoop\shims\jetcarp.exe`).
**No everyday host is running**: no `jetcarp` process, no JETCARP `Run` value, no `SCRNSAVE.EXE`
(this matters for D1/D5: there is no everyday host to stop and put back). The user PATH is
ExpandString with `~\scoop\shims` first, as v0.4.0 left it.

The test folder is `C:\Users\jimmi\jetcarp-rc-042` (`$T`), with `JETCARP_CONFIG_DIR`,
`JETCARP_DATA_DIR` and `JETCARP_OUT` pointed at `$T\config`, `$T\data` and `$T\out` for every
command.

## A0. Unpack and check: pass

Files: `A0-version-paths.txt`, `A0-results-doctor.txt`, `A0-results-doctor.json`.

1. **The hash is right:** the zip's SHA-256 is `f2d13c6edc83d35ba1002b7d8ce25f2db4af910589bf4346668ad26794fe842f`,
   the same as its line in `SHA256SUMS` (download 28.4 MB in about 1 s). The zip holds one folder,
   `jetcarp-0.4.2-rc.1-x86_64-pc-windows-msvc\`, with `jetcarp.exe` (82.4 MB), `jetcarpw.exe`,
   `packs\` and the licence files; moved up into `$T\bin`. **`--version`: `jetcarp 0.4.2-rc.1`.**
2. **`paths`:** settings `$T\config`, data `$T\data`, output `$T\out`, bundled `$T\bin\packs`;
   nothing else.
3. **doctor's GPU block** (first run, exit 0, 13.7 s):

       GPU: auto (automatic)
         setting: C:\Users\jimmi\jetcarp-rc-042\config\gpu.json (not saved)
         the app: auto, from automatic (its own choice: follow)
         the desktop background: auto, from automatic (its own choice: follow)
         display: Intel(R) UHD Graphics (Intel Corporation), Vulkan (integrated)
             why: the adapter driving the screen (automatic)
             limits: 59 storage buffers per stage, 1023 MiB storage bindings, 4 GiB buffers
             self-test: passed (1165 ms, kept from before): 53 world rules and 33 explore batches matched the CPU
             the GPU simulation uses it
         compute: NVIDIA GeForce RTX 3050 6GB Laptop GPU (NVIDIA), Vulkan (discrete)
             why: the fastest adapter (automatic)
             limits: 524288 storage buffers per stage, 2 GiB storage bindings, 4 GiB buffers
             self-test: passed (706 ms, kept from before): 53 world rules and 33 explore batches matched the CPU
             the GPU simulation uses it

   As expected on this Optimus laptop: **display is the Intel UHD** (driving the laptop panel) and
   **compute the RTX 3050**, both on Vulkan. **Both self-tests passed**: 53 world rules and 33
   explore batches matched the CPU. The adapter list also has both GPUs on DX12, the UHD on GL and
   WARP ("Windows' software renderer (WARP), which the GPU simulation never uses").
4. **`where.exe jetcarp`** is still `C:\Users\jimmi\scoop\shims\jetcarp.exe` (0.4.1).

Findings:
- **"kept from before" on a fresh folder, and the self-test runs again every time.** On this first
  run, with no `$T\config` or `$T\data` yet, both self-tests say "kept from before" (JSON:
  `"cached": true`), but nothing was written anywhere (not under `$T`, not in `%APPDATA%`,
  `%LOCALAPPDATA%` or `%TEMP%`; doctor didn't create `$T\config`), and the time is different on each
  run: 1165/706 ms, then 372/223 ms, then 355/600 ms (UHD/RTX). So the result is neither saved nor
  really "kept from before". The Framework's F1 doctor says the same on its fresh folder (99 ms,
  "kept from before", "not saved"), so it's not Windows-only; G1 check 3 looks at it again.
- doctor is slow here: 13.7 s, then 9.3 s (two self-tests and the adapter enumeration).
- The everyday folders (`%APPDATA%\jetcarp`, `%LOCALAPPDATA%\jetcarp`) were not touched: newest
  file from 2026-11-13.

## G1. Each GPU's self-test: pass

Files: `G1-rtx-vulkan.txt`, `G1-rtx-dx12.txt`, `G1-uhd.txt`, `G1-off.txt`, `G1-auto.txt` (the
plan's five runs), `G1-rtx-again1.txt`, `G1-rtx-again2.txt` (check 3 without a settings folder),
`G1-rtx-cache1.txt`, `G1-rtx-cache2.txt` (check 3 with one), `G1-gpu-checks.json`.

1. **Every self-test passed** ("53 world rules and 33 explore batches matched the CPU"):

   | Way | Adapter doctor used (display and compute) | Self-test | doctor |
   |---|---|---|---|
   | `JETCARP_GPU=RTX` | RTX 3050, Vulkan (discrete): "named RTX, as asked" | passed, 607 ms | 8.7 s |
   | `RTX` + `WGPU_BACKEND=dx12` | RTX 3050, Dx12, driver 31.0.15.4618 (limits: 262144 storage buffers, 2 GiB buffers) | passed, **2733 ms** | 6.2 s |
   | `JETCARP_GPU=UHD` | Intel UHD, Vulkan (integrated): "named UHD, as asked" | passed, 391 ms | 8.4 s |

   `gpu-checks.json` (once it could be written, below) shows doctor tests **every adapter it
   lists, not only the chosen ones**, and all five passed: UHD Vulkan 344 ms, UHD **GL** 624 ms,
   UHD Dx12 2948 ms, RTX Vulkan 215 ms, RTX Dx12 2776 ms. DX12 is the slow one on both GPUs (about
   2.8-2.9 s against 0.2-0.6 s on Vulkan), probably its shader compilation. No failure anywhere.
2. **`off`:** the header says `GPU: off (JETCARP_GPU=off)`, and "the app: off" and "the desktop
   background: off", from `JETCARP_GPU=off`. **But each adapter's block still ends "the GPU
   simulation uses it"**, still gives a "why" ("the adapter driving the screen (JETCARP_GPU=off)",
   "the fastest adapter (JETCARP_GPU=off)") and still runs its self-test (382/587 ms). The header
   says off and the adapter lines say it's used: confusing. With off, those lines could say "not
   used: the GPU simulation is off".
   **`auto`** picks as in A0: display Intel UHD (Vulkan, "the adapter driving the screen"), compute
   RTX 3050 (Vulkan, "the fastest adapter").
3. **The cache works, but only once the settings folder exists, and its label is wrong before
   that.**
   - With no `$T\config` (as after A0), the RTX doctor run twice more gave 603 ms, then 216 ms,
     both "kept from before", and nothing was saved. The binary's own help says the result "is
     written only where the settings folder already exists". So **on a fresh install every program
     start runs the self-test again** (doctor: 8-14 s each time) **and calls it "kept from
     before"**: in that case it was just run, in this process.
   - After `New-Item -ItemType Directory $T\config` (an empty folder, inside the test folder only),
     the first RTX doctor wrote `config\gpu-checks.json` (8.0 s, 215 ms) and **the second took
     1.3 s and showed the same 215 ms, "kept from before"**: a real cache hit. The keys are
     adapter | backend | PCI id | driver | version | build (e.g. `NVIDIA GeForce RTX 3050 6GB
     Laptop GPU | Vulkan | 10de:25ac | NVIDIA 546.18 | 0.4.2-rc.1 | fc65fcb2c010b79c.1`). The DX12
     keys have an empty field and a double space (`31.0.15.4618  |`), cosmetic.

Findings:
- **The self-test result isn't saved until something creates the settings folder**, and until then
  every start re-tests and says "kept from before" (`"cached": true`). Suggest: create the settings
  folder when saving `gpu-checks.json`, and say "just now" (`cached: false`) for a test run in this
  process.
- **With `JETCARP_GPU=off`, doctor still says "the GPU simulation uses it"** for both adapters and
  still runs their self-tests.
- **doctor tests all adapters** (5 here), which makes an uncached doctor take 8-14 s; only the
  chosen ones affect the result.
- doctor's Environment block lists `JETCARP_*` but not `WGPU_BACKEND`, which changed what it showed
  (only DX12 adapters were listed).
- From now on `$T\config` exists, so the later steps use the cached self-test.

## G2. The parity suite: pass

Files: `G2-rtx-vulkan.csv`, `G2-rtx-dx12.csv`, `G2-uhd.csv` and their `.log`s. The runner is the
plan's `parity\parity.ps1`, copied to `$T\parity` and run unchanged with the plan's three
commands, one after another (from `g2.ps1` in this session's scratchpad, logging each pass).
**`parity.ps1` worked on Windows PowerShell 5.1 as written**: it parsed `run --json` correctly, so
it needed no fix. (One weakness: it drops stderr with `2>$null`, so an ERROR row would have no
message. None happened.)

1. **No mismatch anywhere.** Each pass: "364 scenes: CPU matches 364, GPU matches 364; all 300
   generations on the GPU in 327". No ERROR rows. Each row's `gpu_backend` names the adapter asked
   for (one exception, below).

   | Pass | Adapter in `gpu_backend` | CPU | GPU | All 300 gens on GPU | Partly | CPU only | Time |
   |---|---|---|---|---|---|---|---|
   | `JETCARP_GPU=RTX` | RTX 3050, Vulkan | 364/364 | 364/364 | 327 | 1 | 36 | 7.3 min |
   | `RTX` + `WGPU_BACKEND=dx12` | RTX 3050 (31.0.15.4618), Dx12; **1 scene on the UHD, Dx12** | 364/364 | 364/364 | 327 | 1 | 36 | 17.2 min |
   | `JETCARP_GPU=UHD` | Intel UHD, Vulkan | 364/364 | 364/364 | 327 | 1 | 36 | 6.6 min |

2. **327 scenes ran all 300 generations on the GPU** on each adapter; **scene by scene the split
   is identical to the Framework's** `gpu_gens` (0 differences in all three passes). The partial
   one is n=2 `script-five` (151 on the GPU, "149 of 300 generations on the cpu: Rule 30 (W30) runs
   only on the CPU"). The 36 CPU-only scenes are Wolfram rules, hex/hex3 rules, turmites and ants,
   von Neumann 29-state, layered rules, the table parity rule and Lenia, each with a reason ("…
   runs only on the CPU").
3. **Medians** for the 327 all-GPU scenes (each includes starting `jetcarp.exe`):

   | Pass | median `cpu_s` | median `gpu_s` | GPU faster than CPU | sum `cpu_s` / `gpu_s` |
   |---|---|---|---|---|
   | RTX Vulkan | 0.203 | 0.986 | 11 of 327 | 110 s / 328 s |
   | RTX DX12 | 0.196 | **2.438** | 2 of 327 | 104 s / 927 s |
   | UHD Vulkan | 0.196 | 0.623 | 9 of 327 | 104 s / 290 s |
   | (Framework, expected.csv) | 0.080 | 0.059 | | |

   - **Opening the GPU device dominates `gpu_s` here.** Even the 36 CPU-only scenes take 0.58 s
     (RTX Vulkan), 2.40 s (DX12) and 0.53 s (UHD) with `--gpu`, against 0.08-0.09 s with `--cpu`.
     So it costs about 0.5 s (UHD), 0.9 s (RTX, which Optimus has to wake) or 2.3 s (DX12) per
     program start; the Framework's Radeon starts in well under 0.1 s. The GPU is faster than the
     CPU only for the heavy scenes: Larger than Life with big radii (n=203 `R10,C2,S122-211,B123-170`:
     CPU 7.68 s, RTX 0.94 s; n=201-202, 204) and the sandpiles (n=10-12, 18, 93).
   - For the thresholds: on this machine a one-off 300-generation run of a typical scene is
     cheaper on the CPU, because of device start-up, not the stepping. Long-running uses (app,
     host, explore) pay it once.
4. **Optional GPU tests (Rust installed): they fail on the Intel UHD.** The branch was cloned
   with depth 1 and updated to its head at the time, **`472bec5`** (after rc.1's `0ca10af`:
   `c2ab5e3` CI test fixes, `4a495c9` #17, `472bec5` #16). `cargo test --release -p jetcarp-gpu
   --no-run` built in 1.5 min; then the plan's two runs (files `G2-tests-build.txt`,
   `G2-tests-rtx.txt`, `G2-tests-uhd.txt`, `G2-tests-uhd-nofailfast.txt`,
   `G2-tests-sandpile-{rtx,uhd}-nocapture.txt`):
   - **`JETCARP_GPU=RTX`: all pass**: 55 passed, 1 ignored ("heavy: two worlds of 17 million
     cells"), 1.7 min. `--nocapture` confirms "GPU tests on NVIDIA GeForce RTX 3050 6GB Laptop GPU
     (NVIDIA), Vulkan".
   - **`JETCARP_GPU=UHD`: 2 fail**, 53 passed, 1 ignored ("GPU tests on Intel(R) UHD Graphics
     (Intel Corporation), Vulkan"). Both in `tests\families.rs`, the same on every run
     (three runs):

         ---- sandpile_edges_drops_and_patches stdout ----
         thread 'sandpile_edges_drops_and_patches' panicked at crates\jetcarp-gpu\tests\families.rs:54:5:
         assertion `left == right` failed: sandpile drop 1 on square Dead Edge: hash at generation 1
           left: "60047217d97ba607"
          right: "024298488f7067d5"

         ---- sandpile_repeats_and_scripts stdout ----
         thread 'sandpile_repeats_and_scripts' panicked at crates\jetcarp-gpu\tests\families.rs:54:5:
         assertion `left == right` failed: sandpile script: hash at generation 1
           left: "3e93fe95da80cba1"
          right: "f9fb28e4fdfb1611"

     (`left` is the CPU, `right` the GPU.) With `--no-fail-fast` the other test binaries (`pile`,
     `recovery`, `select`, `worth`) pass on the UHD too. In `sandpile_edges_drops_and_patches`
     the loop's first case, drop 0 on square Dead Edge, passed; it fails at drop 1. The script
     test's failing scene is the hex pile that drips 2 grains a generation. `sandpile_scenes` (the
     five built-in sandpile scenes, no drops) passes.
   - **Reproduced with the rc.1 binary** (`G2-drops.csv`, scenes in `G2-drops-scenes\`, made by
     a script from scene 93's format, adding `"drop_per_gen"`): CPU against `--gpu`, 1 and 300
     generations, on four adapter/backend pairs:

     | Scene (dead edges) | RTX Vulkan | RTX DX12 | UHD Vulkan | UHD DX12 |
     |---|---|---|---|---|
     | square 40x30, edge, pile 20000, **drop 0** | same | same | same | same |
     | the same, **drop 1** | same | same | **differs** | **differs** |
     | the same, drop 7 | same | same | **differs** | **differs** |
     | the same, touch, drop 1 | same | same | **differs** | **differs** |
     | hex 30x24, edge, pile 500, drop 2 | same | same | **differs** | **differs** |
     | square 140x140, 20 steps/gen, pile 30000, drop 1 | same | same | **differs** | **differs** |

     The rc.1 binary's UHD hash for "drop 1 on square 40x30" at generation 1 is
     `024298488f7067d5`, **exactly the test's `right`**, and the CPU's is `60047217d97ba607`, the
     test's `left`. **On UHD Vulkan the population at generation 1 is 4,294,969,752 (about 2^32)
     instead of 20,001**, and drop 1 and drop 7 give the same wrong hash: the centre cell looks
     saturated to `0xFFFFFFFF` instead of getting `h + drop` (the WGSL `grains()`'s
     `select(h + p.k1, 0xffffffffu, h > 0xffffffffu - p.k1)` in `sim.wgsl`). After 300 generations
     it holds 247,431 grains instead of 11,140. **On UHD DX12 the result is wrong the other way:
     population 3** (or 4, 7) at generation 1, as if almost all grains were lost.
   - **What it means:** on Intel's UHD, a sandpile with a grain drop (`drop_per_gen` > 0) runs
     wrong on the GPU from the first generation, on both backends. **The UHD's self-test passes**
     (it has no sandpile drop), so JETCARP trusts the UHD for it, and **none of the 364 parity
     scenes has a drop**, so G2's parity didn't catch it. In auto mode the CLI's `run` uses the RTX
     here (the drop scene is right without `JETCARP_GPU`), but the UHD is this laptop's **display**
     adapter, which the desktop host uses (D2): a dripping pile in the wallpaper would be wrong.
     Worth adding a dropping sandpile to the self-test and to the parity set.

Findings:
- **Sandpile grain drops are wrong on the Intel UHD's GPU path** (Vulkan and DX12), from
  generation 1; the RTX is right. Two GPU tests fail on the UHD, and the rc.1 binary reproduces it
  exactly (above). The self-test and the parity set don't cover drops.
- **Once, with `JETCARP_GPU=RTX` and `WGPU_BACKEND=dx12`, a run used the Intel UHD instead of the
  RTX**: n=342 `tiling:ih41`, `gpu (Intel(R) UHD Graphics (31.0.101.4146), Dx12)`, at about 18:07;
  its neighbours (n=340-344) ran on the RTX. The hash still matched (`e2cd11dde8e8b9b0`). **Not
  reproduced**: 15 more runs of that scene with the same settings all used the RTX (2.3-4.1 s, no
  stderr). No System or Application event-log entries (display driver, nvlddmkm, dxgkrnl, errors)
  between 17:43 and 18:16. stderr of the original run was discarded by `parity.ps1`, so it's
  unknown whether JETCARP printed a note. Possibly the RTX was missing from the DX12 adapter list
  for that start (Optimus waking it), and the named choice fell back to the automatic one without
  saying so. If a named adapter isn't found, JETCARP should say so (or refuse) rather than quietly
  use another.
- DX12 is much slower to start than Vulkan (2.3 s against 0.9 s on the RTX), consistent with G1's
  self-test times. Vulkan is the default here, so it only matters with `WGPU_BACKEND=dx12`.

## G2b. The #20 fix on the Intel UHD (branch c74c357): pass

Asked for in NOTES.md (2026-11-15, main session). Files: `G2b-log.txt` (the whole step, timed),
`G2b-tests-uhd-vulkan.txt`, `G2b-tests-uhd-dx12.txt`, `G2b-build-tail.txt`,
`G2b-doctor-uhd-vulkan.txt`, `G2b-doctor-uhd-dx12.txt`, `G2b-drops-uhd-vulkan.csv`,
`G2b-drops-uhd-dx12.csv`, `G2b-all-uhd-vulkan.csv`, `G2b-drops-uhd-vulkan-rc1.csv`. The clone in
`$T\src` was fetched and checked out at **c74c357** (the branch head: "Tune test: a sweep may stop
early …", after 4d4faba "GPU: sandpile drops right on Intel's UHD …").

1. **`cargo test --release -p jetcarp-gpu --no-fail-fast` with `JETCARP_GPU=UHD`: all pass** (55
   passed, 1 ignored, 2.4 min), on "Intel(R) UHD Graphics (Intel Corporation), Vulkan". **With
   `WGPU_BACKEND=dx12` added: all pass** (3.1 min), on "Intel(R) UHD Graphics (31.0.101.4146), Dx12".
   That includes `sandpile_edges_drops_and_patches` and `sandpile_repeats_and_scripts`.
2. **`cargo build --release -p jetcarp`** (5.5 min; `--version` still says `jetcarp 0.4.2-rc.1`).
   Its **`doctor` with `JETCARP_GPU=UHD`: the self-test re-ran and passed: "passed (916 ms): 59 world
   rules and 33 explore batches matched the CPU"** (rc.1: 53 world rules), with no "kept from
   before" on that first run (#17 fixed too). With `WGPU_BACKEND=dx12` right after: "passed (4184
   ms, kept from before): 59 world rules …" (doctor had tested the DX12 adapter in the previous run
   and saved it, so here "kept from before" is true).
3. **Parity with that build** (the 371-scene set from `git pull`; a subset folder with scenes
   364-370 and their `expected.csv` rows):
   - **drops (364-370), UHD Vulkan: "7 scenes: CPU matches 7, GPU matches 7; all 300 generations on
     the GPU in 7"**;
   - **drops, UHD DX12: the same, 7 of 7**;
   - **all 371, UHD Vulkan: "371 scenes: CPU matches 371, GPU matches 371; all 300 generations on
     the GPU in 334"** (327 + the 7 drop scenes; 1 partly, 36 CPU-only, as before);
   - for contrast, **rc.1 on the drop scenes, UHD Vulkan: GPU matches 1 of 7** (only 364, drop 0);
     365, 366 and 370 (drop 1, drop 7, saturate) all give rc.1's wrong `1f920aa0dbcd1af4`.

**The #20 fix works on the UHD on both backends**, and nothing else changed on the UHD's parity.

## A1. GPU explore search: pass

Files: `A1-explore.txt` (the search's output, 18:30-18:40), `A1-status.txt`, `A1-runs.csv` (32,606
runs). Run as the plan says, no `--gpu`, no `JETCARP_GPU`.

1. **The GPU is the default:** the search printed `GPU: NVIDIA GeForce RTX 3050 6GB Laptop GPU
   (NVIDIA), Vulkan`, every progress line and the status name it (the compute adapter), and the
   status ends with **290 confirmed** (1,104 confirmation runs).

       explore 1: 32,606 runs (39/s), 6,733 elites in 3,428 niches, 290 confirmed, 21 of 1,359 tilings; NVIDIA GeForce RTX 3050 6GB Laptop GPU (NVIDIA), Vulkan
         status paused, 9 min 59 s run over every session, 1,104 confirmation runs, 33,718 candidates tried, 0.67 GB of memory
         threads: 6 for runs on the processor and 4 for the GPU's batches, of 12 cores (2 left free)
         family                     runs   mean   best  elites
         life_like                14,194   0.31   1.46   2,531
         generations              11,418   0.67   2.02   2,143
         jaca                      5,311   0.56   2.11   1,496
         cyclic                    1,683   0.45   2.10     563

2. **32,606 runs in 9 min 59 s: 54 runs/s on average.** (The Framework's Radeon: 338 runs/s.) The
   rate in the progress line is per print interval, so it swings: 71 of the 99 progress lines say
   "0/s", the others 39-140/s (mean 85/s), and the final status says "39/s". The runs come in
   batches of 1,024. A rate averaged over the last minute would read better than "0/s" most of
   the time. Origins: random 12,991 (40%), mutate 7,640, seed 4,628, cover 3,248, named 2,203,
   balance 729, transplant 690, transplant-scaled 477.
3. **Usable: "Usable, no lag"** (Jimmie, while it ran). "6 for runs on the processor and 4 for
   the GPU's batches, of 12 cores (2 left free)."
4. **No error or GPU warning**: the output has only the start lines, progress lines and the
   final status.

Smaller (A1): the "N confirmed" count goes down as well as up (0, 96, 90, 75, 67, 163, 159 … 299, 293,
290), presumably as confirmed elites are displaced by better unconfirmed ones. Fine if meant, but
a reader may expect it never to fall.

## A2. GPU runs replay the same on the CPU: pass

Files: `A2-jaca.json`, `A2-life.json` (the plan's corrected commands, `--measures all`),
`A2-check.ps1` (the loop), `A2-check-output.txt`, `A2-replays.csv`, `A2-hashes.csv`,
`A2-scenes\` (the 30 saved scenes), `A2-gpu-tests.txt`.

1. **30 of 30 match**: for each of the 20 JACA and 10 Life-like runs from job 1, the scene saved
   with `jobs scene 1 <RUN>` and run with `--cpu` for the run's `gens` (1024) gives population /
   cells equal to the run's **`measures.density`** to 6 decimals; the largest difference is
   3.0e-8 (float32). All 30 replays ran on `cpu (12 threads)`. (My first pass of the script also
   required the run's `cells` to equal the replay's and so flagged all 30; that was my mistake,
   not the plan's check, and is fixed in the committed script. See the small finding below.)
2. **The five `--gpu` hashes equal the CPU's** (three JACA, two Life-like, 1024 generations, all
   on the RTX 3050, Vulkan):

   | Run | Family | CPU = GPU hash | `run` with no flag picks |
   |---|---|---|---|
   | 28742 | jaca | d6844bf981476804 | cpu (12 threads) |
   | 29441 | jaca | 50203b220b8c925a | cpu (12 threads) |
   | 2315 | jaca | 42896127555a1603 | cpu (12 threads) |
   | 12443 | life_like | b0f52c8e767e90fc | gpu (RTX 3050, Vulkan) |
   | 33034 | life_like | bc6daad3401b6f86 | gpu (RTX 3050, Vulkan) |

3. **Optional GPU tests with the automatic choice** (no `JETCARP_GPU`; branch 472bec5):
   **all pass**, 55 passed, 1 ignored, 1.6 min; they run on "NVIDIA GeForce RTX 3050 6GB Laptop
   GPU (NVIDIA), Vulkan". (On the UHD two fail: G2.)

Smaller (A2):
- **`jobs runs` lists `cells` as 16000 for every run, but the worlds have 15,510-16,048 cells**
  (each tiling's nearest fit), and **run 27882 (`JACA B1/S123` on `penrose-rhomb`, level 5) has
  35,000**. So `cells` is the requested size, not the run's. The stored densities use the real
  count (they all match), but a reader computing population from `density × cells` would be off.
- With no flag, `run` picks the CPU for these JACA scenes (16,000 cells, 1024 generations) and the
  GPU for the Life-like ones of the same size: JACA's work estimate puts it under the GPU
  threshold here. For the main session's threshold tuning; the GPU gives the same hash.

## A3. CPU-only explore confirms (#3): pass

Files: `A3-steps.ps1` (the script that ran the step), `A3-log.txt` (timed log), `A3-explore.txt`
(first session), `A3-resume.txt` (the resume: its final summary on stdout first, then its progress
lines from stderr), `A3-status.txt`.

**Deviation: I added `--cpu`** (`search explore --cpu --families jaca --minutes 10 --label
cpu-jaca`). The step tests the CPU-only path (#3), but in 0.4.2 explore's default is automatic
("the GPU once the work is large enough to gain", per `--help`), and A1's JACA runs went to the
GPU. With `--cpu` every line says "cpu only" and "threads: 10 for runs on the processor, of 12
cores (2 left free)". It is still job 2, as the later steps expect.

The "second window" was a second process from the same script: after 300 s, `jobs stop 2`, then
`jobs wait 2 --timeout 60`, timed from just before the stop, then `jobs resume 2 --minutes 4` at
once.

1. **Confirmation works on the CPU:** the first session paused with "30 confirmation runs" and 7
   confirmed (the stopped progress line); the final status: **"39 confirmation runs", "8
   confirmed"**, 825 runs, 268 elites in 152 niches, 8 min 56 s over both sessions. (0.4.1 always
   showed 0.) About 1.5 runs/s on this CPU (the Framework: ~3 runs/s on 32 threads).
2. **`jobs stop` → `jobs wait` returned in 0.47 s, exit 3** ("explore search 2 is paused"); the
   stop said "asked explore search 2 to stop at its next checkpoint". **The explore process
   itself exited 1.44 s after the stop**, so `wait` returned about 1 s before the run let go:
   **#16 shows here too**. Its last output: "explore search 2 paused (as asked)".
3. **The resume straight after was accepted** (exit 0, no "already being run"), although the old
   process was still running when it started. It ran 505 → 825 runs and paused "at its budget".
   So on this machine #16's window didn't bite, but it's there (1 s).

Smaller (A3): the resumed session's **last progress line says "5 confirmed", while its final
summary and `jobs status 2` say "8 confirmed"** (the count went 7, 6, 5 during the resume). The
two counts seem to measure different things (elites currently confirmed vs. all confirmed?);
the same word for both is confusing. In A1 the last line and the status agreed (290).

## A4. The smart JACA search: pass

Files: `A4-explore.txt`, `A4-status.txt`, `A4-parents.json` (the job's `spec.parents` from `jobs
status 3 --json`), `A4-runs-signs.csv` (all 14,273 runs with the five `sign_*` measures; a
superset of the plan's `A4-runs.csv`, which is left out of the repo).

1. **It started without an error** (`search explore --gpu --families jaca --parents-from 2
   --reviewed keep,maybe --minutes 6 --label smart-jaca`, job 3, exit 0, 6.1 min) and ran on the
   RTX: 14,273 runs (40 runs/s), 2,528 elites in 1,321 niches, **133 confirmed** (399
   confirmation runs). **It took its parents from job 2**: `jobs status 3 --json` → `spec.parents`
   holds **500 parents, all `"job": 2`**, every one with **`"why": "best"`** (the fallback: job 2
   has no reviews), 313 of them `"strong": true`, 304 distinct rules, runs 5-855. **But the
   search doesn't say so**: its output has no line about parents at all (only "explore search job
   3 in …", the GPU line, progress and the final status), and neither does `jobs status 3`. A line
   such as "parents: 500 best runs of job 2 (it has no reviews)" would answer check 1 and warn that
   the fallback was used.
2. **Origins** (`Group-Object origin` over the plan's `A4-runs.csv`): all seven, `random` the
   largest at about 30%:

   | origin | runs | share |
   |---|---|---|
   | random | 4,160 | 29.1% |
   | mutate | 2,460 | 17.2% |
   | balance | 1,957 | 13.7% |
   | transplant | 1,814 | 12.7% |
   | transplant-scaled | 1,369 | 9.6% |
   | cover | 1,333 | 9.3% |
   | seed | 1,180 | 8.3% |

   (The Framework: random 29%, mutate 18%, balance 14%, transplant 11% + scaled 9%, cover 9%, seed
   9%.)
3. **The `sign_*` columns aren't in the plan's `A4-runs.csv`**: `jobs runs 3 --limit 0 --format
   csv` without `--measures` gives only `id,stage,parent,family,tiling,nb,rule,seed,seed_kind,
   cells,gens,rng,origin,fate,score`. With `--measures
   sign_pos,sign_balance,sign_sorted,sign_trade,sign_lost` they are **filled for all 14,273 JACA
   runs** (sign_pos 0-1, sign_balance 0-0.5, sign_sorted 0-1, sign_trade 0-0.55, sign_lost 0-1).
   The plan's command needs `--measures` for check 3.

Smaller (A4):
- **The `parent` column is empty for every run**, including the 2,460 `mutate`, 1,814 `transplant`
  and 1,957 `balance` runs (and all 32,606 of A1's). So the export can't show lineage, neither
  within a search nor back to job 2.

## A5. The rating page in Edge: pass (with a deviation: `--sample` gave 13 clips)

Files: `A5-clips-sample48\` (the plan's command: its manifest and output), `A5-ids.txt` (the 48
runs used instead), `A5-clips-manifest.json` and `A5-clips-index.html` (the page Jimmie rated; the
48 GIFs are left out of the repo), `ratings-A5-clips.json` (the downloaded ratings),
`A5-page.png` (the page after the reload and Save, dark mode; Edge's tab strip and address bar
cropped off), `A5-review.txt`, `A5-review-again.txt`, `A5-reviewed.txt`.

**The plan's `jobs clips 3 --sample 48 --px 180 --page --out A5-clips` wrote only 13 clips** (in
3.9 s; "13 clips in …"). `--sample 96` and `--sample 400` also gave 13. All 13 are JACA,
category "Battles", with an empty `bucket`; the fates were running 7, froze 4, cycle 2. The same
command on job 1 (four families) gave 46 of 48, only 4 of them JACA. So **the stratified sample
caps at 13 on a JACA-only job**, too few for 30 ratings and a JACA refit. **Instead**, 48 runs of
job 3 were picked at random (`Get-Random -Count 48 -SetSeed 4242` over `A4-runs.csv`: fates running
28, cycle 10, died 6, froze 4; all seven origins) and rendered with `jobs clips 3 --ids A5-ids.txt
--px 180 --page --out A5-clips` (48 clips, 12.8 s). The page was opened with `Start-Process msedge`.

Jimmie rated **24 clips: 8 keep, 8 maybe, 8 drop, and 3 stars** (a little under the plan's 30,
but the 8 keeps and 8 drops are there), with the note "This is a test note, lots of static in this
one."

Checks (Jimmie):
1. **The keys: "All worked, moved on."** (→ ←, K M D, S; rating moved to the next clip.)
2. **After F5: "All still there."** The page says "Your ratings from before are back." (screenshot).
3. **Save downloaded `C:\Users\jimmi\Downloads\ratings-A5-clips.json`** (2,336 bytes, 19:09): `{"format":
   "jetcarp-ratings 1", "job": 3, "search": "668eb340-…", "round": "A5-clips", "rater": "Jimmie
   Rodgers", "note": …, "ratings": [24 × {"run", "verdict", "star", "ts"}]}`. The file name comes
   from the output folder (`ratings-<round>.json`).
4. **Light and dark: "Right in both."**
5. **Clumsy? "Nothing clumsy"** compared with the claude.ai version.

Reading them back:

6. **`jobs review 3 --from … --rater "Jimmie Rodgers"`**: "recorded 24 review(s) and 3 star(s) by
   Jimmie Rodgers (0 for runs not in job 3, 0 already recorded); job 3 has drop 8, keep 8, maybe 8,
   ★ 3", then "note: This is a test note, lots of static in this one." The counts match the file.
7. **The second time**: "recorded 0 review(s) and 0 star(s) … (0 for runs not in job 3, 27 already
   recorded); job 3 has drop 8, keep 8, maybe 8, ★ 3": nothing added (27 = 24 verdicts + 3 stars).
   `jobs runs 3 --reviewed any --limit 100` lists the 24 runs.

Smaller (A5):
- `jobs runs --reviewed any` lists the reviewed runs (id, score, fate, family, tiling, rule) but
  **not each run's verdict or star**, so the list can't show which were kept and which dropped.

## A6. Refit, score and export: pass (Excel skipped: not installed)

Files: `A6-refit.txt` (PowerShell's error-record wrapping of the stderr line "replaying on …"
removed), `A6-model.json`, `A6-rescore.txt`, `A6-explore.txt`, `A6-status.txt`, `A6-all.csv`,
`A6-five.json`.

1. **refit** (exit 0) replayed the runs on the RTX ("replaying on NVIDIA GeForce RTX 3050 6GB
   Laptop GPU (NVIDIA), Vulkan"), then: "fitted to 24 review(s) of 24 run(s) of explore job(s) 3 by
   Jimmie Rodgers (8 keep, 8 maybe, 8 drop; jaca runs only)", **"held-out AUC 0.410 (keep against
   drop; on the runs fitted 0.672; the built-in score 0.422)"**, and the strongest terms
   (`size_entropy` +0.188, `jaca:sign_trade` −0.152, `jaca:sign_balance` −0.138,
   `jaca:sign_lost_early` +0.116, `jaca:sign_lost` −0.092, `patchiness` −0.090, `cycle` +0.084,
   `entropy` −0.081, `growth` +0.070, `travel` −0.065). It wrote `A6-model.json` ("jetcarp-score-model
   1", logistic, 23 features including five `jaca:sign_*`). **The AUC is below chance**: with 8
   keeps and 8 drops of a test round that's noise, as the plan says.
2. **rescore** (exit 0): "rescored 14672 runs of explore job 3 by the score model 'Jimmie Rodgers,
   jaca on explore job 3' (for jaca runs) (11597 scores changed); the archive now holds 2528
   elites in 1321 niches (2.1 s)". **The scored search** (job 4, exit 0, 3.1 min, RTX): 6,977
   runs, 1,215 elites, 10 confirmed (30 confirmation runs), no errors. **But job 4's status doesn't
   say it uses a score model**: neither the search's output nor `jobs status 4` mentions one.
   It's in `jobs status 4 --json` → `spec.score` (the model: family `jaca`, its features and
   weights). After the rescore, `jobs status 3` doesn't mention the model either.
3. **`A6-all.csv`: Excel isn't installed on the Acer** (no `Excel.Application`), so it wasn't
   opened in Excel. Checked instead: a strict CSV parse (`TextFieldParser`, quoted fields) reads
   **6,977 data rows = job 4's 6,977 runs**, all with the header's 41 fields; ASCII only, no BOM, LF
   line endings. **The five `sign_*` columns are there** (`sign_pos`, `sign_balance`,
   `sign_sorted`, `sign_trade`, `sign_lost`), after the 21 general measures. `A6-five.json` has 5
   runs, each with all 26 measures.

Findings (A6):
- **A search run with `--score` doesn't say so** in its output or status (only in the JSON spec),
  the same pattern as A4's `--parents-from`.

## A7. Jobs wait and memory caps: pass (no note for #10)

Files: `A7-steps.ps1` (the script), `A7-log.txt` (timed log; the last 12 lines of each command),
`A7-out\` (each command's full stdout and stderr, numbered in order). Every command was started
with `Start-Process` redirected to files, waiting on that process only, so a detached hunt couldn't
hold a pipe open (none did: the detached starts returned in 0.2-0.3 s).

1. **Exit codes as expected:**
   - `search hunt --soups 3000 --detach --label wait-done`: "hunt job 5 started (detached)",
     0.29 s. **`jobs wait 5` → exit 0** after 5.2 s: "hunt 5 is done" (3,000 soups, 1,377 soups/s,
     on the RTX).
   - `search hunt --soups 2000000 --max-rss-gb 0.05 --label capped` (exit 0, 1.75 s): "hunt 6
     paused (memory 0.2 GB is over the cap of 0.05 GB); `jetcarp jobs resume 6` resumes it
     exactly". It paused before its first soup (0 soups, 0 s run), because the process alone is
     over 0.05 GB. **`jobs status 6`**: "status paused, 0 s run …" and "note: memory 0.2 GB is
     over the cap of 0.05 GB". **`jobs wait 6 --timeout 5` → exit 3** at once: "hunt 6 is paused".
   - `search hunt --soups 2000000 --detach --label to-kill` → job 7. After 10 s, the only
     `jetcarp.exe` was **`jetcarp.exe jobs resume 7 --library …\library.sqlite --quiet`** (the
     detached runner, pid 47736), killed with `Stop-Process -Force` at 19:20:28. **`jobs wait 7
     --timeout 120` → exit 6**: "hunt 7 is still marked running, but no process runs it" (11,923
     soups done). **`jobs wait 7 --timeout 2` → exit 6 at once** (0.17 s).
2. **The killed hunt showed as gone after 43.0 s** (from the kill to `wait` returning), inside
   the ~45 s heartbeat. Windows file locks didn't get in the way.
3. **Job 7 resumed:** `jobs resume 7 --minutes 1` → exit 0 after 62.8 s, 11,923 → 99,858 soups,
   "hunt 7 paused (at its budget)". `jobs status 7` lists its new finds.
4. **#10:** `JETCARP_GPU=off`, `search hunt --gpu --soups 500 --label no-gpu` → **exit 0**, 500
   soups done (1,137 soups/s), **on the CPU** (`jobs status 8` names no GPU, where job 5's says
   "GPU NVIDIA GeForce RTX 3050 6GB Laptop GPU (NVIDIA), Vulkan"). **It didn't fail, but it printed
   no note**: its stderr is only "hunt job 8 in …", its stdout the result. The plan expected "one
   note". `JETCARP_GPU` beats `--gpu` by design, but a word that `--gpu` was overridden would help.

Smaller (A7):
- While `jobs wait 7` waited, it printed the same progress line every ~5 s (9 identical lines in
  43 s, `A7-out\7.err`).

## A8. Rules, names and progress: pass

Files: `A8-log.txt`, `A8-out\` (full outputs), `A8-rules.txt` (as the plan's `Set-Content` wrote
it: LF between the lines, CRLF at the end), `A8-B47_S13568V_4.json`, `A8-B3_S23V_C4.json` (the
two `try` runs saved with `--json --save`).

1. **Both V rules run as edge-neighbour Generations rules.** `search try --tiling square --rule
   "B47/S13568V/4"` → exit 0, "generations: froze at generation 6, score 0.32 (Frozen at once)";
   `"B3/S23V/C4"` → exit 0, "generations: froze at generation 11, score 0.32". The text doesn't
   show the neighbourhood, so I reran both with `--json --save`: the scene's CA is `{"rule":
   "B47/S13568/C4", "neighborhood": "edge"}` and `{"rule": "B3/S23/C4", "neighborhood": "edge"}`
   (the V becomes `neighborhood: edge`).
2. **`"B4v7/S2"` → exit 1: "Error: a V goes at the end of the rule or right after its B or S
   counts: B47/S2V"**: it says where, and suggests the fix.
3. **The bad rules file is refused before anything runs:** `search hunt --rules "" --rules-file
   A8-rules.txt --soups 20` → exit 1 in 0.11 s: "Error: 1 rule cannot run, so the job was not
   started:" / "line 3 of A8-rules.txt: B4x/S2: 'x' is not a neighbour count". No job was made
   (the next hunt is job 9, right after A7's job 8).
4. **The progress line reads "hunt 9: 30/30 soups in each of 6 groups, 562 soups/s, …"** (#8),
   for `--rules B3/S23,B36/S23,B2/S34 --tilings square,hex --soups 30 --label groups` (exit 0,
   1.0 s, on the RTX), with one line per group (3 rules × 2 tilings).

## A9. `library soup` and the scripts: pass

Files: `A9-list.txt`, `A9-soup.json`, `A9-objects.txt` (400 generations, the plan's),
`A9-objects-2000.txt`, `A9-best.txt`, `A9-best.json`, `A9-best-2.json`, `A9-best-3.json`,
`A9-jaca-territories.txt`, `A9-jaca-territories-final.png`, `-run.json`, `.csv` (the script's
output folder).

`library list --class spaceship --limit 5` (5 of 6): a B2/S34 c-ship from hunt 9, and the glider,
HWSS, MWSS and LWSS (B3/S23). I took the **MWSS** `77364004b6d2c23cba74126b8aeb6ca3`.

1. **The rebuilt soup produces the MWSS, but not within "a few hundred generations".** `library
   soup … --save A9-soup.json`: "MWSS (B3/S23 on Square): 16x16 rect soups at density 0.5, hunt job
   7 / soup 4526 (rng state 17520777392164346969): 1 copy, 38 ships; **settled at generation
   8551**", with the note "the grid is 1024 unit cells across: ships that fly off reach its dead
   edge before generation 8551, and land there". The plan's `objects A9-soup.json --gens 400
   --list` shows 14 objects (2 gliders, 3 blocks, a ship, 8 unsettled) and **no MWSS yet**.
   Scanning generations: **at 2,000 and 2,500 the census has "MWSS (c/2) x 1", `77364004` (the
   find's own key), "MWSS (c/2), c/2 orthogonal"**; it isn't there at 800 or 1,500, and is gone
   by 3,000 (it reached the dead edge, as the note warned). So `library soup` rebuilt the exact
   soup. The plan's 400 generations just suits short soups; `library soup` could print when the
   find first appears.
2. **`--best 3` wrote three scenes** (7.5 s, re-running all 10,000 soups of hunt 7): `A9-best.json`
   (soup 4526, 38 ships, the same soup), `A9-best-2.json` (soup 7794, 7 ships), `A9-best-3.json`
   (soup 9324, 7 ships), each "1 copy".
3. **The JACA example ran** (`script --example jaca-territories`, 1.9 s, exit 0): JACA B27/S03456
   on cairo, 12,288 cells. Each line gives the sign shares and territory measures:

       generation 0: +1 2761, -1 2719, balance 0.496, sorted 0.01, fronts 4508, traded -
       generation 64: +1 3061, -1 3420, balance 0.472, sorted 0.948, fronts 491, traded 0.467
       generation 256: +1 3181, -1 4069, balance 0.439, sorted 0.976, fronts 275, traded 0.15
       generation 1024: +1 3245, -1 4413, balance 0.424, sorted 0.99, fronts 130, traded 0.139
       generation 2048: +1 3109, -1 4677, balance 0.399, sorted 0.991, fronts 122, traded 0.072

   It makes sense: the two signs sort into territories (sorted 0.01 → 0.99), the fronts between
   them shrink (4,508 → 122), trading slows, and −1 slowly gains. `final.png` shows two clean
   territories, blue and red (Koi), with a bright front. It wrote `final.png`, `run.json` and
   `territories.csv` into `$T\out\…_jaca-territories`.

## A10. Packs with schema-2 runs: fail as planned (the export carried 0 runs), pass after `jobs seal`

Files: `A10-log.txt` (both attempts, timed), `A10-out\` (full outputs, 1-6 the plan's commands,
7-12 after sealing), `A10-check.txt` and `A10-import.txt` (the sealed pack's), **`A10-pack.zip`**
(the sealed pack, 1.30 MB, sha256 `9b58221d4e6cb843429ce913e52655264e764c4adce26bb673182cd658cdbbe4`;
pack version `sha256:07b03d90…`; made with `tar.exe -a`, so the paths use `/`; unzipped again
and `pack check` passed).

Deviation: the plan's `$S = (& $J jobs status 3 --json | ConvertFrom-Json).folder` gives nothing
(rc.1's JSON has no `folder`); the uuid is `spec.uuid`, `668eb340-e9e8-45b2-8eea-bcfe9df3be76`.

`pack key --name "RC tester (Acer)"`: "made publisher key SHA256:F1dD/mOg51iiC1+we8XeUDg9LMLEE4n19z9Li3pOqN8",
in `$T\config\pack\` (`publisher_ed25519`, `.pub`, `publisher.json`); the everyday
`%APPDATA%\jetcarp` was unchanged.

**First attempt, as the plan says:**
1. `pack export --to A10-pack --feed rc-acer --title "rc test, Acer" --search 668eb340… --no-media`
   → exit 0, "27 files, 252875 bytes", "120 patterns read", "search 668eb340…: copying its
   segments". `pack check` → exit 0 ("11 objects checked", signed by its publisher). `pack import
   --library $T\import\library.sqlite` → exit 0: patterns 120 added, sightings 209, searches 1,
   120 of 120 verified again, **but "search 668eb340…: 0 runs, 0 elites in 0 niches, rebuilt in
   1.9 s"**. `jobs list` shows `explore 1: 0 runs … paused` (and hunts 2-5 "imported from pack");
   **`jobs runs … --measures sign_balance,sign_sorted` → "0 run(s) of explore job 1"**.
2. **Why:** job 3's search folder held only `manifest.json` and `search.sqlite` (7.1 MB), **no
   Parquet segment**. A search seals its runs into segments "every million runs by itself" or with
   `jobs seal`, and a pack carries only sealed segments. Job 3 had 14,672 runs and was never
   sealed, so **the export copied no runs and said nothing** ("copying its segments" either way).
   Anyone exporting a normal-sized search gets an empty search in the pack. Suggest: `pack export`
   seals a stopped search's unsealed runs (or refuses, or at least warns "N runs not sealed: run
   `jobs seal`").

**Second attempt, after `jobs seal 3`** ("sealed 14672 run(s) of explore job 3 into
runs/part-000001.parquet … (0.2 s)", 1.3 MB); the first pack, its hidden store and import folder
were moved aside first:
1. **Export, check and import pass:** export "28 files, 1549199 bytes"; check "12 objects checked
   (1398499 bytes)", signed; import: patterns 120 added, sightings 209, searches 1, **"search
   668eb340…: 14672 runs, 2528 elites in 1321 niches, rebuilt in 1.9 s"**.
2. **The imported library has the search as a paused explore job with `sign_*` measures:** `jobs
   list` → `1 explore paused … explore 1: 14,273 runs (0/s), 2,528 elites in 1,321 niches, 80
   confirmed, 13 of 1,359 tilings; cpu only`; `jobs runs --measures sign_balance,sign_sorted
   --limit 5` lists five JACA runs with both filled (e.g. 4868: 0.0495, 1).
3. **`A10-pack.zip` (1.30 MB) is committed** for the Mac and the Framework to import.

Smaller (A10):
- **The imported job says "80 confirmed", the source job 3 "133 confirmed"** (same 14,273 runs,
  2,528 elites, 1,321 niches).
- The imported job's line says "cpu only" though job 3 ran on the RTX (nothing ran on import; the
  label could say "imported").
- "ratings 0": Jimmie's 24 verdicts and 3 stars on job 3 stayed home, as designed ("otherwise only
  consented raters' go in", `--no-ratings`).

## A11. The app and JACA's colours: pass

Files: `A11-jaca.png` (the app window, PrintWindow by process id: "JACA rainbow fronts (Cairo)",
running, gen 3062, 348 fps, status bar "simulation: GPU", 1,839,360 cells), `A11-koi-242.png` and
`A11-koi-224.png` (*JACA bead borders (square, blast 1)* and *JACA war on the hat tiling* rendered
with `run <parity scene> --gens 1500 --png`, on the RTX).

The app was started from the test environment (`Start-Process $T\bin\jetcarpw.exe`; it starts
`jetcarp.exe`, window "JETCARP"), with no `JETCARP_GPU`.

Jimmie's steps:
1. JACA presets (bead borders, war on the hat tiling, two others): done, each ran.
2. A world with `B3/S23V`: done.
3. *Run → GPU simulation*: a choice set to Automatic. The 2048 × 2048 Life world: "both were over
   300 FPS, it was hard to tell a difference"; **the status bar said "simulation: GPU" on Automatic
   and the CPU on Off**.
4. JACA at full speed: "looks the same CPU or GPU" (glow and counts).
5. *View → Desktop background* beside Screensaver: "That's fine".
6. *Tools → AI control…*: "It opens, closes, and even pops out and back into the main window
   correctly."

Checks (Jimmie):
1. **Koi: "Didn't notice."** So I looked at the two presets rendered from the command line (same
   scenes, palette *Tide*): **the first sign is teal, the second cream → peach → orange (the light
   end of Koi, little red after 1,500 generations)**, and **the two are easy to tell apart, in the
   still territories too**.
2. **The card reads `B3/S23V`** (not `B3/S23`).
3. **The big world runs on the GPU by default** ("simulation: GPU" on Automatic, the CPU on Off), but
   **not visibly faster**: both over 300 fps, so the display rate hides the difference at this size.
4. **JACA on the GPU: the same glow and counts** as on the CPU.
5. **"Nothing wrong"**, nothing worse than 0.4.1.

## D. The desktop background on the candidate (Jimmie's go-ahead at about 19:50)

Files: `D-log.txt` (commands, timed), `D-out\` (full outputs), `D2-status.txt`, and the later
files named below.

**D1. The everyday host:** in a clean environment (no `JETCARP_*`), Scoop's `jetcarp` 0.4.1:
`jetcarp host status` → exit 1, **"Error: the JETCARP background host is not running"**; no
`jetcarp` process, no JETCARP `Run` value, no `SCRNSAVE.EXE`. **So there was nothing to stop, and
D5's "put it back" means: stop the candidate's host and see the normal wallpaper return.** Before
D2 I saved the wallpaper settings (`HKCU\Control Panel\Desktop` and `…\Explorer\Wallpapers`
exported, and a copy of `TranscodedWallpaper`, in this session's scratchpad): a picture wallpaper
(`WallpaperStyle` 10, history `c:\windows\web\wallpaper\themea\img20.jpg`), last set 2026-11-12.

**D2. The candidate's host as wallpaper** (the A11 app still open, running a JACA world):
`host start` → exit 0 in 0.74 s ("running, pid 49412 … GPU Intel(R) UHD Graphics"; screen 0: "A
classic a day · Quick Start rule:ForestFire 0.01/0.0001 (3 of 7)"; "note: GPU: Intel(R) UHD Graphics
(Intel Corporation), Vulkan; GPU simulation auto (automatic)"); `host wallpaper on` → exit 0
("wallpaper: showing", "230400 cells of 2 px"); `host status` 3 s later: "518400 cells of 2 px",
generation 78, 516 MB. Processes: `jetcarpw.exe host serve` → `jetcarp.exe host serve`.
1. **"Live, under the icons"** (Jimmie).
2. **`host status` names the Intel UHD**, the **display** adapter from doctor. **Windows' per-process
   GPU counters** (`\GPU Engine(*)\Utilization Percentage`, LUIDs mapped to names through
   `HKLM\SOFTWARE\Microsoft\DirectX`) agree: the host's process uses the **UHD's 3D engine at
   15-19%**, the RTX shows nothing over 1%; the host takes 3.5% of the CPU (of 12 threads).
3. **"Smooth"** (Jimmie).

Finding (D2): **the app's GPU simulation runs on the UHD too, not on the RTX.** The A11 app was
showing a JACA world ("simulation: GPU", 1.84 M cells, ~348 fps), and its process (48632) loaded
the UHD's 3D engine at ~60% with nothing on the RTX, although doctor calls the RTX the compute
adapter ("the GPU simulation uses it" on both lines). So on this laptop the app and the host
simulate on the UHD, and **on rc.1 a sandpile with drops would be wrong in both (#20)**. If the
app is meant to simulate on the compute adapter, it doesn't here; if it's meant to stay on the
display adapter, doctor could say so.

**D3. The Desktop background pane, Fit to this computer, the cards** (`D-monitor.txt`: every 3 s,
the host's status, its CPU %, and per-process GPU engine use per adapter; `D3-host-tuning.json`:
the tune as saved in `host.json`; `D3-tune-crops\`: the 7 crops it saved):
0. Jimmie paused the app's JACA world first.
1. **The pane: "Looks ok."**
2. **Fit to this computer… (10% CPU, 25% GPU): no sweep. "I only saw it try a single one, it didn't
   sweep through options."** The monitor agrees: from 20:28:55 to 20:29:13 (**about 18 s**) the host
   went through all 7 scenes of "A classic a day" (`tuning: screen 0, scene 1 of 7: profile Life at
   16 px (size 1 of up to 8)`, then Langton's ant, Cyclic spirals, Penrose waves at level 4 (15.1 px,
   "size 1 of up to 3"), Hodgepodge, …), **each at its first, coarsest size only**, then "last
   tune: done" / "swept 7 scene(s); sizes saved". Every scene ended at 16 px (Penrose level 4),
   "(tuned)": Forest fire went from 518,400 cells of 2 px to 8,040 cells of 16 px.
   **Why: the tuner measured another process's GPU load as its own.** The saved rung for Life at
   16 px: `"cells": 8040, "cpu_percent": 0.51, "gpu_percent": 92.5, "p95_ms": 21.5, "fps": 29.7,
   "on_gpu": false, "fits": false, "over": "GPU 93% (over 20%: the 25% limit, less 20%)"`. At that
   moment Windows' per-process counters had **the host's process at 3% of the UHD's 3D engine and
   the app's process at 93%** of the same UHD (it was 60% while JACA ran before, 9% right after the
   tune, under 1% later). So on Windows the tuner's GPU % seems to be the **whole adapter's** busy
   time, not the host's own, and any other GPU user (here the app, during its own Fit) makes every
   size look far over the limit: the sweep stops at the first rung and recommends the coarsest size
   for every scene. (Why the app loaded the UHD at 93% during the Fit is a second question; its
   world was paused.)
3. **The cards: "The cards showed life, not forrest fire, which was the scene in the background at
   the time."** The saved tuning has 7 scenes with one rung each (`"recommended": {"px": 16}`); the
   crops are real frames at 16 px (e.g. `s0-profile-life-16px.png`, 190 × 120 px of orange Life
   cells), each 326-475 bytes.

**Also (not in the plan): Jimmie couldn't make a rotation from a running scene.** "I tried creating
a rotation, as I want only that one in the rotation for now. Then I tried to set that new
rotation, but couldn't get it to go." In the settings folder, the app saved the scene as a profile
(`screensavers\jaca-rainbow-fronts-cairo.json`, 20:31:08, "JACA rainbow fronts (Cairo)", the full
scene) **but no rotation: there is no `rotations\` folder**, and `host status` lists only the four
built-in rotations. The monitor saw a second screen appear for a moment at 20:32:48 ("screen 1: A
classic a day · ForestFire · 518400 cells of 2 px · wallpaper on monitor 0 (\\.\DISPLAY1)", gone by
20:33:37), pauses and resumes, then the rotation changed to "Wolfram series" (20:34:59) and "Until
it settles" (20:35:02, Life at 3 px), where it is now.

**D3b. The Fit again from the command line, with the app closed** (my addition, Jimmie agreed; to
see whether the app's GPU load caused D3.2): Jimmie quit the app (only `host serve` left);
`host tune --json --crops D3b-crops` (default limits 10/25) → exit 0 in 6.8 s (`D3b-tune.json`,
`D3b-crops\`). **The same: each of "Until it settles"'s 3 scenes was shown once at 16 px (8,040
cells) and measured `"gpu_percent"` 90.4-90.6%, `"fits": false`, "no size was within the limits;
finer sizes were not shown: 16 px was already far over the limits", `"gpu_timing": "submission"`.**
Meanwhile **Windows' counters had the host's process at 10-11% of the UHD's 3D engine** (and
13-33% at 3 px, 230,400 cells, just before), CPU ~1%. So **it isn't the app: on Windows the
tuner's "submission" GPU timing reads ~90% for a scene the GPU spends ~10% of its time on**, about
8-9 times too high, and Fit can never get past the first rung. Jimmie: "There were only 3 scenes
before it selected one it seems."

**Jimmie then saw something wrong:** "Life doesn't look right, blinkers are oscillating too slowly
vs the rest. Either the updates are happening too quickly and it just looks wrong, or something
serious is happening." **Checked: the simulation is right, and it's temporal aliasing.** The host
draws **30.0 fps** (`fps: 30`; the panel is 144 Hz) and steps **60.2 generations a second**
(`generation 2521 → 2832` in 5.2 s), **2 generations per frame**, so a period-2 blinker shows
nearly the same phase every frame and drifts slowly (0.2 gen/s over). The 16 px Life scene holds
30 blinkers by generation 1,000 (`D4-objects.txt`: blinker (p2) x 30, block x 13, beehive x 4, boat
x 4, loaf x 1), so it shows badly at 16 px; it was already 60 gens/s at 30 fps at 3 px before the
Fit. D4's hash check (below) confirms the scene computes the same on CPU and GPU. A gens-per-frame
of 2 (or any even number) freezes every period-2 oscillator; an odd number, or one generation per
frame, would show them blinking.

**D4. The same from the command line:**
1. `host tune --cpu-limit 2 --gpu-limit 5 --fps 30 --json --crops D4-crops` → exit 0 in 6.8 s
   (`D4-tune.json`): **it finished, and its JSON lists each size's numbers per scene, the
   recommended size and the GPU timing method** (`"gpu_timing": "submission"`), but again **one size
   per scene**: 16 px, GPU 88-91% ("over 4.0%: the 5.0% limit, less 20%"), recommended 16 px.
   **`D4-crops` holds one PNG per card** (3).
2. `host scene --save D4-scene.json` ("saved Quick Start rule:B3/S23 (120 x 67 cells, tuned)");
   **`run --gens 300 --json --cpu` and `--gpu` give the same hash, `cd1d189a720ceee4`** (population
   373; the GPU run on the RTX). The tuned wallpaper is reproducible.

**Undoing a failed Fit doesn't work from the command line:** `host tune --pick own --cpu-limit 10
--gpu-limit 25` and then `host tune --pick 3` both left every scene at 16 px (`"chosen": true` with
`--pick 3`, but `cell_px` 16): the sweep never reaches the scene's own 3 px, so it can't be placed.
To get a normal wallpaper back for D3.6 I switched the host to a rotation that hadn't been tuned:
`host rotation "Classics, hourly"` → "profile Life (1 of 7) · 230400 cells of 3 px", tuned false,
the host at 21-24% of the UHD, 1.3% CPU.

**D3.3-D3.5 with one size per scene:** the cards had nothing to choose between (one rung each), so
Jimmie's picks, *Use the recommended size for the rest* and the strict-limits re-run (D3.4; D4's
command-line strict tune behaved the same) couldn't test anything. **D3.5, the host against
Windows' own measure**, from the monitor: at 16 px the card said GPU 88-98%, CPU 0.2-1.0%; Windows
had the host's process at 3-11% of the UHD's 3D engine and 0.4-1.4% CPU. At 3 px (230,400 cells,
untuned) Windows had the host at 8-33% of the UHD and 1-3% CPU. So the CPU % agrees, the GPU % is
8-9 times too high (`gpu_timing: submission`), as the plan warned ("a large difference is a
result"). No 1 px card was ever made, so no 1 px comparison.

**D3.6. The GPU overrides: pass.** The app was reopened. My first instructions were too vague
(Jimmie set only the app's *Run → GPU simulation* to Off and couldn't find the pane's control), so
after a screenshot of the app (`D3-app-now.png`) I pointed to the exact rows: the Desktop background
tab's **GPU simulation** ("Follow the shared setting (Automatic)", under "Frames per second 30",
above "Shared setting: Automatic") → **Off**; **Run → GPU simulation → On**. Then:
- the app's status bar: **"simulation: GPU"** (its big Life world, 1,841,280 cells; the app's
  process on the UHD at ~70%); `app.json` `"gpu": "on"`, `host.json` `"gpu": "off"`;
- **`doctor` shows the two choices separately, with where each came from** (`D3-doctor-overrides.txt`):
  "the app: on, from the app's own setting (its own choice: on)" / "the desktop background: off,
  from the desktop background's own setting (its own choice: off)";
- **the wallpaper steps on the CPU:** the same Life wallpaper (230,400 cells, 3 px), measured over
  12 s each: **Off → host CPU 8.0%, host UHD 3D 7.1%; Follow → host CPU 1.6%, UHD 8.7%**, 30 gens/s
  both. (The rotation had moved to a turmite, which only runs on the CPU; `host previous` ×4 brought
  Life back for the comparison.)
- Both set back: pane → "Follow the shared setting (Automatic)", *Run → GPU simulation →
  Automatic*; `app.json` and `host.json` `"gpu": "follow"`; doctor: "the app: auto, from automatic
  (its own choice: follow)", "the desktop background: auto, from automatic (its own choice:
  follow)" (`D3-doctor-follow.txt`).
- Small: `host status`'s note keeps saying "GPU simulation auto (automatic)" (from the host's start)
  while the desktop background is set to Off.

**D3.7. Monitors: skipped** (the external monitor wasn't attached).

**D5. Put it back:** `host stop` → exit 0, "stopped"; `host status` → "the JETCARP background host
is not running"; no `host serve` process left (only the app). **The wallpaper settings are exactly
as before D2**: `WallPaper` = `…\Themes\TranscodedWallpaper`, style 10, tile 0, `BackgroundType` 0,
and `TranscodedWallpaper` has the same SHA-256 as the copy saved before. **Jimmie: "Normal wallpaper
back."** The everyday host wasn't running in D1, so it wasn't started again.

Findings (D), most important first:
1. **Fit to this computer can't work on Windows (rc.1):** the tuner's GPU timing ("submission")
   reads ~90% for scenes Windows measures at ~10% of the GPU, so every scene is "far over the
   limits" at its first, coarsest size, there's no sweep, and every wallpaper scene is left at
   16 px. Same from the app and from `host tune`, with the app closed too.
2. **After such a Fit the scenes can't be put back from the command line:** `--pick own` and
   `--pick 3` both leave 16 px.
3. **A new rotation made in the app isn't saved** (no `rotations\` folder; only the scene's profile
   is saved), so it can't be chosen.
4. **Period-2 oscillators alias on the wallpaper:** the host draws 30 fps and steps 60 gens/s (2 per
   frame), so blinkers look nearly frozen or slowly blinking; very visible at 16 px.
5. The app's and the host's GPU simulation both run on the UHD here (D2), so #20 hit both on rc.1.
6. Smaller: the cards showed only Life's row (Jimmie); `host status` keeps the startup GPU note.

## A12. Opening a copy of the everyday library: pass

Files: `A12-041-info-before.txt`, `A12-041-jobs.txt` (Scoop's 0.4.1 on the original, first),
`A12-info.txt`, `A12-jobs.txt`, `A12-qs.txt` (the candidate on the copy), `A12-041-info-after.txt`
(0.4.1 on the original, afterwards), `A12-041-on-copy.txt` (extra: 0.4.1 on the copy).

1. **The everyday data folder** (`jetcarp paths` with Scoop's 0.4.1, no `JETCARP_*`):
   `C:\Users\jimmi\AppData\Local\jetcarp` (40.5 MB: `library.sqlite` 12.4 MB, three searches,
   `host.lock`). 0.4.1 on the original: **"schema version: 3; patterns 98, rules 24, pattern rules
   99, sightings 141 (647339 copies), jobs 33, Quick Start 2619, ratings 1, media 0, ants 8"**; `jobs
   list` 33 jobs; `library quickstart` 2,255 entries.
2. **Copied** (`Copy-Item -Recurse`, not moved) to `$T\data-copy`.
3. **The candidate on the copy works, with the same counts:** `library info --library
   $T\data-copy\library.sqlite` → exit 0 in 0.4 s, **the identical line** (schema version 3, patterns
   98 … ants 8); `jobs list` → the same 33 jobs, **line for line identical** to 0.4.1's; `library
   quickstart` → 2,255 entries, **identical to 0.4.1's apart from the catalog path**. The candidate
   wrote to the copy (its `library.sqlite` grew from 12,402,688 to 12,492,800 bytes); the original
   was unchanged across the candidate's runs (same files, sizes and times).
4. **Afterwards Scoop's 0.4.1 still opens the original without complaint:** `jetcarp library info`
   gives the same line as before; `jobs list` 33 jobs; `library.sqlite` still 12,402,688 bytes,
   2026-11-13 18:42:47. (0.4.1's own first `library info` had removed the original's 0-byte `-wal`
   and its `-shm`, a normal SQLite close.)
5. Extra: **0.4.1 also reads the copy the candidate opened** (`library info`, `jobs list`, `jobs runs
   33 --limit 3`), all exit 0. That copy has no 0.4.2 runs, so it doesn't test reading schema-2 runs
   back.

## A13. Clean up: done

1. All results committed and pushed (this folder, the table in `v0.4.2-rc.1.md`, `NOTES.md`).
2. The app was closed normally (`CloseMainWindow`, as clicking ×); the candidate's host had been
   stopped in D5. **No `jetcarp` process is left.**
3. **`$T` (`C:\Users\jimmi\jetcarp-rc-042`) is left in place** until the main session says the wave
   is done: the candidate (`bin\`), the test settings (with the tuned host settings and the test
   publisher key), the test library (jobs 1-9; job 3 sealed), the pack (`A10-pack`, `import\`), the
   library copy (`data-copy\`), and the branch clone at c74c357 with its Rust build (`src\`,
   most of the 3.8 GB). Delete it all after that.
4. **`where.exe jetcarp` is still `C:\Users\jimmi\scoop\shims\jetcarp.exe`, `jetcarp 0.4.1`.** No
   JETCARP `Run` value, no `SCRNSAVE.EXE` (ScreenSaveActive 1, timeout 60, as before the wave); the
   user PATH is still ExpandString; the wallpaper is as before (D5). The everyday settings
   (`%APPDATA%\jetcarp`, newest `app.json` 2026-11-13 13:57) and library (`%LOCALAPPDATA%\jetcarp`,
   `library.sqlite` 2026-11-13 18:42:47) weren't touched by the candidate.
