# Release candidate 1 (v0.4.0-rc.1)

**What this wave tests:** installing JETCARP each way, the app, the desktop features (live
wallpaper, screen saver, still picture, start at login) and uninstalling, on the Acer and the Mac.
The setup wizard, the MCP server's new tools and the starter pack come in rc2. This candidate has
no starter pack, so the Quick Start menu shows only the built-in classics.

**The release:** https://github.com/jprodgers/jetcarp/releases/tag/v0.4.0-rc.1 (a public
pre-release). Its notes list every file.

Work through your machine's section in order. For each step:
- record the result in the table at the end of your section: **pass**, **fail**, or **skip**, with a
  short note;
- save command output to `results/rc1/<machine>/` (`acer` or `mac`) as `NN-name.txt`;
- save screenshots there too, when they show something useful.

Commit and push after each section. Ask Jimmie each "Check" one at a time, and tell Jimmie before
anything changes the desktop.

Before starting, record the system: OS version and build, graphics adapters, monitors attached,
and whether the laptop is on battery or mains.

---

## Acer (Windows 11)

### A1. Install with the PowerShell installer

In a new PowerShell window (not as administrator):

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.1/jetcarp-installer.ps1 | iex"
```

Then open a **new** PowerShell window, so it sees the new `PATH`, and run each of these, saving the
output:

```powershell
jetcarp --version          # expect: jetcarp 0.4.0-rc.1
jetcarp paths
jetcarp doctor
```

Checks:
1. Did the installer finish without errors, and say where it installed (`%LOCALAPPDATA%\Programs\jetcarp`)?
2. Does `jetcarp doctor` list both graphics adapters (RTX 3050 and Intel UHD), with one marked `*`?
3. Does `jetcarp paths` show `bundled:` as none? (Expected: rc1 has no starter pack.)
4. Did SmartScreen or Defender warn about anything? Record the exact wording if so.

### A2. The app

Start it from the terminal with `jetcarp`. Then also try `jetcarpw.exe` from the install folder (by
double-clicking it in Explorer), which should open the app with no console window.

Checks:
1. Does the app open on the Quick Start screen, with cards whose previews animate?
2. Open three entries, one at a time: a classic (Life), an aperiodic one (hat or spectre), and a
   sandpile. Does each run and pause (Space)?
3. Right-click a card. Is there a menu with five stars and *Hide*? Rate one card, hide another, go
   back to the Quick Start screen: is the hidden one gone?
4. *File → Save scene…*, then *File → Open scene…* on that file. Does it come back at the same
   generation?
5. *File → Export PNG…*. Does the picture look right?
6. *Tools → Large sandpile…*: 1,000,000 grains on `square`, with *Topple on the GPU* ticked. How
   long did it take (it reports seconds), and does the picture look like a square-ish mandala?
7. *Tools → Hunts…*: start a short soup hunt (the defaults, stopped after a minute). Do finds appear
   in *Tools → Pattern library…*?
8. Does the window resize, maximise and close normally? Is the text sharp at the laptop's display
   scaling?

### A3. The desktop

Clear the desktop first (Win+D). Each step changes the desktop and undoes it afterwards.

```powershell
jetcarp host start
jetcarp host status
jetcarp host wallpaper on
```

Checks:
1. Is a live picture drawn under the desktop icons, with the icons readable and clickable?
2. `jetcarp host next`: does it change to the next scene?
3. `jetcarp host caption on`: is there a caption in a corner? Then `caption off`.
4. **Attach the external monitor.** `jetcarp host status` lists the monitors. Does the picture
   cover both? Try `jetcarp host wallpaper on --screen 0 --monitor 0` and
   `jetcarp host wallpaper on --screen 1 --monitor 1 --rotation "Classics, hourly"`: does each
   monitor show its own screen?
5. Unplug the charger: does the host pause (battery)? Plug it back in: does it carry on?
6. `jetcarp host still on`, then `jetcarp host stop`: is a still picture left as the desktop
   background? Then `jetcarp host still off`.
7. `jetcarp host wallpaper off`, `jetcarp host stop`: is your normal wallpaper back?
   On Windows, watch `jetcarp host stop` closely: before rc1 it could print a connection error
   although the host stopped. That should now be fixed. Record whether it happens, and check
   with `jetcarp host status` that the host is gone.

The screen saver:

```powershell
jetcarp host saver install
```

8. Does Windows' screen saver settings dialog open with JETCARP chosen? Does *Preview* show it?
9. Set the wait to 1 minute and leave the laptop idle: does it start? Does moving the mouse end it?
10. `jetcarp host saver status`, then `jetcarp host saver remove`: is it gone from the list?

Start at login:

```powershell
jetcarp host login on
jetcarp host status
```

11. Ask Jimmie whether to test a real sign-out and sign-in now (nobody has tested that yet). If yes:
    sign out and back in, then run `jetcarp host status`. Did the host start by itself, with no
    console window?
12. `jetcarp host login off`.

### A4. pipx or uv

Only if `uv` or `pipx` is already installed (`uv --version`, `pipx --version`). Don't install either
without asking Jimmie. Download the Windows wheel from the release and install it:

```powershell
gh release download v0.4.0-rc.1 --repo jprodgers/jetcarp --pattern "*win_amd64.whl" --dir rc1-wheel
uv tool install (Get-ChildItem rc1-wheel\*.whl).FullName     # or: pipx install <that file>
```

Checks:
1. Does `jetcarp --version` (in a new terminal) report 0.4.0-rc.1, from the uv or pipx folder
   (`where.exe jetcarp`)?
2. Does `jetcarp paths` show `bundled:`? (With no starter pack in rc1: none.)
3. Uninstall it: `uv tool uninstall jetcarp` or `pipx uninstall jetcarp`.

### A5. Uninstall

```powershell
jetcarp uninstall --help
jetcarp uninstall
```

Checks:
1. Did it list what it would remove, and remove it? Is your own desktop picture still yours?
2. Run the installer's uninstall:
   `powershell -ExecutionPolicy Bypass -c "& ([scriptblock]::Create((irm https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.1/jetcarp-installer.ps1))) -Uninstall"`.
   Is `%LOCALAPPDATA%\Programs\jetcarp` gone, and `jetcarp` no longer on the `PATH` in a new
   terminal?
3. List what's left: `dir $env:APPDATA\jetcarp, $env:LOCALAPPDATA\jetcarp` and
   `dir "$env:USERPROFILE\Pictures\JETCARP"`. Record what remains; the pictures folder is kept on
   purpose.

### Acer results

| Step | Result | Note |
|---|---|---|
| A1 | pass | Installed in 14 s, no warnings; doctor `*` on the RTX 3050; bundled none. But the installer turned the user PATH from REG_EXPAND_SZ into REG_SZ and expanded `%PNPM_HOME%\bin` (see `results/rc1/acer/notes.md`) |
| A2 | pass | All 8 checks pass (pile 1M grains on the GPU: 8.2 s; hunt: 10,000 soups in 7 s, 64 finds in the library; jetcarpw.exe: no console). But the first session **crashed silently on close** (0xC0000005 in `nvoglv64.dll_unloaded`); not reproduced in two more. Smaller: window first opened partly under the taskbar; status bar says "Running" while paused; an opened scene starts running at once |
| A3 | pass, except 3 and 10 | Live wallpaper, `next`, two monitors (AOC left of the laptop), battery pause, still, login (real reboot) work; `host stop` printed no connection error (3 stops). Check 3: caption under the taskbar, cut off. Check 10: `saver remove` fails ("Access is denied") while the Settings dialog is open. Also: one still for both monitors; `wallpaper off` makes the next login open screens as windows; `host start` hangs anything that captures its output |
| A4 | skip | Neither uv nor pipx is installed (Python 3.14 is, without pipx) |
| A5 | pass | `jetcarp uninstall` showed its plan, `--yes` did it; wallpaper (same image hash) and screen saver settings as before; installer `-Uninstall` removed the folder and the PATH entry. Left: settings, data (with a stale `host.lock`), empty `desktop-pictures`, and the piles in `OneDrive\Pictures\JETCARP` (not `%USERPROFILE%\Pictures`). The user PATH stays REG_SZ with `%PNPM_HOME%` expanded |

---

## Mac (macOS 27)

### M1. Install with the shell installer

```bash
curl -LsSf https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.1/jetcarp-installer.sh | sh
```

If it says `~/.local/bin` is not on your `PATH`, run the line it shows in this terminal only (don't
edit shell startup files without asking Jimmie). Then:

```bash
jetcarp --version          # expect: jetcarp 0.4.0-rc.1
jetcarp paths
jetcarp doctor
```

Checks:
1. Did it install into `~/.local/lib/jetcarp`, with a link in `~/.local/bin`?
2. Did macOS block anything as unidentified? Expected: no, because curl leaves no quarantine mark.
   Record any dialog.
3. Does `jetcarp doctor` show the M2 Max (Metal)?
4. `bundled:` none (rc1 has no starter pack)?

### M2. The app

Start it with `jetcarp`. Run the same checks as A2 (1–8), using Cmd for Ctrl. Add:

9. Does the app appear in the Dock with JETCARP's name, and quit cleanly with Cmd+Q?

### M3. The desktop

Hide all windows first. Run the same commands as A3, with these differences:

1–3. As A3.
4. **External monitor:** as A3 step 4. Also switch Spaces (Ctrl+←/→) and open Mission Control:
   does the picture stay on every Space?
5–7. As A3 (battery pause, still picture, wallpaper back).

Screen saver:

```bash
jetcarp host saver install
```

8. Does System Settings open at the screen savers with JETCARP listed? Does its preview animate?
9. Set it to start after 1 minute and leave the Mac idle: does it start? Does it end on a key press?
10. `jetcarp host saver remove`: is it gone?

Start at login: as A3 steps 11–12 (log out and back in only if Jimmie agrees).

### M4. pipx, uv or Homebrew

Only if `uv` or `pipx` is already installed:

```bash
gh release download v0.4.0-rc.1 --repo jprodgers/jetcarp --pattern "*macosx*arm64.whl" --dir rc1-wheel
uv tool install rc1-wheel/*.whl      # or: pipx install rc1-wheel/*.whl
jetcarp --version; which jetcarp; jetcarp paths
uv tool uninstall jetcarp            # or: pipx uninstall jetcarp
```

Homebrew isn't published for candidates: skip it.

### M5. Uninstall

```bash
jetcarp uninstall --help
jetcarp uninstall
curl -LsSf https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.1/jetcarp-installer.sh | sh -s -- --uninstall
ls ~/Library/Application\ Support/jetcarp ~/.cache/jetcarp ~/Pictures/JETCARP 2>&1
```

Checks: as A5 (desktop picture is yours; the install folder and link are gone; what remains).

### Mac results

| Step | Result | Note |
|---|---|---|
| M1 | pass | Installed in `~/.local/lib/jetcarp`, link in `~/.local/bin` (already on the PATH); no quarantine mark, no dialog; doctor `*` Apple M2 Max (Metal); bundled none. Jimmie ran the install line, because auto mode blocks `curl \| sh` |
| M2 | pass, except 9's name | All checks pass (pile 1M grains on the GPU: 4.2 s, same 11.58e9 topplings as the Acer; hunt: 10,000 soups in 4.6 s, the Acer's exact counts). Quit with Cmd+Q and with the red button: exit 0, no crash. Check 9: the Dock and menu bar say `jetcarp`, lowercase. Also: export frames the tiling, not the view; an opened scene starts running at once |
| M3 | pass | Live wallpaper (icons fine), `next`, caption (lower left, not hidden), two monitors (AOC left of the laptop, each its own screen; every Space and Mission Control), battery pause, still, saver on both monitors, login (real reboot) all work; `host stop` printed no error. But: one still for both monitors (screen 0's, as on the Acer); `saver remove` leaves the deleted saver selected ("custom", blank) and open System Settings lists it until reopened; the saver animates a hidden view after it's chosen; `wallpaper off` makes windows (as on the Acer); host Dock icon is the generic "exec"; monitors named `Monitor #41041` |
| M4 | skip | Neither uv nor pipx is installed; Homebrew isn't published for candidates |
| M5 | pass | `jetcarp uninstall` showed its plan (only "forget the recorded host command" left), `--yes` did it; desktop picture is Jimmie's (same hash). Installer `--uninstall` (run by Jimmie) removed the folder and the link; `jetcarp` gone from the PATH. Left: settings, data, empty `desktop-pictures` and `library.sqlite-jobs`, a 0-byte `~/.cache/jetcarp/host.lock`, an empty `~/.local/lib` (made by the installer), the pile in `~/Pictures/JETCARP`; the screen saver selection stays the deleted JETCARP (blank "custom") |

---

## Framework (Fedora 44, GNOME 50): Jimmie, by hand, when convenient

The main session runs on this machine, and logging out of GNOME ends it. So this part is a short
checklist to do at a convenient time, in a terminal, with notes for the main session afterwards.

1. Install: `curl -LsSf https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.1/jetcarp-installer.sh | sh`.
2. `jetcarp host gnome install`, then log out and back in once.
3. `jetcarp host start`, then `jetcarp host wallpaper on`: live picture behind the desktop? A menu
   in the top bar?
4. The host's windows stay out of the Activities overview and the Alt+Tab switcher (the rewritten
   part, never tested in a real session).
5. `jetcarp host lock` with each mode, then lock the screen (Super+L) and unlock with your password.
6. `jetcarp host login on`, log out and in: did the host start by itself? Then `login off`.
7. `jetcarp uninstall`, then `jetcarp host gnome remove` if anything is left, and the installer's
   `--uninstall`. Is GNOME's own background back?

Results go in `results/rc1/framework/notes.md`, or tell the main session.
