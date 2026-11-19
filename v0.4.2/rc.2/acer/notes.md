# v0.4.2-rc.2 Phase 1 on the Acer (2026-11-15)

- **Scripts:** `phase1.ps1` ran 09:01–11:42 UTC (0, 1.6, 1.1, 1.2, 1.3, 1.4). `phase1b.ps1` ran 11:46–12:58 UTC
  (the end of 1.4 and reruns of the 1.3 crash). Log times are local, UTC−5; the JSON `updated` fields are UTC.
- **Machine:** on mains; 12 threads; RTX 3050 6GB Laptop (546.18) and Intel UHD (31.0.101.4146).
- **Test folder:** `C:\Users\jimmi\jetcarp-rc-042b`. The candidate ran by full path, with `JETCARP_CONFIG_DIR`,
  `JETCARP_DATA_DIR` and `JETCARP_OUT` pointed there.
- **Everyday copy:** Scoop's 0.4.1 was untouched (`where.exe jetcarp` is still its shim). The desktop state
  (wallpaper, screen saver, Run values) was the same at the start, after 1.3 and at the end.

## 0 Unpack: pass

- **Download:** the zip's sha256 `aa024bba…a15a14` matched `SHA256SUMS`; `--version` said `jetcarp 0.4.2-rc.2`.
- **doctor:** the first run took 11.0 s (self-tests ran, `gpu-checks.json` written). The second took 0.9 s, with
  both self-tests "kept from before": display UHD 492 ms, compute RTX 339 ms. This is the #17 evidence for 2.0.
  - It lists six adapters, including WARP ("which the GPU simulation never uses") and the UHD's GL.
  - The app and the desktop background simulate on the UHD; runs, searches and scripts on the RTX.

## 1.6 Hunt determinism: pass

Hunt job 1 found 1,783 distinct and 760,892 objects (ships 51,012, osc 236,468, still 473,412) in 18 s. This
equals the Framework's numbers exactly. The status JSON is in `1.6-status.json`.

## 1.1 Parity on every adapter: pass ×4

Every run: 371/371 on the CPU and the GPU, all 300 generations on the GPU in 334, and 0 MISMATCH lines.

| Adapter | Time |
|---|---|
| RTX Vulkan | 7.4 min |
| RTX DX12 | 17.5 min |
| UHD Vulkan | 6.8 min |
| UHD DX12 | 18.7 min |

The `gpu_backend` column names the adapter asked for in all 335 GPU rows of each run. DX12 takes about 2.5 times
as long as Vulkan on both adapters.

## 1.2 Long parity: pass ×4

Every run: 40/40 at 5,000 generations, all on the GPU. RTX Vulkan 2.3 min, RTX DX12 3.3, UHD Vulkan 2.4,
UHD DX12 3.8.

## 1.3 The test suite: RTX fail (one crash), UHD pass

The tag was cloned at 2d4b84c, and `cargo test --release --workspace --no-fail-fast` ran in a scratch
environment.

- **RTX:** 986 passed, 0 failed, 33 ignored; exit 101 after 23 min, including the build.
  - `-p jetcarp-gpu --test recovery` died with `0xc0000005, STATUS_ACCESS_VIOLATION` after "running 2 tests",
    before either test reported: `a_run_that_fails_part_way_leaves_the_world_as_it_was` and
    `gpu_and_cpu_generations_mix_around_a_failure`.
  - The context is in `1.3-tests-rtx-crash.txt`.
- **UHD:** 988 passed, 0 failed, 33 ignored; exit 0 after 13 min.
- **Reruns of the same binary afterwards** (`1.3-recovery-reruns.txt`):
  - RTX: 8 of 8 passed, 5 in parallel and 3 with `--test-threads=1`.
  - UHD: 2 passed. One **hung**: "running 2 tests" and nothing more for 10 min, then killed.
  - Counting the suite's runs, this test crashed once in 9 runs on the RTX and hung once in 4 on the UHD.
- **Ignored (the same 33 on both):**
  - `app::reseed_ui::tests::preset_survey` and `app::shots::*` (7).
  - `keepawake::tests::take_and_release`, `offscreen::tests::*` (11) and `setup_ui::tests::offscreen_setup_wizard`.
  - `size_classes_exact_vs_float_level6`, `spectre_exact_equals_float_level6`, `gun_hashes`, `hunt_one_soup`,
    `hunt_throughput`, `big_world_reseed_timing`, `spectre_window_equals_level_8_cell_for_cell`.
  - `profiles::tests::profile_survey`, `world_larger_than_one_dispatch_dimension`, `write_golden_packs`,
    `explore::job::tests::cpu_cost_by_family`, `gpu_prefix_speed`, `hunt_profile`.
  - The full list is in `phase1.log`.

## 1.4 A long search with a crash in the middle: pass except step 3

**Start.** Explore job 2 (`--minutes 120 --label long --detach`) started at 10:40 UTC.

**First hour.**
- 60 probes: none at 0/s, median 36/s.
- Working set 0.4–0.9 GB, peak 1,557 MB. `jobs status` said 0.81 GB at the kill.
- That is well below the Framework's 3.45 GB at an hour.

**First kill**, at 11:41 UTC: `Stop-Process -Force` on `jetcarp.exe jobs resume 2 … --minutes 120`.
- `jobs wait 2 --timeout 180` exited 6 after 45.4 s: "still marked running, but no process runs it".
- `jobs status` straight after still said `status running` (#49).
- `jobs resume 2 --detach` started `jetcarpw.exe`, which started `jetcarp.exe jobs resume 2 … --quiet`.

**Two findings at the resume:**
- **`jobs wait` 0.2 s after `jobs resume --detach` exited 6, "no process runs it".** The new process was still
  starting. `phase1.ps1` took that as the end and went on to the pack too early.
  - The export refused correctly: "explore job 2 is running, and its newest 125,869 runs are not sealed yet, so
    the pack would leave them out / stop it first (jobs stop), then publish". This is #35's refusal working.
  - That first attempt's outputs are in `1.4-first-attempt.txt`.
- **`--minutes` is per session**, so the resumed search had no end. "`jobs resume` it to the end" needs
  `jobs resume N --minutes <what is left>`.

**Across the kill.** The 125,104 screened runs were kept. Confirmation runs went from 4,110 to 3,885 after the
reload.

**`phase1b.ps1` finished the job:**
- **Second hour.** The resumed session ran to 2 h in all: 57 probes, none at 0/s, median 36/s. Working set
  peaked at 1,223 MB; status said 1.19 GB at 2 h.
- **Second hard kill**, at 12:42:36 UTC. Killing `jetcarp.exe` also ended its `jetcarpw.exe` parent, and
  nothing respawned.
  - **`jobs status` said `running`, stale false, resumable true at +2, 15, 30, 45, 60, 90 and 120 s.** Its
    `updated` stayed at 12:42:35Z, the last heartbeat. Meanwhile `jobs wait` at +121 s exited 6 at once.
  - So status never called the job stalled within 2 min. That is longer than #49's "up to 45 s".
  - Details: `1.4b-status-after-second-kill.md` and `1.4b-status-kill-120.json`.
- **The end.** `jobs resume 2 --minutes 1` in the foreground exited 0 after 63 s. Status was `paused`, 120 min in
  all, and `jobs wait` exited 3.

**Final.** 261,392 runs: 254,912 screened plus 6,480 confirmation runs. 26,665 elites in 12,931 niches; 188 of
1,359 tilings. Status memory 0.44 GB, from the 1-minute session.

**Pack, with no `jobs seal`:**
- **Export:** exit 0 in 3.3 s. "sealed its newest 261,392 runs first, so the pack carries every run".
  28 files, 20,679,628 bytes (19.7 MB).
- **`pack check`:** 0.
- **Import into a fresh library:** 0. "261392 runs, 26665 elites in 12931 niches, rebuilt in 3.1 s". 1,454
  patterns and 1,783 sightings: the 1.6 hunt came along.
- **The imported job:** `jobs runs` gives 254,912 stage-1 rows and 6,480 stage-2 rows, the same as the source.
  The stage-1 rows (rule, tiling, rng, score) are identical after sorting. **#35: pass.**

`jobs runs --limit 0` lists stage 1 only by default. The first script's count (121,984 rows) was taken while
the job was still running.

## Lost logs (my mistake)

While copying these results, a helper I named `Rd` resolved to PowerShell's built-in `rd` alias (aliases win
over functions). It ran `Remove-Item` on about 70 files in `jetcarp-rc-042b\logs`.

