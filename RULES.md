# JETCARP release-candidate tests: the rules the test sessions work by

This is the README of the repository holding the test plans and results for JETCARP's release
candidates, kept apart from the program's repository (`jprodgers/jetcarp`); it is published as
`jprodgers/jetcarp-testing`, less what `WITHHELD.md` lists.

The Claude Code sessions on each computer don't share a conversation or memory. Everything one
session needs to tell another goes in this repository.

## Machines

| Machine | OS | Notes |
|---|---|---|
| Framework Desktop | Fedora 45, GNOME 51.1 (Wayland) | runs the main session, which builds and releases; one monitor only |
| Acer Nitro V15 | Windows 11 | RTX 3050 Laptop + Intel UHD; the external monitor can be attached |
| MacBook Pro M2 Max | macOS 27 | the external monitor can be attached |

The external monitor is the Framework's only monitor, so multi-monitor tests run on the laptops.

## Where things go

One folder per release cycle, named after the release's tag (`v0.4.3/`). Its release candidates
share it: `v0.4.3-rc.2` is `v0.4.3/rc.2/`.

| | |
|---|---|
| `<cycle>/NOTES.md` | The one log of the cycle, release candidates included. Newest last |
| `<cycle>/<candidate>/PLAN.md` | A candidate's plan, with each machine's table of results (`v0.4.3/rc.1/PLAN.md`) |
| `<cycle>/<candidate>/<machine>/` | That machine's logs, outputs and screenshots (`v0.4.3/rc.1/acer/`); the machines are `framework`, `acer` and `mac` |
| `<cycle>/rc.N-pre/<machine>/` | Checks on the branch before candidate N is tagged; their steps are in `rc.N/PLAN.md` |
| `<cycle>/release/` | Checks on the release itself, with a `PLAN.md` if they have steps of their own |
| `<cycle>/parity/` | The cycle's parity set |
| `<cycle>/README.md` | The cycle at a glance: a row per candidate, added when it is tagged |

A new cycle starts with a new folder and an empty `NOTES.md`, whose first lines point to the
cycle before. The records of 0.4.0 and 0.4.2 were written under an older layout, and the paths
inside them are the old ones: `MOVED.md` lists each.

## How to work here

1. Start with `git pull`.
2. Read the cycle's `NOTES.md` from the end. Newer notes may change the instructions.
3. Open the current candidate's plan (e.g. `v0.4.3/rc.1/PLAN.md`) and run your machine's section,
   in order.
4. Write each result into your machine's table in that file. Save logs and screenshots under the
   candidate's folder for your machine (for example `v0.4.3/rc.1/acer/`).
5. Commit and push after each section, so a failure part-way still leaves results behind.
6. Add a dated note at the end of the cycle's `NOTES.md`: what you did, what failed, what you'd
   try next.

**Who does what**

| Claude session | Jimmie |
|---|---|
| Runs the commands, saves logs, reads them | Looks at the screen and answers the checks |
| Records exact versions, errors and timings | Decides anything about the machine itself (restarts, settings, admin rights) |
| Fills in the tables, commits, pushes | Says when something looks wrong that the checks don't cover |

## Rules

- **Install only as the plan says, into the places it names.** Don't run anything as administrator or
  edit the registry without asking Jimmie, and don't restart Explorer or the Finder without asking.
- **Don't change JETCARP's code here.** If something fails, record it exactly: the command, the full
  error and the version (`jetcarp --version`). The main session fixes it and makes the next
  candidate.
- **A failure is a result.** Record it and move on to the next step. Don't spend long on one step
  while others remain.
- **Keep secrets out.** No tokens, passwords or personal files in logs or screenshots. Crop or skip
  a screenshot that shows anything private.
- **Clean up.** At the end of a wave, uninstall as the plan says, so the next candidate starts clean.
