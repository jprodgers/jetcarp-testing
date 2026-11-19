# Release candidate 2 (v0.4.0-rc.2)

**What this wave tests:** the new first-run setup wizard and its profiles, the starter pack, the
MCP server with a real AI client, and the rc1 findings fixed since. It is shorter than rc1: the
desktop features that passed in rc1 are rechecked only where something was fixed.

**The release:** https://github.com/jprodgers/jetcarp/releases/tag/v0.4.0-rc.2 (a public
pre-release). Its notes list every file, and the changelog's 0.4.0 section lists what's in it.

Same method as rc1:
- record each step as **pass**, **fail** or **skip**, with a note, in your machine's table;
- save outputs and screenshots to `results/rc2/<machine>/`;
- commit and push after each section;
- ask Jimmie each "Check" one at a time, and say before anything changes the desktop.

Record the system first, as in rc1.

**Before installing,** remove rc1's leftovers so the wizard sees a first run. Move the settings
folder aside rather than deleting it, and note where it went:
- Windows: `%APPDATA%\jetcarp`
- macOS: `~/Library/Application Support/jetcarp`

---

## Acer (Windows 11)

### A1. Install, and the PATH

1. Save the user PATH as it is now:
   `(Get-Item HKCU:\Environment).GetValue("Path", $null, "DoNotExpandEnvironmentNames") | Out-File results\rc2\acer\00-path-before.txt`
   and its type: `(Get-Item HKCU:\Environment).GetValueKind("Path")`.
2. Install rc2:
   `powershell -ExecutionPolicy Bypass -c "irm https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.2/jetcarp-installer.ps1 | iex"`
3. Save the PATH and its type again.

Checks:
1. The type is still `ExpandString`, every `%VAR%` entry (`%PNPM_HOME%\bin`) is still written
   that way, and the only change is the new JETCARP entry at the end.
2. In a new terminal, `jetcarp --version` says `0.4.0-rc.2`, and `jetcarp paths` shows `bundled:`
   with the starter pack.
3. Right-click `%LOCALAPPDATA%\Programs\jetcarp\jetcarp.exe` → *Properties* → *Details*: product
   name JETCARP, version 0.4.0, company Jimmie Rodgers. Check `jetcarpw.exe` too.

### A2. The setup wizard (Explorer)

Start the app with `jetcarp`. The wizard should open on its own.

Checks:
1. Read every page aloud to Jimmie, or show it. Does anything read oddly or look wrong?
2. Choose **Explorer**, keep the starter pack, keep the 10-minute search, and Start. Do the
   progress bars move? Does *Continue in the background* let you use the app while the search
   runs?
3. **Timing:** note when Start was pressed and when the search said it was done. Compare it with
   the wizard's estimate.
4. After it finishes, the Quick Start menu has three kinds of entries:
   - the featured built-ins first;
   - the starter pack's entries in their categories (ships, oscillators, ant highways, sandpiles,
     atlas pictures);
   - the search's own atlas entries.
   Open three starter-pack entries (a ship, a highway, an atlas picture): does each run?
5. *Help → Setup…* reopens the wizard. Close it with *Later*.

### A3. The rc1 fixes

1. **Crash on close.** Use the app for a few minutes, including the GPU (a large sandpile on the
   GPU), then close it with the X. Repeat three times. Any 0xC0000005 in the Application event log
   (Event Viewer → Windows Logs → Application, source "Application Error")?
2. **Pause state.** Run a world, pause it: do the status bar and the menu bar both say paused?
3. **Opening a scene.** Save a scene, then *File → Open scene…* on it: does it open paused, at the
   generation it was saved at?
4. **The window's place.** Is the app's window fully above the taskbar on first launch? Move and
   resize it, close the app, and open it again: is the window where you left it?
5. **The Quick Start order.** Go into an entry and back: is the Featured order the same as before?
   (*Shuffle* should still change it.)
6. **The badge.** Built-in cards say "Built-in", not "Classics".
7. **The caption.** `jetcarp host start`, `jetcarp host wallpaper on`, `jetcarp host caption on`:
   is the caption fully visible above the taskbar?
