# Release candidate v0.4.2-rc.2: a full pass

> **Not tagged yet.** Start when `NOTES.md` says the release exists. Until then, this is the plan
> for review.

**Why a full pass.** rc.1's wave found 28 bugs (#15–#42, less two enhancements). Several were in
places rc.1's plan barely touched:
- a pack of a real-sized search carried no runs (#35);
- the desktop tuner can't work on Windows (#38);
- nobody could make a rotation (#41);
- the desktop's Life looks wrong (#42).

The only outside report so far (#1) came from a newcomer's first hour, and found two bugs right
away. So rc.2 tests **everything again**, on all three machines and every GPU, and adds what rc.1
left out:
- a newcomer's first hour on each OS;
- the upgrade from 0.4.1;
- long runs and soaks;
- MCP with a real assistant;
- multiple monitors;
- robustness.

Jimmie: "We need to do much more testing … I've got the time, and I'm not in a rush to get this
release out." Nothing here is to be skipped for speed. If a part is too much in one sitting, split
it, and record where it stopped.

**The release:** https://github.com/jprodgers/jetcarp/releases/tag/v0.4.2-rc.2, a public pre-release
from `release-0.4.2`. Its archives are named `jetcarp-0.4.2-rc.2-<target>`. PyPI, crates.io,
Homebrew and Scoop don't get it (the tag has a `-`).

## What changed since rc.1

Every fix has an issue (https://github.com/jprodgers/jetcarp/issues/N).

| # | Fix | Where to see it |
|---|---|---|
| 15 | CI's GPU tests on virtual GPUs; a clear refusal when WARP is the only adapter | CI |
| 16 | `jobs wait` returns only once the run lets go, so `jobs resume` right after works | 2.3 |
| 17 | The self-test on a fresh install: saved (the settings folder is made), "just now" when run now, not run with the GPU off | 2.0, 2.G1 |
| 18, 19 | GNOME: after a refresh, "log out and back in once"; a switched-off extension (state 6) says switched off | 6, 3.2 |
| **20** | **Sandpile drops on Intel's UHD GPU** (the shader's saturating add). The self-test steps dropping piles (59 world rules); parity has 371 scenes (364–370 drops) | 1.1, 2.G1 |
| 21 | A named adapter that isn't found says "no X adapter was found, so the best one" wherever the adapter is named | 2.0 |
| 22 | Explore's runs a second over the last minute (no "0/s" between GPU batches) | 2.1 |
| 23 | The tune test on CI's macOS runner | CI |
| 24 | "… elites in … niches (N of them confirmed)"; that count can fall | 2.1, 2.3 |
| 25 | `--parents-from` says which parents it took | 2.4 |
| 26 | doctor lists `WGPU_*`; no double space in cache keys | 2.0 |
| 27 | The runs reference: `cells` is the size asked for | docs |
| **29** | **`jobs clips --sample N` gives N clips** for a search on few tilings (rc.1 gave 13) | 2.5 |
| 30 | A search scored by a model says so, at start, in status and after a rescore | 2.6 |
| 31 | `JETCARP_GPU=off` over `--gpu` says so | 2.7 |
| 32 | `jobs wait` prints only changed lines | 2.7 |
| 33 | `jobs runs --reviewed` shows verdicts and stars | 2.5 |
| **35** | **A pack of a search that never sealed carried no runs.** Publishing seals a stopped search first and refuses a running one | 2.10, 1.4 |
| 36 | A rescore rewrites the job's confirmed count and line | 2.6 |
| 37 | An imported search says "not run here yet" | 2.10 |
| **38** | **Fit to this computer sweeps on Windows** (GPU timestamps in the host's window; the fallback clock no longer fails a size) | 2.D |
| 39 | `host tune --pick own` / `--pick N` place those sizes even if the sweep never showed them | 2.D |
| 40 | doctor says who simulates where (the app and the desktop on the display adapter; runs, searches and scripts on the compute one) | 2.0 |
| **41** | **Rotations from the Desktop background pane**: show just this scene in one click, New/Edit in the pane, Save at the top | 2.D, 3.1 |
| **42** | **The desktop shows every generation** (draws as fast as the scene steps, up to 60 fps by default, or the monitor's full refresh with `host max-fps refresh`), with a low-power option that caps the speed at the frame rate | 2.D |
| 43 | `host status` and the pane print a patch's cell size rounded (10.8 px) | 2.D |
| 44 | `host tune`: a patch's heading names its level; an own-size pick reports one size and its cells | 2.D |
| 45 | The tuner names a missing Quick Start entry ("…; showing Life") instead of sweeping Life quietly | 2.D |
| 46 | The on-screen sweep test on CI's macOS runner | CI |

Also new since rc.1, beyond fixes:
- **The README** has an animated banner of six scenes and a picture of the app.
- **The book was audited** against every change above: about a dozen pages, re-run examples, and new
  pictures of the Desktop background pane and the rotation editor. In 3.1, compare the pictures with
  what you see.

Left for later (enhancements): #28 (each run's lineage), #34 (`library soup`: when the find first
appears).

## How this wave runs: one person, one monitor

Jimmie reads every chat in full, has one monitor (the Framework's), and tests live on one machine at
a time. So the wave runs in two phases, and every part of it can pause.

**Phase 1: the overnight batch (all three machines at once, unattended).**
1. Before Jimmie leaves for a few hours, he starts each machine's session on part 1.
2. The session writes one script that runs 1.1–1.4 and 1.6 end to end. Each step carries on if the
   one before failed, and everything is logged to files.
3. The session checks that the script has started and says so in one line, then **stays quiet**
   until the script ends.
4. At the end it commits everything and writes a **short summary** as a new `NOTES.md` entry: at
   most 15 lines, each step's pass or fail with one number, and any failure in a sentence. It ends
   its chat with the same summary.

Jimmie reads three short summaries when he's back.

1.5 (the overnight desktop soak) isn't in this batch: the heavy tests would pause the host (its busy
rule) and spoil the soak's numbers. It runs on a machine that's otherwise idle for 8 hours or more:
a later night, or a laptop that waits while Jimmie tests the other.

**Phase 2: live testing, one machine at a time, in sittings.**
- The order is the Acer, then the Mac, then the Framework. Each machine's block is a numbered list of
  sittings (see "The sittings").
- A sitting is about one session of Jimmie's attention, and it **ends at a pause point**:
  - results committed and pushed;
  - the machine's `progress.md` updated;
  - a closing chat message with a summary and the next sitting's name.
- A sitting can also stop early at any step. Record where, and the next one starts there.
- **The two-monitor sitting is the last of each laptop's block.** The external monitor moves from
  the Framework to that laptop, so the Framework's screen, and the main session's chat, are out of
  sight during it. Nothing in that sitting needs the main session, and Jimmie reads the main chat
  afterwards.
- **An idle machine can run unattended steps** during another machine's live block (1.5's soak, a
  long rerun), as long as they need nothing from Jimmie until they finish.

**Pausing and resuming.**
- Every machine keeps `results/v0.4.2-rc.2/<machine>/progress.md`: each step with pass, fail or skip,
  and a **Next:** line naming the next step.
- A session, or a new one after a break with no memory of the last, reads `progress.md`, `NOTES.md`
  and this plan, and carries on from **Next**.
- Nothing runs between sittings unless the last sitting said it would (a soak, say).

**Chats.**
- Jimmie reads every chat in full, though not always at once: his desk is L-shaped, and he turns to
  read between steps.
- The laptop sessions put the details in `notes.md` and keep the chat to what happened and what's
  next.
- The main session keeps its chat up to date the whole time. During a live sitting it carries on
  with its own work (reading pushed results, filing an issue for every finding, fixing on the
  branch), and says what it's doing as it goes.
- Fixes found during the wave go to the branch for rc.3. A machine mid-wave keeps testing rc.2.

**As in rc.1:**
- **Fresh test folders** (`jetcarp-rc-042b`, as below) for parts 1, 2, 4 and 5. Part 3 uses a separate
  OS user account. Results and a `notes.md` go under `results/v0.4.2-rc.2/<machine>/`.
- **Keep the everyday JETCARP and its library untouched.** Nothing is installed in Jimmie's own
  account. The candidate runs from its unpacked folder by full path, with JETCARP's folders pointed
  at the test folder. Only part 3 installs anything, in its own account.
- **Every bug is recorded in full** in `notes.md`: steps, what was expected, what happened, files. A
  confusing moment counts as a bug: #41 was one.
- **Sizes:** S is under an hour, M is about a session, L is several sessions or overnight.

Set-up lines, as in rc.1 with the new folder:

    # Acer (PowerShell)
    $T = "$env:USERPROFILE\jetcarp-rc-042b"
    $env:JETCARP_CONFIG_DIR = "$T\config"; $env:JETCARP_DATA_DIR = "$T\data"; $env:JETCARP_OUT = "$T\out"
    $J = "$T\bin\jetcarp.exe"; Set-Location $T

    # Mac (zsh)
    export T="$HOME/jetcarp-rc-042b"
    export JETCARP_CONFIG_DIR="$T/config" JETCARP_DATA_DIR="$T/data" JETCARP_OUT="$T/out"
    J="$T/bin/jetcarp"; cd "$T"

---

## Part 1. Unattended, on every machine (start first)

### 1.1 Parity on every GPU (M, unattended)

As rc.1's G2, with all 371 scenes:
- **Acer:** RTX Vulkan, RTX DX12, UHD Vulkan, **UHD DX12**.
- **Mac:** Metal.
- **Framework:** Radeon and llvmpipe.

Expect "371 scenes: CPU matches 371, GPU matches 371; all 300 generations on the GPU in 334" on
each.

### 1.2 Long-run parity (M, unattended)

`parity/long/` (the main session adds it with the tag) holds 40 scenes chosen across every family
and tiling kind, with the Framework's CPU hashes after **5,000 generations**, so slow drift shows.
Run `parity.py … --gens 5000` (or `parity.ps1 … -Gens 5000`) on it. Use each adapter, as in
1.1. Expect every hash to match.

### 1.3 The whole test suite on real GPUs (M, unattended; Rust is installed on both laptops)

CI only ever sees software adapters. Clone the tag (`git clone --depth 1 -b v0.4.2-rc.2 …`), then run
`cargo test --release --workspace --no-fail-fast` in a scratch environment (the tests make their own
folders):
- **Acer:** with `JETCARP_GPU=RTX`, then again with `JETCARP_GPU=UHD`.
- **Mac:** once (Metal).

Expect 0 failures. Record the counts and anything ignored.

### 1.4 A long search with a crash in the middle (L, unattended)

1. A 2-hour GPU explore of every family: `search explore --minutes 120 --label long`.
2. At about an hour, kill it hard: `Stop-Process -Force` on the Acer, `kill -9` on the Mac. The
   batch script does this, and the resume below, with no one at the machine.
3. `jobs status` must say the job is stalled and resumable. `jobs resume` it to the end.
4. Then, with no `jobs seal`, a pack export and import into a fresh library. The import must have
   every run (#35).

Record:
- the runs per second (the progress line's rate should rarely say 0/s: #22);
- memory at the end;
- the pack's size;
- the run counts on both sides.

### 1.5 The desktop overnight (L, unattended, on an idle machine; Jimmie starts it)

Not part of the overnight batch (see "How this wave runs"). Run it when the machine has 8 hours
or more to itself.

The candidate's host as the desktop background, on the default rotation, overnight (8 hours or
more). A small script logs every 5 minutes:
- `host status --json` (generation, scene, memory);
- the host's CPU %;
- its GPU share (Windows' per-process GPU counters as in D3; macOS `powermetrics` if allowed, or
  Activity Monitor's GPU column by hand in the morning).

In the morning:
- Is the rotation still advancing?
- Has memory stayed flat (no steady growth)?
- Were there no errors, and is the desktop still live?
- Does it still look right (Jimmie)?

Stop the host and check the wallpaper is restored.

### 1.6 Hunts give the same finds everywhere (S, unattended)

Hunts are deterministic. On each machine run:

    search hunt --rules B3/S23,B36/S23,B2/S34 --tilings square,hex --soups 20000 --seed 4242 --label det --json
    jobs status <job> --json

Commit the status JSON. Once all three are in, the main session compares them: every machine's finds
must be identical.

---

## Part 2. Every feature again (hands-on with the session; Jimmie for the looks)

Run **every** row of rc.1's plan again on rc.2, with rc.2's checks:
- the Acer's A0–A13 and D;
- the Mac's M0–M13 and MD.

Nothing stands from rc.1. The checks below add to rc.1's.

### 2.0 Unpack and check (as A0/M0)

1. Is the hash right, and does `--version` say `jetcarp 0.4.2-rc.2`?
2. **#17:** on the first run, does each self-test say "passed (… ms)" without "kept from before", is
   `gpu-checks.json` written, and does a second `doctor` say "kept from before" and take a second
   or two?
3. **#21:** with `JETCARP_GPU=nosuchgpu`, does `run --gpu --gens 300 --json parity/scenes/0.json`
   give a `backend` ending "no nosuchgpu adapter was found, so the best one"?
4. **#26:** with `WGPU_BACKEND` set, does doctor's Environment block list it?
5. **#40:** do doctor's display and compute lines say who simulates on each?

### 2.G1 Each GPU's self-test (as G1)

Expect "59 world rules and 33 explore batches" on every adapter. With `JETCARP_GPU=off`, each
adapter says "not used, and not tested: the GPU simulation is off".

### 2.1–2.12 As A1–A12 / M1–M12, adding:

- **2.1 (A1):** most progress lines give a rate above 0/s (#22), and the line says "(N of them
  confirmed)" (#24).
- **2.3 (A3):** after `jobs stop` and `jobs wait`, `jobs resume` is accepted at once (#16).
- **2.4 (A4):** "parents: 500 JACA runs of explore job 2 (its best ones: it has no reviews …)" at
  start and in `jobs status` (#25).
- **2.5 (A5):** `jobs clips 3 --sample 48 …` writes 48 clips (#29); after the ratings, `jobs runs 3
  --reviewed any` shows `[keep]`, `[maybe]`, `[drop]` and the stars (#33).
- **2.6 (A6):** the scored search prints "score: the score model '…'" and `jobs status` shows it;
  after `jobs rescore 3 --score …`, `jobs status 3` shows the model and its confirmed count (#30,
  #36).
- **2.7 (A7):** with `JETCARP_GPU=off`, `hunt --gpu` prints "the GPU was asked for, but
  JETCARP_GPU=off: running on the processor" (#31); `jobs wait` prints only changed lines (#32).
- **2.10 (A10):**
  - without `jobs seal`, the export says "sealed its newest N runs first …" and the import has
    every run (#35);
  - the imported line ends "not run here yet" (#37);
  - an export that takes a running search is refused ("stop it first");
  - commit `A10-pack.zip` (or `M10-pack.zip`): each machine imports the other two's.

### 2.D The desktop background in depth (M–L, Jimmie)

On each OS (the Framework's part is in part 6), as rc.1's D/MD, then:

1. **Show just this scene (#41).** Open a scene in the app, then click the Desktop background pane's
   button to show it alone. Does the desktop switch to it, is a rotation saved (its file in
   `config/rotations/`), and does the screensaver's choice stay as it was?
2. **Make a rotation in the pane (#41).** Click New beside a screen's chooser. Can Jimmie find Save
   without help? Add two items (a profile and a Quick Start entry), save, and check the screen shows
   it. Then Edit it and change the order.
3. **Every generation (#42).**
   - Show Life (a blinker field, e.g. "Until it settles"): do the blinkers blink at an even pace
     (Jimmie)?
   - Does `host status` give the screen's frame rate as the scene's speed (60)?
   - A faster scene (Langton's ant, 240 a second) draws at 60 fps by default, even on the Acer's
     144 Hz panel.
   - `host max-fps refresh` (or the pane's *Up to* choice) lets it draw at the panel's 144. Note the
     GPU share at each, then set it back to 60.
   - Switch on low power: is Life now as many generations a second as the frame rate, and is the GPU
     share lower?
4. **Fit to this computer (#38).** From the pane, then `host tune --json`:
   - Does the sweep show several sizes per scene, coarse to fine and on to the finest within limits?
   - Does each result say `"gpu_timing": "timestamps"` (Windows; macOS may say timestamps or
     submission)?
   - Do its GPU shares roughly match the OS's own per-process numbers?
   - Are the cards right for each scene?
   - Is "Recommended" the finest within the limits?
5. **Picks (#39).** `host tune --pick own` puts every scene back at its own size; `--pick 3` gives
   3 px; the pane's "Use the scenes' own sizes" does the same.
6. **The GPU overrides.** Desktop background Off, then On, then Follow, against the shared setting.
   `host status` and doctor must agree.
7. **Pauses:**
   - a full-screen video in a browser pauses the host, and it resumes after;
   - on battery the host pauses (unplug the laptop; `host battery` on), then resumes when plugged
     in;
   - a CPU search above the busy threshold pauses it (`host busy`).
8. **Sleep and wake.** Sleep the laptop with the host running, then wake it: is the desktop live
   again, with no error, a still or a black screen?
9. **The lock screen.** Lock, then unlock: what does the lock screen show, and is the desktop right
   after?
10. **Start at login.** `host login on`, log out and back in: does the host start with the saved
    rotation? Then `host login off`.
11. **The screen saver (Windows, macOS).** Install it, wait for it (set the shortest delay), and
    check it shows the rotation. Uninstall it.
12. **A host crash.** Kill the host process hard. Is the user's own wallpaper back, or a still if
    `host still` is on? Does `host start` bring the live desktop back?

### 2.MM Two monitors (M, Jimmie; the laptops with the external monitor)

The external monitor moves from the Framework to each laptop in turn.
1. Two screens with different rotations, one per monitor. Each shows its own, at the right size and
   scale (the Mac's Retina panel next to a 1× monitor).
2. Fit with two monitors: does each screen get its own sizes?
3. **Unplug the external monitor while the host runs**, then plug it back in. No crash; the screens
   go back to their monitors.
4. Change the external monitor's resolution or scaling while it runs.

### 2.APP The app, everything once (M, Jimmie with the session)

The session builds a checklist from the app's menus and panes, so nothing is missed. Then:
1. Open **every menu item and every pane** once. Pop each window and pane out (↗) and back in. #1's
   crash was a pop-out.
2. **AI control** (#1's lockout):
   - switch it on, pop its window out and back, quit the app;
   - restart with no world open: can the AI control window be opened, and does it serve on its port?
3. Every keyboard shortcut in the help.
4. Light and dark; resizing the window very small and very large; a second monitor (2.MM).
5. Quick Start: open entries from each category; edit a world; change rules, palettes and
   reseeding; save a scene; reopen it; check `verify` passes on it.
6. Export a PNG, a GIF and a WebP from the app; check they open.
7. Scripting pane: run each built-in example (`script --examples` lists them).
8. Leave the app running a large JACA world for an hour: no slowdown, no memory growth.

---

## Part 3. A newcomer's first hour, and the upgrade (each OS, a separate OS user account)

These need an account with nothing of Jimmie's in it:
- a new local user on Windows;
- a new standard user on macOS;
- a new user on Fedora.

Jimmie makes the account and logs in. The session works there, and its results still go to
`jetcarp-rc`. **Record every moment of confusion** with what was tried, even when it ends well.

### 3.1 First hour (M, Jimmie)

1. Starting from the GitHub release page, a newcomer downloads rc.2's archive for this OS and
   follows the book's **Getting started** literally: every command as written, every screenshot
   compared. Where the book and the program disagree, record it.
2. **The setup wizard:** the app's first-run window, and `jetcarp setup`. Choose *Desktop art*, and
   follow it through to a live desktop background. Then `jetcarp setup --status`.
3. A first Quick Start world, a first search (a short hunt), a first find saved and seen in the
   library.
4. **MCP with an assistant:** register `jetcarp mcp` with Claude Code (or Claude Desktop) in this
   account as the book says (Jimmie logs in there), and ask it for a few things:
   - make a world;
   - run a search;
   - render a picture.

   Do the files land where they should? Then the app's AI control from the assistant (`use_app`).
5. `jetcarp uninstall` (the plan, then `--yes`): does it undo the login entry, extension or screen
   saver, and wallpaper, and offer to delete the settings and data? Afterwards, is there nothing of
   JETCARP left outside the folders it named?

### 3.2 The upgrade from 0.4.1 (M, Jimmie)

In the same account (or a second one):
1. Install **0.4.1 the everyday way** (Scoop, Homebrew, or the Linux installer).
2. Use it for a while:
   - set it up with a profile;
   - run a hunt with finds;
   - rate a few runs;
   - turn the desktop background on with login.
3. Upgrade to rc.2 by putting rc.2's programs in place of 0.4.1's (the package managers skip rc
   tags). Then check:
   - the library opens with the same counts;
   - settings are kept;
   - the host comes back at the next login, as rc.2;
   - on GNOME, the extension is refreshed and asks for one logout (#18);
   - nothing was lost.
4. `jetcarp uninstall --yes` at the end.

---

## Part 4. MCP in depth (M, mostly unattended)

On each machine, `jetcarp mcp` with the test folders (pass the `JETCARP_*` folders in the MCP config,
or as the session's environment), driven by a script over stdin/stdout or through Claude Code:
1. **Every tool once** (`help` lists them):
   - worlds: new, edit, step, read, render, status;
   - searches: start, runs, job_status, job_stop;
   - library: query, curate;
   - pack;
   - media_render;
   - files_list;
   - reference;
   - run_script;
   - host_control (on a test host);
   - app_display and use_app (with the app running and AI control on).
2. **Folders:** writes outside the output and library folders are refused unless `--allow`ed, with a
   clear error.
3. **Bad input:** each tool given a missing or wrong argument gives an error a person can act on.
4. **Long jobs:** a search started through MCP keeps running after the MCP process ends, and is seen
   by `jobs status`.

---

## Part 5. Robustness (M, the session; Jimmie for 5.4)

1. **Odd files:**
   - a truncated scene JSON;
   - a scene with an unknown rule;
   - a scene whose `format` is from the future;
   - a truncated pack;
   - a pack with one byte changed (the signature must fail);
   - an unsigned pack (refused unless `--allow-unsigned`).

   Each needs a clear error and no crash.
2. **Two programs on one library at once:** the app open, a CLI explore and an MCP search running;
   `jobs list` from each; `jobs stop` from a different process than the one running the job.
3. **Limits:**
   - the largest world each GPU allows (doctor's limits), stepped on the GPU;
   - one cell more than the program's limit, which must be a clear refusal;
   - a 64-million-cell world on the host (`host status` memory).
4. **The graphics driver resets (Windows: Win+Ctrl+Shift+B; Jimmie)** while the host and the app
   run. Do they recover: the device re-created, or the CPU taking over with a note? Is the desktop
   right after?
5. **No room to write:** an output folder that's read-only gives a clear error.

---

## Part 6. The Framework (the main session; Jimmie for the looks)

| Step | What | Who |
|---|---|---|
| F0 | CI on the rc.2 commit: Linux, Windows and macOS green | main session |
| F1 | 2.0 and 2.G1 on rc.2's Linux build | main session |
| FG | `parity/expected.csv` and `parity/long/` regenerated with rc.2's Linux build; 1.1 and 1.2 on the Radeon and llvmpipe | main session |
| F2 | 2.1–2.12 on Linux (2.5–2.6 on a copy of Jimmie's library: clips from job 2, the score and rescore lines) | main session |
| F4 | The rating page in Firefox and Chrome: keys, reload, Save, light and dark | main session and Jimmie (a look) |
| F6 | Import the Acer's and the Mac's rc.2 packs; 1.6's comparison of all three hunts | main session |
| FD | 2.D on GNOME 51 in a private headless shell (as rc.1's F3/FD), then Jimmie's look at the pane and the desktop | main session; Jimmie |
| F7 | 2.APP on Linux (Wayland) | Jimmie with the main session |
| F3 | The GNOME refresh on Jimmie's real session: once, at the final release (one logout) | Jimmie |
| F9 | Part 4 (MCP) and part 5 (robustness) on Linux | main session |

---

## The sittings

**Phase 0 (the main session, before the tag):**
1. #41 and #42 merged, and the suite and CI green.
2. Jimmie's go for the tag.
3. The parity sets regenerated with rc.2's Linux build.
4. A "start" note in `NOTES.md`.

**Phase 1 (one evening, unattended, all three at once):** 1.1, 1.2, 1.3, 1.4 and 1.6 on each
machine. On the Framework, the main session also runs F1 and FG.

**Phase 2, the Acer, then the Mac (same sittings, M-1 to M-8):**

| Sitting | Steps | Jimmie |
|---|---|---|
| A-1 | 2.0, 2.G1, 2.1–2.4: unpack, self-test, explore, replays, CPU confirms, smart search | answers the checks |
| A-2 | 2.5–2.10: rating page (rate about 24 clips), refit and score, wait and caps, rules, soup and scripts, packs | rates clips |
| A-3 | 2.APP: every menu and pane, pop-outs, AI control | hands-on |
| A-4 | 2.D 1–7: just this scene, rotations, every generation, Fit, picks, overrides, pauses | hands-on |
| A-5 | 2.D 8–12: sleep, lock, login, screen saver, host crash; and 5.4, the driver reset (the Acer only) | hands-on |
| A-6 | Parts 4 and 5: MCP, robustness | answers the checks |
| A-7 | Part 3 in a separate account: a newcomer's first hour, the upgrade from 0.4.1 | hands-on |
| A-8 | 2.MM: two monitors (the monitor comes off the Framework) | hands-on |
| idle | 1.5: the overnight soak, while the next machine's block runs | starts it |

**Phase 2, the Framework (the monitor back on it).** The main session does its unattended rows
(F1, FG, F2, F6, F9) whenever they fit, and reports them in its chat as it goes.

| Sitting | Steps | Jimmie |
|---|---|---|
| F-1 | F4: the rating page in Firefox and Chrome; FD: the desktop pane and the headless shell's results; F7: 2.APP on Linux | hands-on |
| F-2 | Part 3 on Fedora, in a separate account | hands-on |
| F-3 | 1.5 overnight on the Framework, on a night Jimmie chooses (it's his main machine) | starts it |
| F3 | The GNOME refresh on Jimmie's real session: at the final release (one logout) | Jimmie |

## Results

Each machine's `results/v0.4.2-rc.2/<machine>/progress.md` holds its table (one row per step:
**Step | Result | Notes**) and the **Next:** line. The details go in `notes.md` beside it. At the
end, the main session copies the three tables here.

## After the wave

The main session:
1. reads every table and `NOTES.md`;
2. files an issue for every finding;
3. fixes them on the branch, then rc.3 with its own wave if anything needed a fix.

Only a wave that passes everything leads to the final release steps:
- bump to 0.4.2 and date the changelog;
- merge the branch into `main`;
- tag `v0.4.2` and publish (Jimmie's gates);
- Jimmie's one GNOME logout.

Then the JACA rerun starts on the released 0.4.2.
