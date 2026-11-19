# JETCARP's test records and audits

The plans, logs and results of the testing behind each JETCARP release, and the independent audits
of the program. Every release candidate is tested on three machines, with GPUs from four vendors,
before it can become a release. The process is described in the JETCARP book,
[How JETCARP is tested](https://jprodgers.github.io/jetcarp/about/testing.html); this repository
is its evidence. The program is at [jprodgers/jetcarp](https://github.com/jprodgers/jetcarp), and
every problem found here has an issue there, saying where it was found. A security problem is the
exception until it is fixed (see below).

## What is here

One folder per release cycle, named after the release's tag. A cycle's release candidates share
that folder: `v0.4.2-rc.1` is `v0.4.2/rc.1`.

| | |
|---|---|
| [`v0.4.0/`](v0.4.0/README.md) | The first public release: three candidates and the release, 11 to 13 November 2026 |
| [`v0.4.2/`](v0.4.2/README.md) | Five candidates and the release, 14 to 17 November 2026 |
| [`audits/`](audits/README.md) | Independent audits of the program: reports, method, the harness they ran, and their logs |
| [`DECISIONS.md`](DECISIONS.md) | What was decided about the testing and about what is published here, by whom and why |
| [`RULES.md`](RULES.md) | The rules the test sessions work by |
| [`WITHHELD.md`](WITHHELD.md) | What this public copy leaves out or masks, and why |
| [`MOVED.md`](MOVED.md) | Where each file was before November 2026's rearrangement, for reading an old path |
| `tools/` | The script that made the rearrangement |

0.4.1 (13 November 2026) was a small release without candidates, and has no records here.

## Inside a cycle

```
v0.4.2/
├── README.md       the cycle at a glance: candidates, tags, machines
├── NOTES.md        the running log between the sessions, oldest first: one for the whole cycle
├── parity/         the cycle's parity set: scenes, and the hashes every CPU and GPU must give
├── rc.1/
│   ├── PLAN.md     the candidate's plan: each step, what to run, what counts as a pass,
│   │               and each machine's table of results
│   ├── acer/       that machine's logs, outputs, scripts and screenshots for this candidate,
│   ├── framework/  with its notes.md, progress.md or summary
│   └── mac/
├── rc.2/ …
├── rc.4-pre/       checks run on the branch before a candidate was tagged (steps in rc.4/PLAN.md)
└── release/        checks on the release itself
```

To follow one candidate, read its `PLAN.md` first, then the cycle's `NOTES.md` between the dates
in the cycle's README, then the machine folders the plan's tables point to.

The records are as the sessions wrote them, so **the paths written inside them are the old ones**
(`results/v0.4.2-rc.3/acer/…`, `rc1.md`, `NOTES.md`). [`MOVED.md`](MOVED.md) gives the new place
of each.

The machines are `framework` (Linux, AMD Radeon 8060S), `acer` (Windows 11, NVIDIA RTX 3050 Laptop
and Intel UHD) and `mac` (macOS, Apple M2 Max); their full specifications are in the book.

## How it was made

Each machine's steps were run by a Claude Code session working from the written plan, with Jimmie
Rodgers at the machine for every step that needed eyes or hands, and a main session reading the
results, filing the issues and making the fixes. The records are as those sessions wrote them;
paths name the test folders and user accounts they ran in. See the book's page for who did what,
and for what this testing does not cover.

This is a copy of the private repository the sessions work in, regenerated after each wave.
[`WITHHELD.md`](WITHHELD.md) lists what the copy leaves out or masks.

## Security problems

A problem found here that could put JETCARP's users at risk is handled privately until a release
fixes it: until then its records are left out of this copy, and `WITHHELD.md` says how severe it
is, which releases have it and which one fixes it. The records are added once that release is out
and the problem is described publicly. The two found during the 0.4.2 cycle were fixed in 0.4.2,
and their records are in `v0.4.2/`.

## Audits

[`audits/`](audits/README.md) holds the independent audits: a fresh session on a clean machine
that reads the code, runs it against reference code of its own, re-runs the published parity sets,
and checks what the documentation claims against these records. They are planned every three to
six months.

## Copying

Public-domain research records: dual-licensed under the [Unlicense](UNLICENSE) and the
[MIT licence](LICENSE-MIT), at your option, like JETCARP itself.
