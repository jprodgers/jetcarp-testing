# v0.4.2-rc.1 on the Mac: notes

System: `00-system.txt` (macOS 27.2.1, build 26B131; Apple M2 Max, 8 performance + 4 efficiency
cores, 38-core GPU, Metal 4; 64 GB; the built-in 3456 × 2234 Retina panel only, no external
monitor; on mains). Rust is installed (cargo 1.99.1), so the branch's GPU tests can run.

State before the wave: the everyday JETCARP is Homebrew's **0.4.1** (`/opt/homebrew/bin/jetcarp`).
**No everyday host is running**: no `jetcarp` process and no JETCARP LaunchAgent. The everyday
folder is `~/Library/Application Support/jetcarp`; its newest file is from 2026-11-13 18:36.

The test folder is `~/jetcarp-rc-042` (`$T`), with `JETCARP_CONFIG_DIR`, `JETCARP_DATA_DIR` and
`JETCARP_OUT` pointed at `$T/config`, `$T/data` and `$T/out` for every command.

Per the main session's note of 2026-11-15, the Mac runs **M0, G1 and G2 on rc.1**, then the
branch's GPU tests and a parity pass with the branch's build (G2b), and then waits for rc.2.

## M0. Unpack and check: pass

Files: `M0-version-paths.txt`, `M0-results-doctor.txt`, `M0-results-doctor.json`.

1. **The hash is right:** `jetcarp-0.4.2-rc.1-aarch64-apple-darwin.tar.gz` (29.3 MB, downloaded in
   about 1 s) has SHA-256 `91cfbd3ac4d7cc5d6187510faca1d4636316bbe19b60b2ea511a42f9180264dc`, the
   same as its line in `SHA256SUMS`. The archive holds one folder with `jetcarp` (61.9 MB, arm64,
   ad-hoc signed), `libjetcarp_saver.dylib`, `packs/` and the licence files; unpacked with
   `--strip-components=1` into `$T/bin`. **`--version`: `jetcarp 0.4.2-rc.1`.**
2. **`paths`:** settings `$T/config`, data `$T/data`, output `$T/out`, bundled `$T/bin/packs`;
   nothing else.
3. **doctor** (first run, exit 0, 0.61 s; then 0.17-0.18 s):

       GPU: auto (automatic)
         setting: /Users/Jimmie/jetcarp-rc-042/config/gpu.json (not saved)
         the app: auto, from automatic (its own choice: follow)
         the desktop background: auto, from automatic (its own choice: follow)
         display: Apple M2 Max, Metal (integrated)
             why: the adapter driving the screen (automatic)
             limits: 29 storage buffers per stage, 4 GiB storage bindings, 4 GiB buffers
             self-test: passed (588 ms, kept from before): 53 world rules and 33 explore batches matched the CPU
             the GPU simulation uses it
         compute: Apple M2 Max, Metal (integrated)
             why: the fastest adapter (automatic)
             limits: 29 storage buffers per stage, 4 GiB storage bindings, 4 GiB buffers
             self-test: passed (588 ms, kept from before): 53 world rules and 33 explore batches matched the CPU
             the GPU simulation uses it

       Graphics adapters (* = used for computing)
         * Apple M2 Max (Metal, IntegratedGpu)

   As expected: the **M2 Max on Metal** for both display and compute, one adapter in the list, and
   its **self-test passed** (53 world rules and 33 explore batches). Display and compute share one
   test (the same time on both lines). The driver field is empty on Metal.
4. **`which jetcarp`** is still `/opt/homebrew/bin/jetcarp` (0.4.1).
5. **No security prompt.** The program ran at once from Terminal. The download and the unpacked
   files carry `com.apple.provenance` (empty) but **no `com.apple.quarantine`**, as expected for
   curl.

