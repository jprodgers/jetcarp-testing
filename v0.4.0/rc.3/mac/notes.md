# rc3 on the Mac: notes

System: `00-system.txt` (MacBook Pro Mac14,6, M2 Max, 64 GB; macOS 27.0.1, build 26A434; on mains,
battery 80%). Not run as root. The Mac skipped rc2, so it comes to rc3 from rc1's state.

Before install:
- rc1's settings (`app.json`, `host.json`, the empty `desktop-pictures/`) were moved from
  `~/Library/Application Support/jetcarp` to `~/Library/Application Support/jetcarp-rc1-settings/`.
  On macOS the library lives **inside** the settings folder (`jetcarp/data/library.sqlite`), so the
  `data/` folder was left in place to keep the library (rc1's 64 hunt finds, one rating, 3 job rows),
  and a copy was saved beside the moved settings as `library-rc1-backup.sqlite`. There was no
  `setup.json` (rc1 had no wizard).
- The screen saver selection still pointed at rc1's deleted `JETCARP.saver` everywhere (rc1's
  finding; `00-wallpaper-choices-before.txt`). So that M3 check 6 has a real choice to restore,
  **Jimmie chose Flurry** in System Settings (`00-wallpaper-choices-flurry.txt`: all 14 Idle
  entries name `Flurry.appex`). idleTime stays 0 (never).
- The AOC is the Framework's only monitor; Jimmie attaches it only for the M3 checks that need it.

## M1. Install — pass

Files: `01-install.txt`, `02-version.txt`, `03-paths.txt`, `04-doctor-setup-status.txt`.

Jimmie ran the plan's `curl -LsSf .../v0.4.0-rc.3/jetcarp-installer.sh | sh` (auto mode blocks
`curl | sh`). Claude read the script first: it matches the release's `SHA256SUMS`
(`1f0f0d28...e516`) and touches no shell startup files (hashes unchanged after install).

- `jetcarp --version`: `jetcarp 0.4.0-rc.3`.
- `jetcarp paths`: **`bundled: ~/.local/lib/jetcarp/packs`** (rc1 had none); the installer said
  "the starter pack is in .../packs". `setup --status` lists *JETCARP starter pack: 26 patterns,
  79 Quick Start entries, 8 ant runs, 1.5 MB*, and "setup: not run yet".
- Installed: `~/.local/lib/jetcarp` (jetcarp 59.7 MB, `libjetcarp_saver.dylib` 12.5 MB, `packs/`,
  licences), link `~/.local/bin/jetcarp`. The marker records no `made` folders, because rc1 left
  `~/.local/lib` behind (empty), so the install made nothing new around it. No quarantine marks.
- doctor: `Apple M2 Max (Metal, IntegratedGpu)`, 12 threads; host not running; saver not installed.

Small: `setup --status` says the library has "2 jobs", while its `jobs` table has 3 rows (0: a
`manual` job from rc1 still `running`, 1: the pile, 2: the hunt). The count may leave out the manual
job on purpose; noted in case "the job count includes job 0" was meant to cover it.

## M2. Setup: Desktop art, then Researcher, timed

The app was started from Claude's shell at 23:17:41 (`05-app-terminal.txt`); it opened on the
setup wizard's Welcome page (the first run, as `setup --status` said "not run yet").

### Step 1. Desktop art — pass

Files: `06-desktop-art-status.txt`.

Jimmie chose **Desktop art**, ticked only *Show a live wallpaper on the desktop*, and pressed Finish.
- **The live wallpaper is on** (Jimmie). `host status`: running (its parent is the app),
  `screen 0: A classic a day · profile Life ... · wallpaper`, `monitors: 0: Built-in Retina Display`
  (macOS's name, not rc1's `Monitor #41041`), `wallpaper: showing`.
- **Nothing imported or built**: `setup.json` says `"profile": "desktop-art"`, `"packs": []`,
  `"jobs": []`, `quickstart_minutes 0`; the library still has rc1's 64 patterns and 364 built-in
  Quick Start entries, and `jobs list` shows only rc1's two jobs.
- `host.json` was written fresh: one screen, `"monitor": null`, rotation *A classic a day*, place
  `wallpaper`.

