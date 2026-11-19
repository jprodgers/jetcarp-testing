# Release candidate 3 (v0.4.0-rc.3)

**What this wave tests:** the fixes made since rc2, and a Quick Start build that ends on time. It is
short: each machine checks only what changed for it. If everything passes, the next build is the
final v0.4.0.

**The release:** https://github.com/jprodgers/jetcarp/releases/tag/v0.4.0-rc.3 (a public
pre-release).

Same method as before:
- record each step as **pass**, **fail** or **skip**, with a note, in your machine's table;
- save outputs and screenshots to `results/rc3/<machine>/`;
- commit and push after each section;
- ask Jimmie each "Check" one at a time, and say before anything changes the desktop.

**Before installing,** move the settings folder aside again so the wizard sees a first run, and
note where it went:
- Windows: `%APPDATA%\jetcarp`
- macOS: `~/Library/Application Support/jetcarp`

Keep the library: it still has rc1's and rc2's entries.

---

## Acer (Windows 11)

### A1. Install with the documented command

Use the README's Windows lines, which save the installer and then run it as a file:

    Invoke-WebRequest https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.3/jetcarp-installer.ps1 -OutFile jetcarp-installer.ps1
    powershell -ExecutionPolicy Bypass -File .\jetcarp-installer.ps1

