# JOSS readiness: JETCARP 0.4.2 against JOSS's rules as of 2026-11-18

This page compares JETCARP, as it stood at v0.4.2 (commit `a3e829a`, 2026-11-17), with what the
*Journal of Open Source Software* asks of a submission. The rules quoted are from JOSS's own pages,
fetched on 2026-11-18:

- Submitting a paper: <https://joss.readthedocs.io/en/latest/submitting.html>
- Review criteria: <https://joss.readthedocs.io/en/latest/review_criteria.html>
- Paper format: <https://joss.readthedocs.io/en/latest/paper.html>
- Policies (AI usage): <https://joss.readthedocs.io/en/latest/policies.html>

JOSS revised these rules in 2026. Read them again before each audit and before submitting: the
next auditor should fetch the pages afresh and diff them against the quotations here.

The checklist that follows from this page is tracked in jprodgers/jetcarp#184.

## The short answer

**JETCARP cannot be submitted to JOSS today, and the earliest date it could be is about
mid-May 2027.** Two of JOSS's four pre-review gates fail on the calendar alone, a third has no
evidence yet, and the AI-usage statement JOSS requires cannot be made truthfully as things stand.
None of this is about the quality of the program. Most of what JOSS asks for beyond these gates is
already in place, some of it to a standard few submissions reach.

A desk rejection on these grounds is, in JOSS's words, "a 'not yet,' rather than a 'never'". The
rest of this page says what would turn each "not yet" around, and by when.

## The four pre-review gates

JOSS: "Before entering review, all submissions are evaluated against the following gates. A
submission that fails any one of these will receive a desk rejection."

| Gate | JOSS's words | JETCARP at v0.4.2 | Verdict |
|---|---|---|---|
| 1. Public development history | "The repository must have been public for more than six months prior to submission, with active development spanning that period. A repository made public immediately before submission, or one showing development concentrated into a few days or weeks, will not be accepted. We run automated checks on commit distribution — a repo dump is not a history." | The repository was created on GitHub on 2026-11-12. Its 611 commits run from 2026-11-10 to 2026-11-17: eight days. The second commit, "Import CART as JETCARP", adds 223,547 lines in one step. | **Fails.** Earliest pass: 2027-05-12, and only with visible development between now and then. |
| 2. Demonstrated research impact | "There must be evidence that the software is being used for research — at minimum by the developers themselves, and ideally by others. Acceptable signals include: references in published papers or preprints, documented adoption by other research groups, or clear integration into research workflows… Aspirational statements about future use are not sufficient." | The book's *Findings* pages report results made with JETCARP and its predecessor (60 spaceships, a Life census on the Archimedean and k-uniform tilings, the eleven graphs of the isohedral types). There is no paper or preprint, no citation, and no user outside the project beyond two bug reports from one person. | **Not yet shown.** A preprint that uses JETCARP would meet the minimum. |
| 3. Good open-source practices | "For single-author projects… multiple indicators must be present at submission time: a meaningful public commit history over time, tagged releases or a changelog, tests and CI, clear documentation, a CONTRIBUTING file, and stated support or governance expectations." | Tagged releases, a changelog, tests and CI on three systems, a book, `CONTRIBUTING.md`, a code of conduct, a security policy, issue and PR templates: all present. "Over time" is the missing part (gate 1), and there is no stated support channel or governance line. | **Passes except for time**; two small gaps (below). |
| 4. Iterative development over time | "The development history must show ongoing iteration, not a single burst of commits… A repository where all significant work was added in a concentrated window is a signal that the project was not developed iteratively." | All significant work is in one eight-day window. Within it the iteration is real and well recorded (five release candidates, 141 issues, each fix tied to a commit), but JOSS means months. | **Fails** until there is a record over months. |

The review criteria repeat the point for reviewers: "Not acceptable: All or most commits
concentrated in the last few weeks before submission", and for a single author, "Not acceptable:
Single author with no evidence of community engagement, external use, or collaborative input".

## The AI-usage disclosure