8. **One still per monitor.** With the external monitor attached:
   `jetcarp host wallpaper on --screen 0 --monitor 0`,
   `jetcarp host wallpaper on --screen 1 --monitor 1 --rotation "Classics, hourly"`,
   `jetcarp host still on`, `jetcarp host stop`.
   Does each monitor keep a still of its own screen? Then `jetcarp host still off`: is your own
   wallpaper back on both?
9. **`saver remove` with the dialog open.** `jetcarp host saver install` (the Screen Saver Settings
   dialog opens), then, with the dialog still open, `jetcarp host saver remove`.
   Expected: a clear message to close the dialog, with nothing changed. Close the dialog, run
   remove again: removed?
10. **`host start` in a pipe.** In Git Bash: `jetcarp host start | tee host.txt`. Does the command
    return at once? Then `jetcarp host stop`.
11. **`host status`.** It now says each screen's monitor, the caption, and why it is paused, if it
    is.
12. **Login after `wallpaper off`.** `jetcarp host wallpaper off`, `jetcarp host login on`,
    reboot. Expected: no windows open at sign-in, and the host is in the tray. Then
    `jetcarp host login off`.

### A4. MCP with Claude Code

Only if Claude Code is installed here (it is: this session runs in it). In a separate terminal:

1. `claude mcp add jetcarp -- jetcarp mcp`, then start a new Claude Code session.
2. Ask it to follow tutorial 6, *Driving JETCARP from an AI assistant*: make a Brian's Brain world,
   run it, render a picture, run a short hunt, and read the finds.
3. Checks: did every tool call work? Did anything confuse it? Save the conversation's tool calls
   and answers (trimmed) to `results/rc2/acer/mcp-session.md`.
4. `claude mcp remove jetcarp`.

### A5. Uninstall

As in rc1 A5:
- `jetcarp uninstall --yes`;
- the installer's `-Uninstall`;
- the PATH check again (type and `%VAR%` entries as before install);
- what is left.

### Acer results

