# A-7 on rc.5: Part 3 in a new Windows account (the Acer, 2026-11-17, about 13:20–15:56 EST)

Jimmie, in a new local Standard account ("Ada Test") on Windows 11 Home, with fast user switching (Jimmie's own
session kept running). Jimmie followed `checklist.txt`, and rc.5's book was served from Jimmie's account at
`127.0.0.1:3000`. Jimmie's notes are in `jimmie-notes.txt`, word for word. `a7_watch.ps1` noted the jetcarp processes in every session
(`a7-procs.txt`).

**The checklist changed twice during the sitting.** Part B's command lines had notes on them, so they wouldn't paste;
then Jimmie asked for literal steps ("If you skip things, I skip things"). `checklist.txt` is the last version (Part C).
Two of the checklist's faults affected results:
- A3 had Desktop art as a bullet, and it was skipped.
- Until Part C, a block's last line ran only if the selection held its line break. So the last line of most blocks in
  A6 and B never ran: `jetcarp --version`, `library list`, `Get-ItemProperty` and `scoop bucket rm`.

## Part A: a newcomer's first hour on rc.5

| Step | Result |
|---|---|
| A2, install | **pass**: rc.5's installer (`releases/download/v0.4.2-rc.5/jetcarp-installer.ps1`) checked the zip against `SHA256SUMS`, installed in `%LOCALAPPDATA%\Programs\jetcarp`, and added it to the user PATH. **Moment of confusion:** `jetcarp` typed in the same window wasn't found. The installer's line 5 of 6 says "open a new terminal to use `jetcarp`", and the book says so after its table, but both are easy to miss. In a new window: `jetcarp 0.4.2-rc.5`. |
| A3, the app | Started; Jimmie went through the tutorials. **Desktop art not done** (the checklist's fault, above). |
| A4, Quick Start, a hunt, the library | **pass** ("Works as expected") |
| A5, MCP | skipped: no Claude Code in the new account. #102 passed in Jimmie's own (rc.4). |
| A6, uninstall | **pass**, with a finding. `jetcarp uninstall` printed its plan. `--yes --data --settings` removed the empty job-locks folder, the settings folder and the data folder: each "done", no FAILED (#103). The settings, data and program folders were then all gone (`Test-Path`: three False). The installer's `-Uninstall` ran from Downloads, but its output wasn't kept, so #134's wording isn't in this record (R5's #134 row covers it). **Finding:** the installer lines that `jetcarp uninstall` prints failed in a new PowerShell window (below). **Moment of confusion:** a third `uninstall --yes --settings --data` said "Nothing to undo: JETCARP has not set anything up outside its folders", which Jimmie read as the flags being ignored when given in the other order. The folders were already gone. |

**Finding (Windows, for 0.4.3): the installer lines save into the current folder, which may not be writable.**
- Every new PowerShell window Ada opened (Start, type PowerShell, Enter) started in `C:\WINDOWS\system32`.
- `jetcarp uninstall` prints `Invoke-WebRequest …/jetcarp-installer.ps1 -OutFile jetcarp-installer.ps1`. Run there,
  it fails: "Access to the path 'C:\WINDOWS\system32\jetcarp-installer.ps1' is denied."
- The book's install and uninstall lines have the same form; A2 worked only because the checklist began with
  `cd ~\Downloads`.
- A fix: `-OutFile "$env:TEMP\jetcarp-installer.ps1"` and run that path, or `cd ~` first.

## Part B: the upgrade from 0.4.1 (first try)

| Step | Result |
|---|---|
| B1, 0.4.1 with Scoop | **pass**: Scoop, git, the `jetcarp` bucket, `jetcarp` 0.4.1 |
| B2, use it | **pass.** 0.4.1's setup with Desktop art turned on the live wallpaper: host running "A classic a day", "wallpaper: showing". The hunt gave the book's own example result (20,000 soups, 430,384 objects, 50 distinct), and there was a 1-minute explore. The checklist's rating line recorded 4 keeps: it also took the summary line "3 run(s)…" as run 3. |
| B3, rc.5 over it | **set aside.** `Copy-Item` failed: `scoop\apps\jetcarp\current\jetcarp.exe` was in use. A jetcarp process from Scoop's folder had run since the app was opened in B2 (15:28) and ran on until the sign-out (15:33); Jimmie doesn't remember closing the app. The other files were copied, so `jetcarp.exe` stayed 0.4.1 beside rc.5's `jetcarpw.exe`. After the sign-in the host came back, in 0.4.1's status format, and the app showed no seizure warning: 0.4.1 throughout. |
| B4, uninstall | 0.4.1's `uninstall --yes` stopped the host, removed the login entry and the lock, and forgot the host command; then `scoop uninstall jetcarp`. Desktop back. |

## Part C: the upgrade from 0.4.1, again (a pass)

| Step | Result |
|---|---|
| C1, 0.4.1 again | **pass**: `scoop install jetcarp` (0.4.1, from Scoop's cache), with Part B's settings and data. `host start`, `wallpaper on`, and `login on`, which registered `"…\scoop\apps\jetcarp\current\jetcarpw.exe" host serve --login`. Desktop: Penrose waves (`B2/S/C4`, which Jimmie saw as Brian's Brain). |
| C2, rc.5 over it | **pass.** After `host stop`, no jetcarp process was left, and the copy worked: `jetcarp 0.4.2-rc.5`. |
| C3, sign out and in | **pass.** The host came back at login as rc.5 and **held**: generation 0 after 87 s, with "waiting: the photosensitive seizure warning has not been accepted (open the JETCARP app, or run `jetcarp setup`, …)". The app showed the warning first; Jimmie answered, and no setup followed, since the settings were kept. The host then ran: generation 2,454 at 210 s, "the photosensitive seizure warning has been accepted; the scenes run". The same two jobs, with the explore's status identical to Part B's; the library has the hunt's 4 spaceships (glider, LWSS, MWSS, HWSS). After the app's X, only the host was left: the app exits when its window closes. |
| C4, uninstall | **pass.** rc.5's `uninstall --yes --settings --data`: the host stopped, the login entry removed, the lock removed, the settings and data deleted. Then **one command named for the installer** (#103): "To remove the program itself (in …\scoop\apps\jetcarp\0.4.1, installed with Scoop), run this: scoop uninstall jetcarp". After `scoop uninstall jetcarp` and `scoop bucket rm jetcarp`, no jetcarp process was left, and the desktop was back to its static picture. |

Not covered here: rc.5's own Desktop art step in setup (A3); MCP (A5); and the ratings after the upgrade
(`jobs status` doesn't list reviews). rc.5's host ran on the UHD after the upgrade, while 0.4.1's ran on the RTX.
