# Where things were

Until November 2026 the plans sat at the top of this repository, the results were under
`results/` by wave, and one `NOTES.md` covered everything. They are now in one folder per release
cycle. Nothing inside a record was edited for the move, so **a path written in a plan, a note, a
log or a script is the old one**, and so is a path quoted in an issue of
[jprodgers/jetcarp](https://github.com/jprodgers/jetcarp/issues). This page gives the new place
of each.

## Plans

| Was | Is |
|---|---|
| `rc1.md` | `v0.4.0/rc.1/PLAN.md` |
| `debug-host-start.md` | `v0.4.0/rc.2-debug/PLAN.md` |
| `rc2.md` | `v0.4.0/rc.2/PLAN.md` |
| `rc3.md` | `v0.4.0/rc.3/PLAN.md` |
| `v0.4.0.md` | `v0.4.0/release/PLAN.md` |
| `v0.4.2-rc.1.md` | `v0.4.2/rc.1/PLAN.md` |
| `v0.4.2-rc.2.md` | `v0.4.2/rc.2/PLAN.md` |
| `v0.4.2-rc.3.md` | `v0.4.2/rc.3/PLAN.md` |
| `v0.4.2-rc.4.md` | `v0.4.2/rc.4/PLAN.md` |
| `v0.4.2-rc.5.md` | `v0.4.2/rc.5/PLAN.md` |

## Results

Each wave's folder moved whole: what was `results/<wave>/<machine>/<file>` is
`<cycle>/<candidate>/<machine>/<file>`, with the machine's folder and the file names unchanged.

| Was | Is |
|---|---|
| `results/rc1/` | `v0.4.0/rc.1/` |
| `results/rc2-debug/` | `v0.4.0/rc.2-debug/` |
| `results/rc2/` | `v0.4.0/rc.2/` |
| `results/rc3/` | `v0.4.0/rc.3/` |
| `results/v0.4.0/` | `v0.4.0/release/` |
| `results/v0.4.2-rc.1/` | `v0.4.2/rc.1/` |
| `results/v0.4.2-rc.2/` | `v0.4.2/rc.2/` |
| `results/v0.4.2-rc.3/` | `v0.4.2/rc.3/` |
| `results/v0.4.2-rc4-pre/` | `v0.4.2/rc.4-pre/` |
| `results/v0.4.2-rc4/` | `v0.4.2/rc.4/` |
| `results/v0.4.2-rc5-pre/` | `v0.4.2/rc.5-pre/` |
| `results/v0.4.2-rc5/` | `v0.4.2/rc.5/` |
| `results/v0.4.2/` | `v0.4.2/release/` |

The old names were not regular (`v0.4.2-rc.3` beside `v0.4.2-rc4`); the new ones follow the
tags.

## The rest

| Was | Is |
|---|---|
| `NOTES.md`, the entries of 11 to 13 November 2026 | `v0.4.0/NOTES.md` |
| `NOTES.md`, from "2026-11-14, main session: wave v0.4.2-rc.1 written" on | `v0.4.2/NOTES.md` |
| `parity/` (and `parity/long/`) | `v0.4.2/parity/` (and `v0.4.2/parity/long/`) |
| `TEST-SESSION-RULES.md` | `RULES.md` |

`NOTES.md` was cut in two at a heading; no entry was split, and each half got a title of its own.
A note that says "NOTES, 8:07 PM" means the entry of that time in its own cycle's `NOTES.md`.

`README.md`, `WITHHELD.md`, the licence files and `audits/` stayed where they were.

The move was made by [`tools/restructure-by-cycle.sh`](tools/restructure-by-cycle.sh), which
holds the same table and can be read as the definition.
