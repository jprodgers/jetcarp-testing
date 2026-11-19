# F-1 on rc.4: the rating page, and the app on GNOME (the Framework, 2026-11-17, 6:00–7:09 AM EST)

With Jimmie at the Framework (Fedora 45, GNOME 51.1 on Wayland, Radeon 8060S). rc.4's release build ran in a scratch
home (`homes/f1`: every `JETCARP_*` folder, `HOME` and the XDG folders), started by `app.sh`. A `gsettings` guard
first on its PATH (`guard-gsettings`) refused any change to the real GNOME settings. It refused nothing, since the app
never tried.

**FD** (the desktop pane and the live desktop on GNOME, in a private headless shell) is in `../FD/`: pass.

## F4: the rating page (24 clips from a scratch explore, `jobs clips --page`)

| Browser | Result |
|---|---|
| Firefox | **pass**: 12 rated (3 each of keep, maybe, drop, and star), a note; ratings and the note survive a reload; light and dark both look right; Save ratings gave `firefox-ratings.json`. `jobs review --from`: 9 reviews and 3 stars recorded, the note shown; again: 0 recorded, 12 already. |
| Chrome (Flatpak) | **pass**: 10 rated, a note; reload keeps them; `chrome-ratings.json` imported: 9 reviews, 3 stars. Chrome first wouldn't start (since the Fedora 45 upgrade, the document portal's FUSE mount at `/run/user/1000/doc` had gone; `bwrap: Can't find source path …`). Restarting `xdg-document-portal.service` fixed it. Not JETCARP's. |

## The app (F7, 2.APP, with R4's app rows)

| Row | Result |
|---|---|
| #96, the warning | **pass**: shown first, before setup (fresh settings folder); answered "no disorder" |
| Setup | **pass**: Explorer; the pack imported; a 1-minute search ran |
| #112, the Desktop background pane | **pass**: no Fit button, cards or limits (looked at only, not switched on) |
| #114, Copy | **pass**: Copy on AI control's `jetcarp mcp --app` row, pasted into a terminal, exact |
| #114, Paste | **pass**: `B36/S23` pasted into the Rule box shows in the box at once. The CA's header follows when the box loses focus, by design (#61). That's also what the Mac's "#132" was, so it's closed. |
| #88, Jump | **pass**: Jump's Generations field takes typing; Jump 4096 |
| #90 | **pass**: a typed rule saved with Ctrl+S straight away (no Enter) is in the file, `r90.json` ending with `update_ca` `B23/S23V` (`r90-last-commands.json`); a typed rule applies on switching windows |
| #87 under GNOME | **pass**: polled every 2 s for 5 min (`poll87.log`); hidden with Super+H at about 6:28, back with Alt+Tab. Every answer came (0.10 to 0.28 s, no gap over 2.3 s), the world held about 15 gens/s throughout, and the window drew again on its return. |
| Hunts, a killed run | **pass**: job 1, started detached and killed (`stale.sh`), says stale |
| Pop-outs | **pass**: every pane and tool window popped out and back in |
| Exports | **pass**: PNG 1062x850, GIF 640x503, animated WebP 640x512, each valid. GNOME briefly said the app might not be responding while each Save dialog was open: **#136** (0.4.3), rfd's blocking dialog on the main thread. |
| Scripts | **pass**: the HexW, Wolfram and soup-hunt examples ran |
| Light and dark | The app stays dark when GNOME is light; on Windows and macOS it follows the system. **#137** (0.4.3): winit 0.30 reports no system theme on Wayland or X11. |
| Resizing | **pass**: very small and very large |
| Restart, AI control (#1's lockout) | **pass**: the app reopened with AI control off; switched on from Tools → AI control…, it answered `jetcarp app status` |
| #100, the book's copy buttons | **pass**: three commands from *Hunting for spaceships* copied with the copy buttons ran as pasted, output as the book. Jimmie ran them with his installed 0.4.1, in his own library, which still checks the copy buttons. |

Not done here: #102 (`claude mcp add --scope user`), kept for F-2's separate account so the real Claude settings aren't touched.