Small, seen on the way: `jobs list` shows rc1's pile job as `pile 1: 0 grains on , step 0/0 (0
grains), 0.000e0 topplings, 0.0 s` (it was 1,000,000 grains, 11,583,796,400 topplings): rc1's pile
jobs read as empty, as the Acer saw in rc2. rc1's `manual` job 0 isn't listed ("2 job(s)").

### Step 2. Researcher, timed — pass

Files: `07-build-poll.txt` (every 10 s: CPU, memory and the build job's status lines),
`08-researcher-paths-jobs.txt`.

On the done page Jimmie pressed **Set up again** (no restart), chose **Researcher**, the new empty
folder `~/Documents/jetcarp-data` (Claude made it just before), kept the starter pack, set the
search to **10 minutes**, and pressed Start at **23:23:20**.
- **Build time: 10 min 42 s**, Start to done. The job was created 04:23:21Z and finished
  04:34:02Z (`elapsed_s` 639.25): 10 minutes of search, then about 40 s "publishing its atlas into
  the Quick Start" (1,070 entries). On time, compared with rc2's 17.5 minutes on the Acer.
- **Progress kept moving**: the log's "N of 10 min" rose by 0.15-0.2 every 10 s, never stuck.
  The run count sometimes held for 30-40 s (it moves in GPU batches of about 1,024), while the
  minutes went on rising. Jimmie couldn't watch the whole time; it was moving every time they looked.
- **`jetcarp paths` shows the new data folder** (`data: /Users/Jimmie/Documents/jetcarp-data`,
  "chosen in setup: paths.json"), and **the starter pack was imported there** (pack import 1:
  26 patterns new, 79 Quick Start entries, 8 ant runs; plus 21 imported hunt/search jobs 3-23).
- **`jobs status 2` has the *threads:* line**: "threads: 6 for runs on the processor and 4 for
  the GPU's batches, of 12 cores (2 left free)". The app peaked at about 1,040% CPU (10.4 of 12
  cores), 2.5-2.8 GB; the host on the live wallpaper used 15-35% and dropped to 0% (paused) while
  the app was at full load.

(Withdrawn: an earlier version of these notes said `setup --status` left the build out of
"setup's jobs". That was Claude's mistake: the command in `08-researcher-paths-jobs.txt` was cut
off by `head -12` just after the first job. The full output lists both jobs: `10-setup-jobs.txt`.)

### Step 3. The Quick Start, the previews, the Hunts window — pass, with one note on titles

File: `09-quickstart-library.txt` (the library's Quick Start rows after the build).

- **Sandpiles has its 39 built-ins again**: the app shows 47 entries there = 39 built-in + 8 from
  the pack (the library agrees; none hidden). The build's 17 atlas sandpiles (*Abelian sandpile*)
  aren't in that 47.
- **Langton's ant, WireWorld, Diamoeba and Rule 30 are there** (Jimmie found 2, 3, 1 and 2 by
  name; the library has the built-ins in *Ants & turmites*, *Classics* and *Fractals & rows*).
- **Atlas titles: mostly their own names** (Jimmie: "mostly, a few like *Fractal Elementary* or
  *Agents*"). In the library, all 44 elementary entries are *Rule N* and 52 of 60 agents are
  *Turmite <rule>*. But several families still give every card the same title: *Battle JACA* x60,
  *Forest fire* x59, *Fractal Layered* x56, *Fractal Hexagonal elementary* x46, *Oscillating
  Generations* x44, *WireWorld* x28 (1,070 atlas entries, 187 distinct titles). Hexagonal
  elementary has 87 entries and 3 titles, although its rules have numbers (*HexW3 5033*,
  *HexT 25*) that could name them as elementary ones now are.
- **Previews keep going from where they were**: after opening a card for a few seconds and coming
  back, the previews carried on from where they had been (Jimmie). The first time, the cards came
  back in a different order, so it couldn't be judged; that was the first return after the build
  had added its entries. On a second try the order was kept and the previews resumed.
- **Hunts window: the starter pack's hunts say *imported from pack …*** (Jimmie).

Addendum to step 3: in the Hunts window, the starter pack's hunt says *imported from pack …*, but
the window's **status section still says "0 soups"** for it (Jimmie); the job itself doesn't.

## M3. The Mac fixes

The app has been open since 23:17 (started from Claude's shell), and the host it started for
Desktop art has been showing the live wallpaper since 23:20 (pid 6128, a child of the app).

1. **Names — pass except the Dock.** The menu bar's application menu, *About* and *Quit* all say
   **JETCARP** (Jimmie). But hovering over the app in the Dock still shows **jetcarp** (lowercase),
   as in rc1: the Dock's name comes from elsewhere than the menu (a bare program, no bundle).
2. **The host's Dock icon — pass.** `host start` → "Error: the host is already running" (exit 1,
   since the app had started it); `host wallpaper on` → status, wallpaper showing
   (`10-host-start-wallpaper-on.txt`). **No second icon in the Dock** (rc1 had a generic *exec*
   icon); the host has its icon in the menu bar (Jimmie).
3. **Monitor names — pass.** With the AOC attached (00:03), `host status` says
   `monitors: 0: Built-in Retina Display, 1: Q3277` (rc1: `Monitor #41041`, `#12919`); macOS's
   System Information calls them *Color LCD* and *Q3277* (`11-host-status-two-monitors.txt`).
   The one screen (`"monitor": null`) showed as "wallpaper on every monitor".