| Step | Result | Note |
|---|---|---|
| A1 | fail (step 2) | **Defender blocks the plan's `irm \| iex` line** as `Trojan:Win32/Commando.B!ml` / `.C!ml` (the command line, cloud ML); nothing installed. The same script run as a file (`-File`) installed fine, no alert, 21 s. Checks 1-3 pass: PATH stays ExpandString with `%PNPM_HOME%\bin`, only the new entry added (after an empty `;;`); `0.4.0-rc.2`, `bundled:` with the starter pack (26 patterns, 79 Quick Start entries); version resources right on both exes. See `results/rc2/acer/notes.md` |
| A2 | pass except check 5 | Wizard opened by itself; pages fine; starter pack imported in 2 s. **The build took 17.5 min against "about 11"**: one search step ran 12 min (a slow CPU round; progress frozen at "4.3 of 10 min", 10.5 of 12 cores busy, laptop sluggish). 879 atlas entries. Starter-pack ship, highway and atlas picture run. Featured order mixes built-ins with atlas/pack entries (by design); **57 built-ins hidden** (dedupe by rule only: 34 sandpiles, Langton's ant, WireWorld…). **Help → Setup… shows the done page with only Close** for the rest of the session (no Later, no new profile). rc1's pile jobs read as empty |
| A3 | pass | No crash on close (3 GPU sessions, exit 0); pause shown in both bars; scenes open paused at their generation; window place and maximised state kept; Quick Start order kept (previews restart, so it looks different), Shuffle works; "Built-in" badge; caption above the taskbar; one still per monitor (but `WallPaper` now names the cached copy); `saver remove` refuses clearly with the dialog open, then removes; `host start \| tee` returns in 0.7 s; status names monitors, caption, "paused: on battery". Login after `wallpaper off` (real reboot): nothing opened, host in the tray; the tray's *Show on the desktop* brought the live wallpaper back on both monitors; `login off` and `host stop` clean, own wallpaper back. But `wallpaper off` itself still opens full-monitor windows at once |
| A4 | pass, one finding | Claude Code 2.1.317, tutorial 6's prompts (`mcp-session.md`): 9 JETCARP calls, all worked first time, nothing confused it. **Brian's Brain hash `c38568895709dcc6` and the 20,000-soup counts match the tutorial exactly.** `search_start` with `wait_s` returned at the end (13 s). **The user never saw the picture**: no `save_path`, and Claude Code's terminal doesn't show a tool's image, though the answer said "the picture above" |
| A5 | pass | Auto mode blocked `uninstall --yes`, so Jimmie ran both steps. `jetcarp uninstall --yes` forgot the host command and kept settings and data; the installer's `-Uninstall` (as a file) removed the folder and the PATH entry. **PATH stays ExpandString with `%PNPM_HOME%in`**, equal to before install except the trailing `;`. Wallpaper and screen saver settings as before; `jetcarp` not found. Still from rc1: the Windows hint says `--uninstall`, settings folder not mentioned, stale 0-byte `host.lock`. New: `library.sqlite-wal` (5.5 MB) left behind, so the main file lacks the last hour's writes |

---

## Mac (macOS 27)

**Skipped:** the Mac runs `rc3.md` instead, which carries the steps below that still matter.

### M1. Install

`curl -LsSf https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.2/jetcarp-installer.sh | sh`
(Jimmie runs it; auto mode blocks `curl | sh`.)

Checks: `jetcarp --version` says 0.4.0-rc.2, and `jetcarp paths` shows `bundled:` with the
starter pack.

### M2. The setup wizard (Desktop art, then Researcher)

1. Start `jetcarp`. On the profile page choose **Desktop art**. On the desktop page tick *Show a
   live wallpaper on the desktop* only. Finish.
   Checks: is the live wallpaper on? Nothing was imported or built (`jetcarp setup --status`)?
2. **Quit JETCARP and start it again first.** In rc2, *Help → Setup…* in the same session as
   a finished setup shows only the done page (found on the Acer; fixed for rc3). Then
   *Help → Setup…*; choose **Researcher**. Choose a data folder on the desktop or in
   Documents (a new empty folder, for example `~/Documents/jetcarp-data`), keep the starter pack,
   set the search to 5 minutes, Start.
   Checks:
   - does `jetcarp paths` show the new data folder?
   - did the starter pack import there?
   - how long did the 5-minute search take? rc2 was built just before the fix that makes a
     build end on time (the Acer's 10-minute build took 17.5), so an overrun is expected here.
     Note the time, and whether the progress line froze. rc3 re-times it.
3. The Quick Start menu: as A2 check 4.

### M3. The rc1 fixes on the Mac

1. **One still per screen.** As A3 check 8, with the AOC attached. Does each display keep a still
   of its own screen?
2. **Pause state**, **opening a scene**, the **window's place** and the **Quick Start order**: as
   A3 checks 2–5.
3. Not in rc2 (they come in rc3, with a short wave of their own): the host's Dock icon, monitor
   names, `saver remove` restoring your earlier choice, and the saver's hidden animation. Skip them.
4. **Login after `wallpaper off`:** as A3 check 12 (log out and in, or reboot).

### M4. MCP with Claude Desktop

If Claude Desktop is installed:

1. Add JETCARP to its configuration as tutorial 6 shows (*Settings → Developer → Edit Config*,
   with `jetcarp` and `mcp` as the command and argument), and restart Claude Desktop.
2. Ask it to do the same session as A4.
3. **AI control:** open the JETCARP app, turn on *Tools → AI control…*, and ask Claude Desktop to
   change the world shown in the app (`use_app`, `app_display`).
4. Save a trimmed transcript to `results/rc2/mac/mcp-session.md`. Remove JETCARP from the config
   afterwards.

### M5. Uninstall

As in rc1 M5, plus:
- choose the default data folder again (`jetcarp setup --data-dir default`, or the wizard)
  before uninstalling;
- delete the Researcher data folder by hand.

### Mac results

| Step | Result | Note |
|---|---|---|
| M1 | | |
| M2 | | |
| M3 | | |
| M4 | | |
| M5 | | |
