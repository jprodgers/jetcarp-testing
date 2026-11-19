# The audit's independent harness (November 2026, JETCARP 0.4.2)

A small Rust crate, outside JETCARP, that compares `jetcarp-core` with reference code written for
the audit. It depends on JETCARP's engine by path and changes nothing in it. The method, and the
rules the reference code keeps to, are in [`../../METHODOLOGY.md`](../../METHODOLOGY.md); the
results are in [`../REPORT.md`](../REPORT.md); the output of the run the report quotes is in
[`../logs/harness-run.txt`](../logs/harness-run.txt).

## Running it

Put a clone of `jprodgers/jetcarp`, checked out at the commit to test, beside the clone of this
repository:

```text
somewhere/jetcarp            (at a3e829a for the first audit's numbers)
somewhere/jetcarp-testing
```

```bash
cd jetcarp-testing/audits/2026-11-v0.4.2/harness
cargo test --release --no-fail-fast -- --nocapture --test-threads=1
```

It needs the Rust the workspace needs (1.99 or newer at `a3e829a`; see jprodgers/jetcarp#175) and
takes about a minute and a half after the build. `JETCARP_REPO=/path/to/jetcarp` tells the
spaceship test where the book's scenes are, if the clone is somewhere else.

## What is in it

`src/lib.rs` is the reference geometry: contact between two polygons from segment overlap and
segment distance, at tolerances of 1e-8 and 1e-6, and neighbour lists for a set of polygons. It
calls none of JETCARP's contact or neighbour code.

**Tests that must pass** (`tests/verified_*.rs`): what the audit checked and found sound.

| File | What it shows | Size of the check at `a3e829a` |
|---|---|---|
| `verified_periodic_graphs.rs` | Every periodic tiling's touch and edge neighbour sets equal the reference geometry's; edge slots wind the same way in every cell; wrapped grids are symmetric graphs with no self loops or repeats; tile areas add up to the torus | 1,355 tilings; 2,472,216 interior cells; 2,710 tori |
| `verified_kuniform_catalogue.rs` | Each k-uniform entry is made of regular unit polygons, has the vertex types its name lists and the per-cell counts its note gives, never more vertex classes than k (exactly k for 1,229 entries at the default radius of 7, for 1,244 with `AUDIT_RADIUS=16`), and differs from every other entry | 1,248 entries (11, 20, 61, 151, 332, 673 for k = 1 to 6) |
| `verified_aperiodic_patches.rs` | Penrose kites and darts, Penrose rhombs, hat and spectre patches: tile counts, neighbour lists equal to the reference, no gaps, no overlaps; exactly the seven Penrose vertex figures in each Penrose tiling; the hat's mirrored share; the spectre's single handedness | 4 families, levels 1 to 5 (up to 35,000 tiles) |
| `verified_isohedral_graph_classes.rs` | The 81 isohedral types have 11 neighbour graphs, with the class sizes the book gives | 81 types |
| `verified_rules.rs` | Life-like and Generations rules, Larger than Life on squares, elementary rules, Langton's ant and the sandpile equal naive references; results do not depend on the thread count | 99 + 12 + 10 cases and more |
| `verified_sandpile_graphs.rs` | Sandpiles on mixed-degree tilings and aperiodic patches equal one-at-a-time toppling, lost grains included | 12 cases |
| `verified_jaca.rs` | JACA equals a reference written from the book's definition | 42 cases |
| `verified_lenia_orbium.rs` | The standard Orbium glides with steady mass and speed | 400 generations |
| `verified_sha256.rs` | The engine's own SHA-256 equals RustCrypto's | 311 message lengths |
| `verified_published_spaceships.rs` | Every spaceship scene the book publishes recurs after exactly its stated period, as a lattice translate, on a large torus, under the harness's own stepper | 104 scenes |
| `verified_symmetries_are_automorphisms.rs` | Every tiling symmetry the engine uses for pattern identity carries neighbours to neighbours, so it commutes with every counting rule | 16,206 maps over 1,355 tilings, both neighbourhoods |
| `verified_hashlife_b0_uniform.rs` | Stepper, HashLife and brute force agree on B0 rules where every tile has the same degree; HashLife refuses the others | 15 cases |

**Tests that reproduce the findings** (`tests/finding_*.rs`): each fails at `a3e829a` and is the
regression test for an issue the audit filed. They should pass, unchanged, once the issue is fixed.

| File | Issue |
|---|---|
| `finding_171_b0_mixed_degree.rs` | jprodgers/jetcarp#171: B0 Life-like rules on tilings with mixed neighbour counts |
| `finding_172_ltl_counts.rs` | jprodgers/jetcarp#172: Larger than Life drops counts above the square grid's maximum |
| `finding_173_state_hash.rs` | jprodgers/jetcarp#173: the state hash leaves out a turmite's internal state |

**Tools for the follow-up comparison** (`tests/guttesen_*.rs`, added 18 November 2026): not checks
in themselves. They serve [`../guttesen-comparison`](../guttesen-comparison/README.md).

| File | What it does |
|---|---|
| `guttesen_dump_lattice.rs` | Prints, from the engine, every tile of a kagome and a snub-square patch: its coordinates, outline and neighbours |
| `guttesen_run_expected.rs` | Runs a pattern in the engine and compares its live cells, generation by generation, with a file of expectations (`GUTT_FILE`); with no file named it does nothing |

`AUDIT_RADIUS`, `AUDIT_GROW` and `AUDIT_ONLY` adjust the k-uniform test (coordination-sequence
radius, patch margin, a list of ids); the defaults are the ones the report used.

## Licence

Like the rest of this repository: the Unlicense or the MIT licence, at your option.
