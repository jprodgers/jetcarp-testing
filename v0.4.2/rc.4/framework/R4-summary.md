# R4 on the Framework: v0.4.2-rc.4's release build

Run unattended on 2026-11-16, 10:05 to 10:23 PM EST, with the release build
`jetcarp-0.4.2-rc.4-x86_64-unknown-linux-gnu.tar.gz` (sha256 d805fada8cc612f7…, as in its
SHA256SUMS). Every command ran inside `env.sh <name>`, each check in a fresh scratch home under
`~/Documents/jetcarp-dev/work/0.4.2-rc4/homes/`. The parity runs were still going when R4 began
(they ended at 10:06 PM), so the searches here ran on the CPU (4 or 8 threads). The scripts are in
`R4-scripts/`.

| # | Fix | Check (Framework part) | Verdict | File |
|---|---|---|---|---|
| 0 | upgrade | rc.3's test settings and data, rc.4's program: version, doctor, library, host status, host start refused | PASS | R4-0-upgrade.txt |
| 1 | #96 | The seizure warning: five commands and MCP host_control refused, naming it; setup writes photosensitivity.json; then the host starts | PASS | R4-1-seizure.txt |
| 2 | #112 | Fit hidden: no tune in `host --help` or host_control; `host tune` refused; rc.3's saved Fit sizes ignored, each scene at its own size | PASS (monitor change skipped) | R4-2-fit.txt |
| 3 | #84 | `JETCARP_GPU=off doctor`: "not used, and not tested", no adapter tested | PASS | R4-3-doctor-gpu-off.txt |
| 4 | #85 | `paths` and `paths --json` list the runtime folder | PASS | R4-4-paths.txt |
| 5 | #86 | JACA clips: settled runs Static, not Battles (Static 26, Battles 8; rc.3: Battles 8 incl. 2 settled) | PASS | R4-5-jaca-clips.txt |
| 6 | #57 | Export of a running search refused; nothing beside the target | PASS | R4-6-export-refused.txt |
| 7 | bdc8730 | (a) held host says held, reason once; (b) `jobs resume --detach` answers once its process has the job (0.14 s) | PASS (Hunts window skipped) | R4-7-audit-bdc8730.txt |
| 8 | #104 | Progress redraws fit a 60-column terminal (rc.3 control leaves pieces) | PASS | R4-8-progress-60col.txt and four typescripts |
| 9 | #92 | MCP reference shows `<id>` and `L<level>` (book and `jetcarp mcp`) | PASS | R4-9-mcp-reference.txt |
| 10 | #122 | Ten rounds of `host start --headless; host stop`: 10 of 10 each | PASS | R4-10-start-stop.txt |
| 11 | (private) see the withheld files | (private) see the withheld files | (private) see the withheld files | (private) see the withheld files |

No check failed.

## Surprises (none of them a failure of the fix it checks)

1. **host_control doesn't reject an action outside its own enum** (seen in R4-1 and R4-2).
   tools/list gives host_control's `action` an enum without `start`, but
   `{"action": "start"}` isn't refused by the server's argument check: with no host it answers
   "the JETCARP background host is not running", and with a host running the host answers
   `unknown action "start"`. The book says arguments of the wrong type are refused, naming the
   argument; an unknown enum value isn't. Cosmetic.

2. **CLI `host resume` and MCP `resume` disagree while the warning holds the host** (R4-7a).
   With the warning unanswered and a host held by it, `jetcarp host resume` succeeds (exit 0: it
   lifts a hand pause, and the screen line goes back to "· held", so nothing animates), while MCP
   `host_control {"action": "resume"}` is refused with the full warning text (host_call_shows
   counts resume, next, previous and rotation as showing scenes). Harmless; only the two answers
   differ.

3. **The MCP reference as served is the Markdown source** (R4-9). The book's page now writes the
   placeholders as `&lt;id>` and `L&lt;level>`, which mdbook renders as `<id>` and `L<level>`.
   `jetcarp mcp` serves that same source (resources/read and help), so a client reading it as
   plain text sees `&lt;id>` rather than `<id>`. Probably fine; noted in case MCP clients should
   get the plain form.

4. **A small JACA clip round fills with Static** (R4-5). `jobs clips --sample 48` on a 3-minute
   JACA search over 8 tilings gave 34 clips, 26 of them Static, though Static is capped at 3 (a
   sixteenth of 48). taste_sample's top-up falls back to the rarely kept categories once the others
   (here only Battles, 8 runs with rules of their own) run out, so this is the code's design, not
   #86 failing. On a longer search it shouldn't show.

## Notes

- `doctor` says "GNOME Shell was not found in this session" here: this session runs inside a
  Flatpak sandbox (D-Bus through `/run/flatpak/bus`), not a JETCARP problem.
- `jetcarp mcp`'s `host_control` has no start action; #96's MCP check used wallpaper on, login on,
  resume, next and rotation, all refused with the warning.
- After the warning was answered, `wallpaper on`, `login on` and `saver install` weren't run: the
  Framework's rules allow them only where a refusal is expected. `host serve --saver` ran with
  DISPLAY and WAYLAND_DISPLAY unset (its refusal comes before any window).
- #112's comparison also ran at 2560x1440 (`host serve --headless --canvas 2560x1440`), the canvas
  rc.3's sweep saved its sizes for, as well as at `host start --headless`'s 1280x720.
- Skipped, as the plan says: the app's warning screen (Jimmie's, F-1), a monitor change starting no
  fit (needs a desktop), the Hunts window (app).
- Housekeeping: a read-only Python sqlite3 look at rc.3's original
  `work/0.4.2-rc3/data/library.sqlite` (before check 0) made an empty `library.sqlite-wal` and a
  `library.sqlite-shm` beside it. Both were removed; `library.sqlite` itself was never changed
  (mtime still 2026-11-15 11:07 PM). Only that folder's mtime differs.
- No JETCARP process started here is left running. Nothing was written to `~/.config/jetcarp`,
  `~/.local/share/jetcarp`, `~/Pictures/JETCARP`, `~/.config/autostart` or the GNOME extension
  folder (compared before and after). GNOME Shell's own notifications file changed at 10:10 PM
  with a GNOME Software notification ("Visual Studio Code has been updated"), nothing from JETCARP.
