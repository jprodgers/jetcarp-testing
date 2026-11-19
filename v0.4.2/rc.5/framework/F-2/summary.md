# F-2 on rc.5: Part 3 in a new Fedora account (the Framework, 2026-11-17, about 7:33–8:25 AM EST)

Jimmie, in a new standard account (`test`) on Fedora 45, GNOME 51.1 on Wayland, with fast user switching (his own
session kept running). He followed `checklist.md`, and rc.5's book served from his account at `localhost:3000`, since
the online book is still 0.4.1's. His notes are in `jimmie-notes.txt`, word for word.

## Part A: a newcomer's first hour on rc.5

| Step | Result |
|---|---|
| A1, install | **pass**: rc.5's own installer (`releases/download/v0.4.2-rc.5/jetcarp-installer.sh`); `jetcarp 0.4.2-rc.5`. The book's command fetches "latest", still 0.4.1, since pre-releases are never latest (expected for a pre-release). |
| A2, setup with Desktop art, wallpaper and login on | **finding, #139** (0.4.3): a window opened running Brian's Brain, and nothing showed on the desktop. GNOME loads the extension setup installs only at the next login, and the only mention is setup's small print, which Jimmie didn't see. The stand-in window doesn't say why it's a window. |
| A3, `jetcarp setup --status` | **pass**: Desktop art, the folders, the starter pack, the Radeon, the profiles |
| A4, Quick Start world, a short hunt, a find in the library | **pass** |
| A5, MCP with an assistant | skipped: no Claude Code in the new account. #102 passed on the Acer and the Mac. |
| A6, `jetcarp uninstall --yes` | **pass**: stopped the host, removed the login entry, the GNOME extension, the host's lock and the job-locks folder; kept data and settings (no `--data`/`--settings`), said so, and named the installer command (`A6-lockup.jpg`). Afterwards the terminal window (ptyxis) wouldn't respond to clicks or keys until a new terminal window was opened. No JETCARP process was left, and the shells were idle; ptyxis logged a GTK tab assertion. ptyxis's, not JETCARP's. |

## Part B: the upgrade from 0.4.1

| Step | Result |
|---|---|
| B1, 0.4.1 with its installer | **pass** |
| B2, use it | 0.4.1 started with Part A's kept settings: no warning, no setup, as expected. **Finding, #140** (0.4.3): it opened drawn skewed, the contents squeezed and short of the window's edge (`skewed_start.jpg`), until the window was resized. |
| B3, rc.5 over it | **pass** for the version and the kept settings (no second warning: the answer from Part A was kept). **#140 again**: rc.5 opened grainy, the contents larger than the window and clicks landing away from the pointer, until resized (`second_start.jpg`). On Wayland the app restores its saved size through winit directly, which applies it with no Resized event, so egui keeps the old size. In 0.4.1 too. No desktop wallpaper after logging in again: A6's uninstall had removed the login entry and the extension, and B didn't turn them on again, so that's as expected. So the host's return at login after an upgrade wasn't tried on Linux; the Mac (#99) and the Acer covered it. |
| B4, uninstall | **pass** |

#139 and #140 are for 0.4.3 (Jimmie, 2026-11-17: "0.4.2 has too many other critical fixes that I want to get out").
