# v0.4.2-rc.5 on the Acer

| Step | Result | Notes |
|---|---|---|
| Upgrade from rc.4 | pass | Zip, installer and wheel match `SHA256SUMS`; rc.5's 70 files over rc.4's in `~/jetcarp-rc-042c/bin`, none left over; `jetcarp 0.4.2-rc.5` (`0-upgrade.txt`) |
| A-7 (Part 3, new account) | pass, with a finding | rc.5's installer, first hour, uninstall (#103: each step "done"); 0.4.1 from Scoop, rc.5 over it: the host back at login, held until the warning was answered, then running; jobs and finds kept; rc.5's uninstall names `scoop uninstall jetcarp`. **Finding:** the installer lines (printed by `jetcarp uninstall`, and in the book) save into the current folder, and a new PowerShell window opened in `C:\WINDOWS\system32`: access denied (#143). Two moments of confusion (#144; see `A-7/summary.md`) |
| A-8 (two monitors) | pass; #130 confirmed | Two screens, one per monitor, each at its own size (the AOC on the left, at x = −2560); unplug and replug while running: the same host, both back; the AOC's scaling 100→125→225→100%: only its screen rebuilt, cells scaled to the monitor; #112: no fit, no tune key, `host.json` unchanged. #130 (0.4.3): started with the AOC out, its screen steps unseen at 30 gens/s with no window; back at once when replugged (`A-8/summary.md`) |
| 1.1, 1.2 parity | pass | RTX and UHD × Vulkan and DX12: 371 of 371 and 40 of 40 on each, CPU and GPU; 0 MISMATCH lines; every GPU process on the adapter asked for (`1-parity/`, `t1_long.log`) |
| 1.3 suite on the tag | pass | `v0.4.2-rc.5` (c0db1ab): 1048 passed, 0 failed, 41 ignored in 137 test binaries, on RTX (22 min) and UHD (14 min); no message box |
| R5 #127 | pass | conhost (cmd and PowerShell), 60 columns: output mode 0x7 (rc.4: 0x3); progress redraws as one clean row, with no `←[2K`. Windows Terminal is the same as rc.4's. Output sent to a file has whole lines, no ESC, no bare CR (`127-narrow-*.txt`, `127-file.txt`) |
| R5 #128 | pass | `host tune --help` and `host help tune`: only "Fit to this computer isn't in JETCARP 0.4.2…". rc.5's installer `-NoModifyPath` then `-Uninstall`: "(it wasn't on your PATH)"; a normal install then `-Uninstall`: "took it off your PATH"; the user PATH back exactly (`R5-rows.txt`) |
| R5 #124's note | pass | With every `JETCARP_*` set, `host login on` names the five variables the login item won't carry; with none set, no note; `login off` removes the Run value |
| R5 #134 | pass | After `jetcarp uninstall --yes --settings --data`, `-Uninstall` names only `~\OneDrive\Pictures\JETCARP`, the one folder left. The wording "kept your settings, data and pictures in" is #142 (0.4.3). The case with none left needs Jimmie's Pictures folder gone, so it's left to the Mac |
| (private) part 4.2 | pass | |
| Clean-up | done | Installer install and default folders gone; Public A-7 files and mdBook deleted; Developer Mode and Ada's account are Jimmie's call |

Details: `notes.md`, `A-7/summary.md`, `A-8/summary.md`.
