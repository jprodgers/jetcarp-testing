# Release candidate v0.4.2-rc.3: the rc.2 fixes, and the rest of the wave

> **Tagged and released (2026-11-15, 7:00 PM EST):** https://github.com/jprodgers/jetcarp/releases/tag/v0.4.2-rc.3,
> a public pre-release, tag `v0.4.2-rc.3` on 400d41d (CI green on all three). Plan approved by Jimmie: "sound".

**What rc.3 is.** rc.2's wave found 23 bugs (#47–#69), plus a private security problem. Every one
that fits is fixed on `release-0.4.2`. Two are moved to 0.4.3, because the fix would change stored
data or how the app picks its simulator: #55 (aperiodic sizing) and #71 (automatic GPU choice on
Optimus laptops). rc.3 also carries three app gaps from the Acer's A-3: #58, #59 and #62.

**Jimmie's slicing (2026-11-15):** every fix that reasonably can go into rc.3 does; rc.4 catches
stragglers; anything too big goes to 0.4.3. GitHub milestones `v0.4.2` and `v0.4.3` track it.

## How the wave goes on

rc.2's wave isn't finished:
- The Acer has done A-1 to A-3 and is on A-4.
- The Mac has done only Phase 1.
- The Framework has done its unattended rows (F1, FG, F2, F6, F9, F10, FD).

Proposed:
1. **The Acer finishes A-4 and A-5 on rc.2.** The desktop barely changed: only #69, the host's
   memory after a sweep.
2. **Tag rc.3**, on Jimmie's go.
3. **On rc.3:**
   - the Acer's A-6 to A-8 and 1.5;
   - the Mac's whole Phase 2 (M-1 to M-8, as rc.2's plan has them);
   - the Framework's F-1 (F4, F7, the pane and desktop look), F-2 and F-3.
   - Each machine also runs **R** below on rc.3, once: a check of every fix.
4. **Phase 1 again on rc.3, unattended, on all three machines:** parity (1.1, 1.2), the suite
   (1.3) and the long explore (1.4). 1.4's memory reading is #53's real test.

## After rc.3: rc.4, then the release

Expected (2026-11-15):
- **rc.4** carries rc.3's stragglers (whatever Phase 2 finds) and **the book audit** of everything
  changed since rc.2, pictures included. The audit was started the night rc.3 was tagged; Jimmie's
  rule is that the docs stay current with every update.
- rc.4's wave is **short and targeted**: R for what rc.4 changed, the parity sets, and the suite. It
  is not a full pass.
- If that's clean, **0.4.2 ships**, on Jimmie's go.