- **Kept:** every CSV, every status JSON and `1.6-status.json`.
- **Rebuilt from what this session had printed** (each says so at the top): `phase1.log`, `phase1b.log`,
  `summary.txt`, `0-doctor-second.txt`, `1.4-first-attempt.txt`, `1.4b-end-and-pack.txt`,
  `1.3-tests-rtx-crash.txt` and the head and tail of `1.4-progress.txt`.
- **Gone:**
  - the first doctor output;
  - the hunt's stdout;
  - the full `cargo test` outputs (counts, the crash and the ignored list survive);
  - most of the per-minute 1.4 probe log.
- Nothing outside that logs folder was touched.

# Phase 2, sitting A-1 (2026-11-15)

Phase 1's `config` and `data` were moved to `jetcarp-rc-042b\phase1\`, so Phase 2 starts on empty settings and an
empty library (job numbers as in the plan) with the same `bin`. Outputs: `2.*` files here.

## 2.0 Unpack and check: pass

- **Hash:** a fresh download's sha256 `aa024bba…a15a14` equals `SHA256SUMS`. Its 70 files are identical to `bin`.
  `--version` says `jetcarp 0.4.2-rc.2`; `paths` names settings, data and output under the test folder only.
- **Everyday copy:** `where.exe jetcarp` (registry PATH) is still Scoop's shim, `jetcarp 0.4.1`.
- **#17:** the first doctor took 10.4 s:
  - display UHD Vulkan "passed (521 ms)", compute RTX Vulkan "passed (639 ms)", with no "kept from before";
  - `gpu-checks.json` was written. It holds all five adapters: both Vulkan, both DX12 and the UHD's GL, which
    passes here, unlike the Radeon's (#48).
  - The second doctor took 0.8 s and says "kept from before" for both.
- **#21:** `JETCARP_GPU=nosuchgpu run --gpu --gens 300 --json scenes/0.json` gives backend "gpu (NVIDIA GeForce
  RTX 3050 6GB Laptop GPU (NVIDIA), Vulkan; no nosuchgpu adapter was found, so the best one)". The hash is
  `d9c87f6d4f91849f`, which equals `expected.csv`.
- **#26:** with `WGPU_BACKEND=dx12`, doctor's Environment block lists `WGPU_BACKEND=dx12`. Display and compute
  become the DX12 adapters (3,029 ms and 2,861 ms, kept from the first doctor).
- **#40:** display: "the app and the desktop background simulate on it"; compute: "runs, searches and scripts
  simulate on it".

## 2.G1 Each GPU's self-test: pass

doctor ran once per way of reaching each GPU, with `gpu-checks.json` removed first so that each test ran fresh.

| Way | Self-test | doctor |
|---|---|---|
| `JETCARP_GPU=RTX` (Vulkan) | passed (230 ms) | 8.2 s |
| RTX + `WGPU_BACKEND=dx12` | passed (2,659 ms) | 6.0 s |
| `JETCARP_GPU=UHD` (Vulkan) | passed (392 ms) | 8.6 s |
| UHD + `WGPU_BACKEND=dx12` | passed (2,880 ms) | 6.5 s |

- **Every test:** "59 world rules and 33 explore batches matched the CPU". The UHD's GL passed in 2.0 (632 ms).
- **A named adapter** is both display and compute ("why: named RTX, as asked (JETCARP_GPU=RTX)").
- **`JETCARP_GPU=off`:** both lines say "not used, and not tested: the GPU simulation is off" (2.5 s).
- **Auto:** UHD display and RTX compute, as in 2.0, "kept from before" (0.8 s). RTX again: "kept from before"
  (0.8 s). The kept times are from the latest test, because each doctor on an empty cache tests all five
  adapters.

## 2.1 GPU explore search (A1): pass

`search explore --families life_like,generations,jaca,cyclic --minutes 10 --label gpu-mix` (no `--gpu`), 08:32–08:42
local.
- **Status:** "explore 1: 32,598 runs (48/s), 6,733 elites in 3,428 niches (286 of them confirmed), 21 of 1,359
  tilings; NVIDIA GeForce RTX 3050 6GB Laptop GPU (NVIDIA), Vulkan". 1,092 confirmation runs, 0.41 GB.
- **Families:** life_like 14,191, generations 11,415, jaca 5,310, cyclic 1,682. The runs CSV has 32,598 rows
  (7 MB, not committed).
- **#22:** 99 progress lines give a rate: median 47/s, max 78/s. The only two at 0/s are the opening "0 runs"
  lines.
- **#24:** every line says "(N of them confirmed)". The count fell once, from 289 to 286, as #24 allows.
- **Usable:** Jimmie says "Usable, no lag". The search's process used 2.5 cores on average (4.0 at most) and
  775 MB at most, with "2 left free" of 12.
- **Errors and warnings:** none in the output.

## 2.2 GPU runs replay the same on the CPU (A2): pass

`2.2-check.ps1` (rc.1's `A2-check.ps1` with rc.2 file names) took the top 20 JACA and 10 Life-like runs of job 1,
with all their measures.
- **Replays:** **30 of 30** match: `measures.density` equals the CPU replay's population / cells to 6 decimals.
  All replays ran on "cpu (12 threads)".
- **Hashes:** **5 of 5** (3 JACA, 2 Life-like) are the same on `--cpu`, `--gpu` (RTX Vulkan) and no flag. With no
  flag, the JACA scenes run on the CPU and the Life-like ones on the RTX.
- **Cells:** every run's stored `cells` is 16,000, the size asked for (#27). The replays have 15,510–16,048
  cells, except run 27762 (JACA B1/S123 on `penrose-rhomb`), which has **35,000**: a Penrose patch asked for
  16,000 cells gets 2.2 times that.
  - Not a mismatch. But a screening run on that tiling costs about twice the others'. Job 1 has 3,066 runs on
    it.
- **Files:** `2.2-replays.csv`, `2.2-hashes.csv`, `2.2-jaca.json`, `2.2-life.json` and the 30 scenes in
  `2.2-scenes/`.

## 2.3 CPU-only explore confirms, stop and resume (A3): pass

`2.3-steps.ps1` (rc.1's `A3-steps.ps1`) ran `search explore --cpu --families jaca --minutes 10 --label cpu-jaca`.
After 5 min it ran `jobs stop 2`, then `jobs wait 2 --timeout 60`, then at once `jobs resume 2 --minutes 4`.
- **Confirms:** "679 runs, 244 elites in 131 niches (18 of them confirmed)", 66 confirmation runs, 8 min 55 s in
  all. Both counts are above 0.
- **Stop to wait:** `jobs wait` returned **exit 3 (paused) 2.01 s after the stop**, and the explore process had
  already exited. In rc.1 it returned in 0.47 s while the process still ran.
- **#16:** `jobs resume 2 --minutes 4`, straight after, was accepted (exit 0) and ran its 4 minutes.
- **Speed:** the same as rc.1 (825 runs in 8:56 then, 679 now; JACA on 10 CPU threads, about 1.3 runs/s, with 28
  runs stopped at their time cap).
  - At that pace, 12 of the 88 progress lines say 0/s and 15 say 1/s. #22's "rarely 0/s" was about the GPU
    batches, so this is only an observation.

## 2.4 The smart JACA search (A4): pass

`search explore --gpu --families jaca --parents-from 2 --reviewed keep,maybe --minutes 6 --label smart-jaca` (job 3).
- **#25:** at the start, "parents: 500 JACA runs of explore job 2 (its best ones: it has no reviews with the
  verdicts asked for); 257 with both signs holding to the end". The same line is in `jobs status 3` at 13 s and
  at the end. No error.
- **Result:** 13,236 runs, 1,994 elites in 1,033 niches (92 of them confirmed), 288 confirmation runs, 0.42 GB, on
  the RTX.
- **Rates:** 0/s only in the 3 opening lines; median 33/s.
- **Origins** (`2.4-origins.txt`): random 29.2%, mutate 16.7%, balance 14.1%, transplant 13.1%, transplant-scaled
  9.6%, cover 9.3%, seed 8.0%. All seven are there, and random is the largest, about 30%.
- **Signs:** the `sign_*` columns (`sign_pos`, `sign_balance`, `sign_sorted`, `sign_trade`, `sign_lost`) are
  filled for JACA runs with `--measures all` (`2.4-runs-signs.csv`). As in rc.1, the plain CSV has no measures.
- **At the budget's end:** "1,024 runs given up at a stop or the end (not kept)", the GPU batch in flight. That's
  8% of the kept runs, by design.

# Phase 2, sitting A-2 (2026-11-15)

## 2.5 The rating page in Edge (A5): pass, with a finding about the sample

- **#29:** `jobs clips 3 --sample 48 --px 180 --page --out 2.5-clips` wrote **48 clips** in 9.7 s. rc.1 gave 13 on a
  JACA-only job.
  - The clips: 48 GIFs (3.4 MB), 12 tilings. Fates: running 14, cycle 12, froze 20, died 2. Categories: Battles
    26, Frozen at once 20, Quick deaths 2.
  - The page was opened with `Start-Process msedge`. Files: `2.5-clips-manifest.json`, `2.5-clips-index.html`
    (the GIFs stay out of the repo).
- **Jimmie rated all 48 honestly:** 2 keep, 6 maybe, 40 drop, 2 stars. His note: "Way too many die almost
  immediately, or just turn into static."
- **Checks (Jimmie):**
  1. The keys: "All worked, moved on".
  2. After F5: "Stays after reload, as expected".
  3. Save downloaded `C:\Users\jimmi\Downloads\ratings-2.5-clips.json` (4,469 bytes; "jetcarp-ratings 1", job 3,
     round "2.5-clips", rater, note and 48 ratings). It is committed as `ratings-2.5-clips.json`.
  4. Light and dark: "Works".
  5. Clumsy? "Honestly it works better than the Claude.ai page, as all the images loaded instantly and there was
     no lag." He asked how many ratings a page allows. Locally there is no cap: `--sample N` (default 96) or
     `--ids`, and the page shows every clip in its folder (about 72 KB a clip).
- **Reading them back:**
  6. `jobs review 3 --from … --rater "Jimmie Rodgers"`: "recorded 48 review(s) and 2 star(s) by Jimmie Rodgers (0
     for runs not in job 3, 0 already recorded); job 3 has drop 40, keep 2, maybe 6, ★ 2", then the note.
  7. The second time: "recorded 0 review(s) and 0 star(s) … (… 50 already recorded)". Nothing was added.
