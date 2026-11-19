# Notes between sessions: the 0.4.2 cycle

Newest last. Date each note and name the machine. The notes of the cycle before are in
`../v0.4.0/NOTES.md`.

## 2026-11-14, main session: wave v0.4.2-rc.1 written (Framework)

The next wave is `v0.4.2-rc.1.md`: a full wave for 0.4.2, run **before** anything reaches `main`.
The candidate is a public pre-release built from the branch `release-0.4.2` (tag `v0.4.2-rc.1`);
PyPI, crates.io, Homebrew and Scoop don't get it. If the release page doesn't exist yet when you
start, stop and tell Jimmie: the main session pushes the branch and the tag only once Jimmie says so.

What's different from the 0.4.0 waves:
- **Nothing is installed.** Each laptop unpacks the candidate's archive into a test folder and runs
  it by full path, with `JETCARP_CONFIG_DIR`, `JETCARP_DATA_DIR` and `JETCARP_OUT` pointed into that
  folder. The everyday copies (Scoop 0.4.1 on the Acer, Homebrew 0.4.1 on the Mac) and their
  libraries must stay untouched: 0.4.2 adds a run schema 0.4.1 can't read back.
- **The GPU steps (A1/M1, A2/M2) matter most:** the explore search's GPU code changed, and CI has
  no GPU. A2/M2 compares GPU-screened runs with CPU replays, run by run.
- **Safari and the rating page (M5):** it's an offline page that keeps ratings in localStorage and
  saves them as a download. Safari may treat file:// pages differently; record exactly what
  happens.
- **Packs travel:** the Acer commits its test pack (A10), and the Mac and the Framework import it.

The Framework has moved to Fedora 45 and GNOME 51.1 (README updated). The main session runs the
Framework section itself.

## 2026-11-14, later: v0.4.2-rc.1 grew (main session)

Jimmie put everything into 0.4.2, so `v0.4.2-rc.1.md` was rewritten. New sections: **G1** (each
GPU's self-test, through `doctor`), **G2** (the parity suite in `parity/`: every built-in scene on
this machine's CPU and GPU against the Framework's CPU hashes; the Acer runs it three times: RTX on
Vulkan, RTX on DX12, Intel UHD), and **D/MD** (the candidate's background host on the real desktop,
the new Desktop background pane and Fit to this computer, cross-checked with Task Manager or Activity
Monitor; the everyday host is stopped for it and put back afterwards, with Jimmie's okay). A1 now
checks that explore uses the GPU without `--gpu`; A7 checks the no-GPU fallback (#10); A11 checks the
GPU menu and a big world on the GPU.

**A failed GPU self-test or any parity mismatch is the most important result of this wave.** Record
it in full.

Still not started: the main session pushes the branch and the tag only when Jimmie says so.

## 2026-11-14 evening, main session: v0.4.2-rc.1 is out; start here

- **The pre-release:** https://github.com/jprodgers/jetcarp/releases/tag/v0.4.2-rc.1, built from
  `release-0.4.2` (pull request #14, not merged). Use its archives as the plan says.
- **`parity/expected.csv`** is now made with the candidate's own Linux build (364 scenes, 0
  mismatches on the Radeon). `git pull` before G2.
- **CI on the pull request** failed on Windows and macOS: three tests that assumed things about CI's
  virtual GPUs, plus a misleading message when WARP is the only adapter (issue #15). Fixed on the
  branch in c2ab5e3. The rc.1 programs behave the same, so test them as they are. If a refusal
  message on a WARP-only machine reads oddly, that's #15.
- **Order:** the Acer first (the most risk: two GPU vendors and every Windows-only path), then the
  Mac. Start each one's unattended parts (A0, G1, G2) early; Jimmie joins for A5, A11 and D one
  machine at a time.

## 2026-11-14 night, main session: known on rc.1, fixed on the branch (for rc.2)

Thanks, Acer: the G1 findings were real.
- **#17:** on a fresh settings folder the self-test re-ran at every start (doctor 8–14 s); "kept
  from before" appeared when nothing was kept; with `JETCARP_GPU=off` doctor still said each adapter
  is used and tested it. Fixed on the branch (4a495c9). On rc.1, expect these; just record timings.
- **#16:** `jobs wait` returns as soon as `jobs stop` is asked, before the run lets go, so a `jobs
  resume` straight after can be refused with "already being run". Fixed on the branch (472bec5). On
  rc.1, wait ~10 s and resume again (A3 says so).
- **A2:** compare the runs' **`measures.density`** (from `--measures all`) with the replay's
  population over `cells`. The top-level `density` is the last-quarter mean. The plan is corrected.

Keep going with rc.1 as planned. Anything else that fails is new and worth recording in full.

## 2026-11-14 (18:40), Acer: G2's GPU tests fail on the Intel UHD (sandpile drops)

A0, G1 and G2 are done (`v0.4.2-rc.1.md` table; details in `results/v0.4.2-rc.1/acer/notes.md`).
**The parity suite passes on all three Acer adapters** (RTX Vulkan, RTX DX12, UHD Vulkan: 364/364 CPU
and GPU, 327 all on the GPU, scene by scene as on the Framework). But **the optional GPU tests fail on
the UHD**, and the rc.1 binary reproduces it:
- `cargo test --release -p jetcarp-gpu` (branch 472bec5): **RTX all 55 pass; UHD fails
  `sandpile_edges_drops_and_patches` ("sandpile drop 1 on square Dead Edge: hash at generation 1",
  CPU `60047217d97ba607`, GPU `024298488f7067d5`) and `sandpile_repeats_and_scripts` ("sandpile
  script: hash at generation 1", `3e93fe95da80cba1` vs `f9fb28e4fdfb1611`)**. Everything else passes.
- **With the rc.1 binary: any sandpile with `drop_per_gen` > 0 is wrong on the UHD from generation 1,
  on Vulkan and on DX12; right on the RTX (both backends); piles without a drop are right
  everywhere.** On UHD Vulkan the population at generation 1 is ~2^32 (4,294,969,752 instead of
  20,001; drop 1 and drop 7 give the same hash, the test's `024298488f7067d5`): the centre cell looks
  saturated to `0xFFFFFFFF` (`grains()` in `sim.wgsl`). On UHD DX12, population 3: the grains vanish.
  Scenes and results: `results/v0.4.2-rc.1/acer/G2-drops-scenes/`, `G2-drops.csv`.
- The UHD's self-test passes (no drop in it), and no parity scene has a drop. The CLI's `run` picks
  the RTX here in auto mode, but the UHD is this laptop's display adapter (the host's, per D2).
- Smaller: in the DX12 parity pass, one scene (n=342) ran on the UHD although `JETCARP_GPU=RTX`
  (hash right; not reproduced in 15 reruns).

Going on with A1.

## 2026-11-15 (early), main session: the Acer's findings fixed on the branch; please check #20 on the UHD

Thanks, Acer: G2's sandpile finding was a real GPU bug, and the smaller findings were worth having.
Each one is an issue, fixed on `release-0.4.2` at **c74c357** (pushed; CI running):
- **#20, sandpile drops on the Intel UHD** (4d4faba): the shader's saturating add `select(h + k1,
  MAX, h > MAX - k1)` is a pattern Intel's compiler gets wrong on both backends. The host now passes
  the limit (`thresh = MAX - drop`) and the shader just compares. The self-test now steps two dropping
  piles (one saturating the centre cell), so an adapter that gets drops wrong fails its self-test and
  isn't trusted. **Passes on the Radeon and llvmpipe; not yet seen on the UHD.**
- **#21:** a named adapter that isn't found is replaced by the best one, and run's backend,
  explore's lines and the host's GPU note now say "no RTX adapter was found, so the best one" (the
  n=342 mystery in G2 would now show it). **#26:** doctor lists `WGPU_*`; no double space in check keys.
- **#22:** explore's runs a second is now over the last minute (no more "0/s" between GPU batches).
  **#24:** the line says "(N of them confirmed)", which can fall by design. **#25:** a `--parents-from`
  search says where its parents came from, at start and in `jobs status`. **#27:** `cells` documented
  as the size asked for. **#28** (lineage of mutate/transplant runs) is an enhancement for later.
- **Parity set: 371 scenes** (`git pull`). 364–370 are sandpile drops: your six G2 scenes and one that
  saturates the centre cell. Their CPU hashes, from the Framework's development build, equal your rc.1
  Windows ones exactly.

**Acer, when Jimmie can relay, please check #20 on the UHD** (branch c74c357; Rust is installed):
1. `git fetch` and check out c74c357, then `cargo test --release -p jetcarp-gpu` with `JETCARP_GPU=UHD`,
   then again with `WGPU_BACKEND=dx12` added. Expect every test to pass, including
   `sandpile_edges_drops_and_patches` and `sandpile_repeats_and_scripts`.
2. With that build (`target\release\jetcarp.exe`): `doctor` with `JETCARP_GPU=UHD`. Expect the
   self-test to re-run (new test version) and pass with "59 world rules and 33 explore batches".
3. With that build, `parity.ps1` on scenes 364–370 only (or all 371) with `JETCARP_GPU=UHD`, Vulkan and
   then DX12. Expect CPU = GPU = expected.
4. Record it as G2b in `results/v0.4.2-rc.1/acer/`. If anything still fails on the UHD, give the
   failing hash and population at generation 1, as before.

Then carry on with the rc.1 plan (A5 onward) on the rc.1 build as written. **rc.2** (Jimmie's call)
follows once CI is green and the Mac's G1/G2 are in.

## 2026-11-15 (early), main session: Mac, start here

rc.2 is coming (#20 changed the GPU shader), after more fixes from the Acer's A5–A7. Until then the
Mac's job is to **find Metal-specific problems early**, the way the Acer found the UHD's:
1. **M0, G1, G2 on rc.1, as written** (unattended). `git pull` first: the parity set now has 371
   scenes. On rc.1, 364–370 (sandpile drops) may fail on the GPU, as they did on the UHD (#20).
   Record which, with the hash and population at generation 1.
2. **If Rust is installed, the GPU tests from the branch** (c74c357 or newer, which has the #20 fix):
   `git clone --depth 1 -b release-0.4.2 https://github.com/jprodgers/jetcarp` in `$T`, then
   `cargo test --release -p jetcarp-gpu -- --nocapture 2>&1 | tee G2-tests-metal.txt`. Expect every
   test to pass on "Apple M2 Max …, Metal". Then build `cargo build --release -p jetcarp` and run
   `parity.py` with that binary on all 371 scenes (record as G2b): CPU = GPU = expected everywhere.
3. **Then stop** and wait for rc.2. The rest of the Mac rows (M1 onward, MD, M11) run on rc.2, so
   Jimmie's time goes to the build we'll ship.

## 2026-11-14 (19:35), Acer: A1-A10 done; the pack export needs `jobs seal` first

A1-A10 are in the table (details in `results/v0.4.2-rc.1/acer/notes.md`). For the Mac and the
Framework:
- **A10/M10: `pack export --search` carries only sealed runs.** A search seals its runs into Parquet
  "every million runs" or on `jobs seal`; job 3 (14,672 runs) had none sealed, so the plan's export,
  check and import all passed but the imported search had **0 runs**, with no warning. After
  `jobs seal 3` it works: the import has the paused explore job with its runs and `sign_*` measures.
  **On the Mac, run `"$J" jobs seal 3` before M10's export.**
- **The Acer's pack is `results/v0.4.2-rc.1/acer/A10-pack.zip`** (sealed; 1.30 MB; sha256 9b58221d…;
  pack version sha256:07b03d90…; feed rc-acer; 14,672 runs of a JACA search with sign measures, 120
  patterns). Zipped with `tar.exe -a`, so its paths use `/`; it unzips to `A10-pack/`.
- Other plan notes: explore's default is automatic, so A3 needs `--cpu` to be CPU-only;
  `jobs clips --sample N` gives only 13 clips on a JACA-only job (used `--ids` with 48 random runs);
  A4's CSV needs `--measures` for the `sign_*` columns; `jobs status --json` has no `.folder` (use
  `spec.uuid`); Excel isn't on the Acer.
- New small findings: `--parents-from` and `--score` work but the output never says so; `parent` is
  empty in every exported run; `JETCARP_GPU=off` + `hunt --gpu` runs on the CPU with no note.

Next: A11 (the app, with Jimmie), then D after Jimmie's go-ahead.

## 2026-11-15, main session: G2b confirms #20; A5–A10's findings fixed; the Acer pauses for rc.2

Thanks, Acer. **G2b settles #20**: the fix passes on the UHD on Vulkan and DX12 (GPU tests, the
59-rule self-test, 371/371 parity), where rc.1 got 1 of the 7 drop scenes right.

A5–A10's findings are issues, fixed on `release-0.4.2` (784828d, local until CI on 67fb2f7 is done):
- **#29** `jobs clips --sample` capped at one clip per tiling (13 on job 3); it now tops up with
  more runs of the same tilings, each with its own rule (48 of 48 on such a job).
- **#30** the score model shows at start and in `jobs status`; **#31** `JETCARP_GPU=off` over
  `--gpu` now says so; **#32** `jobs wait` prints only changed lines; **#33** `jobs runs --reviewed`
  shows `[keep ★]`.
- **#35 (the important one)**: a pack of a search that never sealed carried no runs. Publishing now
  seals a stopped search's newest runs first ("sealed its newest N runs first, so the pack carries
  every run") and refuses a running one. On rc.2, A10 needs no `jobs seal`.
- **#36** a rescore rewrites the confirmed count and line; **#37** an imported search says "not
  run here yet". Enhancements for later: #28 (lineage), #34 (`library soup` first appearance).

**Acer: please stop here** (A11, A12, A13 and D are left). They run on **rc.2**, along with a re-run
of the rows the fixes touched, so Jimmie's time goes to the build we'll ship. The rc.2 plan comes
with the tag.

## 2026-11-14 (20:20), Mac: M0, G1, G2 pass on rc.1; GPU tests and G2b pass on Metal; waiting for rc.2

As the main session's "Mac, start here" asked (details in `results/v0.4.2-rc.1/mac/notes.md`):
- **M0, G1:** the rc.1 archive's hash is right, no Gatekeeper prompt (provenance xattr, no
  quarantine); doctor picks the **Apple M2 Max, Metal** for display and compute; **the self-test
  passes** (53 world rules + 33 batches, 588 ms cold, then ~145 ms). #17 as on the Acer: "kept from
  before" with no settings folder and nothing saved, and `off` still tests the adapter.
- **G2 on rc.1: "371 scenes: CPU matches 371, GPU matches 371; all 300 generations on the GPU in
  334"**, scene by scene the Framework's split, **no Metal mismatch**. **The drop scenes 364–370 are
  right on Metal even with rc.1** (CPU = GPU at generation 1, same populations), so #20 was
  Intel-only. The whole pass took **71 s**: the Metal device opens in about 10 ms, so the GPU beats
  the CPU on 304 of 334 scenes even for a one-off 300-generation run (medians 0.079 s CPU, 0.039 s
  GPU, including program start). The Acer's GPUs cost 0.5–2.3 s to open.
- **Branch 67fb2f7 (Rust installed):** `cargo test --release -p jetcarp-gpu`: **55 passed, 0 failed**
  on Metal, plus the ignored heavy test with `--ignored`. **G2b** with its `jetcarp` (own fresh
  folders): the self-test "59 world rules", #17's fixes, #21 and #26 show as rc.2's plan expects;
  **parity 371/371, every GPU hash identical to rc.1's.**

Nothing new failed. The Mac stops here for rc.2. `$T` (`~/jetcarp-rc-042`) stays until the wave is
done. rc.2 uses a fresh `~/jetcarp-rc-042b`.

## 2026-11-15, main session: the Acer finishes rc.1 first (Jimmie)

**Jimmie's call: finish the Acer's rc.1 rows (D, A12, A13) before rc.2 is tagged**, so anything they
find goes into rc.2. This replaces "Acer: please stop here" above. rc.2 is ready (51a1428, CI
green) and is tagged once the Acer is done. The Mac waits for rc.2 as planned.

## 2026-11-14 (21:10), Acer: G2b, A11 and D done; Fit to this computer can't work on Windows

Details in `results/v0.4.2-rc.1/acer/notes.md` (G2b, A11, D) and the table.
- **G2b (the #20 fix, c74c357) passes on the UHD:** GPU tests all pass on Vulkan and DX12; the
  build's self-test "59 world rules"; parity drops 7/7 on both backends, all 371 on UHD Vulkan.
- **A11 passes** (Koi checked from renders; Jimmie: nothing wrong).
- **D: Fit to this computer fails on Windows.** The tuner's GPU timing (`gpu_timing: submission`)
  reads 88-98% for 16 px scenes that Windows' per-process counters put at 3-11% of the UHD (CPU %
  agrees). Every scene is "far over the limits" at its first rung, so there's no sweep and every
  scene is left at 16 px; the same from `host tune` with the app closed. `host tune --pick own` and
  `--pick 3` can't put the scenes back. Also: a new rotation made in the app isn't saved (only the
  scene's profile); the host draws 30 fps and steps 60 gens/s, so blinkers alias (look frozen or
  slow; Jimmie spotted it); the app's GPU simulation runs on the UHD (display adapter), not the
  RTX, as does the host. The GPU overrides work (Desktop background Off → CPU, doctor shows both).
- The candidate's host is stopped and the wallpaper is exactly as before. The everyday host wasn't
  running before D, so nothing else was changed.

Next: A12 (a copy of the everyday library), then A13.

## 2026-11-14 (21:20), Acer: rc.1 finished (A12, A13); rc.2 can be tagged

**The Acer section of v0.4.2-rc.1 is done** (table in `v0.4.2-rc.1.md`; details in
`results/v0.4.2-rc.1/acer/notes.md`). A12 passes (the candidate opens a copy of the everyday 0.4.1
library with identical counts; 0.4.1 still opens the original). A13: app closed, no `jetcarp`
processes, `where.exe jetcarp` is Scoop's 0.4.1, no login entry or screen saver, wallpaper and the
everyday settings and library untouched. **`C:\Users\jimmi\jetcarp-rc-042` is kept** until the wave
is done (3.8 GB, mostly the branch's Rust build in `src\target`).

What rc.1 still gets wrong on this Acer, most important first (all in the notes):
1. **Fit to this computer can't sweep on Windows**: `gpu_timing: submission` reads ~90% GPU where
   Windows measures ~10%, so every scene stops at its first (coarsest) size; `--pick own`/`--pick 3`
   can't undo it.
2. **#20** (sandpile drops on the UHD): fixed on the branch, checked here (G2b). Note that the app's
   and the host's GPU simulation both run on the UHD (display adapter) on this laptop, not the RTX.
3. **Pack export of an unsealed search carries 0 runs** silently (A10); `jobs seal` first works.
4. A new rotation made in the app isn't saved (D); blinkers alias on the wallpaper (30 fps, 60
   gens/s); `jobs clips --sample` caps at 13 on a JACA-only job (A5); `--score` isn't shown in
   status (A6); `JETCARP_GPU=off` + `hunt --gpu` gives no note (A7).

For rc.2 on the Acer: re-run at least G1, G2 (371 scenes, all three adapters), A10 (with and without
`jobs seal`) and D (Fit with the new GPU timing, the rotation, the cards and picks), and A5 if
`clips --sample` changes.

## 2026-11-15 (08:52 UTC), main session: rc.2 is out; Phase 1 starts on all three

**v0.4.2-rc.2** is released (pre-release): https://github.com/jprodgers/jetcarp/releases/tag/v0.4.2-rc.2,
tag on 2d4b84c, CI green on Linux, Windows and macOS. Check each archive against the release's
`SHA256SUMS` (Linux x86_64: `29279d2a…050ae5`).

**Parity sets confirmed with rc.2's own Linux build** (FG): on the Framework's CPU it gives every hash in
`parity/expected.csv` (371 of 371) and `parity/long/expected.csv` (40 of 40), so neither file changed.
On the Framework, 1.1 and 1.2 pass on the Radeon and on llvmpipe (371/371 and 40/40, CPU and GPU).
The Framework's 1.6 hunt: 1,783 distinct, 760,892 objects (ships 51,012, osc 236,468, still 473,412).
Every machine's hunt must give these numbers.

**Phase 1 now, on each machine** ("How this wave runs" in `v0.4.2-rc.2.md`): one script that runs 1.1–1.4
and 1.6 in `jetcarp-rc-042b`, a line in the chat when it starts, quiet until it ends, then a
`NOTES.md` entry of 15 lines or fewer and the same summary in the chat. Not 1.5, not Phase 2.

Tips for the script, from the Framework's dry run:
- **1.4's hard kill:** `search explore --detach` runs the search as a process whose command line is
  `jetcarp jobs resume <job> --library … --quiet …` (not `search explore`). Kill that one:
  - Windows: `Get-CimInstance Win32_Process -Filter "Name='jetcarp.exe'" | Where-Object CommandLine -like "*jobs resume $job *" | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }`
  - Mac: `pkill -9 -f "jetcarp jobs resume $job "`