JOSS permits AI-written software and requires an "AI usage disclosure" section in the paper with
three parts. The third is the hard one:

> Confirmation of review: Authors must assert that human authors reviewed, edited, validated all
> AI-assisted outputs and made the core design decisions.

and, in the policies page, "Authors must affirm that human team members thoroughly reviewed,
modified, and validated all AI-generated content while making primary architectural and design
decisions." JOSS adds: "Failure to provide a complete and accurate disclosure of AI usage may be
considered an ethical breach."

What JETCARP's own record says:

- "All of its code was written by Claude Code… Jimmie wrote no code, test code included" (`how-made.md`).
- Jimmie "asked for the features in the app rather than designing its interface" (same page).
- The checks described are tests, hands-on testing on three machines, exact re-verification of
  results, and audits "largely run by Claude agents under Jimmie's direction". No page says that a
  person read the code.
- The repository has one pull request, with no review recorded on it; 424 of 611 commits went
  straight to `main`.
- The code grew from about 170,000 lines to 254,566 lines of Rust between 2026-11-10 and
  2026-11-17. Nobody can read 85,000 new lines in a week alongside the testing that was done.

So of JOSS's three verbs, **validated** can be claimed with evidence (this is where JETCARP is
strong: the test records, the parity sets, the exact re-verification), **edited** cannot be claimed
for the code, and **reviewed** can be claimed for behaviour but not for the code itself. "Made the
core design decisions" is true of what JETCARP is and does, its rules, its research direction and
its release decisions, and less clearly true of its software architecture.

This audit also shows why JOSS asks. It found a rule family that computes the wrong thing on mixed
tilings (jprodgers/jetcarp#171), where the CPU and GPU agree with each other, every test passes, and one part
of the code carries a comment that knows about the limit while the rest of the program and the
book do not. Testing by the same author as the code did not find it; a reader of the code would
have.

**What to do about it.** Three honest routes, not exclusive:

1. **Write to the JOSS editors before submitting** (a pre-submission enquiry) with the disclosure
   as it truthfully is, and ask whether validation by testing plus independent audits meets the
   "reviewed" requirement. Better to hear the answer in 2026 than in a desk rejection in 2027.
2. **Make the statement true for a defined core.** Over the next six months, read and come to
   understand `jetcarp-core`'s central path: the neighbour graph (`topology.rs`), the steppers
   (`step.rs`, `rules.rs`), pattern verification (`pattern/verify.rs`) and the state hash. That is
   a few thousand lines, not 255,000. Record the reading as reviews on pull requests. The paper can
   then say exactly what a person reviewed and what was validated by other means.
3. **Bring in a human reviewer or co-author** who reads Rust and knows cellular automata, and
   record their review in the open. JOSS treats "a single developer working closely with… domain
   experts" who are co-authors as "meaningfully different from a solo project".

Whatever the route, the disclosure should name the model and versions (Claude Code, Opus 5.5 for
the program; a different model for the audits), say that the book's first drafts and the test
plans were AI-written, and point to `how-made.md` and to these audit reports.

## Authorship

JOSS: "You must be a major contributor to the software you are submitting", and "purely financial…
and organizational… contributions are not considered sufficient for co-authorship… but active
project direction and other forms of non-code contributions are." Reviewers are asked to check
"whether the submitting author has made a 'substantial contribution' to the submitted software (as
determined by the commit history)".

Every commit is authored by Jimmie Rodgers and 610 of 611 carry `Co-Authored-By: Claude Opus 5.5`.
Project direction, design of the rules (JACA, the layered rules), the research questions and all
hands-on testing are his and are documented. This fits "active project direction", but it is new
ground for JOSS, and a reviewer may ask what the author contributed that the commit history can
show. The answer should be easy to find: keep `how-made.md` current, and consider putting design
notes and decisions in the repository under the author's own hand (issues, discussions, an ADR
folder) so the human contribution is in the record and not only described.

## The paper

There is no `paper.md` or `paper.bib` in the repository. JOSS wants 750 to 1,750 words with these
sections, and "Your paper must not focus on new research results accomplished with the software".

