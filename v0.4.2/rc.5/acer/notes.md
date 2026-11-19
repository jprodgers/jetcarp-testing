# The rc.5 wave on the Acer (NOTES, 2026-11-17 7:32 AM EST; `v0.4.2-rc.5.md`, "The wave")

The Acer: on mains, 12 threads, RTX 3050 6 GB Laptop GPU and Intel UHD Graphics, Windows 11 Home. Started at
12:45 EST, after rc.4's 1.5 soak (which counts for rc.5). rc.5 is from the release (`v0.4.2-rc.5`, c0db1ab,
published 07:30 EST). The order is Jimmie's choice: A-7 and A-8 while Jimmie is here, then the unattended runs and
R5's rows.

## 0. The upgrade from rc.4: pass

- **The download** (`gh release download`): the Windows zip, `jetcarp-installer.ps1`, the win_amd64 wheel and
  `SHA256SUMS`, each matching `SHA256SUMS` (zip `e0f270b3…`).
- **rc.5 in place of rc.4** (`0-upgrade.txt`): each of rc.5's 70 files was copied over rc.4's in
  `~/jetcarp-rc-042c/bin`. None differs from the zip, and nothing of rc.4's is left over.
  `jetcarp --version`: `jetcarp 0.4.2-rc.5`.

## A-7: Part 3 in a new Windows account: pass, with a finding

