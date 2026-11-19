# The rc.4 pre-check on the Acer (NOTES, 2026-11-16 12:30 PM, 1:18 PM and 6:35 PM EST)

The Acer: on mains, 12 threads, RTX 3050 6 GB Laptop GPU and Intel UHD Graphics, Windows 11 Home. Unattended, Jimmie
out. The branch `release-0.4.2`, built in Phase 1's clone `~/jetcarp-rc-042c/src`: **af07766** ("host status gives
the speed a screen reaches when it falls short of its scene's (#116)") for steps 1–4, then **41f7f2f** ("Windows: a
refused host serve --saver says so on the command line, not in a message box (#120)") for the #117 and #120
rechecks, then **29fea86** ("host start straight after host stop: stop waits for the host's lock too, and a new
host waits up to 2 s for it (#122)") for the #122 recheck (NOTES 7:25 PM EST). Every build says
`jetcarp 0.4.2-rc.3`, as the branch's crates do. Everything ran in a scratch folder,
`~/jetcarp-rc4pre` (`JETCARP_CONFIG_DIR`, `_DATA_DIR`, `_OUT`, `_RUNTIME_DIR`), so the everyday 0.4.1 library stays as
it is for A-7's upgrade test (`0-build-setup.txt`).

Scripts: `pre.ps1` (parity, then the suite on each GPU; `pre.log`, `pre-summary.txt`), `t87_minimise.py` (#87),
`t3_installer.ps1` (the installer), `t1_suite_rerun.ps1` (the suite again, with a watcher for the saver's box).

## 0. Build and the seizure warning: pass

- `cargo build --release -p jetcarp` at af07766: exit 0 in 3 min 09 s (`0-build.txt`); at 41f7f2f: exit 0 in 57 s;
  at 29fea86: exit 0 in 48 s.
- With no answer saved, `host start` refuses with the whole photosensitive seizure warning, exit 1.
  `jetcarp setup --seizure-warning no-disorder` saves the answer (`config\photosensitivity.json`, `"via": "setup"`).

## 2. Parity with the branch build (af07766): pass ×8

Every hash matches (`2-parity/`: one CSV and log a step; `pre.log` names the adapter each scene ran on):

| | RTX Vulkan | RTX DX12 | UHD Vulkan | UHD DX12 |
|---|---|---|---|---|
| 371 scenes × 300 generations | 371/371, 7.8 min | 371/371, 17.7 min | 371/371, 7.0 min | 371/371, 18.9 min |
| 40 scenes × 5,000 generations | 40/40, 2.3 min | 40/40, 3.3 min | 40/40, 2.4 min | 40/40, 3.7 min |

In each 371 run, CPU and GPU match all 371, with all 300 generations on the GPU in 334 scenes. In each 40 run, all
5,000 generations ran on the GPU in all 40. No MISMATCH lines.

## 1. The whole suite

`cargo test --release --workspace --no-fail-fast`, scratch folders, 3 h timeout.

### On af07766: a hang on Windows (#120), then UHD passes

- **The hang:** `nothing_starts_on_screen_before_the_warning_is_accepted` (host.rs, added in bc1d72f for #96)
  runs `jetcarp host serve --saver --seconds 1` with the warning unanswered and waits for it to end. On Windows that
  refusal put up a modal message box ('JETCARP', #32770, an OK button, the whole warning) and waited for OK, so the
  test never ended. Details, the window and the code: `1-suite-hang.txt`. The main session filed it as #120 and
  fixed it in 41f7f2f.
- **RTX (13:54):** the main binary's 14 unit tests and cli_json's 11 passed, then host.rs hung. The timeout killed
  the tree at 16:54, so nothing after host.rs ran (`1-tests-rtx-run1-timeout.txt`). In that run host.rs also printed
  `host_stop_returns_once_the_host_has_gone ... FAILED`; its report was lost with the kill.
- **UHD (16:54): pass** once the box was closed. It hung the same way from 16:55:05. At 18:31:31 the session
  posted IDOK to the box (BM_CLICK on the button did nothing); OK only closes it. The test passed, host.rs ended
  "15 passed; 0 failed; 3 ignored" (in 5,783 s), and the suite went on: **1,043 passed, 0 failed, 39 ignored, in 137
  test binaries**; exit 0, 111 min including the 96-min hang (`1-tests-uhd.txt`). rc.3 on this laptop gave 1,018 / 0 /
  33 in 135. The six newly ignored are the Mac's six (compared name by name with rc.3's 33): the three Fit tests
  (#112) and three new `app::shots` tests (`a_rule_being_typed_applies_before_save`, `jump_field_takes_typing`,
  `shots_photosensitivity_warning`).

### On 41f7f2f: RTX again, and host.rs alone on the UHD

`t1_suite_rerun.ps1`, the same command and folders, with a watcher for the saver's box. The first rerun, still on
af07766, was stopped after 2 min when the 6:35 PM note asked for 41f7f2f (`1-rerun-rtx-af07766-stopped.log`).

- **#120: pass.** `nothing_starts_on_screen_before_the_warning_is_accepted ... ok` on its own, on both GPUs; the
  watcher saw no message box in either run.
- **RTX, the whole suite: 1,042 passed, 1 failed, 41 ignored, in 137 test binaries**; exit 101, 15 min
  (`1-tests-rtx-41f7f2f.txt`). The two more ignored than on af07766 are new screenshot tests from d8ed2fb (the
  book's pictures): `app::shots::shots_ai_control` and `setup_ui::tests::offscreen_setup_wizard_running`.
- **UHD, host.rs alone: 14 passed, 1 failed, 3 ignored**; exit 101 (`1-tests-uhd-host-41f7f2f.txt`).
- **The failure, both times: `host_stop_returns_once_the_host_has_gone`** (host.rs:443), "start, round 1: Error:
  the host did not start: the JETCARP background host is not running". Round 0 passes; round 1's second
  `host start --headless` waits its whole 10 s and no host answers. It is intermittent (`1-host-stop.txt`):
  - in the whole suite: failed on af07766 RTX and 41f7f2f RTX, passed on af07766 UHD; host.rs alone on the UHD
    right after the 41f7f2f suite: failed;
  - the test alone: 20 of 20 pass; host.rs in parallel: 10 of 10; host.rs with `--test-threads=1`: 5 of 6;
  - from a terminal in a fresh folder, 20 rounds: the old host was always gone when `host stop` returned, and 20 of
    20 starts straight after a stop worked.
  host.rs removes `JETCARP_GPU`, so the GPU makes no difference to it. `1-host-stop.txt` has the whole report and
  what the code says: a new host that finds `host.lock` held exits 3 with its message on a stderr nobody reads,
  which would look exactly like this. It passed on rc.3 on this laptop, on the Mac and on the Framework.
  The main session found the cause (#122): Windows frees a dead process's lock after a delay that grows with load,
  so `host stop` could return while the old host still held `host.lock`.

### On 29fea86 (#122): pass

- **RTX, the whole suite: 1,043 passed, 0 failed, 41 ignored, in 137 test binaries**; exit 0, 14 min
  (`1-tests-rtx-29fea86.txt`). `host_stop_returns_once_the_host_has_gone ... ok`, and
  `nothing_starts_on_screen_before_the_warning_is_accepted ... ok` with no box (the watcher closed none).
- **host.rs alone, `--test-threads=1`, 10 runs straight after the suite: 10 of 10 pass**, each "15 passed; 0
  failed; 3 ignored" in 41–45 s, none with the 10 s wait of a failed start (`1-host-rs-29fea86-x10.txt`;
  `t1_host_x10.ps1`). 41f7f2f gave 5 of 6.

## 3. The PowerShell installer: pass; #117 recheck: pass

- **On af07766** (`3-installer.txt`): `Parser::ParseFile` 0 errors (PowerShell 5.1). Installs and `-Uninstall`
  work, with `-NoModifyPath` and without. The user PATH stays `ExpandString` with `%PNPM_HOME%` unexpanded, gets no
  duplicate on a second install, and is byte-identical after the uninstall. Four refusals are right, but each was
  followed by PowerShell's error block (`At …`, `CategoryInfo`): filed as #117.
- **On 41f7f2f** (`3-installer-117.txt`, the #117 recheck): all three criteria pass.
  - Every refusal exits 1 with no error block. Each is one line, `jetcarp-installer: …`; the three inside the
    download step follow the usual "getting JETCARP … from …" progress line.
  - Installs, the second install and `-Uninstall` as before. The PATH round trip is byte-identical (value and type).
  - No `jetcarp-*` folder appears in `%TEMP%` after any run, including the two new refusals inside the download
    step: `-DownloadUrl` an empty folder ("could not get SHA256SUMS from …") and a folder with SHA256SUMS but no zip
    ("could not get jetcarp-0.4.2-rc.3-x86_64-pc-windows-msvc.zip from …"). No `inst-c` folder is made either.
  - Aside: `%TEMP%` already held 33 `jetcarp-*` folders (`jetcarp-api-wait-*`, `-stopwait-*`, `-stopstat-*`,
    `jetcarp-app-lib-*`, `jetcarp-results-*`, `jetcarp-results-lib-*`), dated 2026-11-15 05:14 to 2026-11-16 18:40:
    test suites' leftovers, not the installer's.

## 4. #87 on Windows (af07766): pass

The branch app with `--control`, a 512 × 512 Life world at speed 30 through `jetcarp mcp --app`, `world_status`
polled every 2 s; minimised by script (`ShowWindow(h, 6)`) for 60 s, then restored (`4-87-minimise.txt`, `.json`):

| | polls | gens/s | slowest answer | app CPU (% of a core) |
|---|---|---|---|---|
| in view | 10 | 31.0 | 1.48 s (the first) | 42 |
| minimised | 30 | 30.0 | 0.33 s | 4 |
| restored | 10 | 30.0 | 0.32 s | 37 |

The app closed on WM_CLOSE, exit 0. rc.3 stopped dead when minimised (A-6).

## The Acer afterwards

- Free: no `jetcarp`, `cargo` or test processes; nothing of the pre-check on the user PATH (the round trip put it
  back byte for byte); the everyday 0.4.1 (Scoop) untouched.
- Left: the scratch folder `~/jetcarp-rc4pre` (9 MB: logs, the parity copy, the installer's refusal folders, the
  `stoprace` folder), and `~/jetcarp-rc-042c/src` at 29fea86, built.
- `%TEMP%` holds `jetcarp-*` folders left by test suites (#121, for 0.4.3); not removed.
- Developer Mode is still on (turned on for A-6's symlink test); Jimmie may turn it off.
