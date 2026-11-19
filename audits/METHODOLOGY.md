# How JETCARP is audited

This is the working method of JETCARP's independent audits, written after the first one
(November 2026, v0.4.2) for whoever runs the next: a future Claude session, a human reviewer, or a
JOSS reviewer who wants to know what "independently audited" meant. It says what the audit is for,
how it is set up, what each workstream does and how to repeat it, how findings are handled, and
what the first audit did not reach.

Each audit's results are in its own folder beside this file (`2026-11-v0.4.2/` for the first).

## What an audit is for

JETCARP's code, tests, test plans and first-draft documentation are written by an AI coding
assistant under one person's direction. The project's own testing page names the weakness that
follows: "The same author for the code and the tests… they can share its blind spots… None of
these is an independent implementation: a mistake made the same way on the CPU and the GPU would
pass." An audit exists to supply what that testing cannot:

1. **An independent second opinion on correctness**: results computed another way, by code the
   project's author did not write, compared with the program's.
2. **A check of every claim against the record**: what the book, the README and the release notes
   say, against the program, the tracker, the workflow runs and the test records.
3. **An outside view of readiness for publication** (JOSS), against the journal's current rules.
4. **A privacy and security pass**, reported privately.

It is not a re-run of the project's own tests (though it runs them), and it does not fix anything.

## Ground rules

- **The auditor does not touch the code.** Read-only on `jprodgers/jetcarp`. Everything the audit
  writes lives outside the audited repository; what is published goes in `jetcarp-testing/audits/`.
- **Isolation.** The audit runs in a fresh cloud container with a clean clone of the public
  repositories, not on a development machine. That is what makes "can an outsider build it, run it
  and reproduce the numbers?" a real test, and it lets the auditor say exactly what the public
  copies contain.
- **A different model from the author.** Each audit is run by a Claude model other than the one
  that wrote the program (the commit that adds an audit's report names the model that ran it, as
  the program's own commits name theirs). That is some independence, not full independence: both
  are Claude models from one company and may share habits of thought. Where it matters most (the
  mathematics), independence comes from the method below, not from the model: a naive reference
  implementation is hard to get wrong in the same way.
- **Verify, don't trust.** No finding is reported, and no issue filed, until the auditor has
  reproduced it. That applies to the auditor's own first impressions and to anything a helper agent
  reports. Several first "failures" in the first audit were mistakes in the audit's own harness
  (a patch too small for a vertex-orbit count; an expectation of seven Penrose vertex figures
  that ignored tile type). Fix the harness, re-run, and only then conclude.
- **Record what passed, with its coverage.** "Neighbour graphs: no problem found" means little;
  "1,355 tilings, 2,472,216 interior cells, both neighbourhoods, equal to an independent geometric
  reference" can be checked and repeated. Unearned criticism is as much a failure as unearned
  praise.
- **Bugs and documentation errors become public issues** in `jprodgers/jetcarp`, one per problem,
  in the tracker's house style: where it was found, what happens, a minimal reproduction, why, what
  it affects, a suggested fix. Search the tracker first.
- **Privacy findings and security findings are private.** They go to the maintainer directly and
  never into an issue or a published report; the report says only that the pass was made and what
  it covered. A security problem follows `SECURITY.md`.
- **The maintainer's time is the scarce resource.** Rank findings; say what to do first.

## Setting up

1. Clone both repositories with full history (`git fetch --unshallow`; fetch all branches, tags
   and `refs/pull/*`). Note the commits audited.
2. Work area outside the clones (`/home/user/audit-work/` in the first audit): `logs/`, `notes/`,
   `data/`, the harness, scratch homes. Point every JETCARP folder at scratch
   (`HOME`, `JETCARP_CONFIG_DIR`, `JETCARP_DATA_DIR`, `JETCARP_OUT`, `JETCARP_LIBRARY`,
   `JETCARP_RUNTIME_DIR`) so nothing touches default folders, and set `CARGO_TARGET_DIR` outside
   the clone.
3. Keep a running notes file with every established fact, its evidence and its location. A long
   audit outlives the auditor's working memory.
4. Fetch the JOSS pages afresh and save them with the date (see `JOSS-READINESS.md` in each audit).
5. **Disk and time.** A CI-style build (`cargo build --workspace --release --all-targets`) with the
   repository's release profile (`debug = 1`) wrote more than 28 GB before the first audit's
   container ran out of space. Build and test with `CARGO_PROFILE_RELEASE_DEBUG=0`; it changes
   nothing but debug information. Budget an hour of four-core time for the suite.
6. Linux packages, as in `ci.yml`: `pkg-config libxkbcommon-dev libwayland-dev libx11-dev
   libxcursor-dev libxrandr-dev libxi-dev libvulkan1 mesa-vulkan-drivers`. With
   `JETCARP_GPU=software` the GPU tests and `jetcarp run --gpu` use Mesa's llvmpipe.

## The workstreams

Each is described as: what it answers, how it was done, how to repeat it. The first audit's
numbers are in its report.

### A. Build, toolchain and the project's own tests

*Can an outsider build and test it as documented, and what does the suite say?*

- Load the workspace with the **declared minimum Rust** and bisect upward
  (`rustup toolchain install 1.95.0 …; cargo +1.95.0 metadata --locked`). The first audit found the
  declared minimum did not load the workspace at all.
- Run the suite the way CI's Linux job does (default folders under a scratch `HOME`,
  `JETCARP_GPU=software`), with `--no-fail-fast`, to a log. Count test binaries, tests, ignored
  tests, failures; read every failure. A failure under load is still a finding about the test.
