# JETCARP's kagome and snub-square ships against H. S. Guttesen's configurations

A follow-up to the November 2026 audit, made on 18 November 2026, after the report was written.

JETCARP's book credits two Life gliders to H. S. Guttesen: the small glider *g* on the kagome
tiling (3.6.3.6) and the period-8 glider on the snub square tiling (3.3.4.3.4). It says its own
kagome ship is "exactly Guttesen's Fig. 4 glider", that its snub-square ship "matches Fig. 5 by
eye", and that "a cell-for-cell check awaits Guttesen's published configurations". It also says
his large kagome glider *G* was not found by JETCARP's searches. This is that check, and a run of
his large glider, a bouncer and his glider gun in JETCARP's engine.

## Results

| Question | Answer | Evidence |
|---|---|---|
| Is JETCARP's published kagome ship Guttesen's glider *g*? | **Yes, cell for cell.** JETCARP's pattern is frame 1 of his animation, unturned (or frame 3 reflected) | `logs/compare-gliders.txt` |
| Is JETCARP's published snub-square ship his period-8 glider? | **Yes, cell for cell.** JETCARP's pattern is frame 1 of his animation, reflected and turned by 270° | `logs/compare-gliders.txt` |
| Is the glider his gun sends out the same *g*? | **Yes** | `logs/compare-gliders.txt` |
| Does JETCARP's own object finder give his gliders the keys of its own ships? | **Yes:** `47fc3f43` for both kagome gliders, `c574f8e3` for both snub-square gliders | `logs/jetcarp-objects.txt` |
| Does JETCARP's engine run his large glider *G* as he reports it? | **Yes.** Period 40, ten lattice steps per period (c/4). 400 generations, every one equal to the reference: 17,200 live cells compared, none different | `logs/check-seeds.txt`, `logs/engine-results.txt` |
| His bouncer B1? | **Yes.** Period 116. 464 generations, 42,416 live cells compared, none different | the same |
| His glider gun? | **Yes.** The gun repeats every 276 generations and sends out one *g* each time. 1,104 generations, 462,300 live cells compared, none different | the same |

So the book's "by eye" can become "cell for cell", for both gliders. The statement that *G* was
not found by JETCARP's searches stands; what is new is that JETCARP runs it, the bouncer and the
gun exactly as an independent implementation of his lattice does. The suggested changes to the
book are in jprodgers/jetcarp#185.

## What was compared with what

