# The 0.4.2 cycle

Five release candidates and the release, 14 to 17 November 2026, on all three machines and four
GPU vendors (AMD on the Framework, NVIDIA and Intel on the Acer, Apple on the Mac). This is the
cycle that made the GPU the default, so its core is the parity set: every built-in scene must give
the same hash on every CPU and every GPU.

| Folder | Tag | Tagged (US Eastern) | Commit | Records from | What the plan set out to test |
|---|---|---|---|---|---|
| [`rc.1/`](rc.1/PLAN.md) | `v0.4.2-rc.1` | 14 Nov, 4:37 PM | `560958d` | `acer`, `framework`, `mac` | Everything 0.4.2 changes, before anything reached `main`; the parity set's first run |
| [`rc.2/`](rc.2/PLAN.md) | `v0.4.2-rc.2` | 15 Nov, 2:58 AM | `2d4b84c` | `acer`, `framework`, `mac` | A full pass, after rc.1's wave found 28 bugs (#15 to #42, less two enhancements) |
| [`rc.3/`](rc.3/PLAN.md) | `v0.4.2-rc.3` | 15 Nov, 6:27 PM | `400d41d` | `acer`, `framework`, `mac` | The fixes for what rc.2's wave found (23 bugs, #47 to #69, and a security problem), and the rest of the wave |
| `rc.4-pre/` | none (branch `release-0.4.2`) | | | `acer`, `framework`, `mac` | The branch, before rc.4 was tagged. Its steps are in [`rc.4/PLAN.md`](rc.4/PLAN.md) |
| [`rc.4/`](rc.4/PLAN.md) | `v0.4.2-rc.4` | 16 Nov, 9:17 PM | `cf5cbdf` | `acer`, `framework`, `mac` | rc.3's stragglers, the photosensitive seizure warning, and "Fit to this computer" held back to 0.4.3 |
| `rc.5-pre/` | none (branch `rc5-fixes`) | | | `framework`, `mac` | The test suite, and the fix for #131, before rc.5 was tagged |
| [`rc.5/`](rc.5/PLAN.md) | `v0.4.2-rc.5` | 17 Nov, 6:56 AM | `c0db1ab` | `acer`, `framework`, `mac` | The ⌘M freeze the Mac found in rc.4 (#131), and six small fixes |
| `release/` | `v0.4.2` | 17 Nov, 7:06 PM | `a3e829a` | `framework` | One check on the release itself: the GNOME extension's refresh on a real session |

The issue numbers are the plans' own counts; the issues are in
[jprodgers/jetcarp](https://github.com/jprodgers/jetcarp/issues).

- [`NOTES.md`](NOTES.md) is the log between the sessions for the whole cycle, oldest first.
- [`parity/`](parity/README.md) is the parity set: 371 scenes run for 300 generations, and 40 of
  them for 5,000 (`parity/long/`), with the hash each must give. Each machine's parity results
  are CSV files in, or one folder under, its folder for the candidate.
- Each plan ends with each machine's table of results; the files a table names are in that
  machine's folder beside the plan.

**The two security problems** found in this cycle were handled privately until 0.4.2 fixed them.
Their records were left out of this copy until then and are here now (the files named `4.2…`),
and the notes about them are the entries marked "(private)". Two table rows read "(private) see
the withheld files", as the session wrote them while the problems were private. The results are
in their own files: `rc.4/framework/R4-11-t42b-symlink.txt` for row 11 of `R4-summary.md` (the
check that found the second problem), and `rc.5/framework/t42b-R5-private-symlink.txt` and
`t42b-R5-private-c4-symlink.txt` for the last row of `R5-summary.md`.

The records were written when the plans were `v0.4.2-rc.1.md` to `v0.4.2-rc.5.md` at the top of
the repository, the results were under `results/v0.4.2-rc.1/` and so on, and the parity set was
`parity/`. Paths inside the records still say so: see [`../MOVED.md`](../MOVED.md).
