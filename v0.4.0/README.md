# The 0.4.0 cycle

The first public release: three release candidates and the release itself, 11 to 13 November
2026. The laptops tested; the Framework ran the main session, which built the candidates, read
the results, filed the issues and made the fixes, so it has no folder of its own here.

| Folder | Tag | Tagged (US Eastern) | Commit | Records from | What the plan set out to test |
|---|---|---|---|---|---|
| [`rc.1/`](rc.1/PLAN.md) | `v0.4.0-rc.1` | 11 Nov, 10:57 PM | `a7ce1fb` | `acer`, `mac` | Installing each way, the app, the desktop features (live wallpaper, screen saver, still picture, start at login) and uninstalling |
| [`rc.2-debug/`](rc.2-debug/PLAN.md) | none | | | `acer` | A host-start failure that only Windows CI showed, pinned down on a real machine before rc.2 |
| [`rc.2/`](rc.2/PLAN.md) | `v0.4.0-rc.2` | 12 Nov, 6:06 AM | `c87a153` | `acer` | The first-run setup wizard and its profiles, the starter pack, the MCP server with a real AI client, and rc.1's findings fixed since |
| [`rc.3/`](rc.3/PLAN.md) | `v0.4.0-rc.3` | 12 Nov, 12:26 PM | `3a5bd76` | `acer`, `mac` | The fixes made since rc.2, and a Quick Start build that ends on time |
| [`release/`](release/PLAN.md) | `v0.4.0` | 13 Nov, 3:11 AM | `069efb9` | `acer`, `mac` | Installing the release through Homebrew and Scoop, and the fixes made after rc.3 |

- [`NOTES.md`](NOTES.md) is the log between the sessions for the whole cycle, oldest first.
- Each plan ends with each machine's table of results; the files a table names are in that
  machine's folder beside the plan.
- This cycle had no parity set: that came with 0.4.2.
- 0.4.1 followed on 13 November (5:00 PM, `f033b00`) without candidates, and has no records.

The records were written when the plans were `rc1.md`, `rc2.md`, `rc3.md` and `v0.4.0.md` at the
top of the repository, and the results were under `results/rc1/` and so on. Paths inside the
records still say so: see [`../MOVED.md`](../MOVED.md).
