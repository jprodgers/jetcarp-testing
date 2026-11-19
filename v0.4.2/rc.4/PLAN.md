# Release candidate v0.4.2-rc.4: rc.3's stragglers, the seizure warning, Fit held back

> **Tagged** `v0.4.2-rc.4` on **cf5cbdf** ("Release 0.4.2-rc.4") on 2026-11-16 at 9:17 PM EST, on
> Jimmie's go, after the pre-check passed on all three machines (NOTES, 8:07 and 9:10 PM) and CI was
> green. Written 2026-11-16, 1:00 PM EST, from `release-0.4.2` at af07766.

**What rc.4 is.** rc.3's Phase 2 found #84–#104, #112, #114 and #116, and the rc.4 pre-check found #117–#122. Every one marked `v0.4.2` is
fixed on `release-0.4.2`. Two changes are larger than stragglers:
- **#96, the photosensitive seizure warning**, answered before anything animates on screen;
- **#112: Fit to this computer is hidden in 0.4.2.** Jimmie's rule: "A fit should be 10 seconds,
  maybe 30 seconds. If we can't hit that target, I want the feature removed." The fast fit (#113)
  is 0.4.3.

rc.4 also carries the rc.3 book audit and its code fixes (bdc8730), #80, the private planted-link
fix (d1f3478) and the #57 straggler (efe1a03). The full list is in "On `release-0.4.2` for rc.4"
in `v0.4.2-rc.3.md`, and in the changelog.

**rc.4's wave is short and targeted** (rc.3's plan, "After rc.3"):
- R4 below, a check of what rc.4 changed;
- the parity sets and the suite;
- the Phase 2 rows still open.

It isn't a full pass. If it's clean, 0.4.2 ships, on Jimmie's go.

## Before the tag

1. **The branch pre-check** (2026-11-16, while Jimmie is out; NOTES, 12:30 PM):
   - the suite and both parity sets on every adapter of the three machines, on the branch build;
   - the PowerShell installer's syntax and an install and uninstall (the Acer);
   - #87 minimised by script (the Acer);
   - then 1.5, the 8-hour desktop soak, on the Mac.

   Results go in `results/v0.4.2-rc4-pre/<machine>/`.
2. **The rc.4 book audit:** every page against everything since rc.3's audit, pictures included.
   Under way; its commits land on the branch after review.
3. **`about/testing.md`:** the cycle record brought up to date (the main session).
4. **CI green** on the branch head with all of the above.
5. **The version bump:** "Release 0.4.2-rc.4", `Cargo.toml` and `Cargo.lock` only, as rc.3's 400d41d.
6. **Jimmie's go**, then the tag, and the pre-release from CI's builds.

## The wave

