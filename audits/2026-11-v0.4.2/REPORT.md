# Independent audit of JETCARP 0.4.2

| | |
|---|---|
| Audited | `jprodgers/jetcarp` at `a3e829a` (tag `v0.4.2`, 2026-11-17), all history; `jprodgers/jetcarp-testing` at `7fbd762`; the issue tracker, releases and workflow runs as of 2026-11-18 |
| Auditor | Claude, in Claude Code, in a fresh cloud container, at Jimmie Rodgers's request: a different Claude model from the one that wrote the program (the commit that added this report names it; the program's commits name Claude Opus 5.5). Three helper sessions of the auditing model did the privacy scan, the tracker and process audit and the documentation audit; their findings were re-verified before use |
| Date | 2026-11-18 |
| Method | [`../METHODOLOGY.md`](../METHODOLOGY.md) |
| Issues filed | 14, jprodgers/jetcarp#171 to #184 |

This is the first of a series of audits. It was asked to be meticulous and to give the good, the
bad and the ugly. It is not a human expert's review, and the auditor is an AI model from the same
company as the one that wrote the program; what that independence is worth, and where it stops, is
set out in the methodology. Nothing in the audited repositories was changed.

## Summary

**The good.** The engine's mathematics held up under an independent check that shares no code with
it. Every one of 1,355 periodic tilings has exactly the neighbour graph that separate geometry
gives it; the 1,248 k-uniform tilings are what their names say; the Penrose, hat and spectre
patches have the textbook properties; rule families from Life to the sandpile to the project's own
JACA match naive reference code; all 104 spaceships the book publishes are spaceships, with the
periods stated; the hunt's census of Conway's Life agrees with Catagolue's to within one
percent for the common objects; and all 371 published parity hashes reproduce on a machine the
project never saw. The test records are real evidence, the tracker is disciplined, the examples in
the book reproduce to the exact hash, the bibliography is real, and the account of how the program
was made is unusually candid.

**The bad.** Life-like rules with birth on 0 can compute the wrong thing on any tiling whose tiles
have different neighbour counts, which is most of the tilings the project is about, on the CPU and
the GPU alike, with every test passing. The stated minimum Rust version does not build the project.
Larger than Life silently drops part of a rule on tilings with large neighbourhoods. The state
hash leaves out part of the state. The book repeats three universal claims that the program does
not bear out, carries counts and "planned" notes from two releases ago, and states a few things
about its own testing process that the record contradicts.

**The ugly.** JETCARP cannot be submitted to JOSS before about mid-May 2027, whatever its quality:
its whole public history is eight days. JOSS also requires the authors to affirm that people
reviewed all AI-written output, and nothing in the record shows a person reading the code. The
B0 bug is the proof of why that matters: one comment in the code knew the limit, and neither the
rest of the program, the tests, the book nor the author did. And the security review this audit
set out to make is unfinished.

## Findings

Ranked. A "private" finding was reported to the maintainer directly and is not described here.
The privacy pass is reported separately (see *Privacy*).

| # | Severity | Finding | Where |
|---|---|---|---|
| 1 | High | JOSS's pre-review gates on public history and iterative development fail on the calendar; no evidence of research use yet; no paper | [`JOSS-READINESS.md`](JOSS-READINESS.md), jetcarp#184 |
| 2 | High | The AI-usage statement JOSS requires ("human authors reviewed, edited, validated all AI-assisted outputs") cannot be made truthfully as things stand; no code review is recorded anywhere | same |
| 3 | High | B0 Life-like rules give wrong results on tilings whose tiles have different neighbour counts, on CPU and GPU | jetcarp#171 |
| 4 | High | The workspace does not load on Rust 1.95 to 1.98, the stated minimum being 1.95; CI never builds the minimum | jetcarp#175 |
| 5 | High | "Every rule runs on every tiling" (11 places) and "every simulation result is checked" (README) say more than the program does | jetcarp#177 |
| 6 | Medium | Larger than Life drops birth and survival counts above the square grid's neighbourhood size | jetcarp#172 |
| 7 | Medium | The state hash omits a turmite's internal state (and, by reading, the random generator and two other pieces of hidden state) | jetcarp#173 |
| 8 | Medium | The testing and how-made pages state things the record contradicts: tagging only on green CI, security fixes "fixed privately", "withheld records", "on every machine" | jetcarp#174 |
| 9 | Medium | Research pages: the ship count does not add up as written; one prior-work sentence contradicts another page; the search log the novelty claims rest on is not published | jetcarp#179 |
| 10 | Medium | Catagolue and apgsearch, the prior work for the soup hunt, are never mentioned; two objects differ from Catagolue's census by more than chance | jetcarp#182 |
| 11 | Medium | Counts and status text left from 0.4.0 ("170,000 lines in twelve crates", "29 claimed", "packs come in a later release", and more) | jetcarp#178 |
| 12 | Medium | WireWorld with its default start is refused on every tiling but squares | jetcarp#180 |
| 13 | Medium | The security review is incomplete (see *Security* below) | this report |
| 14 | Low | One security finding | Private |
| 15 | Low | A timing test fails on a busy machine | jetcarp#176 |
| 16 | Low | CI gaps: no clippy, advisory check, job timeouts, pinned actions or branch protection; the documented build needs over 28 GB | jetcarp#183 |
| 17 | Low | Small reference errors; three generated pages nothing checks | jetcarp#181 |

