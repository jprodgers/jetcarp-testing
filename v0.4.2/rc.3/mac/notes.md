# v0.4.2-rc.3 on the Mac: notes

System as in rc.1 (`../../v0.4.2-rc.1/mac/00-system.txt`): macOS 27.2.1, Apple M2 Max (12 cores,
38-core GPU, Metal 4), 64 GB, on mains, the built-in panel only. Everyday JETCARP: Homebrew's 0.4.1,
untouched. Test folder `~/jetcarp-rc-042c` (`$T`), with `JETCARP_CONFIG_DIR`, `JETCARP_DATA_DIR`,
`JETCARP_OUT` and `JETCARP_RUNTIME_DIR` in it. The plan allows the default folders on the laptops; a
fresh folder kept the job numbers as the plan's (hunt 1, explore 2) and Homebrew's folder out of it.

## Phase 1 (unattended, 2026-11-16 00:26–04:42 UTC)

`phase1.sh` (with the helper `p1.py`), run as `caffeinate -is bash phase1.sh`. Its log is
`phase1.log`, and its one-line results are `summary.txt`. Order: 0, 1.6, 1.1, 1.2, 1.3, 1.4.

**My mistake, and the restart.** In the first run, 1.4's probe read the status with
`IFS='|' read … <<< "$($P1 status …)"`. In macOS's bash 3.2 the temporary `IFS` also applies to the
word splitting of `$P1` inside the here-string's `$( )`, so the helper never ran and the status
fields came back empty. The first four minutes of 1.4 have no status in `1.4-watch.txt`. At 00:44 I
stopped the script only (bash and its caffeinate, by pid). The search (pid 27989, reparented to
launchd) ran on untouched. I fixed the read and restarted the script with `P1_JOB=2 P1_T0=<its start>`,
which skips 0–1.3 and adopts job 2 on its own clock (started 00:40:45; kill due at +60 min). Nothing
in the search's timing or results is affected.

### 0. Unpack and doctor: pass

`0-unpack.txt`, `0-doctor-first.txt`, `0-doctor-second.txt`.
- `jetcarp-0.4.2-rc.3-aarch64-apple-darwin.tar.gz` (29.5 MB): SHA-256 `2125d411…ba39daac`, as in
  `SHA256SUMS` and the start note. Provenance xattr only. `jetcarp 0.4.2-rc.3`.
- First doctor on the fresh folder: "self-test: passed (191 ms): 59 world rules and 33 explore
  batches matched the CPU", and it wrote `gpu-checks.json`. The second: "passed (191 ms, kept from
  before)". Both under a second.

### 1.6 The deterministic hunt: pass

`1.6-hunt.json`, `1.6-status.{json,txt}`. Hunt job 1, 12 s (10,519 soups/s): 760,892 objects (ships
51,012, osc 236,468, still 473,412), 1,783 distinct. `progress.groups`, `by_class`, the counts and
even the `newest` list are identical to rc.2's Mac (and so to the Framework's and the Acer's).

### 1.1 Parity, 371 scenes, Metal: pass

`1.1-metal.{csv,txt}`. "371 scenes: CPU matches 371, GPU matches 371; all 300 generations on the GPU
in 334", 73 s.

### 1.2 Long-run parity, 40 scenes × 5,000 generations, Metal: pass

`1.2-metal.{csv,txt}`. "40 scenes: CPU matches 40, GPU matches 40; all 5000 generations on the GPU in
40", 64 s.

### 1.3 The whole test suite: pass

`1.3-tests.txt`. The tag cloned with depth 1, at **400d41d**. `cargo test --release --workspace
--no-fail-fast` in a scratch `HOME` with no `JETCARP_*` variables: **1,027 passed, 0 failed, 33
ignored, in 141 test binaries**, 11 min, exit 0. The ignored ones are as in rc.2 (screenshots,
offscreen windows, surveys and timings, the slow and heavy ones).

### 1.4 A long search (240 min) with a crash in the middle: pass

Files: `1.4-start.json`, `1.4-watch.txt` (a probe a minute: the runner's pid, RSS, footprint and CPU,
then the status), `1.4-memory.csv` (every 5 min), `1.4-status-before-kill.*`,
`1.4-status-kill-{1,3,5,10,20,30}.json`, `1.4-list-{before,after}-kill.*`, `1.4-wait-after-kill.txt`,
`1.4-resume.txt`, `1.4-wait-after-resume.txt`, `1.4-status-end.*`, `1.4-footprint-{1h,2h,3h,end}.txt`,
`1.4-vmmap-{1h,2h,3h,end}.txt`, `1.4-key.txt`, `1.4-export.txt`, `1.4-check.txt`, `1.4-import*.`

1. **The search:** `search explore --minutes 240 --label long --detach --json`, job 2, at 00:40:45.
   Runner `…/bin/jetcarp jobs resume 2 --library … --quiet --minutes 240`, on "Apple M2 Max, Metal".