**Every machine first:**
1. **Upgrade from rc.3 to rc.4** the way a tester would: put rc.4's programs in place of rc.3's.
   The package managers skip rc tags.
   - **The Mac:** start-at-login was on under rc.3. Open the app once, then log out and back in:
     the host comes back (#99).
2. **Check the seizure warning (#96)**, then accept it (below).
3. Then R4, the parity sets and the suite.

**Parity (1.1 and 1.2):** the 371 scenes at 300 generations and the 40 at 5,000. They run on
every adapter and API pair, as in rc.3, with the release's own build. That's 8 runs in all: the
Framework's Radeon and llvmpipe, the Acer's RTX and UHD on Vulkan and DX12, and the Mac's Metal.
rc.4 changes no stepping, so both `expected.csv` files stand.

**The suite (1.3):** on each machine's adapters. The pre-check's run on the branch counts for rc.4
if no Rust code changed between its commit and the tag other than the version bump (book commits
don't count). Otherwise run it again.

### R4: a check of every fix since rc.3

F = the Framework (scratch folders, as always), A = the Acer, M = the Mac.

| # | Fix | Where | Check |
|---|---|---|---|
| **96** | **The photosensitive seizure warning** | F A M | With a fresh settings folder:<br>• The app shows the warning before setup.<br>• "May have a seizure disorder" offers **Quit** first and **Continue at my own risk** second, and Quit quits.<br>• `host start`, `wallpaper on`, `login on`, `saver install` and `host serve --saver` are refused, each naming the warning; so is MCP `host_control`.<br>• `jetcarp setup --seizure-warning no-disorder` writes `photosensitivity.json` (answer, date, version, via), and then all of them work. |
| **112** | **Fit is hidden** | F A M | • The Desktop background pane has no Fit button, cards or limits.<br>• `jetcarp host --help` lists no `tune`, and `jetcarp host tune` refuses with "Fit to this computer isn't in JETCARP 0.4.2…".<br>• MCP `host_control` offers no tune.<br>• The machine's rc.3 `host.json`, with its saved sizes, shows each scene at its own size: `host status` cells against the scene's own.<br>• A monitor change starts no fit.<br>This replaces R's rows #38, #39, #44–#46, #69, #72 and #73. |
| **114** | **Copy and Paste reach the system** | F A M | • AI control: Copy on the `jetcarp mcp --app` row, then paste into a terminal: the same text.<br>• Copy a rule in a text editor and paste it into the CAs pane's Rule box.<br>• The window's footer says the address is a private link, not HTTP.<br>• Linux under GNOME (Wayland), with Jimmie in F-1. |
| **87** | **The app goes on behind a hidden window** | A M F | Poll `world_status` through `jetcarp mcp --app` every 2 s. The answers keep coming and the generation keeps climbing near its visible speed:<br>• A: minimised for 60 s;<br>• M: covered, then minimised (already passed on the branch; once more on rc.4);<br>• F: minimised under GNOME (F-1).<br>Record the app's CPU while hidden. |
| 116 | `host status` gives the speed a screen reaches | A (UHD) | A scene heavier than the screen can run: the text says "N fps, X of Y generations a second", and the JSON has `measured_speed`. |
| 88 | The Jump field takes typing | F A M | Run → Jump: click Generations, type 4096, Jump: the generation goes up by 4,096. |
| 90 | A typed rule applies before Save and on leaving the window | F A M | Type a rule and press Save at once: reopening the scene shows the new rule. Type one and switch windows: it's applied. |
| 91, 98 | macOS shortcuts | M | ⌘⇧H opens Quick Start, ⌃⌘F is full screen, ⌘M minimises. ⌘H is the system's Hide. |
| 89 | Keep awake on macOS | M | View → Keep awake: `pmset -g assertions` lists JETCARP's NoDisplaySleepAssertion; turning it off removes it. |
| 95 | The host holds while the displays sleep | M | From the pre-check soak's log, or `pmset displaysleepnow`: `host status` says held, and the generation stays put until the displays wake. |
| 99 | macOS login item after an upgrade, and login off | M | • The upgrade above.<br>• `jetcarp host login off` with the host stopped: `launchctl print gui/$UID/com.jimmieprodgers.jetcarp.host` exits 113.<br>• With the host running: the host is left running, and the job is gone after the next logout.<br>• `jetcarp uninstall` stops the host first, so the job goes at once. |
| 80 | macOS memory is the physical footprint | M | During an explore, `jobs status` memory is near `footprint <pid>`'s figure, not the RSS. |
| 84 | doctor with the GPU off tests no adapter | F A M | `JETCARP_GPU=off jetcarp doctor`: "not used, and not tested", and no adapter is tested. |
| 85 | `jetcarp paths` names the runtime folder | F A M | `jetcarp paths` and `--json` list it. |
| 86 | JACA clips | F | On a JACA explore, `jobs clips --sample 48`: runs that settled are Static, not Battles. |
| 57 | A refused export leaves nothing behind | F | `pack export` of a running search is refused, and `ls -a` beside the target shows no hidden store. |
| — | From rc.3's audit (bdc8730) | F | • `host status` says held for a screen a hold froze, and its reason isn't doubled.<br>• The Hunts window says stale for a killed run.<br>• `jobs resume --detach` answers once its process has the job. |
| 103 | Uninstall's wording | F A M | • `jetcarp uninstall` names the command that removes the program for how it was installed.<br>• `install.sh --uninstall` and `install.ps1 -Uninstall` say what they removed.<br>• The Mac's data step doesn't report FAILED.<br>A: from A-7's account. |
| 117 | The Windows installer's refusals are one line | A | `install.ps1` into a folder it didn't make, and `-Uninstall` where nothing is installed: each prints its one line and exits 1, with no PowerShell error block. The temporary folder is gone (`$env:TEMP\jetcarp-*`). CI's Windows job checks the second. |
| 120 | A refused `host serve --saver` doesn't wait for a click (Windows) | A | • The suite's `host.rs` ends on its own, with no message box.<br>• With the warning not yet answered (#96's fresh settings folder), Windows' screen saver itself still says why in a message box: Settings → Screen saver → Preview. |
| 122 | `host start` straight after `host stop` | F A M | • `host start --headless; host stop; host start --headless` ten times in a row: every start works.<br>• The Acer, busy (straight after the suite): host.rs serial 10 times, 10 of 10. |
| 104 | Progress lines fit the terminal | F A M | In a 60-column terminal, a `pack import` or explore progress line leaves no pieces behind. |
| 100–102 | The book | F A M | • Copy three commands with the book's copy button and run them.<br>• `claude mcp add --scope user jetcarp -- jetcarp mcp` registers JETCARP for every folder (`/mcp` in another folder).<br>• The MCP reference shows `<id>` and `L<level>` (#92). |
| — | (private) Files JETCARP names itself inside a checked folder | F A M | F9's `t42b_symlink.py` again, plus a link planted at an animation's `poster.png` and at a pack export's `pack.json`: each is refused, and nothing is written where it leads. |

#52's hang on the UHD (1 run in 30 with both tests in flight) is 0.4.3's. rc.4 doesn't recheck it.

### Phase 2 rows still open (on rc.4)

| Sitting | Steps | Jimmie |
|---|---|---|
| A-7 | Part 3 in a separate account: a newcomer's first hour on rc.4, then the upgrade from 0.4.1 to rc.4 (3.2), and #103's uninstall at the end | hands-on |
| A-8 | 2.MM without Fit (steps 1, 3 and 4): two rotations on two monitors, each at its own size; unplug and replug while the host runs; change the external monitor's scaling. Also (#130): start the host with the external monitor unplugged, and see whether its screen runs (`host status`, GPU use) | hands-on |
| A idle | 1.5 overnight soak on rc.4 | starts it |
| F-1 | F4: the rating page in Firefox and Chrome; FD: the desktop pane (no Fit) in the headless shell; F7: 2.APP on Linux, with R4's app rows | hands-on |
| F-2 | Part 3 on Fedora, in a separate account | hands-on |
| F-3 | 1.5 overnight on the Framework, on a night Jimmie chooses | starts it |

The Mac's 1.5 runs before the tag, on the branch (the pre-check). If the host's code changes
after that, it runs again on rc.4.

## Set-up

As in rc.3:
- The laptops' default folders are fine.
- The Framework uses scratch folders with every `JETCARP_*` set, `JETCARP_RUNTIME_DIR` included.
  It never uses the real settings, library, pictures or GNOME settings, and GNOME runs only in a
  private headless shell.
- Accept the seizure warning on each machine once its check is done.

## After a clean rc.4: 0.4.2

All of these are Jimmie's go:
- the version bump to 0.4.2 and the changelog's date;
- the tag and the release;
- Homebrew and Scoop;
- F3, the GNOME refresh on Jimmie's real session (one logout);
- then the private advisory published, and the public test records regenerated without the
  withheld parts (`tools/publish_public.py`).

## Left for 0.4.3

#28, #34, #52's UHD hang, #55, #70, #71, #77, #81–#83, #93, #94, #105–#111, #113 (the fast fit),
#115, #121 (tests' leftover temp folders), #123 (the notices list GTK crates in no build), #124–#128,
#129 (explore steps overrun, so the memory figure and cap lag) and #130 (a screen whose monitor isn't connected runs).
#119 (the glib alert) is closed: no build contains glib, and Jimmie dismissed the alert as not used (2026-11-16).

(private) And R4's private row's extra finding, the hidden store beside a command-line export (NOTES 2026-11-16 10:26 PM): fixed in 0.4.3, private until then; the public copy holds rc.4's private records until 0.4.3 is released.
