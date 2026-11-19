# v0.4.2-rc.4 on the Mac

MacBook Pro M2 Max, macOS 27.2.1, on mains, the built-in display only. The wave in `v0.4.2-rc.4.md` ("The wave"), from
NOTES 2026-11-16 (9:50 PM EST). The pre-release `v0.4.2-rc.4` (cf5cbdf), published 9:48 PM EST.

- **Downloads** (`~/jetcarp-rc4/dl/`): rc.4's and rc.3's macOS archives (aarch64) and installers, each checked against
  its release's `SHA256SUMS`: OK.
- **Folders:** the upgrade (#99) and the app rows run in the default folders, as the plan allows on the laptops. Parity
  and the scripted rows run the release archive's own `jetcarp` (unpacked in `~/jetcarp-rc4/rel`; the same sha256 as
  the installed one), each in a test folder of its own, `~/jetcarp-rc4/homes/<row>`, with every `JETCARP_*` folder
  variable set (`R4-scripts/lib.sh`, adapted from the Framework's R4 scripts). rc.3's `~/jetcarp-rc-042c` is used only
  for #112's saved sizes, the rc.3 control of #104 and the private row's publisher key.

## 0. Upgrade from rc.3 to rc.4 (#99)

Nothing of JETCARP's was installed (rc.3 was removed before M-8, as Jimmie asked), so rc.3 went back first, the way a
tester has it (`0-upgrade.txt`):
- `sh jetcarp-installer.sh` (rc.3's own): "installed jetcarp 0.4.2-rc.3 in ~/.local/lib/jetcarp", "linked
  ~/.local/bin/jetcarp"; `which jetcarp` is that link.
- `host wallpaper on` ("saved; the host is not running"), `host start` (pid 72762, "A classic a day"), `host login on`
  (`"~/.local/bin/jetcarp" host serve --login starts at login`). As in rc.3, launchd doesn't load the job until the next
  login (`launchctl print` exit 113).
- **Logout 1** (Jimmie, 10:01 PM): launchd started rc.3's host at login (22:01:46, parent launchd; `managed LWCR | has
  LWCR`). That's a tester's Mac under rc.3.
- **rc.4's installer** (`sh jetcarp-installer.sh`, rc.4's own): "installed jetcarp 0.4.2-rc.4 in ~/.local/lib/jetcarp",
  `--version` 0.4.2-rc.4. It swaps the folder, so rc.3's host ran on from the old file (`~/.local/lib/jetcarp.old.73910`,
  deleted). The settings folder held only `host.json` and `host-program`: no answer to the seizure warning.
- **The app opened once** (`jetcarp`, from here, its stderr in `0-app-first.log`): at once "JETCARP: registered the
  login item with launchd, for JETCARP 0.4.2-rc.4", and launchd restarted the host as rc.4 (pid 74008). The plist
  carries `<!-- Registered with launchd by JETCARP 0.4.2-rc.4 -->`; `plutil -lint` OK.
  - **The new host waited for the warning (#96):** `host status`: "held", generation 0, "waiting: the photosensitive
    seizure warning has not been accepted (open the JETCARP app, or run `jetcarp setup`, to read and answer it); the
    scenes start once it has been". Its window was still: the dark background and the turmite's first cell
    (`0-host-waiting.jpg`).
  - Jimmie: the warning came first; answered "no epilepsy or seizure disorder"; then setup (the defaults: "Blank
    slate"); then quit with ⌘Q. `photosensitivity.json`: `no_disorder`, 03:05:39 UTC, 0.4.2-rc.4, `via: app`.
  - **The same host then ran its scenes** (pid 74008, not restarted): "note: the photosensitive seizure warning has been
    accepted; the scenes run", 240 generations a second. Jimmie: "desktop is animating now".
- **Logout 2** (Jimmie, 10:09 PM, the app closed): **the host came back at login as rc.4** (22:09:36, parent launchd,
  `runs = 1`, `managed LWCR | has LWCR`), its scenes running. No new crash report (the only one is rc.3's 3.2, 08:33),
  and nothing about code signing or launch constraints in the log. rc.3's 3.2 failure (the first login after an
  upgrade killed the host) is gone. **#99's upgrade: pass.**

## R4 #96: the seizure warning: pass

**The command line and MCP** (`96-cli.sh`, `96-cli.txt`), in a fresh settings folder `~/jetcarp-rc4/w96`:
- Before the answer, each refused with exit 1, naming what it won't do and printing the whole warning and how to answer
  it: `host start` ("won't start the background host"), `host wallpaper on` ("won't show the desktop background"),
  `host login on` ("won't start the background host at login"), `host saver install` ("won't install the screen
  saver"), `host serve --saver --seconds 3` ("jetcarp-host: … won't run the screen saver"). MCP `host_control`
  wallpaper on and login on: `isError`, "won't start or show scenes in the background host until…".
  Nothing started, registered or installed: no new host, the login item's file unchanged (md5), no screen saver.
- **The plan's `host start --saver` doesn't exist** (`unexpected argument '--saver'`, exit 2); the saver is `host serve
  --saver`, refused as above.
- `setup --seizure-warning no-disorder`: "saved your answer…", and `photosensitivity.json` holds `version` 1, `answer`
  `no_disorder`, `date`, `jetcarp` 0.4.2-rc.4, `via` `setup`.
- Then each worked: `wallpaper on` (saved), `host start` (a host), `login on` (registered), `saver install` (written to
  `~/Library/Screen Savers/JETCARP.saver`), `host serve --saver --seconds 3` (ran, exit 0), MCP wallpaper on and login on
  (no error). Undone: `saver remove`, `host stop`.
- **Side effects of testing from a second folder** (not a tester's case): the script ran the program by its full path,
  so `login on` pointed the one login item at `~/.local/lib/jetcarp/jetcarp`, and launchd restarted the default host
  from there, though the message said "the host already running carries on" (it judged by the test folder's host).
  MCP's `login on` then rewrote the file without the "Registered with launchd" comment: by design, the host's own
  login switch (tray, MCP) only writes the file, and the next app open or `host start` registers it
  (`autostart::set`). Put back with `jetcarp host login on` from the default folders: the link, the comment,
  "registered with launchd, which restarted the host".

**The app**, opened with a fresh settings folder (`~/jetcarp-rc4/w96app`), Jimmie at the window:
- The warning came first, before setup. "May have a seizure disorder" offered **Quit first, then Continue at my own
  risk**; **Quit quit the app** (its process gone). It wrote only `app.json` (the window): no answer, no setup, and the
  login item untouched.
- The upgrade above showed the rest in the default folders: the warning before setup, and the host held still until it
  was answered.

## R4, the unattended rows (2026-11-17, from 3:01 AM EST)

Jimmie was away from the Mac; the hands-on rows wait for them. The default host was stopped for these (below), so the
Mac was quiet. One script and one output file a row, in `R4-scripts/`.

### #99, login off with the host stopped: pass (`99-login-off-stopped.txt`)

- Before: launchd's job running the default host (pid 75667, `~/.local/bin/jetcarp host serve --login`, `RunAtLoad`).
- `jetcarp host stop`: "stopped"; launchd: "state = not running", "job state = exited".
- `jetcarp host login off`: "the host no longer starts at login". **`launchctl print` exits 113 at once** ("Could not
  find service"), and the plist is gone. Still 113 five seconds later, and no host started.
- Left: login off with the host running (the job goes at the next logout: logout 3, with Jimmie), and `jetcarp
  uninstall` stopping the host first (at the end, with #103). Login stays off, and the default host stopped, until then.

### #84, doctor with the GPU off: pass (`84-85-doctor-paths.txt`)

`JETCARP_GPU=off jetcarp doctor`: "GPU: off (JETCARP_GPU=off)"; display and compute (the M2 Max, Metal) each "not used,
and not tested: the GPU simulation is off", with no self-test line. With the GPU automatic, both say "self-test: passed
(373 ms): 59 world rules and 33 explore batches matched the CPU". (Wording only, as on the Framework: the adapters list
still stars the M2 Max, "* = used for computing", with the GPU off.)

### #85, `jetcarp paths`: pass (`84-85-doctor-paths.txt`)

`paths` and `paths --json` list the runtime folder: `$H/run` in a test folder, `~/.cache/jetcarp` in the default
folders (where `host.lock` lives).

### #112, Fit hidden: pass, the monitor change left for Jimmie (`112-fit.txt`, `112b-unplugged-screen.txt`)

- `host --help` has no tune or fit. `host tune` and `host tune --json` are refused, exit 1: "Fit to this computer isn't
  in JETCARP 0.4.2: it returns, faster, in 0.4.3. Each scene shows at its own size." (`host tune --help` and `host help
  tune` still print Fit's whole help, as on the Acer.)
- MCP: `host_control`'s actions are status, next, previous, pause, resume, rotation, wallpaper, login, open_app,
  reload, scene, quit: no tune. Called anyway, `tune`, `tune` with `pick` and `tune_stop` each get the same sentence.
- **rc.3's own `host.json` from this Mac**, copied into a test folder: screen 0 (the built-in, "Wolfram series", canvas
  4112x2658) saved Fit sizes of 12.02 to 32.02 px against each scene's own 8 px; screen 1 (the Q3277, "A classic a
  day") 2.4 to 6 px against 2 to 4 px.
- **rc.4 shows each scene at its own size**, eight scenes each way, never a saved size:
  - headless at 1280x720: 57,600 cells of 4 px; headless at 4112x2658: 682,592 cells of 4 px (scale 1);
  - on the desktop (the built-in, scale 2): **170,648 cells of 8 px**, exactly rc.3's "own" rung for that canvas (the
    saved 32 px would be 10,624 cells).
  - `host.json` wasn't rewritten (sha256 OK); rc.3's tuning is still in it, for 0.4.3.
- **Seen on the way, for 0.4.3: a screen whose monitor isn't connected still runs.** rc.3's screen 1 is bound to the
  Q3277, which isn't here. `host status`: "wallpaper on monitor 1 (not connected)", yet generation 1,508 after 50 s at
  30 a second on the GPU, 1,517 frames drawn, on a 1280x720 canvas, with no window for it (`hostwin`: only screen 0's
  desktop window is on screen). GPU work nobody sees while a monitor is away. (rc.3's 2.MM: with the host running, an
  unplugged screen moved onto the built-in; this is a host started while the monitor is away.)

### #122, start straight after stop: pass (`122-start-stop.txt`)

Ten rounds of `host start --headless; host stop` in one test folder, no pause: 10 of 10. Starts 0.18 to 0.19 s, stops
0.17 to 0.23 s; no host left.

### #80, memory is the physical footprint: pass, with an observation (`80-memory.txt`, `80b-memory.txt`)

- A 3-minute explore (`--detach`, the GPU), then the same job resumed for 3 minutes, sampled every 3 s: `jobs status`'s
  memory (`progress.rss_gb`), footprint's `phys_footprint` and `phys_footprint_peak`, and `ps`'s RSS, for the process
  running the job.
- **Each time the status's figure changed, it matched the footprint taken just before, within 2%, never the RSS:** 730
  MiB (footprint 743 to 750, RSS 610), 508 (506 to 508, RSS 628), 568 (569, RSS 690).
- **But the figure is refreshed only now and then:** three times in 2.5 minutes, while the status itself is rewritten
  every 2 to 4 s. The footprint rose to 2,031 MiB (peak 2,094) while the status said 568 MiB, and in the first pass the
  status said 1.43 GB for 90 s while the footprint was 0.8 to 0.9 GB. So the figure is the footprint as of its last
  reading, which can be a minute or more old (question 1).

### #104, progress lines in 60 columns: pass (`104-progress-60col.txt`, four `104-*.typescript`)

The Framework's check in a 60x40 pseudo-terminal (`pty60.py`: macOS's `script` needs a terminal of its own, which this
session hasn't). rc.4: a 30-second hunt (24 redraws), a 1-minute JACA explore (81) and a pack import (none): every
redraw cut to 59 columns, one row each. rc.3's build, the same hunt: 24 redraws of 89 to 193 columns, each leaving 2 to
4 rows behind. The same as the Framework.

### #92, the MCP reference (the book row's third bullet): as on the Framework (`92-mcp-reference.txt`)

The page's source at the tag escapes all 11 placeholders (`&lt;id>`, `L&lt;level>` and the rest), so the book renders
`<id>` and `L<level>` (rendered on the Framework; mdbook isn't here). `jetcarp mcp` serves the source as it is
(resources/read and `help`: the same 88,922 characters), so an MCP client reads `&lt;id>`: #126, for 0.4.3. The copy
button and `claude mcp add` wait for Jimmie.

### (private) part 4.2: pass

### #87, the app behind a covered window: pass (`87-89-app.txt`, `.json`, `.jsonl`; `t87_89_app.py`)

The Acer's script for the Mac. The app (`jetcarp --control`, test folder `homes/app87`, the warning and setup answered
there) with a 512 x 512 Life world at speed 30, `world_status` through `jetcarp mcp --app` every 2 s: 20 s in view, then
**60 s fully covered** by an opaque window of the script's (`cover`, above normal windows, 40 points beyond the app's
window on every side), then 20 s in view again.

| Phase | Polls | Answers | Speed | App CPU (median, % of a core) |
|---|---|---|---|---|
| in view | 10 | all, 0.01 s, no gap over 2.0 s | 30.1 gens/s | 46% |
| **covered, 60 s** | **32** | **all, 0.01 s, no gap over 2.1 s** | **30.0 gens/s** | **4%** |
| in view again | 8 | all | 30.0 gens/s | 46% |

The same as bf6f64f's recheck on rc.3's branch (15 gens/s, 2 to 5% covered). Minimising another app's window from a
script needs the Accessibility permission, which this session hasn't (`AXIsProcessTrusted` false; I didn't ask for
it), so Jimmie minimised it (below).

### #87, minimised (Jimmie, ⌘M and the Dock): pass; but after ⌘M and a restore the window stays frozen (#131, new in rc.4)

`t87b_minimise.py`, `t87c_restore.py`, `t87d_rc3_restore.py`: the same app and world, the phase read from the window's
on-screen flag, the window captured by its id (`screencapture -l`, only JETCARP's window).
- **Minimised: pass.** Run 2 (`87b-minimised.txt`): off screen for 88 s, 44 polls, every one answered (slowest 0.12
  s, no gap over 2.1 s), **30.0 gens/s**, the app's CPU 3% of a core (49% in view). Run 1 (38 s off screen) the same.
- **Finding: after the restore from the Dock, the window doesn't draw again.** Jimmie: "it was still". In run 2 both
  captures after the restore (8 and 10 s) were byte-identical and showed "gen 1273" in the window's toolbar, the
  generation from when it was minimised, while `world_status` said 4,018 to 4,214 (`87b-restored-*.jpg`; before
  minimising the toolbar matched, gen 537 at 540). The app's CPU stayed at 4% against 46 to 49% in view.
- **Nothing wakes it** (run 3, `87c-restore.txt`, `87cd-imgdiff.txt`): captured every 2 s for 46 s after the restore,
  Jimmie moving the mouse over the grid at +10 s, clicking the title bar at +20 s and ⌘Tab away and back at +30 s.
  The app's content never changed: the only pixels that did (3,350, x 18 to 287, y 17 to 46) are the title bar's
  active and inactive look, which macOS draws. Before minimising, 290,892 pixels changed in 2 s. The world kept 30.0
  gens/s and AI control answered throughout.
- **rc.3 draws again at once** (run 4, `87d-rc3-restore.txt`, rc.3's app in its own folder): every capture after the
  restore differed from the one before, CPU 36%. (rc.3 still stops while minimised, the original #87: no answer within
  3 s, 0% CPU. And ⌘M does nothing in rc.3, #91: Jimmie used the window's button.)
- So it is new in rc.4, most likely from #87's fix: the logic passes that keep the app going while hidden (bf6f64f
  asks for the next pass 50 ms on while the window is hidden). The app seems to go on treating the window as hidden
  after the restore. (Question 3.)
- **The main session's three checks** (NOTES 4:36 AM; `t87e_wake.py`, `87e-run5.txt`, `87e-run6.txt`,
  `87e-imgdiff.txt`):
  1. **Covering and uncovering, a click inside, a resize: none wakes it** (run 5, the world running). After the
     restore the script's cover window lay over it from +6 to +10 s; Jimmie clicked in the Scene pane's empty space at
     +20 s and dragged the corner at +30 s. Jimmie: "it never moved, even after the resize". The captures changed only
     in size while the window grew: macOS stretched the old frame, still showing "gen 1575" from before ⌘M
     (`87e-run5-after-18.jpg`), and then only the title bar's look. CPU 5%.
  2. **rc.3 draws again after a restore**: run 4 above.
  3. **Paused, a zoom and a pan after the restore don't draw either** (run 6, `app_display playing false` before ⌘M).
     Jimmie: "neither the zoom nor the pan showed". In 44 s after the restore the only change was the title bar's look
     (+14 s); CPU 0%.
  So after a restore from the Dock the window never paints again, whatever happens in it, until the app is closed.
- **The main session's confirming check** (NOTES 4:45 AM; run 7, `87e-run7.txt`): minimised with the window's **yellow
  button** instead of ⌘M, restored from the Dock: **it draws again at once** (every capture 2 s apart differed for 44
  s; CPU back to 32%; Jimmie: "it moved after the restore"). Minimised, it went on as before (30.0 gens/s, 3%). So the
  freeze is **⌘M's (#98)**: rc.4's ⌘M goes through egui's `ViewportCommand::Minimized(true)`, which sets egui's own
  flag, and on macOS egui-winit never reads it back after a restore. **Filed as #131** (milestone v0.4.2), with
  Jimmie's go.

### #89, Keep awake: pass through app_display; the menu click is Jimmie's (`87-89-app.txt`, `89b-state.txt`)

The View menu's Keep awake is the app's `keep_awake` setting, which `app_display` also sets. Twice each way:
- on: the state's `keep_awake` is `{"on": true, "held": true, "backend": "iokit"}`, and `pmset -g assertions` lists
  `pid …(jetcarp): NoDisplaySleepAssertion named: "JETCARP is showing cellular automata"`;
- off: `{"on": false, "held": false}`, and JETCARP's line is gone.

(My first script read `screensaver.settings.keep_awake`, the screensaver's own setting, as the state; `89b-state.txt`
reads the right field.) Jimmie clicks View → Keep awake once in the hands-on round, for the menu itself.

## R4, the app rows with Jimmie (2026-11-17, 4:52 to 5:20 AM EST), the default folders

The installed rc.4 (`jetcarp` from `~`), the settings Jimmie answered at the upgrade. The host was back on (`jetcarp
host login on`: "registered with launchd, which started the host").

- **#112, the Desktop background pane: pass.** Jimmie: "No Fit button, cards or limits". `112-desktop-pane.jpg`
  (JETCARP's window alone, captured by its id): Show on the desktop, Rotation, Add a screen, Frames per second, GPU
  simulation, Caption; no Fit.
- **#91 and #98, shortcuts: pass.** Jimmie: "shortcuts work": ⌘⇧H opens Quick Start, ⌃⌘F full screen and back, ⌘H the
  system's Hide. ⌘M minimises (the #87 runs, seven times), but brings #131 with it, so it wasn't used here.
- **#89, View → Keep awake: pass.** `89-menu-assertions.txt`: `NoDisplaySleepAssertion named: "JETCARP is showing
  cellular automata"` from 04:55:28, gone at 04:55:38 (Jimmie: on about 10 s, then off).
- **#114, Copy: pass.** Tools → AI control…, Allow, Copy on the `jetcarp mcp --app` row: the system clipboard got
  exactly `jetcarp mcp --app` (17 bytes, no backticks, no newline; `114-clipboard.txt`, which writes down only text
  that mentions jetcarp or is a rule). Jimmie's first press didn't register; the second did.
- **#114, the footer: pass.** Jimmie: "footer says private link", no HTTP.
- **#114, Paste: the rule gets in, but the Rule box doesn't show it** (finding, question 4). `B36/S23` copied in
  TextEdit (in the clipboard log at 05:01:48 and 05:13:29), then ⌘A and ⌘V in the CAs pane's Rule box:
  - Jimmie: "it didn't show B36/S23 until after the save happened"; and in a second try, "It didn't change until I
    pressed enter", after 5 s untouched and the mouse moved over the window.
  - Yet the pasted rule is taken: saved straight after the paste, `r90b.json` ends with `update_ca` `B36/S23`, and the
    world ran B36/S23 afterwards (`world_status`).
  - So the paste reaches the field, but the window isn't drawn again until the next key or the save. Someone pasting
    sees nothing happen.
- **#132's follow-up (the main session, 5:21 AM): a paste into Run → Jump's Generations field shows at once.** `4096`
  copied in TextEdit, ⌘A and ⌘V in the field. Jimmie: "pasting shows the text right away". So the Rule box's delay is
  its own, not egui-winit's paste on macOS.
- **#90, a typed rule before Save: pass.** `B34/S34` typed and saved at once without Enter: `r90c.json` ends with
  `update_ca` `B34/S34`; reopened in a test folder (`world_new` of the file), it runs B34/S34 at generation 8,436. The
  pasted one too: `r90b.json` reopens as B36/S23, and Jimmie's first `r90.json` as B36/S23 (`90-scenes/`,
  `90-reopen-*.jsonl`). A scene file keeps the starting rule in `cas` and each change in `commands`.
- **#90, a typed rule on leaving the window: pass.** Jimmie typed `B3/S23` and ⌘Tab away and back: the header read
  B3/S23.
- **#88, Jump: pass.** Paused at 4,340 (`world_status` through AI control), Run → Jump, Generations, 4096, Jump: **8,436**,
  exactly 4,096 on. (Jimmie's first try, earlier, "looked like it jumped"; the scene files record both jumps.)
  Jimmie had to set the grid size for Quick Start's Life, which my instructions didn't say.

## #112's monitor change, and the book rows (#100–#102), with Jimmie (5:21 to 5:36 AM EST)

- **#112, a monitor change starts no fit: pass** (`112c-monitor-change.txt`, `r4_112c_monitor.sh`). The default host
  (launchd's, pid 43936) logged every second while Jimmie changed the built-in display's resolution and back: its
  canvas went 4112x2658 → 3456x2234 (05:26:41) → 4112x2658 (05:26:55); the same process throughout, never held, no
  Fit or tune field in its status, `host.json` unchanged (the same sha256 before and after), the scene at its own
  280,000 cells. Jimmie: for about 2 s after each change the host showed the old picture cropped (smaller screen) or
  filling only part of the screen (back to full size), then re-laid itself out. Cosmetic; not a fit.
- **#100, the book's copy buttons: pass** (`100-book.txt`). The online book is still 0.4.1's (as on the Acer), so the
  tag's `docs/` was built with mdBook v0.5.4 (GitHub's macOS arm64 release, sha256 as GitHub's digest; in
  `~/jetcarp-rc4/tools/mdbook`, with Jimmie's OK) and served on 127.0.0.1:3000. Jimmie copied the first three commands
  of *Hunting for spaceships* with the copy buttons and ran them in Terminal.app (the default folders): "All three ran
  as pasted, output matches the book". Read back: 13,674 objects (ships 6,900, oscillators 5,824, still lifes 950), 20
  distinct, and ship `16bc37` (c/4 orthogonal, seen 6,900), as the page says.
- **#102, `claude mcp add --scope user`: pass** (`102-claude-mcp.txt`), with Jimmie's OK for this task. `claude mcp
  add --scope user jetcarp -- jetcarp mcp`: "Added stdio MCP server jetcarp … to user config". From three other
  folders `claude mcp list`: "jetcarp: jetcarp mcp - ✔ Connected"; `claude mcp get`: "Scope: User config (available
  in all your projects)". Then `claude mcp remove jetcarp -s user`: gone. (Only JETCARP's lines are kept.)
- #92's third bullet: above (as on the Framework; #126).

## #99's last steps and #103's uninstall, with Jimmie (5:35 to 5:38 AM EST)

- **Login off with the host running: pass** (`99-login-off-running.txt`). `jetcarp host login off`: "the host no
  longer starts at login"; the host went on (the same pid 43936, generation climbing), the plist was gone, and
  launchd still held the running job, as designed.
- **Logout 3** (Jimmie, 5:36 AM), then (`99-after-logout3.txt`): **`launchctl print` exits 113**, no plist, no host
  started; doctor: "background host: not running", "starts at login: no". Jimmie's desktop showed their own picture.
- **`jetcarp uninstall` stops the host first, so the job goes at once: pass** (`99-103-uninstall.txt`). `host login
  on` again ("registered with launchd, which started the host (pid 67214)"), then `jetcarp uninstall --yes --settings
  --data`: "done: stop the background host", "done: stop the host starting at login", the lock file, the job locks;
  `launchctl print` exit 113 straight after, no plist, no host.
- **#103, the wording: pass.**
  - `jetcarp uninstall` (no `--yes`) opens with "This undoes what JETCARP set up outside its folders. It never removes
    the program itself, and deletes its settings and data only when asked (--settings, --data)", lists what it would
    undo, and names **one** command for how it was installed: "to remove the program itself (in ~/.local/lib/jetcarp,
    installed with JETCARP's installer), run this: `curl -LsSf https://github.com/jprodgers/jetcarp/releases/latest/download/jetcarp-installer.sh | sh -s -- --uninstall`".
    It also says to remove an AI assistant's registration (`claude mcp remove jetcarp`).
  - **The data step:** "done: delete the data folder … (995.3 KB)", then "done: delete the settings folder": no FAILED
    (rc.3's M-7 had it).
  - **rc.4's installer `--uninstall`** (the copy checked against `SHA256SUMS` at the start): "removed
    ~/.local/bin/jetcarp", "removed ~/.local/lib/jetcarp", "removed ~/.local/lib (empty, made by the install)"; it
    says first that `jetcarp uninstall` undoes the rest "if that is still to do". Again with nothing installed: "error:
    no JETCARP installed by this installer in ~/.local/lib/jetcarp", exit 1.
  - Small: the installer still says "kept your settings, data and pictures, usually in ~/Library/Application
    Support/jetcarp …" when `uninstall --settings --data` has just deleted them (only the pictures are left).
  - Small: `~/.cache/jetcarp/app-endpoint.json` (the app's AI control address) and its folder stay. Most likely
    because I closed the app with SIGTERM rather than ⌘Q; `uninstall` doesn't remove it either way.
- JETCARP is now uninstalled from this Mac: no program, no settings or data, no login item; `~/Pictures/JETCARP` kept,
  as `uninstall` says. The 1.5 soak, when it runs, uses the release archive in a test folder, as the pre-check's did.

## Parity on Metal with the release build: pass (`long.sh`, `long-summary.txt`)

The release archive's `jetcarp` (sha256 f66c440a…, the installed one too), in a test folder of its own:
- **1.1:** 371 scenes at 300 generations: CPU matches 371, GPU matches 371, all on the GPU in 334; no MISMATCH; 75 s.
- **1.2:** 40 scenes at 5,000 generations: CPU matches 40, GPU matches 40, all on the GPU; no MISMATCH; 64 s.
- The same as the pre-check (74 s and 63 s) and rc.3.

## The suite on the tag: pass (`1.3-tests.txt`, `1.3-ignored.txt`)

Seven Rust files changed between the pre-check's af07766 and the tag (#118, #120, #122 and the app's screenshot tests),
so it ran again: `~/jetcarp-rc-042c/src` at **cf5cbdf** (`v0.4.2-rc.4`), `cargo test --release --workspace
--no-fail-fast`, a scratch HOME, no `JETCARP_*` variables. **1,058 passed, 0 failed, 41 ignored, in 143 test binaries**;
exit 0, 11 min; no warnings. The pre-check gave 1,058 / 0 / 39. The two newly ignored are screenshot tests, `#[ignore]`
like the rest of their kind: `app::shots::shots_ai_control` and `setup_ui::tests::offscreen_setup_wizard_running`.

## 1.5, the 8-hour soak on rc.4: pass (`soak/`)

2026-11-17, 5:54 AM to 1:54 PM EST (10:54 to 18:54 UTC), on Jimmie's word ("Start the soak, I can leave the laptop
now"). Jimmie was away throughout; on mains, the lid open. The release archive's `jetcarp` in a test folder of its own
(`~/jetcarp-rc4/homes/soak`), the warning answered there (`setup … --profile blank-slate`), wallpaper on, then `host
rotation "Classics, hourly"`, as on the Acer. `soak.sh` under `caffeinate -is`: a sample every 5 min (`soak.csv`,
`soak-status.jsonl`), and every hour a capture of the host's own window and a push.

- **pass (automatic, `soak-summary.txt`):** alive in 97 of 97 samples, the one host (pid 71955) throughout; never held
  or paused; the generation moved in all 96 intervals, and never went back within a scene.
- **The scene changed on the hour**, eight times, through all seven classics, each at full speed. The ants ran on the
  CPU ("the world is too small to be worth the GPU"), the rest on the GPU (Metal):

| Hour (EST) | Scene (of 7) | Cells | Gens/s, set / measured | On | Footprint | CPU (median) |
|---|---|---|---|---|---|---|
| 5:54 | Cyclic spirals (4) | 303,455 at 6 px | 30 / 30.00 | GPU | 261–265 MB | 36% |
| 6:00 | Life (1) | 303,455 at 6 px | 30 / 29.98–30.03 | GPU | 264–265 MB | 38% |
| 7:00 | Forest fire (3) | 682,592 at 4 px | 30 / 29.99–30.01 | GPU | 282 MB | 57% |
| 8:00 | Hodgepodge (7) | 303,455 at 6 px | 30 / 30.00 | GPU | 263 MB | 38% |
| 9:00 | Langton's ant (2) | 170,648 at 8 px | 240 / 239.69–240.00 | CPU | 262–270 MB | 73% |
| 10:00 | Penrose waves (6) | 280,000 at 5 px | 30 / 30.00 | GPU | 313–314 MB | 38% |
| 11:00 | Turmite LLRR (5) | 170,648 at 8 px | 240 / 239.99–240.00 | CPU | 312 MB | 73% |
| 12:00 | Cyclic spirals (4) | 303,455 at 6 px | 30 / 30.00 | GPU | 268 MB | 37% |
| 1:00 PM | Life (1) | 303,455 at 6 px | 30 / 30.00 | GPU | 269 MB | 38% |

- **Memory follows the scene, with no climb.** The scenes that ran twice: Life 264–265 MB in the first hour, 269 MB in
  the last; Cyclic spirals 261–265 MB at the start, 268 MB seven hours on. The most was 314 MB, on Penrose waves; the
  turmite after it kept 312 MB, and Cyclic spirals then gave it back (268 MB). The summary's slope, first hour to
  last, is 2.10 MB/h (265 → 269 MB). The status's memory followed the footprint (298 MB in the first sample, 269 at the
  end); RSS 255–291 MB. CPU median 38.5% of a core, whole GPU median 10%.
- **Nine pictures, one an hour** (`soak-shot-00h-w0.jpg` to `08h`): the host's own desktop window, captured by its id,
  960 px wide. Each shows the scene the samples name, and nothing else. The two of Cyclic spirals (00h and 07h) look
  alike, with the same seed and the same spiral cores, but differ in 595,184 of 595,200 pixels. So the window wasn't
  stale.
- **All ten pushes went through:** the start, each hour, and the end.
- The pre-check's soak ran one scene (the turmite, on the CPU) for all 8 hours. This one covers scene changes and GPU
  simulation over time: the pre-check's question 4.

### #95 on rc.4: pass (`soak-95.csv`, `soak-95-display-log.txt`, `soak-end.txt`)

At the end of the soak, as in the pre-check:
1. `pmset displaysleepnow` (1:54:26 PM EST);
2. a sample about every 17 s for 3 min;
3. `caffeinate -u -t 2`, then 90 s more;
4. `host stop`.

Nobody touched the Mac this time (in the pre-check a mouse bump woke the display after 4 s).

- **The power log** (`pmset -g log`, EST): display off 13:54:28 to 13:57:59, the whole asleep phase, with nothing
  waking it. On at 13:57:59 (the script's `caffeinate -u`), at the lock screen. Off at 13:58:29 (30 s idle at the lock
  screen). The system never slept.
- **The host.** Before: Life at 30 gens/s, CPU 37.6%, footprint 268 MB.
  - Within 15 s of the display going off it held, with "the screen is locked or off" (`dark`). From then on the
    generation stayed at 98,061, the CPU at 0.1–0.2%, the GPU at 0–1%, and the footprint dropped to 182 MB.
  - At the lock screen with the display on (awake+15 s): still held, `covered` and `dark`, footprint 54 MB.
  - Then `dark` again once the display went off.
  
  It never let go while the screen was locked. The host's `paused` stayed false, and the screen's own `paused` was
  true while held, as in the pre-check.
- **So the case the pre-check couldn't see, a display off the whole time, holds too.** The resume at sign-in wasn't
  seen this time: `host stop` (exit 0) came at 1:59:47 PM EST, with the Mac still locked. The pre-check saw the host
  resume 12 s after Jimmie signed in.

## rc.4 on the Mac: done

Every row of the Mac's in the rc.4 wave is done: the upgrade, R4's rows, parity, the suite, 1.5 and #95.
- Found: #131 (fixed in rc.5, and passed on `rc5-fixes`, NOTES 6:00 AM), and the questions below.
- Nothing of JETCARP is left running: no host and no login item (`launchctl print` exit 113).
- `~/jetcarp-rc4` keeps the release archive and the test folders.
- The Mac was left at the lock screen; it holds until Jimmie signs in.

## Questions (recorded, not asked; the run carried on)

1. **#80 (now #129, for 0.4.3):** `jobs status`'s memory is the footprint, but read only now and then, so it can be a minute or more old and
   miss a peak (568 MiB shown while the footprint was 2 GB). Is that intended? If `--max-rss-gb` uses the same reading,
   a short peak could pass it unseen.
2. **#112 (now #130, for 0.4.3):** a screen bound to a monitor that isn't connected still steps and draws (30 generations a second on the GPU)
   with no window. Should it wait until its monitor comes back, or move onto a connected one, as it does when a monitor
   is unplugged while the host runs?
3. **After ⌘M and a restore from the Dock the window stays frozen** (rc.3 redraws; the yellow button is fine). Anyone who
   minimises with ⌘M and brings it back sees a still picture while the world runs on. **#131, milestone v0.4.2**: ⌘M's
   (#98), not #87's.
4. **#114, Paste:** after ⌘V the Rule box keeps showing the old text until the next key (Enter) or a save, though the
   pasted rule is taken (a save straight after has it). A newcomer would think the paste failed. 0.4.2 or 0.4.3?