- `cargo fmt --all -- --check`; `cargo clippy --workspace --all-targets` (CI does not run clippy);
  count `unsafe`, `#[allow]`, `TODO`; look for lint configuration.
- Read `.github/workflows/*.yml` for what CI does *not* check.

### B. An independent harness for the mathematics

*Does the engine compute what it says, judged by code its author did not write?*

This is the heart of the audit. The harness (`harness/` in each audit folder) is a small Rust crate
outside the audited repository that depends on `jetcarp-core` by path and compares it with
deliberately naive reference code. Rules for writing it:

- **Reference code shares nothing with the engine** except, where unavoidable, the neighbour graph,
  and the graph itself is checked first against independent geometry.
- **Prefer facts from outside the project**: textbook properties (the seven Penrose vertex
  figures, the hat's share of mirrored tiles, Galebach's counts of k-uniform tilings, Langton's
  104-step highway, the Abelian property of sandpiles), published tables (MCell's Margolus
  rules), another implementation (RustCrypto's SHA-256).
- **Where the rule is the project's own invention**, write the reference from the book's
  definition, not from the code. Then the test checks the documentation and the code against each
  other.
- **Go where the project's tests do not.** Read the project's tests for the tilings, sizes and
  edges they use, and test the others. The first audit's most serious finding (B0 rules on
  mixed-degree tilings) was found by reading `step_b0`, noticing its per-cell assumption, and
  running the project's own brute-force test on a tiling other than the square grid.
- **Report coverage in numbers.**

The first audit's tests, all to be re-run and extended next time:

| Test | Reference | Covers |
|---|---|---|
| `verified_periodic_graphs` | segment-overlap contact at tolerances 1e-8 / 1e-6 | every periodic tiling: neighbour sets (touch, edge), slot winding, symmetry, no self loops or repeats, areas |
| `verified_kuniform_catalogue` | geometry alone | all 1,248 k-uniform entries: regular polygons, vertex types against names, per-cell counts against notes, vertex-orbit bound, distinctness |
| `verified_aperiodic_patches` | the same contact code; textbook facts | Penrose P2/P3, hat, spectre at levels 1–5: counts, neighbour lists, gaps, overlaps, vertex figures, chirality |
| `verified_isohedral_graph_classes` | coordination sequences | the 81 isohedral types fall into 11 graphs, with the book's class sizes |
| `verified_symmetries_are_automorphisms` | the offset tables | every symmetry used for pattern identity is an automorphism of the neighbour graph |
| `verified_rules` | naive steppers | Life-like, Generations, Larger than Life, elementary rules, Langton's ant, the sandpile; thread-count independence |
| `verified_sandpile_graphs` | one-at-a-time toppling | sandpiles on mixed-degree tilings and aperiodic patches |
| `verified_jaca` | the book's definition | JACA on six tilings, seven rules |
| `verified_lenia_orbium` | behaviour | the standard Orbium glides with steady mass and speed |
| `verified_sha256` | RustCrypto `sha2` | the engine's own SHA-256 |
| `verified_published_spaceships` | naive B/S stepper on a large torus | every spaceship scene the book publishes recurs at its stated period, and no sooner |
| `verified_hashlife_b0_uniform` | brute force | stepper, HashLife and truth agree on B0 rules where degrees are uniform |
| `finding_171_…`, `finding_172_…`, `finding_173_…` | brute force | the findings filed as issues: these **fail** until the issues are fixed, and are the regression tests for the fixes |
| `scripts/apg_compare.py` | Catagolue's public census | the soup hunt's object shares for Conway's Life; every object's identity by apgcode |

Not yet covered by the harness, in rough order of value: canonical pattern ids end to end (the
same pattern in every phase, orientation and position gives one id; different patterns give
different ids; the first audit checked only that the symmetries used are sound);
HashLife on the unbounded plane; the soup hunt against Catagolue for more rules, and the cause of the two differences the first
audit found; von Neumann's 29-state rule
against a published transition table; the hexagonal row rules; turmites on non-square tilings;
WireWorld circuits; the large-sandpile boards (`pile/`) against the stepper; the GPU on real
hardware.

### C. Reproducing the published test records

*Do the public records in `jetcarp-testing` hold up on a machine the project never saw?*

