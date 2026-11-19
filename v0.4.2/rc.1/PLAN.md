# Release candidate v0.4.2-rc.1

**What this wave tests:** everything 0.4.2 changes, on all three machines and **all four GPU
vendors** (AMD on the Framework, NVIDIA and Intel on the Acer, Apple on the Mac), before anything
reaches `main`. It is a heavy wave on purpose. Since the first draft of this plan, 0.4.2 also gained:
- **GPU first:** every rule family that can run on the GPU now does, and the GPU is the default
  wherever a capable one is present, with the CPU as the fallback. Results must be **bit-identical**
  on every system, so the core of this wave is a parity suite: every built-in Quick Start scene, run
  on each machine's CPU and GPU, must give exactly the Framework's hash.
- **A Desktop background pane** of its own, and **Fit to this computer**, which shrinks each wallpaper
  scene's cells until it stays within your CPU and GPU limits. Its GPU timing works differently on
  Windows and macOS than on Linux, so the laptops matter most here.

Also new: the explore runs' Parquet schema 2, carried in packs; new commands; a rating page that runs
in your browser; and new job and lock handling that behaves differently on Windows. The main session
tests the Linux and GNOME parts on the Framework.

**The release:** https://github.com/jprodgers/jetcarp/releases/tag/v0.4.2-rc.1, a public
pre-release built by the release workflow from the branch `release-0.4.2`. It isn't on `main`,
and PyPI, crates.io, Homebrew and Scoop don't get it, because the tag has a `-` in it.

## What's new in 0.4.2 (so you know what you're looking at)

| Change | Issue |
|---|---|
| A CPU-only explore search confirms its elites, and runs every candidate it makes | #3 |
| JACA's second sign is coloured with Koi (white to red), so still territories of the two signs no longer look alike | #6 |
| Upgrading JETCARP upgrades its GNOME extension (Linux only) | |
| JACA sign measures: `sign_pos`, `sign_balance`, `sign_sorted`, `sign_trade`, `sign_lost`; run schema 2; a JACA run that lost a sign scores ×0.3 | |
| A smart JACA search: parents picked by quality, `transplant`, `transplant-scaled` and `balance` runs, and `--parents-from JOB` | |
| `jobs refit` fits a score model to your ratings; `search explore --score` and `jobs rescore --score` use one | |
| `jobs clips --page` writes a rating page; `jobs review --from FILE` reads its ratings back | |
| `jobs runs --measures all --format csv\|json --limit 0 --out FILE` exports every measure | |
| `jobs wait JOB`, whose exit status says how the job ended | |
| `--max-rss-gb` for hunts and bounded searches | |
| `library soup ID` rebuilds the soup a hunt find came from | |
| Scripts: `w.neighbours`, `w.live_cells`, `w.tile`; a built-in `jaca-territories` example | |
| A `V` may follow the B or S counts; a search checks all its rules before it starts | #5 |
| The stale `explore-supervise.sh` is gone | #4 |
| An edge-neighbour rule keeps its `V` in its name | #7 |
| A hunt's progress line reads "100/100 soups in each of 1,200 groups" | #8 |
| The JACA page says the explore search runs JACA on the GPU | #9 |
| **GPU first:** JACA (glow, counts, blast up to 64), B0 Life-like, Margolus, Larger than Life, forest fire and the sandpile rule run on the GPU world stepper; about 90% of the built-in scenes run entirely on the GPU | |
| **One GPU choice for everything:** `gpu.json` (Automatic, On, Off, plus an adapter), `JETCARP_GPU=off\|on\|auto\|software\|integrated\|discrete\|<name>`, `--cpu` and `--gpu`; a cached 100 ms self-test against the CPU; `doctor` shows the display and compute adapters, why, their limits and the self-test | #11 |
| The GPU is the default in the app, host, `run`, wallpapers, scripts, MCP, explore, hunts and piles, where the world is big enough (displays from 16,000 cells; runs by their total work) | |
| Hunts and piles asked for the GPU fall back to the CPU when there's none | #10 |
| CI runs the GPU parity tests on a software GPU | #12 |
| A GPU batch that fails part way puts the world back as it was | #13 |
| **The Desktop background pane**, and **Fit to this computer** (`jetcarp host tune`): CPU and GPU limits and a frame-rate target; a visible sweep of cell sizes in both directions, down to 1 physical pixel (patch levels on aperiodic tilings), then cards to pick from per scene, with *Recommended* = the finest within the limits; again by itself when monitors change, keeping your picks where they fit | |
| GPU on or off: the shared setting is the default, and the app and the Desktop background can each override it (*Follow the shared setting*, *On*, *Off*); `JETCARP_GPU` beats everything | |

## Method

As before:
- record each step as **pass**, **fail** or **skip**, with a note, in your machine's table at the end
  of its section;
- save outputs and screenshots under `results/v0.4.2-rc.1/<machine>/`;
- commit and push after each section, so a failure part-way still leaves results behind;
- ask Jimmie each "Check" one at a time, and say before anything changes the desktop.