2. **The first hour:** 271,502 runs by the kill, 28,114 elites in 13,471 niches, 1,261 confirmed.
3. **The kill (#49): pass.** `kill -9` at +60 min (01:40:56). `jobs status --json` said `"stale": true`
   at +1.2 s and at every probe after (+3, 5, 10, 20, 30 s), and the text says "status stale". The
   JSON's `status` field still says `running` beside `stale: true`. `jobs list --json` at +30 s: stale
   true. `jobs wait 2 --timeout 180` exited 6 (gone) at once.
4. **The resume (#50, #51): pass.** `jobs resume 2 --detach` (0 s) said: "explore search 2 keeps the
   budget it was started with: 2 h 59 min left of its 4 h 0 min of running (give this run a budget of
   its own to change that)". The new runner has `--minutes 179.84`. **`jobs wait 2 --timeout 2` straight
   after exited 5** (still running). It picked up from the last checkpoint (270,944 runs, 1,186
   confirmed). It **ended by itself** 179 min later (`jobs wait` exit 3, paused), at **239.6 min** of
   search in all.
5. **The end:** "explore 2: 1,142,553 runs, 52,560 elites in 23,474 niches (3,327 of them confirmed),
   556 of 1,359 tilings", 17,664 confirmation runs. `jobs runs` lists 1,142,553 (stage 1) and 17,664
   (stage 2). **The rate said 0/s in 1 of 239 probes**, the first one 5 s after the resume (#22's
   opening line); median 78/s (rc.2: 75/s). In 4 h: 1,160,217 runs, against rc.2's 1,138,247.
6. **The pack, with no `jobs seal` (#35): pass.** `pack export --to $T/rc3-long --feed rc3-long
   --no-media` (2 s): "explore job 2 (search 9ca7d1d5…): sealed its newest 160,217 runs first, so the
   pack carries every run". **86 MB.** `pack check`: exit 0.
7. **The import (#35, #54): pass.** Into a fresh library (5 s): explore 1 ("paused … not run here
   yet") and hunt 2. Stage 1: 1,142,553 runs; stage 2: 17,664. **Every row is the same** as the
   search's (all columns but the id, compared as multisets). **Confirmed elites: 3,327 in the search
   and 3,327 in the import** (rc.2: 3,321 against 3,314).

### #53 on macOS: the search holds 1–1.7 GB; the rest of the RSS is free memory the allocator keeps

The status's "GB of memory" is the RSS. It climbed as in rc.2: 5.6 GB at the kill, 5.0 GB at 2 h,
7.3 GB at 3 h, **8.6 GB at the end** (ps RSS peak 9.0 GB; rc.2: 5.5 and 7.5 GB). But the **physical
footprint** (what macOS charges the process, Activity Monitor's Memory column) stayed small:

| Search time | RSS (status) | Footprint | Malloc Small: dirty / **reclaimable** | Malloc Large | GPU (graphics) |
|---|---|---|---|---|---|
| 60 min (before the kill) | 5.60 GB | 533 MB | 67 MB / **5,231 MB** | 255 MB | 141 + 41 MB |
| 120 min | 4.97 GB | 1,261 MB | 174 MB / **4,527 MB** | 333 MB | 573 + 154 MB |
| 181 min | 7.25 GB | 1,069 MB | 175 MB / **6,719 MB** | 351 MB | 425 + 81 MB |
| 239 min (40 s before the end) | ~8.6 GB | 1,629 MB | 179 MB / **7,903 MB** | 677 MB | 575 + 155 MB |

(From `footprint`. `vmmap --summary` agrees: "Malloc Small (empty)" is 4.3 GB at 1 h and 6.0 GB at the
end, and its physical-footprint peak is 2.5 GB. The 5-minute samples' footprint peaked at 1.7 GB.)

So almost all of the growth is **Malloc Small pages that are free but still resident**, marked
reclaimable: macOS's allocator hands freed pages back with `MADV_FREE_REUSABLE`, which keeps them in
RSS until the kernel needs them, and doesn't count them in the footprint. The memory the search
really holds is the footprint, 0.5–1.7 GB, of which up to ~0.7 GB is GPU buffers. Nothing in it grows
steadily. (`malloc_trim` has no macOS equivalent, and here none is needed.) One suggestion for the
main session: on macOS, the status's figure could be `phys_footprint` (`task_info` with
`TASK_VM_INFO`) instead of RSS, which would read about 1.5 GB here rather than 8.6.

### Afterwards

Homebrew's 0.4.1 is still `jetcarp`. The everyday folder's newest file is unchanged during Phase 1
(2026-11-15 19:09 EST; it was written before this session started, not by the candidate). No
`jetcarp` process left running.

# Phase 2, sitting M-1 (2026-11-16, from 06:15 UTC; Jimmie at the Mac)

**Set-up:** Phase 2 runs on empty settings and an empty library, so job numbers match the plan. Phase 1's
`config`, `data`, `out`, its import and pack are moved to `$T/phase1/`. The environment is `env2.sh`
(the same four `JETCARP_*` folders, `JETCARP_GPU` and `WGPU_BACKEND` unset).

## 2.0 Unpack and check: pass

`2.0-unpack.txt`, `2.0-doctor-{first,second}.txt`, `2.0-21-26-47.txt`.
- **Hash:** a fresh download checks against `SHA256SUMS`, and its 70 files are identical to `bin`.
  `jetcarp 0.4.2-rc.3`. `paths` names settings, data and output under `$T` only. Provenance xattr only;
  no security prompt (as in Phase 1).
- **Everyday copy:** `which jetcarp` is still Homebrew's, `jetcarp 0.4.1`.
- **#17:** the first doctor on the empty settings took 0.2 s: display and compute "self-test: passed
  (185 ms)", with no "kept from before", and `gpu-checks.json` written (one adapter: the M2 Max on Metal).
  The second said "passed (185 ms, kept from before)", in under 0.1 s.
- **#21:** `JETCARP_GPU=nosuchgpu run --gpu --gens 300 --json parity/scenes/0.json`: backend "gpu (Apple M2
  Max, Metal; no nosuchgpu adapter was found, so the best one)", hash `d9c87f6d4f91849f`, as in `expected.csv`.
- **#26:** with `WGPU_BACKEND=metal`, doctor's Environment block lists `WGPU_BACKEND=metal` (and the four
  `JETCARP_*` folders, `JETCARP_RUNTIME_DIR` included).
- **#40:** display: "the app and the desktop background simulate on it"; compute: "runs, searches and
  scripts simulate on it". Both are the M2 Max ("the adapter driving the screen", "the fastest adapter").
- **R #47:** `search explore --help`: "--limit … An explore search checks it between steps, so it finishes
  the step it is in and may run past it". **Pass.**
- **Small finding:** `jetcarp paths` names settings, data, output and bundled, but not the runtime folder
  (`JETCARP_RUNTIME_DIR`, where `host.lock` goes since A-5's finding); doctor's Environment block does
  show the variable.

## 2.G1 The GPU's self-test: pass, with a small finding

`2.G1-doctor.txt`. `gpu-checks.json` removed before each:

| Way | Self-test |
|---|---|
| automatic | passed (202 ms) |
| `JETCARP_GPU=M2` | passed (167 ms); "why: named M2, as asked (JETCARP_GPU=M2)" for both |
| `JETCARP_GPU=Apple` + `WGPU_BACKEND=metal` | passed (195 ms); named Apple, `WGPU_BACKEND=metal` listed |
| `JETCARP_GPU=off` | both lines: "not used, and not tested: the GPU simulation is off" |

- Every test: "59 world rules and 33 explore batches matched the CPU". Each doctor took 0.2 s.
- (My first try at the third row passed both variables as one, because the Bash tool runs zsh, which
  doesn't split `$envs`. It showed the fallback note for a name that matches nothing: "no Apple
  WGPU_BACKEND=metal adapter was found, so the best one". The row above is the rerun.)
- **Finding:** with `JETCARP_GPU=off`, doctor says "not used, and not tested", but it **does run the
  self-test and writes `gpu-checks.json`** (192 ms, then 165 ms, from an empty cache). The next automatic
  doctor then says "kept from before". Harmless, but the line isn't true. (The Acer's rc.2 `off` doctor
  took 2.5 s against 0.8 s cached, which suggests the same there.)

## 2.1 GPU explore search (M1): pass

`2.1.sh`, `2.1-explore.{out,err}`, `2.1-status.{txt,json}`, `2.1-sample.csv`. `search explore --families
life_like,generations,jaca,cyclic --minutes 10 --label gpu-mix`, no `--gpu`, 06:19–06:29 UTC.
- **Status:** "explore 1: 57,109 runs (103/s), 9,989 elites in 4,996 niches (419 of them confirmed), 34 of
  1,359 tilings; Apple M2 Max, Metal". 1,860 confirmation runs, 2.19 GB (RSS). "6 for runs on the
  processor and 4 for the GPU's batches, of 12 cores (2 left free)".
- **Families:** life_like 24,949, generations 19,929, jaca 9,238, cyclic 2,993. The runs CSV has 57,109 rows
  (not committed). (The Acer's RTX: 32,598 runs at 48/s.)
- **#22:** 98 progress lines give a rate: median 87/s, max 158/s. The only 0/s is the opening "0 runs" line.
- **#24:** every progress line says "(N of them confirmed)". The count rises in steps (each confirmation
  batch) and falls a little between them, e.g. 96 → 67, 248 → 219, 451 → 418, as elites are replaced.
- **Usable:** Jimmie: "Usable, no lag". The search's process used 2.5 cores on average (11.7 at a moment's
  peak), with RSS up to 2.4 GB and a footprint up to 1.45 GB.
- **Errors and warnings:** none.

## 2.2 GPU runs replay the same on the CPU (M2): pass

`2.2-check.py` (the Acer's `2.2-check.ps1` in Python), `2.2-check.txt`, `2.2-replays.csv`, `2.2-hashes.csv`,
`2.2-jaca.json`, `2.2-life.json`. The top 20 JACA and 10 Life-like runs of job 1, with all their measures.
- **Replays:** **30 of 30** match: `measures.density` equals the CPU replay's population / cells to 6
  decimals. All replays ran on "cpu (12 threads)".
- **Hashes:** **5 of 5** (3 JACA, 2 Life-like) are the same on `--cpu`, `--gpu` (Metal) and no flag. With no
  flag, the JACA scenes and one Life-like scene on `hex` ran on the CPU; the Life-like one on `square` ran on
  the GPU.
- **Cells:** as on the Acer, every run stores the 16,000 cells asked for (#27); the replays have
  15,696–16,200, except run 41744 (JACA B15/S0123 on `penrose-rhomb`) with **35,000** (#55, in 0.4.3).

## 2.3 CPU-only explore confirms, stop and resume (M3): pass

`2.3.sh` (the Acer's `2.3-steps.ps1` in bash), `2.3-log.txt`, `2.3-explore.{out,err}`, `2.3-resume.txt`,
`2.3-status.{txt,json}`. `search explore --cpu --families jaca --minutes 10 --label cpu-jaca`; after 5 min,
`jobs stop 2`, `jobs wait 2 --timeout 60`, then at once `jobs resume 2 --minutes 4`.
- **Confirms:** "1,278 runs, 393 elites in 215 niches (21 of them confirmed)", 90 confirmation runs, 8 min
  57 s in all. Both counts are above 0.
- **Stop to wait:** `jobs wait` returned **exit 3 (paused) 1.15 s after the stop**, with the explore process
  already gone (the Acer: 2.01 s).
- **#16:** the resume straight after was accepted (exit 0) and ran its 4 minutes.
- **Speed:** JACA on 10 CPU threads, about 2 runs a second (the Acer: 1.3). At that pace 4 of 52 progress
  lines in the first session say 0/s (and 3 in the resumed one), as on the Acer: not #22's GPU case.
  7 runs stopped at their time cap; 10 given up at the stop or the end.

## 2.4 The smart JACA search (M4): pass

`2.4.sh`, `2.4-explore.{out,err}`, `2.4-status-13s.txt`, `2.4-status.{txt,json}`, `2.4-origins.txt`.
`search explore --gpu --families jaca --parents-from 2 --reviewed keep,maybe --minutes 6 --label smart-jaca`
(job 3).
- **#25:** at the start, "parents: 500 JACA runs of explore job 2 (its best ones: it has no reviews with the
  verdicts asked for); 379 with both signs holding to the end". The same line is in `jobs status 3` at 13 s
  and at the end. No error.
- **Result:** 24,366 runs, 3,901 elites in 1,963 niches (243 of them confirmed), 861 confirmation runs, on
  the M2 Max (Metal). (The Acer's RTX: 13,236 runs.)
- **Rates:** 0/s only in the opening line; median 58/s, max 105/s.
- **Origins:** random 28.4%, mutate 17.8%, balance 14.0%, transplant 12.3%, cover 9.6%, seed 9.0%,
  transplant-scaled 9.0%. All seven are there, and random is the largest, about 30%.
- **Signs:** with `--measures all`, the five `sign_*` columns (`sign_pos`, `sign_balance`, `sign_sorted`,
  `sign_trade`, `sign_lost`) are filled for all 24,366 JACA runs.

# Phase 2, sitting M-2 (2026-11-16, from 06:45 UTC)

## 2.5 The rating page in Safari and Chrome (M5): pass; R #56 pass

- **#29 and R #56:** `jobs clips 3 --sample 48 --px 180 --page --out 2.5-clips` wrote **48 clips** in 8.8 s and said
  how the round is made up: **"categories: Battles 48"**. Frozen at once, Quick deaths, Static and Quiet got
  none (the cap is 3 each; rc.2's Acer round gave Frozen at once 20 of 48).
  - Fates in the round: running 35, cycle 12, froze 1, across 18 tilings. Job 3's runs are 59% running, 21%
    cycle, 10% died and 10% froze. A 220-clip draw (seed 2) was all Battles too, running and cycle only.
  - Files: `2.5-clips.txt`, `2.5-clips-manifest.json`, `2.5-clips-index.html` (the GIFs stay out of the repo).
- **Safari** (`open -a Safari …/index.html`, macOS in dark mode). Jimmie rated all 48 honestly: **4 keep,
  15 maybe, 29 drop, 3 stars**. His note: "Lots of static."
  1. The keys: "Keys worked".
  2. After reload (⌘R): "ratings stayed after reload". Safari keeps the page's storage for a file:// page.
  3. Save downloaded `~/Downloads/ratings-2.5-clips.json` (4,460 bytes; "jetcarp-ratings 1", job 3, round
     "2.5-clips", the search's uuid, rater, note and 48 ratings). Committed as `ratings-2.5-clips.json`.
  4. Light and dark: "Looked good in light and dark".
  5. Clumsy? "it functions fine".
- **Chrome:** "chrome works fine" (keys and reload). Jimmie didn't press Save there, so only Safari's file exists.
- **Reading them back:**
  6. `jobs review 3 --from … --rater "Jimmie Rodgers"`: "recorded 48 review(s) and 3 star(s) by Jimmie Rodgers (0
     for runs not in job 3, 0 already recorded); job 3 has drop 29, keep 4, maybe 15, ★ 3", then the note.
  7. The second time: "recorded 0 review(s) and 0 star(s) … (… 51 already recorded)". Nothing was added.
- **#33:** `jobs runs 3 --reviewed any --limit 100` lists the 48, ending `[keep ★]` (3), `[keep]` (1), `[maybe]` (15)
  and `[drop]` (29) (`2.5-reviewed.txt`).
- **Observation for #56:** the caps took the dead and frozen runs out of the round, as meant. But Jimmie still
  dropped 29 of 48 "Battles", with "Lots of static": many running JACA runs look like static noise, and the
  categories don't tell them apart.

## 2.6 Refit, score and export (M6)

**The first refit refused**, clearly (exit 1): "replaying on Apple M2 Max, Metal / Error: a fit needs at least 20
reviewed runs with 5 keeps and 5 drops; these have 48 runs, 4 keeps and 29 drops / review more runs: jobs clips
makes clips to rate, jobs review records the ratings" (`2.6-refit-1.txt`).

**Second round (as the Acer did):** job 3's 48 highest-scoring unrated runs (`2.6-ids.txt`; score 1.63–2.11;
running 24, cycle 24; 8 tilings), with `jobs clips 3 --ids … --page`. Jimmie rated all 48: **0 keep, 9 maybe,
39 drop**, no stars. His note: "One of the worst sets yet." (`ratings-2.6-clips.json`.) `review`: "recorded 48
review(s) and 0 star(s) …; job 3 has drop 68, keep 4, maybe 24, ★ 3".
- **So the built-in score's top runs of this search are ones Jimmie drops.** On the Acer's rc.2 job 3 the same
  round gave 11 keeps of 48. That is what a refit is for, but it can't fit without 5 keeps.
- Jimmie asked whether more data would help, and offered to rate 2–3 times as many at a time ("48 is a small
  sample"). **Third round: 144 clips**, a broad draw rather than the top scores: the program's own sample
  (`jobs clips 3 --sample 220 --seed 2`) less the 96 rated, first 144 (`2.6b-ids.txt`; running 120, cycle 24;
  score 0.21–1.55; 13 tilings). Rendered in 28 s (29 MB).
- Jimmie rated 143 of the 144: **3 keep, 12 maybe, 128 drop**, no stars. His note: "Mostly static or ones that
  settle to a single sign." ("pretty terrible"; `ratings-2.6b-clips.json`.) `review`: "recorded 143 review(s) …;
  job 3 has drop 196, keep 7, maybe 36, ★ 3".

**The refit, now with 7 keeps: pass** (exit 0; `2.6-refit.txt`, `2.6-model.json`):
- "replaying on Apple M2 Max, Metal / fitted to 239 review(s) of 239 run(s) of explore job(s) 3 by Jimmie Rodgers
  (7 keep, 36 maybe, 196 drop; jaca runs only)".
- **"held-out AUC 0.806 (keep against drop; on the runs fitted 0.885; the built-in score 0.468)"**. The built-in
  score is worse than chance on Jimmie's ratings of this search; the Acer's rc.2 fit gave 0.850 (built-in 0.779).
- Strongest terms: `jaca:sign_sorted` +0.381, `jaca:sign_trade` −0.288, `same_nb` −0.247, `movers` +0.233,
  `growth` +0.192, `settle_frac` +0.187, `density_late` −0.164, `jaca:sign_balance` +0.146, `largest` +0.144,
  `travel` +0.144. Sorted territories and movement up, trading and late density down: Jimmie's "static" and
  "settle to a single sign" in numbers.

**The rescore and the scored search: pass** (#30, #36):
- **Rescore** (exit 0): "rescored 25227 runs of explore job 3 by the score model 'Jimmie Rodgers, jaca on explore
  job 3' (for jaca runs) (20405 scores changed); the archive now holds 3901 elites in 1963 niches (1.5 s)".
- `jobs status 3` now says "(173 of them confirmed)" (243 before) and "score: the score model 'Jimmie Rodgers, jaca
  on explore job 3' (for jaca runs)".
- **The scored search** (job 4, `--gpu --families jaca --score 2.6-model.json --minutes 3`, exit 0) printed
  "score: the score model '…' (for jaca runs)" right after its job line; `jobs status 4` has it too. 12,840 runs
  (78/s), 2,101 elites, 72 confirmed, on Metal; no errors.
- **`2.6-all.csv`** (5.9 MB, not committed): 12,840 rows (= job 4's runs), 41 fields in every row (a strict CSV
  parse), ASCII, no BOM, LF; the five `sign_*` columns. `2.6-five.json`: 5 runs, 26 measures each. Not opened in
  a spreadsheet app.

## 2.7 Jobs wait and memory caps (M7): pass

`2.7.sh` (with `lib2.sh`); the log is `2.7-log.txt`, each call's output in `2.7-out/`.
1. **Exit codes as expected:**
   - **0:** `search hunt --soups 3000 --detach --label wait-done` (job 5, 0.2 s); `jobs wait 5` exit 0 after 1.6 s
     ("hunt 5 is done", 1,878 soups/s).
   - **The capped hunt** (job 6) paused at once: "memory 0.1 GB is over the cap of 0.05 GB"; `jobs status 6` has
     the note. **3:** `jobs wait 6 --timeout 5` exit 3 at once.
   - **6:** `search hunt --soups 2000000 --detach --label to-kill` (job 7) runs as one process, `…/jetcarp jobs
     resume 7 --library … --quiet`, killed with `kill -9` at 10 s. **`jobs status 7` 0.1 s later: "stale: marked
     running, but no process is running it"**, and **`jobs wait 7 --timeout 120` exit 6 in 0.1 s** (rc.2's
     Acer: 43.8 s; #49). `--timeout 2`: 6 again at once.
2. **Gone at once**, not after the ~45 s heartbeat, thanks to #49.
3. **Job 7 resumed:** `jobs resume 7 --minutes 1` exit 0 after 60.1 s, from 24,067 to 171,450 soups, paused at its
   budget.
4. **#31:** with `JETCARP_GPU=off`, `search hunt --gpu --soups 500 --label no-gpu` (job 8) exit 0 and printed
   "the GPU was asked for, but JETCARP_GPU=off: running on the processor".
5. **#32:** every `jobs wait` printed one progress line; none waited long enough to watch a line change.

## 2.8 Rules, names and progress (M8): pass

`2.8.sh`; `2.8-log.txt`, `2.8-out/`.
1. **Both V rules run as edge-neighbourhood Generations rules:** `B47/S13568V/4` froze at generation 6 and
   `B3/S23V/C4` at 11 (exit 0). Their saved scenes' CA: `{"neighborhood":"edge","rule":"B47/S13568/C4"}` and
   `{"neighborhood":"edge","rule":"B3/S23/C4"}`.
2. **`B4v7/S2`** exit 1: "Error: a V goes at the end of the rule or right after its B or S counts: B47/S2V".
3. **The bad rules file is refused before anything runs:** exit 1 in 0.0 s, "Error: 1 rule cannot run, so the
   job was not started: / line 3 of …/2.8-rules.txt: B4x/S2: 'x' is not a neighbour count". No job was made: the
   next hunt is job 9, right after job 8.
4. **"hunt 9: 30/30 soups in each of 6 groups, 1152 soups/s, …"** (#8), one line per group, on Metal.

## 2.9 `library soup` and the scripts (M9): pass

`2.9.sh`; `2.9-log.txt`, `2.9-list.{txt,json}`, `2.9-soups/`, `2.9-scan.txt`, `2.9-best*.json`,
`2.9-jaca-territories.txt`. `library list --class spaceship --limit 10` lists 6: two c-ships (B2/S34, hunt 9) and
the glider, HWSS, MWSS and LWSS (B3/S23), as on the Acer.
1. **Each rebuilt soup produces its ship**, in the census (`objects --json`) at exactly the Acer's generations:
   c-ships `12334684`, `484e9fe1` at 50; glider `5a080db3` 400–2,000; HWSS `1376072e` 800–1,200; LWSS `6dd55e69`
   1,200–1,600; MWSS `77364004` 2,000–2,500.
2. **`--best 3` wrote three scenes** (5.0 s): "the best 3 of 10000 soups run again": soups **4526** (38 ships),
   **7794** and **9324**, the same three as rc.1 and the Acer.
3. **The JACA example** (`script --example jaca-territories`, exit 0, 1.65 s) prints the same five lines as rc.1
   and the Acer (sorted 0.01 → 0.991, fronts 4,508 → 122, balance 0.496 → 0.399) and wrote `final.png`,
   `run.json` and `territories.csv` to the output folder.

## 2.10 Packs with schema-2 runs (M10): pass; R #54 and #57 pass (one leftover, known)

`2.10.sh`; `2.10-log.txt`, `2.10-out/`, `2.10-check.txt`, `2.10-import.txt`, `2.10-import-jobs.txt`.
- **As on the Acer,** `jobs status 3 --json` has no top-level `folder`; it's `progress.folder`, and the uuid is
  `spec.uuid`. Before the export the folder held only `manifest.json` and `search.sqlite`.
1. **#35:** `pack export --to M10-pack --feed rc-mac --title "rc.3 test, Mac" --search 294b906e… --no-media`: exit 0,
   28 files, 2.5 MB. "explore job 3 (search 294b906e…): **sealed its newest 25,227 runs first, so the pack carries
   every run**". Afterwards the folder has `runs/part-000001.parquet` (2.2 MB).
   - New in rc.3's output: "the version was published first into …/.M10-pack.store, a hidden store kept beside
     the export".
   - `pack check`: exit 0, 12 objects, "signed by its publisher", RC tester (Mac).
2. **The import into a fresh library:** exit 0, 134 patterns, 248 sightings, 1 search; "verified again (sample):
   134 of 134 passed".
   - **Every run:** stage 1 24,366 and stage 2 861, as in job 3, and **every row is the same** (all columns but
     the id).
   - **R #54: confirmed elites 173 in the search and 173 in the import.** Pass.
   - `--measures sign_balance,sign_sorted` lists filled values.
3. **#37:** "explore 1: 24,366 runs (0/s), 3,901 elites in 1,963 niches (173 of them confirmed), 18 of 1,359
   tilings; **not run here yet**". The hunts say "imported from pack rc.3 test, Mac (its finds came with the pack;
   nothing ran here)". `jobs status 1` adds "note: its working database was rebuilt from its sealed runs".
4. **R #57, an export that takes a running search:** job 10 (`search explore --families life_like --minutes 3
   --detach`).
   - **At once, with nothing stored yet** (status running, no runs): **refused**, exit 1: "Error: explore job 10
     is running, and the pack would leave out every run it stores from now on / stop it first (jobs stop), then
     publish". (rc.2 exported it silently as an empty search.)
   - **At +40 s, 4,096 runs:** refused, exit 1: "… its newest 4,096 runs are not sealed yet, so the pack would
     leave them out / stop it first …".
   - **Neither left its `--to` folder.** But each left an **empty hidden store** beside it (`.M10-running-empty.store`,
     `.M10-running.store`). The Framework found the same; fixed for rc.4 in efe1a03.
5. **The zip:** `M10-pack.zip` (2.2 MB, sha256 `caa62481…4b201d2952`, made with `zip -qr`) is committed. Unzipped
   again, `pack check` passes.
6. **The other machines' packs** (rc.2's; no rc.3 packs exist yet), each into its own fresh library:
   - **The Acer's `A10-pack.zip`:** check exit 0; import exit 0, 113 patterns (113 of 113 verified again), 202
     sightings, 1 search. "explore 1: 13,236 runs … (67 of them confirmed) …; not run here yet"; `sign_*` filled.
     **A pack made on Windows reads on macOS.**
   - **The Framework's `F10-pack.zip`:** check exit 0; import exit 0, 341 patterns (341 of 341 verified again), 441
     sightings, 1 search. "explore 1: 95,955 runs … (816 of them confirmed) …; not run here yet". **Linux to macOS
     works too.**

# Phase 2, sitting M-3: 2.APP and 2.11, the app (2026-11-16, from 07:40 UTC)

**Set-up.** The app started from the test bin (`$T/bin/jetcarp`, no arguments, with `env2.sh`'s folders), on the
built-in panel only. The checklist (`2.APP-checklist.md`) comes from the app's menu table at the tag (`menu.rs`,
`panes.rs`): 10 menus, 15 tool windows, 12 panes.
- Monitors: `appmon.sh` (the app's CPU, RSS, threads every 5 s; footprint every 30 s → `2.APP-app-mon.csv`);
  `autoshot.sh` (each app window every 30 s, 1400-px JPEGs in `$T/autoshots`, not committed); `shot.sh` (on demand,
  full size, into `shots/`), with `winlist.swift` to find the app's windows by pid.
- Jimmie allowed screen capture on this test machine; VS Code got the Screen Recording permission (one restart,
  which also closed the first app launch before round 1 began).

## 2.APP 1: every menu item, pane and pop-out: pass, with two findings

- **Round 1** (the setup wizard, File, Edit, View): "Everything went well, except keep awake".
  - The wizard ran first (fresh settings). Jimmie finished it as "blank slate" with the desktop offers unticked
    (`setup.json`: profile `blank-slate`, no packs, no jobs).
  - Saved into `~/Desktop/jetcarp-test/`: `scene.json` (JACA rainbow fronts on triangles), `jetcarp-world.png`
    (2400 × 1913), `jetcarp-view.png` (2125 × 1700): all three pass `jetcarp verify` (generations 71, 191, 274).
    The scene is committed as `2.APP-m3-scene.json`.
  - `contact-sheet.png` (1512 × 928). Export wallpaper wrote a 4112 × 2658 PNG (the panel's size) into the test
    output folder's `wallpapers/`.
  - **R #62: File → Export animation (GIF or WebP)… exists and makes both:** `jetcarp.gif` (640 × 512, looping,
    25 MB) and `jetcarp.webp` (animated, 201 frames, 22 MB). Jimmie opened both in Safari: "Both images play fine".
  - **Finding: View → Keep awake doesn't work on macOS.** It says the feature isn't supported on this system yet.
    In the source (`keepawake.rs` line 321), every OS but Linux and Windows gets "keep-awake is not available on
    this system yet". macOS has an API for it (an IOKit power assertion, as `caffeinate` uses). The menu offers it
    anyway; the suite's `keepawake::tests::take_and_release` is ignored. No issue found for it.
- **Round 2** (Run, Tiling, CA, Seed): "Everything acted as expected".
  - **R #58 (size):** the Tiling pane's Size → Width × height made a 256 × 256 world: the status bar reads "65536
    cells, dense storage" (`autoshots/080133`).
  - **R #59:** Run → GPU adapter lists the choices (Automatic, Discrete, Integrated, and the M2 Max) and saved
    `gpu.json` (`"gpu": "auto"`). The status bar reads "simulation: GPU". One GPU here, so no move to test.
  - The Family, Edges and Tiling catalog menus, the Tile and Unit cell editors and the CA and Seed menus all worked.
  - **R #61:** Jimmie checked the Rule box (click away applies, Esc puts the old rule back) within "everything as
    expected"; it is checked on file in 2.APP 5.
- **Round 3** (Tools, Window, Help, every tool window and pane popped out and back): "acted as expected". No crash;
  the app process was the same throughout.

## R #58: HashLife's jump in place: pass, with a finding (the jump's number can't be typed)

- Life (`B3/S23`) on square 256 × 256, wrap edges, random cells; Run → Jump → Jump ahead (HashLife): "Jumped 1000 in
  place". Saved as `m3-jump.json` (committed as `2.APP-m3-jump.json`): its one command is `{"op":"jump","gens":1000}`;
  `verify`: "ok: generation 1000 hash a1469f7cce19fa99".
- **The same world stepped 1,000 generations on the CPU has the same live cells:** the object census is identical
  (406 objects: 140 blocks, 91 blinkers, 69 beehives, 3 gliders, …), and so are the fields' populations. Only the
  state hash differs (`85467577…` stepped), because it covers each cell's age (`world.rs` line 2203), and the jump
  restarts ages at 1, as its hover text says.
- **Finding: the Jump menu's Generations field can't be edited.** "As soon as I click in it the menu closes, I don't
  get time to type." The field is an egui `TextEdit` inside a menu (`jump_ui.rs` line 28; eframe 0.37), and a click
  inside the menu closes it. It starts at 1000 (`app.rs` line 289), so 1,000 generations is the only in-place jump
  the GUI allows; R #58's 2^20 can't be asked for. (HashLife view… has its own jump, but not in place.)

## 2.APP 2: AI control (#1's lockout): pass; R #60 pass; **a serious finding: a hidden app window stops the app**

1. **Switched on** (Tools → AI control…, "Allow AI control (127.0.0.1 only)"): the app listened on `127.0.0.1:47811`.
   `jetcarp mcp --app` connected ("server jetcarp 0.4.2-rc.3"; stderr "connected to the JETCARP app on port 47811").
   `world_status` returned the app's world (`mcppoll.py`; logs `2.APP-mcp-{1,2,3,4}.txt`).
2. **R #60:** with two links open, the window read **"Open connections 2"**, with Tool calls climbing (Jimmie; a
   capture showed "Open connections 0" and "Tool calls 6 (last: world_status)" before the links' calls ran). The
   label is fixed. (The capture showed the token's first characters, so it isn't committed.)
3. **Popped out and back in:** fine.
4. **Quit** (⌘Q): the process exited 0 and the port closed. The open `mcp --app` link then answered every call with a
   clear error: "the JETCARP app closed the connection (to use this server's private world instead, call use_app with
   attach=false)".
5. **Restarted with no world open** (the Quick Start): the AI control window reopened by itself, **off**
   (`ai_control_at_launch: false`; `shots/2.APP-restart.png`, no token shown). Ticked, it listened on the same port,
   and `world_status` answered with the placeholder world (9,600 cells, no scene).

**Finding (serious for Jimmie's use): on macOS the app stops when its window is hidden: the simulation pauses and AI
control requests wait.**
- **How it showed:** the app had landed in a second Space (after round 1's View items; Jimmie, not a Mac user, got it
  back by closing the extra desktops in Mission Control). A `world_status` sent at 03:25:07 was answered at 03:25:59,
  the moment Jimmie switched to the app. Later links waited 23 s and 73 s for their first answer, each until he
  clicked the app.
- **Measured** (`2.APP-mcp-4.txt` with `2.APP-app-mon.csv`; a running JACA Quick Start world, 23,868 cells):

  | Phase | AI control | The app's simulation | The app's CPU |
  |---|---|---|---|
  | visible, running | an answer every 5 s | 42 → 174 at **11–15 gens/s** | 40–95% |
  | minimised (⌘M), ~23 s | no answer until restored | 174 → 230, mostly in its first moments | 0% |
  | covered by VS Code, 58 s | no answer for 58 s | 235 → 284, **under 1 gen/s** | **0.0%** |
  | visible again | answers at once | 15 gens/s | 15–43% |

  With the window only partly covered (an edge showing), it ran and answered normally.
- **Why** (the source at the tag): the app answers AI control "once per frame on the UI thread" (`ai_control.rs`
  line 87); the listener thread only calls `request_repaint`. The world steps in the frame loop too. macOS gives a
  hidden window no frames (occlusion), so both stop.
- **Jimmie:** "if I can't use the MCP while the window is minimized, that's not of much help to me. I need to be able
  to set up tasks and alt-tab away while things are running on the MCP."
- Not yet checked: whether Windows and Linux behave the same when the app is minimised (the Acer's hour-long run was
  with the window in view); whether `jetcarp mcp` without `--app` (its own world, and searches as detached jobs) keeps
  working with the app hidden (Part 4, in M-6, will test it with the app hidden).

## 2.APP 3 and 4: shortcuts, light and dark, sizes: pass, with two macOS shortcut findings

- **Shortcuts** (Help → Keyboard shortcuts, F1): "Other than that, shortcuts worked as expected": ⌘N, ⌘O, ⌘S, ⌘E, R,
  Esc, F, +/=, −, Tab, Space, S/→, F10, F12, ⌘1, F1.
- **Finding: ⌘H hides the app on macOS** (the system's Hide), so the Quick Start shortcut (⌘H, `menu.rs` line 368)
  can't be used there. Jimmie: "we should probably change that key". A hidden app also stops (2.APP 2's finding).
- **Finding: F11 shows the desktop on macOS** (the system's Show Desktop), so Full screen (F11, line 383) has no
  working shortcut there. macOS's own full-screen key is ⌃⌘F.
- **Light and dark:** "Light mode looks like light mode" (Jimmie dislikes light mode in general, not JETCARP's).
- **Window sizes:** "the window resizes as expected".

## 2.APP 5: Quick Start, editing, save and reopen: pass; R #61 pass (one unexplained first try)

- **Quick Start:** Jimmie opened entries from each category (`autoshots/090908` shows the Computing category's 7). The
  tiling and family filters (the left column's TILINGS and RULE FAMILIES lists) weren't clear from my wording at
  first; see below.
- **Edit, save, reopen:** an empty world with `B2/s23` added by notation, its palette changed (Neon, then Lava) and
  reseeding set to blobs when settled. Saved as `m3-edited.json` (committed as `2.APP-m3-edited.json`), another entry
  opened, then reopened: "Saved, and it came back". `verify`: "ok: generation 0 hash 9c017365ae650188".
- **R #61, first try: "The world did not take the rule once I clicked elsewhere."** The saved file agrees: its
  commands are `add_ca`, two palette `update_ca`s and `set_reseed`, with no rule change. Where the click landed isn't
  known. A click outside the app (into VS Code, say), then ⌘S, would explain it: leaving the window doesn't make
  the box lose focus, so the typed rule would sit there unapplied and be saved without it. That is a possible gap
  for the main session to look at (apply a pending rule on window blur, or before Save).
- **R #61, repeated with one-second captures** (`$T/r61/`): `B36/S23` typed in the Rule box, Enter not pressed, then a
  click on the grid: the CA's heading became "HighLife B36/S23" (`r61/091913.jpg`). **Pass.**
- **Esc:** another rule typed, then Esc: the box went back to the rule in use. **Pass.** (The code at the tag:
  `ca_ui.rs` lines 53–58, applied on any loss of focus, given up on Esc; its hover text says so.)
- **The filters:** with the left column's TILINGS and RULE FAMILIES lists explained, "Filters work".

## 2.APP 6: PNG, GIF and WebP from the app: pass (R #62 pass)

Done in round 1: the world and view PNGs (both pass `verify`), and **File → Export animation (GIF or WebP)…** made a
640 × 512 looping GIF and a 201-frame animated WebP; both play in Safari. In round 3 the Hunts window's Render media
button was found without trouble (asked about in round 3's list; "the rest of round 3 acted as expected").

## 2.APP 7: the scripting pane's examples: pass

Tools → Scripts and sweeps… → Script → Examples, each with Run script. Jimmie: "all scripts ran". Each wrote its folder
in `$T/out/`:

| Example | Files | Time |
|---|---|---|
| hexw3-atlas | 19,683 PNGs, `manifest.csv`, `manifest.json`, `run.json` (856 MB on disk) | about 2 min (04:21:26 → 04:23) |
| hexw-all | 16 PNGs, manifests, `run.json` | seconds |
| wolfram-all | 256 PNGs, manifests, `run.json` | seconds |
| soup-hunt | `finds.csv` (a p7 oscillator 12c `#69ed78` in B36/S23, soup 9, as on the Acer), `soups.csv`, 1 PNG | under a minute |
| catalog-hunt | no folder: it writes to the library (now 135 patterns, 289 sightings) | – |
| script-five | 5 PNGs, `final.json`, `run.json` | seconds |
| jaca-territories | `territories.csv`, 1 PNG, `run.json` | seconds |

## 2.11 (M11): JACA's colours and the GPU in the app: pass (R #59 pass)

**How it was measured.** `mcppoll.py` kept one `jetcarp mcp --app` link open and logged `world_status` every 5 s
(generation, cells, playing, tiling, the app's RSS and footprint), so gens/s is the generation's change over time
(`2.11-poll.txt`). The 30-second captures give the status bar's "simulation: …" and the fps. The app was kept at least
partly in view throughout (2.APP 2's finding).

1. **JACA colours:** *bead borders (square, blast 1)*, *war on the hat tiling*, *rainbow fronts (Cairo)* and *Life vs
   HighLife*, about 20 s each, at their own sizes (12–15 gens/s). Jimmie: "signs easy to tell apart". In the
   capture of the hat tiling (`autoshots/092720`) the −1 palette is Koi (cream → peach) against Tide's teal for +1,
   with Glow on, on "simulation: GPU".
2. **A 4,194,304-cell Life world:** Life, square, **Width × height 2048 × 2048** (R #58's new size, "Built Square
   (parallelogram), about 4194304 cells in 0.0 s"), wrap, random cells, Max speed:

   | GPU simulation | Status bar | Speed |
   |---|---|---|
   | Follow (automatic), ~1 min | "simulation: GPU", 41 fps | **about 330 gens/s** (298–338) |
   | Off, ~1 min | "simulation: CPU", 36 fps | **about 40 gens/s** |

   On the M2 Max the GPU is about 8 times the CPU for a big Life world (at Max speed it runs about 8 generations a
   frame). On the Acer's Intel UHD it was slower than the CPU (21 against 27).
3. **JACA at full speed:** *rainbow fronts (Cairo)* at "About 4 million" (4,000,000 cells), Max speed. Jimmie ran Off
   first, then On: "it looks fine … the count moves too fast at max speed to properly compare the numbers, but it seems
   to work."

   | GPU simulation | Speed |
   |---|---|
   | Off, ~1 min | **about 17 gens/s** |
   | On, ~1.5 min | **about 130 gens/s** |
   | Follow (the start of the hour) | about 125 gens/s |

   (The Acer's UHD: 18 against 12–13 gens/s.)
4. **R #59:** Run → GPU adapter lists Automatic, Discrete, Integrated and the M2 Max, and saves the choice
   (`gpu.json`); with one GPU there's nothing to move to. The status bar says "simulation: GPU" on Follow and On.

## 2.APP 8: an hour of a large JACA world: pass

*JACA rainbow fronts (Cairo)* at "About 4 million" (4,000,000 cells, wrap edges), Max speed, GPU simulation on Follow
(the M2 Max). It ran from 04:37:34 local; the log covers 04:39:45 to 05:40:39 (60.9 min) with VS Code on top and part
of the app's window in view.

`mcppoll.py` logged `world_status` and the app's memory every 10 s (`2.APP-hour-poll.txt`); `appmon.sh` logged CPU
every 5 s; a capture every 10 minutes (`shots/2.APP-hour-00…60.jpg`).

| Minutes | Generations | Gens/s | Live cells | RSS | Footprint |
|---|---|---|---|---|---|
| 0–10 | 32,147 → 106,020 | 125.0 | 2,667,454 | 557–572 MB | 532–563 MB |
| 10–20 | → 182,641 | 127.7 | 2,672,894 | 557–572 MB | 535–569 MB |
| 20–30 | → 259,198 | 127.4 | 2,676,487 | 557–572 MB | 543–574 MB |
| 30–40 | → 335,928 | 127.8 | 2,678,448 | 557–572 MB | 543–574 MB |
| 40–50 | → 412,804 | 127.9 | 2,679,769 | 557–576 MB | 543–574 MB |
| 50–60 | → 489,542 | 127.9 | 2,680,594 | 557–572 MB | 543–574 MB |
| 60–61 | → 497,071 | 125.3 | 2,680,535 | 557–561 MB | 543–572 MB |

- **No slowdown:** 464,924 generations in 60.9 minutes (127.3 gens/s), every 10 minutes within 125–128. (The Acer's
  UHD: 12.4 gens/s.)
- **No memory growth:** RSS 557–576 MB and footprint 532–574 MB throughout.
- **Steady:** about 2.6 cores on average; all 366 polls answered on time (no gap over 15 s).
- Every capture says "Running … simulation: GPU" (35 fps at the end). The fronts in the last capture have settled into
  large territories with glowing rainbow borders (generation 494,505).

## The main session's check of 5fcef69 (#87, #88, #89): all three pass

At the main session's request (NOTES, 4:20 AM EST): the tag clone moved to `origin/release-0.4.2` at **5fcef69**,
`cargo build --release -p jetcarp` (74 s, no warnings; `--version` still says 0.4.2-rc.3), and that
`target/release/jetcarp` run with `env2.sh`'s folders (the rc.3 app quit first). Logs: `87-poll.txt` (`world_status`
every 2 s), `87-app-mon.csv`, `88-m3-jump2.json`, `89-assertions.txt`.

**#87, the app behind a hidden window: pass.** A running JACA Quick Start world (*JACA rainbow fronts (3.6.3.6)*,
24,174 cells), AI control on, then Jimmie's phases:

| Phase (UTC, from the app's CPU) | AI control | Simulation | App CPU |
|---|---|---|---|
| visible, 10:47:22–10:48:33 | an answer every 2 s | 15 gens/s | 30–56% |
| minimised (⌘M), 10:48:43–10:49:14 | **an answer every 2 s** | **15 gens/s** | 2–19% |
| fully covered, 10:49:24–10:50:14 | **an answer every 2 s** | **15 gens/s** | **≈ 99%** |
| visible again, from 10:50:24 | an answer every 2 s | 15 gens/s | 34–48% |

- No answer was late in any phase (rc.3 waited 23–73 s), and the generation climbed at the visible rate throughout
  (15 gens/s is this entry's own speed).
- **Side note:** fully covered, the app used a whole core (≈ 99%) against ≈ 50% in view, as if its loop spins when
  macOS withholds frames. Minimised, it was 2–19%. Worth a look for battery use.
- The one gap in answers (32 s, 05:52:22–05:52:54 local) is when the save dialog for #88's scene was open.

**#88, the Jump field: pass.** Life on 256 × 256 with wrap edges; Jimmie clicked Run → Jump's Generations field, typed
`2^20`, and jumped in place: the world reached generation 1,048,576. Saved as `m3-jump2.json` (committed as
`88-m3-jump2.json`): `add_ca B3/S23`, then `{"op":"jump","gens":1048576}`; `verify`: "ok: generation 1048576 hash
768be531a000e512".

**#89, Keep awake on macOS: pass.** View → Keep awake on: `pmset -g assertions` lists `pid 84604(jetcarp):
NoDisplaySleepAssertion named: "JETCARP is showing cellular automata"` and `PreventUserIdleDisplaySleep 1`. Off: no
JETCARP assertion, and `PreventUserIdleDisplaySleep 0`.

# Phase 2, sitting M-4: 2.D 1–7, the desktop background (2026-11-16, 11:03–11:47 UTC)

Files: `2.D-monitor.txt` (`dmon.sh`: every 5 s, the host's state per screen, its memory and CPU, the app's CPU, and
the GPU's whole-device utilisation from `ioreg`, since macOS gives no per-process GPU share without sudo),
`2.D-3-steps.txt`, `2.D-tune.json` and `2.D-tune-table.txt` (the command-line fit), `2.D-4-loop.txt`,
`2.D-5-picks.txt`, `2.D-6-gpu.txt` (`gpuwatch.sh`), `2.D-7-busy.txt`, `2.D-7-holds.txt`, `2.D-app-mon.csv`.

**Setup, as rc.1's MD.** Homebrew's 0.4.1 `host status` (clean environment): "not running", so there was no everyday
host to stop. The wallpaper store (`~/Library/Application Support/com.apple.wallpaper/Store/Index.plist`) was copied
first. The candidate's host started from the test folder (`host start`, 0 s; "running, pid 87495, … GPU Apple M2
Max"), then `host wallpaper on`, then the app. One monitor, the built-in Retina panel (120 Hz, scale 2).
- **R #75, at once:** `host status` gives each screen's simulation now: "simulation: CPU: automatic, and the world is
  too small to be worth the GPU" for the turmite, "simulation: GPU (Apple M2 Max, Metal)" for Life.
- **The basics (rc.1's D2):** Jimmie: "Live turmite under the icons, smooth".

### 2.D 1. Show just this scene (#41): pass
- Jimmie opened *JACA war on the hat tiling* and clicked **Show just this scene**: "desktop switched to the hat".
- Saved `rotations/jaca-war-on-the-hat-tiling.json` ("Just "JACA war on the hat tiling", made by Show just this
  scene", one profile item) and `screensavers/jaca-war-on-the-hat-tiling.json`. `host.json`'s screen 0 rotation
  changed; **the screen saver's choice stayed as it was** (`saver_rotation` null).
- The host: "35000 cells of 20 px · 30 fps, 15 generations a second · wallpaper · simulation: GPU".

### 2.D 2. Make a rotation in the pane (#41): pass; R #74 pass
- New → two items → Save → the desktop shows it → Edit, order swapped: "Saved "My rotation", desktop shows it, order
  swapped". Save was found without help.
- `rotations/my-rotation.json`: the profile "JACA war on the hat tiling" and the Quick Start entry
  `jaca:cairo-rainbow`, shuffled, 5 min each. The host: "My rotation · profile JACA war on the hat tiling (1 of 2)".
- **R #74:** the Quick Start entry came from the editor's "Add Quick Start: search" box (typed part of a name, the
  entry clicked); no id typed by hand. (The order shows only in the file: the rotation shuffles.)

### 2.D 3. Every generation (#42): pass

| Scene | Pacing / max | `host status` | Host CPU |
|---|---|---|---|
| Life ("Until it settles"), 303,455 cells of 6 px | every generation, 60 | 60 fps, 60 gens/s, on the GPU | 50–63% |
| Turmite LLRR (240 gens/s), 170,648 cells of 8 px | every generation, 60 | 60 fps, 240 gens/s (on the CPU: a small world) | 59–64% |
| Turmite | `max-fps refresh` | **120 fps** (the panel's refresh), 240 gens/s | 93–115% |
| Life | `pacing low-power` | **30 fps, 30 gens/s** | 24–34% |

- **Blinkers:** Jimmie: "Blinkers are even and steady".
- The GPU figure here is the whole device (38–53%), with the app's own animated window and the compositor in it, so it
  can't show the host's share; low power halved the host's CPU. Set back to max-fps 60 and every generation.

### 2.D 4. Fit to this computer (#38): the sweep works; R #69 pass; R #72's plain note; R #73 not tested here
- **The sweep (pane):** each of "Until it settles"'s 3 scenes (B3/S23, B36/S23, B368/S245) stepped coarse to fine
  (32 → 24 → 16 → 12 → 8 → 6 → 4 → 3 → 2 px) and stopped at 2 px: about 45 s for 27 sizes. **1 px is never tried**:
  2 px is already far over the limits (CPU 17–18%, frames 9–15 ms). The command line's `host tune --json --crops` did
  the same: exit 0 in 56 s, 27 crops (`2.D-tune.json`, `2.D-tune-table.txt`).
- **Recommended is the finest size within the limits**, judged on the processor alone (below):

  | Scene | Fits down to | First size over | Recommended |
  |---|---|---|---|
  | B3/S23 | 6 px, CPU 5.4% | 4 px, CPU 8.3% | 6 px (its own size) |
  | B36/S23 | 4 px, CPU 7.6% | 3 px, CPU 13% | 4 px |
  | B368/S245 | 4 px, CPU 7.3% | 3 px, CPU 12% | 4 px |

  - The reasons are spelled out: "processor 8.3% (over 8.0%: the 10% limit, less 20%)". Frame times stay far inside
    the budget down to 3 px (p95 ≈ 6.5 ms against 16.7 ms).
  - **The recommendation flips from sweep to sweep** at the edge: the 4 px rungs measure 7.3–8.3% against the 8.0%
    line. B3/S23 came out at 4 px ("within the limits, Recommended", CPU 7.3%) in the first fit, at 6 px in the second
    and third; B368/S245 at 6, 6 and 4 px across the picks' sweeps.
- **Jimmie's pick:** "6 is the one that came in under the limits, but 4 is slightly better in my opinion."
- **GPU timing (#38, R #72's wording):** every result has `"gpu_timing": "submission"`, and the pane says plainly, in
  orange: "GPU share not measured on this adapter (it has no GPU timestamps): the GPU limit isn't applied"; each card
  says "GPU unknown". So on the M2 Max (Metal) the tuner judges the processor only. **macOS's own count (Activity
  Monitor's % GPU) put the host at 30% at 6 px**, over the 25% limit the tuner can't see (the app: 0%). As on the
  Acer's UHD, the GPU limit does nothing here.
- **R #69: pass.** The host's memory: 111 MB at start, 146 MB before the first fit, 162 MB after the second, 161 MB
  after the third (command line), 162 MB after the three picks' sweeps and at the end (six sweeps in all).
- **R #73: not tested here.** The cards held only "Until it settles"'s rows, but no automatic fit of another rotation
  had happened (the hat scene stayed `tuned False` though "Measure again by itself" was on). Automatic fits come with a
  monitor change, so #73 waits for M-8 (two monitors).
- **"It kept restarting the fitting over and over again, as the "Measure again…" box was checked."** Jimmie saw the
  desktop go "coarse and then fine, and then restarts", and again after re-ticking the box and pressing Fit; then "It
  stopped at some point". Not confirmed in the host: the 5 s monitor shows one sweep (11:17:51–11:18:38, "swept 3
  scene(s); sizes saved"), and a one-second log taken while Jimmie said it was "still looping" (`2.D-4-loop.txt`) shows
  `tuning running False` throughout, while "Until it settles" moved from B3/S23 at its own 6 px to B36/S23 at 4 px.
  At 60 gens/s each Life scene settles within a minute, so the rotation itself goes coarse → fine → coarse, which may be
  what looked like a restarting sweep. Unresolved; worth a look at whether "Measure again by itself" can retrigger a fit
  on macOS.

### 2.D 5. Picks (#39): pass

| Pick | Every scene shows at | Notes |
|---|---|---|
| `host tune --pick 4` | 4 px "(chosen)" | 55 s (re-runs the sweep) |
| `host tune --pick 3` | 3 px "(chosen)" | 56 s |
| `host tune --pick own` | 6 px, its own size; status `tuned False` | 56 s |
| the pane's **Use the scenes' own sizes** | 6 px | clears screen 0's fitted sizes (`tuning: null`), and the cards go away |

- Jimmie: "I already had 6px selected when I hit the button, and then the cards went away" (the own size here is 6 px).
- As on the Acer, each `--pick` re-runs the whole sweep though the sizes were measured.

### 2.D 6. The GPU overrides: pass; R #75 pass

`gpuwatch.sh` logged `host status`, `doctor` and the host's CPU 4 s after each change:

| Desktop background / shared | `host status` | doctor | Host CPU | GPU (device) |
|---|---|---|---|---|
| Follow / auto | "simulation: GPU (Apple M2 Max, Metal)" | "auto, from the setting in gpu.json (its own choice: follow)" | 56–64% | 24% |
| Off / auto | "simulation: CPU: GPU simulation off, from the desktop background's own setting" | "off, from the desktop background's own setting (its own choice: off)" | 191–210% | 16% |
| On / auto | "simulation: GPU (Apple M2 Max, Metal)" | "on, from the desktop background's own setting (its own choice: on)" | 48–75% | 37% |
| Follow / auto | "simulation: GPU" | "auto …" | 49–72% | 22% |
| Follow / **off** (≈ 5 s) | (5 s monitor) "CPU: GPU simulation off, from the setting in gpu.json" | (too brief to read) | 202% | – |

- The host really steps on the processor when it should. **`host status` now names each screen's simulation and its
  reason, and its note follows the change** ("GPU simulation off (the desktop background's own setting)"). rc.2's gap
  is fixed. Jimmie: "nothing looked different".
- Small: `host status` repeats "note: swept 3 scene(s); sizes saved" once per sweep (six identical lines here).

### 2.D 7. Pauses: pass; R #76 pass
1. **A busy processor** (`busy` 80, the default): a detached 2-minute CPU hunt on every thread (job 11). **Held from
   11:40:05 to 11:41:57** (about 15 s after the start, until the hunt ended), the generation frozen at 3,274 and the
   host's CPU at 0%; moving again by 11:42:02. JSON: `held ['busy']`, `held_why ['the processor is busy']`.
2. **A full-screen video** (Jimmie's browser): 11:43:52–11:44:36, the screen line ends "· paused" and `host status`
   says **"held: held by the desktop: windows cover it (resumes by itself)"**; the generation froze at 4,106, then moved.
3. **Battery** (`battery` on, the default): unplugged at 11:44:52; 2 s later **"held: on battery (resumes by itself)"**,
   frozen at 5,218; plugged in at 11:45:10 → moving again at once.
- Jimmie: "it resumed for both". **R #76:** the status says held, and why, in the text and the JSON (`held`,
  `held_why`); `paused` stays false for a hold, which now has fields of its own.

### Put back
- `host stop` → "stopped"; `host status` → "not running"; no host process. Homebrew's 0.4.1 is still "not running".
- **The wallpaper is unchanged:** the store's three wallpaper choices (providers and configurations) are identical
  before and after. The file differs only in macOS's bookkeeping: "LastUse" times, and an entry for the Space the
  full-screen video made (11:43:50). On macOS the host draws in a window behind the icons and never sets the picture.

## The main session's recheck of bf6f64f (#87's CPU while covered): pass

The tag clone moved to `origin/release-0.4.2` at **5def684** (it includes bf6f64f, "a hidden window's passes come every
50 ms, not back to back"); `cargo build --release -p jetcarp` 21 s, no warnings. Run with `env2.sh`'s folders; a running
JACA Quick Start world (*JACA rainbow fronts (triangles, edge)*, 24,056 cells), AI control on; `87b-poll.txt`
(`world_status` every 2 s), `87b-app-mon.csv`. Jimmie: visible about 20 s, fully covered about 60 s, then back.

| Phase (UTC) | AI control | Simulation | App CPU |
|---|---|---|---|
| visible, 11:51:29–11:52:05 | an answer every 2 s | 15.0 gens/s | 22–49% |
| **fully covered, 11:52:09–11:53:35** | **an answer every 2 s (71 in all, no gap over 3 s)** | **15.0–15.1 gens/s** | **2–5%** |
| visible again | an answer every 2 s | 15.0 gens/s | 26–42% |

Covered, the app now uses about a tenth of its visible CPU (5fcef69: about 99%, a core spinning).

# Phase 2, sitting M-5: 2.D 8–12 (2026-11-16, from 12:01 UTC)

Files: `2.D-M5-monitor.txt` (`dmon.sh` every 3 s), `2.D-12-crash.txt`, `2.D-11-saver.txt`, `2.D-10-login.txt`.
**Setup:** the candidate's host from the test folder, wallpaper on, Life ("Until it settles", 60 fps = 60 gens/s on the GPU).

### 2.D 8. Sleep and wake: pass
- Apple menu → Sleep: the Mac slept at 12:02:36 UTC ("Software Sleep") and woke at 12:04:05 (the power button).
- Just before sleeping the host held: "held by the desktop: windows cover it", "held by the desktop: the screen is locked
  or off". After waking it stayed held on the sign-in screen until 12:04:16, then resumed at 60 gens/s.
- The same process throughout (pid 10288), no error. Jimmie: "Woke it up, desktop is live again".
- Small: `host status`'s "up" leaves out the time asleep ("up 64.0s" for a host about 2½ minutes old, 89 s of it asleep).

### 2.D 9. The lock screen: pass, with a finding
- Control-⌘-Q: the host held from 12:05:20 ("windows cover it", "the screen is locked or off"), frozen at generation
  441, its CPU at 0%. Jimmie: "Lock screen showed macOS's picture, desktop live after". (`host lock` is for GNOME.)
- **Finding: when the display turns off while the Mac is locked, the host stops holding and runs.** The display went
  off at 12:05:46 (the power log); from 12:05:52 to 12:06:04 the host was unheld and ran Life at ≈ 63 gens/s (441 →
  1,355), CPU 7–13%, still locked, with the screen dark. When the display came back (12:06:04, the lock screen) it held
  again (12:06:08), and it resumed on unlock (12:06:14). A sleeping display evidently reads as neither covered nor dark,
  the opposite of what "the screen is locked or off" means, and it spends power on a screen nobody sees.

### 2.D 12. A host crash: pass

| Case | What happened | The desktop (Jimmie) |
|---|---|---|
| `kill -9` on the host (`still` off) | nothing restarted it; "not running" | "My own wallpaper is showing" |
| `host start` | live again in 1.2 s (new pid, "wallpaper: showing") | – |
| `host still on`, then `kill -9` | no still set, while running or after; the wallpaper store's choices unchanged | "My own wallpaper is showing" |
| `host still on`, then a clean `host stop` | a still written (`config/desktop-pictures/still-…-0.png`, 74 KB) and set as the desktop picture (a fourth image choice in the store); `desktop-picture.json` records the original picture and the still | "A still of Life is showing" |
| `host still off` | "put the desktop's own picture back"; the still and `desktop-picture.json` removed; the store's choices identical to before | "My own wallpaper is back" |

As on the Acer, a crash always leaves the user's own picture: nothing is left to set the still. (The original picture's
file name in `desktop-picture.json` is withheld from `2.D-12-crash.txt`.)

### Steps 11 and 10: in the default folders
macOS runs the screen saver and the login item with no `JETCARP_*` variables, so these use the default folders
(`~/Library/Application Support/jetcarp`, Homebrew's 0.4.1's), as the rc.3 plan allows on the laptops. That folder was
copied first (`$T/everyday-backup/`: `app.json`, `setup.json`, `host-program`, `data/`).

### 2.D 11. The screen saver: pass
- `jetcarp host saver install --rotation "Wolfram series"` (the candidate, no `JETCARP_*`): "written to
  ~/Library/Screen Savers/JETCARP.saver; choose JETCARP in System Settings, Wallpaper, Screen Saver… (opening; if it was
  open already, quit and reopen it to see JETCARP). Install again after changing its rotation".
  - A code-signed bundle with the rotation inside (`Contents/Resources/jetcarp-saver.json`), and thumbnails.
  - In the everyday settings folder: `host.json` (the saver's rotation) and `screen-saver-before.plist` (macOS's
    screen saver settings, kept to put back).
- `host saver status`: "… at ~/Library/Screen Savers/JETCARP.saver, showing "Wolfram series"".
- **Jimmie chose it and previewed it: "It showed the Wolfram series".**
- `host saver remove` **with System Settings still open: it worked** (unlike Windows, where the open dialog holds the
  file): "removed / put back the screen saver macOS had chosen before JETCARP was installed; System Settings, if it is
  open, may keep listing JETCARP until you quit and reopen it". The bundle is gone; status "not installed"; the
  wallpaper store's choices (the screen saver's included) are identical to before. It left
  `wallpaper-store-before-saver-remove.plist` in the settings folder.
- After quitting and reopening System Settings: "JETCARP is gone, my old screen saver is selected".

### 2.D 10. Start at login: set up (the logout comes next)
- In the default folders: `host start`, `host wallpaper on`, `host rotation "Classics, hourly"` (it showed profile
  Hodgepodge, 7 of 7, 303,455 cells of 6 px, 30 fps), then `host stop`. Saved: screen 0 "Classics, hourly", wallpaper,
  still off.
- **`host login on`**: ""…/jetcarp-rc-042c/bin/jetcarp" host serve --login starts at login". It wrote
  `~/Library/LaunchAgents/com.jimmieprodgers.jetcarp.host.plist` (`ProgramArguments` the candidate's `jetcarp host serve
  --login`, `RunAtLoad` true, `ProcessType` Interactive).
- **The logout and login:** Jimmie logged out and back in at 07:15 local. **The host started within a second of the
  login:** `/dev/console` changed owner at 07:15:15, and launchd started `…/jetcarp host serve --login` (pid 15357,
  parent launchd) at 07:15:14. `host status` 40 s later: "Classics, hourly · profile Hodgepodge (7 of 7) · 303455
  cells of 6 px · 30 fps · wallpaper", "wallpaper: showing"; `launchctl print`: running, never exited. So on macOS the
  host starts at once; nothing like Windows' 97 s queue (R #78's subject on the Acer).
  Jimmie: the live scene appeared "Within a few seconds as well, much faster than the Acer".
- **Undone:** `host login off` → "the host no longer starts at login", the LaunchAgent file gone; `host stop` →
  "stopped". **Small:** launchd kept the job loaded for the session (its plist gone; state not running, last exit 0),
  so I unloaded it with `launchctl bootout`. It would have gone at the next logout anyway.

### Putting the everyday folder back
- **The candidate wrote into the everyday settings folder:** `host.json`, `gpu-checks.json`,
  `wallpaper-store-before-saver-remove.plist` (from 2.D 11's remove), and a new `host-program` naming the candidate.
  The first three were removed, and `host-program` restored (it names Homebrew's `/opt/homebrew/bin/jetcarp` again).
- **Finding: the candidate's host, started in the default folders, wrote to the everyday library.** At 07:13:37 local
  (2.D 10's `host start`) the library's WAL grew from 0 to 811,672 bytes. A copy showed what: rc.3's **built-in sync**
  (`meta.builtin_version` 0.4.1 → 0.4.2-rc.3, all 78 `engine_pins` rows and 649 of the 1,156 `quickstart` rows
  refreshed). The schema (user version 3, 19 tables) and the user's own rows (90 patterns, 26 jobs, ratings) were
  unchanged, so it isn't a migration, and Homebrew's 0.4.1 would presumably re-sync its own built-ins. But A-5's "the
  everyday library was never written" doesn't hold here: a host started at login, or by hand in the default folders,
  touches the library. The three library files were restored from the backup taken before 2.D 11.
- **At the end the everyday folder is identical to that backup** (`diff -r`). Homebrew's 0.4.1: `host status` "not
  running". No JETCARP LaunchAgent, no screen saver installed, and the wallpaper store's choices are the same as before
  M-4.

## The main session's check of 7e1bbc3 (#95, the host while a locked Mac's display sleeps): **fail**

The tag clone moved to `origin/release-0.4.2` at **7e1bbc3** (its `desktop_mac.rs` has the new `displays_asleep()`,
`CGDisplayIsAsleep` on every online display); built in 20 s, no warnings. Its host ran from the test folder (pid
16577, `…/target/release/jetcarp host serve`), wallpaper on, Life ("Until it settles", 60 gens/s). `95-check.sh`
logged the host every second and, 5 s after the session locked, ran `pmset displaysleepnow`.

**First run** (`95-check.txt`): locked 12:26:43 → held (`covered`, `dark`) → display asleep 12:26:48 → **from 12:26:51
to 12:27:16 `held []`, the generation 3,376 → 4,793 (≈ 57 gens/s)**, still locked → display on (the lock screen):
held again → unlocked 12:27:19 → running. The same as rc.3 (M-5's 2.D 9).

**Second run, with a probe** (`95-probe.swift`, `95-probe.sh`, `95-probe.txt`): each second, what macOS reports
(`CGDisplayIsAsleep` and `CGDisplayIsActive` per display, `CGSessionCopyCurrentDictionary`'s
`CGSSessionScreenIsLocked`, which the host's `locked()` reads, and `ioreg`'s console lock flag) beside the host's state:

| UTC | `CGDisplayIsAsleep` | `CGSSessionScreenIsLocked` | `ioreg` locked | Host |
|---|---|---|---|---|
| 12:28:41 (unlocked) | 0 | absent | no | running |
| 12:29:04 (locked) | 0 | 1 | yes | held (`covered`, `dark`) |
| 12:29:09 (`pmset displaysleepnow`; "Display is turned off") | **1** (active 0) | **1** | **yes** | held |
| **12:29:13 → 12:29:47** (display still off) | **1** | **1** | **yes** | **`held []`, generation 1,274 → 1,967** |
| 12:29:47 ("Display is turned on") → 12:29:51 | 0 | 1 | yes | held (`covered`, `dark`) |
| 12:29:53–55 (unlocked) | 0 | absent | no | running |

- **macOS reports the right thing throughout:** while the display sleeps, `CGDisplayIsAsleep` is 1 and the session's
  `CGSSessionScreenIsLocked` stays 1 (as does `ioreg`'s flag). So both `displays_asleep()` and `locked()` should be
  true, and the host still drops its hold about 4 s after the display sleeps. The fault is in how the host combines
  them, not in the detection: perhaps they're consulted only while the window counts as covered, and macOS stops
  calling it covered once the display sleeps.
- The code's comment ("While a locked Mac's display sleeps, the session no longer reads as locked") doesn't match
  this Mac: the session still reads as locked.
- While asleep the host ran at ≈ 20 gens/s in this run (≈ 57 in the first).

## The main session's check of 67a08a6 (#95 again): **pass**

67a08a6: "dark" holds while a wallpaper is wanted and nothing of it can be seen: locked, every display asleep, or no
wallpaper window at all. Built in 21 s, no warnings; its host from the test folder (pid 18521), wallpaper on, Life.
`95b-probe.sh` logged each second the same probe as before plus `host status`'s screen, `monitors:` and `wallpaper:`
lines (`95b-probe.txt`); 5 s after the lock it ran `pmset displaysleepnow`.

| UTC | Display | `monitors:` line | `CGDisplayIsAsleep` / locked | Host |
|---|---|---|---|---|
| 12:38:37 | on, unlocked | Built-in Retina Display | 0 / no | running |
| 12:38:54 | on, locked | Built-in Retina Display | 0 / yes | held (`covered`, `dark`), generation 2,033 |
| 12:38:58 | off ("Display is turned off") | still there | 1 / yes | held |
| 12:39:01 | off | **gone** | 1 / yes | held (`covered`, `dark`) |
| 12:39:02 → 12:39:24 | off | gone | 1 / yes | **held (`dark`), generation 2,033** |
| 12:39:24 → 12:39:26 | on ("Display is turned on"), the lock screen | back at 12:39:26 | 0 / yes | held (`dark`, then `covered` too) |
| 12:39:30 | unlocked | Built-in Retina Display | 0 / no | held for a moment |
| 12:39:31 | – | – | – | running (2,042) |

- **The generation stayed at 2,033 from the lock to the unlock**, through 26 s of display sleep, and the host was live
  again a second after unlocking. `wallpaper:` said "showing" throughout.
- **The main session's reading is right:** while the display slept, macOS took the monitor away (no `monitors:` line
  from 12:39:01 to 12:39:26, about 3 s after the display slept until 2 s after it woke), so the host had no wallpaper
  window, `covered` let go, and the new rule kept `dark`.

# Phase 2, sitting M-6: Parts 4 and 5, MCP in depth and robustness (2026-11-16, 12:44–13:25 UTC)

**Set-up.** The Framework's rc.3 R scripts (rc.2's F9 ones), copied into `M6/` and pointed at the Mac: `mcpc.py`'s
paths, `env.sh`, the shell scripts' paths; `t5_cli.sh` with `stat -f` and 12 threads, and the Framework's rc.2
`F10-pack` (unzipped in 2.10) for the damaged packs; `rss.py` reading macOS's `ru_maxrss` in bytes. Every folder under
`~/jetcarp-rc-042c/m6` (`JETCARP_CONFIG_DIR`, `_DATA_DIR`, `_OUT`, `_LIBRARY`, `_RUNTIME_DIR`). The unattended part is
`run_m6.sh` (log `run_m6.log`, 07:44:56–07:48:52 local); `t51` was rerun after `t5_cli.sh`, which makes its files.
The parts with Jimmie are `t41b_app_host.py` (host, app, hidden) and `t52_two_programs.py` with the app open.

### 4.1 Every tool once: pass
- `t41_every_tool.py` (`4.1-every-tool.{txt,jsonl}`): 53 calls over every tool but three. 6 errors, none JETCARP's:
  `pack publish` refuses clearly with no publisher key ("…which these tools never make: ask the user to run `jetcarp
  pack key`…"), so the four pack calls after it have nothing to work on (the Framework's run is the same); and
  `job_stop {"job": null}` is the script failing to read a JSON reply's job id (the Framework's too).
  `resources/list`: 116 resources.
- **The three the Framework skipped** (`t41b_app_host.py`, `4.1b-{host,app}.{txt,jsonl}`):
  - **`host_control`** on a test host (the M-6 folders, its screen a window): status, next (item 5 → 6 of 7), pause
    (`paused` true, the generation frozen), resume, rotation "Until it settles", scene; the refusals are clear
    ("`rotation` needs `name`", "unknown action "bogus"").
  - **`app_display`** before attaching: "app_display is only available in the JETCARP app: start the app with AI
    control on … then use `jetcarp mcp --app` or call use_app with attach=true".
  - **`use_app` attach=true** (the app open with the M-6 folders, AI control on): "Attached to the JETCARP app". Then
    `app_display` returned the app's state; `world_new` made a 128 × 96 Life world in the app; `app_display {"playing":
    true, "speed": 30}` ran it (generation 0 → 120 in 4 s; Jimmie saw it in the status bar and the generation), and
    `{"playing": false}` paused it. `use_app` attach=false went back to the private world (4,096 cells, headless).
    My `world_step {"gens": 50}` got "world_step has no argument `gens`. Its arguments: generations,
    stop_when_settled" (#68 at work). No token in any log.

### (private) part 4.2: pass (its files: `M6/4.2*`)

### 4.3 Bad input: pass; R #68 pass
`4.3-bad-input.txt`, `4.3b-followups.txt`: 132 cases, each with an error a person can act on. **R #68:** "search_start:
`threads` must be at least 0 (got -1)", "help: `topic` must be text (got 5)".

### 4.4 Long jobs: pass; R #64 pass; and with the app hidden
- `t44_long_job.py` (`4.4-long-job.txt`): a detached hunt (job 5) and an explore (job 6) started through MCP; the MCP
  server closed at 07:46:20; `jetcarp jobs status` (another process) followed both still running (hunt 5: 14,711 →
  54,162 soups); one stopped from a new MCP session, the other from the command line (`jobs wait` exit 3).
- **R #64** (`4.4b-in-server-job.txt`): the MCP server's own hunt (job 7) was left **paused** when the server exited.
- **With the app minimised** (`4.1b-hidden.txt`, Jimmie's case: "set up tasks and alt-tab away"):
  - `use_app` attach=true and `world_status` on the app's world: **no answer in 20 s** each. That is rc.3's #87, fixed
    on the branch (checked on 5fcef69 and bf6f64f).
  - **A standalone `jetcarp mcp`** started a detached hunt (job 11) and closed at about 08:18:55; with the app
    minimised the whole time, `jobs status` showed it running at **2,244 soups/s** (162,638 → 230,533 soups over 30 s,
    72–103 s after its start), and it stopped cleanly when asked (exit 3). So searches set up through MCP run as jobs
    of their own, whatever the app does.
- **Finding: ⌘M does nothing in the app.** Jimmie: "⌘M doesn't minimize, it does nothing in the app. I had to click
  the yellow button." (M-3: ⌘H hides it, F11 shows the desktop.)

### 5.1 Odd files: pass; R #66 pass
- **Scenes** (`5.1-scenes-cli.txt`, `5.1-mcp-odd.txt`): a truncated scene, an unknown rule, an unknown rule name, a
  future format, a format number too large and an empty file each fail with a clear error and exit 1, on the command
  line and through MCP ("scene JSON: EOF while parsing a value at line 23 column 27", "unknown-rule.json: CA 1 'Life':
  rule 'B3/S23/Q9 Frobnicate': Generations need a state count, like B2/S/C3", "scene format 2 is newer than this
  JETCARP supports (1)", …). No crash.
- **Packs** (copies of the Framework's rc.2 pack, through MCP): a truncated part, a truncated manifest, a byte changed
  in the manifest and in a part: each refused by `check` and `import` ("… is altered or truncated", "manifest: not
  JSON", "a signature on this version does not verify"). The unsigned copy: "not signed by its publisher".
- **R #66** (`r-66.txt`): `pack info` on a tampered pack: "signed, but a signature does not verify: the version was
  changed after it was signed, or the signature is damaged"; its import is refused (exit 1); the unsigned import's
  refusal names "--allow-unsigned on the command line". **Pass.**

### 5.2 Two programs on one library: pass
`5.2-two-programs.txt`, with the app open on the same library and its Hunts window showing: a command-line explore
(job 12) and an MCP hunt (job 13) ran at once; `jetcarp jobs list` and MCP `job_status` each listed both running; MCP's
`job_stop` paused the command line's explore, and `jetcarp jobs stop` paused the MCP hunt.

### 5.3 Limits: pass; R #63 pass
- `5.3-over-limit.txt`, `t5_cli.stdout`: 16,001 × 16,000 and 37 × 6,918,919 refused ("grid is larger than 256 million
  cells"). The largest, 16,000 × 16,000 (256,000,000 cells), stepped 20 generations on Metal in 4.0 s (max RSS 3.36 GB)
  and on 12 CPU threads in 22 s (1.92 GB). (`{"cells": 256000001}` gives exactly 256,000,000: cell counts are
  approximate.) doctor's limit on the M2 Max is 4 GiB buffers, above the program's own.
- **R #63** (`5.3b-mcp-over-limit.txt`): "4096 x 4096 on square is 16,777,216 cells, over the limit of 4,000,000 cells
  (try 2000 x 2000)"; trihex: "50,331,648 cells (3 in each unit cell) … (try 1154 x 1154)".
- Not run: 5.3's 64-million-cell world on the host.

### 5.4 The graphics driver reset: the Acer's only.

### 5.5 No room to write: pass; R #65 pass; R #67's read-only library pass
- **R #65** (`5.5-readonly-mcp.txt`): with a read-only (555) output folder, every MCP tool that writes names the path with
  "Permission denied (os error 13)": `world_status`, `world_render` (and its wallpaper), `run_script` (twice),
  `search_start` (a pile), `media_render`, `search_runs` csv, `pack site`; `pack publish` stops first on the missing key.
- **R #67** (`r-cli.txt`): "bad-rule.json: CA 1 'Lifeish': rule 'B3/S23/Q9 Frobnicate': …" (the CA and the file named);
  a read-only (444) library lists its 116 patterns.

### R's command-line rows
- **#47:** pass (also 2.0). **#57** (`r-cli.txt`): a running search (nothing stored, and later with runs) is refused,
  and no `--to` folder is left; an empty hidden `.p57.store` is left beside it (the known rc.3 straggler, fixed for
  rc.4 in efe1a03).

# Phase 2, sitting M-7: Part 3, the upgrade and a newcomer's first hour (2026-11-16, 13:28–14:45 UTC)

**In Jimmie's own account, no new user:** "I would rather do that from here, this is a test machine, blow away and
reinstall any version of JETCARP, no new user is needed on the Mac." 3.2 came first (Homebrew's 0.4.1 was installed and
lived in), ending with uninstall, which gave 3.1 a clean slate. The everyday folder is backed up twice in `$T`
(`everyday-backup/` from before M-5, `everyday-before-upgrade/`), and `~/Pictures/JETCARP` was moved aside to
`$T/pictures-JETCARP-before-3.1`.

## 3.2 The upgrade from 0.4.1: pass, with a finding (the first login after the upgrade doesn't start the host)
Files: `3.2-use-041.txt`, `3.2-upgrade.txt`, `3.2-counts-{before,after}.txt`, `3.2-after-login.txt`, `3.2-uninstall.txt`.
1. **0.4.1 the everyday way:** Homebrew's (`/opt/homebrew/Cellar/jetcarp/0.4.1`: `bin/jetcarp`,
   `lib/jetcarp/libjetcarp_saver.dylib`, `share/jetcarp/packs`), its library lived in (90 patterns, 25 jobs, explorer
   profile from 0.4.0).
2. **Used a while, with 0.4.1:** `setup --profile desktop-art --yes` (recorded; the desktop offers only printed, as
   designed); a hunt (`--rules B3/S23,B36/S23 --soups 5000`) with finds; three finds rated with `library update --rating`
   (4, 5, 3); `host wallpaper on`, `host start`, `host rotation "Classics, hourly"`, `host login on` (a LaunchAgent running
   `/opt/homebrew/bin/jetcarp host serve --login`). Then: 94 patterns, 25 rules, 119 pattern rules, 159 sightings, 26 jobs,
   1,156 Quick Start entries, 1 run rating, 3 pattern ratings, 8 ants.
3. **The upgrade:** rc.3's program, saver library and starter pack put in place of 0.4.1's in the Cellar, each as a new
   file (so the running 0.4.1 host was undisturbed). `/opt/homebrew/bin/jetcarp --version`: `jetcarp 0.4.2-rc.3`.
4. **Logout and login: the host did not start.** `launchctl print`: "last exit reason = OS_REASON_CODESIGNING", "job state
   = spawn failed", "needs LWCR update | managed LWCR | has LWCR". macOS's crash report
   (`~/Library/Logs/DiagnosticReports/jetcarp-2026-11-16-083330.ips`, the login's second): termination namespace
   CODESIGNING, indicator "Launch Constraint Violation", "SIGKILL (Code Signature Invalid)", parent launchd, coalition
   `com.jimmieprodgers.jetcarp.host`.
   - `launchctl kickstart` straight after, with nothing changed, started it (rc.3, "Classics, hourly"), and launchd dropped
     "needs LWCR update". **A second logout and login started the host by itself** (one second before the console changed
     owner).
   - **Finding: after an upgrade replaces the binary, the first login kills the host (a launch-constraint violation:
     launchd's recorded code identity for the login item no longer matches); later launches work.** A user upgrades, logs
     in and has no live desktop until the next login, or until it's started by hand. Any upgrade that swaps the binary
     (`brew upgrade`, the installer) should meet it. A fix might re-register the LaunchAgent when the program changes,
     or launch through a stable app bundle identity.
5. **Nothing lost:** every table's row count unchanged (`3.2-counts-*.txt`), schema version 3, the three pattern ratings
   intact, `app.json`, `setup.json`, `host.json` and `host-program` byte-identical; only rc.3's built-in sync
   (`builtin_version` 0.4.2-rc.3) and a new `gpu-checks.json`. `setup --status` read 0.4.1's "Desktop art" record.
6. **`jetcarp uninstall`** (the plan, then `--yes`): stop the host, stop the login start, remove the lock file and the
   empty job-lock folder, forget the recorded host command: all "done"; the data (9.8 MB) and settings kept unless asked.
   As in M-5, launchd keeps the unloaded job until logout.
7. **For 3.1's clean slate:** `uninstall --yes --settings --data` and `brew uninstall jetcarp`. **Small finding:** on macOS the
   data folder is inside the settings folder, and `--settings --data` deletes the settings first, so the data step says
   "FAILED: … No such file or directory" though the data is gone with it.

## 3.1 A newcomer's first hour: pass, with eleven findings on the book and the uninstall (Jimmie the newcomer)
Jimmie followed the book from the release page; every confusion is in `3.1-newcomer.txt` (15 items), the checks in
`3.1-checks.txt` and `3.1-checks.txt.after`. In short:
1. **Installing:** read top-down, the page sends a candidate's tester to the latest release's installer; "Release
   candidates" is far below, its example naming v0.4.0-rc.1. With rc.3's installer the install worked as described
   (`~/.local/bin/jetcarp` → `~/.local/lib/jetcarp`).
2. **Neither Installing nor First run says how to open the app** (`jetcarp` with no arguments).
3. Jimmie: "I was hoping for an icon to click on." JETCARP has no app icon or launcher on any system (what it would take
   is in `3.1-newcomer.txt`: an icon, and on macOS a `JETCARP.app` made and signed on the Mac as the screen saver is).
4. **The setup window (Desktop art): pass** ("wallpaper is live"; start at login and the screen saver set; `setup
   --status` right).
5. **The book's command blocks can't be copied and pasted:** they hold a `$ ` prompt, the command and its output together
   (about 80 command lines in 12 pages). Jimmie: "None of these commands copy and paste." The hunting tutorial was stopped
   after its hunt, which ran (typed alone) with exactly the book's numbers (13,674 objects, 6,900 ships, 20 distinct).
   Small: the hunt's progress lines, wider than the Terminal, garble when redrawn.
6. **The first find in the library: pass** (the k2-017 ship in Tools → Pattern library).
7. **MCP with an assistant:** the book's `claude mcp add jetcarp -- jetcarp mcp` registers for one folder only (Claude
   Code's default local scope), so the first session didn't have JETCARP and built an HTML page itself. With `--scope
   user`, the tutorial's prompt worked: **a world and its picture** (in `~/Pictures/JETCARP`, `verify` ok), **a search** (two
   hunts, in the library), and **the app through use_app** ("it did so properly").
8. **Uninstall:** `jetcarp uninstall --yes` undid the host, login item and screen saver, but Jimmie: "It didn't uninstall":
   the program stays, and the last line lists eight ways to remove it. The guide's step 3 uses `releases/latest`'s
   installer (0.4.1's), which does remove a candidate (the scripts differ only in the version). Its table cell holds two
   commands joined by ", or", and copied whole fails ("unknown option --uninstall,"). The installer's messages point at
   `jetcarp paths` just after removing it.
9. **Afterwards nothing of JETCARP's is left outside its named folders** (pictures kept, as promised), but **Claude Code's
   registration remains**, failing ("Executable not found in $PATH"); neither the command nor the guide mentions it.

## The main session's check of #99 and #96 (6ea0c89, after M-7): pass

The branch at **6ea0c89** (with #96 bc1d72f and #98, "Cmd+M minimises the app's window"); built in 67 s, no warnings;
`--version` still says `jetcarp 0.4.2-rc.3`. Log: `99-check.txt`. In Jimmie's own account, the default folders.
- **Setup:** rc.3 by its installer (`~/.local/lib/jetcarp`; its last line: "start JETCARP with `jetcarp`"), `host wallpaper
  on`, `host start`, `host login on` (rc.3's LaunchAgent has no version comment). **Logout 1:** rc.3's host started at
  login (09:53:59, parent launchd; `managed LWCR | has LWCR`).
- **Step 1:** the build put in place of rc.3's program (a new file); `jetcarp setup --yes --seizure-warning no-disorder`
  ("saved your answer…", `photosensitivity.json`); `jetcarp host start`: "registered the login item with launchd, for
  JETCARP 0.4.2-rc.3", "launchd restarted the host as JETCARP 0.4.2-rc.3", exit 0. **One host, a new pid** (27167, `host
  serve --login`; rc.3's 26866 gone). `launchctl print`: running, no "needs LWCR update" (no LWCR at all until the next
  login). `plutil -lint`: OK; the plist carries `<!-- Registered with launchd by JETCARP 0.4.2-rc.3 -->`.
  - **Jimmie: one "Background Items Added" notification** after this step.
  - Caution: the comment records the version string, and this build shares rc.3's (`0.4.2-rc.3`); it re-registered
    because rc.3's plist had no comment. Two builds of one version string wouldn't be told apart.
- **Step 2, logout 2:** the host started at login (09:56:19, pid 28034, parent launchd), **no `OS_REASON_CODESIGNING`**, no
  new crash report; launchd recorded a new LWCR. (M-7's failing login, fixed.)
- **Step 3, `host login on` in three states, one host each time:** started by launchd → "registered with launchd, which
  restarted the host (pid 28261)"; none → "registered with launchd, which started the host (pid 28290)"; started by hand
  (`host serve`) → "registered with launchd; the host already running carries on". All exit 0.
- **Step 4:** the version comment deleted, everything quit, the app opened from Terminal and its window closed at once:
  stderr "JETCARP: registered the login item with launchd, for JETCARP 0.4.2-rc.3"; a host left running (pid 28383,
  launchd's); the comment back.
- **Step 5:** `launchctl bootout` of a job that isn't loaded exits **3**; `launchctl print` of a missing job exits **113**.
- **Step 6 (#96):** with `photosensitivity.json` moved aside, `host login on` and `host start` each refuse (exit 1) with the
  whole PHOTOSENSITIVE SEIZURE WARNING and how to answer it; no host starts. The answer put back.
- **Notifications:** Jimmie: "Only the one": one "Background Items Added" in all, after step 1's first registration; none
  for step 3's three `host login on` or the app's re-registration.
- **Cleaned up before M-8** (Jimmie: uninstall): `jetcarp uninstall --yes --settings --data`, the installer's
  `--uninstall`, and `claude mcp remove jetcarp` (user and local scopes). Nothing of JETCARP's left; the wallpaper and
  screen saver choices as before M-4. **Small:** the build's `uninstall` ("done: stop the host starting at login") still
  left the job loaded in launchd (`launchctl print` exit 0, its plist gone), as rc.3's `login off` did in M-5 and M-7.
  Now that #99 registers with bootstrap, `login off` and `uninstall` could boot it out too. Unloaded by hand.

## 2.MM (M-8): two monitors: pass, with findings; R #73 pass

The Q3277 (2560 × 1440, 60 Hz, scale 1), moved from the Framework, to the left of the built-in Retina (2056 × 1329
points, 4112 × 2658 pixels, scale 2, 120 Hz). rc.3's test host and app in the test folders (`env2.sh`), "Measure again
by itself when the monitors change" on since M-4 (`tune`: CPU 10%, GPU 25%, auto). One host process (pid 28818)
throughout. Logs: `2.MM-monitor.txt` (`dmon.sh`: each screen's status, host and app CPU, ioreg's GPU %, every 5–15 s),
`2.MM-tune.json` (step 2's fit), `2.MM-73.txt` and `2.MM-73-tune.json` (R #73 and step 4).

- **The app (2.APP 4's second monitor):** it opened on the built-in at its last saved place (x 25, y 113 points), not on
  the external monitor.
- **Step 1, two screens, one per monitor: pass.** In the app's Desktop background settings Jimmie set screen 0 ("Until it
  settles", on every monitor) to the Built-in Retina Display, added screen 1 on the Q3277 with "A classic a day".
  Jimmie: "Each monitor shows its own rotation, both crisp". `host status`: screen 0 on monitor 0 at scale 2, 303,455
  cells of 6 px; screen 1 on monitor 1 at scale 1, the turmite's 230,400 cells of 4 px.
- **Step 2, Fit with two monitors: each screen gets its own sweep, but nothing fits.** `host tune --json`: exit 0 in
  139 s, 10 scenes (3 on screen 0, 7 on screen 1), 67 sizes measured, **0 within the limits**.
  - **The CPU limit is split between the screens:** each size is judged against "the 5.0% limit, less 20%" (4.0%),
    where one monitor had 10% (8.0%) in M-4. Every size is over it, even the coarsest (the Retina's 32 px: 5.9–6.7%;
    the Q3277's 24 px: 4.8–6.0%). With nothing in the limits, Fit takes the coarsest size: the built-in went from
    303,455 cells of 6 px to **10,496 cells of 32.1 px**, about 30 times fewer. Jimmie: "Yes it's blocky".
  - **The Retina's frame times miss the budget at almost every size, with the external monitor attached:** p95 17–20
    ms against 16.7 ms (at 60 fps), as much at 32 px (10k cells) as at 6 px (303k); a few sizes measure 1–4 ms. In M-4,
    on the Retina alone, the frames were ≈ 6.5 ms down to 3 px. The Q3277's frames stay at 1.4–12.5 ms. The Retina's
    frames seem paced by the 60 Hz monitor, not by the size of the world.
  - Screen 1's recommended sizes: 24 px for Life, ForestFire, Cyclic spirals and Hodgepodge, and 4 px (its own size)
    for the turmite and Langton's ant.
  - GPU: "GPU share not measured on this adapter (it has no GPU timestamps): the GPU limit isn't applied", as in M-4.
- **Step 3, unplug and plug back in: pass.** At 15:15:09 the Q3277 came out: screen 1's world (the same 230,400 cells)
  moved onto the built-in at 8 px (scale 2), and the host's CPU fell from ≈ 85% to 20–30%. About 16 s later (15:15:25)
  **an automatic fit began** ("the monitors changed"), screen 0's scenes first. Jimmie plugged the Q3277 back in during
  it ("It tried to re-fit Life, so it was going through that when I plugged back in"), and the sweep went on to screen
  1's 7 scenes on the Q3277. By 15:18 both screens were back on their own monitors (screen 0 at 12 px for B36/S23,
  screen 1 at 4 px). No crash, the same process. Jimmie couldn't say whether the Q3277 looked oversized on its return
  ("it started re-fitting pretty quickly").
- **The cards don't scroll sideways.** Jimmie: "I can't see all the cards, as the left/right scroll doesn't work, none
  of the selected cards are visible." Each scene's row runs off the pane's right edge, where the selected (finer) sizes
  are. M-4's capture showed the same cut-off row on one monitor.
- **R #73: pass.** Read from `host.json`, which the cards are drawn from. After the automatic fit each screen's fit held
  only its own rotation ("Until it settles": 3 scenes; "A classic a day": 7). Then screen 0 moved to "Wolfram series",
  never fitted, and `host tune --screen 0` fitted it alone: its fit holds only Wolfram series' scenes, with no row of
  "Until it settles" left, and screen 1's fit is untouched.
  - **That fit took 737 s (12.3 min).** It sampled **40 of the series' 256 rules** (W0, W1, …), at up to 9 sizes each
    (360 sizes). With screen 0 fitted alone, the limit was the whole 10% again, but only 9 sizes (in 7 of the 40 rules)
    came within the limits. The frames were the main reason: 329 of the 351 failing sizes were over on frame time
    (17–20 ms). Recommended sizes 12–32 px; the built-in showed W0 at 32.1 px.
  - **Jimmie: "Just a note, a fit should never sweep through hundreds of options, it should pick a single rule and
    just fit with one in the series, not every one in the series. That's a bit crazy, and not at all what I
    wanted."** A series rotation is one kind of scene with the rule number changing; it should be fitted once, on one
    representative rule (or one per kind of scene), and that size used for the whole series.
- **Step 4, the Q3277's resolution changed while the host ran: pass, with a finding.** No crash. Jimmie changed the
  resolution (15:36:40) and set it back to 2560 × 1440 (15:37:16). Screen 1 refilled the monitor each time (261,888
  cells at 3 px at the new resolution; 230,400 at 4 px again once set back). **The host did fit again by itself**: at
  15:36:53, 13 s after the first change, it logged "the monitors changed; sweeping the desktop background's sizes
  again", with **47 scenes**: screen 0's 40 Wolfram rules first, though the built-in hadn't changed, then screen 1's 7.
  The Q3277's screen wouldn't have been reached for about 12 minutes, so Jimmie saw nothing happen there ("Changed
  resolution, but it did not refit"). The sweep was at scene 7 of 47 when I stopped the host (15:38:26).
  - **Finding:** an automatic fit after a monitor change sweeps every screen. It could sweep only the screens whose
    monitor changed, starting with them.
- **The host's memory grows with each two-screen sweep.** `host status`: 135 MB at the start, 147 MB before step 2's
  fit, **399 MB after it**, 327 MB steady, **536 MB at the peak** of the replug sweep, 315 MB after it, 376 MB after
  the Wolfram fit, 339 MB at the end. `footprint`: 565 MB during the sitting, **781 MB at the end**. On one monitor
  (M-4's R #69) it stayed at 162 MB after six sweeps.
- **Put back:** `host stop` (it ended the sweep), the app closed, the monitor stopped. The Q3277 goes back to the
  Framework.
- **Afterwards:** Jimmie: "My own wallpaper is back on both."
- **Jimmie on Fit's time: "A fit should be 10 seconds, maybe 30 seconds. If we can't hit that target, I want the
  feature removed. You can manually tune faster than this."** For scale, rc.3's fits on this Mac took 45–56 s (M-4, one
  monitor, 3 scenes × 9 sizes), 139 s (step 2, two screens, 10 scenes), 737 s (R #73, Wolfram series, 40 scenes), and
  step 4's automatic fit had 47 scenes queued (about 15 min). Each size is measured for about 2 s, so 10–30 s allows
  roughly 5–15 sizes in all, not per scene.