See `A-7/summary.md`. In short:
- **Part A,** rc.5 with its own installer: install, the app, a hunt and the library. Uninstalling: each step
  "done" (#103), with nothing left after.
- **Part C,** 0.4.1 from Scoop, then rc.5's files over it:
  - the host came back at login as rc.5, held, with "waiting: the photosensitive seizure warning has not been
    accepted";
  - after the app's warning was answered, it ran;
  - the jobs and finds were kept, and setup wasn't asked again;
  - rc.5's uninstall named `scoop uninstall jetcarp` as the one command.
- **Part B's** upgrade didn't happen (`jetcarp.exe` was in use), so it was redone as Part C.
- **The finding, for 0.4.3 (#143):** the installer lines that `jetcarp uninstall` prints, and the book's, save
  `jetcarp-installer.ps1` into the current folder. A new PowerShell window in Ada's account opened in
  `C:\WINDOWS\system32`, so the save was refused.
- **Two moments of confusion, for 0.4.3 (#144):**
  - After the installer, `jetcarp` in the same window isn't found until a new window is opened. The installer and
    the book both say so, but where they're easy to miss.
  - A repeated `uninstall --settings --data` says "Nothing to undo: JETCARP has not set anything up outside its
    folders", and doesn't say the folders are already gone.
- **The checklist's faults are in the summary too.** Desktop art was buried in a bullet, and blocks' last lines
  didn't run on paste. The checklist was rewritten as literal steps during the sitting.

## A-8: two monitors without Fit, #112's monitor change, #130: pass; #130 confirmed

See `A-8/summary.md`. rc.5's host ran in its own folder, with the laptop's screen and the AOC (2560×1440, on the
left at x = −2560).
- **Two screens:** two rotations, one per monitor, each at its scene's own size. Jimmie: "Both looked right".
- **Unplug and replug while running:** the same host throughout; both screens back on their monitors at once.
- **The AOC's scaling (100 → 125 → 225 → 100%):** only the AOC's screen was rebuilt, its cells scaled to the
  monitor (2 → 3 → 5 → 2 px).
- **#112:** no fit or tune key in any status, and `host.json` unchanged.
- **#130 (0.4.3), as on the Mac:** with the AOC unplugged at start, screen 1 ("monitor 1 (not connected)") stepped at
  30 gens/s on the GPU with no window; plugged back in, it showed on the AOC at once. While the AOC was out during
  step 3, the screen also kept stepping, unseen.

## 1.1, 1.2 Parity with the release build: pass

`t1_long.ps1`, 16:22–17:18, on mains, with rc.5's `jetcarp.exe` from the zip. `1-parity/` holds each run's CSV and
summary; `t1_long.log` is the whole run. The AOC was unplugged during the first run; that made no difference.

| Run | GPU, backend | Scenes | CPU matches | GPU matches | Every generation on the GPU | Time |
|---|---|---|---|---|---|---|
| 1.1 | RTX, Vulkan | 371 at 300 gens | 371 | 371 | 334 | 5.6 min |
| 1.1 | RTX, DX12 | 371 | 371 | 371 | 334 | 17.0 min |
| 1.1 | UHD, Vulkan | 371 | 371 | 371 | 334 | 5.4 min |
| 1.1 | UHD, DX12 | 371 | 371 | 371 | 334 | 17.8 min |
| 1.2 | RTX, Vulkan | 40 at 5,000 gens | 40 | 40 | 40 | 2.0 min |
| 1.2 | RTX, DX12 | 40 | 40 | 40 | 40 | 3.2 min |
| 1.2 | UHD, Vulkan | 40 | 40 | 40 | 40 | 2.1 min |
| 1.2 | UHD, DX12 | 40 | 40 | 40 | 40 | 3.3 min |

There were 0 MISMATCH lines anywhere. The 37 scenes not all on the GPU are the CPU-only rules, as on rc.4. Every GPU
process ran on the adapter asked for. rc.3 and rc.4 each had one RTX DX12 process fall back to the UHD; this time
there were none.

## 1.3 The suite on the tag: pass

The source at `~/jetcarp-rc-042c/src` was fetched and moved from rc.4's tag to `git checkout --detach v0.4.2-rc.5`
(c0db1ab, "Release 0.4.2-rc.5"), clean. The suite ran with `cargo test --release --workspace --no-fail-fast`, with a
watcher to close any message box (it closed none).

| `JETCARP_GPU` | Passed | Failed | Ignored | Test binaries | Time | Log |
|---|---|---|---|---|---|---|
| RTX | 1048 | 0 | 41 | 137 | 22 min (7 min of it the build) | `1-tests-rtx-tag.txt`, `1-rerun-rtx-tag.log` |
| UHD | 1048 | 0 | 41 | 137 | 14 min | `1-tests-uhd-tag.txt`, `1-rerun-uhd-tag.log` |

- **The same tests on both GPUs:** both runs list the same 1,089 tests. That is rc.4's 1,084 plus five new ones,
  among them `a_login_item_s_missing_folders_are_named` (#124) and `the_line_is_erased_with_the_code_or_with_spaces`
  (#127).
- **The RTX log's first line names `jetcarp 0.4.2-rc.4`,** as rc.4's named rc.3. That line reads
  `target\release\jetcarp.exe` before cargo builds, so it showed rc.4's leftover binary. The run then compiled every
  crate at `v0.4.2-rc.5`, and the UHD log names rc.5.
- **The build's only warning** is rc.4's: `unused import: stable_name` in
  `crates\jetcarp-core\tests\bundled_packs.rs:3`. It's in a test, so it's information only.

## R5 #127, the old console window: pass (`127-narrow-*.txt`, `127-file.txt`)

`t127_narrow.ps1` is rc.4's #104 check again. A window 60 columns wide ran `jetcarp --version`, a `pack import` of
the starter pack into a fresh library, and a half-minute `search explore`. The window's text was read row by row (with
the console's output mode) 15 s into the explore and at the end. Every run named rc.5 by its full path.

| Window | Output mode | The explore's progress | `←[2K` or ESC |
|---|---|---|---|
| conhost, cmd | 0x7 (rc.4: 0x3) | one row, redrawn in place, cut to 60 columns with "…" | none (rc.4: a new row per redraw, each starting `←[2K`) |
| conhost, PowerShell 5.1 | 0x7 (rc.4: 0x3) | the same | none (rc.4: as cmd) |
| Windows Terminal, cmd | 0x7 | the same, as rc.4's row for row | none |
| Windows Terminal, PowerShell | 0x7 | the same, as rc.4's | none |

- **conhost:** rc.5 turns escape codes on at start-up (mode 0x3 → 0x7), and its progress lines now redraw as one
  clean row. rc.4's blank row after "reading verifications, sightings, provenance and annotations" is gone too.
- **Windows Terminal is unchanged:** the same rows as rc.4's captures.
- **Output sent to a file is unchanged** (`t127_file.ps1`). It was checked with cmd's `> file 2>&1` (a `pack import`
  and a quarter-minute explore) and with Start-Process's stdout and stderr files. Each line was whole, never cut to a
  width, and each progress line was on a line of its own. No file had an ESC byte, a carriage return without a line
  feed, or an ellipsis.
- **Information only, not #127:** a 15 or 30 s explore sometimes ends with about 1,030 runs "given up at a stop or
  the end (not kept)". That happens when the GPU's batch is still running when the budget runs out. rc.4's Windows
  Terminal runs ended the same way (111 runs kept).

## R5 #128: pass (`R5-rows.txt`)

- **The CLI:** `jetcarp host tune --help` and `jetcarp host help tune` each print only "Fit to this computer isn't in
  JETCARP 0.4.2: it returns, faster, in 0.4.3. Each scene shows at its own size." Both exit 0.
- **The installer** was rc.5's own `jetcarp-installer.ps1` from the release, checked against `SHA256SUMS`, installing
  into its default folder `%LOCALAPPDATA%\Programs\jetcarp`. The user PATH (its raw value and its kind, ExpandString)
  was compared before and after each step.
  - `-NoModifyPath` "left your PATH alone: run JETCARP as …\jetcarp.exe", and the user PATH was unchanged. Then
    `-Uninstall`: "removed …\Programs\jetcarp **(it wasn't on your PATH)**", and the user PATH was still unchanged.
  - A normal install "added …\Programs\jetcarp to your user PATH". Then `-Uninstall` (after #134's step): "removed
    …\Programs\jetcarp **and took it off your PATH**". The user PATH was then byte for byte what it was before the
    install, kind and all.

## R5 #124's note: pass (`R5-rows.txt`)

- **With every `JETCARP_*` folder set** (a test folder, `~/jetcarp-rc5/h124`, with the warning answered there),
  `jetcarp host login on` printed the login line and then: "note: the login item starts the host with the default
  folders; JETCARP_CONFIG_DIR, JETCARP_DATA_DIR, JETCARP_RUNTIME_DIR, JETCARP_LIBRARY, JETCARP_OUT are not passed on to
  it". The Run value was `JETCARP="~\jetcarp-rc-042c\bin\jetcarpw.exe" host serve --login`. `login on` started no host
  in either the test folder or the default folders. `host login off`: "the host no longer starts at login", and the
  Run value was gone.
- **The control, with no `JETCARP_*` folder set** (the default folders): the same login line with no note. Then
  `login off`, and the Run value was gone.

## R5 #134, the installer's `-Uninstall` after `jetcarp uninstall --settings --data`: pass (`R5-rows.txt`)

This used a normal install with rc.5's installer, on the default folders (not sacred on the Acer: Jimmie). They held
the rc.4 sitting's settings and 42.5 MB of data.
- `jetcarp uninstall` (no `--yes`) listed the steps, and kept the data and settings folders without the flags.
- `jetcarp uninstall --yes --settings --data`: each step "done", including "delete the settings folder" and "delete
  the data folder (42.5 MB)". "Your pictures and exports in ~\OneDrive\Pictures\JETCARP are never deleted." After it,
  both folders were gone and Pictures\JETCARP was still there.
- Then `-Uninstall`: "kept your settings, data and pictures in ~\OneDrive\Pictures\JETCARP; delete them by hand if you
  want them gone". It names only the folder still there. rc.4's said it kept the settings it had just deleted, so
  #134 is fixed on Windows too.
- **The wording is #142 (0.4.3), the Mac's question 2:** the line still opens "kept your settings, data and pictures"
  when only the pictures are left. It's the same on Windows.
- **The case with no folder left** can't be made here without touching Jimmie's OneDrive `Pictures\JETCARP`, so it
  wasn't. The Mac's scratch-home run covers it. In `install.ps1`, the line is printed only when at least one of the
  three folders exists.

### (private) part 4.2: pass

## Clean-up at the end of the wave

- **Gone:** rc.5's installer install (`-Uninstall` in #134), and the default settings and data folders
  (`uninstall --settings --data` in #134).
  - There's no JETCARP Run value, no jetcarp process and no screen saver.
  - `C:\Users\Public\jetcarp-a7.txt` and `jetcarp-a7-notes.txt` were deleted once checked identical to `A-7/`.
  - mdBook was deleted from `~/jetcarp-rc4/tools`.
- **Left in place:**
  - rc.5's release files in `~/jetcarp-rc-042c/bin`, for the next upgrade, as rc.4's were;
  - the source clone at `v0.4.2-rc.5`;
  - the test folders under `~/jetcarp-rc5`;
  - Scoop's 0.4.1, as before the wave;
  - OneDrive's `Pictures\JETCARP`, untouched throughout.
- **Jimmie's call:** Developer Mode (still on, for the private row) and Ada's account.