**On `release-0.4.2` for rc.4 so far** (2026-11-16, 12:15 AM EST):
- The rc.3 book audit (c9a0ec0, 930eece, 7163b3e, 8cb3df2) and its code fixes (bdc8730): `host status` says held for a screen a hold froze; the Hunts window says stale; `--detach`'s help says it waits for its process.
- **#80:** macOS memory readings and caps use the physical footprint (9c0ff6c). The Mac's 1.4 showed why: 8.6 GB RSS, 1.2–1.7 GB footprint.
- **(private) files JETCARP names itself inside a checked folder** are each checked for a link that leads out (d1f3478). This is the item under "Not fixed yet" below.
- **#57 straggler:** a refused export left its hidden store beside it (efe1a03; found by R on the Framework).
- **#52:** the crash is fixed (none in 60 runs); the UHD still hangs 1 run in 30, only with both tests in flight (0 in 30 serial). The changelog says only the crash is fixed, and the hang moves to 0.4.3 as an investigation (two GPU devices on one adapter at once). New issues from Phase 1, all for 0.4.3: #81 (explore memory peaks), #82 (DX12 misses the RTX now and then), #83 (screening stalls during confirmation).
- **#96, the photosensitive seizure warning** (Jimmie, 2026-11-16): the app asks before first setup (and once after upgrading), and the desktop background and screen saver refuse to start, from the CLI, at login or over MCP, until it's accepted (in the app, or with `jetcarp setup`). Answering "may have a seizure disorder" advises strongly against using JETCARP, with **Quit** first and **Continue at my own risk** second. The answer is saved for the planned strobe limiter (#97, roadmap). **rc.4's wave must accept it first on each machine** (the app, or `jetcarp setup`'s flag), and check it: a fresh settings folder shows the warning and refuses `host start`; the at-risk path offers Quit first.
- **Fit to this computer is hidden in 0.4.2 (#112; Jimmie, 2026-11-16):** "A fit should be 10 seconds, maybe 30 seconds. If we can't hit that target, I want the feature removed." rc.3's fits took 45 s to 12 min. 0.4.2 ships without it: no button, cards or limits in the pane, `host tune` hidden and refusing, no automatic refit, no MCP tune, and saved sizes not applied (each scene at its own size). A fast fit (about 10 s, one scene per screen, binary search, screens together, the limit shared by area) returns in 0.4.3 (#113), folding in #106–#111, #93, #94 and #77. **rc.4's R:** Fit is gone everywhere it was (pane, CLI, MCP, automatic refit), and a host.json with saved sizes from rc.3 shows each scene at its own size. R's rows for Fit (#38, #39, #44–#46, #69, #72, #73) become that check.
- Since rc.3, also: #84–#91, #95, #96, #98, #99, #100–#104 (see the changelog).
- rc.4's R adds: on the Mac, `jobs status` memory during an explore is near `footprint`'s figure, not the RSS (#80). On every machine, F9's `t42b_symlink.py` again, plus a link planted at an animation's `poster.png` and at a pack export's `pack.json`, each refused with nothing written where it leads.

## R: a check of every fix (each machine, on rc.3)

| # | Fix | Check |
|---|---|---|
| 47 | `--limit` help says an explore search finishes its step | `jetcarp search explore --help` |
| 48 | doctor with `JETCARP_GPU=<name>` tests only adapters the name matches | the Framework's `JETCARP_GPU=llvmpipe jetcarp doctor` shows no Radeon GL failure |
| 49 | A killed run reads `stale` at once in `jobs status`, `jobs list`, MCP `job_status` and the app's Hunts window | 1.4 step 3: status right after the kill |
| 50 | `jobs resume --detach` returns once the new process has the job; `jobs wait` straight after says running (exit 5), not gone | 2.3 / 1.4 |
| 51 | `jobs resume` with no budget runs what is left of the job's `--minutes`, and says so | 1.4: the resume ends at about 2 h in all, not after 3 h more |
| **53** | **An explore search gives its free memory back** (Linux): RSS stays near what it holds | 1.4: memory at 2 h and 4 h, against rc.2's |
| **54** | **An imported explore search has the same confirmed elites** | 2.10: pack, import, compare confirmed counts; equal |
| 56 | `jobs clips --sample 48` gives Frozen at once, Quick deaths, Static and Quiet rows at most 3 each, and says how the round is made up | 2.5 on a JACA search |
| 57 | `pack export` refuses any running search, even one with nothing stored; a refused export leaves no folder | 2.10 |
| 58 | Tiling pane → Size → Width × height, then HashLife's jump in place on 256 × 256 with wrap edges | 2.APP: Life on 256 × 256, wrap, Run → Jump → 2^20 |
| **59** | **Run → GPU adapter**: pick the RTX on the Acer, restart, and the status bar's hover names the RTX | 2.APP / 2.11: big Life on the RTX against the UHD's 21 gens/s |
| 60 | AI control window says *Open connections* | 2.APP 2 |
| **61** | **Rule box applies when clicked away; Esc puts the old rule back** | 2.APP 5: type a rule, click away, save, `verify` shows the new rule |
| **62** | **File → Export animation (GIF or WebP)…** | 2.APP 6: a GIF and a WebP of the view, open both; Render media is a full-size button |
| 63 | MCP `world_new` with width and height refuses over 4,000,000 cells, naming the count | part 4.3 |
| 64 | An MCP server's own search is left paused when the server exits | part 4.4 |
| 65 | A read-only output folder says "Permission denied" in every MCP tool | part 5.5 |
| 66 | `pack info` on a tampered pack says the signature doesn't verify; the unsigned refusal names `--allow-unsigned` | part 5.1 |
| 67 | A malformed rule's error quotes it with its CA and file; a read-only library can be read | part 5.1, extra |
| 68 | MCP argument errors name the argument; `threads: -1` and `help {"topic": 5}` are refused | part 4.3 |
| 52 | The GPU recovery test neither crashes nor hangs on Windows | the Acer: 30 runs on each adapter (see below) |
| **72** | **Fit judges the GPU limit on the Acer's UHD** (Windows' per-process GPU counters), or says plainly that it couldn't | 2.D 4 on the UHD: `gpu_timing` and the cards; the recommended size within 25% by Windows' own count |
| 73 | Fit's cards show only the shown rotation's scenes | 2.D 4 after an automatic fit of another rotation |
| 74 | The rotation editor's Add Quick Start box searches and adds the entry clicked | 2.D 2 |
| 75 | `host status` shows each screen's simulation now, after an override changes | 2.D 6 |
| 76 | `host status` says held (and why) when a hold pauses it | 2.D 7 |
| 78 | At login on Windows the launcher doesn't keep Windows waiting | 2.D 10: seconds from sign-in to the live desktop |
| 69 | The host's memory after three Fit sweeps stays near its start | 2.D 4–5: `host status` memory before and after |
| — | (private) The MCP tools don't write or read through a symlink that points outside their folders | part 4.2 with a link in the output folder (F9's `t42b_symlink.py`) |