- **His lattices and animations:** his public repository,
  [henrisro313/Games_of_life](https://github.com/henrisro313/Games_of_life), at commit `9ff8616`
  (14 September 2026), which his paper
  ([arXiv:2608.27622](https://arxiv.org/abs/2608.27622)) names as its code. The lattices are
  defined in `Kagome.java` and `SkewSquare.java`; the two gliders are the animations
  `glider_Kagome.gif` and `glider_SkewSquare.gif` in `GlidersAndPuffers.zip`. The repository
  states no licence, so nothing from it is copied here: the scripts read the definitions and the
  animations from a clone at run time.
- **His large glider, bouncer and gun:** three cell strings he sent the maintainer by email in
  November 2026. They are not in this repository, and neither are scenes made from them.
- **JETCARP:** 0.4.2 at `a3e829a`: the engine (`jetcarp-core`, through the audit's harness), the
  released program's `jetcarp objects`, and the two scenes in the book,
  `docs/scenes/tilings/glider-guttesen-kagome.json` and `glider-guttesen-snubsq.json`.

## Method

1. **A reference Life on his lattice** (`ref_lattice.py`), written from his definitions: a tile
   is (x, y, T), its outline is a list of whole-number points, two tiles are neighbours when they
   share an outline point, and the rule is B3/S23 on the unbounded plane. It shares no code with
   his program or with JETCARP.
2. **A map between the two coordinate systems, proven and not fitted** (`gmap.py`). Candidate
   maps are found from the geometry (lattice to lattice, tile centres to tile centres). A
   candidate is kept only if it carries every tile's neighbours onto the neighbours JETCARP's
   engine lists for the image tile. There are 12 such maps for the kagome tiling and 8 for the
   snub square tiling, which are the sizes of the two tilings' symmetry groups; JETCARP's own
   object finder reports the same numbers. The maps used:

   | His tile | JETCARP's (i, j, k) |
   |---|---|
   | Kagome (x, y, A), the hexagon | (y, x, 0) |
   | Kagome (x, y, B) | (y, x, 2) |
   | Kagome (x, y, C) | (y + 1, x, 1) |
   | Snub square (x, y, A) | (y, x, 1) |
   | Snub square (x, y, B) | (y + 1, x + 1, 0) |
   | Snub square (x, y, C) | (y, x, 5) |
   | Snub square (x, y, D) | (y, x, 4) |
   | Snub square (x, y, E) | (y + 1, x, 2) |
   | Snub square (x, y, F) | (y + 1, x + 1, 3) |

3. **His gliders, read from his animations** (`gif_decode.py`). His program draws one pixel per
   lattice unit, so each tile's centre pixel says whether it is live. The read is checked against
   the rule: in both animations, each of the 100 frames is the next generation of the frame
   before.
4. **The comparison** (`compare_gliders.py`). Two patterns are the same object when some phase
   of one, under some symmetry of the tiling and a translation, is the other. Both gliders are
   reduced to a canonical form over every phase and every symmetry, and the forms are equal.
5. **His three configurations in JETCARP's engine** (`check_seeds.py`, then
   `../harness/tests/guttesen_run_expected.rs`). The reference runs each on his lattice; the
   cells it says are live at each generation are mapped to JETCARP's coordinates; JETCARP's
   engine runs the same start, and its live cells are compared with the reference's at every
   generation. As a control, one cell was removed from one generation of the expectations, and
   the test failed at that generation.

## What this does not show

- His two small gliders were read from the animations his program wrote, not from cell lists he
  published. The kagome one is confirmed a second way, by the gun's output.
- "The same" means the same cells in Life (B3/S23), with tiles that share an edge or a corner as
  neighbours. That is the rule and the neighbourhood both programs use.
- His other configurations (oscillators, the puffer, the collisions) and his other four lattices
  were not compared.
- Nothing here bears on who found what first. The book's account of that is unchanged.

## Running it again

Three clones side by side: `jetcarp` (at the commit to test), `jetcarp-testing` (this
repository) and `Games_of_life`. Python 3 with Pillow.

```bash
cd jetcarp-testing/audits/2026-11-v0.4.2/harness
```

```bash
mkdir -p ../guttesen-comparison/work
```

```bash
cargo test --release --test guttesen_dump_lattice -- --nocapture > ../guttesen-comparison/work/jetcarp-lattice-dump.txt
```

```bash
cd ../guttesen-comparison
```

```bash
GUTTESEN_REPO=../../../../Games_of_life JETCARP_REPO=../../../../jetcarp python3 -I compare_gliders.py work/jetcarp-lattice-dump.txt
```

That is the whole of the glider comparison. The three configurations need his cell strings,
saved as `seeds/G.txt`, `seeds/B1.txt` and `seeds/gun.txt`:

```bash
GUTTESEN_REPO=../../../../Games_of_life python3 -I check_seeds.py work/jetcarp-lattice-dump.txt seeds work
```

It prints the line that runs the engine test for each.

## Files

| File | What it is |
|---|---|
| `ref_lattice.py` | The reference Life on his lattices |
| `gmap.py` | Matching two descriptions of a tiling tile for tile; symmetries; canonical forms |
| `gif_decode.py` | Reading live cells out of his animations |
| `compare_gliders.py` | The two glider comparisons |
| `check_seeds.py` | His large glider, bouncer and gun in the reference, and the expectations for the engine |
| `../harness/tests/guttesen_dump_lattice.rs` | JETCARP's tile coordinates, outlines and neighbours, printed by its engine |
| `../harness/tests/guttesen_run_expected.rs` | JETCARP's engine against the expectations, generation by generation |
| `logs/` | The output of each, from the run of 18 November 2026 |