- **#33:** `jobs runs 3 --reviewed any --limit 100` lists the 48 runs, each ending `[keep ★]`, `[maybe]` or
  `[drop]` (`2.5-reviewed.txt`).

**Finding: the stratified sample spends most of a round on runs nobody keeps.**
- **The numbers:** job 3's 13,236 runs are 59% running, 18% cycle, 12% froze and 10% died. But the sample gave
  "Frozen at once" 20 of its 48 slots (42%), and Jimmie dropped all 20. Of the 26 "Battles", 18 were dropped too.
- **Why it matters:** a rater's round should mostly show runs that could be keeps. Here 40 of 48 were dropped,
  and the refit in 2.6 then refused for want of keeps.
- **Suggestions:**
  - give the dead and frozen categories a few slots, not a share by category count;
  - or weight the strata by score;
  - and say in `jobs clips`' output how many clips each category got.

## 2.6 Refit, score and export (A6): pass (after a second round of ratings)

1. **The first refit refused**, clearly (exit 1): "a fit needs at least 20 reviewed runs with 5 keeps and 5
   drops; these have 48 runs, 2 keeps and 40 drops / review more runs: jobs clips makes clips to rate, jobs
   review records the ratings".
   - With Jimmie's OK, a second round: job 3's 48 highest-scoring unrated runs (`2.6-ids.txt`; score 1.54–1.66;
     running 46, cycle 2; 10 tilings), rendered with `jobs clips 3 --ids … --page --out 2.6-clips`.
   - Jimmie rated all 48 honestly: 11 keep, 14 maybe, 23 drop, 3 stars (`ratings-2.6-clips.json`).
   - `review`: "recorded 48 review(s) and 3 star(s) …; job 3 has drop 63, keep 13, maybe 20, ★ 5".
   - **The refit** (exit 0, replaying on the RTX): "fitted to 96 review(s) of 96 run(s) of explore job(s) 3 by
     Jimmie Rodgers (13 keep, 20 maybe, 63 drop; jaca runs only)".
   - **"held-out AUC 0.850 (keep against drop; on the runs fitted 0.944; the built-in score 0.779)"**. rc.1's 24
     ratings gave 0.410.
   - Strongest terms: `same_nb` −0.372, `jaca:sign_sorted` +0.339, `travel` +0.286, `movers` +0.234, `growth`
     +0.207, `jaca:sign_lost_early` −0.200, `jaca:sign_balance` −0.192, `settle_frac` +0.169, `jaca:sign_lost`
     +0.162, `entropy` +0.158.
   - It wrote `2.6-model.json` ("jetcarp-score-model 1", 23 features).
2. **The rescore and the scored search:**
   - **Rescore** (exit 0): "rescored 13524 runs of explore job 3 by the score model 'Jimmie Rodgers, jaca on
     explore job 3' (for jaca runs) (10461 scores changed); the archive now holds 1994 elites in 1033 niches
     (2.2 s)".
   - **#36 and #30:** `jobs status 3` now says "(67 of them confirmed)" (92 before the rescore) and has the line
     "score: the score model 'Jimmie Rodgers, jaca on explore job 3' (for jaca runs)".
   - **The scored search** (job 4, `--gpu --families jaca --score 2.6-model.json --minutes 3`, exit 0) printed
     "score: the score model '…' (for jaca runs)" right after its job line. `jobs status 4` has the same line.
   - Job 4: 9,510 runs (52/s), 1,976 elites, 51 confirmed, on the RTX; no errors. rc.1 said nothing about the
     model in either place.
3. **`2.6-all.csv`** (4.1 MB, not committed): Excel isn't installed on the Acer, so it got a strict parse
   instead (`TextFieldParser`, quoted fields).
   - 9,510 data rows, the same as job 4's 9,510 runs, all with the header's 41 fields. ASCII only, no BOM, LF line
     endings.
   - It has the five `sign_*` columns. `2.6-five.json` has 5 runs with 26 measures each.

## 2.7 Jobs wait and memory caps (A7): pass