(The README names `releases/latest`, which is still rc2's until the final.)

Checks:
1. Is there any Defender or SmartScreen alert? (rc2's `irm | iex` raised one; the file form didn't.)
2. Is the user PATH still ExpandString, with `%PNPM_HOME%\bin` and **no empty `;;` entry**?
3. Does `jetcarp --version` say `0.4.0-rc.3`?

### A2. Setup, timed

1. Start `jetcarp`; choose **Explorer**; keep the starter pack and the 10-minute search; Start.
   Write down the time Start was pressed. Leave the build alone (no worlds running).
   Checks:
   - How long did the build take, from Start to *done* (the wizard's estimate is "about 11
     minutes")?
   - Did the progress line keep moving, or did it stop for more than a few seconds?
   - Was the laptop usable during the build? Note the app's CPU use (Task Manager) a few times:
     the search now leaves two cores free.
   - Afterwards, `jetcarp jobs status <the build's job>`: does it have a *threads:* line, ending
     "(2 left free)"? (Use the job number `jetcarp jobs list` gives.)
2. On the done page, press **Set up again**. Does it go back to the Welcome page? Press *Later*.
3. *Help → Setup…*: does it open on Welcome? Close it.
4. The Quick Start:
   - does the *Sandpiles* category have its 39 built-ins again (rc2 showed 16 entries in all)?
   - are *Langton's ant*, *WireWorld*, *Diamoeba* and *Rule 30* there?
   - do atlas cards read like *Rule 150* and *Ant RRL* rather than many *Fractal Elementary* and
     *Agents*?
5. Open a card, run it for a few seconds, and go back. Are the previews still running where they
   were, rather than starting over?
6. *Tools → Hunts…*: pick one of the starter pack's hunts. Does it say it was *imported from pack
   …*, with no "runs until stopped" or "0 soups"?

### A3. The desktop fixes

1. `jetcarp host start`. Its reply: does any screen say *(not connected)* with the monitors
   attached?
2. `jetcarp host wallpaper on`, then `jetcarp host wallpaper off`. Are the screens now ordinary
   windows (about 1280 by 720, movable) instead of covering each monitor and the taskbar?
   `jetcarp host stop`.
3. In the app, *File → Export the view as PNG…*: does the picture show what the window shows?
   And *File → Export the world as PNG…*: the whole tiling?

### A4. Uninstall

1. `jetcarp uninstall --yes`, then the installer's `-Uninstall` as a file:
   `powershell -ExecutionPolicy Bypass -File .\jetcarp-installer.ps1 -Uninstall`.
2. Checks:
   - does `jetcarp uninstall` say it kept the settings folder, and name `-Uninstall` (not
     `--uninstall`) for the installer?
   - is anything left (`%LOCALAPPDATA%\Programs\jetcarp`, a 0-byte `host.lock`, empty folders)?
   - with the app closed, is `%LOCALAPPDATA%\jetcarp\library.sqlite-wal` gone or 0 bytes (rc2 left
     5.5 MB in it)?
   - is the PATH as before install?
3. After the wave, ask Jimmie about removing Defender's *Allow* for `Commando.C!ml`.

### Acer results

| Step | Result | Note |
|---|---|---|
| A1 | pass | No Defender or SmartScreen alert with the README's two lines (Jimmie ran them; the saved file matched SHA256SUMS; Defender's history has only rc2's detections). PATH: still ExpandString with `%PNPM_HOME%\bin`, **no `;;`**: the trailing `;` (put back first with Jimmie's OK, so this was a real test) was trimmed before the folder was added. `jetcarp 0.4.0-rc.3`; `bundled:` shows the starter pack. rc2's settings moved to `%APPDATA%\jetcarp-rc2-settings`. Details in `results/rc3/acer/notes.md` |
| A2 | pass, with findings | **11 min 11 s** Start to done (estimate "about 11 minutes"; rc2 17.5): 10 min search + 64 s publishing 900 atlas entries. Progress kept moving (minutes rose every 10 s; runs move in batches of 1,024). Laptop usable (Jimmie); 6.8 of 12 cores on average, peak 10.6 while publishing. *threads:* "(2 left free)". Set up again → Welcome; Help → Setup… → Welcome. Sandpiles 39 built-ins; the four classics there. Previews carry on. Hunts: *imported from pack*, no "0 soups" in the detail. **Findings:** the new entries appear only after opening a world and coming back (the done page says they're in); rc2's 879 atlas entries keep their old titles beside rc3's 900, so "still many generic" (rc3's own repeat some, as on the Mac); the imported hunt's list row still says "0 soups", "0 s run", empty *What* |
| A3 | pass | 1: after binding the screens to monitors 0 and 1 (rc2's case), `host start`'s reply says "wallpaper on monitor 0/1", **no "(not connected)"**. 2: `wallpaper off` → two ordinary windows, 1280x720 client, title bar, resizable, not topmost, inside each monitor's work area; Jimmie dragged them, taskbar and wallpaper visible. `host stop` clean. 3: *Export the view* = the window's world area exactly (1062x850; only the outlines' anti-aliasing differs); *Export the world* = the whole tiling (2400x2393); both embed the scene, `verify` ok (gen 104, `4e506491ab27b935`) |
| A4 | pass | App closed with exit 0 (40-min GPU session). `uninstall --yes` (Jimmie ran it) **names the kept settings folder** and data folder, says **`-Uninstall`**, and removed rc1's stale 0-byte `host.lock` and the empty job-locks folder; the installer's `-Uninstall` as a file removed the program. Left: settings, library, pictures (on purpose); **no `host.lock`, no empty folders**; **`library.sqlite-wal` 0 bytes** with the app closed. PATH: ExpandString with `%PNPM_HOME%\bin`, no JETCARP entry; equal to before install except the trailing `;` the install trimmed |

---

## Mac (macOS 27)

The Mac skipped rc2, so this section also carries rc2's Mac-only steps (Desktop art, a second
setup with its own data folder, and MCP with Claude Desktop). If usage runs short, M3 and M4
matter most; M5 is optional.

### M1. Install

`curl -LsSf https://github.com/jprodgers/jetcarp/releases/download/v0.4.0-rc.3/jetcarp-installer.sh | sh`
(Jimmie runs it; auto mode blocks `curl | sh`.)

Checks: `jetcarp --version` says 0.4.0-rc.3, and `jetcarp paths` shows `bundled:` with the starter
pack.

### M2. Setup: Desktop art, then Researcher, timed

1. Start `jetcarp`; choose **Desktop art**; on the desktop page tick *Show a live wallpaper on the
   desktop* only; Finish. Checks: is the live wallpaper on? Nothing imported or built
   (`jetcarp setup --status`)?
2. On the done page press **Set up again** (no restart needed in rc3). Choose **Researcher**, a new
   empty data folder (for example `~/Documents/jetcarp-data`), keep the starter pack, set the
   search to **10 minutes**, Start, and leave it alone. Checks:
   - how long from Start to *done*? Did the progress line keep moving?
   - does `jetcarp paths` show the new data folder, with the starter pack imported there?
   - `jetcarp jobs status <the build's job>`: is there a *threads:* line ending "(2 left free)"?
3. The Quick Start, the previews and the Hunts window: as A2 checks 4 to 6.

### M3. The Mac fixes

1. **Names.** Does the app show as *JETCARP* (not *jetcarp*) in the menu bar's application menu,
   About and Quit?
2. **The host's Dock icon.** `jetcarp host start`, `jetcarp host wallpaper on`: is there no
   generic *exec* icon in the Dock (the host lives in the menu bar only)?
3. **Monitor names.** With the AOC attached, does `jetcarp host status` name the screens as macOS
   does (*Built-in Retina Display*, *Q3277…*), not *Monitor #41041*?
4. **Wallpaper off.** `jetcarp host wallpaper off`: ordinary windows, not covering the screens?
   `jetcarp host stop`.
5. **The saver's hidden animation.** `jetcarp host saver install`, choose JETCARP in System
   Settings, then close System Settings. Over the next two minutes, does Activity Monitor show the
   saver busy on the GPU? (rc1: about 3,700 frames drawn unseen.) Does the saver still start and
   animate when it's due (or with a hot corner)?
6. **Saver remove restores your choice.** `jetcarp host saver remove`: does System Settings show
   the screen saver you had before (reopen it), not a blank *custom* tile?
7. **Export the view.** As A3 check 3.

### M4. Uninstall

1. `jetcarp uninstall --yes`, then the installer's `--uninstall`
   (`curl -LsSf …/v0.4.0-rc.3/jetcarp-installer.sh | sh -s -- --uninstall`; Jimmie runs it).
2. Checks: does `uninstall` say it kept the settings folder? What is left in
   `~/Library/Application Support/jetcarp`, `~/Library/Caches/jetcarp`, `~/.cache/jetcarp`,
   `~/.local/lib`, `~/Pictures/JETCARP`, `~/Library/LaunchAgents`, `~/Library/Screen Savers`? Is
   there no `library.sqlite-wal` with data in it? Delete the Researcher data folder by hand.

### M5. MCP with Claude Desktop (optional)

If Claude Desktop is installed and usage allows, do this before M4:
1. Add JETCARP as tutorial 6 shows (*Settings → Developer → Edit Config*, command `jetcarp`,
   argument `mcp`); restart Claude Desktop.
2. Ask for tutorial 6's session: Brian's Brain 120 by 80 for 200 generations "and show me" (does the
   picture appear in the conversation? hash `c38568895709dcc6`), then 20,000 Life soups and their
   spaceships.
3. **AI control:** open the app, turn on *Tools → AI control…*, and ask Claude Desktop to change the
   world the app shows.
4. Save a trimmed transcript to `results/rc3/mac/mcp-session.md`; remove JETCARP from the config.

### Mac results

| Step | Result | Note |
|---|---|---|
| M1 | pass | `jetcarp 0.4.0-rc.3`; `paths` shows `bundled: ~/.local/lib/jetcarp/packs` (starter pack: 26 patterns, 79 Quick Start entries). Jimmie ran the install line (auto mode blocks `curl \| sh`); script matched SHA256SUMS, startup files unchanged. rc1's settings moved to `~/Library/Application Support/jetcarp-rc1-settings` (the library stays in `jetcarp/data`); Flurry chosen as the saver for M3 check 6. Details in `results/rc3/mac/notes.md` |
| M2 | pass | Desktop art: live wallpaper on, nothing imported or built. **Set up again** works without a restart. Researcher into `~/Documents/jetcarp-data`, 10-min search: **10 min 42 s** Start to done (10 min search + 40 s publishing 1,070 atlas entries); progress kept moving; `paths` shows the new folder with the starter pack imported; *threads:* line "(2 left free)", app peak 10.4 of 12 cores. Quick Start: Sandpiles 47 (39 built-in + 8 pack); the four classics there; atlas titles mostly named (*Rule N*, *Turmite …*) but some families still repeat one title (*Battle JACA* x60, *Forest fire* x59, *Fractal Layered* x56, *Fractal Hexagonal elementary* x46); previews resume where they were; Hunts says *imported from pack* |
| M3 | pass except the Dock name | 1: menu bar, About and Quit say **JETCARP**, but the Dock tooltip still says *jetcarp*. 2: no host icon in the Dock; menu bar icon only. 3: `host status` names `Built-in Retina Display` and `Q3277`. 4: `wallpaper off` gives one ordinary, movable window; own wallpaper back. 5: the saver drew **1 frame** after being chosen (rc1: about 3,700) and waited; it still starts and animates (about 30 fps) when started. System Settings, open since rc1, didn't list the new saver until reopened. 6: `saver remove` put **Flurry** back (store identical to before). 7: view export = the window's close-up; world export = whole tiling; embedded scenes verify |
| M4 | pass | App quit cleanly; **`library.sqlite-wal` 0 bytes** in both libraries. `uninstall --yes` removed rc1's stale `host.lock` and **named both kept folders** (data and settings); installer `--uninstall` removed the program and link. Left on purpose: settings + rc1 library, pictures. Also left: the empty `~/.local/lib` that rc1's installer made (rc3's rightly didn't claim it). Wallpaper and saver choices as before; Researcher folder moved to the Trash |
| M5 | pass, one finding | Bare `jetcarp` command works in Claude Desktop 5.1231.2 (servers are under *Settings → Customize* now, not *Developer*). **The tutorial's prompt as written got an artifact simulation, no tool call**; with "Use the JETCARP tools to …" the picture showed in the chat and was saved, hash `c38568895709dcc6` exactly. 20,000 soups: every count matches the tutorial. AI control: the app's window changed, in its command log; the model saved the old scene first. Config restored. Transcript: `results/rc3/mac/mcp-session.md` |