4. **Wallpaper off — pass.** `host wallpaper off` (00:03:59): the screen became **one ordinary
   window on the laptop**, which Jimmie could drag, not covering either monitor; Jimmie's own
   desktop picture came back on both monitors. The scene restarted at the window's size (14,400
   cells, against 170,648 as wallpaper). `host stop`: "stopped", exit 0, no host process left
   (`12-host-wallpaper-off.txt`). (On Windows in rc2 it opened one full-monitor window per
   monitor.) The AOC was then given back to the Framework.
5. **The saver's hidden animation — pass (fixed).** Files: `13-saver-install.txt`,
   `14-saver-hidden-view-log.txt`.
   - `host saver install` (00:06:30) wrote `~/Library/Screen Savers/JETCARP.saver` (ad-hoc signed,
     `CFBundleName` JETCARP, 0.4.0-rc.3) and brought System Settings forward, but **JETCARP wasn't in
     its list**: that System Settings had been open since 02:05 the day before (rc1) and reads the
     Screen Savers folder only when it starts. After Jimmie quit and reopened it, JETCARP was listed.
     (`install` could say "quit System Settings first if it's open", as `remove` now does.)
   - Jimmie chose JETCARP at 00:09:28 and quit System Settings at about 00:10:27. As in rc1, macOS
     made a full-screen view ahead of time (4112 x 2658) and called `startAnimation` 0.5 s later.
     This time the saver drew **1 frame**, then: *"no frame: no screen saver is running, so nothing
     shows this view (made ahead of time); waiting for one to start"*. Its process used 0.6-0.9% CPU
     (0.64 s in all) and exited at about 00:10:50, soon after System Settings closed. rc1 drew about
     3,700 frames in the same two minutes. Jimmie saw about 1.5% in Activity Monitor.
   - **It still starts and animates when due**: `open -a ScreenSaverEngine` at 00:13:03 (the
     saver is set to never start by itself; this is what a hot corner does). The log: "macOS's screen
     saver app is running: a screen saver is showing", 100 frames in 3.3 s (about 30 fps); Jimmie
     saw it moving until a mouse click, then logged in (this Mac asks for the password at once).
     Then "macOS says the screen saver is stopping; ending this process"; one more view made ahead
     of time drew nothing and was gone 5 s later; no saver process was left.
6. **Saver remove restores your choice — pass (fixed).** `host saver remove` (00:14:20): "removed /
   put back the screen saver macOS had chosen before JETCARP was installed; System Settings, if it
   is open, may keep listing JETCARP until you quit and reopen it" (`15-saver-remove.txt`). In
   macOS's wallpaper store all 14 screen saver entries went from `JETCARP.saver` back to
   `Flurry.appex`, and the whole store is identical to how it was after Jimmie chose Flurry. System
   Settings, reopened, shows **Flurry** selected and no JETCARP (Jimmie).
7. **Export the view — pass.** Jimmie opened *JACA rainbow fronts (squares)*, zoomed in, and used
   both menu items (`16-export-view.png`, `16-export-world-full.png`, `16-export-png.txt`):
   - *File → Export the view as PNG…*: **2125 x 1700, the close-up the window showed** (about
     28 x 23 cells), at generation 145. rc1's single export framed the whole tiling instead.
   - *File → Export the world as PNG…*: **2400 x 1592, the whole tiling**, at generation 1090.
   - Both look right to Jimmie, and to Claude. Both carry version, generation, hash and the scene
     in iTXt chunks; each embedded scene replays to the recorded hash (`ok: generation 145 hash
     e9b5f31726b3e41e`; `ok: generation 1090 hash 7a27149159fbce5e`). Small: `jetcarp verify` on
     the PNG itself fails ("stream did not contain valid UTF-8"); it reads only scene JSON, so
     checking an export means extracting the scene first.

## M5. MCP with Claude Desktop — pass, with one finding on the tutorial's first prompt

