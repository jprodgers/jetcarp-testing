# Release candidate v0.4.2-rc.5: the ⌘M freeze, and six small fixes

> **Tagged** `v0.4.2-rc.5` on **c0db1ab** ("Release 0.4.2-rc.5") on 2026-11-17 at 6:56 AM EST, on Jimmie's
> go, after CI was green on 3e40e84 and the Mac had checked #131. Written 2026-11-17, 5:13 AM EST, from `rc5-fixes` at c976627 (rc.4's cf5cbdf
> and seven fixes). Jimmie chose rc.5 with all six small fixes (2026-11-17, about 5:00 AM). The branch
> head is now **3e40e84**: #131's test fixed for debug builds, and #134 (5:53 AM).

**Why rc.5.** The Mac's rc.4 wave found **#131**: after ⌘M and a restore from the Dock, the app's
window never draws again, while the world steps and AI control answers. rc.4's ⌘M (#98) went through
egui's `Minimized` command, which egui on macOS never undoes. rc.3 had no ⌘M, so this is new in rc.4.
A user who minimises the app sees a frozen picture, so it can't ship.

**What else rides along.** These six were small and safe, and none of them touches the host or the
simulation:

| # | Fix | Where it is |
|---|---|---|
| **131** | ⌘M minimises through AppKit (`miniaturize:`), as the yellow button does | `jetcarp-app` (`macwin.rs`, `app/menu.rs`) |
| — | (private) The hidden store beside a command-line `pack export` is checked like the files inside the folder | `jetcarp-api` (`ops/pack.rs`) |
| 127 | Windows' old console window: escape codes turned on at start-up, spaces where that fails | `jetcarp` (`term.rs`) |
| 128 | `host tune --help` says only that Fit is held back; `install.ps1 -Uninstall` mentions PATH only when it was on it | `jetcarp` (`host_cmd.rs`), `packaging/install.ps1` |
| 126 | Book pages over MCP: `&lt;id>` reaches clients as `<id>`, code left as written | `jetcarp-mcp` (`docs.rs`) |
| 125 | MCP `host_control`: an unknown action is refused, naming the actions; `resume`, `next`, `previous` and `rotation` reach the host as on the command line | `jetcarp-mcp` (`stdio.rs`) |
| 124 | `host login on` names the `JETCARP_*` folders a login item won't carry, and on macOS stops reporting on the wrong host | `jetcarp` (`host_cmd.rs`) |
| 134 | The installers' uninstall names only the settings, data and picture folders still there (found by the Mac's #103 row, 5:50 AM) | `packaging/install.sh`, `packaging/install.ps1` |

No file in `jetcarp-host`, `jetcarp-display`, `jetcarp-gpu`, `jetcarp-search` or `jetcarp-core/src` changed
(`git diff --stat cf5cbdf c976627`).

## What carries over from rc.4

- **The soaks (1.5):** the Acer's and the Mac's on rc.4 count for rc.5, since no host code changed.
- **Phase 2's sittings** (A-7, A-8, F-1, F-2, F-3) and rc.4's R4 rows count, on rc.4 or rc.5, except the
  rows R5 checks again below.
- **Parity:** no stepping changed, so both `expected.csv` files stand. The sets still run once on rc.5's
  release build, unattended, as every candidate's do.

## Before the tag

1. The suite on the Framework, on `rc5-fixes`.
2. CI green on the branch head (Linux, Windows and macOS: #131's and #127's code runs there first).
3. The Mac builds `rc5-fixes` and checks #131 (NOTES, 4:55 AM). **Done: pass** on c976627 (NOTES, 6:00 AM); the
   unit test then needed a fix for debug builds (8e4b345).
4. The version bump, "Release 0.4.2-rc.5" (`Cargo.toml` and `Cargo.lock` only), Jimmie's go, the tag
   and the pre-release.

## The wave

**Every machine:** parity 1.1 and 1.2 on each adapter with the release build, and the suite on the
tag. All unattended.

### R5: a check of each fix

| # | Fix | Where | Check |
|---|---|---|---|
| **131** | **⌘M, then a restore** | M | • The world running: ⌘M, 30 s, restore from the Dock: the window draws again at once, and the toolbar's generation matches `world_status`.<br>• Paused: ⌘M, restore, then a pan or zoom draws.<br>• The yellow button still works the same.<br>• `cargo test -p jetcarp-app cmd_m_minimises` passes (CI's macOS job runs it too). |
| — | (private) The hidden store beside an export | F A M | R4's private row again, with case c3: a link planted at the hidden store beside a command-line `pack export --to` is refused, naming the store, and nothing is written where it leads; MCP still refuses it (c4, c5). |
| 127 | The old console window | A | In conhost (cmd and PowerShell, not Windows Terminal), 60 columns wide: a `pack import` or explore progress line redraws as one clean row, with no `←[2K`. Windows Terminal is unchanged, and so is output sent to a file. |
| 128 | `host tune --help`, `install.ps1 -Uninstall` | A (F M for the first) | • `jetcarp host tune --help` and `host help tune` print only "Fit to this computer isn't in JETCARP 0.4.2…".<br>• `install.ps1 -NoModifyPath`, then `-Uninstall`: "(it wasn't on your PATH)". A normal install, then `-Uninstall`: "took it off your PATH". |
| 126 | Book pages over MCP | F | `resources/read jetcarp://docs/reference/mcp` and `help {"page": "reference/mcp"}` read `L<level>` and `find:<id>`, with no `&lt;`. |
| 125 | MCP `host_control` | F | • `{"action": "start"}` is refused, naming the actions, with or without a host.<br>• With the warning not yet answered: `wallpaper` on is refused with the warning; `resume` reaches the host (held, or "not running"), as `jetcarp host resume` does. |
| 124 | `host login on` with folders of its own | M (F A for the note) | With `JETCARP_*` set: a note names the variables the login item won't carry. On the Mac, after registering: "registered with launchd, which runs the host with the default folders, not this run's". |
| 134 | The installers' uninstall, after `jetcarp uninstall --settings --data` | M A (F) | `install.sh --uninstall` (Mac, Linux) and `install.ps1 -Uninstall` (Acer) name only the folders still there; with none left, no "kept your settings" line. |

## After a clean rc.5: 0.4.2

As in rc.4's plan, all on Jimmie's go:
- the version bump to 0.4.2 and the changelog's date;
- the tag and the release;
- Homebrew and Scoop;
- F3, the GNOME refresh on Jimmie's real session;
- then both advisories published, and the public test records regenerated (`tools/publish_public.py`, with
  "0.4.2" and the second problem's tier released).