## Set-up for every sitting

- **The Acer and the Mac:** default folders are fine. Jimmie (2026-11-15): their JETCARP installs are
  only for testing, and he'll upgrade both when the next release ships, to test the upgrade path, so
  their everyday folders needn't be protected. A scratch folder is still handy where a step needs a
  clean start, but it's optional. (With the default folders, a test host and the app share the
  everyday runtime folder, which A-5 found; that's fine here.)
- **The Framework (the main machine):** scratch folders as before, `JETCARP_RUNTIME_DIR` included.
  Never the real settings, library, pictures or GNOME settings; GNOME only in a private headless shell.

## Also in rc.3

- The four parity sets, unchanged: rc.3 changes no stepping. The 371-scene and 40-scene
  `expected.csv` still hold, and 1.1 and 1.2 check that.
- Docs: the GPU guide (*Run → GPU adapter*), the HashLife guide (Width × height), the pictures
  guide (*Export animation*), the searching guide (the clip sample's caps) and the changelog.

## Not fixed yet (rc.4 if not in rc.3)

- **#52:** the GPU recovery test crashed (0xC0000005) or hung on Windows (`tests/recovery.rs`, the
  RTX and the UHD).
  - Hardened in aa0b6ef: a failed or dropped stepper lets in-flight GPU work finish before its
    buffers go, and every wait for the GPU gives up after 60 s, which counts as a failure, so the
    processor carries on.
  - It isn't proven on Windows yet. The Acer's check (unattended, in rc.3's Phase 1): from a clone
    of the tag, `cargo test --release -p jetcarp-gpu --test recovery` **30 times** with
    `JETCARP_GPU=RTX`, then 30 with `JETCARP_GPU=UHD`. Pass: no crash, no hang (each run is about
    10 s; kill any that pass 2 minutes). If it still fails, rc.4.
- ~~**(private) files JETCARP names itself inside a checked folder** (media, pack contents, piles)
  aren't checked one by one for a planted link. This is narrower than the fixed hole.~~ Fixed for
  rc.4 in d1f3478. Every such writer checks the final path once links are followed; the command
  line and the app too. Left out: SQLite's own `-wal`/`-shm` files, a script-named library's
  `media/` and `searches/` folders, and hard links.

## Left for 0.4.3

#28 (run lineage), #34 (when a find first appears in its soup), #55 (aperiodic sizing, which needs
a sizing version stored with each search), #70 (isotropic non-totalistic rules), #71 (automatic
GPU choice that's timed, or simulation on the compute adapter).