Done before M4, as the plan says. Files: `mcp-session.md` (trimmed transcript),
`17-mcp-brians-brain.png`, `18-mcp-hunt.txt`.

1. **Connecting.** Claude Code backed up `claude_desktop_config.json` and added the tutorial's
   entry (`"command": "jetcarp", "args": ["mcp"]`) with Claude Desktop closed. **The bare `jetcarp`
   works**: Claude Desktop 5.1231.2 passes the login shell's PATH and started
   `~/.local/bin/jetcarp mcp` (21 tools). The book's *Settings → Developer → Edit Config* is out of
   date for this version: Jimmie found the server under *Settings → Customize*.
2. **Brian's Brain "and show me": pass, after naming the tools.** With the tutorial's prompt as
   written, **the model wrote its own simulation in an artifact and called no JETCARP tool** (the
   server log has no `tools/call`). Asked again with "Use the JETCARP tools to …" (JETCARP switched
   on in the chat's tools menu), **the picture appeared in the conversation**, and the model saved
   it unasked (`~/Pictures/JETCARP/brians_brain_120x80_gen200.png`, 960 x 640): **generation 200,
   hash `c38568895709dcc6`, 690 live: the tutorial's exactly**.
   **20,000 Life soups: every count matches the tutorial** (430,384 objects; ships 38,188, osc
   124,582, still 267,614; 50 distinct, 50 new; 19,892 settled, 52 died, 56 exploded; glider
   38,120, LWSS 51, MWSS 13, HWSS 4), as on the Acer. 2,087 soups/s. The model read
   `help {"topic": "searches"}` first and followed its example.
3. **AI control: pass.** With *Allow AI control* ticked, `use_app` attached, and **the app's window
   changed to Brian's Brain 120 x 80, shown in the app's command log** (Jimmie). The model saved the
   app's scene before replacing it (`~/Pictures/JETCARP/jaca_rainbow_fronts_before_brians_brain.json`,
   a replay that verifies: `ok: generation 15286 hash 07ee9deacc16f6b4`).
4. Afterwards: AI control off (the token file `~/.cache/jetcarp/app-endpoint.json` was removed);
   Claude Desktop quit, leaving no `jetcarp mcp` process; JETCARP removed from the config, which is
   identical to before.

## M4. Uninstall — pass

Files: `19-uninstall.txt`, `20-installer-uninstall.txt`, `21-leftovers.txt`.

Jimmie quit the app first (Cmd+Q, 00:41:35, exit 0 after a 1 h 24 min session with GPU builds,
the live wallpaper host and AI control; no crash report).
- **No `library.sqlite-wal` with data**: the Researcher library's WAL was 0 bytes right after the
  app quit (main file written at 00:41), and the default library's too. (rc2 on the Acer left
  5.5 MB.) The 32 KB `-shm` files stay beside them.
- **`jetcarp uninstall --yes`** (auto mode didn't block it here): removed rc1's stale 0-byte
  `~/.cache/jetcarp/host.lock` (and the folder, now empty), the empty job-locks folder, and the
  recorded host command; **"Kept the data folder … add --data to delete it" and "Kept the settings
  folder ~/Library/Application Support/jetcarp; add --settings to delete it"**; pictures are never
  deleted; then the ways to remove the program, the installer's `--uninstall` first.
- **The installer's `--uninstall`** (Jimmie ran `curl … | sh -s -- --uninstall`): removed
  `~/.local/bin/jetcarp` and `~/.local/lib/jetcarp`; "your settings, data and pictures are kept".
- **Left** (`21-leftovers.txt`):
  - `~/Library/Application Support/jetcarp`: the settings (app.json, host.json, `paths.json`
    naming the deleted Researcher folder, setup.json, `wallpaper-store-before-saver-remove.plist`)
    and `data/` with rc1's library, kept on purpose.
  - `~/Pictures/JETCARP`: rc1's pile, M5's picture and saved scene, kept on purpose.
  - `~/.local/lib`: an **empty folder rc1's installer made**. rc3's installer found it there, so
    it didn't record it as its own and rightly left it.
  - Gone: `~/.cache/jetcarp`, `~/Library/Caches/jetcarp` (never made), the saver, any LaunchAgent.
- The wallpaper store is identical to before the saver test (Jimmie's picture; Flurry as the
  saver). The Researcher data folder was moved to the Trash by hand.

Small: once the Researcher folder is deleted, the kept `paths.json` points at a folder that's gone;
a later JETCARP would start with that data folder missing (rc2's plan chose the default folder
again before uninstalling; rc3's didn't).