| Required section | What JETCARP already has to draw on | What is missing |
|---|---|---|
| Summary | README, `introduction.md` | The paper itself |
| Statement of need | `automata/generalising.md` ("What is new here"), `research/contributions.md` §7 | A short statement of who needs it and for what research |
| State of the field ("build vs. contribute") | The book's history sections name Golly, Ready, HatLife, SpectreLife, Edmond's monotile-ca, aperiodic-life, LifeViewer | A direct comparison table, and why JETCARP was built and not added to Golly or Ready |
| Software design (trade-offs) | The graph model with three storage kinds, deterministic maths, the state hash, packs | Written as design reasoning. This section is where the author's own decisions must show |
| Research impact statement | The Findings pages; this audit re-verified all 104 published spaceships independently | A preprint or paper that uses JETCARP; outside users; the ConwayLife community's check, which the book says "is still to come" |
| AI usage disclosure | `how-made.md` | See above |
| References | `docs/data/bibliography.bib` | A `paper.bib`, checked entry by entry |

Since the paper may not centre on new results, the spaceship and census findings belong in a
separate preprint (arXiv, or the ConwayLife forums and LifeWiki for the community's check). That
preprint is also the strongest answer to gate 2.

## The review checklist

| Item | State at v0.4.2 | Notes |
|---|---|---|
| OSI licence, in a file | Yes | `UNLICENSE`, `LICENSE-MIT`, `COPYING`; third-party notices kept and checked in CI |
| Repository browsable, issues open without approval | Yes | |
| Installation | Yes, by six routes | But the stated minimum Rust (1.95) is wrong: the workspace loads only on Rust 1.99 or newer (jprodgers/jetcarp#175). A reviewer on a distribution toolchain would fail at the first command |
| Example usage | Yes | Tutorials, guides, a scene for every figure |
| Functionality documentation | Yes | Book; generated CLI and MCP references checked against the program in CI |
| API documentation | Partly | The crates are published, but the book documents the program, the scripting API and the MCP tools, not the Rust API. Say in the paper that the interface is the CLI, scripts and MCP, or add rustdoc coverage |
| Tests | Yes | 1,100+ tests, CI on three systems. One test is timing-sensitive under load (see the report) |
| Community guidelines: contribute, report, seek support | Mostly | Contribute and report: yes. **Seek support: no stated channel.** Discussions are enabled; say so in the README and `CONTRIBUTING.md` |
| Statement of need in the documentation | Partly | Spread across pages; put a short one in the README |
| Substantial scholarly effort | Yes by size and scope | JOSS weighs history, not size |

## A timetable

| When | What | Why |
|---|---|---|
| Now | Fix the issues this audit filed. Decide the privacy and security items privately | Correctness first |
| Now | Write to the JOSS editors about the AI-usage statement | The answer shapes the next six months |
| Nov 2026 – May 2027 | Develop in the open, steadily: issues, pull requests with a recorded review, a release every few weeks | Gates 1 and 4 are measured from the commit record |
| By early 2027 | Post the findings as a preprint; take them to the ConwayLife community | Gate 2; and the check the book says is still to come |
| By early 2027 | Find at least one outside user or reviewer; answer their issues in the open | "Collaborative effort"; a second pair of human eyes on the code |
| Each audit (every 3–6 months) | Re-run this page's table against the then-current JOSS rules | The rules changed in 2026 and may change again |
| From 2027-05-12 | Earliest submission, if the above is in the record | Six months public |

## What already stands out

A reviewer who gets past the gates will find things most submissions lack: a public record of
every problem found and how it was handled; test records from three machines and seven GPU
back ends that an outsider can re-run (this audit reproduced all 371 parity hashes on a fourth
machine); a provenance audit with its mistakes listed; exact, exactly documented geometry for
1,248 k-uniform tilings that this audit validated from scratch; and an unusually candid account of
how the program was made. The gap is time, outside eyes, and a truthful review statement, not
substance.
