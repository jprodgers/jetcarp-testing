# Independent audits of JETCARP

JETCARP's code, tests and first-draft documentation are written by an AI coding assistant under
one person's direction. These audits are the outside check on that: a fresh session, on a clean
machine, with a clean clone of the public repositories, that reads the code, runs it, compares it
with reference code of its own, checks what the documentation and the process pages claim against
the record, and reports what it finds, good and bad. Bugs and documentation errors become issues
in [jprodgers/jetcarp](https://github.com/jprodgers/jetcarp/issues); the reports are published
here, next to the test records they draw on.

Audits are planned every three to six months until JETCARP is in a good place for publication.

| Audit | JETCARP | Auditor | Report |
|---|---|---|---|
| November 2026 | 0.4.2 (`a3e829a`) | Claude, in Claude Code, at Jimmie Rodgers's request (a different Claude model from the program's author; the commit names it) | [`2026-11-v0.4.2/REPORT.md`](2026-11-v0.4.2/REPORT.md) |

- [`METHODOLOGY.md`](METHODOLOGY.md): how an audit is run, what each part checks, how findings
  are handled, and how to run the next one.
- Each audit's folder holds its report, its assessment against JOSS's rules, the harness it ran
  (source, with instructions), and its logs. Work that followed a report in the same weeks is in
  the same folder and is listed at the report's end ("Since the report").

A report describes the test records as they were at the commit it names. The November 2026 audit
read them at `7fbd762`, before they were rearranged into one folder per release cycle: a path it
gives in the old layout is mapped by [`../MOVED.md`](../MOVED.md).

This public repository was started afresh on 18 November 2026, from the masked and rearranged
copy, so `7fbd762` is not in its history: it is in the earlier history, which the maintainer keeps.

What an audit is not: it is not a human expert's review, and the auditor is an AI model from the
same company as the one that wrote the program. The methodology page says what independence the
audit has and where it stops, and each report lists what it did not cover.
