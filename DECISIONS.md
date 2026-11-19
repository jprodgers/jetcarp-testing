# Decisions

What the people working on JETCARP have decided about how releases are tested and what these
records publish, and why. The decisions about the program itself are in its own page,
[jetcarp/DECISIONS.md](https://github.com/jprodgers/jetcarp/blob/main/DECISIONS.md), whose entries
are numbered D-01 and up; the ones here are numbered T-01 and up.

## How this page is kept

- One entry per decision. Entries are numbered and never renumbered.
- A decision that changes gets a new entry, which names the one it replaces. The old entry stays,
  marked as replaced.
- Each entry says who decided and when. An entry written down after the fact says so.
- **Claude's part** says where an idea, or the options, came from the AI coding assistant. Where an
  entry has no such line, there was none.
- Words in quotation marks are the decider's own.

**How the first entries were written.** On 18 November 2026, during the independent audit of 0.4.2,
the auditor (Claude, in Claude Code) interviewed Jimmie Rodgers in writing and drafted T-01 to T-11
from his answers and from the public record. Jimmie corrected and approved them. Quotes with no
source named are from that interview or from his request for the audit.

## Testing

### T-01. Every release is tested on real machines, by hand as well as by script

- **Decided:** Jimmie Rodgers, for the first release candidates (November 2026).
- **The decision:** Jimmie decided what needed checking and how thoroughly: "every operating system
  and GPU vendor, the upgrade path, a newcomer's first hour, full passes rather than quick ones, an
  issue for every problem" (the book,
  [How JETCARP is tested](https://jprodgers.github.io/jetcarp/about/testing.html#who-does-what)).
- **Why:** JETCARP's code is written by an AI coding assistant, and Jimmie does not take it on
  trust: "I don't know Rust well enough to say if it's good or not, so I test to make up for that
  failing on my part." "I chose to have Claude write it for speed and efficiency, and to test it to
  hell and back."
- **Stands.**

### T-02. Who does what in a test

- **Decided:** Jimmie, November 2026.
- **The decision:** Jimmie approves each test plan, sits at each machine for every step that needs
  eyes or hands, judges the results, and decides which problems hold a release back. A Claude Code
  session on each machine runs the plan's commands and records the results; a main session reads
  them, files the issues and makes the fixes. Jimmie writes no test code (`RULES.md`; the book's
  testing page).
- **Stands.**

### T-03. The machines are the ones Jimmie owns

- **Decided:** Jimmie. Written down 18 November 2026.
- **The decision:** three machines, with GPUs from four vendors: Linux with AMD, Windows with
  NVIDIA and Intel, macOS with Apple. "They are simply what I own and have access to, but it
  happens to be a pretty good selection for development." No fourth is planned for now.
- **Stands.**

### T-04. A failure is a result, and every problem gets an issue

- **Decided:** Jimmie, November 2026 (the rules the test sessions were given).
- **The decision:** a test session records a failure exactly and moves on; it does not change
  JETCARP's code. Every problem found becomes an issue in
  [jprodgers/jetcarp](https://github.com/jprodgers/jetcarp/issues) that says where it was found
  (`RULES.md`).
- **Stands.**

### T-05. What does not work as intended does not ship, and a candidate is tagged only on Jimmie's go

- **Decided:** Jimmie.
- **The decision** is D-26 and D-27 of the program's page. Its record is here: `v0.4.2/rc.3/PLAN.md`
  (how fixes are divided between candidates), `v0.4.2/rc.4/PLAN.md` (a feature taken out because it
  could not be made to work in time) and `v0.4.2/rc.5/PLAN.md` (a fifth candidate for one fault).
- **Stands.**

## What is published

### T-06. The test records are public

- **Decided:** Jimmie, 16 November 2026 (`v0.4.2/NOTES.md`, the entry of 5:35 AM that day).
- **The decision:** everything committed to the working repository in which the tests are planned
  and recorded is published here after each wave, less what T-07 and T-08 leave out.
- **Why:** "I want to be very clear about what I have and haven't done, what I have and haven't
  found, and what I have and haven't read or tested. I'm developing in the open for everyone to
  see, audit, and verify. I don't wish to mis-label or mislead."
- **Stands.**

### T-07. Evidence stays as recorded; personal details that are not evidence are masked

- **Decided:** Jimmie, 16 November 2026; widened 18 November 2026 after the audit.
- **The decision:** the logs, outputs, tables and notes are published as the sessions wrote them.
  What identifies a person or a machine and is not evidence is masked, each kind listed in
  `WITHHELD.md`. The names of the user accounts and folders the tests ran in, tool and driver
  versions, GPU names and timings are evidence, and stay: "Lots about the testing environment I
  purposefully made public."
- **Stands.**

### T-08. A security problem's records wait for the fix

- **Decided:** Jimmie, November 2026.
- **The decision:** the records of a problem that could put users at risk are left out of this copy
  until a release fixes it and it is described publicly; then they are added (D-25 of the
  program's page; `README.md`).
- **Stands.**

### T-09. The sessions' chats are not published; the records are the evidence

- **Decided:** Jimmie. Written down 18 November 2026.
- **Why:** "I have chosen to keep the actual chats private, as I talk to Claude about personal
  issues mixed in with the chats", and they hold "the actual file-paths and such on my computers."
  What a session needs another to know, or a reader to check, goes into these files.
- **Stands.**

### T-10. One folder per release cycle, with one running log

- **Decided:** Jimmie, 18 November 2026.
- **The decision:** "Moving forward I want a single NOTES.md per release cycle. That means when we
  start 0.4.3 we get a new folder in the repository, and when we're inevitably on 0.4.3-rc.2, its
  notes share that of the 0.4.3 directory."
- **Claude's part:** the layout itself (folders named after the tags, each plan beside its
  results, `MOVED.md`, and leaving the paths inside the records as written). Jimmie approved it.
- **Stands.** `MOVED.md` lists where everything was before.

### T-12. The public copy's history starts afresh

- **Decided:** Jimmie Rodgers, 18 November 2026, after the audit's privacy pass.
- **The decision:** the repository that held the first public history (16 November 2026 to
  `7fbd762`, and the audit's pull request) was renamed and made private, and is kept by the
  maintainer. A new `jprodgers/jetcarp-testing` was started on 18 November 2026 with one commit:
  the masked copy, arranged by cycle (T-10), with the audits. Each publish since adds to that
  history, and stops if anything is left to mask or a new identifier turns up (`WITHHELD.md` lists
  each kind of mask). The program's repository keeps its history: the one detail there concerned
  another person, who was asked and answered that no change was needed (the audit's report,
  *Privacy*).
- **Why:** the masks of T-07 only protect a repository whose history never held what they mask,
  and the first one's did. It was kept rather than deleted: "A restructuring needed to occur for
  future development, and I wanted a snapshot of it before we changed anything. I can always share
  the private repository with human auditors later if they request it." (Jimmie, to the main
  session, 18 November 2026.)
- **Claude's part:** the auditor (Claude, in Claude Code) found the details, wrote the masks, and
  suggested starting the public history afresh, which Jimmie agreed to; it set out the steps, and
  the main session (Claude, in Claude Code) carried them out and made the masks' check a gate on
  every publish.
- **In the record:** `audits/README.md`; the November 2026 report's *Privacy* section;
  `WITHHELD.md`.
- **Stands.**

## Audits

### T-11. An independent audit every three to six months, published here in full

- **Decided:** Jimmie, 18 November 2026.
- **The decision:** a fresh session with no part in writing the program audits it every three to
  six months, until JETCARP is ready for publication, and the report goes here whole: "Give me the
  good, the bad, the ugly." "I want to be open with this audit, so we'll be publishing the
  results." Bugs and documentation errors become issues in the program's repository.
- **Privacy and security findings** go to the maintainer privately. The public report says that
  there were some and what was done, not what they were.
- **In the record:** `audits/`.
- **Stands.**

## Open

Nothing at present.