- Re-run the newest cycle's parity sets on the audit machine:
  `scripts/parity_run.py JETCARP v0.4.2/parity OUT.csv` (371 scenes, 300 generations) and
  `… v0.4.2/parity/long OUT.csv --gens 5000`, CPU, and with `--gpu` under `JETCARP_GPU=software`.
  Every hash must equal `expected.csv`. (The records are in one folder per release cycle; the
  first audit read them in the layout before that, which `MOVED.md` at the top maps.)
- Tabulate every published parity CSV (candidate × machine × adapter): scenes, CPU matches, GPU
  matches. Any mismatch must be one the records explain.
- Run the book's reproducibility example and compare the hash it prints.
- Cross-check a sample of the book's testing claims against log timestamps and tag times.

### D. Documentation and scholarly claims

*Does what is written match what the program is and does, and are the citations real?*

Extract every checkable number and enumeration; run every documented command that can run
headless; run the generators' `--check` modes; look for contradictions between pages, stale
version-specific statements, and "planned" features that shipped. Verify a stratified sample of
the bibliography against Crossref, arXiv or the publisher, alert to plausible references that do
not exist. List each novelty claim with its hedge and its support. A helper agent did this in the
first audit; its findings were re-verified before filing.

### E. Tracker, releases, CI and process

*Does the project do what its process pages say?*

Dump every issue and pull request (bodies and comments) and every workflow run. Check the book's
process numbers row by row. For each closed issue: a citing commit, a test change, a changelog
entry, a verification record. Compare tag times with the CI verdict on the tagged commit. Look at
branch protection, reviews, moved tags, release assets and checksums, flaky re-runs. Say what is
good as carefully as what is not.

### F. Privacy

*What personal information is in the public copies, in any commit?* **Private.**

Every blob of every ref of both repositories, commit and tag messages, issue and comment text, and
metadata inside images, archives and data files; every screenshot looked at; anything removed from
current files that history still holds; and whether masking in the test records can be undone from
other public text. Findings, with values and locations, go to the maintainer only. The published
report carries a summary without values, and only once the maintainer has decided what to do.

### G. Security

*Do the boundaries `SECURITY.md` documents hold?* **Private.**

In the first audit this stream was only partly done. The auditor read the path-sandbox code and
the signing code, checked the "no network connections" claim from the dependency list and the
socket code, read the workflows' permissions, and found one low-severity boundary gap, reported
privately. A broader adversarial review (hostile packs, fuzzing
of scene and pack parsers, resource exhaustion through the MCP tools, the local link's
unauthenticated surface, installers) was started and then stopped by the auditing model's own
safety safeguards, which restrict some security-testing work. **That review is still owed.** It is
better done by a person with security experience, or by a session with the access such work
needs, than skipped.

### H. Publication readiness

Compare the project with JOSS's current gates, review criteria, paper format and AI-usage policy,
quoting the rules as fetched. Give dates. See `JOSS-READINESS.md` in each audit.

## Working with helper agents

The first audit used two helpers at a time for work that was wide, mostly reading, and separable:
the privacy scan, the tracker and process audit, the documentation audit. What worked:

- A written brief each: the goal, the hard rules (read-only, where to write, what not to send
  anywhere), what is already established, what to check, how to report, and an instruction to
  recheck every finding before reporting it and to record what is good.
- Keeping the mathematics with the lead auditor, so that the findings that matter most were made
  and verified in one head.
- Treating a helper's report as leads. The lead re-verified every item before it went into an
  issue or was reported to the maintainer.

What to know: helpers in that setup could not write report files, only return text and raw data,
so the lead saved their reports; helpers and background builds compete for the same four cores,
and a timing-sensitive test failed under that load; a helper asked to probe security boundaries
was stopped by safeguards (see G).

## Severity and wording

| Level | Meaning |
|---|---|
| Critical | Published results are wrong, or users are at risk now |
| High | The program computes something other than it says in normal use; or a claim a reviewer will check is false; or a publication gate fails |
| Medium | Wrong in a corner, or a stated property that does not hold, or a process statement the record contradicts |
| Low | Hygiene, wording, hardening |
| Good | Checked and sound; say how and how much |

Write findings so that a reader who was not there can act on them: the claim, the evidence, the
command to see it, what it affects and what it does not.

## Running the next audit

1. Read the previous report and this file. Start a fresh container; clone both repositories.
2. `git diff --stat <last audited commit>..HEAD` and the changelog since: what changed decides
   where to look hardest. Re-run everything in B and C regardless.
3. For every issue the last audit filed: is it fixed, with a test that fails without the fix? The
   harness tests that failed last time must now pass, unchanged.
4. Do the harness items listed as not yet covered, most valuable first.
5. Do workstreams A, D, E and H in full; F on everything new since the last audit, and on the
   remedies for the last audit's private findings; G as far as the auditor can, and say how far.
6. Fetch JOSS's pages again; update the readiness table and the timetable.
7. Publish: the report, the harness as run, the logs, in a new folder; update this file with what
   the audit learned about auditing.

Expect two to four hours of wall-clock time on a four-core container when helpers run in parallel,
most of it builds and test runs.