## What was checked and found sound

Numbers are from this audit's runs; the harness and its output are in [`harness/`](harness/) and
[`logs/`](logs/).

### The engine, against independent reference code

| Check | Size | Result |
|---|---|---|
| Neighbour graphs of every periodic tiling (20 built-in families, 1,254 catalogue entries, 81 isohedral types) against separate geometry at tolerances 10,000 times tighter than the engine's | 1,355 tilings; 2,472,216 interior cells; both neighbourhoods | Identical. Edge slots wind the same way in every cell, so turns mean the same thing everywhere |
| Wrapped grids as graphs: symmetric, no self loops, no repeated neighbours, edge ⊆ touch, tile areas sum to the torus | 2,710 tori | No exception |
| The k-uniform catalogue from its geometry alone: regular unit polygons; the vertex types in each name; polygons and vertices per cell in each note; never more vertex classes than k; no two entries alike | 1,248 entries (11, 20, 61, 151, 332, 673 for k = 1 to 6, Galebach's counts) | All consistent. Vertex classes equal k for 1,229 entries at radius 7 and for 1,244 at radius 16; the other 4 show fewer than k (inconclusive at that radius), none more |
| Aperiodic patches: counts, neighbour lists, no gaps, no overlaps | Penrose kites and darts, Penrose rhombs, hat, spectre; levels 1 to 5 | Exact. Each Penrose tiling shows exactly its seven vertex figures; the hat's mirrored tiles are 12.74 % (theory 12.73 %); the spectre's counts obey a(n+1) = 8a(n) − a(n−1) |
| The 81 isohedral types fall into 11 neighbour graphs | coordination sequences from every tile | 11 classes: 30 square, 19 hexagonal, 8 triangular, 3 Cairo, as the book says |
| Tiling symmetries used for pattern identity are automorphisms of the neighbour graph | 16,206 maps over 1,355 tilings | All are |
| Life-like and Generations rules against a naive stepper | 11 rules × wrap, dead and live edges × 3 sizes, 60 generations | Identical |
| Larger than Life on squares, both notations, Moore and von Neumann, two and four states | 12 cases | Identical |
| Elementary rules; Langton's ant (highway after 11,000 steps, 104-step cycle, 834 black cells) | | As the literature says |
| The sandpile against one-at-a-time toppling, lost grains included | squares, four mixed-degree tilings, four aperiodic patches; up to 60,000 grains | Identical; grains conserved |
| JACA against a reference written from the book's definition | 6 tilings × 7 rules, blast 0 to 3 | Identical |
| The named Margolus tables (BBM, Critters, Tron, HPP, Single Rotation) | by reading | Equal to MCell's published tables |
| Lenia: the standard Orbium | 400 generations | Glides with steady mass and speed |
| The engine's own SHA-256 against RustCrypto's | 311 message lengths | Identical |
| Results do not depend on the thread count | 9 rule and tiling pairs; 1, 3 and 4 threads | Identical hashes |

The Penrose rhomb construction, rewritten "clean-room" before release, was read line by line: it
is the standard Robinson-triangle deflation.

### Research results

- **All 104 published spaceship scenes** (60 findings, 44 from the Life census) were re-run with
  the audit's own stepper on tori of at least 128 × 128 unit cells: each recurs after exactly its
  stated period as a lattice translate of its start, and no sooner. Not checked: the stated
  displacements, the rule ranges, and novelty.
- **The Life soup hunt against Catagolue.** 150,000 soups gave 3.25 million objects of 99 kinds;
  every kind is in Catagolue's table under the code computed from JETCARP's cells, and the shares
  of the common objects agree closely (block 30.84 % against 30.89 %, blinker 28.69 against 28.69,
  beehive 16.33 against 16.37, loaf 4.83 against 4.83). Two objects differ by more than chance
  (finding 10). [`logs/catagolue-comparison.txt`](logs/catagolue-comparison.txt).
- None of the catalogued results depends on finding 3: hunts, the census, pattern verification and
  the exploratory search all exclude B0 rules.

### Reproducibility

- **The published parity sets on a fourth machine.** Built from source at `a3e829a`, this
  container's CPU gives all 371 hashes after 300 generations and all 40 after 5,000, and Mesa's
  llvmpipe 20.1 (a version in none of the project's records) gives all 371, with the same split
  the records show: 334 scenes wholly on the GPU, 36 on the CPU, 1 in part. [`logs/`](logs/).
- **The published records are consistent.** 84 parity result files across five candidates and
  seven adapter and API combinations: every CPU and GPU hash equals the expected one, except the
  Intel UHD's sandpile-drop failure on `rc.1`, which the records report and `rc.2` fixed.
- The book's reproducibility example prints the hash the book gives, on one thread and on four.
- The pattern-verification code (`pattern/verify.rs`) was read: a dead-edged frame, an exact
  comparison with the stored phases every generation, and failure if a live cell touches the edge.
  Sound for the range-1 rules the catalogue holds. Its margin does not scale with steps per
  generation or with a rule's range; neither arises in what the hunts store.

### The project's own tests, here

Built and run as CI's Linux job does, with debug information off to fit the disk: 137 test
binaries, **1,064 tests passed, 1 failed, 41 ignored**, 44 minutes on four shared cores. The one
failure is a timing test that fails when the machine is busy (finding 15). No test wrote to the
default folders. `cargo fmt --check` passes. Clippy, which CI does not run, reports no error and
nothing in its correctness group: 47 style and complexity warnings in 254,566 lines.

### Process

Checked by the tracker and process audit (169 issues and one pull request, 262 workflow runs, 11
releases), and good:

- Every range and count in the book's table "The 0.4.2 cycle in numbers" matches the tracker.
- All 102 issues closed as completed have a commit on `main` that cites them; 99 are cited in a
  later candidate's test plan and 101 in a results file.
- Negative results are written down: a changelog entry corrected to say only the crash was fixed
  (#52), a first fix recorded as failing (#95), a diagnosis retracted in the thread (#119).
- A feature that missed its target was pulled and the book cleaned of it (#112).
- Outside reports were answered in 26 and 16 minutes.
- Releases: one workflow for candidates and releases, pre-release flags right, checksums and
  provenance attestations on every asset, notes identical to the changelog.
- The workflows' permissions are tight, and no published final release came from a commit whose
  CI ended red.
- AI authorship is disclosed in the book and in 610 of 611 commit trailers.

### Documentation and scholarship

Checked by the documentation audit, and good: about 150 numbers in the book against the program
(seven mismatches, all filed); every "Try it" command and three tutorials to the exact hash; 121
rule-notation examples and 46 documented refusals; all 231 pictures that carry their scene replay
to their recorded hash; three reference pages generated from the program and enforced in CI. **All
136 DOIs and 27 arXiv identifiers in the bibliography resolve to the works cited**, the recent
ones included; none of the 266 entries was found to be invented. 60 of 60 named-rule credits agree
with MCell's lexicon. The novelty claims are hedged and carry "not claimed" lists.

"JETCARP makes no network connections" holds by inspection: the dependency list has no HTTP, TLS
or DNS client, and the only sockets in the code are bound to 127.0.0.1.

## The findings in more detail

**B0 rules on mixed tilings (3).** The stepper runs a rule with birth on 0 by an
alternating-background emulation that picks its masks from each cell's own degree and assumes its
neighbours are stored the same way. That is exact when every tile has the same number of
neighbours, or when none or all of the degrees present are in the survival list. Otherwise it is
wrong from the third generation, in a quarter to a half of the cells in the audit's runs: on
4.8.8, 3.6.3.6, the snub square and other Archimedean tilings, and on Penrose, hat and spectre
patches. The GPU shaders port the same logic, so the parity tests pass. HashLife refuses these
worlds with a message that says "the stepper's alternating-background emulation assumes one
degree": the limit was known in one place and never reached the stepper, the tests (which use the
square grid only), the book (which says the tests check the emulation against brute force) or an
issue. This is the case the project's testing page describes in the abstract: "a mistake made the
same way on the CPU and the GPU would pass".

**The minimum Rust (4).** Three manifests use a form that cargo rejected until 1.99. The audit
container came with Rust 1.97, so the first command failed. With a manifest-only change the whole
workspace type-checks on 1.95, so the stated minimum can be made true cheaply; what is missing is
a CI job that builds it.

**Universal claims (5).** The book has a careful page on which rule families are tied to one grid,
and eleven other places that say every rule runs everywhere. The README says every simulation
result is checked; what is true is that every catalogued pattern is verified and every run
replays, which is a strong claim already.

**Process statements (8).** `rc.1` was tagged before its CI run finished, and that run failed; the
fixes for the two security problems were on the public branch, with descriptive commit messages,
days before the advisories; the "withheld" records were restored and three places still say
withheld; the general description of release testing reads wider than what each candidate got
(four overnight runs in the cycle, none on the first three candidates). None of this is hidden:
it is all in the public record, which is how the audit found it. The pages should say what was
done. Also from the record: 14 fixes have neither a test nor a stated reason, and "checked to fail
without the fix" is written down for five.

**The hunt and Catagolue (10).** The hunt's defaults are Catagolue's convention, which makes
Catagolue both the prior work to cite and a free outside validation. Ship-ties are about 6 % fewer
than Catagolue's share and gliders 0.7 % more, across two runs. The hunt drops soups that
"explode" without a census, where Catagolue censuses everything; that, or the way touching objects
are separated, may be the cause. Neither is confirmed.

## Code hygiene and efficiency

- **Size and pace.** 254,566 lines of Rust in 13 crates (the book says "about 170,000 in twelve");
  611 commits in eight days, on the busiest days in 17 to 19 different hours of the day. The
  import held 162,437 lines of Rust in 9 crates; a week later there were 92,000 more. Commit messages are detailed. No person can
  have read this code at the rate it was written, which is the root of finding 2.
- **Unsafe code.** About 200 uses, nearly all in the operating-system wrappers of the host,
  display and screen-saver crates. The engine's are two parallel writers in the large-sandpile
  boards; the disjointness argument was read and holds. The OS wrappers were not reviewed.
- **Lints.** No lint configuration in the workspace; clippy is clean enough to enforce.
- **Design for speed.** There are four tiers: a general stepper, a bit-parallel board for hunts,
  HashLife, and the GPU. The general stepper measured about 20 million cell updates a second per
  core here (Life on a 2,048 × 2,048 torus through `jetcarp run`, on a busy shared machine, so
  treat it as an order of magnitude). That is far from a dedicated Life engine and is the price of
  one code path for every tiling; the hunt ran about 700 soups a second on four cores. Nothing
  records speed from release to release.
- **Determinism by construction.** The engine's own generator (SplitMix64, constants checked),
  its own exponential and trigonometry built from correctly rounded operations, and counter-based
  noise for the one stochastic rule are the right choices for the reproducibility the project
  claims, and the parity results bear them out.

## Privacy

Every file version in every commit of both repositories was scanned, with commit messages, issue
and comment text, and the metadata inside pictures, archives and data files; every screenshot in
the test records was looked at. **No secret was found**: no token, password or private key, in any
commit. The pass did find a small number of personal details that should not have been published,
in both repositories. They were given to the maintainer privately the same day. By the project's
rule, this report says that there were some and what was done, not what they were.

**What was done** (added 18 November 2026). The maintainer masked the ones in the test records,
where `WITHHELD.md` now lists each kind of mask, and on 18 November 2026 started that repository's
public history afresh from the masked copy, so that its history does not hold them. One detail
concerned another person. It is in neither the current files, the documentation nor any release of
the program, only in the history of its repository, and the maintainer chose not to rewrite that
history: the person was told and offered its removal, and answered that no change was needed.

## Security

Partly done, and reported privately where it found something.

- Read and found careful: the code that keeps file access inside the allowed folders (links
  followed by hand, loops refused, the path opened being the path checked), and the pack signing
  code, which uses standard Ed25519 SSH signatures from an established library, with separate
  namespaces. The workflows' permissions were read (see *Process*).
- One low-severity gap in a documented boundary was found and reported privately, as
  `SECURITY.md` asks. It will be described here once a release fixes it.
- **Not done:** a broader adversarial review (hostile packs, malformed scenes and packs, resource
  limits through the MCP tools, the local link before authentication, the installers, the
  operating-system wrappers). It was started and then stopped by the auditing model's own safety
  safeguards, which restrict some security-testing work. It is still owed, and is better done by
  a person with security experience than skipped.

## What this audit did not cover

- The app's interface, the desktop background and screen savers, the host, the installers and
  package-manager routes, and anything on Windows or macOS: this was one Linux container with no
  display and no hardware GPU.
- Most of the 185,000 lines outside `jetcarp-core`, beyond what the tests, the parity runs and the
  targeted reading above exercise. The search crate's object separation was checked from outside
  (Catagolue) and not read.
- In the engine: von Neumann's 29-state rule, the hexagonal row rules, turmites off the square
  grid, WireWorld circuits, HashLife on the unbounded plane, the large-sandpile boards, canonical
  pattern ids end to end, and the evolutionary and exploratory searches. The methodology lists
  these for the next audit.
- Novelty. The audit checked that the published objects are what they are said to be, not that
  nobody found them before.
- Test coverage was not measured.
- The security review, as above.

## Recommendations, in order

1. **Fix jetcarp#171** (exact emulation on any graph, or refuse), with tests on mixed tilings and
   on the GPU, and correct the book. Then #172, #173, #180.
2. **Deal with the items reported privately.**
3. **Make the minimum Rust true and keep it true** (#175): the manifest change, and a CI job.
4. **Correct the pages a reviewer reads first** (#177, #178, #174, #179).
5. **Write to the JOSS editors now** about the AI-usage statement, and start the six months:
   steady public development, pull requests with a recorded review, a preprint of the findings,
   the ConwayLife community's check, at least one outside user or reviewer (#184).
6. **Put a person's reading into the record** for a defined core of the engine. Finding 3 would
   not have survived a careful reading of `step_b0`.
7. **Adopt outside checks as tests**: the Catagolue comparison (#182), and whichever of this
   audit's harness tests are worth keeping in the repository. The three `finding_*` tests are the
   regression tests for #171 to #173.
8. **Close the CI gaps** (#183) and protect `main`.
9. **Commission the security review** this audit could not finish.
10. **Next audit in three to six months**, starting from the methodology's list.

## Tools and versions

Rust 1.100.0 (stable on the day) for builds and tests, and 1.95.0, 1.97.0, 1.98.0 and 1.99.0 for
the minimum-version check; Ubuntu 24.04, 4 cores, 15 GB; Mesa 25.2.8 with llvmpipe (LLVM 20.1.2)
as the software GPU. JOSS's pages and Catagolue's census were fetched on 2026-11-18.

## Since the report

Added on 18 November 2026. Everything above is as it was written; this section lists what
followed in the same week.

- **The findings are filed:** jetcarp#171 to #183, tracked in #184.
- **The decisions are on record.** Both repositories now have a `DECISIONS.md`: what the maintainer
  decided and why, and where the AI assistant proposed something that he accepted. The entries
  come from a written interview and from the public record. This is the record the JOSS assessment
  asked for where it says the author's own decisions must show.
- **The test records were rearranged** into one folder per release cycle, and more was masked
  (`MOVED.md`, `WITHHELD.md`). Paths this report gives are the old ones.
- **Guttesen's gliders, cell for cell.** The book said its snub-square ship matched H. S.
  Guttesen's figure "by eye" and that a cell-for-cell check awaited his configurations. With his
  public repository, and three configurations he sent the maintainer, the check was made: both of
  JETCARP's published ships are his gliders cell for cell, and JETCARP's engine runs his large
  glider (period 40), a bouncer (period 116) and his glider gun (period 276) exactly as an
  independent implementation of his lattice does, over 1,968 generations and 521,916 live cells.
  The method and logs are in [`guttesen-comparison`](guttesen-comparison/README.md); the changes
  it suggests to the book are jetcarp#185.
- **Privacy:** see *Privacy* above.
- **Still owed:** the security review by a person, and a release that fixes the finding reported
  privately.