`2.7-steps.ps1` (rc.1's `A7-steps.ps1`; job ids read from the output). The log is `2.7-log.txt`; each command's
full output is in `2.7-out\`.
1. **Exit codes as expected:**
   - **0:** `search hunt --soups 3000 --detach --label wait-done` started job 5 in 0.19 s. `jobs wait 5` gave exit 0
     after 3.2 s ("hunt 5 is done", 3,000 soups, 1,320 soups/s).
   - **The capped hunt:** `search hunt --soups 2000000 --max-rss-gb 0.05 --label capped` (job 6) paused at once:
     "memory 0.1 GB is over the cap of 0.05 GB". `jobs status 6` has the same note.
   - **3:** `jobs wait 6 --timeout 5` gave exit 3 at once ("hunt 6 is paused").
   - **6:** `search hunt --soups 2000000 --detach --label to-kill` (job 7) runs as `jetcarpw.exe jobs resume 7 …`
     with a child `jetcarp.exe jobs resume 7 …`. The child was killed with `Stop-Process -Force`.
     `jobs wait 7 --timeout 120` gave **exit 6 after 43.8 s** ("still marked running, but no process runs it";
     9,330 soups). `--timeout 2` gave 6 again at once (0.17 s).
2. **Gone after 43.8 s**, inside the ~45 s heartbeat (rc.1: 43.0 s). Windows file locks didn't get in the way.
3. **Job 7 resumed:** `jobs resume 7 --minutes 1` gave exit 0 after 62.9 s, going from 9,330 to 84,141 soups and
   pausing at its budget.
4. **#31:** with `JETCARP_GPU=off`, `search hunt --gpu --soups 500 --label no-gpu` (job 8) exited 0 and printed
   **"the GPU was asked for, but JETCARP_GPU=off: running on the processor"**. rc.1 printed nothing.
5. **#32:** `jobs wait 7 --timeout 120` waited 43.8 s on the killed hunt and printed its progress line once. rc.1
   printed 9 identical lines in 43 s. Every `jobs wait` printed one progress line.
   - None of these waits watched a line change, so this shows the repeats are gone more than that changes print.
- **Also:** hunt 7 found the same MWSS `77364004…` in soup 4526 as in rc.1 (hunts are deterministic).

## 2.8 Rules, names and progress (A8): pass

`2.8-steps.ps1`; the log is `2.8-log.txt`, with outputs in `2.8-out\`.
1. **Both V rules run as edge-neighbourhood Generations rules.** `"B47/S13568V/4"` froze at generation 6 and
   `"B3/S23V/C4"` at 11, both exit 0. Saved with `--json --save`, their scenes' CA are `{"neighborhood":"edge",
   "rule":"B47/S13568/C4"}` and `{"neighborhood":"edge","rule":"B3/S23/C4"}`.
2. **`"B4v7/S2"`** exits 1 with "Error: a V goes at the end of the rule or right after its B or S counts: B47/S2V".
3. **The bad rules file is refused before anything runs:** exit 1 in 0.12 s, "Error: 1 rule cannot run, so the job
   was not started: / line 3 of …\2.8-rules.txt: B4x/S2: 'x' is not a neighbour count". No job was made: the next
   hunt is job 9, right after job 8.
4. **"hunt 9: 30/30 soups in each of 6 groups, 1116 soups/s, …"** (#8), with one line per group (3 rules × 2
   tilings), on the RTX.

## 2.9 `library soup` and the scripts (A9): pass

`library list --class spaceship --limit 10` lists 6 (`2.9-list.txt`): two c-ships from hunt 9 (B2/S34), and the
glider, HWSS, MWSS and LWSS (B3/S23).
1. **Each rebuilt soup produces its ship.** `library soup <id> --save` ran for all six (0.2–0.4 s each;
   `2.9-soups\`). Each soup's census was then read at 50–2,500 generations (`2.9-scan.txt`):

   | Ship | In the census at |
   |---|---|
   | c-ships `12334684`, `484e9fe1` | 50 (their soups explode at 54–55) |
   | glider `5a080db3` | 400 on |
   | HWSS `1376072e` | 800–1,200 |
   | LWSS `6dd55e69` | 1,200–1,600 |
   | MWSS `77364004` (hunt 7 soup 4526, as in rc.1) | 2,000–2,500, not at 400 |

   - So the plan's "a few hundred generations" suits only short soups; #34 (when the find first appears) is
     already listed.
   - A first check matched the id prefix in the scene's file name. It was redone on the census table's key
     column.
2. **`--best 3` wrote three scenes** on the MWSS in 9.3 s: "the best 3 of 10000 soups run again", soups 4526 (38
   ships), 7794 and 9324. These are the same three as rc.1.
   - Hunt 7 now has 86,857 soups. `--soups` defaults to "as many as the hunt ran, at most 10,000", as its help says.
3. **The JACA example** (`script --example jaca-territories`, exit 0) prints the same five lines as rc.1:
   - sorted goes from 0.01 to 0.991, fronts from 4,508 to 122, balance from 0.496 to 0.399;
   - it wrote `final.png` (two territories), `run.json` and `territories.csv`.

## 2.10 Packs with schema-2 runs (A10): pass, with one gap (an empty running search exports silently)

`2.10-steps.ps1`; the log is `2.10-log.txt`, with outputs in `2.10-out\`.

**Deviation:** the plan's `(& $J jobs status 3 --json | ConvertFrom-Json).folder` is empty. The folder is at
`.progress.folder`, and the uuid at `.spec.uuid` (`5cbba190-…`).

**Before the export:** job 3's folder held only `manifest.json` and `search.sqlite` (13,236 + 288 runs, never
sealed).
1. **#35:** `pack export --to A10-pack --feed rc-acer --title "rc.2 test, Acer" --search 5cbba190… --no-media` →
   exit 0, 28 files, 1,450,390 bytes.
   - It printed **"explore job 3 (search 5cbba190-…): sealed its newest 13,524 runs first, so the pack carries
     every run"**. Afterwards the folder has `runs\part-000001.parquet` (1.2 MB).
   - `pack check` → exit 0: 12 objects, signed by its publisher, "RC tester (Acer)".
2. **The import into a fresh library** → exit 0: 113 patterns, 202 sightings, 1 search, "13524 runs, 1994 elites
   in 1033 niches, rebuilt in 2.6 s".
   - **It has every run:** stage 1 13,236 rows and stage 2 288, as in job 3. The stage-1 rows (rule, tiling, rng,
     origin, fate) are identical after sorting.
   - Confirmed: 67 on both sides, so #54's shortfall doesn't show here.
   - `--measures sign_balance,sign_sorted` lists filled values.
3. **#37:** `jobs list` on the import: "explore 1: 13,236 runs (0/s), 1,994 elites in 1,033 niches (67 of them
   confirmed), 12 of 1,359 tilings; **not run here yet**".
   - The hunts say "imported from pack rc.2 test, Acer (its finds came with the pack; nothing ran here)".
   - `jobs status 1` adds "note: its working database was rebuilt from its sealed runs".
4. **An export that takes a running search:**
   - **First try:** job 10 (`search explore --families life_like --minutes 3 --detach`), 16 s after its start
     (status `running`, no runs stored yet). `pack export --search <its uuid>` was **not refused**: exit 0, 27
     files, 111,831 bytes, "copying its segments". The pack has the library's patterns and nothing from the
     search, with no word that it was running.
   - **Second try**, after `jobs resume 10 --minutes 2 --detach` and 40 s: running, 2,112 runs. The export **was
     refused**: exit 1, "Error: explore job 10 is running, and its newest 2,112 runs are not sealed yet, so the
     pack would leave them out / stop it first (jobs stop), then publish".
   - **So the refusal only fires when there are unsealed runs.** A search that is running but hasn't stored a run
     yet exports silently, as an empty search. The refused export also leaves an empty `--to` folder behind.
   - The detached resume kept `--minutes 2` in its command line.
5. **The zip:** `A10-pack.zip` (1.21 MB, sha256 `a0385f4476d14750e4966d0c6ae680b435b52090b7ea1e67c6eee5d9a1ee4f72`,
   made with `tar.exe -a`) is committed. Unzipped again, `pack check` passes.
   - **Importing the other two machines' packs waits:** neither the Mac's nor the Framework's rc.2 pack exists
     yet.

# Phase 2, sitting A-3: 2.APP, the app (2026-11-15)

**Set-up.** The app was started from the test bin (`jetcarpw.exe`, with the three folder variables), on one
screen, the Acer's panel.
- `jetcarpw.exe` is only a launcher: the app runs in a child `jetcarp.exe` with no arguments.
- A monitor logged that process every 5 s (`app-mon.txt`: working set, private bytes, CPU, title).

**The checklist** came from the app's own menu table (`crates/jetcarp-app/src/app/menu.rs` at the tag): 10
menus, 15 tool windows and 12 panes. Jimmie went through it in rounds.

## 2.APP 1: every menu item, pane and pop-out: pass, with two findings

- **Round 1** (the setup wizard, File, Edit, View):
  - "everything opened fine".
  - The wizard ran first (fresh settings). Jimmie finished it as "blank slate", with the desktop offers unticked
    (`setup.json`).
  - The saved scene `a3-scene.json` and the two PNG exports (world 2400×2371, view 1062×835) all pass `jetcarp
    verify` (generation 103, hash `1b6dff83b3e02963`).
  - Export wallpaper wrote a 1920×1080 PNG into the test output folder.
  - The contact sheet (`contact-sheet.png`) is a labelled grid of elementary rules 90–153.
  - Nothing touched the desktop: the wallpaper, `SCRNSAVE.EXE` and the Run values are unchanged, and no host
    ran.
- **Round 2** (Run, Tiling, CA, Seed):
  - **Tiling: "went fine".** The `B3/S23V` card reads `B3/S23V`, and MCP's `world_status` later showed
    `"rule": "B3/S23V", "neighborhood": "edge"`.
  - Run, CA and Seed (seeding, Reseed pane, Reseed now, Auto reseed): "All worked".
  - **Finding (Jimmie): the HashLife jump in place is nearly impossible from the GUI.**
    - Run → Jump → "Jump ahead (HashLife)" needs a wrap-edge lattice whose sides are powers of two (`torus_shape`
      in `hashlife.rs`: "HashLife needs a torus whose sides are powers of two").
    - But the Tiling pane's Size offers only approximate cell counts ("About 400" … "About 64 million") or "Fill
      the view", so the GUI can't make such a grid. ("On the unbounded plane" and "HashLife view…" work on any
      lattice.)
    - Jimmie: "There needs to be a way in the GUI to set a specific grid size", meaning width × height.
  - **Finding (Jimmie): no GUI to choose the GPU.** Run → GPU simulation offers "Follow the shared setting
    (auto)", "On" and "Off".
    - The shared setting can name an adapter (`gpu.json`, which takes `discrete`, `integrated` or part of a name),
      and so can `JETCARP_GPU`.
    - But no window picks the RTX or the UHD, so on this Optimus laptop the app can't be moved to the RTX from the
      GUI.
- **Round 3** (Tools, Window, Help, and every tool window and pane popped out and back):
  - "this time it went smoothly, nothing negative to report".
  - The app process stayed the same throughout (no crash; at most 1.55 GB).

## 2.APP 2: AI control (#1's lockout): pass

1. **Switched on** (Tools → AI control…, "Allow AI control (127.0.0.1 only)"): the app listened on
   `127.0.0.1:47811`.
   - `jetcarp mcp --app` connected ("connected to the JETCARP app on port 47811"). `initialize` gave "jetcarp
     0.4.2-rc.2", protocol 2025-06-18, and there are 21 tools.
   - `world_status` returned the app's world: `B3/S23V`, edge, Koi, on hex 332×257.
   - The window showed "Connections 0, Tool calls 1". Connections counts the links open at the moment, so 0 after
     each client closed is right; "open connections" would read better.
   - (My first client sent a UTF-8 byte-order mark and got "parse error … column 1". That was my client, not
     JETCARP.)
2. **Popped out and back in:** fine.
3. **Quit** (File → Quit): the process ended and the port closed.
4. **Restarted with no world open** (the Quick Start): the AI control window reopened by itself, **off**
   (`ai_control_at_launch: false`).
   - Ticked again, it listened on the same port. `jetcarp mcp --app` connected, and `world_status` returned the
     empty placeholder world (square 120×80, no CAs, "Empty: every cell is dead").
   - Files: `2.APP-mcp-3.jsonl`, `2.APP-mcp-4.jsonl`, and `2.APP-ai-control-at-restart.png` (the window, off;
     no token shown).

## 2.APP 3 and 4: shortcuts, light and dark, sizes: pass

- **Shortcuts:** "all shortcuts worked": every key in the F1 list. Ctrl+Q wasn't pressed this round; Quit itself
  worked in round 4.
- **Light and dark:** "worked".
- **Window resizing**, very small and very large: "worked".

## 2.APP 5: Quick Start, editing, save and reopen: pass, with a finding

- **Quick Start:** Jimmie opened entries from each category and tried the tiling and family filters. No problems.
- **Edit, save, reopen:** "Brian's Brain on Penrose rhombs" with the palette changed (Prism → Aurora) and the reseeding
  changed twice (blobs when settled, then blobs every 100 generations). Jimmie saved it as `a3-edited.json`, opened
  another entry and reopened it: "everything came back as saved". `jetcarp verify`: `ok: generation 1389 hash
  145e517acb1498b2`, exit 0.
- **Finding: the Rule box shows a rule that isn't applied.**
  - Jimmie had also typed a new rule, but the file still had `B2/S/C3` and no rule change.
  - The CAs pane's Rule box applies only on Enter (`ca_ui.rs` line 48). After clicking away, the box keeps showing
    the typed rule, with no sign that it isn't applied (the JACA rule boxes at least say "Press Enter to apply" on
    hover; this one has no hover text). Jimmie: "the box changed, so I thought the rule had as well".
  - The repro: `B23/S/C3` typed, Enter pressed, the world changed, and the scene recorded `update_ca` → `B23/S/C3`.
    Jimmie saved over the same file: `verify` gives `ok: generation 1616 hash 472d01a0e80d2c12`, exit 0. That
    second version is the committed `a3-edited.json`.
  - A fix could apply the rule when the box loses focus, or mark the box as pending (a colour or "Enter to apply").

## 2.APP 6: PNG, GIF and WebP from the app: PNG and GIF pass; the app can't make a WebP on request

- **PNG:** done in round 1: the world and view exports, both passing `verify`.
- **GIF:** the app's only animation export is the Hunts window's **Render media**.
  - The button isn't easy to find. Jimmie first reported "No Render Media visible. I can't find that anywhere".
  - It appears only after a hunt is picked in the job list, on the "Finds" line of the right-hand column under the
    hunt's counters.
  - On hunt #9, rendered twice (the house style, then another palette under Colours): "both rendered fine". That
    gave 40 GIFs (20 per palette), all `GIF89a`, at most 225×216 px. `library info` now says "media 80".
  - `media export` copied three of them out under readable names (`anim.gif`, `poster.png`, `thumb.png`). Jimmie
    opened the p3 hexagon oscillator's `anim.gif` in Edge: it plays.
- **WebP: not from the app.**
  - Render media picks the format itself: GIF when a frame fits in 320×320 px with 256 colours, else WebP. Every
    find here is small, so all came out as GIFs.
  - The app offers no format choice and no other animation export, so a WebP can't be asked for from the GUI.
  - From the CLI, `jetcarp media render --scene a3-edited.json --format webp` wrote a 3.3 MB `anim.webp`
    (200 generations from the seed), and it plays in Edge. So the encoder works; the gap is the GUI.

## 2.APP 7: the scripting pane's examples: pass

Tools → Scripts and sweeps… → Script → Examples, each run with Run script. Jimmie: "All run". Each wrote its folder in
`jetcarp-rc-042b\out\`:

| Example | Files | Time |
|---|---|---|
| hexw3-atlas | 19,683 PNGs, `manifest.csv`, 2 JSON (378 MB) | 136 s |
| hexw-all | 16 PNGs, `manifest.csv`, 2 JSON | under 1 s |
| wolfram-all | 256 PNGs, `manifest.csv`, 2 JSON | 1 s |
| soup-hunt | `finds.csv` (a p7 oscillator in B36/S23), `soups.csv`, 1 PNG | 29 s |
| catalog-hunt | no folder: it writes to the library (patterns 113 → 114, sightings 202 → 243; no new spaceship to promote, Quick Start still 364) | – |
| script-five | 5 PNGs (one per stage), 2 JSON | 1 s |
| jaca-territories | `territories.csv`, 1 PNG | under 1 s |

## 2.11 (A11): JACA's colours and the GPU in the app: pass, with a finding

No sitting lists 2.11, so I ran it here, since it's the app. A11's other parts are covered above: the `B3/S23V` card
(2.APP 1), AI control (2.APP 2), and the Desktop background pane (2.APP 1, round 3).

**How it was measured.** `mcppoll.ps1` kept one `jetcarp mcp --app` connection open and logged `world_status` every 5 s
(generation, cells, playing, scene), so gens/s is the generation's change over time. A PrintWindow screenshot every
10 s gives the status bar's "simulation: …" and the fps. Files: `2.11-poll.txt`, `2.11-strip-life.png` and
`2.11-strip-cairo.png` (the status bars stacked), and `2.11-jaca-bead.png` and `2.11-jaca-hat.png`.

1. **JACA colours:** *bead borders (square, blast 1)*, *war on the hat tiling*, *rainbow fronts (Cairo)* and *Life vs
   HighLife*, about 20 s each. Jimmie: the "signs [are] easy to tell apart". Jimmie didn't name the second sign's colour.
   In the screenshots the −1 palette is Koi, and it shows Koi's light end (cream → peach, a little orange) against Tide's
   teal for +1, as in rc.1.
2. **A 4-million-cell Life world** (Life, square, Tiling Size "About 4 million"; 2048 × 2048 can't be set), at Max speed:

   | GPU simulation | Status bar | Speed |
   |---|---|---|
   | Follow (auto), 1 min | "simulation: GPU" | 21–23 fps, 21–22 gens/s |
   | Off, 1.7 min | "simulation: CPU" | 25–27 fps, 26–28 gens/s |

3. **JACA at full speed:** *rainbow fronts (Cairo)* at "About 4 million" cells, Max speed. Jimmie: "looks the same" (glow
   and counts).

   | GPU simulation | Status bar | Speed |
   |---|---|---|
   | On, 1.5 min | "simulation: GPU" | 14–19 fps, about 18 gens/s |
   | Off, 1.2 min | "simulation: CPU" | 12–13 fps, 12–13 gens/s |
   | Follow, at the start of the hour | "simulation: GPU" | about 15 gens/s |

   At its own size (23,940 cells) the same preset ran at 577–762 gens/s, with "simulation: CPU (automatic: a small
   world)".
4. **"Nothing worse than 0.4.1".**

**Finding: the app simulates on the Intel UHD, not the RTX.** Hovering over "simulation: GPU" names the Intel UHD
(Jimmie). That's rc.1's D2 finding again, and with no GUI choice of adapter (2.APP 1) there's no way to move it.
- On the UHD, the GPU is *slower* than the CPU for big Life worlds (about 21 vs 27 gens/s).
- For JACA it's no faster. "On" gave about 18 gens/s, but only over the first 1,500 generations. In the hour that
  followed (2.APP 8), "simulation: GPU" held a steady 12.4 gens/s, the same as the CPU's 12–13.
- So on this laptop, "Follow (auto)" buys nothing for JACA and loses about a fifth for Life.
- The CLI jobs in this library all named the RTX (Vulkan). So the app chooses its adapter differently from the CLI,
  or Windows gives the app the power-saving GPU.

rc.1's "both over 300 fps" isn't comparable: the frame rate here tracks the generations (one per frame at Max speed),
and small worlds show 144–145 fps (the display's refresh).

## 2.APP 8: an hour of a large JACA world: pass

*JACA rainbow fronts (Cairo)* at "About 4 million" cells (wrap edges), Max speed, GPU simulation on Follow (the Intel
UHD). It ran from 13:24:34 to 14:29:39 with nobody using the app.

`mcppoll.ps1` logged `world_status` and the app's memory every 10 s, with a screenshot every 10 minutes. `appmon.ps1`
logged CPU and threads every 5 s. Files: `2.APP-hour-poll.txt`, `2.APP-hour-strip.png` (the seven status bars),
`2.APP-hour-end.png`, and `2.APP-app-mon.txt` (the whole sitting).

| Minutes | Generations | Gens/s | Live cells | Working set | Private |
|---|---|---|---|---|---|
| 0–10 | 3,280 → 10,800 | 12.7 | 2,588,524 | 340–354 MB | 655–663 MB |
| 10–20 | → 18,184 | 12.3 | 2,605,879 | 331–344 MB | 655–663 MB |
| 20–30 | → 25,499 | 12.2 | 2,615,151 | 332–339 MB | 655–663 MB |
| 30–40 | → 32,963 | 12.4 | 2,621,768 | 332–339 MB | 655–663 MB |
| 40–50 | → 40,409 | 12.4 | 2,625,965 | 332–339 MB | 655–663 MB |
| 50–60 | → 47,871 | 12.4 | 2,629,812 | 315–339 MB | 659–663 MB |
| 60–65 | → 51,584 | 12.3 | 2,630,957 | 308–319 MB | 659–663 MB |

- **No slowdown:** 48,304 generations in 64.9 minutes (12.40 gens/s), every 10 minutes within 12.2–12.7.
- **No memory growth:** private memory stayed at 655–663 MB, and the working set fell slightly.
- **Steady:** about 1.2 cores and 50–53 threads throughout.
- All 390 polls answered, with "playing" throughout; every screenshot says "Running … simulation: GPU" (10–17 fps at
  those moments). The fronts in the last screenshot have settled into large territories with glowing borders.

## Sitting A-4: 2.D 1–7, the desktop background (hands-on, 14:30–15:40)

Files:
- `2.D-log.txt`: every command, timed, with its output; full outputs in `2.D-out\`.
- `2.D-A4-monitor.txt` (renamed from `2.D-monitor.txt` in A-5): every 5 s, the host's status, its CPU (of the whole
  machine) and Windows' per-process GPU engine use per adapter, for the host and the app.
- `2.D-pauses.txt`: step 7's pause reasons and power state.
- `2.D-out\tune-crops\` (the command-line Fit's 24 crops), `2.D-crops-sample.png`, and
  `2.D-rotation-show-just-this-scene.json`.
- The scripts: `dlib.ps1`, `dmon.ps1`, `gpuwatch.ps1`, `pausewatch.ps1`.

**Setup, as rc.1's D1/D2.**
- In a clean environment, Scoop's `jetcarp` 0.4.1 `host status` gave exit 1, "not running". No JETCARP process, no
  JETCARP `Run` value, no `SCRNSAVE.EXE`. So the everyday host had nothing to stop.
- I saved the wallpaper settings (both registry keys exported, and `TranscodedWallpaper`, sha256 `85FF3BB2…`). It's
  the same picture as in rc.1.
- The candidate's host was started from the test folder: `host start` (2.4 s) and `host wallpaper on`. Then the app.
- The host and the app both run on the **Intel UHD** (Vulkan). The status says the panel is 144 Hz.

### 2.D 1. Show just this scene (#41): pass

- Jimmie opened *JACA war on the hat tiling* and clicked **Show just this scene**: "the desktop switched to the hat
  tiling".
- Saved: `rotations\jaca-war-on-the-hat-tiling.json` ("Just "JACA war on the hat tiling", made by Show just this
  scene", one profile item) and the profile `screensavers\jaca-war-on-the-hat-tiling.json`.
- The only change in `host.json` is screen 0's rotation. **The screen saver's choice stayed as it was**
  (`saver_rotation` null before and after).
- rc.1's finding (a rotation made in the app wasn't saved) is fixed.

### 2.D 2. Make a rotation in the pane (#41): pass, with a small finding

- **New → items → Save → the desktop shows it → Edit:** all work. Jimmie: "Save was easy to find".
- Jimmie first misread my instructions and added three scene files from the Desktop. Then a Quick Start entry
  (`jaca:hat-war`) was added. A profile item was shown working in step 1.
- "My rotation" is saved in `rotations\`, and screen 0 showed it (item 3 of 4 when checked).
- The order change couldn't be checked: the rotation is set to shuffle.
- **Finding:** a Quick Start entry can only be added by typing its *id* into a box hinted "Quick Start id" and pressing
  Enter. There's no list to pick from, and the ids (`jaca:hat-war`, `rule:B3/S23`) appear only in `jetcarp quickstart`.

### 2.D 3. Every generation (#42): pass

| Scene | Pacing / max | Status | Measured | Host on the UHD (Windows) | Host CPU |
|---|---|---|---|---|---|
| Life, "Until it settles" | every generation, 60 | 60 fps, 60 gens/s | 59.8 gens/s | 50% | 3.9% |
| Langton's ant | every generation, 60 | 60 fps, 240 gens/s | – | 38% | 3.6% |
| Langton's ant | every generation, `max-fps refresh` | 144 fps, 240 gens/s | – | 78% | 5.9% |
| Life | low power | 30 fps, 30 gens/s | 30.0 gens/s | 27% | 2.0% |

- **Blinkers:** Jimmie: "Even and steady". rc.1's aliasing (30 fps for 60 gens/s) is gone.
- `host status` gives the frame rate as the scene's speed for Life (60). The fast scene is capped at 60 fps on the
  144 Hz panel by default, and `refresh` raises it to 144.
- **Low power:** speed = frame rate, and the GPU share is about halved.
- Set back to `max-fps 60` and every-generation.
- (From 15:00 on, the same 3 px Life at 60 fps read 18–20% of the UHD, against 50% here and 23–29% at 14:52. I don't
  know why it varied; the 50% came during the first minutes after a rotation change.)

### 2.D 4. Fit to this computer (#38): the sweep works; the GPU timing check fails

- **The sweep:** "it swept several sizes per scene" (Jimmie).
  - Each of the rotation's 3 scenes (B3/S23, B36/S23, B368/S245) was tried at 8 sizes, 16 → 12 → 8 → 6 → 4 → 3 → 2 →
    1 px, coarse to fine: 24 crops in 48 s.
  - The command-line `host tune --json --crops` did the same (exit 0 in 49.9 s; 24 rung, 24 measured, 3 scene and 1
    done events).
  - rc.1 never got past the first size.
- **Recommended is the finest size within the limits:** 3, 3 and 2 px from the pane; 3, 2 and 3 px from the command
  line.
  - Each finer size fails on frame time (budget 15 ms at 60 fps; 2 px is 14.2–18.5 ms), and 1 px on CPU too
    (8.7–13.8%, over 8%).
  - The B36/S23 and B368/S245 2 px rungs sit right at the budget, so the two runs differ there.
- **The cards:** one row per scene, one card per size, with real frames (`2.D-crops-sample.png`). Jimmie saw "4
  recommendations, one for each".
  - The 4th row is the hat-tiling scene from an earlier **automatic** fit (`tune.auto` is on): at 14:43 the host
    fitted step 1's one-scene rotation by itself (level 4, 5.1 px, level 6; it chose 1.8 px, 280,000 cells).
  - That scene isn't in "Until it settles" but stays in screen 0's tuning, so its card row shows under it.
- **Fails: `"gpu_timing": "submission"`, not "timestamps"**, in every result: the pane's, the command line's and
  the automatic one.
  - The tuner uses timestamps only when the GPU device offers `TIMESTAMP_QUERY` (`jetcarp-host\src\tune.rs` 862–867).
    The host's UHD device evidently doesn't.
  - **Its GPU shares don't match Windows':**

    | Size | Tuner | Windows (host's process on the UHD) |
    |---|---|---|
    | 3 px | 70–73% | 19–21% |
    | 16 px | 88–92% | 8% |
    | 2 px | 59–61% | 31% |
    | 1 px | 67–68% | 8–33% |

    The CPU shares do match.
  - rc.2 no longer judges a submission-timed share (`judged_gpu`, `tuning.rs` 73–80), which is why the sweep now
    works. But it also means **the GPU limit isn't applied at all on this laptop**: B368/S245's recommended 2 px uses
    about 31% of the UHD by Windows' count, over the 25% limit.

### 2.D 5. Picks (#39): pass

| Pick | Every scene placed at | Notes |
|---|---|---|
| `host tune --pick 4` | 4 px | `tuned true` |
| `host tune --pick own` | 3 px, its own size | the status says `tuned false` |
| `host tune --pick 2` | 2 px | – |
| the pane's **Use the scenes' own sizes** | 3 px | Jimmie: "Coarser, worked". It clears screen 0's fitted sizes; the host shows 3 px, `tuned false` |

- The plan's `--pick 3` is the same as `own` here (every scene's own size is 3 px), hence 4 and 2.
- rc.1's "a pick can't undo a failed Fit" is fixed.
- Small: each `--pick` runs the whole 50 s sweep again, though the sizes were already measured.

### 2.D 6. The GPU overrides: pass, with a gap

`gpuwatch.ps1` ran `host status` and `doctor` 4 s after each change:

| Desktop background | Shared | `doctor` says | Host CPU | Host on the UHD |
|---|---|---|---|---|
| Off | auto | "off, from the desktop background's own setting (its own choice: off)" | 13.5–17.8% | 15% |
| On | auto | "on, from the desktop background's own setting (its own choice: on)" | 2–4% | 19–20% |
| Follow | auto | "auto, from the setting in gpu.json (its own choice: follow)" | 2–3% | 18–20% |
| Follow | **off** | "off, from the setting in gpu.json (its own choice: follow)", and the app off too | 14.5–17.1% | 14–15% |
| Follow | auto | "auto …" | 3% | 18% |

- The host really steps on the CPU when it should, and doctor is right every time. Jimmie: "nothing looked different
  on the desktop".
- **Gap: `host status` never shows it.** Its note stays "GPU simulation auto (the setting in gpu.json)", from start-up,
  through every change (as in rc.1). `host status --json` has no field for the current backend. So the plan's
  "`host status` and doctor must agree" isn't met.

### 2.D 7. Pauses: pass

1. **A busy processor** (`host busy` 80): I ran a detached 2-minute CPU hunt on every thread (job 11; the machine at
   89–100%).
   - About 15 s later, `paused_why` said **"the processor is busy"** and the generation froze at 6,062.
   - It resumed about 6 s after the hunt stopped.
2. **A full-screen video** (YouTube in Chrome; Jimmie used Chrome, not Edge): **"held by the desktop: windows cover
   it"** from 15:34:27 to 15:35:46, with the generation frozen at 1,279, then moving again.
3. **Battery** (`host battery on`): unplugged at 15:36:32 → **"on battery"** 2 s later, frozen at 3,876; plugged in at
   15:37:04 → moving again at once.

Jimmie: "both paused and resumed". Small: the status's `paused` field stays `false` while `paused_why` gives a reason.

### Put back

- `host stop` → "stopped", and `host status` → "not running".
- **The wallpaper is exactly as before:** the same `WallPaper`, style 10, tile 0, `BackgroundType` 0, and
  `TranscodedWallpaper` with the same SHA-256. No JETCARP `Run` value, no `SCRNSAVE.EXE`.
- The app was closed normally. No JETCARP process or monitor is left.
- The app's process peaked at 624 MB.

## Sitting A-5: 2.D 8–12 and 5.4 (hands-on, 15:40–)

Files:
- `2.D-A5-log.txt` and `2.D-A5-out\`.
- `2.D-monitor.txt`: every 3 s; it now also logs `paused_why`. A-4's monitor is `2.D-A4-monitor.txt`.

**Setup:** the candidate's host from the test folder, with the wallpaper on (Life, "Until it settles", 60 fps), plus the
app and the monitors.

### 2.D 8. Sleep and wake: pass

- As the screen went off (15:44:09), the host held: "held by the desktop: the screen is locked or off", frozen at
  generation 2,846.
- The laptop slept (S3) from 15:44:12 to 15:45:05. On waking, the host stayed held on the sign-in screen and resumed 2 s
  after Jimmie signed in (15:45:16).
- The same process throughout (pid 56296), with no error. Jimmie: "the desktop was live again after waking".

### 2.D 9. The lock screen: pass

- Win+L: the host held ("the screen is locked or off") from 15:46:35 to 15:47:23 and resumed on unlock.
- Jimmie: "lock screen showed Windows' picture, desktop live after". That's expected: `host lock` is for GNOME only.

### 5.4. The graphics driver resets: no disruption; the recovery path wasn't exercised

- First try (Win+Ctrl+Shift+B): "no screen blank … everything is running normal". Nothing in the logs. The app had
  been minimized (its CPU and GPU at 0, no title), so that drop wasn't a reset.
- Second try, with the app visible and running a world: "no flash, but there was a very quick bleep", which is
  Windows' sound for the reset. It came just after 15:52:06.
  - The host and the app kept running on the UHD with **no gap** in the 3 s monitor.
  - The host stayed at 60 gens/s, with the same processes and nothing new in its log. The app's GPU share was steady
    (41–55%).
  - Windows logs nothing for this shortcut.
- So the reset disturbed neither program. Whether either lost its GPU device and re-created it can't be seen, so the
  "device re-created or CPU with a note" path wasn't exercised.
- A real driver timeout would need administrator tools (`dxcap -forcetdr`, or a TDR registry setting), which weren't
  used.

### 2.D 12. A host crash: pass, with a note on `host still`

| Case | What happened | The desktop (Jimmie) |
|---|---|---|
| `Stop-Process -Force` on the host (`still` off) | The launcher exited too; nothing restarted it; the wallpaper settings unchanged | "My own wallpaper" |
| `host start` | Back live in 3 s (new pid, "wallpaper: showing") | – |
| `host still on`, then a hard kill | No still was set, either while running or after the crash; the settings unchanged | "My own wallpaper" |
| `host still on`, then a clean `host stop` | A still written (`config\desktop-pictures\still-….png`, 40 KB) and set as the monitor's wallpaper (`Transcoded_000` became 43,763 bytes; `HKCU …\WallPaper` unchanged) | "A still of Life" |
| `host still off` | "put the desktop's own picture back"; `Transcoded_000` back to the original (249,170 bytes, dated 11-10) | "Yes, my own" |

So a crash always leaves the user's own picture. `host still` works for a clean stop but can't cover a crash, since
nothing is left to set the still. The plan's "or a still if `host still` is on" doesn't happen after a crash.

### Steps 10–11: in Jimmie's account, with the default folders

The login entry and the screen saver are started by Windows with no `JETCARP_*` variables. JETCARP finds its folders
only through them (`jetcarpw.rs`, `paths.rs`), so in Jimmie's account these use the **everyday folders**
(`%APPDATA%\jetcarp`, `%LOCALAPPDATA%\jetcarp`).

Jimmie chose to run them here anyway: "JETCARP on this laptop is only for testing … I don't care if we nuke it, as
I'll be reinstalling once 0.4.2 ships". I copied the everyday settings folder first (`app.json`, `setup.json`,
`host-program`; no `host.json`).

### 2.D 11. The screen saver: pass

- Jimmie ran, in a new PowerShell window: `jetcarp.exe host saver install --rotation "Wolfram series"` (the candidate's
  exe).
  - It copied the launcher to `%LOCALAPPDATA%\JETCARP\JETCARP.scr` (identical to `jetcarpw.exe`) and set
    `SCRNSAVE.EXE` to it.
  - It opened Screen Saver Settings with it selected (wait 1 minute, as before).
  - It wrote `host.json` (`saver_rotation` "Wolfram series") and `host-program` (the candidate's `jetcarpw.exe`) into the
    everyday settings folder.
- **"The screen saver showed the Wolfram series"** (Jimmie). The preview ran as `JETCARP.scr /p` → `jetcarp.exe host scr
  /p`.
- `host saver status`: "JETCARP is the selected screen saver".
- `host saver remove` while Screen Saver Settings was still open: exit 1, **"…JETCARP.scr is in use, most likely by the
  preview in Screen Saver Settings. Close that dialog, then run `jetcarp host saver remove` again. Nothing was
  changed."** A clear refusal.
- After Jimmie closed the dialog: "removed". `SCRNSAVE.EXE` is empty again (`ScreenSaveActive` 1, wait 60, as before),
  and the `.scr` is gone. Status: "JETCARP's screen saver is not installed".

### 2.D 10. Start at login: pass

- **Setup, in the default folders:** `host start`, `host wallpaper on`, `host rotation "Classics, hourly"` (it showed
  Life, 1 of 7), then `host stop`. Saved: screen 0 "Classics, hourly", place wallpaper, still off.
- **`host login on`** (auto mode allowed it this time): "… starts at login". The `Run` value `JETCARP` =
  `"C:\Users\jimmi\jetcarp-rc-042b\bin\jetcarpw.exe" host serve --login`.
- **The logout:** I closed the test app, stopped the monitors and pushed. Jimmie signed out and back in, then resumed
  this session in VS Code.
- **After signing in, the host started with the saved rotation.** Jimmie: "desktop eventually showed Life. It took a
  couple of minutes to start".
  - `host status`: "Classics, hourly · profile Life (1 of 7) · 230400 cells of 3 px · 30 fps · wallpaper", with
    "wallpaper: showing".
  - The process was `jetcarpw.exe host serve --login` → `jetcarp.exe host serve --login`.
- **The delay is Windows' order.** The Shell-Core log shows Windows running the `Run` entries one at a time, waiting up
  to 30 s for each:
  - sign-in (Explorer) at 16:15:13;
  - another program at 16:15:32;
  - another program from 16:15:49 to 16:16:19, and another program from 16:16:19 to 16:16:49 (each the full 30 s);
  - JETCARP's entry at 16:16:50, 97 s after sign-in, and the host running at 16:16:53.
- **Small:** Windows logged JETCARP's entry as finished only at 16:17:20. The launcher stays running as the host's
  parent, so Windows waits its full 30 s, which would hold up any entry listed after it. It was last here.
- **Undone:** `host login off` → "the host no longer starts at login", and the `Run` value is gone. `host stop` → the
  wallpaper unchanged (same hash).

### Putting the everyday folders back

- **The everyday library was never written:** `library.sqlite` and the searches are still dated 11-12 or 11-13.
- **The candidate wrote into the everyday settings folder:** `host.json`, `gpu-checks.json`, and a new `host-program`
  (the candidate's launcher).
  - I removed the first two and copied back the three files saved before steps 10–11. All three now match the copy,
    and `host-program` again names Scoop's `jetcarpw.exe`.
  - Scoop's 0.4.1 then printed `library info` (schema 3, 98 patterns, 33 jobs) and "not running" for the host.
- **A note for later waves:** the everyday data folder has a `host.lock` dated 14:36:21, the moment A-4 first started
  the *test* host.
  - The host's single-instance lock and the endpoint files go to `JETCARP_RUNTIME_DIR`, else `%LOCALAPPDATA%\jetcarp`
    (`paths.rs` `runtime_file`).
  - My test setup sets only `JETCARP_CONFIG_DIR`, `JETCARP_DATA_DIR` and `JETCARP_OUT`. So a test host and an
    everyday host share one lock: there's one host per user, whichever folders it uses.
  - That's by design and harmless (an empty file), but test setups should set `JETCARP_RUNTIME_DIR` too.

## Left in place

- `jetcarp-rc-042b`:
  - Phase 1's settings and library (job 2 paused) are in `phase1\`, beside `P14b-pack`, `import14b`, and `src`
    with its release build.
  - Phase 2's settings and library are in `config\` and `data\`, with outputs in `phase2\`.
    - The library holds jobs 1–10; A-3 added catalog-hunt's finds and 80 media rows.
    - The `A10-pack` and `import10` folders are in `phase2\`.
    - A-3's scripting examples are in `out\` (hexw3-atlas: 19,683 PNGs, 378 MB).
  - Settings after A-3: the setup wizard finished as "blank slate"; AI control was on when the app closed, and it
    stays off at launch.
- `jetcarp-rc-042`: the rc.1 test folder.
  - Settings after A-4:
    - two saved rotations in `config\rotations\` ("JACA war on the hat tiling", "My rotation");
    - screen 0 on "Until it settles", with no fitted sizes; every-generation pacing, `max-fps` 60, battery on;
    - the shared GPU setting auto, and both GPU choices on follow.
  - The library has hunt job 11 (paused after its 2 minutes).
  - After A-5: the test settings have `host still` off again; the hosts' saved rotations are unchanged since A-4.
- The everyday folders are as before A-5: the settings folder restored, and the library untouched. They also hold a
  `host.lock` (empty) from the test hosts.
- No JETCARP login entry, no screen saver (`SCRNSAVE.EXE` empty), no JETCARP processes. The wallpaper is Jimmie's own,
  unchanged. 1.5 has not run.
- Phase 2 is through A-5. Next is A-6 (Parts 4 and 5: MCP and robustness; 5.4 was done in A-5). 2.12 (A12, opening a
  copy of the everyday library) isn't in any sitting yet.