**Keep the everyday JETCARP and its library untouched.** The Acer's everyday copy is Scoop's 0.4.1,
and the Mac's is Homebrew's 0.4.1. This wave doesn't install anything. It unpacks the candidate's
archive into a test folder and runs it by its full path. Every command runs with JETCARP's folders
pointed at that test folder, so the candidate never opens the everyday library. (0.4.2 adds columns
and a run schema that 0.4.1 can't read back.)

**Times are rough guides.** If a step takes far longer than its estimate, record how long it took
and move on.

---

## Acer (Windows 11)

Use PowerShell. Every command below assumes these lines have been run in the same window. If you
open a new window, run them again.

    $T = "$env:USERPROFILE\jetcarp-rc-042"
    $env:JETCARP_CONFIG_DIR = "$T\config"
    $env:JETCARP_DATA_DIR   = "$T\data"
    $env:JETCARP_OUT        = "$T\out"
    $J = "$T\bin\jetcarp.exe"
    Set-Location $T

### A0. Unpack and check (5 min)

    New-Item -ItemType Directory -Force $T, "$T\bin" | Out-Null
    Invoke-WebRequest https://github.com/jprodgers/jetcarp/releases/download/v0.4.2-rc.1/jetcarp-0.4.2-rc.1-x86_64-pc-windows-msvc.zip -OutFile rc.zip
    Invoke-WebRequest https://github.com/jprodgers/jetcarp/releases/download/v0.4.2-rc.1/SHA256SUMS -OutFile SHA256SUMS
    (Get-FileHash rc.zip -Algorithm SHA256).Hash.ToLower()   # compare with the zip's line in SHA256SUMS
    Unblock-File rc.zip
    Expand-Archive rc.zip -DestinationPath "$T\bin-unpacked" -Force
    # move the program files up into $T\bin (the zip may hold a folder); then:
    & $J --version
    & $J paths
    & $J doctor > results-doctor.txt

Checks (record the answers):
1. Is the hash right, and does `--version` say `jetcarp 0.4.2-rc.1`?
2. Does `paths` show settings, data and output under `$T` and nowhere else?
3. In `doctor`'s **GPU** block: which adapter does **display** use, and which does **compute** use,
   and why? On this Optimus laptop, display should be the adapter driving the screen (probably the
   Intel UHD for the laptop panel) and compute the RTX 3050. Does the **self-test** say passed, with
   how many world rules and explore batches, and how long? Copy the block into your notes.
4. Is `where.exe jetcarp` still Scoop's 0.4.1 (`…\scoop\shims\jetcarp.exe`)? It must not have
   changed.

Save `results-doctor.txt` to `results/v0.4.2-rc.1/acer/`.

### G1. Each GPU's self-test (10 min)

The candidate tests a GPU against the CPU before trusting it, and remembers the result per adapter
and driver. Run `doctor` once per way of reaching each GPU, and keep each output:

    $env:JETCARP_GPU = "RTX";  & $J doctor > G1-rtx-vulkan.txt
    $env:WGPU_BACKEND = "dx12"; & $J doctor > G1-rtx-dx12.txt; Remove-Item Env:WGPU_BACKEND
    $env:JETCARP_GPU = "UHD";  & $J doctor > G1-uhd.txt
    $env:JETCARP_GPU = "off";  & $J doctor > G1-off.txt
    Remove-Item Env:JETCARP_GPU;  & $J doctor > G1-auto.txt

Checks:
1. For the RTX (Vulkan and DX12) and the UHD: does the self-test pass, and how long does it take?
   A **failed** self-test is the most important result of this wave: copy its full text.
2. With `off`, does doctor say the GPU simulation is off? With `auto`, does it pick as in A0?
3. Run `& $J doctor` again with `JETCARP_GPU=RTX`: does it say the self-test result was kept from
   before (cached)?

### G2. The parity suite (an hour, unattended)

Every built-in Quick Start scene (364 of them) runs for 300 generations on this machine's CPU and on
its GPU, and each hash must equal the Framework's CPU hash in `expected.csv`. On the Framework, 327
scenes run entirely on the GPU, 1 partly, and 36 (Lenia, ants, row rules) only on the CPU, with no
mismatch. This one step checks GPU against CPU on this vendor, and Windows against Linux.

The scenes and the runner are in this repository (`git pull` first): `parity/scenes/`,
`parity/expected.csv`, `parity/parity.ps1` (`parity/parity.py` for the Mac). Copy the folder to
`$T\parity`, then run it once per adapter:

    $env:JETCARP_GPU = "RTX";  .\parity\parity.ps1 -J $J -Dir "$T\parity" -Out G2-rtx-vulkan.csv
    $env:JETCARP_GPU = "RTX"; $env:WGPU_BACKEND = "dx12"
    .\parity\parity.ps1 -J $J -Dir "$T\parity" -Out G2-rtx-dx12.csv; Remove-Item Env:WGPU_BACKEND
    $env:JETCARP_GPU = "UHD";  .\parity\parity.ps1 -J $J -Dir "$T\parity" -Out G2-uhd.csv
    Remove-Item Env:JETCARP_GPU

(`parity.ps1` hasn't been run on Windows yet. If it fails to parse or misreads the JSON, fix the
script, not JETCARP, and commit the fix with a note.)

Checks:
1. For each adapter: "CPU matches 364, GPU matches 364"? List every MISMATCH line in full, and
   commit the CSVs.
2. How many scenes ran all 300 generations on the GPU (about 327 expected)?
3. From the CSVs, the median `cpu_s` and `gpu_s` for the scenes that ran on the GPU. These include
   starting the program each time, so they're rough. They tell the main session whether the size
   thresholds suit this GPU.
4. **Optional, if Rust is installed** (`cargo --version`; don't install it without asking Jimmie):
   clone the branch and run the GPU tests on each adapter:

       git clone --branch release-0.4.2 --depth 1 https://github.com/jprodgers/jetcarp.git "$T\src"
       Set-Location "$T\src"
       $env:JETCARP_GPU = "RTX"; cargo test --release -p jetcarp-gpu 2>&1 | Tee-Object "$T\G2-tests-rtx.txt"
       $env:JETCARP_GPU = "UHD"; cargo test --release -p jetcarp-gpu 2>&1 | Tee-Object "$T\G2-tests-uhd.txt"
       Remove-Item Env:JETCARP_GPU; Set-Location $T

### A1. GPU explore search (12 min)

This tests the explore batch on NVIDIA, and that the GPU is now the default (no `--gpu`).

    & $J search explore --families life_like,generations,jaca,cyclic --minutes 10 --label gpu-mix
    & $J jobs status 1 > A1-status.txt
    & $J jobs runs 1 --limit 0 --format csv --out A1-runs.csv

Checks:
1. Without `--gpu`, does the status line still name the RTX 3050 (the compute adapter), and say
   *N confirmed* with N above 0?
2. How many runs, and how many runs a second (in the status)?
3. Did the laptop stay usable (the search leaves two cores free)? Jimmie's impression.
4. Any error or GPU warning in the output? Paste it.

### A2. GPU runs replay the same on the CPU (15 min)

Every explore run replays exactly from its scene. A run screened on the GPU must give the same end
population on the CPU. Take 20 JACA runs and 10 Life-like runs from job 1, **with all their
measures**:

    & $J jobs runs 1 --family jaca --limit 20 --measures all --format json > A2-jaca.json
    & $J jobs runs 1 --family life_like --limit 10 --measures all --format json > A2-life.json

For each run id: save its scene, run it on the CPU for the run's `gens`, and compare. The run's
end density, **`measures.density`** (not the top-level `density`, which is the mean over the last
quarter), must equal the replay's population (the sum of `fields[].population` in `run --json`)
divided by its `cells`, to 6 decimals. On the Framework: 30 of 30 matched.

    & $J jobs scene 1 <RUN> --save "A2\<RUN>.json"
    & $J run "A2\<RUN>.json" --gens <GENS> --json     # population and cells are in the output

(Write a short PowerShell loop over both JSON files; save it as `A2-check.ps1` with the results.)
Then the same five scenes on the GPU world path, against the CPU:

    & $J run "A2\<RUN>.json" --gens <GENS> --json          # CPU: note "hash"
    & $J run "A2\<RUN>.json" --gens <GENS> --json --gpu    # GPU: the same "hash"?

Checks:
1. Do all 30 match, run by run? List any that don't, with both numbers.
2. Do the five `--gpu` hashes equal the CPU's?
3. **Optional, if Rust is installed** (`cargo --version` works; don't install it without asking
   Jimmie): clone the branch and run the GPU tests:

       git clone --branch release-0.4.2 --depth 1 https://github.com/jprodgers/jetcarp.git "$T\src"
       Set-Location "$T\src"; cargo test --release -p jetcarp-gpu 2>&1 | Tee-Object "$T\A2-gpu-tests.txt"; Set-Location $T

   Do all GPU tests pass? Save the output.

### A3. CPU-only explore confirms (#3) (15 min)

    & $J search explore --families jaca --minutes 10 --label cpu-jaca

Leave it running in this window. In a second window (set `$T`, `$J` and the three variables again),
after about 5 minutes:

    $t0 = Get-Date; & $J jobs stop 2; & $J jobs wait 2 --timeout 60; "exit $LASTEXITCODE"; (Get-Date) - $t0

Then resume it for the rest of its budget, and read it:

    & $J jobs resume 2 --minutes 4
    & $J jobs status 2 > A3-status.txt

Checks:
1. Does the status show *confirmation runs* above 0 and *N confirmed* above 0? (0.4.1 always showed 0.)
2. How many seconds from `jobs stop` until `jobs wait` returned, and what exit code (3 = paused)?
3. Did it resume without errors? **Known on rc.1 (#16):** `jobs wait` returns as soon as the stop is
   asked, before the run lets go, so the resume straight after may be refused with "already being
   run". If so, record it, wait 10 seconds, and resume again. It's fixed on the branch for rc.2.

### A4. The smart JACA search (10 min)

    & $J search explore --gpu --families jaca --parents-from 2 --reviewed keep,maybe --minutes 6 --label smart-jaca
    & $J jobs runs 3 --limit 0 --format csv --out A4-runs.csv

Job 2 has no reviews, so `--parents-from` falls back to its best runs. That fallback is the one
path the agent couldn't test, so watch for errors.

Checks:
1. Did it start without an error, and say it took parents from job 2?
2. Count the runs by `origin` in `A4-runs.csv` (a PowerShell `Group-Object`). Are there `random`,
   `mutate`, `transplant`, `transplant-scaled`, `balance`, `seed` and `cover`, with `random` the
   largest, about 30%?
3. In `A4-runs.csv`, are the `sign_*` columns filled for JACA runs?

### A5. The rating page in Edge (20 min, mostly Jimmie)

    & $J jobs clips 3 --sample 48 --px 180 --page --out A5-clips
    Start-Process msedge "$T\A5-clips\index.html"

Jimmie rates on the page. The steps:
1. Click a clip to make it current, then use the keys: → and ← move; K, M and D rate keep, maybe
   and drop, and move on; S stars. Rate at least **30 clips**, with at least 8 keeps and 8 drops,
   and star 3.
2. Reload the page (F5).
3. Type a name (Jimmie Rodgers) and a note, then press **Save ratings**.
4. Switch Windows to light mode, then dark (Settings → Personalisation → Colours), and look at the
   page in each.

Checks (Jimmie):
1. Did the keys work, and did rating move on to the next clip?
2. Were the ratings still there after the reload?
3. Did Save download a file? Note its name and where Edge put it.
4. Does the page look right in both light and dark?
5. Anything clumsy about it? Jimmie rated 227 clips on the claude.ai version; this is its offline
   twin.

Then read the ratings back:

    & $J jobs review 3 --from "<the downloaded file>" --rater "Jimmie Rodgers" > A5-review.txt
    & $J jobs runs 3 --reviewed any --limit 100 > A5-reviewed.txt

Checks:
6. Does `review` count the verdicts you gave (keeps, maybes and drops) and print the note?
7. Running the same `review` a second time: does it say they're already recorded, and add nothing?

Save the downloaded ratings file, `A5-review.txt` and a screenshot of the page to results (crop out
anything private).

### A6. Refit, score and export (10 min)

    & $J jobs refit 3 --family jaca --rater "Jimmie Rodgers" --out A6-model.json > A6-refit.txt
    & $J jobs rescore 3 --score A6-model.json > A6-rescore.txt
    & $J search explore --gpu --families jaca --score A6-model.json --minutes 3 --label scored
    & $J jobs runs 4 --measures all --format csv --limit 0 --out A6-all.csv
    & $J jobs runs 4 --measures all --format json --limit 5 > A6-five.json

Checks:
1. Does refit report a held-out AUC and the strongest terms, and write the model? Copy the AUC.
   (With ~30 ratings the AUC is noisy; that's fine.)
2. Did the rescore and the scored search run without errors? Does job 4's status say it uses a
   score model?
3. Does `A6-all.csv` open in Excel? Does it have the `sign_*` columns, and as many rows as job 4 has
   runs?

### A7. Jobs wait and memory caps (10 min)

    & $J search hunt --soups 3000 --detach --label wait-done
    & $J jobs wait 5; "exit $LASTEXITCODE"          # expect 0 (done)

    & $J search hunt --soups 2000000 --max-rss-gb 0.05 --label capped
    & $J jobs status 6                              # paused, with a memory note?
    & $J jobs wait 6 --timeout 5; "exit $LASTEXITCODE"   # expect 3 (paused)

    & $J search hunt --soups 2000000 --detach --label to-kill
    Start-Sleep 10
    Get-Process jetcarp | Format-Table Id, StartTime, Path   # pick the detached hunt's process
    Stop-Process -Id <ID> -Force
    & $J jobs wait 7 --timeout 120; "exit $LASTEXITCODE"  # expect 6 (gone) within about a minute

    & $J jobs wait 7 --timeout 2; "exit $LASTEXITCODE"    # still 6, at once

    $env:JETCARP_GPU = "off"; & $J search hunt --gpu --soups 500 --label no-gpu; "exit $LASTEXITCODE"
    Remove-Item Env:JETCARP_GPU          # #10: it should run on the CPU with one note, exit 0

Checks:
1. Exit codes 0, 3 and 6 where expected? Note what each run printed.
2. How long did the killed hunt take to show as gone? (It needs the heartbeat to go stale, about
   45 s.) This tests Windows file locks.
3. Can job 7 be resumed afterwards (`jobs resume 7 --minutes 1`)?
4. With the GPU off, did the hunt asked for `--gpu` run on the CPU with a note, instead of failing (#10)?

### A8. Rules, names and progress (5 min)

    & $J search try --tiling square --rule "B47/S13568V/4"
    & $J search try --tiling square --rule "B3/S23V/C4"
    & $J search try --tiling square --rule "B4v7/S2"
    Set-Content A8-rules.txt "B3/S23`nB36/S23`nB4x/S2`nB2/S"
    & $J search hunt --rules "" --rules-file A8-rules.txt --soups 20
    & $J search hunt --rules B3/S23,B36/S23,B2/S34 --tilings square,hex --soups 30 --label groups

Checks:
1. Do the first two run (as edge-neighbour Generations rules)?
2. What does the third's error say? It should say where a `V` goes.
3. Is the hunt with the bad rules file refused **before any soup runs**, naming line 3?
4. The last hunt's progress line: does it read "… soups in each of 6 groups"?

### A9. `library soup` and the scripts (10 min)

    & $J library list --class spaceship --limit 5      # from the hunts above (job "groups" or wait-done)
    & $J library soup <a spaceship's id> --save A9-soup.json
    & $J objects A9-soup.json --gens 400 --list > A9-objects.txt
    & $J library soup <the same id> --best 3 --save A9-best.json
    & $J script --example jaca-territories > A9-jaca-territories.txt

Checks:
1. Does the rebuilt soup, run for a few hundred generations, produce that spaceship? Look for its
   id prefix or label in `A9-objects.txt`.
2. Did `--best 3` write three scenes?
3. Did the JACA example script run, and does its output make sense (sign shares and a territory
   measure)?

### A10. Packs with schema-2 runs (10 min)

    $S = (& $J jobs status 3 --json | ConvertFrom-Json).folder    # job 3's search folder; its uuid is the folder name
    & $J pack key --name "RC tester (Acer)"      # a throwaway key in the test settings folder
    & $J pack export --to A10-pack --feed rc-acer --title "rc test, Acer" --search <uuid> --no-media
    & $J pack check A10-pack > A10-check.txt
    New-Item -ItemType Directory -Force "$T\import" | Out-Null
    & $J pack import A10-pack --library "$T\import\library.sqlite" > A10-import.txt
    & $J jobs list --library "$T\import\library.sqlite"
    & $J jobs runs --library "$T\import\library.sqlite" --measures sign_balance,sign_sorted --limit 5

Checks:
1. Did export, check and import pass?
2. Does the imported library have the search as a paused explore job, with `sign_*` measures?
3. Zip `A10-pack` and commit it to `results/v0.4.2-rc.1/acer/` if it's under 20 MB. The Mac and the
   Framework import it, as a cross-platform check.

### A11. The app and JACA's colours (15 min, Jimmie)

Start the app from the same PowerShell window, so it uses the test folders:

    & "$T\bin\jetcarpw.exe"

1. Quick Start → JACA. Open *JACA bead borders (square, blast 1)* and *JACA war on the hat tiling*,
   and two other JACA presets, and let each run a minute.
2. Open a world with rule `B3/S23V` (Edit or Draw → add an automaton) and read its card.
3. *Run → GPU simulation*: is it a choice of Automatic, On and Off, set to Automatic? Open a big
   world (Life on a 2048 × 2048 square grid) and run it at full speed: does the status bar say it
   runs on the GPU, and how fast (generations a second)? Set Off and compare, then set Automatic
   again.
4. Open a JACA preset at full speed with the GPU on: do the glow of destroyed cells and the card's
   counts (each sign, contacts, destroyed, cancelled births) look as they do with the GPU off?
5. *View* menu: is there a **Desktop background** pane beside Screensaver? Open both, and say whether
   the split makes sense (D1 tests the pane in depth).
6. *Tools → AI control…*: does the window open? Close it.

Checks (Jimmie):
1. Is the second sign coral or red (Koi), and can you still tell the two signs apart where the
   territories have gone still?
2. Does the `B3/S23V` card read `B3/S23V`, not `B3/S23`?
3. Does the big world run on the GPU by default, much faster than with Off?
4. JACA on the GPU: the same glow and counts?
5. Anything that looks wrong or worse than 0.4.1?

Screenshot one JACA preset for results.

### D. The desktop background on the candidate (40 min, Jimmie)

This runs the candidate's background host on the real desktop, so the everyday one has to stop for a
while. **Ask Jimmie first**, and put the everyday host back at the end (D5).

**D1. Stop the everyday host.** In a fresh window (no `$env` overrides), with Scoop's copy:
`jetcarp host status` (note what it shows), then `jetcarp host stop`.

**D2. The candidate's host as wallpaper.** Back in the test window:

    & $J host start
    & $J host wallpaper on
    & $J host status > D2-status.txt

Checks:
1. Does a live scene show as the desktop background, under the icons?
2. Does `host status` name the GPU it uses, and is it the **display** adapter from doctor? In Task
   Manager → Performance (or the Details tab with a GPU engine column), which GPU is busy?
3. Is it smooth? Jimmie's eye.

**D3. The Desktop background pane, the sweep and the cards.** Start the app from the test window
(`& "$T\bin\jetcarpw.exe"`), and open *View → Desktop background*.
1. Does the pane hold the screens, the wallpaper rotation, the lock screen, the still picture, the
   frame rate, the GPU setting, start at login and the Performance group? Is anything missing that
   used to be in the Screensaver pane, or still duplicated there?
2. **Fit to this computer…** with the default limits (10% CPU, 25% GPU). Watch the desktop: each
   wallpaper scene should step through cell sizes, about 2 seconds each, from coarse down towards
   1 physical pixel, stopping early where a size is far over a limit. Note how long the whole
   sweep took.
3. **The cards.** Each scene gets a row of cards: a crop of the real frame at that size, the cell
   size and number of cells, CPU %, GPU % and frame rate, a within-limits mark, *Recommended* on the
   finest size within the limits, and *its own size* on the scene's designed size.
   - Jimmie: do the crops show the cells as they really look on this screen (at 1 px, single
     pixels)?
   - Which size would you pick for Life on squares, and for an aperiodic scene (hat, spectre or
     Penrose)? Does *Recommended* agree with your eye? Pick your own choice for two scenes, and use
     *Use the recommended size for the rest*.
   - Do the scenes then show at the sizes chosen, and smoothly?
4. **Strict limits** (CPU 1%, GPU 3%): run *Fit to this computer…* again. Do the recommendations
   get coarser? Are the scenes you picked yourself kept if they still fit, and replaced with a note
   if they don't?
5. **Compare with Task Manager:** with a 1 px scene showing, roughly what GPU % and CPU % does the
   host process show? Is that near what its card said? The host times the GPU differently on
   Windows than on Linux (from submission to completion), so a large difference is a result.
6. **The GPU overrides.** The pane's *GPU simulation* offers *Follow the shared setting*, *On* or
   *Off*. Set the Desktop background to **Off**, and the app's *Run → GPU simulation* to **On**:
   - does the wallpaper now step on the CPU (Task Manager: the GPU goes quiet, the CPU busier) while
     a big world in the app still runs on the GPU?
   - `& $J doctor`: does it show the app's and the host's choices separately, and where each came
     from?
   - Set both back to *Follow the shared setting*.
7. **Monitors (if the external monitor is to hand):** plug it in or unplug it. After about 15
   seconds, does the host measure again by itself? Do your own picks survive where they fit?

**D4. The same from the command line:**

    & $J host tune --cpu-limit 2 --gpu-limit 5 --fps 30 --json --crops D4-crops > D4-tune.json
    & $J host scene --save D4-scene.json      # the scene as shown now, with its tuned size
    & $J run D4-scene.json --gens 300 --json --cpu
    & $J run D4-scene.json --gens 300 --json --gpu

Checks:
1. Did tune finish? Does its JSON list every size's numbers per scene, the recommended size, and
   the GPU timing method? Does `D4-crops` hold one PNG per card?
2. Do the two `run` hashes match (the tuned wallpaper is still reproducible)?

**D5. Put the everyday host back.** `& $J host stop`; then, in a fresh window, `jetcarp host start`
with Scoop's copy, and `jetcarp host status`. Is it back as in D1 (same rotation, wallpaper on)?

### A12. Opening a copy of the everyday library (10 min)

Upgrading opens a 0.4.1 library with 0.4.2. Test that on a **copy**:
1. Find the everyday data folder: run Scoop's copy, `jetcarp paths` (no `$env` overrides; use a
   fresh window). Note the folder.
2. Copy that whole folder to `$T\data-copy`. Don't move it.
3. Back in the test window:

       & $J library info --library "$T\data-copy\library.sqlite"
       & $J jobs list --library "$T\data-copy\library.sqlite"
       & $J library quickstart --library "$T\data-copy\library.sqlite" > A12-qs.txt

Checks:
1. Do these work, with the same counts Scoop's 0.4.1 shows for the original?
2. Afterwards, does Scoop's 0.4.1 still open the **original** without complaint
   (`jetcarp library info`)?

### A13. Clean up

1. Commit and push all results.
2. Close the app and any `jetcarp` processes from `$T\bin` (Task Manager).
3. Leave `$T` in place until the main session says the wave is done. It holds the test pack and the
   libraries. Delete it after that.
4. Confirm `where.exe jetcarp` is still Scoop's, and that nothing changed in the login items or the
   screen saver.

### Acer results

| Step | Result | Notes |
|---|---|---|
| A0 Unpack and check | pass | zip sha256 f2d13c6e… matches SHA256SUMS; `--version` 0.4.2-rc.1; paths all under `$T`; doctor: display Intel UHD (Vulkan, "the adapter driving the screen"), compute RTX 3050 (Vulkan, "the fastest adapter"), both self-tests passed (1165 / 706 ms, 53 world rules + 33 batches); `where.exe jetcarp` still Scoop's 0.4.1. Finding: both self-tests say "kept from before" (`cached: true`) on a fresh folder, though nothing is saved and the time changes each run (see notes, G1) |
| G1 Self-test per adapter (RTX Vulkan, RTX DX12, UHD) | pass | all passed (53 world rules + 33 batches): RTX Vulkan 607 ms, RTX DX12 2733 ms, UHD Vulkan 391 ms; doctor also tests UHD DX12 (2948 ms) and UHD GL (624 ms), passed; `auto` as in A0. Findings: the result is saved (`config\gpu-checks.json`) only if the settings folder already exists, so on a fresh folder every start re-tests (doctor 8–14 s) yet says "kept from before"; with the folder, the 2nd run is a real cache hit (1.3 s, same 215 ms). With `off` the header says off but each adapter still says "the GPU simulation uses it" and is self-tested |
| G2 Parity suite per adapter | parity pass; **GPU tests fail on the UHD** | **The optional GPU tests (branch 472bec5) fail on the Intel UHD**: `sandpile_edges_drops_and_patches` and `sandpile_repeats_and_scripts`, hash at generation 1 (`60047217…` CPU vs `02429848…` GPU); RTX: all 55 pass. **Reproduced with the rc.1 binary: any sandpile with `drop_per_gen` > 0 is wrong on the UHD from generation 1, on Vulkan (centre cell saturates: population ~2^32) and DX12 (grains vanish: population 3)**; right on the RTX; the UHD self-test passes, and no parity scene has a drop (notes, `G2-drops.csv`). Parity: **0 mismatches**: RTX Vulkan, RTX DX12 and UHD each "CPU matches 364, GPU matches 364"; 327 all on the GPU, 1 partly (`script-five`), 36 CPU-only, scene by scene as on the Framework. Medians (all-GPU scenes, incl. program start) cpu_s / gpu_s: RTX Vulkan 0.203 / 0.986, RTX DX12 0.196 / 2.438, UHD 0.196 / 0.623 s (GPU device start-up dominates). `parity.ps1` ran unchanged. Finding: in the DX12 pass one scene (n=342 `tiling:ih41`) ran on the **UHD** despite `JETCARP_GPU=RTX` (hash still right); not reproduced in 15 reruns |
| G2b #20 fix on the UHD (branch c74c357) | pass | GPU tests all pass on UHD Vulkan and UHD DX12 (incl. both sandpile-drop tests); the build's doctor: self-test re-ran, "59 world rules and 33 explore batches", passed; parity drops 364–370: 7/7 on Vulkan and DX12; all 371 on UHD Vulkan match (334 all on the GPU); rc.1 on the drop scenes: 1/7 |
| A1 GPU explore | pass | without `--gpu` the search and status name the RTX 3050 (Vulkan); **290 confirmed** (1,104 confirmation runs); 32,606 runs in 9 min 59 s = 54 runs/s average (the per-interval rate shows "0/s" on 71 of 99 lines, else 39–140/s); 6 CPU + 4 GPU threads, 2 cores free; Jimmie: usable, no lag; no errors or GPU warnings |
| A2 GPU = CPU replays | pass | **30/30** runs' `measures.density` = CPU replay's population/cells to 6 decimals (max diff 3e-8); the five `--gpu` hashes (RTX) = CPU; optional GPU tests in auto (RTX): all 55 pass. Small: `jobs runs` says `cells` 16000 for every run, but the worlds have 15,510–16,048 (one Penrose run 35,000); with no flag `run` picks the CPU for these JACA scenes and the GPU for Life-like |
| A3 CPU-only confirms (#3) | pass | run with `--cpu` added (explore's default is automatic and would use the GPU); status: **39 confirmation runs, 8 confirmed**, 825 runs (~1.5 runs/s, "cpu only", 10 threads); stop → `jobs wait` exit **3 in 0.47 s**, but the process exited 1.44 s after the stop (#16 visible); the resume straight after was accepted (exit 0) and ran its 4 min. Small: the resume's last progress line says 5 confirmed, its summary and status 8 |
| A4 Smart JACA search | pass | no error; on the RTX, 14,273 runs (40/s), 133 confirmed; `spec.parents` = **500 parents from job 2, all `why: best`** (the no-reviews fallback), **but the output never says it took parents from job 2**; origins random 29.1%, mutate 17.2%, balance 13.7%, transplant 12.7%, scaled 9.6%, cover 9.3%, seed 8.3%; `sign_*` filled on all runs, **but only with `--measures`** (the plan's CSV command has none). Small: `parent` column empty for every run (A1 too) |
| A5 Rating page (Edge) | pass | **`jobs clips 3 --sample 48` made only 13 clips** (96 and 400 too: the stratified sample caps at 13 on a JACA-only job), so the page was made from 48 random runs with `--ids`. Jimmie rated 24 (8 keep, 8 maybe, 8 drop, 3 ★): keys all worked and moved on; ratings survived F5 ("Your ratings from before are back."); Save downloaded `Downloads\ratings-A5-clips.json`; right in light and dark; nothing clumsy. `review`: 24 reviews + 3 stars and the note; again: 0 recorded, "27 already recorded" |
| A6 Refit, score, export | pass (Excel skipped) | refit on 24 ratings: **held-out AUC 0.410** (fitted 0.672, built-in 0.422; noise with 8+8), strongest terms listed, model written; rescore 14,672 runs (11,597 changed); scored search ran (6,977 runs, no errors) **but its output and `jobs status 4` never mention the score model** (only `--json` `spec.score`); `A6-all.csv`: Excel not installed, strict parse = 6,977 rows = job 4's runs, 41 columns incl. the five `sign_*` |
| A7 Jobs wait, memory caps | pass (no #10 note) | `jobs wait 5` → 0 (done); capped hunt paused at once ("memory 0.2 GB is over the cap of 0.05 GB"), `wait 6 --timeout 5` → 3; detached runner (`jobs resume 7 … --quiet`) killed with `Stop-Process -Force`: `wait 7 --timeout 120` → **6 after 43.0 s**, `--timeout 2` → 6 at once; `jobs resume 7 --minutes 1` worked (11,923 → 99,858 soups). `JETCARP_GPU=off` + `hunt --gpu`: ran on the CPU, exit 0, **but printed no note** |
| A8 Rules, names, progress | pass | `B47/S13568V/4` and `B3/S23V/C4` run as Generations, `neighborhood: edge` (per `--json`); `B4v7/S2`: "a V goes at the end of the rule or right after its B or S counts: B47/S2V"; bad rules file refused before any job ("line 3 of A8-rules.txt: B4x/S2: 'x' is not a neighbour count"); hunt 9: "30/30 soups in each of 6 groups" |
| A9 library soup, scripts | pass | MWSS `77364004…` from hunt 7: the rebuilt soup (soup 4526, settles at gen 8,551) has **no MWSS at 400 gens** (the plan's), but **"MWSS (c/2)" with key `77364004` at 2,000 and 2,500**, then it hits the dead edge; `--best 3` wrote 3 scenes; `script --example jaca-territories` ran: sign shares, balance, sorted 0.01 → 0.99, fronts 4,508 → 122 (makes sense) |
| A10 Packs, schema 2 | fail as planned; pass after `jobs seal` | **The plan's export carried 0 runs**: job 3 (14,672 runs) was never sealed into a Parquet segment (searches seal every million runs or on `jobs seal`), so export/check/import all passed but the imported search had "0 runs, 0 elites", silently. After `jobs seal 3`: export, check, import pass; imported paused explore job with 14,273 runs, `sign_*` filled. **`A10-pack.zip` (sealed, 1.30 MB) committed.** Small: imported job says 80 confirmed vs 133; `.folder` isn't in `jobs status --json` (used `spec.uuid`) |
| A11 App, JACA colours, GPU menu | pass | presets ran; `B3/S23V` card reads `B3/S23V`; GPU menu Automatic/On/Off on Automatic; 2048² Life: status bar "simulation: GPU" on Automatic, CPU on Off, both >300 fps (no visible speed difference); JACA glow and counts the same on GPU and CPU; Desktop background pane beside Screensaver "fine"; AI control opens, closes, pops out and back; nothing wrong. Koi: Jimmie didn't notice; my renders of bead borders and hat war: second sign cream→peach→orange, clearly apart from the teal first sign |
| D Desktop background, Fit to this computer | **fail (Fit)**; rest pass | D1: no everyday host running (nothing to stop). D2: live wallpaper under the icons, smooth, on the UHD (display adapter; Windows counters: host 15–19% UHD, 3.5% CPU). **D3: Fit never sweeps on Windows: the tuner's GPU timing ("submission") reads ~90% where Windows measures ~10%, so every scene stops at its first size and is left at 16 px** (same from `host tune` with the app closed); `--pick own`/`--pick 3` can't undo it; a new rotation made in the app isn't saved; blinkers alias (30 fps, 60 gens/s). D3.6 overrides work: Desktop background Off → wallpaper on the CPU (8.0% vs 1.6% CPU), app On → GPU; doctor shows both and their sources. D4: tune JSON has per-size numbers, recommended size, timing method, one crop per card; the tuned scene's CPU and GPU hashes match. D5: host stopped, wallpaper exactly as before (Jimmie: normal wallpaper back). D3.7 skipped (no external monitor) |
| A12 Everyday library copy | pass | `%LOCALAPPDATA%\jetcarp` (40.5 MB) copied to `$T\data-copy`; the candidate's `library info`, `jobs list` and `library quickstart` on the copy give exactly 0.4.1's counts (schema 3; patterns 98, sightings 141, jobs 33, Quick Start 2619 / 2,255 entries; job list line for line); the copy grew 90 KB (migration), the original was untouched; afterwards 0.4.1 opens the original as before (and reads the copy too) |
| A13 Clean up | done | app closed, no `jetcarp` processes; `$T` kept until the wave is done (3.8 GB, mostly the Rust build); `where.exe jetcarp` still Scoop's 0.4.1; no login entry, no screen saver, wallpaper as before; everyday settings and library untouched |

---

## Mac (macOS 27, M2 Max)

Use Terminal (zsh). Every command assumes:

    export T="$HOME/jetcarp-rc-042"
    export JETCARP_CONFIG_DIR="$T/config" JETCARP_DATA_DIR="$T/data" JETCARP_OUT="$T/out"
    J="$T/bin/jetcarp"
    cd "$T"

### M0. Unpack and check (5 min)

    mkdir -p "$T/bin"
    curl -LO https://github.com/jprodgers/jetcarp/releases/download/v0.4.2-rc.1/jetcarp-0.4.2-rc.1-aarch64-apple-darwin.tar.gz
    curl -LO https://github.com/jprodgers/jetcarp/releases/download/v0.4.2-rc.1/SHA256SUMS
    shasum -a 256 jetcarp-0.4.2-rc.1-aarch64-apple-darwin.tar.gz   # compare with SHA256SUMS
    tar -xzf jetcarp-0.4.2-rc.1-aarch64-apple-darwin.tar.gz -C "$T/bin" --strip-components=1   # adjust if the archive has no top folder
    xattr -l "$J"                       # curl downloads have no quarantine flag; note if one shows
    "$J" --version; "$J" paths; "$J" doctor > results-doctor.txt

Checks:
1. Is the hash right, and does `--version` say `jetcarp 0.4.2-rc.1`?
2. Do the paths all point under `$T`?
3. Which GPU does doctor choose (the M2 Max, Metal)? Copy the lines.
4. Is `which jetcarp` still Homebrew's 0.4.1?
5. Did macOS show any security prompt when the program first ran? If it refused to run, note the
   exact message and ask Jimmie (don't change security settings yourself).

### M1–M10. As on the Acer

Run steps **G1, G2 and A1 to A10** with these changes:
- **Commands:** `"$J"` for `& $J`, `$?` or `echo $?` for `$LASTEXITCODE`, `sleep` for
  `Start-Sleep`, and a small shell or Python loop for A2's comparison (save it as `M2-check.sh`).
- **G1 and G2 on the Mac:** one adapter, the M2 Max (Metal): run doctor with `JETCARP_GPU` unset, then
  `off`; run the parity suite once with `python3 parity/parity.py "$J" "$T/parity" G2-metal.csv`.
  Metal is the backend most likely to disagree (fast-math defaults), so a mismatch here matters most.
- **M1:** the status should name the M2 Max (Metal), without `--gpu`.
- **M2:** the same GPU-vs-CPU replay check, for Metal. For the optional GPU tests, clone and test
  only if `cargo --version` works.
- **M5, the rating page:**
  - **in Safari** (`open -a Safari "$T/M5-clips/index.html"`), then the same steps in Chrome if it's
    installed;
  - **Safari is the one to watch.** It may refuse to keep localStorage for a page opened from a
    file, or save the download differently. Record exactly what happens on reload and on Save, in
    each browser;
  - light and dark: System Settings → Appearance.
- **M7:** kill the detached hunt with `kill -9 <pid>` (find it with `pgrep -fl "jetcarp search hunt"`).
- **M10:** export as feed `rc-mac`, and also import **the Acer's pack** from
  `results/v0.4.2-rc.1/acer/` (after `git pull`): does `pack check` pass, and does `pack import`
  bring in its search with its `sign_*` measures? That checks a pack made on Windows reads on macOS.

### M11. The app and JACA's colours (15 min, Jimmie)

    "$T/bin/jetcarp"     # the app, with the test folders

The same checks as A11: JACA presets with Koi, the `B3/S23V` card, the GPU menu and a big world on
the GPU, JACA's glow and counts on the GPU, the new Desktop background pane, the AI control window.
Also: does the app's window open on the external monitor if it's attached, as before?

### MD. The desktop background on the candidate (40 min, Jimmie)

As D on the Acer, with Homebrew's copy as the everyday one (stop it first, put it back after), and
**Activity Monitor** (Window → GPU History, and the % GPU column in the processes list) for the
cross-check. macOS has one GPU, so the display and compute adapters are both the M2 Max. Note
whether the host's windows sit behind the desktop icons on every Space, as before.

The Mac's Retina screen matters most for the sweep: sizes are physical pixels, so a 1 px card is a
single Retina pixel. Jimmie expects 2–4 px to be the smallest worth having here, and 1 px to be
slow. Do the cards show that, with 1 px marked over the limits? Which would you pick?

### M12. Opening a copy of the everyday library

As A12, with Homebrew's copy and `~/Library/Application Support/jetcarp` (or whatever
`jetcarp paths` names). Copy, don't move.

### M13. Clean up

As A13: commit and push results, quit the app, keep `$T` until the wave is done, and check that
`which jetcarp` is Homebrew's.

### Mac results

| Step | Result | Notes |
|---|---|---|
| M0 Unpack and check | pass | tar.gz sha256 91cfbd3a… matches SHA256SUMS; `--version` 0.4.2-rc.1; paths all under `$T`; doctor: Apple M2 Max, Metal (integrated) for display and compute, self-test passed (588 ms first, then ~145 ms; 53 world rules + 33 batches); `which jetcarp` still Homebrew's 0.4.1; no security prompt (provenance xattr, no quarantine). #17 as on the Acer: "kept from before" on a fresh folder, nothing saved |
| G1 Self-test (Metal) | pass | passed, 143–146 ms (doctor 0.17 s); `off`: header off, but each adapter still "the GPU simulation uses it" and self-tested (#17); `auto` as M0; cache: real only once `$T/config` exists (0.03 s, 172 ms kept), else re-tested every run; cache key has the empty-driver double space (#26) |
| G2 Parity suite (Metal) | pass | **"371 scenes: CPU matches 371, GPU matches 371; all 300 generations on the GPU in 334"** (M2 Max, Metal); 1 partly (`script-five`), 36 CPU-only; `gpu_gens` scene by scene = expected.csv; the whole pass took 71 s. **Drop scenes 364–370 right on Metal with rc.1** (CPU = GPU at gens 1 and 300, same populations): #20 was Intel-only. Medians (all-GPU, incl. program start) cpu_s / gpu_s 0.079 / **0.039**; GPU faster on 304 of 334 (Metal device start ~10 ms, unlike the Acer's 0.5–2.3 s). Optional GPU tests (branch 67fb2f7): **55 passed, 0 failed** on "Apple M2 Max, Metal", incl. both sandpile-drop tests; the ignored heavy test (two 17-million-cell worlds) passes too with `--ignored` |
| G2b Branch build (67fb2f7) on Metal | pass | own fresh folders; doctor: "passed (389 ms): **59 world rules** and 33 explore batches", no "kept from before" at first, cached (0.03 s) after, `off` → "not used, and not tested" (#17 fixed); cache key without the double space (#26); `nosuchgpu` → "no nosuchgpu adapter was found, so the best one" (#21); `WGPU_BACKEND` listed (#26). **Parity 371/371 CPU and GPU, 334 all on the GPU; every GPU hash and split = rc.1's**; drops CPU = GPU at gens 1 and 300 |
| M1 GPU explore (Metal) | | |
| M2 GPU = CPU replays | | |
| M3 CPU-only confirms (#3) | | |
| M4 Smart JACA search | | |
| M5 Rating page (Safari, Chrome) | | |
| M6 Refit, score, export | | |
| M7 Jobs wait, memory caps | | |
| M8 Rules, names, progress | | |
| M9 library soup, scripts | | |
| M10 Packs (and the Acer's pack) | | |
| M11 App, JACA colours, GPU menu | | |
| MD Desktop background, Fit to this computer | | |
| M12 Everyday library copy | | |
| M13 Clean up | | |

---

## Framework (Fedora 45, GNOME 51.1): the main session, with Jimmie for the visual checks

The main session runs these on the Linux candidate (`jetcarp-0.4.2-rc.1-x86_64-unknown-linux-gnu.tar.gz`)
in `~/Documents/jetcarp-dev/work/0.4.2-rc/`, with the same three variables. Jimmie's everyday
copy (`~/.local/bin/jetcarp`, 0.4.1) and library aren't touched, except in F3.

| Step | What | Who |
|---|---|---|
| F0 | CI on the pull request `release-0.4.2` → `main` (not merged): Linux, Windows and macOS all green | main session |
| F1 | Unpack, check the hash, `--version`, `paths`, `doctor` (Radeon 8060S for display and compute; self-test passed) | main session |
| FG | The parity suite with the candidate's own Linux build: `expected.csv` is regenerated from it before the laptops run theirs; also forced onto llvmpipe (`JETCARP_GPU=software`), as CI now does | main session |
| FD | The Desktop background pane and Fit to this computer on a scratch host in a private headless GNOME Shell; the pane in the app | main session; Jimmie (a look at the pane) |
| F2 | A1–A4 on the Radeon: GPU explore with confirmations, GPU = CPU replays, CPU-only confirms with stop and resume, the smart JACA search with `--parents-from` from a **copy** of Jimmie's library (job 2 and his 227 ratings: parents from his keeps and maybes) | main session |
| F3 | The GNOME extension refresh, first in a private headless GNOME Shell (no logout): an installed 0.4.1 extension is rewritten by `jetcarp host status`; `host gnome status` says an older version is running until the shell restarts, then "running"; a switched-off extension stays off; GNOME 51's live desktop still works (#2). On Jimmie's real session it happens once, at the final release: one logout | main session; Jimmie logs out once at the final release |
| F4 | The rating page in Firefox and Chrome: keys, reload, Save, light and dark | main session (headless) and Jimmie (a look) |
| F5 | A5–A6 on Jimmie's real ratings: refit on the library copy (AUC about 0.90, as on the branch), rescore, export | main session |
| F6 | A7–A10: jobs wait (exit codes 0, 3, 6 after `kill -9`), memory caps, rules, names, progress, `library soup`, scripts, pack export, check and import; import the Acer's and the Mac's packs | main session |
| F7 | A11 in the app: JACA presets in Koi, the `B3/S23V` card | Jimmie (a look) |
| F8 | A12 on a copy of Jimmie's everyday library (job 2's 93,243 runs, the Quick Start, the ratings) | main session |

### Framework results

| Step | Result | Notes |
|---|---|---|
| F0 CI | | |
| F1 Unpack and check | pass | rc.1 Linux archive sha256 ef294524… matches SHA256SUMS; `--version` 0.4.2-rc.1; doctor: Radeon 8060S for display and compute, self-test passed (99 ms, 53 world rules + 33 batches); app and host both follow the shared setting |
| FG Parity (Radeon, llvmpipe) | pass | rc.1 build: 364/364 CPU and GPU match on the Radeon (327 all on GPU, 1 partly, 36 CPU-only) and on llvmpipe (`JETCARP_GPU=software`); identical to the dev build's hashes |
| FD Desktop background, tuner | pass (headless); the pane waits for Jimmie's look | Scratch host in the private headless GNOME Shell: `host tune` swept both directions on screen and saved 39 crops (exit 0), with each scene's cards and the recommended size. CI's macOS runner found that a size far over the limits stops the sweep early, as designed, and the test assumed headroom (#23, test fixed). Left: Jimmie's look at the Desktop background pane in the app |
| F2 GPU, replays, #3, smart search | pass, one bug | A1: explore without `--gpu` used the Radeon by default (338 runs/s, 515 confirmed in 5 min). A2: 30/30 GPU-screened runs end with the CPU's density (compare `measures.density`). A3: CPU-only JACA confirms (5 elites, 15 confirmation runs in 3 min; ~3 runs/s on CPU); **#16: `jobs wait` returned before the run let go, so the resume was refused; fixed in 472bec5 (stop→wait 0.6 s→resume works)**. A4: `--parents-from 2` on a library copy: 202 runs/s, 257 confirmed; origins random 29%, mutate 18%, balance 14%, transplant 11% + scaled 9%, cover 9%, seed 9%; sign measures on every run |
| F3 GNOME refresh | pass, two bugs | In a private headless GNOME Shell 51.1 (its own dconf, checked before any write; Jimmie's real settings' mtime unchanged; the first try's harness did write the real dconf, since fixed, and Jimmie restored it): 0.4.1's extension loads as out of date (state 4); a `jetcarp host` command rewrites it to 0.4.2's; after a shell restart it's running (0.4.2-rc.1, state 1); a switched-off one stays off; GNOME 51's live desktop runs (generation 159 → 344). **#18: before the restart, `host gnome status` said "this version of GNOME is not supported" (GNOME's state for the old copy) instead of "log out and back in once"; #19: a switched-off extension (state 6) read "it is starting".** Both fixed on the branch (1dc77ac) and checked in the same shell. Jimmie's one real logout waits for the final release |
| F4 Rating page (Firefox, Chrome) | | |
| F5 Refit on Jimmie's ratings | pass | rc.1: `jobs refit 2 --family jaca --rater "Jimmie Rodgers"` on a library copy: 227 ratings (48/98/81), held-out AUC 0.900 (fitted 0.940; built-in 0.769), as on the branch |
| F6 Wait, caps, rules, soup, packs | pass | `jobs wait`: done 0, memory-capped hunt 3 (note "memory 0.1 GB is over the cap of 0.01 GB"), `kill -9` → 6 after 45 s; `JETCARP_GPU=off` + `hunt --gpu` falls back (#10). Rules: B47/S13568V/4 and B3/S23V/C4 run; B4v7/S2 → "a V goes at the end of the rule or right after its B or S counts: B47/S2V"; a bad rules file refused before starting, naming line 3. Progress "30/30 soups in each of 6 groups". `library soup`: rebuilt soup 16 for a c/4 B2/S34 ship, verified (1 copy, 1 ship); `--best 3` found it in 1 of 30 soups. `script --example jaca-territories` runs. Pack export → check → import: 92 patterns, sample verify 92/92 |
| F7 App, JACA colours | | |
| F8 Everyday library copy | pass | rc.1 opens a reflink copy of Jimmie's library (schema 3): jobs 1–2, Quick Start 1,194, ratings 227; job 2's runs list, old runs show `sign_*` as – (null) |

---

## After the wave

The main session reads every machine's table and `NOTES.md`. It fixes what failed on the branch,
and makes `v0.4.2-rc.2` if anything needed a fix. Otherwise it writes the final release steps:
bump to 0.4.2, merge the branch into `main`, tag `v0.4.2`, and publish (Jimmie's gates). Then the
JACA rerun starts on the released 0.4.2.