Findings: the same as the Acer's A0 (#17, known on rc.1): on this first run there is no settings
folder, doctor doesn't make one, and the self-test says "kept from before" (`"cached": true` in the
JSON) although nothing is saved. The first self-test took 588 ms, later ones about 145 ms
(probably Metal's own shader cache).

## G1. Self-test (Metal): pass

Files: `G1-auto.txt`, `G1-off.txt` (the plan's two), `G1-again1.txt`, `G1-again2.txt` (check 3
without a settings folder), `G1-cache1.txt`, `G1-cache2.txt` (with one), `G1-off-cached.txt`,
`G1-gpu-checks.json`.

1. **The M2 Max's self-test passes** on Metal: "53 world rules and 33 explore batches matched the
   CPU", 143-146 ms on each run without a settings folder (doctor 0.17-0.18 s), 172 ms when first
   saved. No failure.
2. **`off`:** the header says `GPU: off (JETCARP_GPU=off)`, with "the app: off" and "the desktop
   background: off, from JETCARP_GPU=off". **But the adapter lines still say "the GPU simulation
   uses it" and the self-test still runs** (146 ms), as on the Acer (#17, fixed for rc.2).
   **Automatic** picks as in M0 (`G1-auto.txt` equals M0's doctor apart from the times).
3. **Caching:** without a settings folder, every doctor re-runs the test (143-146 ms) and says
   "kept from before" (#17). With `$T/config` made by hand, the first doctor writes
   `config/gpu-checks.json` (0.21 s, 172 ms) and the next is a real cache hit: **0.03 s**, the
   same 172 ms, "kept from before". The cache key is
   `Apple M2 Max | Metal | 0000:0000 |   | 0.4.2-rc.1 | 6f92d1c06a71c229.1`: the empty driver field
   gives the double space that #26 removes.

## G2. Parity suite (Metal): pass, including the drop scenes

Files: `G2-metal.csv`, `G2-metal.log`, `G2-drops-rc1.csv` (made by `G2-drops.py`). The runner is
the plan's `parity/parity.py`, copied with the 371-scene set (after `git pull`) to `$T/parity` and
run unchanged, with `JETCARP_GPU` unset: `python3 parity/parity.py "$J" "$T/parity" G2-metal.csv`.

1. **No mismatch: "371 scenes: CPU matches 371, GPU matches 371; all 300 generations on the GPU in
   334"**, adapter "gpu (Apple M2 Max, Metal)" on every GPU row, no ERROR rows. **The whole pass
   took 71 s** (20:06:26 to 20:07:37), against 7 min per pass on the Acer.
2. **334 scenes ran all 300 generations on the GPU** (the Framework's 327 plus the seven drop
   scenes), 1 partly (n=2 `script-five`, 151 on the GPU: "149 of 300 generations on the cpu (12
   threads): Rule 30 (W30) runs only on the CPU") and 36 on the CPU only, each with a reason
   ("… runs only on the CPU": Wolfram, hex and hex3 rules, ants, layered rules, the table parity
   rule, Lenia, …). **Scene by scene, `gpu_gens` equals `expected.csv`'s: 0 differences.**
3. **Medians** for the 334 all-GPU scenes (each includes starting `jetcarp`):

   | | median `cpu_s` | median `gpu_s` | GPU faster than CPU | sum `cpu_s` / `gpu_s` |
   |---|---|---|---|---|
   | Mac, M2 Max (Metal) | 0.079 | **0.039** | **304 of 334** | 51.2 s / 17.2 s |
   | (Framework, expected.csv) | 0.079 | 0.059 | | |
   | (Acer, RTX Vulkan) | 0.203 | 0.986 | 11 of 327 | |

   **Opening the Metal device costs almost nothing:** the 36 CPU-only scenes take a median
   0.021 s with `--gpu` against 0.009 s with `--cpu`. So, unlike the Acer, the GPU is faster for a
   one-off 300-generation run of a typical scene here. The biggest wins: Larger than Life n=203
   (`R10,C2,S122-211,B123-170`) 3.35 s on the CPU against 0.29 s, n=202 1.56 s against 0.15 s, the
   sandpiles n=10-12 and 93 about 1.0-1.3 s against 0.12-0.18 s, drop scene 369 0.95 s against
   0.13 s. The one heavy scene the GPU doesn't speed up is n=4 `sandpile-identity-cairo` (0.97 s
   against 0.96 s). For the thresholds: on the M2 Max, even small worlds pay off on the GPU.
4. **The drop scenes (364-370) are right on Metal with rc.1**, unlike the UHD (#20): all seven
   match `expected.csv` on the GPU at 300 generations, and `G2-drops.py` shows CPU = GPU at
   generation 1 too, with the same populations. E.g. 365 (drop 1 on square 40x30): population
   20,001 and hash `60047217d97ba607` on both (the CPU hash in the Acer's failing test); 370 (the
   saturating one): 4,294,967,295 on both at generation 1, 2,043,799,666 at 300. So rc.1's
   saturating add in `sim.wgsl` compiles correctly on Apple's Metal compiler; the bug was Intel's.

5. **The branch's GPU tests on Metal (Rust installed): all pass.** Branch `release-0.4.2` cloned
   with depth 1 at its head, **67fb2f7** ("Clips for a search on few tilings; …", which has the #20
   fix: `thresh` in `sim.wgsl`). `cargo test --release -p jetcarp-gpu --no-fail-fast -- --nocapture`
   (file `G2-tests-metal.txt`): built in 34 s, ran in about 1.1 min, **55 passed, 0 failed, 1
   ignored**, "GPU tests on Apple M2 Max, Metal". That includes `sandpile_edges_drops_and_patches`,
   `sandpile_repeats_and_scripts` and `sandpile_scenes`. The ignored one,
   `world_larger_than_one_dispatch_dimension` ("heavy: two worlds of 17 million cells"), **passes
   too** when run with `--ignored` (2.1 s; `G2-tests-metal-ignored.txt`).

## G2b. Parity with the branch's build (67fb2f7): pass

Files: `G2b-build.txt`, `G2b-doctor-1.txt`, `G2b-doctor-2.txt`, `G2b-doctor-off.txt`,
`G2b-gpu-checks.json`, `G2b-21-26.txt`, `G2b-metal.csv`, `G2b-metal.log`, `G2b-drops.csv`.

`cargo build --release -p jetcarp` took 1 min 54 s (`--version` still says `jetcarp 0.4.2-rc.1`).
It ran with **its own fresh folders**, `$T/b/config`, `$T/b/data` and `$T/b/out`, so rc.1's
folders never saw the newer build.

1. **doctor (#17 fixed on Metal):** the first run made `$T/b/config/gpu-checks.json` and said
   "**passed (389 ms): 59 world rules and 33 explore batches matched the CPU**" (rc.1: 53), with no
   "kept from before" (0.43 s). The second run: "passed (389 ms, kept from before)", 0.03 s. With
   `JETCARP_GPU=off`, each adapter says "**not used, and not tested: the GPU simulation is off**".
   The cache key is now `Apple M2 Max | Metal | 0000:0000 |  | 0.4.2-rc.1 | 9bad7813c3a55612.2`:
   no double space (#26).
2. **A preview of rc.2's R0 checks** (`G2b-21-26.txt`): `JETCARP_GPU=nosuchgpu`, `run --gpu` on
   scene 0 gives backend "gpu (Apple M2 Max, Metal; **no nosuchgpu adapter was found, so the best
   one**)", with the right hash; doctor's display and compute lines end the same way (#21). With
   `WGPU_BACKEND=metal`, doctor's Environment block lists it (#26).
3. **Parity, all 371 scenes: "371 scenes: CPU matches 371, GPU matches 371; all 300 generations on
   the GPU in 334"** (77 s). **Every GPU hash and every `gpu_gens` equals rc.1's run**, so the #20
   change to the shader made no difference on Metal. The drop scenes: CPU = GPU at generations 1 and
   300, 14 of 14. Medians (all-GPU) 0.080 / 0.043 s, GPU faster in 304 of 334, as with rc.1.

## State

Nothing installed. `which jetcarp` is still Homebrew's 0.4.1, and the everyday folder is
unchanged (its newest file is still from 2026-11-13 18:36). No `jetcarp` process is left running.
`$T` holds rc.1 (`bin/`), its folders, the branch clone and build (`src/`, 3.5 GB with
`target/`) and the branch build's folders (`b/`). The rest of the Mac rows wait for rc.2, per the
main session's note.
