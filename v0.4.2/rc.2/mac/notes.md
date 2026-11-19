# v0.4.2-rc.2 on the Mac: notes

System as in rc.1 (`../../v0.4.2-rc.1/mac/00-system.txt`): macOS 27.2.1, Apple M2 Max (12 cores,
38-core GPU, Metal 4), 64 GB, on mains, the built-in Retina panel only. Everyday JETCARP: Homebrew's
0.4.1, untouched. Test folder `~/jetcarp-rc-042b` (`$T`), with `JETCARP_CONFIG_DIR`, `JETCARP_DATA_DIR`
and `JETCARP_OUT` in it.

## Phase 1 (unattended, 2026-11-15 09:01–13:17 UTC)

One script, `phase1.sh`, run as `caffeinate -is bash phase1.sh` (so the Mac couldn't sleep). Its log
is `phase1.log`. It ran 0, 1.1, 1.2, 1.3, 1.6, then 1.4, so the hunt is job 1 and the explore job 2,
as on the Framework. 1.5 was not run.

### 0. Unpack, and a first doctor on the fresh folder

`0-unpack.txt`, `0-doctor-first.txt`, `0-doctor-second.txt`.
- **Hash:** `jetcarp-0.4.2-rc.2-aarch64-apple-darwin.tar.gz` (29.4 MB) has SHA-256 `f318a493…93cd`, as in
  `SHA256SUMS`. `--version` says `jetcarp 0.4.2-rc.2`. Provenance xattr only, no quarantine.
- **First doctor**, run before anything else so 2.0's #17 check still has a fresh-folder record:
  "self-test: passed (372 ms): 59 world rules and 33 explore batches matched the CPU", with no "kept
  from before". It wrote `config/gpu-checks.json`. The second doctor (0 s) said "passed (372 ms, kept
  from before)". **#17 fixed on the Mac.** Phase 2's 2.0 will find the settings folder already made.

### 1.1 Parity, 371 scenes, Metal: pass

`1.1-metal.csv`, `1.1-metal.txt`. "371 scenes: CPU matches 371, GPU matches 371; all 300 generations on
the GPU in 334", adapter "gpu (Apple M2 Max, Metal)", 71 s.

### 1.2 Long-run parity, 40 scenes × 5,000 generations, Metal: pass

`1.2-metal.csv`, `1.2-metal.txt`. "40 scenes: CPU matches 40, GPU matches 40; all 5000 generations on
the GPU in 40", 64 s.

### 1.3 The whole test suite on the M2 Max: pass

`1.3-tests.txt`. The tag cloned with depth 1 (git warns that the annotated tag `ecc4009` "is not a
commit" and checks out its commit, **2d4b84c**). `cargo test --release --workspace --no-fail-fast` ran
in a scratch environment: `HOME=$T/test-home` (with `CARGO_HOME` and `RUSTUP_HOME` kept), and no
`JETCARP_*` variables. It took 689 s including the build, and exited 0.
- **991 passed, 0 failed, 33 ignored, in 140 test binaries.**
- The ignored ones are the app's screenshot tests (`app::shots::*`), offscreen window tests
  (`offscreen::tests::*`, `setup_ui::tests::offscreen_setup_wizard`), surveys and timings
  (`preset_survey`, `profile_survey`, `cpu_cost_by_family`, `big_world_reseed_timing`,
  `gpu_prefix_speed`, `hunt_*`), `keepawake::tests::take_and_release`, `gun_hashes`,
  `write_golden_packs`, the slow ones (`size_classes_exact_vs_float_level6`,
  `spectre_exact_equals_float_level6`, `spectre_window_equals_level_8_cell_for_cell`) and
  `world_larger_than_one_dispatch_dimension` (heavy; it passed on Metal in rc.1's G2 with
  `--ignored`).
- The everyday folder was untouched before and after.

### 1.6 The deterministic hunt: pass

`1.6-hunt.json`, `1.6-hunt.err`, `1.6-status.json`, `1.6-status.txt`. Hunt job 1, 12 s (10,337
soups/s): "20,000/20,000 soups in each of 6 groups, 760,892 objects (ships 51,012, osc 236,468, still
473,412), 1,783 distinct". **`finds` and `progress.by_class` in `1.6-status.json` are identical to the
Framework's and the Acer's.**

### 1.4 A long search with a crash in the middle: pass, apart from the known #49, #51, #53

Files: `1.4-start.json`, `1.4-watch.txt` (one sample a minute: the runner's pid, RSS and %CPU, then
`jobs status`'s first lines), `1.4-status-before-kill.txt`, `1.4-wait-after-kill.txt`,
`1.4-status-after-kill.{txt,json}`, `1.4-resume.json`, `1.4-status-end.{txt,json}`, `1.4-key.txt`,
`1.4-export.txt`, `1.4-check.txt`, `1.4-import.txt`, `1.4-import-jobs.{txt,json}`, `1.4-counts.txt`.

1. **The search:** `search explore --minutes 120 --label long --detach --json` started job 2 at 09:15
   UTC. Its runner is `…/bin/jetcarp jobs resume 2 --library …/library.sqlite --quiet --minutes 120`.
   It ran on "Apple M2 Max, Metal" with 6 threads for runs on the processor and 4 for the GPU's
   batches, of 12 cores (2 left free).
2. **The first hour:** 272,936 runs by the kill, with 27,735 elites in 13,251 niches, 1,341
   confirmed. **The rate never said 0/s** in any of the 239 one-minute samples over the whole 4 hours
   (median 75/s, 26–112/s). **#22 fixed.**
3. **The kill:** `kill -9` on the runner at +60 min (10:15:44). **`jobs wait 2 --timeout 180` exited 6
   (gone) after 45 s.** But `jobs status` at that moment still said "status running", JSON
   `"stale": false`, `"resumable": true` (**#49**, as on the Framework and the Acer).
4. **The resume:** `jobs resume 2 --detach` started a runner with no `--minutes`
   (`…jobs resume 2 --library … --quiet`). It picked up from the last checkpoint: 269,575 runs at
   +62 min, against 272,936 just before the kill. **It had no end (#51):** it ran on past the
   120 minutes until the script's own cap (4 hours after the start) called `jobs stop` at 13:16:21.
   `jobs wait` then exited 3 (paused) within 8 s.
5. **The end:** "explore 2: 1,120,514 runs, 51,926 elites in 23,283 niches (3,321 of them confirmed),
   574 of 1,359 tilings; status paused, 3 h 59 min run over every session, 17,733 confirmation runs,
   1,139,316 candidates tried, 7.53 GB of memory". `jobs runs` (stage 1) lists 1,120,514 runs, and
   `--stage 2` lists 17,733.
6. **Memory (#53):** the status's figure was 5.09 GB at 30 min and 5.51 GB at the kill. The resumed
   runner started at 0.61 GB and passed 4 GB within 5 minutes. It was then 5.91 GB at 2 h, 6.44 GB at
   3 h and 7.53 GB at the end, still rising. The runner's RSS peaked at 7.63 GB. As on the Framework
   (7.3 GB at 4 h 14 min).
7. **The pack, with no `jobs seal`:** `pack key --name "rc.2 test publisher"`, then `pack export --to
   $T/rc2-long --feed rc2-long --no-media` (1 s): **"explore job 2 (search c022e749…): sealed its newest
   138,247 runs first, so the pack carries every run"**. **85 MB** (86,616 KiB). `pack check`: exit 0.
8. **The import into a fresh library** (5 s): 1,454 patterns and 1,783 sightings (the 1.6 hunt came
   along), searches 1. The imported jobs are explore 1 ("paused … **not run here yet**", #37) and
   hunt 2 ("imported from pack rc2-long …"). **Stage 1: 1,120,514 runs; stage 2: 17,733: the same as
   the search. #35 pass.**
   - Small: the imported job's line says "(3,314 of them confirmed)", where the search says 3,321
     (the elites and niches, 51,926 in 23,283, are the same). rc.1's A10 import showed a gap like this
     too (80 against 133).

At the end, Homebrew's 0.4.1 was still `jetcarp`, the everyday folder unchanged (newest file still
2026-11-13 18:36), and no `jetcarp` process left running.