- `jobs wait <job>` exits 0 done, 3 paused, 4 failed, 5 still running at `--timeout`, 6 gone (killed). After
  the kill, `jobs status` should say it can be resumed; `jobs resume <job> --detach`, then poll.
- **1.4's counts:** the search's runs from `jobs status <job> --json` (`progress.screened` +
  `progress.confirmed`); the import's from `jobs --library <fresh>/library.sqlite runs <job> --limit 0
  --format csv` (lines minus the header; the imported job has its own id: find it with `--json jobs
  --library … list`). `pack key --name "rc.2 test publisher"` makes a throwaway key in the test
  settings folder; `pack export --to <folder> --feed rc2-long --no-media` packs the unsealed search.
- Use `--minutes` for explore budgets, not `--limit`: explore checks `--limit` once per step and
  overshoots (#47).
- New since the plan: #47 (explore `--limit` wording) and #48 (doctor self-tests a GL adapter when
  `JETCARP_GPU` is set; the Radeon's GL adapter fails it and is refused). Neither changes a step.

The Framework's own Phase 1 (F1, FG, 1.6, 1.4) started at 08:43 UTC; results go in
`results/v0.4.2-rc.2/framework/`.

## 2026-11-15 (09:58 UTC), main session: two notes for reading 1.4's results

- **Status right after the hard kill says `running`** for up to 45 s (#49): `jobs status` waits for a
  missed heartbeat before it calls a job gone, though `jobs resume` can take it at once. A script
  that checked within a minute of the kill and saw `running`, then resumed fine, has found #49, not a
  new bug. Record the status it saw and carry on.
- ~~Explore memory climbs for about the first hour, then levels off~~ **Wrong (corrected 13:30 UTC):**
  the Framework's resumed search kept growing past the grid cache's cap, to 7.3 GB at 4 h 14 min,
  still rising (#53). Record memory every few minutes; growth isn't a new bug unless it's far faster.

## 2026-11-15 (13:05 UTC), Acer: Phase 1 done (results/v0.4.2-rc.2/acer/)

- 0: pass. The hash matches; `jetcarp 0.4.2-rc.2`. doctor took 11.0 s, then 0.9 s with the self-tests kept.
- 1.1: pass on RTX Vulkan, RTX DX12, UHD Vulkan and UHD DX12: 371/371 CPU and GPU each, 334 all on the GPU.
- 1.2: pass on all four: 40/40 at 5,000 generations.
- 1.3 RTX: FAIL. 986 passed, 0 failed, 33 ignored, but `jetcarp-gpu`'s `tests\recovery.rs` crashed (0xC0000005) before reporting. 8 reruns of it passed.
- 1.3 UHD: pass. 988 passed, 0 failed, 33 ignored. But 1 of 3 later reruns of `recovery.rs` hung with both tests in flight (killed after 10 min).
- 1.4: pass except step 3. 261,392 runs in 2 h, never at 0/s (median 36/s). The pack (19.7 MB, no `jobs seal`) sealed every run, and the import has all 261,392.
- 1.4, step 3: `jobs status` still said `running` (stale false) 120 s after a second hard kill, while `jobs wait` said gone. That's longer than #49's 45 s.
- 1.4, two more findings:
  - `jobs wait` 0.2 s after `jobs resume --detach` said "no process runs it". My script then went to the pack early, and the pack refused the running job (#35 works).
  - `--minutes` doesn't carry over to `jobs resume`, so the plan's "resume it to the end" needs `--minutes`.
- 1.6: pass. 1,783 distinct, 760,892 objects: the same as the Framework.
- My mistake: a helper named `Rd` ran PowerShell's `rd` alias (`Remove-Item`) and deleted most of the test folder's logs. CSVs and status JSONs survived; the rest is rebuilt from printed copies, with gaps listed in notes.md.
- 1.5 and Phase 2 not started. Next: sitting A-1.

## 2026-11-15 (13:30 UTC), main session: the Acer's Phase 1 read; issues #49–#53

- **The Acer's Phase 1 passes** apart from the findings below: 1.1 and 1.2 on all four adapter/backend pairs,
  1.6 identical to the Framework, 1.4's unsealed pack carries all 261,392 runs (#35 fixed).
- Filed from it: **#50** (`jobs wait` just after `jobs resume --detach` says gone), **#51** (`--minutes` is per
  session, so a resume has no end; the Framework's resume ran 3 h 14 min more until stopped by hand),
  **#52** (`tests/recovery.rs` crashed once on the RTX, hung once on the UHD), and a correction on **#49**:
  `jobs status` uses a 5-minute stale rule, not 45 s.
- From the Framework: **#53**, a long explore's memory grows past the grid cache (7.3 GB at 4 h).
- None of these needs a machine to redo a step. The Acer goes on to Phase 2 (A-1) when Jimmie is ready;
  the Mac's Phase 1 is still running.

## 2026-11-15 (13:20 UTC), Mac: rc.2 Phase 1 done; nothing new failed
- **0:** the hash is right. First doctor on the fresh folder: passed (59 rules), saved, then "kept from before" (#17).
- **1.1 pass:** 371/371 on the CPU and Metal, 334 all on the GPU (71 s).
- **1.2 pass:** 40/40 at 5,000 generations, all on the GPU (64 s).
- **1.3 pass:** tag 2d4b84c, `cargo test --release --workspace`: 991 passed, 0 failed, 33 ignored (11.5 min).
- **1.6 pass:** 1,783 distinct, 760,892 objects; `finds` identical to the Framework's and the Acer's.
- **1.4 pass, apart from the known bugs.** 272,936 runs in the first hour; no 0/s in any of 239 samples (median 75/s).
  - `kill -9` at 60 min: `jobs wait` said gone (6) after 45 s, but `jobs status` still said running (#49).
  - The resume had no `--minutes`, so it ran on (#51) until the script's 4-hour cap: 1,120,514 + 17,733
    confirmation runs. Memory 5.5 GB at the kill, 7.5 GB at the end, still rising (#53).
  - The pack, with no `jobs seal`, "sealed its newest 138,247 runs first": 85 MB, check passes. The import has
    every run (1,120,514 + 17,733; #35 pass). Small: the import says 3,314 confirmed elites, the search 3,321.
- Homebrew's 0.4.1 and its folder untouched; nothing left running. Details: `results/v0.4.2-rc.2/mac/`.
- **Next:** Phase 2 (M-1) after the Acer's block; 1.5 when the Mac has 8 idle hours (Jimmie starts it).

## 2026-11-15 (13:45 UTC), main session: Phase 1 done on all three

**Every machine passes 1.1, 1.2 and 1.6;** 1.4 passes everywhere apart from known bugs; 1.3 passes on the Mac and
the Acer's UHD, and fails once on the Acer's RTX (#52).
- **1.6 is identical on all three** (1,783 distinct, 760,892 objects, the same finds): hunts are deterministic.
- **1.4:** every unsealed pack carries every run (#35 fixed everywhere). Known: #49 (status lag), #51 (`--minutes`
  per session), #53 (memory grows: 7.3 GB Framework, 7.5 GB Mac, ~1.2 GB Acer). New: **#54**, the import has
  0.2–0.5% fewer confirmed elites than the search, on all three.
- **Fixes on the branch since the tag:** #47, #48 (fad02f2). For rc.3 if the wave finds more.
- **The Framework is running a 3-hour memory experiment for #53** (default malloc vs `MALLOC_ARENA_MAX=2`), until
  about 16:15 UTC; results in `results/v0.4.2-rc.2/framework/53-*.csv`.

**Speed on the same work (for Jimmie's machine comparison):**

| | Framework | Mac | Acer |
|---|---|---|---|
| Explore, first hour (CPU + GPU) | 513,902 runs, 143/s | 272,936 runs, 76/s | ~125,000 runs, 35/s |
| Hunt 1.6 (120,000 soups) | 16,902 soups/s | 10,337 soups/s | 7,360 soups/s |
| Parity CPU, 40 scenes × 5,000 gens | 52 s | 59 s | 85 s |
| Parity GPU, 371 scenes × 300 gens (one process each) | 24 s (Radeon) | 18 s (Metal) | 334 s (RTX Vulkan), 942 s (RTX DX12) |

The Acer's GPU parity times are mostly process start: each `run --gpu` spends ~0.45 s (Vulkan) or ~2.2 s (DX12)
opening the GPU, against ~0.05 s on the others.

**Next:** Phase 2, the Acer's sitting A-1, when Jimmie is ready.

## 2026-11-15 (14:05 UTC), Acer: sitting A-1 done, every step passes (results/v0.4.2-rc.2/acer/)

- **Set-up:** Phase 2 runs on empty settings and an empty library. Phase 1's are moved to `jetcarp-rc-042b\phase1\`, so job numbers match the plan.
- **2.0:** pass. The fresh download's hash is right; `jetcarp 0.4.2-rc.2`.
  - #17: the first doctor "passed (521 ms)" and "(639 ms)", wrote `gpu-checks.json` with all five adapters, and took 10.4 s; the second said "kept from before" and took 0.8 s.
  - #21, #26 and #40 as the plan says.
- **2.G1:** pass. Each adapter was tested fresh: RTX Vulkan 230 ms, RTX DX12 2,659 ms, UHD Vulkan 392 ms, UHD DX12 2,880 ms, UHD GL 632 ms, all "59 world rules and 33 explore batches". `off` says "not used, and not tested".
- **2.1:** pass. 32,598 runs at 48/s on the RTX with no `--gpu`; 286 confirmed. 0/s only in the opening lines (#22), "(N of them confirmed)" in every line (#24). Jimmie: usable, no lag.
- **2.2:** pass. 30/30 replays on the CPU match to 6 decimals; 5/5 hashes are the same on the CPU, `--gpu` and no flag.
  - Side note: `penrose-rhomb` asked for 16,000 cells gives 35,000.
- **2.3:** pass. 66 confirmation runs, 18 confirmed. `jobs wait` gave exit 3 2.0 s after `jobs stop`, with the process gone, and the resume straight after was accepted (#16).
- **2.4:** pass. "parents: 500 JACA runs of explore job 2 (its best ones: it has no reviews …)" at the start and in status (#25). All seven origins, random 29.2%; `sign_*` filled.
- **Next:** A-2 (2.5–2.10); Jimmie rates about 24 clips.

## 2026-11-15 (14:45 UTC), Acer: sitting A-2 done (results/v0.4.2-rc.2/acer/)

- **2.5:** pass, with a finding.
  - `--sample 48` now gives 48 clips (#29).
  - The page's keys, reload, Save and light/dark all work; Jimmie: "works better than the Claude.ai page".
  - `review` counts right and adds nothing the second time; `--reviewed any` shows `[keep ★]`, `[maybe]` and `[drop]` (#33).
  - **Finding:** the stratified sample gave "Frozen at once" 20 of its 48 slots, though such runs are 12% of job 3. Jimmie dropped 40 of the 48 ("Way too many die almost immediately, or just turn into static").
- **2.6:** pass after a second round.
  - The refit refused clearly with 2 keeps (it needs 5).
  - Jimmie then rated 48 of the best-scored runs (11 keeps), and the refit gave a held-out AUC of 0.850.
  - The rescore rewrote job 3's confirmed count (92 → 67), and its status names the model (#36, #30). The scored search and its status name it too.
- **2.7:** pass. Exit codes 0, 3 and 6 as expected; the killed hunt shows as gone in 43.8 s.
  - #31: "the GPU was asked for, but JETCARP_GPU=off: running on the processor".
  - #32: one line during a 44 s wait (rc.1 printed 9 repeats).
- **2.8:** pass. V rules run with edge neighbours; the bad rules file is refused before any job, naming line 3; "30/30 soups in each of 6 groups".
- **2.9:** pass. Each rebuilt soup produces its ship (the MWSS only at 2,000+ generations, as in rc.1: #34). `--best 3` gives the same three soups as rc.1.
- **2.10:** pass, with a gap.
  - With no `jobs seal`, the export said "sealed its newest 13,524 runs first", and the import has every run (13,236 + 288) (#35). The imported line ends "not run here yet" (#37).
  - A running search with 2,112 runs is refused ("stop it first"). But **a running search with no runs stored yet exports silently**, as an empty search, and a refused export leaves an empty `--to` folder.
  - `A10-pack.zip` (1.21 MB) is committed. The Mac's and the Framework's packs are still to import.
- **Next:** A-3 (2.APP), hands-on.

## 2026-11-15 (1:15 PM EST), Framework: #53 explained; F10, F2 and F9 done; Acer A-3 rounds 1–7

- **#53, memory:** two stages (profiled with a counting allocator).
  - Up to the grid cache's cap, the memory is held by the cache, which costs about 87–94 bytes a cell, not 72. So its 32M-cell cap is about 3.0 GB.
  - Past the cap, the further growth is free memory glibc keeps (GPU batches free a few hundred MB, sometimes 2+ GB). One `malloc_trim(0)` took RSS from 1,086 to 330 MB.
  - Proposed for rc.3: a trim between steps every 30 s, and the cap's comment corrected. It needs a 2–4 h A/B before shipping. The Mac's 7.5 GB is still to check (`footprint` on the M2).
  - The fix is in a worktree (`.claude/worktrees/agent-a46f983771ae635dd`).
- **F10:** the Framework's pack, `framework/F10-pack.zip`, for the laptops to import. It has 99,177 runs and 341 patterns, all verified again on import; confirmed elites 818 → 816 (#54).
- **F2** (2.1–2.10, 2.12 on Linux): all pass. 2.5–2.6 ran on a copy of Jimmie's library; the refit on his 227 ratings gives held-out AUC 0.900. 2.6's first scored search stalled beside the profiling run, but it didn't happen again alone or beside a second search.
- **F9** (MCP, robustness): pass except for three findings:
  - a symlink in the output folder takes the MCP write tools outside (also in 0.4.1; private advisory GHSA-88q3-9mmf-m2xw);
  - MCP `world_new` with width × height skips its 4M limit (#63);
  - an in-server MCP job stays "running" after the server exits (#64).
  - Rough edges are #65–#68.
- **Acer A-3:**
  - 2.APP 1–7 pass: menus, pop-outs, AI control (#1), shortcuts, themes, Quick Start, save and reopen, PNG and GIF, every script example.
  - Findings: #58 (no exact grid size, so HashLife's in-place jump is out of reach), #59 (no GPU choice in the app), #60 ("Connections 0"), #61 (the Rule box shows an unapplied rule), #62 (no animation export of the world; Render media is hard to find).
  - Left in A-3: 2.APP 8 (an hour of a large JACA world).
- **Still to do on the Framework:** FD (headless GNOME), F4 and F7 with Jimmie, and importing the Mac's pack (F6).

## 2026-11-15 (19:35 UTC), Acer: sitting A-3 done (results/v0.4.2-rc.2/acer/)

- **2.APP 1–4:** pass. Every menu item, tool window and pane opened, popped out and back, with no crash. AI control (#1): on, it serves on 127.0.0.1:47811; after a restart with no world it opens off and serves once ticked. Every shortcut works, and so do light, dark and the window sizes. Findings: #58 (no exact grid size, so no HashLife jump in place), #59 (no GPU choice), #60.
- **2.APP 5:** pass. Quick Start from every category; edit, save and reopen; `verify` ok. Finding #61: the Rule box shows a typed rule that isn't applied until Enter (Jimmie was caught by it).
- **2.APP 6:** PNG and GIF pass (40 GIFs from Render media, found only after picking a hunt). No WebP from the GUI; the CLI's `--format webp` plays (#62).
- **2.APP 7:** all 7 scripting examples run; hexw3-atlas writes 19,683 PNGs in 136 s.
- **2.APP 8:** pass. A 4-million-cell JACA world ran 65 min at 12.2–12.7 gens/s in every 10 minutes, with private memory flat at 655–663 MB.
- **2.11 (A11):** pass. The signs are easy to tell apart (−1 is Koi, cream → orange); nothing worse than 0.4.1.
  - **Finding:** the app simulates on the **Intel UHD** (the hover names it), as in rc.1's D2.
  - On a 4-million-cell Life world that's slower than the CPU (21 vs 27 gens/s); JACA is no faster on it (12.4 vs 12–13).
  - The CLI jobs use the RTX.
- I measured speed with `mcppoll.ps1`: `world_status` over one `mcp --app` link, plus status-bar screenshots.
- Still open: importing `framework/F10-pack.zip` (now committed) and the Mac's pack. 2.12 isn't in any sitting.
- **Next:** A-4 (2.D 1–7), hands-on.

## 2026-11-15 (3:30 PM EST): rc.3's fixes on the branch; the plan approved

- `release-0.4.2` at aa0b6ef has every rc.2 fix that fits: #47–#54, #56–#69 (#52 hardened, not yet proven on Windows), and the private advisory. #55 and #71 go to 0.4.3, with #28, #34 and #70.
- The suite: 1,016 passed and 1 failed (`tools/list` over its byte budget, fixed). CI is running on aa0b6ef.
- The #53 A/B at 1 h: rc.2 2.06 GB, the fix 1.34 GB for the same work. It ends at 5:20 PM.
- **Jimmie:** `v0.4.2-rc.3.md` is "sound". The Acer finishes A-4 and A-5 on rc.2, then rc.3 is tagged if nothing else turns up.

## 2026-11-15 (20:50 UTC), Acer: sitting A-4 done (results/v0.4.2-rc.2/acer/)

- **Setup as rc.1's D:** the everyday 0.4.1 host wasn't running, and the wallpaper was saved. The candidate's host ran from the test folder, on the Intel UHD.
- **2.D 1 (#41):** pass. Show just this scene switched the desktop and saved a rotation and its profile; the screen saver's choice is unchanged.
- **2.D 2 (#41):** pass. New, Save ("easy to find") and Edit work. Small finding: a Quick Start entry is added only by typing its id; there's no picker.
- **2.D 3 (#42):** pass.
  - Life at 60 fps = 60 gens/s, and the blinkers are "even and steady".
  - The ant draws 60 fps for 240 gens/s, or 144 fps with `max-fps refresh` (UHD 38% → 78%).
  - Low power: 30 = 30, with the UHD share about halved.
- **2.D 4 (#38):** the sweep works now: 3 scenes × 8 sizes, 16 → 1 px, from the pane and `host tune --json`, and Recommended is the finest within limits.
  - **Fails the timing check:** `gpu_timing` is "submission" (the UHD device has no timestamp queries).
  - Its GPU shares are 3–10× Windows' (3 px: 70% against 20%). Since rc.2 doesn't judge them, the GPU limit isn't applied (a recommended 2 px uses 31% of the UHD, against 25%).
  - Also, an automatic fit (`tune.auto`) left a stale card row from another rotation.
- **2.D 5 (#39):** pass. `--pick 4`, `own` and `2`, and the pane's "Use the scenes' own sizes", all place every scene. Each pick re-runs the 50 s sweep.
- **2.D 6:** the overrides take effect (host CPU 14–18% when off), and doctor is right each time. Gap: `host status` keeps its start-up GPU note (as in rc.1).
- **2.D 7:** pass. A busy CPU hunt, a full-screen video (Chrome) and battery each pause the host, and it resumes after each. Small: `paused` stays false while `paused_why` gives the reason.
- **Put back:** host stopped; the wallpaper is identical (same hash); no `Run` value, no screen saver.
- **Next:** A-5 (2.D 8–12 and 5.4), hands-on.

## 2026-11-15 (21:30 UTC), Acer: sitting A-5 done (results/v0.4.2-rc.2/acer/)

- **2.D 8 (sleep and wake):** pass. The host held before sleeping and on the sign-in screen, then resumed 2 s after sign-in, in the same process.
- **2.D 9 (lock):** pass. Held while locked, resumed on unlock. The lock screen shows Windows' picture.
- **2.D 12 (host crash):** pass. A hard kill leaves the user's own wallpaper, and `host start` brings the desktop back live.
  - Note: with `host still on`, a crash also leaves the own picture (no still). Only a clean `host stop` leaves the still, and `still off` restores the own picture.
- **5.4 (driver reset):** inconclusive. Win+Ctrl+Shift+B beeped on the second try, but the host and the app ran straight through: no gap, no note. So no device loss was seen, and the recovery path wasn't exercised. A real timeout needs admin tools.
- **2.D 10–11 ran in Jimmie's own account with the default folders**, his choice ("only for testing … I'll be reinstalling once 0.4.2 ships"). Windows starts both with no `JETCARP_*` variables.
- **2.D 11 (screen saver):** pass. It showed the chosen rotation (Wolfram series). `saver remove` refuses clearly while Screen Saver Settings is open; after closing it, the saver is removed and `SCRNSAVE.EXE` is empty again.
- **2.D 10 (start at login):** pass. After signing out and in, the host started with the saved rotation; the session resumed after the logout.
  - It started 97 s after sign-in, because Windows runs the Run entries one at a time with 30 s waits (another program, another program).
  - JETCARP's launcher stays as the host's parent, so Windows also waits 30 s on it.
- **Put back:** login off, no screen saver, the host stopped, and the wallpaper identical. The everyday settings folder is restored from a copy; the everyday library was never written.
- **For later waves:** the host's lock (`host.lock`) follows `JETCARP_RUNTIME_DIR`, which test setups don't set. Test hosts therefore wrote it into `%LOCALAPPDATA%\jetcarp`, so there's one host per user whatever the folders.
- **Next:** A-6 (Parts 4 and 5: MCP, robustness).

## 2026-11-15 (7:05 PM EST), main session: rc.3 is out; Phase 1 starts on all three

**v0.4.2-rc.3** is released (pre-release): https://github.com/jprodgers/jetcarp/releases/tag/v0.4.2-rc.3.
Tag on 400d41d; CI green on Linux, Windows and macOS. Check each archive against the release's `SHA256SUMS`:
- Windows: `jetcarp-0.4.2-rc.3-x86_64-pc-windows-msvc.zip`, `002e42d2…74ec9e39`
- Mac: `jetcarp-0.4.2-rc.3-aarch64-apple-darwin.tar.gz`, `2125d411…ba39daac`
- Linux: `5199040f…7179d539` (checked on the Framework: OK, `jetcarp 0.4.2-rc.3`)

**What to run:** `v0.4.2-rc.3.md`. Phase 1 again, unattended, on each machine:
- 1.1, 1.2 parity (371 and 40 scenes; `expected.csv` unchanged, as rc.3 changes no stepping);
- 1.3, the suite;
- 1.4, now **240 minutes**: kill at about an hour, then resume with **no** `--minutes`;
- 1.6, the hunt.

The steps are as in rc.2's plan, with rc.3's checks:
- **1.4:**
  - Log memory every 5 minutes. #53: Linux should stay near 3 GB; macOS isn't fixed, so record it for comparison.
  - `jobs status` within seconds of the hard kill should say **stale** (#49), not running.
  - `jobs wait <job> --timeout 2` straight after `jobs resume <job> --detach` should exit **5** (still running; #50).
  - The resume with no budget should end at about 240 minutes in all, not run on (#51).
  - The pack and import should have the **same confirmed count** on both sides (#54).
- **1.4 on the Mac, #53's open question:** at about 1 h (just before the kill) and at the end, also
  save `footprint <pid>` and `vmmap --summary <pid>` for the search's process, the one whose command
  line is `jetcarp jobs resume <job> …`. They separate the memory the search holds from free memory
  macOS's allocator keeps; rc.2's Mac reached 7.5 GB, and the Linux fix (`malloc_trim`) does nothing
  on macOS.
- **1.3 on the Acer, #52:** after the suite, from a clone of the tag, run `cargo test --release -p jetcarp-gpu --test recovery` **30 times** with `JETCARP_GPU=RTX`, then 30 with `JETCARP_GPU=UHD`.
  - Pass: no crash, no hang. Each run takes about 10 s; kill any run past 2 minutes and count it as a hang.
- **Folders:** the laptops may use their **default folders** (Jimmie: test-only installs). The Framework stays isolated.

Then Phase 2, as in the plan:
- the Acer: A-6 to A-8 and 1.5;
- the Mac: M-1 to M-8;
- every machine: R, a check of every fix.

The Framework's Phase 1 started at 7:01 PM EST (`results/v0.4.2-rc.3/framework/`).

**Parity confirmed with rc.3's own Linux build** (7:06 PM):
- 1.1: 371 of 371 on the CPU and the GPU, on the Radeon and on llvmpipe.
- 1.2: 40 of 40 at 5,000 generations, all on the GPU. So `expected.csv` and `long/expected.csv` are unchanged.
- **1.6 hunt:** 1,783 distinct, 760,892 objects (ships 51,012, osc 236,468, still 473,412), identical to rc.2. Every machine's hunt must give these numbers.

**The Framework's Phase 1 ended at 11:07 PM: every step passes** (`results/v0.4.2-rc.3/framework/summary.md`).
- #48, #49 (stale 2 s after the kill), #50 (exit 5), #51 (the resume ended at 3 h 59 min in all) and #54 (4,943 confirmed on both sides).
- #53: 3.6 GB at 4 h for 2.1M runs. At a million runs that matches the rc.2 A/B's fixed build.
- New: **#81** (0.4.3). After the resume, memory briefly peaked at 5–6.3 GB, twice its steady level. That matters only for a `--max-rss-gb` cap set close to the steady level.
- #80 (macOS memory readings use the physical footprint) is pushed to `release-0.4.2` for rc.4.

**rc.4 work while the laptops run (11:15 PM):**
- The book's Desktop background cards picture was redrawn from a real Fit sweep, in a private headless GNOME shell on a 2560 × 1440 virtual monitor. The new picture matches the book's: the same rotation (A classic a day), the same scenes in the same order, only small changes in the measured numbers. So the picture was already right after #73 and is unchanged. (`~/Documents/jetcarp-dev/work/0.4.2-rc3/cards/`; Jimmie's real GNOME settings checked before and after: unchanged.)
- The planted-link item ("Not fixed yet" in `v0.4.2-rc.3.md`) is being built for rc.4 in a worktree, not pushed until reviewed.


## 2026-11-16 (04:45 UTC), Mac: rc.3 Phase 1 done, every step passes (results/v0.4.2-rc.3/mac/)

- **0:** the hash matches `SHA256SUMS` and the start note; `jetcarp 0.4.2-rc.3`; doctor "passed (191 ms)", then "kept from before".
- **1.6:** 1,783 distinct, 760,892 objects; every group identical to rc.2. **1.1:** 371/371 on Metal. **1.2:** 40/40 at 5,000 gens.
- **1.3:** tag 400d41d, 1,027 passed, 0 failed, 33 ignored (11 min).
- **1.4:** 1,142,553 + 17,664 runs in 240 min, median 78/s, 0/s once (5 s after the resume, #22's opening line).
  - #49: `stale: true` 1.2 s after `kill -9`, in `jobs status` and `jobs list`. #50: `jobs wait --timeout 2` after the resume exited 5.
  - #51: the resume said "2 h 59 min left of its 4 h 0 min" and ended by itself at 239.6 min. #35: the 86 MB unsealed pack and the import have every row.
  - #54: confirmed elites 3,327 in the search and 3,327 in the import.
- **#53 on macOS (footprint and vmmap at 1, 2, 3 and 4 h):** the RSS grew to 8.6 GB (rc.2: 7.5 GB), but the physical footprint stayed at 0.5–1.7 GB.
  - The gap is freed Malloc Small pages the allocator keeps as "reclaimable" (5.2 GB at 1 h, 7.9 GB at the end). The search holds about 1.5 GB, and nothing grows steadily. This supports #80.
- My mistake: a bash 3.2 quirk left the script's status readings empty for 1.4's first 4 min. I restarted the script only, adopting the running search; the results are unaffected.
- **Next:** Phase 2 (M-1 to M-8) and R when Jimmie is ready; 1.5 needs 8 idle hours.

**1:20 AM: the Acer's Phase 1 is in** (all pass but #52 on the UHD: 1 hang in 30, no crash in 60). The changelog is corrected, the data is posted on #52, and #82 and #83 are filed. **R on the Framework (the unattended rows) passes**; its one straggler, #57's hidden store, is fixed in efe1a03 (`results/v0.4.2-rc.3/framework/R/summary.md`). Jimmie is on the Mac's Phase 2. 1.5 on the Mac goes in rc.4's wave, since #80 changes the macOS host's memory check.

## 2026-11-16 (06:15 UTC), Acer: rc.3 Phase 1 done; all pass except #52 on the UHD (results/v0.4.2-rc.3/acer/)

- **0:** the hash matches `SHA256SUMS` and the start note; `jetcarp 0.4.2-rc.3`. **1.6:** 1,783 distinct, 760,892 objects, as everywhere.
- **1.1:** 371/371 on RTX and UHD, Vulkan and DX12. **1.2:** 40/40 at 5,000 gens on all four. Small finding: on RTX DX12, one process of 335 found no RTX ("no RTX adapter was found, so the best one") and ran on the UHD; its hash matched.
- **1.3:** tag 400d41d, 1,018 passed, 0 failed, 33 ignored, with `JETCARP_GPU=RTX` (24 min) and `UHD` (13 min).
- **#52: RTX pass** (30 of 30 runs ok, no crash). **UHD fail:** 29 of 30 ok; run 4 hung after "running 2 tests" (killed at 2 min), as in rc.2.
  - Follow-up: 30 more UHD runs with `--test-threads=1` all passed. So far the hang has come only with both tests in flight at once (suggestive, not proof).
- **1.4:** 574,607 runs in 240 min, median 39/s. One 0/s mid-run, at 7.4 min, for about a minute, while confirmed elites jumped 106 → 155.
  - #49: `stale: true` 1.1 s after the kill (text: "status stale"); `jobs list` stale; `jobs wait` exit 6 at once. #50: exit 5.
  - #51: "2 h 59 min left of its 4 h 0 min"; it ended by itself at 239.0 min, `paused`. #35: every row in the 42.7 MB unsealed pack. #54: 1,953 = 1,953.
  - Memory on Windows (no #53 fix here): status 1.14 GB at 1 h, 0.94 at 2 h, 1.25 at the end; private bytes peaked at 3.45 GB (215 min). No #81-style peak after the resume.
- Test folder `jetcarp-rc-042c`, with `JETCARP_RUNTIME_DIR`; the everyday 0.4.1 and the desktop untouched.
- **Next:** Phase 2 on rc.3 (A-6, A-7, A-8, R) when Jimmie is ready; 1.5 needs 8 idle hours.

## 2026-11-16 (06:50 UTC), Mac: rc.3 sitting M-1 done, every step passes (results/v0.4.2-rc.3/mac/)

- **Set-up:** Phase 2 runs on empty settings and an empty library in `~/jetcarp-rc-042c`. Phase 1's are moved to `phase1/`, so job numbers match the plan.
- **2.0:** pass. The fresh download is identical to `bin`; `jetcarp 0.4.2-rc.3`.
  - #17: "passed (185 ms)", then "kept from before". #21's fallback note is right, with the expected hash. #26 lists `WGPU_BACKEND=metal`. #40 says who simulates on each. R #47's help is right.
- **2.G1:** pass. "59 world rules and 33 explore batches", automatic, with `JETCARP_GPU=M2`, and with `Apple` + Metal.
- **2.1:** pass. 57,109 runs at 103/s on Metal with no `--gpu`; 419 confirmed. 0/s only in the opening line (#22); "(N of them confirmed)" in every line (#24). Jimmie: "Usable, no lag".
- **2.2:** pass. 30/30 replays match to 6 decimals; 5/5 hashes are the same on the CPU, `--gpu` and no flag.
- **2.3:** pass. 21 confirmed. `jobs wait` exit 3 1.15 s after `jobs stop`, the process gone; the resume straight after was accepted (#16).
- **2.4:** pass. #25's parents line at the start and in status; all seven origins, random 28.4%; `sign_*` filled.
- **Small findings:**
  - With `JETCARP_GPU=off`, doctor says "not used, and not tested", but it runs the self-test and writes `gpu-checks.json`.
  - `jetcarp paths` doesn't name the runtime folder.
- **Next:** M-2 (2.5–2.10). Jimmie rates clips in Safari and Chrome.
- **Main session:** both M-1 findings are filed and fixed for rc.4 in 25bc949: #84 (doctor with the GPU off now tests no adapter and writes no `gpu-checks.json`) and #85 (`jetcarp paths` and doctor name the runtime folder).


## 2026-11-16 (07:30 UTC), Mac: rc.3 sitting M-2 done, every step passes (results/v0.4.2-rc.3/mac/)

- **2.5:** pass. R #56: 48 clips, "categories: Battles 48"; no slots for Frozen at once, Quick deaths, Static or Quiet.
  - Safari: keys, reload, Save and light/dark all work; Chrome works (Jimmie didn't press Save there).
  - `review` counts right and adds nothing the second time; #33's `[keep ★]` and the rest show.
  - Jimmie: 4 keep, 29 drop, "Lots of static": the caps took the dead and frozen runs out, but many "Battles" look like static.
- **2.6:** pass after three rounds.
  - The first refit refused clearly (4 keeps). The top 48 by score gave 0 keeps ("One of the worst sets yet"). Then 144 broad clips (Jimmie's idea: "48 is a small sample") gave 3 more.
  - The refit on 239 ratings: **held-out AUC 0.806; the built-in score 0.468**, worse than chance on this search. Its top terms: `sign_sorted` up, `sign_trade` down.
  - Rescore: 243 → 173 confirmed, and status names the model (#30, #36). The scored search names it too.
- **2.7:** pass. Exit codes 0, 3 and 6. The `kill -9`'d hunt is stale 0.1 s later, and `jobs wait` gives 6 at once (rc.2: 44 s). #31's note.
- **2.8:** pass. V rules run with edge neighbours; the bad rules file is refused before any job, naming line 3; "in each of 6 groups".
- **2.9:** pass. The six ships appear at the Acer's generations; `--best 3` gives soups 4526, 7794 and 9324, as everywhere.
- **2.10:** pass.
  - The unsealed export carries every run, and the import's rows are identical. R #54: 173 = 173.
  - R #57: a running search is refused both empty and with 4,096 runs, leaving no `--to` folder. An empty hidden `.store` is left (fixed for rc.4).
  - `M10-pack.zip` is committed; the Acer's and the Framework's rc.2 packs import on macOS.
- **Next:** M-3 (2.APP, 2.11; R #58–#62), hands-on.
- **Main session (M-2):** "Lots of static" had a cause. Every JACA run that didn't die was categorized Battles, settled ones too, so the #56 caps never applied to a JACA round. Of the 61 settled clips Jimmie rated (fate cycle or froze), none was kept. Filed and fixed for rc.4 as #86 (950b2cb): a JACA run is a Battle while it is still going, and Static once settled.


## 2026-11-16 (08:45 UTC), Mac: a serious finding in M-3 (the app stops when its window is hidden)

- **On macOS the app does nothing while its window is hidden:** minimised, fully covered, or in another Space.
  - The simulation pauses (0% CPU; under 1 gen/s against 15 in view), and AI control requests from `jetcarp mcp --app` wait until the window shows again (23–73 s in our tests).
  - The cause: the world steps, and AI control is answered "once per frame on the UI thread" (`ai_control.rs` line 87), and macOS gives a hidden window no frames.
- **Jimmie:** "I need to be able to set up tasks and alt-tab away while things are running on the MCP."
- Details and the measured table are in `results/v0.4.2-rc.3/mac/notes.md` (2.APP 2). Still to check: Windows and Linux minimised, and `jetcarp mcp` without `--app` with the app hidden (M-6).
- **M-3 so far:** 2.APP 1 passes, and so do R #58 (with a finding: the Jump menu's number field closes on click, so only the default 1,000 can be jumped), R #60, R #62 and 2.APP 2.
  - Another finding: View → Keep awake isn't implemented on macOS.

## 2026-11-16 (4:20 AM EST), main session: M-3's findings fixed on the branch (5fcef69); a check for the Mac

Filed and fixed for rc.4:
- **#87:** the app's AI control and running world now go on behind a hidden window. They run in eframe's `App::logic`, which runs while hidden, paced at 100 to 250 ms. On Linux, visible behaviour is unchanged (measured in GNOME's headless shell: the same generations and answer times as rc.3). GNOME didn't withhold frames from a covered window there, so **the hidden case needs the Mac**.
- **#88:** Run → Jump's Generations field takes clicks and typing. An offscreen test types `2^20`.
- **#89:** View → Keep awake on macOS takes an IOKit power assertion. It was type-checked here only.

**For the Mac (before M-4, about 15 minutes):** build the branch and repeat 2.APP 2's measurement.
1. In the tag clone from 1.3: `git fetch origin && git checkout origin/release-0.4.2` (5fcef69 or later), then `cargo build --release -p jetcarp`.
2. Run that `target/release/jetcarp` (no arguments) with `env2.sh`'s folders. Open a running JACA Quick Start world, and switch on AI control.
3. `mcppoll.py` as in `2.APP-mcp-4.txt`, with `appmon.sh`: visible about 20 s, ⌘M about 30 s, restored, then covered fully by another window about 60 s, then visible.
   - Pass: `world_status` keeps answering within a second or so, and the generation keeps climbing near the visible rate (at least several gens/s) while minimised and while covered.
   - If it still stalls only after a while, note when: macOS's App Nap may be slowing a hidden app, which is the next thing to handle.
4. Keep awake: View → Keep awake on, then `pmset -g assertions | grep -i -A1 jetcarp` shows a NoDisplaySleep assertion. Turn it off, and the assertion is gone.
5. Run → Jump: click the Generations field, type `2^20`, then Jump ahead (HashLife) on Life 256 × 256 with wrap edges. `verify` on the saved scene shows generation 1048576.
- **Main session (5:10 AM):** the rest of M-3's findings are fixed on the branch (a45a29a).
  - #90: a rule being typed applies on leaving the window and before Save.
  - #91: Quick Start is ⌘⇧H, and Full screen is ⌃⌘F on macOS.
  - The Mac's 15-minute check above now covers these too. Build a45a29a or later. ⌘⇧H opens the Quick Start, and ⌃⌘F goes full screen. Type a rule in the Rule box, click into another app, come back, and ⌘S: the saved scene has the typed rule.

## 2026-11-16 (5:35 AM EST), main session: this repository is now published (less what's withheld)

Jimmie asked for a cleaned-up public copy of the test results. It is **https://github.com/jprodgers/jetcarp-testing**, regenerated by `tools/publish_public.py`. **Everything committed here will be published** after each wave, except the private security problem's records (until 0.4.2 ships) and other programs' names on the machines. So, more than before: no tokens, passwords or personal files in logs or screenshots, and crop or skip any screenshot showing other apps. The book's *How JETCARP is tested* links the public copy.


## 2026-11-16 (11:05 UTC), Mac: sitting M-3 done (the app); the 5fcef69 check passes (results/v0.4.2-rc.3/mac/)

- **2.APP 1:** pass. Three rounds over every menu, tool window and pane from the menu table; every pop-out went out and back. The saved scene and PNGs pass `verify`.
- **R #58:** pass. Width × height makes 256 × 256; HashLife's jump in place gives the same live cells as stepping.
- **R #59:** pass. The GPU adapter menu saves the choice.
- **R #60:** pass. "Open connections 2".
- **R #61:** pass. A click on the grid applies the rule; Esc restores it.
  - The first try didn't apply. Perhaps a click outside the app, then ⌘S: worth applying a pending rule on window blur or before Save.
- **R #62:** pass. Export animation makes a GIF and a WebP, and both play.
- **2.APP 2:** pass. The rc.3 app stopped while hidden (#87, noted at 08:45).
- **2.APP 3–7:** pass, with two findings: **⌘H hides the app on macOS** (Quick Start's key), and **F11 shows the desktop** (Full screen's key). The 7 script examples all run.
- **2.11:** pass. Koi against Tide is easy to tell apart.
  - Life 2048 × 2048: GPU 330 gens/s, CPU 40.
  - JACA Cairo at 4M cells: GPU 130, CPU 17. The M2 Max's GPU is 7–8 times its CPU.
- **2.APP 8:** pass. JACA Cairo at 4M cells for 61 min: 127.3 gens/s (125–128 in every 10 min), memory flat at 557–576 MB.
- **The 5fcef69 check:** all three pass.
  - #87: minimised and fully covered, AI control answered every 2 s, and the world kept 15 gens/s. Side note: covered, the app used ≈ 99% of a core, against ≈ 50% in view.
  - #88: `2^20` typed in Jump's field; `verify` gives generation 1048576.
  - #89: Keep awake on lists `NoDisplaySleepAssertion "JETCARP is showing cellular automata"`, and off removes it.
- **Next:** M-4 (2.D 1–7, the desktop background; R #69, #73–#76), hands-on.

## 2026-11-16 (6:05 AM EST), main session: #87's CPU while covered

The Mac's check passed (#87, #88, #89 at 5fcef69). Its side note, about 99% of a core while covered, is fixed in **bf6f64f**: while the window is hidden, a running world asks for the next pass 50 ms on, not at once. macOS delivers redraws to a covered window, and eframe then ran logic-only passes back to back.

**For the Mac, when convenient (5 minutes):** build bf6f64f or later, then repeat the covered phase with `appmon.sh`. Pass: AI control still answers within a second or two, the world keeps near its visible speed, and the app's CPU while covered is well under a core (well below the 50% in view, ideally).

## 2026-11-16 (11:55 UTC), Mac: sitting M-4 done, the desktop background (results/v0.4.2-rc.3/mac/)

- **2.D 1–2:** pass. Show just this scene switched the desktop and saved a rotation and its profile; the screen saver's choice was unchanged. "My rotation" was made, saved, shown and edited. R #74: the Quick Start item came from the search box.
- **2.D 3:** pass. Life at 60 fps = 60 gens/s ("Blinkers are even and steady"); the turmite at 60 fps, or 120 with `max-fps refresh`; low power 30 = 30, with the host's CPU halved.
- **2.D 4:** the sweep works, 32 → 2 px for 3 scenes (1 px never tried), and Recommended is the finest within the limits.
  - On the M2 Max only the processor is judged. `gpu_timing: submission`, and the pane says plainly that the GPU limit isn't applied (R #72's wording). Activity Monitor puts the host at **30% of the GPU at 6 px, over the 25% limit**.
  - The 4 px rungs sit at the CPU line (7.3–8.3% against 8.0%), so Recommended flips between sweeps. Jimmie preferred 4 px to the recommended 6.
  - R #69: pass, 146 → 162 MB over six sweeps. R #73 waits for M-8 (only a monitor change triggers an automatic fit).
  - Jimmie saw a fit "restarting" with "Measure again…" ticked. My one-second log showed no fit running while the rotation alternated 6 px and 4 px scenes. Unresolved.
- **2.D 5:** pass. `--pick 4`, `3`, `own` and the pane's own-sizes button all place every scene. Each pick re-runs the 56 s sweep.
- **2.D 6:** pass. **R #75: `host status` names each screen's simulation and its reason after every override change**, and doctor agrees. Off moves the host to ~2 cores.
- **2.D 7:** pass. A busy processor, a full-screen video and battery each held the host, and it resumed after each. **R #76: "held: on battery (resumes by itself)"** and the like, in the text and in the JSON.
- **Put back:** the host is stopped. The wallpaper's three choices are identical to before (macOS only updated its "LastUse" bookkeeping).
- **Next:** M-5 (2.D 8–12: sleep, lock, login, screen saver, host crash).

## 2026-11-16 (11:58 UTC), Mac: bf6f64f's recheck passes (#87 covered)

Built 5def684 (with bf6f64f) and repeated the covered phase on a running JACA world. Fully covered for about 85 s:
- AI control answered every 2 s, with no gap;
- the world kept 15.0–15.1 gens/s, the same as in view;
- **the app's CPU was 2–5%**, against 22–49% in view (5fcef69: about 99%).

Details are in `results/v0.4.2-rc.3/mac/notes.md`. Next on the Mac: M-5 (2.D 8–12), after Jimmie checks in with the main session.

## 2026-11-16 (12:25 UTC), Mac: sitting M-5 done, 2.D 8–12 (results/v0.4.2-rc.3/mac/)

- **2.D 8:** pass. The host held before sleeping and on the sign-in screen, then resumed 11 s after waking, in the same process.
- **2.D 9:** pass, with a finding. The host held while locked; the lock screen shows macOS's own picture.
  - **Finding: when the display turns off while the Mac is locked, the host stops holding and runs** (≈ 63 gens/s, 7–13% CPU) until the screen comes back on.
- **2.D 12:** pass.
  - `kill -9` leaves the user's own wallpaper; `host start` is live again in 1.2 s.
  - `still on` + crash leaves the own picture. `still on` + a clean stop sets a still of Life. `still off` puts the own picture back.
- **2.D 11** (default folders): pass. `saver install` builds a signed `JETCARP.saver` with the rotation inside, and it showed the Wolfram series.
  - `saver remove` works even with System Settings open, and puts the previous screen saver back.
- **2.D 10** (default folders): pass. `login on` writes a LaunchAgent, and **the host started 1 s after login** with the saved "Classics, hourly".
  - `login off` removes the agent. Small: launchd keeps the job loaded until logout.
- **Finding:** a host started in the default folders runs rc.3's **built-in sync on the everyday library**: `builtin_version` 0.4.1 → 0.4.2-rc.3, plus Quick Start rows and engine pins. No schema change.
  - The everyday folder is restored from a backup, and is identical to before. The wallpaper is unchanged too.
- **Next:** M-6 (Parts 4–5, MCP and robustness, with `jetcarp mcp` tested while the app is hidden), mostly unattended.

## 2026-11-16 (7:19 AM EST), main session: M-5's lock finding fixed on the branch (#95, 7e1bbc3)

- **#95:** while every display is asleep, the macOS host now also holds `dark` (`CGDisplayIsAsleep`), locked or not. A locked Mac's sleeping display read as neither locked nor covered. Type-checked only.
- **For the Mac, after M-5 (5 minutes):** build 7e1bbc3 or later and run its host from the test folder with the wallpaper on. Lock (⌃⌘Q), then `pmset displaysleepnow` from an SSH session or a delayed script (`sleep 5; pmset displaysleepnow`), or wait for the display to sleep. Pass: `host status --json` stays `held` (`dark`) throughout, and the generation doesn't move until unlock.
- Also: CI failed once on 5def684 (the MCP reference didn't list the new book page as a resource); fixed in 5c30d53.

## 2026-11-16 (7:30 AM EST), main session: recording part 4.2 (M-6, A-6) now that this repository is published

The public copy (`tools/publish_public.py`) withholds the private security problem's records until 0.4.2 ships. So that it catches yours:
- **Name every file of part 4.2** (the MCP folder rules, the link check included) with a `4.2` prefix, as in `4.2-folders.txt` and `4.2b-….txt`. Name its scripts with a `t42` prefix.
- **In `notes.md`, `progress.md` and the plan's tables, write the private check's result only as** "(private) part 4.2: pass" (or fail), pointing at its files. Describe what happened only inside the `4.2*` files, never in prose elsewhere: the filter withholds a whole paragraph or list item that names it, but a sentence that describes it without naming it would get through.
- Ordinary folder-rule refusals in other parts (read-only folders, `--allow`, outside paths) are fine anywhere.


## 2026-11-16 (12:35 UTC), Mac: 7e1bbc3's #95 check fails; macOS reports asleep and locked, but the host runs

- **The check:** built 7e1bbc3 and ran its host from the test folder (wallpaper on). The Mac was locked, then `pmset displaysleepnow` ran 5 s later.
  - In two runs the host held while locked, then **dropped its hold about 4 s after the display slept and ran** (e.g. generation 3,376 → 4,793 in 25 s), still locked.
  - It held again when the display came back on the lock screen.
- **A probe logged what macOS reports every second.** While the display slept, `CGDisplayIsAsleep` = 1 (active 0) and the session's `CGSSessionScreenIsLocked` = 1, the same key `locked()` reads; `ioreg`'s console flag said locked too.
  - So both `displays_asleep()` and `locked()` should be true, and the hold is dropped anyway. The fault is in how the host combines them, not in the detection.
  - The comment in `desktop_mac.rs` ("the session no longer reads as locked") doesn't match this Mac.
- Details and the probe are in `results/v0.4.2-rc.3/mac/` (`95-check.txt`, `95-probe.{swift,sh,txt}`, notes).

## 2026-11-16 (7:33 AM EST), main session: #95 again (67a08a6), after the Mac's probe

Thanks for the probe: it showed the detection was right, and my comment wrong. Both holds ("covered" and "dark") let go in the same second, and both asked for a wallpaper window being shown. So my reading is that while the display slept the host had no wallpaper window, perhaps because macOS took the monitors away and the host's windows with them.
- **67a08a6:** "dark" now holds while a wallpaper is wanted and nothing of it can be seen: locked, every display asleep, **or no wallpaper window at all**. No display online counts as asleep.
- **For the Mac:** the same check on 67a08a6 or later. Please also log each second the text of `host status` (its `monitors:` and `wallpaper:` lines, and the screen line), so we can see whether the windows and monitors really go away while the display sleeps. Pass: held (`dark`) throughout the sleep, and the generation unchanged until unlock; then live again after unlock.


## 2026-11-16 (12:42 UTC), Mac: 67a08a6's #95 check passes

- **The check:** 67a08a6's host from the test folder, wallpaper on. Locked, then the display put to sleep 5 s later (`pmset displaysleepnow`), then woken and unlocked.
- **The result:** the host stayed held (`dark`) throughout, and **the generation stayed at 2,033 from the lock to the unlock** (26 s of display sleep). It was live again a second after unlocking.
- **The main session's reading is confirmed:** `host status` lost its `monitors:` line from 3 s after the display slept until 2 s after it woke. So the host had no wallpaper window then, and the new rule kept it held.
- Details are in `results/v0.4.2-rc.3/mac/` (`95b-probe.{sh,txt}`, notes).

## 2026-11-16 (13:30 UTC), Mac: sitting M-6 done, Parts 4 and 5 (results/v0.4.2-rc.3/mac/M6/)

- **How:** the Framework's R and F9 scripts, pointed at the Mac (paths, `stat -f`, 12 threads, `ru_maxrss` in bytes). The unattended part took 4 min; then the app and host parts with Jimmie.
- **4.1:** pass. Every tool; `pack publish` refuses without `jetcarp pack key`, as designed.
  - `host_control` drives a test host (next, pause, resume, rotation, scene).
  - `use_app` attaches to the app: a world made, run and paused over MCP. `app_display` is refused clearly before attaching.
- **(private) part 4.2: pass.**
- **4.3:** pass. R #68 pass.
- **4.4:** pass. MCP jobs run on after the server closes. R #64: the server's own hunt is left paused.
  - **With the app minimised, a standalone `jetcarp mcp` search kept running (2,244 soups/s) after its server closed.** Jimmie's "set up tasks and alt-tab away" works with plain `jetcarp mcp` on rc.3.
  - The app's own world doesn't answer while it's minimised (#87, fixed on the branch).
- **Finding:** ⌘M does nothing in the app (only the yellow button minimises).
- **5.1:** pass. Every odd scene and damaged pack is refused clearly. R #66 pass.
- **5.2:** pass. A CLI explore and an MCP hunt ran on one library with the app open, each stopped from the other.
- **5.3:** pass. 256M cells: Metal 4.0 s / 3.36 GB, CPU 22 s; over the limit refused. R #63 pass. (The 64M-cell host world wasn't run.)
- **5.5:** pass. R #65: "Permission denied" in every writing tool; R #67 pass.
- **R #47:** pass. **#57:** refused with no folder left, but the empty `.store` remains (fixed for rc.4).
- **Next:** M-7 (Part 3, a separate macOS account), hands-on.

## 2026-11-16 (8:40 AM EST), main session: M-7's login finding is #99; one more logout and login, please

Filed as **#99**. launchd keeps a code requirement for the login agent's program, and Homebrew's ad-hoc-signed upgrade no longer matches it, so the spawn fails at login.

**The question that decides the fix:** does registering the agent again cure the *next* login? Test 2 re-registered it with rc.3 (`host login off`, then `host login on`).
- Please log out and in once more, and record `launchctl print gui/$(id -u)/com.jimmieprodgers.jetcarp.host` (state, last exit reason, properties) and `jetcarp host status`.
- If the host is running, the fix is for JETCARP to refresh its login registration whenever the program has changed.
- If it still fails with OS_REASON_CODESIGNING, note what System Settings → General → Login Items shows for JETCARP.

## 2026-11-16 (9:13 AM EST), main session: #96 and #99 on the branch; a check for the Mac after M-7

On `release-0.4.2` now: **#96** (the photosensitive seizure warning, bc1d72f) and **#99** (6ea0c89). After an upgrade, the macOS login item is registered with launchd again (bootout, bootstrap, kickstart) when the app starts or `host start` / `host wallpaper on` run. `host login on` registers at once too. The LaunchAgent records the version that registered it as an XML comment.

**For the Mac, after M-7 (about 20 minutes, with logouts).** Build 6ea0c89 or later. Use `J=com.jimmieprodgers.jetcarp.host` and `P=~/Library/LaunchAgents/$J.plist`. Answer the seizure warning first (the app, or `jetcarp setup --yes --seizure-warning no-disorder`) in whichever settings folder the host uses.
1. With the old host running from login (rc.3's or 0.4.1's), install the build in its place and run `jetcarp host start`. Expect "registered the login item with launchd…" and "launchd restarted the host as JETCARP …", exit 0. `pgrep -lf "jetcarp host serve"` shows exactly one host with a new pid. `launchctl print gui/$UID/$J` shows it running, without "needs LWCR update". `plutil -lint $P` passes.
2. Log out and in: the host starts at login, with no `OS_REASON_CODESIGNING`.
3. `host login on` in three states (no host; a host started by hand; a host started by launchd). Each time: one host only. Expect "started", "carries on" and "restarted".
4. Delete the version comment from $P, quit everything, and open the app from Terminal (`jetcarp`). stderr says it registered the login item. A host ends up running, even if you close the window at once.
5. Record launchctl's real exit codes for bootout of a job that isn't loaded, and for `print` of a missing job (we assume 3 or 113, and non-zero), and how many "Background Items Added" notifications one registration gives.
6. With `photosensitivity.json` removed: `host login on` and `host start` refuse, with the warning.


## 2026-11-16 (14:50 UTC), Mac: sitting M-7 done, Part 3 in Jimmie's own account (results/v0.4.2-rc.3/mac/)

Jimmie: no new user ("this is a test machine, blow away and reinstall any version of JETCARP").

- **3.2, the upgrade from 0.4.1:** pass, with a finding.
  - Homebrew's 0.4.1 was used a while (desktop-art, a hunt, three ratings, wallpaper with login), then rc.3's program, saver library and pack were put in place in the Cellar. **Nothing was lost:** every table's count, the ratings and the settings files are unchanged.
  - **Finding: the first login after the upgrade doesn't start the host.** macOS kills it: `launchctl` says `OS_REASON_CODESIGNING`, and the crash report says "Launch Constraint Violation", "SIGKILL (Code Signature Invalid)". The second login works. launchd's recorded identity for the login item no longer matched the new binary, so any upgrade that swaps it should meet this.
  - Small: `uninstall --settings --data` on macOS reports the data step "FAILED", because the data folder is inside the settings folder and was deleted with it.
- **3.1, a newcomer's first hour (Jimmie as the newcomer, from the release page and the book):** everything works, with eleven findings, mostly on the book (`3.1-newcomer.txt`):
  - The installer, the setup window's Desktop art (live wallpaper), a hunt (the book's exact numbers), the find in the Pattern library, and MCP all work. Through MCP: a world and its picture, a search, and the app via use_app.
  - **Installing:** a tester reading top-down never reaches "Release candidates" (and its example is v0.4.0-rc.1). Neither Installing nor First run says how to open the app.
  - **No app icon or launcher** on any system ("I was hoping for an icon to click on").
  - **The book's command blocks can't be copied and pasted.** They mix the `$ ` prompt, the command and its output: about 80 lines in 12 pages.
  - **The book's `claude mcp add` registers for one folder** (Claude Code's local scope). The first session didn't have JETCARP and built an HTML page itself; `--scope user` fixed it.
  - **Uninstalling:** `jetcarp uninstall` keeps the program ("It didn't uninstall") and lists eight ways to remove it. The guide's installer command sits in a table cell with a second command, and copied whole it fails.
  - **Claude Code's registration of JETCARP is left behind**, failing after the uninstall.
- **The Mac now:** no JETCARP installed (Homebrew's 0.4.1 removed too), the wallpaper and screen saver as before. The everyday folder is backed up in `~/jetcarp-rc-042c`. M-8 uses the test bin.
- **Next:** M-8 (two monitors; R #73).

## 2026-11-16 (15:00 UTC), Mac: the check of #99 and #96 (6ea0c89) passes

On rc.3 by its installer in the default folders, with the old host started at login, the build put in its place:
- **`host start`** re-registered the login item ("registered the login item with launchd, for JETCARP 0.4.2-rc.3") and "launchd restarted the host" as the new build: one host, a new pid, no "needs LWCR update", and `plutil -lint` OK.
- **The next login started the host**, with no `OS_REASON_CODESIGNING` (M-7's failure, fixed).
- **`host login on` with no host, a hand-started host and a launchd host** said "started", "carries on" and "restarted", with one host each time.
- **The app opened from Terminal**, with the version comment deleted, re-registered on stderr and left a host running after its window closed.
- **launchctl's codes:** bootout of an unloaded job gives 3; print of a missing job gives 113.
- **Notifications:** one "Background Items Added" after step 1's registration. The count for step 3's three registrations is still to come from Jimmie.
- **#96:** without the warning's answer, `host login on` and `host start` refuse (exit 1) with the full warning.
- **Caution:** the plist's comment records the version string, and this build shares rc.3's. Two builds of one version wouldn't be told apart.
- Details are in `results/v0.4.2-rc.3/mac/notes.md` and `99-check.txt`.

## 2026-11-16 (15:45 UTC), Mac: sitting M-8 done, two monitors (results/v0.4.2-rc.3/mac/)

The Q3277 (2560 × 1440, 60 Hz, scale 1) next to the built-in Retina (scale 2, 120 Hz). rc.3's test host and app, with "Measure again by itself when the monitors change" on. One host process throughout.
- **2.MM 1, two screens, one per monitor:** pass. Each monitor shows its own rotation at its own scale. Jimmie: "both crisp". The app opens on the built-in, at its last saved place.
- **2.MM 2, Fit with two monitors:** pass, with findings. Each screen gets its own sweep, but **none of the 67 sizes fit**:
  - **The CPU limit is split between the screens:** 5% a screen (judged at 4.0%), not M-4's 10%. Even the coarsest sizes measure 4.8–6.7%. Fit then takes the coarsest size, so the built-in went from 303,455 cells of 6 px to 10,496 of 32 px. Jimmie: "Yes it's blocky".
  - **With the Q3277 attached, the Retina's frame times miss the budget at almost every size:** p95 17–20 ms against 16.7 ms, at 32 px as much as at 6 px. On the Retina alone (M-4) they were ≈ 6.5 ms. The Q3277's frames are fine (1–12 ms). The frames look paced by the 60 Hz monitor, not by the world's size.
- **2.MM 3, unplug and plug back in:** pass. No crash. Screen 1 moved onto the built-in while the Q3277 was out. An automatic fit began about 16 s later, and both screens ended up back on their own monitors.
- **Finding: the Fit cards don't scroll sideways.** Jimmie: "I can't see all the cards, as the left/right scroll doesn't work, none of the selected cards are visible."
- **R #73:** pass. After the automatic fit, and after "Wolfram series" was fitted alone (`host tune --screen 0`), each screen's saved fit holds only its own rotation's scenes. Screen 1's fit is untouched.
- **Finding, in Jimmie's words: "a fit should never sweep through hundreds of options, it should pick a single rule and just fit with one in the series, not every one in the series. That's a bit crazy, and not at all what I wanted."** rc.3 sampled 40 of the series' 256 rules at up to 9 sizes each, which took 12.3 min. Only 7 of the 40 got a size within the limits, mostly failing on the frame time above.
- **2.MM 4, the Q3277's resolution changed and set back:** pass, with a finding.
  - Screen 1 refilled the monitor each time.
  - The host fitted again by itself, 13 s after the change, but **the automatic fit sweeps every screen**: 47 scenes, starting with the unchanged built-in's 40 Wolfram rules. The changed monitor would have waited about 12 minutes, so Jimmie saw "Changed resolution, but it did not refit". Stopped at scene 7.
  - An automatic fit could sweep only the screens whose monitor changed.
- **Memory grows with two-screen sweeps:** `host status` went 147 → 399 MB over step 2's fit, peaked at 536 MB during the replug sweep, and ended at 339 MB. `footprint` was 781 MB at the end. On one monitor (R #69) it stayed at 162 MB.
- **#99's check, the last two answers:** Jimmie saw only one "Background Items Added" in all, none for step 3's three `host login on`. The build's `uninstall` (like `login off`) leaves the job loaded in launchd, with its plist gone.
- **The Mac's Phase 2 (M-1 to M-8) is done.** The test host is stopped and the app closed. The Q3277 goes back to the Framework. (1.5 is in rc.4's wave.)

## 2026-11-16 (15:55 UTC), Mac: Jimmie on how long a fit may take

**Jimmie: "A fit should be 10 seconds, maybe 30 seconds. If we can't hit that target, I want the feature removed. You can manually tune faster than this."**
- **rc.3's fits on the Mac:**
  - 45–56 s for one monitor and 3 scenes (M-4);
  - 139 s for two screens and 10 scenes (M-8);
  - 12.3 min for "Wolfram series", 40 scenes;
  - about 15 min for the automatic fit after a resolution change, which had 47 scenes queued.
- **The arithmetic:** each size is measured for about 2 s, so a 10–30 s budget allows about 5–15 sizes for the whole fit, not per scene.
- **Also:** Jimmie's own wallpaper is back on both monitors after M-8.

## 2026-11-16 (16:55 UTC), Acer: rc.3 sitting A-6 done, Parts 4 and 5 (results/v0.4.2-rc.3/acer/A6/)

- **How:** the Mac's M-6 scripts, ported to Windows, in `~/jetcarp-rc-042c/a6`, plus the host and app parts with Jimmie. A publisher key was made first, so every pack tool was exercised.
- **4.1:** pass. Every tool. `host_control` drove a test host (its screen a window), and `use_app` ran a world in the app.
- **(private) part 4.2: pass.**
- **4.3:** pass, with no crash in 132 cases; R #68 pass. **4.4:** pass; R #64 pass (left paused).
- **Finding: on Windows too, rc.3's app stops while minimised** (#87).
  - Minimised, `world_status` got no answer for 30 s, and the world went from 721 to 749 generations over about 40 s.
  - Fully covered, it kept 30 gens/s, but at about 1.6 times its CPU in view.
  - #87's fix was checked only on the Mac, so it needs checking on Windows.
  - A standalone `jetcarp mcp` hunt ran fine with the app minimised (about 1,480 soups/s).
- **5.1:** pass; R #66 pass. A new "other-signer" pack is refused, naming the other key. **5.2:** pass, with the app's Hunts window following along.
- **5.3:** pass; R #63 pass. 16000 × 16000 for 20 generations: RTX 6.3 s, UHD 12.7 s, CPU 41 s, all the same hash.
  - **The 64M-cell host world** ran on the UHD at 3.9 gens/s, with `host status` at 1.45 GB.
  - Small finding: `host status` said "30 generations a second" (the speed asked for).
- **5.5:** pass; R #65 and #67 pass ("Access is denied" with the path; a read-only library reads and refuses writes clearly). R #47 and #57 pass (the known empty `.store`).
- **Next:** A-7 (Part 3), A-8 (two monitors) and the rest of R; 1.5 needs 8 idle hours.

## 2026-11-16 (11:57 AM EST), main session: after A-6

- A-6's small finding is **#116**, fixed in af07766: `host status` now gives the speed a screen reaches when it falls short, as in "30 fps, 3.90 of 30 generations a second".
- **#87 on Windows** (the app stopping while minimised) should be fixed by the branch's logic passes, which eframe runs for minimised windows on Windows too, but it was only checked on the Mac. rc.4's R checks it on the Acer: minimised, AI control answers within a second or two and the world keeps its speed. If you'd rather know before rc.4, build `release-0.4.2` (af07766 or later) and repeat A-6's minimised measurement. It's optional.
- Also on the branch since the Mac's sittings:
  - #114: the app's Copy and Paste work at last, so the clipboard was dead in rc.3 on every system;
  - #112: Fit to this computer is hidden in 0.4.2.

## 2026-11-16 (12:30 PM EST), main session: an unattended rc.4 pre-check while Jimmie is out (4–5 h)

The branch now holds everything planned for rc.4 (`release-0.4.2` at **af07766** or later). Before tagging, it's worth catching anything on real GPUs that CI can't see. Each laptop runs this without Jimmie. Results go in `results/v0.4.2-rc4-pre/<machine>/`; commit and push as you go. Never stop for a question: record it and carry on.

**First, on both:** clone or update the source to `origin/release-0.4.2` and build it (`cargo build --release -p jetcarp`). Answer the seizure warning once, before anything that shows a screen: `jetcarp setup --seizure-warning no-disorder` (with no `--profile` it saves only the answer). The laptops' default folders are fine.

**The Acer** (about 2–3 h):
1. The whole suite on each GPU: `cargo test --release --workspace --no-fail-fast`, with `JETCARP_GPU=RTX`, then `JETCARP_GPU=UHD`. Record the counts.
2. Parity with the branch build: the 371 scenes (300 generations) and the 40 (5,000), on RTX Vulkan, RTX DX12, UHD Vulkan and UHD DX12, as in Phase 1's 1.1 and 1.2. Expect every hash to match `expected.csv`, as rc.4 changes no stepping.
3. **The PowerShell installer's syntax**, which nobody could check on Linux: `powershell -NoProfile -Command "$e=$null; [void][System.Management.Automation.Language.Parser]::ParseFile('<repo>\packaging\install.ps1',[ref]$null,[ref]$e); $e"`. Pass: no errors printed. Then run the installer from the branch (`-InstallDir` a scratch folder) to install and `-Uninstall`, and record its messages.
4. **#87 on Windows:** start the branch app (`target\release\jetcarp.exe`) with AI control on (`jetcarp --control`) and a running world. Poll `world_status` through `jetcarp mcp --app` every 2 s (A-6's script). Minimise the window by script (PowerShell: `(Get-Process jetcarp).MainWindowHandle` with `ShowWindow(h, 6)`) for 60 s, then restore it (`ShowWindow(h, 9)`). Pass: answers keep coming while minimised, and the generation keeps climbing near its visible speed. Record the app's CPU too.
5. Leave the Acer free afterwards: A-7 and A-8 need Jimmie when he's back.

**The Mac** (about 1 h, then 8 h on its own):
1. The whole suite on Metal: `cargo test --release --workspace --no-fail-fast`. Record the counts.
2. Parity: the 371 and the 40, on Metal, with the branch build.
3. **Then 1.5, the overnight desktop soak, on the branch build:**
   - the branch's host from the test folder, wallpaper on, the default rotation, pacing as default;
   - logging every 5 min for 8 h: `host status --json` (generation, memory, held, `measured_speed`), `footprint <pid>`, and the process's CPU.
   - Pass: the host is alive throughout, its memory is steady (by the physical footprint, #80), and the screen keeps changing.
   - The Mac must not sleep (on mains, display sleep is fine: #95 holds it then, and that's worth seeing in the log), and nobody uses it till it ends.

## 2026-11-16 (12:50 PM EST), main session: the Framework's pre-check passes; rc.4 plan written; book audit under way

- **The Framework, on af07766:** parity 371/371 and 40/40 on the Radeon and on llvmpipe (CPU and GPU); the suite 1,059 passed, 0 failed, on both. `results/v0.4.2-rc4-pre/framework/summary.md`.
- **The rc.4 plan** is in `v0.4.2-rc.4.md`: R4 (a row per fix since rc.3, with the machine and the check), the parity sets and suite, the Phase 2 rows still open (A-7, A-8, F-1 to F-3, the Acer's 1.5), and the steps to the tag.
- **The rc.4 book audit** (an agent, in a worktree) is reading the whole book against everything since rc.3's audit, Fit's removal first.
- **testing.md:** the cycle's numbers now run to #116 (113 issues: 90 in 0.4.2, 21 to 0.4.3, #97 on the roadmap, #114 from a user). Committed locally as f4af46b; pushed once af07766's CI finishes.
- #115's body said "He" of the reporter, whose pronouns aren't stated: changed to "They".


## 2026-11-16 (17:55 UTC), Acer: rc.4 pre-check, first results: #87 on Windows passes, the installer passes (results/v0.4.2-rc4-pre/acer/)

- **Build:** `release-0.4.2` at af07766, built in 3.2 min (it still says `jetcarp 0.4.2-rc.3`). Everything runs in a scratch folder, `~/jetcarp-rc4pre`, so the everyday 0.4.1 library stays as it is for A-7's upgrade test.
  - With no answer saved, `host start` refuses with the full seizure warning. `jetcarp setup --seizure-warning no-disorder` saves the answer.
- **#87 on Windows: pass.** The branch app ran with `--control` and a 512 × 512 Life world at speed 30, minimised by script (`ShowWindow`) for 60 s.
  - It kept **30.0 gens/s**, and every `world_status` answered within 0.33 s.
  - Its CPU fell to **4% of a core** (42% in view). rc.3 stopped dead here in A-6.
- **The PowerShell installer: pass.** `Parser::ParseFile` finds 0 errors.
  - Installs and `-Uninstall` work, with `-NoModifyPath` and without. The user PATH stays `ExpandString` with `%PNPM_HOME%` unexpanded, gets no duplicate entry on a second install, and is byte-identical after the uninstall.
  - Refusals are right: a folder it didn't make, nothing to uninstall, a bad version, missing files. Cosmetic: each refusal is followed by PowerShell's exception block, from `throw`.
- **Running now:** parity ×4 adapters (371 and 40), then the suite with RTX and with UHD (about 2 h).

## 2026-11-16 (18:05 UTC), Mac: the rc.4 pre-check: parity and the suite pass, the soak is running (results/v0.4.2-rc4-pre/mac/)

On `release-0.4.2` at af07766, built in 81 s with no warnings. `--version` still says 0.4.2-rc.3. The run uses a fresh test folder, so rc.3's fitted `host.json` stays untouched for #112's row.
- **Seizure warning:** `jetcarp setup --seizure-warning no-disorder` saved the answer, exit 0. Doctor's self-test passed.
- **Parity on Metal:** pass. The 371 at 300 generations match on the CPU and the GPU (334 all on the GPU, 74 s), and so do the 40 at 5,000 (63 s).
- **The suite on Metal:** pass. 1,058 passed, 0 failed, 39 ignored, in 143 binaries, 10 min. rc.3 gave 1,027 / 0 / 33. The six new ignores are the three Fit tests switched off for #112 and three new `app::shots` tests.
- **1.5, the 8-hour soak:** running from 18:03:32 UTC until about 02:05 UTC. It's on the default rotation, "A classic a day", and pushes each hour.
  - At the start: footprint 209 MB, which `host status` now reports as its memory (#80), and a measured speed of 240 of 240.
  - Display sleep is set to never on this Mac, so the soak ends with `pmset displaysleepnow` to show #95 in the log.
- **Questions, recorded rather than asked:** `host wallpaper on` with no host says "saved; the host is not running" and starts nothing. Is that intended?
- Details are in `results/v0.4.2-rc4-pre/mac/notes.md`.

## 2026-11-16 (1:18 PM EST), main session: the book audit is in; #117–#119; for the Acer after its suite

`release-0.4.2` is now at **4f93c88** (pushed; CI running). Since af07766:
- **#117, the Windows installer's refusals** (from the Acer's pre-check): each refusal is now its one line and exit code 1, without PowerShell's error block. CI's Windows job now parses `install.ps1` with Windows PowerShell 5.1 and checks a refusal.
- **The third-party notices** list the clipboard's 24 crates (#114 turned it on). CI's notices check had failed on af07766.
- **The rc.4 book audit** (3 commits):
  - the changelog: Fit under Removed, the folder-check fix in one neutral line, #69 and #92 added;
  - the host, the app and the MCP pages for #80, #87, #95, #96, #98, #99, #114 and #116;
  - Contributing and How it was made;
  - the README says how to open the app;
  - new and redrawn pictures: the AI control window, setup's desktop page.
- **#118** (from the audit): the AI control window's literal backticks; ⌘M in the shortcuts list; `host login` and `--seizure-warning` help.
- **#119:** Dependabot's glib alert (GHSA-wrw7-89jp-8q8g). glib 0.18 comes from tray-icon's GTK 3 on Linux. The unsound iterator isn't used anywhere in the tree, and there's no fix without leaving gtk-rs 0.18, so 0.4.3 decides between a pure-Rust tray (ksni) and waiting for tray-icon. Dismissing the alert is Jimmie's call.
- **testing.md:** the cycle's numbers to #116; release candidates "since 0.4.2"; about 40 ignored tests.

**For the Acer, once its suite is done:** update the source to `origin/release-0.4.2` (4f93c88 or later) and run `t3_installer.ps1` again (#117). Pass:
- each refusal prints one line and exits 1, with no `At …` / `CategoryInfo` block;
- installs and `-Uninstall` work as before, and the PATH round trip is still byte-identical;
- no `jetcarp-*` folder is left in `$env:TEMP` after a refusal inside the download step. Try one with `-DownloadUrl` pointing at an empty folder.

Results go in `results/v0.4.2-rc4-pre/acer/3-installer-117.txt`.


## 2026-11-16 (6:35 PM EST), main session: #120, the saver's message box; the Acer's next steps

`release-0.4.2` is now at **41f7f2f** (pushed; CI running).
- **#120:** on Windows, a refused `host serve --saver` put up a modal message box and waited for OK. `nothing_starts_on_screen_before_the_warning_is_accepted` (host.rs) hung on it, on both of the Acer's suite runs and in CI's Windows job on 4f93c88. That job ran 4 h 50 min until it was cancelled. The box is now shown only from the `.scr` entry point (`run_scr`), the fix the Acer's notes suggest. `host serve --saver` refuses on stderr and exits 1, as on Linux and macOS. It started with bc1d72f (#96). Every CI run since then was superseded before it reached this test, except 4f93c88's.
- **testing.md:** a row for rc.4's pre-check (#117–#120), the counts to #120 (117 issues: 93 for 0.4.2, 22 for 0.4.3, #97 on the roadmap), and a paragraph on the pre-check before a tag.
- **The Acer's parity: pass**, 371/371 and 40/40 on the RTX and the UHD, each on Vulkan and DX12.
- **The Mac's soak** is at 5 h. The host is alive, the footprint is flat at 209–211 MB (one sample of 233), and it holds 240 of 240 generations a second. #120 changes only a Windows-only path, so the soak stands for rc.4.

**For the Acer, once the UHD suite (af07766) ends:**
1. Update the source to `origin/release-0.4.2` (**41f7f2f** or later) and rebuild.
2. Run the suite again on the RTX: `JETCARP_GPU=RTX cargo test --release --workspace --no-fail-fast`, with scratch folders and the same 3 h timeout. Its first run stopped at host.rs. Pass:
   - `nothing_starts_on_screen_before_the_warning_is_accepted` ends on its own, with no box on screen;
   - `host_stop_returns_once_the_host_has_gone` passes. It failed once in the timed-out RTX run, and its report was lost. If it fails again, keep the whole report.
3. On the UHD, run host.rs alone on the new build: `JETCARP_GPU=UHD cargo test --release -p jetcarp --test host`. No box, and it passes.
4. Then the #117 installer recheck in the 1:18 PM entry above, into `3-installer-117.txt`.


## 2026-11-16 (7:18 PM EST), Acer: the rc.4 pre-check is done: parity passes, #117 and #120 pass, host_stop_returns_once_the_host_has_gone fails now and then (results/v0.4.2-rc4-pre/acer/notes.md)

- **Parity (af07766): pass ×8.** 371/371 (300 generations) and 40/40 (5,000) on RTX Vulkan, RTX DX12, UHD Vulkan and UHD DX12. Every hash matches, with no MISMATCH lines.
- **The suite on af07766:** the UHD run hung 96 min on #120's box. I closed the box with IDOK (OK accepts nothing), and the UHD then passed: **1,043 passed, 0 failed, 39 ignored**, in 137 binaries. The six ignored that are new since rc.3 are the Mac's six. The RTX run had timed out at 3 h in host.rs.
- **On 41f7f2f** (rebuilt in 57 s):
  - **#120: pass.** `nothing_starts_on_screen_before_the_warning_is_accepted` ends on its own on both GPUs, and the watcher saw no box.
  - **RTX suite: 1,042 passed, 1 failed, 41 ignored** (137 binaries, 15 min). The 2 extra ignored are d8ed2fb's new screenshot tests.
  - **UHD host.rs alone: 14 passed, 1 failed, 3 ignored.**
  - **#117: pass** (`3-installer-117.txt`). Every refusal is one line with exit 1 and no error block. Installs and `-Uninstall` work as before, and the PATH round trip is byte-identical. No `jetcarp-*` folder is left in `%TEMP%`, including after `-DownloadUrl` pointed at an empty folder or at one with SHA256SUMS and no zip.
- **The failure, both times: `host_stop_returns_once_the_host_has_gone`**, `start, round 1: Error: the host did not start: the JETCARP background host is not running` (host.rs:443). Round 1's `host start --headless` waits its whole 10 s and no host answers. It's intermittent (`1-host-stop.txt` has the whole report):
  - in the whole suite it failed 3 of 4 times (counting host.rs alone just after the suite);
  - alone it passed 20 of 20; host.rs in parallel 10 of 10; host.rs with `--test-threads=1` 5 of 6;
  - from a terminal, 20 of 20 start–stop–start rounds worked, and the old host was always gone when `host stop` returned.
  - A host that finds `host.lock` held exits 3, and a detached host's stderr goes nowhere, so the test can't tell why. host.rs removes `JETCARP_GPU`, so the GPU doesn't matter here.
- **Acer free:** no jetcarp, cargo or test processes, and nothing left on the PATH. Scratch `~/jetcarp-rc4pre` is 9 MB; src is at 41f7f2f. Developer Mode is still on.

## 2026-11-16 (7:25 PM EST), main session: #120 passes; #122, host start straight after host stop; #121

`release-0.4.2` is now at **29fea86** (pushed; CI running). CI on 41f7f2f is green, Windows included. Its Windows tests took 26 min, against 4 h 50 min hung on 4f93c88.
- **#120 passes**, on the Acer (both GPUs, no box) and in CI.
- **#122** (from the Acer's `host_stop_returns_once_the_host_has_gone`, 3 failures in 4 busy runs):
  - **Cause:** `host stop` returned once the old host's port closed, but the old process could still hold `host.lock`. Windows lets a dead process's locks go after a delay that grows with load. A host started in that gap quit with exit 3, and `host start` said only "did not start". The Acer's reading was right.
  - **Fix:** `host stop` now also waits until the lock is free. It takes the lock and unlocks it explicitly. A new host waits up to 2 s for the lock before giving up.
  - The changelog has an entry; host.rs passes 3 of 3 on the Framework.
- **#121** (0.4.3): seven tests leave their scratch folders in the system temp folder. These are the 33 `jetcarp-*` folders the Acer's #117 check listed.
- **The Acer's pre-check results so far:** parity pass (4 pairs); the suite on the UHD pass; the RTX suite on 41f7f2f 1,042 / 1 failed (#122) / 41 ignored; #117 pass.

**For the Acer, now (about 30 min):**
1. Update to `origin/release-0.4.2` (**29fea86** or later) and rebuild.
2. The suite once more on the RTX: `JETCARP_GPU=RTX cargo test --release --workspace --no-fail-fast`, with scratch folders. It took 15 min on 41f7f2f. Pass: 0 failed.
3. host.rs alone, serial, 10 times, straight after the suite while the machine is warm: `cargo test --release -p jetcarp --test host -- --test-threads=1`. Pass: 10 of 10, where 41f7f2f gave 5 of 6.
4. Results go in `results/v0.4.2-rc4-pre/acer/1-tests-rtx-29fea86.txt` and `1-host-rs-29fea86-x10.txt`.


## 2026-11-16 (7:53 PM EST), Acer: #122 passes on 29fea86: the RTX suite 0 failed, host.rs serial 10 of 10 (results/v0.4.2-rc4-pre/acer/)

- **Build:** `release-0.4.2` at 29fea86, built in 48 s (it still says `jetcarp 0.4.2-rc.3`).
- **The suite on the RTX: pass.** **1,043 passed, 0 failed, 41 ignored**, in 137 binaries; exit 0, 14 min (`1-tests-rtx-29fea86.txt`).
  - `host_stop_returns_once_the_host_has_gone` passes.
  - `nothing_starts_on_screen_before_the_warning_is_accepted` passes with no box; the watcher closed none.
- **host.rs alone, `--test-threads=1`, 10 runs straight after the suite: 10 of 10 pass** (`1-host-rs-29fea86-x10.txt`). 41f7f2f gave 5 of 6.
  - Each run: 15 passed, 0 failed, 3 ignored, in 41–45 s.
  - None has the extra 10 s of a failed start.
  - Each run's whole output is kept in the scratch folder.
- With the UHD suite (af07766), parity ×8, #87, #117 and #120 from the earlier entries, every step of the Acer's pre-check now passes (`notes.md`).
- **Acer free:** no jetcarp, cargo or test processes. src is at 29fea86. Developer Mode is still on.

## 2026-11-16 (8:07 PM EST), main session: the pre-check passes; the candidate is cf5cbdf

**The branch pre-check is done, apart from the end of the Mac's soak.** By machine:

| | Parity 1.1 / 1.2 | The suite | Other |
|---|---|---|---|
| Framework | 371/371 and 40/40, Radeon and llvmpipe (af07766) | 1,059 / 0 / 41 on both, on 29fea86 | — |
| Acer | 371/371 and 40/40 on 4 pairs (af07766) | RTX 1,043 / 0 / 41 (29fea86); UHD 1,043 / 0 / 39 (af07766, the #120 box closed by hand) | #87 on Windows; installer and #117; #120; #122 (host.rs serial 10 of 10) |
| Mac | 371/371 and 40/40, Metal (af07766) | 1,058 / 0 (af07766) | 1.5, the soak: 7 of 8 h, clean so far |

- CI is green on 29fea86, with all 9 jobs.
- **The version bump** is cf5cbdf, "Release 0.4.2-rc.4" (Cargo.toml and Cargo.lock only, as 400d41d). The CLI and MCP references are current, and `package.py verify --tag v0.4.2-rc.4` passes. CI is running on it.
- **Issues from the pre-check:**
  - fixed for rc.4: #117, #118, #120, #122;
  - for 0.4.3: #119 (the glib alert, Jimmie's call on dismissing it) and #121.
- **The rc.4 wave runs the suite again on the tag on every machine**, since Rust code changed after the pre-check's first runs.
- **Left before the tag:** the soak's end (about 9:05 PM), CI on cf5cbdf, and Jimmie's go.

## 2026-11-16 (9:10 PM EST), main session: the soak passes; one question on #95 for the Mac

**1.5 on the Mac: pass.** 8 h, 97 of 97 samples alive with one pid, footprint 211 → 211 MB (−0.06 MB/h), 239.5–240.2 of 240 generations a second, never held or paused.

**#95, a question before the rc.4 tag.** In `soak-95.csv`:
- After `pmset displaysleepnow` (02:03:40 UTC), the host held within 15 s, with `dark` (and `covered` for the first 30 s). The generation stayed at 6,920,542, the CPU was at 0.1%, and the footprint was 51 MB. That's the fix working.
- But **at 02:05:29 UTC (asleep+90 s) the hold was gone and the scene ran at full speed**, 1 min 45 s before the script woke the display (`caffeinate -u`, 02:07:15).

Either the display woke by itself at about 02:05:15, or the host let go of the hold with the display still off, which would mean #95 isn't fixed.

**For the Mac, now:**
1. Run `pmset -g log | grep -E "Display is turned (on|off)|DarkWake|Wake from|Notification Display"` for 02:03 to 02:08 UTC (9:03 to 9:08 PM EST).
2. Find the display's on and off events. Did it turn on near 02:05:15 before the 02:07:15 `caffeinate -u`, and what woke it?
3. If it was off the whole time, repeat once with the screen watched: `pmset displaysleepnow`, then poll `jetcarp host status --json` every 10 s for 3 min, without touching anything. Record when `held` empties against what the screen shows.

Results go in `results/v0.4.2-rc4-pre/mac/95-display-log.txt`.

## 2026-11-16 (9:15 PM EST), Mac: the soak passes; #95's question: Jimmie woke the display, and the hold held (results/v0.4.2-rc4-pre/mac/)

- **1.5, the 8-hour soak on af07766: pass.** 1:03 to 9:03 PM EST, a sample every 5 min:
  - alive in 97 of 97 samples, the one host (pid 44732) throughout; never held, never paused; `host stop` exit 0;
  - footprint 211 MB in the first hour and in the last (−0.06 MB/h); one sample of 233 MB at the 2-hour mark, 211 MB at the next; status memory followed it (209 → 210 MB);
  - the generation moved in all 96 intervals (to 6,974,838), and 66–93% of the pixels changed between the hourly captures;
  - 240 of 240 generations a second in every sample (#116); CPU median 64.5% of a core, whole-GPU 13%.
- **One scene all 8 hours.** "A classic a day" stayed on "Quick Start turmite-llrr (5 of 7)", whose world is small enough to run on the CPU. So the soak tested neither a scene change nor GPU simulation over time (question 4 in `notes.md`).
- **#95, the 9:10 PM question: the display didn't stay off, and the host didn't let go early.** `pmset -g log` (`95-display-log.txt`), in EST; the system itself never slept:

| Time | The power log | The host (`soak-95.csv`) |
|---|---|---|
| 21:03:43 | display off (the script's `displaysleepnow`, 21:03:40) | |
| 21:03:47 | display on: "Bluetooth LE HID Activity" (Jimmie bumped the mouse by accident), at the lock screen | 21:04:00: held, covered + dark |
| 21:04:17 | display off (30 s idle at the lock screen) | 21:04:18 to 21:05:11: held, dark; generation 6,920,542 |
| 21:05:09 | display on: a mouse event (Jimmie, back at the Mac) | 21:05:11: still held, dark (locked) |
| 21:05:17 | loginwindow: Jimmie signed in | 21:05:29: not held, 240 a second |
| 21:07:15 | the script's `caffeinate -u`: nothing left to wake | |

  - So the hold lasted while the display was off and while it was on at the lock screen, and ended only after the sign-in. That's #95 working, so step 3's repeat (for a display off the whole time) isn't needed.
  - While held: CPU 0.1–1.3%, footprint 51 MB (211 MB running). `paused` and the screen's `hidden` stayed false.
- With the build, parity, the suite (1,058 / 0 / 39) and doctor from the 18:05 UTC entry, **every step of the Mac's pre-check passes**.
- **Mac free:** no jetcarp host or soak running; Jimmie is signed in. The test folder is `~/jetcarp-rc4-pre`, and rc.3's `~/jetcarp-rc-042c/config` is untouched for #112.

## 2026-11-16 (9:18 PM EST), main session: v0.4.2-rc.4 tagged

- **#95 passes**, from the Mac's 9:15 PM entry. Jimmie bumped the mouse at 9:05:09 and signed in at 9:05:17. The host held while the display was off and at the lock screen, and ran again only after the sign-in.
- **Tagged:** on Jimmie's go, `v0.4.2-rc.4` (annotated, like rc.3's) is on **cf5cbdf** and pushed at 9:17 PM EST.
- **The Release workflow** is building the pre-release; rc.3's took 32 min. Once it's out, the wave in `v0.4.2-rc.4.md` begins on each machine:
  - upgrade from rc.3 to rc.4, the way a tester would;
  - check the seizure warning (#96), then accept it;
  - R4, parity, and the suite on the tag.

## 2026-11-16 (9:31 PM EST), main session: #119 corrected: no build contains GTK; #123

- **#119 (Dependabot's glib 0.18 alert): no JETCARP build contains glib or GTK.** The 1:18 PM entry was wrong to say it comes from the tray on Linux.
  - `tray-icon` is a dependency only on Windows and macOS, where it uses the systems' own APIs. Linux has no tray icon: its menu is the GNOME Shell extension's.
  - `cargo tree` shows no GTK-family crate for any of the five release targets, and `ldd` on the Linux binary shows no GTK library.
  - glib 0.18 is in `Cargo.lock` only because the lock lists every platform's possible dependencies, and Dependabot reads it.
  - So nothing needs replacing (no ksni), and the alert can be dismissed as "Vulnerable code is not actually used" (Jimmie's call). The correction is on #119.
- **#123 (0.4.3):** for the same reason, `THIRD_PARTY_LICENSES.html` lists 21 GTK-family crates that are in no build. cargo-about filters by the union of the targets.

## 2026-11-16 (9:50 PM EST), main session: the rc.4 pre-release is out; the wave can start

- **https://github.com/jprodgers/jetcarp/releases/tag/v0.4.2-rc.4** was published at 9:48 PM EST (a pre-release). Every Release job passed: the tag, version and changelog agree; the tests; the five builds; the release.
- It has the same 13 files as rc.3: five archives, five wheels, the two installers and `SHA256SUMS`.
- The Linux archive matches `SHA256SUMS`, and its `jetcarp --version` says `0.4.2-rc.4`.
- **#119 is closed.** Jimmie dismissed the Dependabot alert as "Vulnerable code is not actually used".
- **The wave** follows `v0.4.2-rc.4.md`, "The wave", on each machine:
  1. Upgrade from rc.3 by putting rc.4's programs in place of rc.3's. On the Mac, open the app once, then log out and back in (#99).
  2. Check the seizure warning (#96), then accept it.
  3. R4 for that machine's rows, parity (1.1 and 1.2) with this release's build, and the suite on the tag.
  4. Then the open Phase 2 sittings with Jimmie: A-7, A-8, F-1 to F-3, and the Acer's 1.5 overnight.
- Results go in `results/v0.4.2-rc4/<machine>/`.

## 2026-11-16 (10:26 PM EST), main session: the Framework's rc.4 checks pass; #124–#126

- **The Framework, on rc.4's release build** (`results/v0.4.2-rc4/framework/`; `R4-summary.md` first):
  - parity 371/371 and 40/40 on the Radeon and llvmpipe;
  - the suite counts from 29fea86 (`suite.md`);
  - every unattended R4 row passes: the upgrade from rc.3's folders, #96, #112 (each scene at its own size, never rc.3's saved Fit size), #84, #85, #86, #57, rc.3's audit items, #104 (rc.3's build left pieces, rc.4's doesn't), #92, #122 (10 of 10), and the private row.
  - Still Jimmie's, in F-1: the app's warning screen, the Hunts window, a monitor change, and #114 under GNOME.
- **The Mac:** the upgrade from rc.3 passes (#99: the host came back as rc.4 at the second login), and so does #96 (CLI, MCP and the app; "Quit" quits). The plan's `host start --saver` was a mistake for `host serve --saver` and is fixed.
- **New, all 0.4.3:**
  - #124: macOS `host login on` with non-default folders says the running host carries on, while launchd restarts the default one;
  - #125: MCP `host_control` lets an unknown action through, and its `resume` disagrees with the CLI's while the warning holds the host;
  - #126: the book pages served over MCP keep HTML entities (`&lt;id>`).
- (private) One finding beyond the private row's three cases, for Jimmie to decide: a symlink planted at the hidden store beside a CLI `pack export --to` target (`.<name>.store`, a name JETCARP chooses) is followed, and a whole signed store is written where it leads. MCP refuses the same plant, and a publish into a linked store; no existing file was overwritten. CLI only, with the user's own rights. Details in `R4-11-t42b-symlink.txt`. Not filed publicly: it belongs with the private advisory until that is published.

## 2026-11-16 (10:40 PM EST), Acer: the rc.4 wave so far: the upgrade and R4's unattended rows pass but #104 in the old console window; parity and the suite running (results/v0.4.2-rc4/acer/)

- **The upgrade from rc.3: pass.**
  - The zip, installer and wheel match `SHA256SUMS`.
  - rc.4's 70 files went over rc.3's in `~/jetcarp-rc-042c/bin`, and `jetcarp --version` says `0.4.2-rc.4`.
  - rc.3's library and jobs open. `host start` is refused there with the warning, since rc.3's settings hold no answer.
- **R4, unattended: pass**, each with its own scratch folder:
  - #96 on the command line and through MCP: every command that starts or shows scenes is refused with the warning (exit 1), `host serve --saver` too with no box; the desktop is unchanged; then `photosensitivity.json` is written and the headless host works;
  - #112: no `tune` in help or MCP, `host tune` refused; rc.1's saved 16 px ignored, each scene at its own 3 px (this laptop has no rc.3 `host.json` with Fit sizes);
  - #87, minimised 60 s: 30.0 gens/s, 4% of a core;
  - #116: "7.54 of 30 generations a second", `measured_speed`;
  - #84 and #85;
  - #117 with the released installer;
  - #122: 10 of 10 start/stop/start;
  - (private) part 4.2: pass (see `4.2-summary.txt`).
- **#104: pass in Windows Terminal, FAIL in the old console window (conhost).** For 0.4.3, I'd say: Windows-only, and not the default terminal on Windows 11.
  - The fit works: lines are cut to 59 columns in a 60-column window.
  - But in conhost, cmd and PowerShell both run JETCARP with VT processing off (output mode 0x3), and JETCARP never turns it on. So the `ESC[2K` before each redraw prints as `←[2K`, pushes the line to 63 columns, and every redraw leaves a row behind.
  - Windows Terminal (mode 0x7) shows one clean row.
  - The fix might be `SetConsoleMode(ENABLE_VIRTUAL_TERMINAL_PROCESSING)` on stderr, or no escape code when it can't be set. Details in `notes.md`, with the four `104-narrow-*.txt`.
- **Small findings:**
  - `jetcarp host tune --help` still prints Fit's whole help;
  - after a `-NoModifyPath` install, `install.ps1 -Uninstall` says "took it off your PATH".
- **Running (`t1_long.ps1`, from 22:23):** parity with the release build (1.1 RTX Vulkan: 371/371, pass), then the suite on the tag (RTX), host.rs serial ×10, and the suite (UHD).
- **Waiting for Jimmie:**
  - R4's app rows (#96's warning screen, #112's pane, #114, #88, #90);
  - #96's `wallpaper on`, `login on` and `saver install` after the answer;
  - #120's screen saver Preview;
  - the book rows;
  - then A-7, A-8 and the overnight 1.5.

## 2026-11-17 (12:10 AM EST), Acer: rc.4 parity and the suite on the tag pass (results/v0.4.2-rc4/acer/)

- **1.1 parity, release build:** 371/371 CPU and GPU on RTX and UHD, each on Vulkan and DX12, 0 MISMATCH.
  - As on rc.3, on RTX DX12 one process of 335 found no RTX and ran on the UHD ("no RTX adapter was found, so the best one"); its hash matched.
- **1.2 parity:** 40/40 at 5,000 gens on all four.
- **The suite on `v0.4.2-rc.4` (cf5cbdf):** 1043 passed, 0 failed, 41 ignored with `JETCARP_GPU=RTX` (21 min) and with `JETCARP_GPU=UHD` (13 min). No message boxes.
- **#122's busy half:** host.rs serial ×10 straight after the RTX suite passed 10 of 10.
- **The only build warning:** an unused import in `jetcarp-core`'s `tests/bundled_packs.rs`. Information only.
- **The Acer's unattended part of the wave is done.** Still waiting for Jimmie:
  - R4's app rows;
  - #96's desktop steps;
  - #120's Preview;
  - the book rows;
  - A-7, A-8 and the overnight 1.5.

## 2026-11-17 (3:00 AM EST), main session: the Acer's parity and suite pass; the private finding waits for 0.4.3

- **The Acer's 930b0ac: all pass** (parity on all four adapter and API pairs, the suite on the tag, #122 busy). Its two small findings are 0.4.3's: the DX12 run that missed the RTX is #82, and the Windows-only unused import in `tests/bundled_packs.rs` is noted on #121.
- (private) Jimmie's call (2026-11-17): the hidden-store finding (NOTES 2026-11-16 10:26 PM; the Acer's `4.2c-planted.txt` shows it on Windows too) is fixed in 0.4.3 and kept private until then. `tools/publish_public.py` now holds everything private from rc.4's wave on until 0.4.3 is released, and the public `WITHHELD.md` says how severe it is (low; CVSS 3.1 2.2) without the details. The fix lands near 0.4.3's tag, in a commit that doesn't describe it.
- **Next:** Jimmie restarts the Mac's unattended rows (the suite and parity on the tag, #87, #89, #95, #99's login off, #80, #84, #85, #104), then sits with the Acer: R4's app rows, #96's desktop steps, #120's Preview and the book rows. Then the Acer's 1.5 soak, about 8 hours.
- (private) 3:06 AM: the draft advisory for it is GHSA-78q7-m3j3-xg23 (low, CVSS 3.1 2.2, CWE-59; jetcarp >= 0.4.0, <= 0.4.2), opened on Jimmie's go. It holds the details, the fix plan and the records' paths; it's published with 0.4.3.
- **The Mac's first unattended R4 push (454c70b): pass.** #99's login off with the host stopped (`launchctl print` exits 113, the plist gone, no host), #84 (GPU off: "not used, and not tested", no self-test), #85 (`paths` and `--json` name the runtime folder), #112 (`host tune` refused) and #122 (0 of 10 rounds failed).

## 2026-11-17 (3:28 AM EST), main session: the Mac's unattended rows and parity pass; the Mac's two questions are #129 and #130

Thanks, Mac. Everything so far passes: #80, #84, #85, #92 (as on the Framework: #126), #99's login off with the host stopped, #104, #112, #122, parity 1.1 (371/371) and 1.2 (40/40) on Metal, and the private row.
- (private) The Mac reproduces the hidden-store finding on macOS too, so it's on all three platforms. The draft advisory says so.
- **Question 1 (#80's figure is minutes old): #129, for 0.4.3.** Not intended. The memory reading and the `--max-rss-gb` check are taken only at the start of a step, and steps run far past their 2 s. On the Framework, a traced 2.5-minute explore had 4 steps, each 9 to 81 s past its deadline. So the status repeats a stale reading, and a peak inside a step passes the cap unseen. #80's own fix holds: each reading is the footprint.
- **Question 2 (a screen whose monitor isn't connected still runs): #130, for 0.4.3.** It should hold like a hidden screen, or move onto a connected monitor as an unplug does. The Acer's A-8 adds a check: start the host with the external monitor unplugged.
- **Still the Mac's, unattended:** #87, #89, #95 and the suite on the tag. **With Jimmie:** #99 with the host running (logout 3) and `uninstall`, #112's monitor change, #114, #88, #90, #91/#98, #103 and the book rows.


## 2026-11-17 (3:40 AM EST), Mac: rc.4's unattended rows, parity and the suite on the tag all pass; #87 covered and #89 too (results/v0.4.2-rc4/mac/)

- **The suite on `v0.4.2-rc.4` (cf5cbdf), Metal:** 1,058 passed, 0 failed, 41 ignored, in 143 binaries; 11 min, no warnings. The pre-check's af07766 gave 1,058 / 0 / 39; the two new ignores are screenshot tests (`app::shots::shots_ai_control`, `setup_ui::tests::offscreen_setup_wizard_running`).
- **Parity with the release build:** 1.1 371/371 (75 s), 1.2 40/40 (64 s), no MISMATCH.
- **#87, covered: pass.** The app (`--control`, 512 × 512 Life at speed 30) under an opaque window of the script's for 60 s: 32 of 32 `world_status` answers every 2 s, 30.0 gens/s, the app's CPU 4% of a core against 46% in view. Minimising needs the Accessibility permission, which this session hasn't, so that half is Jimmie's (⌘M).
- **#89: pass through `app_display`.** `keep_awake` on: `NoDisplaySleepAssertion "JETCARP is showing cellular automata"` in `pmset -g assertions`, the state `{"on": true, "held": true, "backend": "iokit"}`; off: gone. Twice. Jimmie clicks View → Keep awake once for the menu itself.
- **#95:** not rerun. The plan lets the pre-check's pass count, and the host's only change since af07766 is #122's lock wait. A rerun locks this Mac (`pmset displaysleepnow`), and the hold ends only at Jimmie's sign-in, so it would need Jimmie. Glad to run it while Jimmie is at the Mac if the main session wants it.
- **The Mac's state:** the default host is stopped and start-at-login is off (#99's half). Both go back on in the hands-on round (`login on`, then `login off` with the host running, logout 3), before `uninstall` at the end. Nothing of JETCARP's is running.
- **With Jimmie, after the Acer:** R4's app rows (#112's pane, #91/#98, #89's menu, #88, #90, #114 and its footer, #87 minimised), #112's monitor change, the book rows, #99's last steps and #103's uninstall, then 1.5 when the laptop can be left for 8 hours.

## 2026-11-17 (3:36 AM EST), main session: the Mac's suite, #87 and #89 pass; #95 stands; 1.5 runs again on rc.4

- **Reviewed 2fb22f1: all pass.** The suite on the tag (1,058 / 0 / 41; the two new ignores are screenshot tests, ignored by design), parity, #87 covered (4% of a core against 46% in view) and #89 through `app_display`.
- **#95: the pre-check's pass stands.** The plan allows it, and no rerun is needed: the host's only change since af07766 is #122's lock wait at start-up, and #120's change touches Windows only.
- **1.5 on the Mac: yes, it runs again on rc.4.** The plan's rule applies, since host code changed after the pre-check soak (#122, `single_instance`). It's 8 hours unattended; Jimmie chooses when. My suggestion to Jimmie: start it now, while he's with the Acer and then the Framework, and do the Mac's hands-on rows once it ends.


## 2026-11-17 (4:35 AM EST), Acer: the sitting's rows all pass (R4's app rows, #96's desktop, #120, the book); the 1.5 soak runs till 12:25 (results/v0.4.2-rc4/acer/)

- **R4's app rows, with Jimmie, on a fresh folder: pass.**
  - #96: the warning shows before setup. "May have a seizure disorder" leads to Quit first and Continue at my own risk second; Quit quits and saves nothing, and Continue saves `at_risk` via app.
  - #112: the Desktop background pane has no Fit.
  - #114: Copy on `jetcarp mcp --app` puts exactly that on the clipboard; a rule copied in Notepad pastes into the Rule box; the footer calls the address a private link.
  - #88: Jump 4096 from 0 gives 4096.
  - #90: Ctrl+S straight after typing saves the new rule, and switching windows applies it.
- **#96 after the answer, in the default folders: pass.** Before the answer, `wallpaper on`, `login on` and `saver install` are refused. After it, each works and is undone cleanly (own picture back, Run value gone, saver removed).
- **#120: pass.** With the answer set aside, Windows started `JETCARP.scr /s` itself after 60 s idle. JETCARP showed its box with the whole warning, on Windows' Screen-saver desktop; Preview did the same.
- **#100–102: pass.** The online book is still 0.4.1's, so rc.4's was built here with mdBook 0.5.4 and served on localhost.
  - Three commands from *Hunting for spaceships*, copied with the copy buttons, ran in PowerShell as pasted, with the book's exact hunt counts.
  - `claude mcp add --scope user` connected from three other folders; then removed.
- **1.5, the soak, 04:24 to about 12:25:** rc.4's host as the wallpaper on **"Classics, hourly"**, Jimmie's choice over "A classic a day", so it covers scene changes (the Mac's question 4). It runs on the UHD's GPU, samples every 5 min and pushes hourly.
- **Next:** the soak's results, then A-7 and A-8 (A-8 needs the AOC plugged in).

## 2026-11-17 (4:36 AM EST), main session: the Mac's frozen window after a restore: three checks, please; FD passes on the Framework

**Mac, about 87346cf** (the window stays on its last frame after ⌘M and a restore, while the world and AI control go on): thanks for catching that the sips hashes were wrong. If it holds, it's a candidate to block 0.4.2. A guess from eframe 0.37's code, which needs your checks:
- eframe paints only while egui thinks the window is visible: `ViewportInfo::visible()` is false if `minimized` or `occluded` is true.
- On macOS, egui-winit reads `minimized` only when the window is made, to avoid a deadlock (egui #3494). So after the start, only winit's `Occluded` events change what counts as visible.
- If no `Occluded(false)` comes after the restore, eframe goes on running `logic` only: the world steps and AI control answers, but nothing is drawn. The app's 4% of a core fits that.

**Please check, on rc.4 (the same script, Jimmie at the Mac):**
1. Once it's frozen after the restore: does covering the window with another one and uncovering it make it draw again? Does a click in it? A resize?
2. **rc.3's app** (`~/jetcarp-rc-042c`'s rc.3 build, or rc.3's archive), the same ⌘M and restore. Does its window draw again after the restore? If rc.3 stays frozen too, the cause is older than #87's fix.
3. On rc.4, the same with the world paused: after the restore, does a pan or zoom draw?

Then a GitHub issue with what you find (pre-approved), milestone v0.4.2 if rc.4 brought it in.

**Elsewhere:** the Framework's FD passes (`results/v0.4.2-rc4/framework/FD/`). That's GNOME 51 headless with two virtual monitors: the live desktop at its own size, a monitor taken away and put back with no fit, and Jimmie's real GNOME settings unchanged. F-1 will check the same minimise and restore under GNOME, and the Acer can check it on Windows after its soak.

## 2026-11-17 (4:45 AM EST), main session: the frozen window is ⌘M's (#98), not #87's; one confirming check, please

**Mac, about aec4aa5:** thanks, that settles it: new in rc.4. The cause looks like #98's ⌘M, not #87's logic passes:
- rc.4's ⌘M sends egui's `ViewportCommand::Minimized(true)` (`app/menu.rs`, 49b73a2). egui-winit then sets egui's own `minimized` flag to true (`process_viewport_command`).
- On macOS egui-winit never reads `minimized` back from the window after it's made (egui #3494's deadlock). So after a restore from the Dock, egui still thinks the window is minimised, and eframe runs only `logic` from then on. That's exactly what you saw, and why hovering, clicking and ⌘Tab don't help.
- rc.3 had no ⌘M (#91), so Jimmie used the window's yellow button there. That minimises through macOS, without touching egui's flag.

**The confirming check (rc.4, Jimmie at the Mac, about a minute):** minimise with the **yellow button** (not ⌘M), restore from the Dock: does the window draw again? If yes, the fix is for ⌘M to ask macOS to minimise the window itself (`miniaturize:` on the app's window, as the yellow button does), not to go through egui's command. Please file the issue (milestone v0.4.2) with both results.


## 2026-11-17 (4:55 AM EST), Mac: the frozen window after a restore holds: rc.3 draws again, rc.4 never does; the three checks (results/v0.4.2-rc4/mac/notes.md, #87)

- **#87 minimised itself passes:** 88 s minimised (Jimmie, ⌘M), 44 of 44 `world_status` answers, 30.0 gens/s, the app at 3% of a core.
- **Your check 2, rc.3: it draws again at once after the restore** (run 4, rc.3's app in its own folder): every capture 2 s apart for 46 s differed, CPU 36%. rc.3 still stops while minimised (no answer within 3 s, 0% CPU), and its ⌘M does nothing (#91), so Jimmie used the window's button. **So the freeze is new in rc.4**, after #87's fix.
- **Check 1, rc.4, the world running (run 5):** after the restore, the script's own window covered it from +6 to +10 s and went; Jimmie clicked in the Scene pane at +20 s and resized it by the corner at +30 s. **None woke it.** During the resize macOS stretched the old frame (still "gen 1575", from before ⌘M); then only the title bar's active look changed. CPU 5%. Run 3 earlier: a hover, a title-bar click and ⌘Tab away and back didn't wake it either.
- **Check 3, rc.4, paused (run 6):** after the restore, a zoom (scroll) at +10 s and a pan at +20 s: **nothing drawn** in 44 s, only the title bar's look; CPU 0%.
- So once restored from the Dock, the window never paints again until the app is closed, while the world steps and AI control answers. That fits your reading: no `Occluded(false)` reaches egui after the restore, so it goes on counting the window as not visible. Captures (the window alone), pixel diffs and hashes: `87b-*`, `87c-*`, `87d-*`, `87e-*`.
- **Next on the Mac:** R4's app rows with Jimmie in the default folders (#112's pane, #91/#98, #89's menu, #114, #88, #90), then #112's monitor change, the book rows, #99 and #103. #91's ⌘M will show the same freeze; I won't count it against #91.

## 2026-11-17 (5:02 AM EST), Mac: the yellow button draws again; the freeze is ⌘M's: #131 filed (v0.4.2)

- **Your confirming check, rc.4 (run 7):** minimised with the window's yellow button, restored from the Dock: **it draws again at once** (every capture 2 s apart differed for 44 s, CPU back to 32%; Jimmie: "it moved after the restore"). While minimised it went on as with ⌘M (30.0 gens/s, 3%).
- **Filed as #131**, "macOS: after ⌘M and a restore from the Dock, the app's window never draws again" (bug, milestone v0.4.2), with Jimmie's go: both results, your reading of the cause, and the suggested fix (⌘M through macOS's `miniaturize:`, as the yellow button). #87 itself passes, covered and minimised.
- **Next:** R4's app rows with Jimmie in the default folders.

## 2026-11-17 (4:55 AM EST), main session: #131's fix is on the branch `rc5-fixes` (9852e17), for the Mac to try when there's a gap

Thanks, Mac: the yellow-button result settled it. **The fix:** ⌘M now asks AppKit to minimise the key window (`miniaturize:`, as the yellow button does), not egui's `Minimized` command (`crates/jetcarp-app/src/macwin.rs`). A macOS test checks that ⌘M is taken and sends no `Minimized`. Type-checked for aarch64-apple-darwin here, so it hasn't run yet.

**When it suits (after the rows with Jimmie; not urgent):** build `rc5-fixes` (`git fetch; git checkout 9852e17; cargo build --release -p jetcarp`), then in a test folder:
- run the suite's new test: `cargo test --release -p jetcarp-app cmd_m_minimises`;
- ⌘M, wait 30 s, restore from the Dock: it draws again, and the toolbar's generation matches `world_status`;
- ⌘M again with the world paused: after the restore, a pan draws.

Whether this becomes rc.5, and what else goes with it, is Jimmie's call (not decided yet).

## 2026-11-17 (5:14 AM EST), main session: rc.5 is on (Jimmie): #131 and six small fixes on `rc5-fixes`; the plan is `v0.4.2-rc.5.md`

- **Jimmie's call (about 5:00 AM):** rc.5, with #131 and all six small fixes: #124, #125, #126, #127, #128 and the private one. All seven are on `rc5-fixes` (9852e17 to c976627). None touches the host or the simulation, so **the soaks on rc.4 count for rc.5**, and so do Phase 2's sittings and rc.4's R4 rows, except what R5 checks again.
- (private) The hidden-store finding is now fixed for 0.4.2 (acaf05b), not 0.4.3. GHSA-78q7-m3j3-xg23 says so (patched 0.4.2), and the public copy's notice now reads "fixed from rc.5". Both advisories go out with 0.4.2.
- **Before the tag:** the suite on the Framework (running), CI on the branch, and the Mac's check of #131 on `rc5-fixes` (NOTES 4:55 AM). Then the version bump and the tag, on Jimmie's go.
- **The wave** is short (`v0.4.2-rc.5.md`): parity and the suite on every machine, unattended, and R5, one row per fix. **Mac:** #131 and #124. **Acer:** #127 in the old console window, and #128's installer lines. **Framework:** #125, #126 and the private row, plus #128's help on every machine.
- **Meanwhile, rc.4's wave goes on** as planned: the soaks, the Mac's hands-on rows, F-1, F-2, A-7 and A-8.


## 2026-11-17 (5:25 AM EST), Mac: R4's app rows pass; one finding on #114's paste (results/v0.4.2-rc4/mac/)

With Jimmie, the installed rc.4 in the default folders:
- **Pass:** #112's Desktop background pane (no Fit; a capture of the window), #91/#98 (⌘⇧H, ⌃⌘F, ⌘H; ⌘M minimises but brings #131), #89 through View → Keep awake (the assertion for the 10 s it was on), #114's Copy (`jetcarp mcp --app`, exactly, on the system clipboard) and its footer ("private link"), #90 (a typed `B34/S34` saved at once without Enter reopens as B34/S34; on ⌘Tab it's applied), #88 (Jump 4096: 4,340 → 8,436).
- **Finding, #114's Paste:** ⌘V of `B36/S23` (copied in TextEdit) into the Rule box: the box kept showing the old rule until the next key (Enter) or a save. Five seconds untouched and the mouse over the window didn't show it. But the paste is taken: a save straight after has it (`r90b.json` reopens as B36/S23), and the world runs it. So the field gets the text, but the window isn't drawn again until the next key. A newcomer would think the paste failed. For the main session: an issue, and which milestone? (I haven't filed it.)
- **Next:** #112's monitor change, the book rows, then #99's last steps (logout 3) and #103's uninstall.

## 2026-11-17 (5:21 AM EST), main session: the Mac's app rows pass; the paste finding is #132 (0.4.3)

Thanks, Mac. **Question 4 (#114's paste isn't drawn until the next key): filed as #132, milestone v0.4.3.**
- Paste only works at all since rc.4: rc.3's eframe had no clipboard.
- The paste is taken, and the Acer's Windows paste showed no delay.
- The cause isn't clear yet. It could be egui-winit's `Event::Paste` on macOS waiting for the next event, or the Rule box's own handling.
- If there's a minute while Jimmie is at the Mac: does a paste into Run → Jump's Generations field show at once? That would tell the two apart. F-1 checks Linux under GNOME.

rc.5 is on (see 5:14 AM). #131's check on `rc5-fixes` still waits for a gap after #112's monitor change, the book rows, #99 and #103.

## 2026-11-17 (5:39 AM EST), main session: rc.5's fixes are on `release-0.4.2` (c976627), pushed; CI running

- With Jimmie's go, `release-0.4.2` is fast-forwarded to `rc5-fixes` and pushed: both are at **c976627** (rc.4's cf5cbdf and the seven fixes). CI's run is 44066756260.
- **Mac, for #131's check:** build **c976627**, not 9852e17, so all seven are in it (`git fetch; git checkout c976627; cargo build --release -p jetcarp`). The steps are as in NOTES 4:55 AM.
- The Framework's suite on c976627 passed (`results/v0.4.2-rc5-pre/framework/`).


## 2026-11-17 (6:00 AM EST), Mac: #131 passes on rc5-fixes; its unit test panics in a debug build; #132's paste shows at once in Jump's field; rc.4's hands-on rows done (results/v0.4.2-rc5-pre/mac/, results/v0.4.2-rc4/mac/)

- **#131 on `rc5-fixes` (c976627), Jimmie at the Mac: pass.** One session, three cycles:
  - ⌘M 32 s, restore: **draws again at once** (8 of 8 captures 2 s apart changed, CPU 39%); the toolbar's "gen 2682" 0.2 s after `world_status` said 2,676.
  - The yellow button: the same (6 of 6).
  - ⌘M with the world paused: a zoom and a pan draw (Jimmie: "It scrolled and panned").
  - While minimised, every time: all polls answered, 30 gens/s (0 when paused), 3 to 5% CPU.
- **The unit test, as the plan writes it (`cargo test -p jetcarp-app cmd_m_minimises`, a debug build): FAILED.** Its assertions pass, but dropping egui's output then panics in epaint 0.37's `debug_assert!` ("Dropped TexturesDelta with 1 unapplied deltas… call `clear` before dropping"). With `--release` it passes, and CI and the suite use `--release`, so CI won't see it. A test fix (clear `out.textures_delta` before the drop), not a #131 fix. (`131-unit-test-debug.txt`.)
- **#132's follow-up:** a paste into Run → Jump's Generations field shows at once (Jimmie: "pasting shows the text right away"). So the Rule box's delay is its own handling, not egui-winit's paste.
- **rc.4's hands-on rows are done:** #112's monitor change (no fit; `host.json` unchanged), #100 (the tag's book served locally: three copied commands ran as pasted, output as the page), #102 (`claude mcp add --scope user`: ✔ Connected from three folders; removed after), #99 (login off with the host running: left running; after logout 3, `launchctl print` 113, no host; `uninstall --yes` stops the host first, the job gone at once) and #103 (one command named for the installer; the data step "done", no FAILED; the installer's `--uninstall` lists what it removed). Two small leftovers: the installer says it "kept your settings…" just after `uninstall --settings --data` deleted them, and `~/.cache/jetcarp/app-endpoint.json` stays (probably because I closed the app with SIGTERM).
- **JETCARP is uninstalled from this Mac now.** Left on the Mac: the rc.4 soak (1.5), when Jimmie can leave it 8 hours, and #95 only if wanted. Then rc.5's wave (parity, the suite, #124, and the private row with c3).

## 2026-11-17 (5:53 AM EST), main session: #131 passes on the Mac, thanks; the test fixed; #134 joins rc.5; #135 for 0.4.3; the branch at 3e40e84

- **#131: pass**, with the yellow button and with the world paused too. Thanks, Mac and Jimmie.
- **The unit test's debug-build panic** is fixed (8e4b345): it clears egui's texture delta before the output drops.
- **#132:** since the Jump field pastes at once, it's the Rule box's own handling. That's noted on the issue, and it stays 0.4.3.
- **#103's two leftovers:**
  - The installers' "kept your settings…" after `jetcarp uninstall --settings --data` is **#134**, fixed for rc.5 (3e40e84): only folders still there are named.
  - The runtime folder that `jetcarp uninstall` leaves behind (`app-endpoint.json`) is **#135**, for 0.4.3.
- `release-0.4.2` and `rc5-fixes` are at **3e40e84**, and CI is running again (44068864638). R5 has a #134 row.
- **Mac:** thanks for the hands-on round. The rc.4 soak, when Jimmie can leave the Mac for 8 hours, still counts for rc.5. #95 isn't needed.


## 2026-11-17 (5:56 AM EST), Mac: 1.5, the 8-hour soak on rc.4, is running (results/v0.4.2-rc4/mac/soak/)

- Started 10:54 UTC (5:54 AM EST) on Jimmie's word ("I can leave the laptop now"); ends about 2:00 PM EST with the #95 display-sleep check, as in the pre-check (it locks the Mac; Jimmie signs in when back).
- rc.4's release build in a test folder of its own (`~/jetcarp-rc4/homes/soak`), the warning answered there, wallpaper on, the rotation **"Classics, hourly"** (Jimmie's choice for the Acer's soak, so it covers scene changes: the pre-check's question 4). A sample every 5 min, a capture of the host's own window and a push every hour.
- First sample: "Cyclic spirals" (4 of 7) on the GPU, 303,455 cells, 30.0 of 30 gens/s; footprint 261 MB; CPU 33%; not held.

## 2026-11-17 (6:43 AM EST), main session: CI green on 3e40e84; the rc.5 candidate is c0db1ab, waiting for Jimmie's go to tag

- **CI on 3e40e84: all nine jobs pass** (run 44068864638). The macOS job ran `cmd_m_minimises_through_appkit_not_egui`, and Windows ran the old-console test and the installer's one-line refusal.
- **The book for rc.5** (8419c54): the uninstall guide (#128's PATH line, #134's folders) and the login item's folders (#124). The photosensitivity page and the changelog were done with the fixes. The MCP and CLI references and the book's copies inside the program all check out.
- **The candidate:** `Release 0.4.2-rc.5`, **c0db1ab** (`Cargo.toml` and `Cargo.lock` only), not pushed yet. Waiting for Jimmie's go to push it and tag `v0.4.2-rc.5`.
- **F-1 so far (Framework, Jimmie, rc.4 in `homes/f1` with a gsettings guard):**
  - The rating page in Firefox: 12 ratings, a note, reload, Save ratings. Imported: 9 reviews and 3 stars, and a second import skipped all 12. Chrome won't start since the Fedora upgrade (Chrome's problem, not JETCARP's), so it waits for a reinstall.
  - Pass: the warning; setup (Explorer); the Desktop background pane has no Fit; #114's Copy; and Paste, where the box shows it at once and the header follows on leaving the box, by design; #88; #90 on leaving the window; Hunts says stale for a killed run.
  - #87 under GNOME (Super+H, then Alt+Tab): the answers never stopped, the world held about 15 gens/s, and the window drew again.
  - #90's Save half is being redone with a real save.
- **FD passed** earlier in the headless shell (`results/v0.4.2-rc4/framework/FD/`).

## 2026-11-17 (6:58 AM EST), main session: v0.4.2-rc.5 tagged (c0db1ab); F-1's app rows done; #132 closed; #136, #137

- **`v0.4.2-rc.5` is tagged** on c0db1ab (Jimmie's go), and pushed at 6:56 AM. The Release workflow is building the pre-release, and the wave (`v0.4.2-rc.5.md`) can start once it's out: parity and the suite on every machine, unattended, and the R5 rows. The soaks on rc.4 go on and count for rc.5.
- **F-1 on the Framework (rc.4, `homes/f1`, the gsettings guard: nothing refused):**
  - #90's Save half: pass. `r90.json` ends with the typed rule, applied by Ctrl+S.
  - Pop-outs: every pane and tool window popped out and back in.
  - Exports: PNG 1062x850, GIF 640x503 and an animated WebP 640x512.
  - Script examples ran (HexW, Wolfram, soup hunt).
  - Resizing works.
  - The restart: AI control switched on in the reopened app answers (`app status`), so #1's lockout stays fixed.
  - The book's three commands: they ran as pasted and matched the book. Jimmie ran them with his installed 0.4.1, which still shows the copy buttons work.
- **#132 is closed, by design:** on the Mac too, the box showed the paste at once. Only the CA's header waits until the rule is applied (#61, #90).
- **New, for 0.4.3:**
  - #136: Linux (Wayland), GNOME says the app may not be responding while a file dialog is open, because rfd's blocking dialog runs on the main thread.
  - #137: Linux, the app stays dark when the system is light, because winit 0.30 reports no system theme on Wayland or X11. Windows and macOS follow it.
- **Still to come on the Framework:** Chrome's half of F4, after Jimmie reinstalls Chrome; F-2, Part 3 in a separate Fedora account; and F-3, the overnight soak, on a night Jimmie chooses.

## 2026-11-17 (7:32 AM EST), main session: the rc.5 pre-release is out; the wave can start once each soak ends

- **`v0.4.2-rc.5` is published** (7:30 AM): a pre-release with 13 files. The Release workflow passed: tests, five builds, and the version agreeing with the changelog.
- **The Framework's R5 rows pass** on the release build (`results/v0.4.2-rc5/framework/R5-summary.md`): #128, #126, #125, #124, and the private row (the planted hidden store is refused on the command line, and still refused through MCP). Its suite on the tag and both parity sets are running now.
- **Acer, once the soak ends (about 12:25 PM):**
  1. Upgrade to rc.5 the way a tester would: its zip's files over rc.4's.
  2. Parity 1.1 and 1.2 on the RTX and the UHD × Vulkan and DX12, and the suite on the tag (`v0.4.2-rc.5`), both GPUs.
  3. R5's rows: **#127** in conhost (cmd and PowerShell, 60 columns: one clean row, no `←[2K`); **#128** (`host tune --help`; `install.ps1 -NoModifyPath` then `-Uninstall`: "(it wasn't on your PATH)"); **#134** (`jetcarp uninstall --settings --data --yes`, then `install.ps1 -Uninstall`: no "kept your settings"); the private row (A-6's script with case c3).
  4. Then A-7 and A-8 with Jimmie, which can run on rc.5.
- **Mac, once the soak ends (about 2:00 PM):** install rc.5, then parity and the suite on the tag (Metal), and R5's rows: **#131** (⌘M; yellow button; paused pan), **#124** (`login on` with `JETCARP_*` set, then launchd's line), **#134** (`install.sh --uninstall` after `uninstall --settings --data`), and the private row with c3.
- **The plan is `v0.4.2-rc.5.md`.** The rc.4 soaks count for rc.5, and so do F-1 (`results/v0.4.2-rc4/framework/F-1/`) and FD. Next on the Framework: F-2, with Jimmie, on rc.5.

## 2026-11-17 (9:11 AM EST), main session: the Framework's rc.5 rows, suite and parity pass; F-2 done; F-3 is running; #139, #140 for 0.4.3

- **The Framework on rc.5 is all pass** (`results/v0.4.2-rc5/framework/`):
  - R5's rows (#124, #125, #126, #128, and the private row);
  - the suite on the tag, 1,065 / 0 / 41;
  - parity 371/371 and 40/40 on the Radeon and llvmpipe.

  The suite and parity ran on the host, because the VS Code sandbox found no Vulkan device after Jimmie's 7:33 session switch. The 7:32 run, with no GPU, is set aside in `no-gpu-0732/`, and its one test failure is #138 (0.4.3, test only).
- **F-2 (Part 3 in a new Fedora account, rc.5): pass, with two findings for 0.4.3** (`F-2/summary.md`):
  - #139: GNOME setup doesn't plainly say to log out once, so the scene shows in an unexplained window;
  - #140: on Wayland the app restores its saved window size behind egui's back, so it draws stretched and clicks miss until it's resized (in 0.4.1 too).

  **Jimmie: both go to 0.4.3, with no rc.6** ("0.4.2 has too many other critical fixes that I want to get out").
- **F-3, the Framework's 8-hour soak, started at 9:10 AM**, on Jimmie's go. It runs rc.5's host in a private headless GNOME Shell (a 2560x1440 virtual monitor) with the extension, rotation "Classics, hourly", a sample every 5 minutes and a screenshot every hour (`$W5/f3/`). It ends at about 5:10 PM. Jimmie stays logged in, with light work only.
- **Left before 0.4.2:** the laptops' rc.5 waves after their soaks (NOTES 7:32 AM), A-7 and A-8 with Jimmie, and F-3. Then the release steps, on Jimmie's go.


## 2026-11-17 (12:40 PM EST), Acer: 1.5, the 8-hour soak on rc.4, passes; rc.5's wave next (results/v0.4.2-rc4/acer/)

- **1.5: pass.** rc.4's host as the wallpaper, rotation "Classics, hourly", on the UHD, 04:24–12:24 (`notes.md`, `soak-summary.txt`):
  - alive in all 97 samples, one host (pid 32428), never stalled, held or paused;
  - the scene changed on the hour, all seven classics at full speed (30 of 30 gens/s; the two ants 240 of 240 on the CPU);
  - private bytes followed the scene (426–430 MB, 480 on Penrose waves, 439 at the end), so no climb; handles about 455;
  - nine hourly pictures of the wallpaper window, all right; all eight pushes went through.
- **Jimmie at the end:** "Still looks right, smooth and moving, nothing odd". `host stop` then gave back Jimmie's own picture, its file unchanged throughout (`soak-end.txt`).
- **Checked after, not a finding:** the 05h picture showed Langton's ant small and early, while its generation (357,338) had never reset. The classic's ant bounces at its dead edge (`agent_edge` defaults to `"bounce"`), and being reversible, it winds itself back to nothing and builds a mirror image, every couple of minutes. So it never ends or restarts, and the count is right. rotations.md's "Langton's ant has walked off the edge" is for an ant set to `fall_off` (`t15_ant.ps1`, `soak-ant.txt`).
- **Next on the Acer (NOTES 7:32 AM):** upgrade to rc.5; parity and the suite on the tag; R5's rows (#127, #128, #134, #124's note, the private row with c3); A-7 and A-8 with Jimmie.

## 2026-11-17 (2:05 PM EST), Mac: 1.5, the 8-hour soak on rc.4, passes; #95 holds with the display off throughout; rc.5's wave next (results/v0.4.2-rc4/mac/soak/)

- **1.5: pass.** rc.4's host as the wallpaper, rotation "Classics, hourly", 5:54 AM to 1:54 PM EST, with Jimmie away
  (`notes.md`, `soak-summary.txt`):
  - alive in all 97 samples, one host (pid 71955), never held or paused; the generation moved in every interval;
  - the scene changed on the hour through all seven classics, each at full speed: 30 of 30 gens/s on the GPU (Metal),
    and the two ants 240 of 240 on the CPU;
  - the footprint followed the scene (261–314 MB, the most on Penrose waves), with no climb: Life used 265 MB in the
    first hour and 269 MB in the last;
  - nine hourly pictures of the host's own window, all right; all ten pushes went through.

  This covers the pre-check's question 4: scene changes and GPU simulation over time.
- **#95 on rc.4: pass**, and the case the pre-check couldn't see: nobody touched the Mac this time.
  - `pmset displaysleepnow` at 1:54 PM. The power log has the display off from 13:54:28 to 13:57:59, with nothing
    waking it (`soak-95-display-log.txt`).
  - The host held (`dark`) within 15 s. From then on the generation stayed at 98,061, the CPU at 0.1%, and the
    footprint dropped from 268 to 182 MB.
  - After the script's `caffeinate -u`, the display was on at the lock screen: still held (`covered`, `dark`),
    footprint 54 MB. The display went off again 30 s later.
  - `host stop` came while the Mac was locked (exit 0), so the resume at sign-in is the pre-check's (12 s after the
    sign-in).
- **rc.4 on the Mac is done:** the upgrade, R4's rows, parity, the suite, 1.5 and #95. No host or login item is left.
  The Mac is at the lock screen until Jimmie signs in.
- **Next on the Mac, on Jimmie's go (NOTES 7:32 AM):**
  1. Install rc.5.
  2. Parity and the suite on the tag (Metal), unattended.
  3. R5's rows: #131 (⌘M, the yellow button, a paused pan: Jimmie's hands), #124, #134, and the private row with c3.

## 2026-11-17 (3:21 PM EST), Mac: rc.5's unattended parts pass: parity, the suite on the tag, #128, #124, #134, the private row; #131's hands-on row next (results/v0.4.2-rc5/mac/)

rc.5's release archive (checked against `SHA256SUMS`), each row in a test folder of its own, from 2:59 PM, on Jimmie's
go (`notes.md`, `progress.md`):
- **Parity on Metal:** 1.1 371/371 and 1.2 40/40, CPU and GPU (74 s, 64 s).
- **The suite on `v0.4.2-rc.5` (c0db1ab):** 1,065 passed, 0 failed, 41 ignored, no warnings, as on the Framework.
  #131's unit test is ok there, and ok again in a debug build, where it panicked before 8e4b345.
- **#128:** `host tune --help` and `host help tune` print only the "isn't in JETCARP 0.4.2" line.
- **#124:**
  - With the `JETCARP_*` folders set, `login on` gives the note naming all five, then "registered with launchd, which
    runs the host with the default folders, not this run's" (no pid).
  - That host was the default folders', waiting for their warning, so the note is right.
  - Without the variables: no note, "which started the host (pid …)". launchd's job was removed each time.
- **#134:** the installer's `--uninstall` names only what's still there:
  - the settings folder when it was kept;
  - only `~/Pictures/JETCARP` after `jetcarp uninstall --settings --data` (the real home);
  - nothing when nothing is left (a scratch home).
- **(private) part 4.2: pass.**
- **Two wording points**, for 0.4.3 if wanted (`notes.md`, questions 1 and 2):
  - a login host with the wallpaper off reports "GPU none … GPU simulation unavailable: no GPU" on the M2 Max, because
    it never opens the GPU;
  - after `uninstall --settings --data`, the installer says "kept your settings, data and pictures in
    ~/Pictures/JETCARP" when only the pictures are left.
- **The Mac now:** rc.5 installed (`~/.local/bin/jetcarp`), with no settings, login item or host.
- **Next, with Jimmie: R5 #131** (⌘M and a restore from the Dock with the world running; the yellow button; a pan
  while paused). Its script is ready (`R5-scripts/t131_cmdm.py`).

## 2026-11-17 (4:00 PM EST), Acer: rc.5 is on; A-7 (Part 3 in a new Windows account) passes, with a finding for 0.4.3; A-8 next (results/v0.4.2-rc5/acer/)

- **rc.5 over rc.4:** the zip, installer and wheel match `SHA256SUMS`; 70 files in place, none left over; `jetcarp 0.4.2-rc.5`. Jimmie chose A-7 and A-8 first, while there, and then the unattended parity and suite runs and R5's rows.
- **A-7: pass** (`A-7/summary.md`, Jimmie's notes word for word). Jimmie, in a new Standard account, with rc.5's book served locally:
  - **Part A**, rc.5's installer: install, the app, a hunt, the library. The uninstall: each step "done", nothing left (#103).
  - **The upgrade from 0.4.1 (Scoop), then rc.5's files over it:** the host came back at login as rc.5 and **held**, at generation 0 after 87 s, "waiting: the photosensitive seizure warning has not been accepted". The app showed the warning; once answered, the host ran. Jobs and finds kept; no second setup. The app's process ends with its window. rc.5's `uninstall --yes --settings --data` named `scoop uninstall jetcarp` as the one command (#103 on Scoop).
  - The first try at the upgrade (Part B) never happened: `jetcarp.exe` was in use, most likely by the 0.4.1 app still open. It was redone as Part C.
- **Finding for 0.4.3 (Windows): the installer lines save into the current folder.** Ada's new PowerShell windows opened in `C:\WINDOWS\system32`. There, the two lines `jetcarp uninstall` prints (`Invoke-WebRequest … -OutFile jetcarp-installer.ps1`) fail with "Access to the path 'C:\WINDOWS\system32\jetcarp-installer.ps1' is denied". The book's install and uninstall lines have the same form. Saving to `$env:TEMP` (or a `cd ~` first) would fix it.
- **Two moments of confusion, for 0.4.3 if wanted:**
  - After the installer, `jetcarp` in the same window isn't found. The "open a new terminal" note is in the installer's fifth line and after the book's table.
  - A repeated `uninstall --yes --settings --data` says "Nothing to undo: JETCARP has not set anything up outside its folders". It doesn't say the settings and data folders are already gone, so it read as if the flags were ignored.
- **Not covered:** rc.5's own Desktop art step in setup (my checklist buried it, so it was skipped; 0.4.1's Desktop art and rc.5's held host were covered), and MCP in the new account (no Claude Code there).
- **Next on the Acer:** A-8 with Jimmie (the AOC on the left: two monitors, #112's monitor change, #130). Then parity, the suite on the tag, and R5's rows (#127, #128, #134, #124's note, the private row with c3).

## 2026-11-17 (4:25 PM EST), Acer: A-8 (two monitors) passes on rc.5; #130 confirmed on Windows; parity and the suite running (results/v0.4.2-rc5/acer/A-8/)

- **A-8: pass** (`A-8/summary.md`). rc.5's host ran in its own folder, with the laptop's screen and the AOC (2560×1440, on the left at x = −2560). `a8.ps1` logged `host status` every second, with each wallpaper window's place and its monitor's DPI; Jimmie did the plugging, scaling and looking.
  - **Two screens, one per monitor** (the book's `host wallpaper on --screen N --monitor N` lines), each at its scene's own size: Penrose waves on the laptop, Forest fire on the AOC. Jimmie: "Both looked right".
  - **Unplug and replug while running:** the same host throughout, never held; both screens back on their monitors at once.
  - **The AOC's scaling, 100 → 125 → 225 → 100%:** only the AOC's screen was rebuilt, its cells scaled to the monitor (2 → 3 → 5 → 2 px); the laptop's screen ran straight through.
  - **#112, a monitor change starts no fit:** no tune or fit key in any status, and `host.json` unchanged.
  - A first try at the scaling changed the laptop's scale (Display settings opens on the main display). Only the laptop's screen was rebuilt then, correctly; it's set aside in the summary.
- **#130 (0.4.3), confirmed on Windows as on the Mac.** With the host started while the AOC was unplugged, screen 1 ("wallpaper on monitor 1 (not connected)") stepped at 30 gens/s on the GPU, at a fallback 1280×720, with no window. The host's GPU use was 49–52%, against 62% with both screens visible. Plugged back in, the screen showed on the AOC at once. During the unplug with the host running, the screen also stayed bound and kept stepping, unseen, rather than moving onto the laptop as rc.3's did on the Mac.
- **Now running, unattended, from 4:22 PM:** parity 1.1 and 1.2 with rc.5's release build on the RTX and the UHD × Vulkan and DX12, then the suite on `v0.4.2-rc.5` on both GPUs (`t1_long.ps1`). It should end about 6:15 PM; R5's rows follow.

## 2026-11-17 (4:35 PM EST), Mac: R5 #131 passes (⌘M, the yellow button, a paused zoom and pan); rc.5 on the Mac is done (results/v0.4.2-rc5/mac/)

rc.5's release build, `--control`, a 512 x 512 Life world at speed 30, with Jimmie at the Mac from 4:23 PM
(`notes.md`, `131-cmdm.txt`):
- **⌘M with the world running**, 26 s, then a restore from the Dock: the window drew again at once. The toolbar
  showed "gen 5467" 4 s after the restore, against `world_status`'s 5,462 just before; on rc.4 it stayed at the ⌘M's.
  While minimised: 30 gens/s, CPU 3%.
- **The yellow button**, 20 s: the same, every capture after the restore changed.
- **⌘M with the world paused**, then a zoom and a pan: both drew. Between them, only the toolbar's fps figure changed.
- With the unit test (ok in release and debug, 3:21 PM entry), R5's #131 row passes.
- **rc.5 on the Mac is done:** every row passes; the two wording points (3:21 PM entry) are for 0.4.3. rc.5 stays
  installed, with no settings, login item or host.

## 2026-11-17 (5:12 PM EST), main session: F-3, the Framework's 8-hour soak on GNOME, passes on rc.5; four issues filed from today's rows (#141–#144), and #130 confirmed on Windows (results/v0.4.2-rc5/framework/F-3/)

- **F-3: pass** (`F-3/summary.md`). rc.5's host as the desktop background, in a private headless GNOME Shell 51.1 on a
  virtual 2560 × 1440 monitor, rotation "Classics, hourly", 9:10 AM to 5:10 PM. Jimmie stayed logged in for light work.
  - **Alive and moving:** all 96 samples, one host, never held or paused; the generation moved in every interval.
  - **Scenes:** all seven classics, changing on the hour, at full speed: 30 gens/s on the Radeon, and the ants 240 on
    the CPU.
  - **Memory:** 334 MB at the start, 467 MB at the peak (Penrose waves), then 407–409 MB flat for the last five hours,
    across five scene changes. No climb.
  - **Jimmie's real GNOME settings** were the same before and after, and nothing from the private session was left.
  - **The pictures:** the test's new home opened GNOME in the overview with Fedora's Welcome dialog, so the pictures
    are dimmed and the dialog covers the centre (the ant's hours look empty).
- **Every machine's soak is now done:** the Acer's and the Mac's on rc.4 (they count for rc.5), and the Framework's on
  rc.5.
- **Issues filed today from the waves, all for 0.4.3:**
  - #141 (Mac): a login host that hasn't opened the GPU yet says "GPU none".
  - #142 (Mac): the installers' "kept your settings, data and pictures" when only pictures are left.
  - #143 (Acer, A-7): the Windows install and uninstall lines save into the current folder, refused in system32.
  - #144 (Acer, A-7): `jetcarp` not found after the Windows installer; a repeated uninstall says only "Nothing to
    undo".
  - #130, confirmed on Windows by A-8, including an unplug while running (comment on the issue).
- **Left before 0.4.2:** the Acer's parity and suite (running, to about 6:15 PM), then its R5 rows: #127 in conhost,
  #128, #134, #124's note, and the private row with c3.

## 2026-11-17 (6:07 PM EST), Acer: rc.5's wave passes: parity, the suite on the tag, R5 #127, #128, #124's note, #134 and the private row; rc.5 on the Acer is done (results/v0.4.2-rc5/acer/)

- **1.1, 1.2 parity: pass** (`1-parity/`, `t1_long.log`). rc.5's release build on the RTX and the UHD, each with Vulkan and DX12: 371 of 371 and 40 of 40 on every run, CPU and GPU, with 0 MISMATCH lines. Every GPU process ran on the adapter asked for; rc.3's and rc.4's one RTX DX12 fallback to the UHD didn't happen this time.
- **1.3 the suite on `v0.4.2-rc.5`** (c0db1ab, clean): **pass**, 1048 passed, 0 failed, 41 ignored in 137 test binaries, with `JETCARP_GPU=RTX` (22 min, 7 of it the build) and `UHD` (14 min). Both list the same 1,089 tests, rc.4's plus five new ones (#124's and #127's among them). No message box. The RTX log's first line names rc.4: that is the old build in `target`, read before cargo rebuilt it at the tag.
- **R5 #127: pass.** In conhost, 60 columns wide, with cmd and with PowerShell 5.1, the console's output mode is now 0x7 (rc.4: 0x3). The explore's progress redraws in place as one row, cut to 60 columns with "…", with no `←[2K` anywhere (rc.4 left a new row per redraw). Windows Terminal (cmd and PowerShell) matches rc.4's captures row for row. Output sent to a file (cmd's `> file 2>&1`, and Start-Process's stdout and stderr) has whole lines, each progress line on its own, with no ESC byte and no bare carriage return.
- **R5 #128: pass.** `host tune --help` and `host help tune` print only "Fit to this computer isn't in JETCARP 0.4.2: it returns, faster, in 0.4.3. Each scene shows at its own size." rc.5's own installer, `-NoModifyPath` then `-Uninstall`, printed "(it wasn't on your PATH)". A normal install then `-Uninstall` printed "took it off your PATH". The user PATH was then exactly as before, value and kind.
- **R5 #124's note: pass.** With every `JETCARP_*` set, `host login on` adds "note: the login item starts the host with the default folders; JETCARP_CONFIG_DIR, JETCARP_DATA_DIR, JETCARP_RUNTIME_DIR, JETCARP_LIBRARY, JETCARP_OUT are not passed on to it". With none set, there's no note. `login off` removed the Run value each time.
- **R5 #134: pass.** After `jetcarp uninstall --yes --settings --data` on the default folders (each step "done"), `-Uninstall` said "kept your settings, data and pictures in ~\OneDrive\Pictures\JETCARP", naming only the one folder left. The wording is #142's, the same on Windows. The case with no folder left would need Jimmie's OneDrive `Pictures\JETCARP` gone, so it wasn't made here; the Mac's scratch home covers it.
- (private) part 4.2: pass, R5's row with c3 (and c4, c5).
- **Clean-up:**
  - Gone: rc.5's installer install, the default settings and data folders, the `C:\Users\Public\jetcarp-a7*.txt` files (copied into `A-7/`) and mdBook in `~/jetcarp-rc4/tools`. There's no JETCARP Run value, process or screen saver.
  - Left: rc.5's release files in `~/jetcarp-rc-042c/bin` (for the next upgrade), the source at the tag, and Scoop's 0.4.1. OneDrive's `Pictures\JETCARP` was untouched.
  - Jimmie's call: Developer Mode (still on) and Ada's account.
- **Nothing is left on the Acer before 0.4.2.**
## 2026-11-17 (7:51 PM EST), main session: 0.4.2 tagged; F3 passes on Jimmie's real session (results/v0.4.2/framework/)

- **0.4.2, on Jimmie's go ("push the branch and start the release", 6:20 PM):**
  - The branch: `release-0.4.2` with two commits over rc.5. eda3dbb is the book (testing.md's cycle in numbers,
    the real logins tried, citing 0.4.2); a3e829a is "Release 0.4.2" (the version, the changelog dated 2026-11-17
    with a Security entry naming both advisories, `CITATION.cff`).
  - CI and the release dry run passed on a3e829a. `main` was then fast-forwarded to it (PR #14 merged), and the
    annotated tag `v0.4.2` pushed at 7:06 PM.
  - The release run passed (the tests, five targets) and made the draft release, 13 files. It waits for Jimmie to
    publish it; publishing sends it to PyPI, crates.io, Homebrew and Scoop.
- **F3: pass** (`F3-summary.md`, `F3-after-login.txt`).
  - The draft's Linux archive, checked against `SHA256SUMS`, replaced Jimmie's 0.4.1 at `~/.local/bin/jetcarp`.
  - `host gnome status` rewrote the extension to 0.4.2's and asked for one logout.
  - After it, the extension runs as 0.4.2, and the login item started 0.4.2's host, showing Jimmie's own rotation
    with the lock screen live.
- **Next:**
  1. Jimmie publishes the draft.
  2. Both advisories published (their drafts now carry the final status; GHSA-88q3 lists 0.4.2 as patched).
  3. The public test records regenerated with both tiers released. The scratch copy passed a privacy review with
     no findings.
  4. The 0.4.2 milestone's issues closed.
