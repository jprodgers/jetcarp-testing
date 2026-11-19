//! Finding filed as jprodgers/jetcarp#171. `b0_emulation_on_uniform_and_mixed_degree_tori` and
//! `b0_emulation_matches_brute_force_on_4_8_8` fail at a3e829a and should pass once it is fixed.
//!
//! H1: is the B0 (birth-on-zero) emulation in jetcarp-core's `step_b0` equal to the true rule on
//! graphs whose cells have different degrees?
//!
//! Ground truth here is the plain synchronous B/S rule on the same neighbour graph: a cell's next
//! state is B[c] if dead, S[c] if live, c = number of live neighbours. The engine stores an encoded
//! state for B0 rules ("true on even generations and complemented on odd ones", or permanently
//! complemented for cells whose own degree d is in S). We try every decoding the engine's own
//! comments describe and report whether any of them reproduces the truth.

use jetcarp_core::rules::Rule;
use jetcarp_core::*;

fn bs(rule: &str) -> (u32, u32) {
    match Rule::parse(rule).unwrap().0 {
        Rule::LifeLike { birth, survive } => (birth, survive),
        other => panic!("{other:?}"),
    }
}

/// Returns None if some decoding matches for all generations, else Some(first generation at which
/// every decoding has failed, mismatching cells under the best decoding at that generation).
fn first_divergence(spec: TilingSpec, rule: &str, nb: Nb, gens: u64) -> Option<(u64, usize, usize)> {
    let (birth, survive) = bs(rule);
    let mut w = World::new(spec, 12345).unwrap();
    w.add_ca(CaSpec::new(rule).nb(nb).seed(SeedSpec::Random { density: 0.35 }))
        .unwrap();
    let t = w.topo.clone();
    let n = t.len();
    let mut truth: Vec<u8> = w.fields[0].state.clone();
    let has_sd: Vec<bool> = (0..n).map(|i| survive >> (t.degree(i, nb) as u32) & 1 == 1).collect();
    // Which decodings are still alive: 0 = global parity, 1 = per-cell (S_d cells stay complemented).
    let mut alive = [true, true];
    for g in 1..=gens {
        w.step();
        truth = (0..n)
            .map(|i| {
                let mut c = 0u32;
                t.for_each_neighbor(i, nb, |j| c += truth[j] as u32);
                let m = if truth[i] == 1 { survive } else { birth };
                ((m >> c) & 1) as u8
            })
            .collect();
        let x = &w.fields[0].state;
        let dec_global: Vec<u8> = x.iter().map(|&s| if g % 2 == 1 { 1 - s } else { s }).collect();
        let dec_cell: Vec<u8> = (0..n)
            .map(|i| if has_sd[i] || g % 2 == 1 { 1 - x[i] } else { x[i] })
            .collect();
        let miss = |d: &Vec<u8>| d.iter().zip(&truth).filter(|(a, b)| a != b).count();
        let m = [miss(&dec_global), miss(&dec_cell)];
        for k in 0..2 {
            if m[k] != 0 {
                alive[k] = false;
            }
        }
        if !alive[0] && !alive[1] {
            return Some((g, m[0].min(m[1]), n));
        }
    }
    None
}

fn degrees(spec: &TilingSpec, nb: Nb) -> Vec<usize> {
    let t = Topology::build(spec).unwrap();
    let mut d: Vec<usize> = (0..t.len()).map(|i| t.degree(i, nb)).collect();
    d.sort_unstable();
    d.dedup();
    d
}

#[test]
fn b0_emulation_on_uniform_and_mixed_degree_tori() {
    // (family, neighbourhood, rule, expectation note)
    let cases: &[(&str, Nb, &str)] = &[
        // Uniform degree: the project's own tests cover only this situation (square torus).
        ("square", Nb::Touch, "B014/S2"),
        ("square", Nb::Touch, "B0123478/S01234678"),
        ("hex", Nb::Touch, "B0/S6"),
        ("cairo", Nb::Touch, "B02/S347"),
        // Mixed degree, no present degree in S: all cells alternate.
        ("oct", Nb::Touch, "B03/S23"),
        ("trihex", Nb::Touch, "B02/S13"),
        // Mixed degree, every present degree in S: all cells stay complemented.
        ("oct", Nb::Touch, "B0123478/S01234678"),
        // Mixed degree, some present degrees in S and some not.
        ("oct", Nb::Touch, "B0/S8"),
        ("oct", Nb::Touch, "B0/S4"),
        ("oct", Nb::Touch, "B03/S238"),
        ("oct", Nb::Edge, "B0/S8V"),
        ("trihex", Nb::Edge, "B0/S6V"),
        ("trihex", Nb::Touch, "B02/S1,10"),
        ("snubsq", Nb::Touch, "B03/S2,3,9"),
        ("rhombitrihex", Nb::Touch, "B03/S238"),
        ("trunctrihex", Nb::Edge, "B0/S4V"),
    ];
    let mut failures = Vec::new();
    println!("{:<14} {:<6} {:<22} {:<14} result", "family", "nb", "rule", "degrees");
    for &(fam, nb, rule) in cases {
        let spec = TilingSpec::rect(fam, 12, 12, Boundary::Wrap);
        let d = degrees(&spec, nb);
        let r = first_divergence(spec, rule, nb, 40);
        let nbs = if nb == Nb::Touch { "touch" } else { "edge" };
        match r {
            None => println!("{fam:<14} {nbs:<6} {rule:<22} {:<14} matches truth for 40 generations", format!("{d:?}")),
            Some((g, m, n)) => {
                println!("{fam:<14} {nbs:<6} {rule:<22} {:<14} DIVERGES at generation {g}: {m} of {n} cells wrong under the best decoding", format!("{d:?}"));
                failures.push((fam, nbs, rule, g));
            }
        }
    }
    assert!(failures.is_empty(), "B0 emulation diverges from the true rule: {failures:?}");
}

#[test]
fn b0_emulation_on_aperiodic_patches_interior() {
    // Aperiodic patches have dead (open) edges, where the emulation's edge convention differs by
    // design, so only report how far from the boundary the first wrong cell is.
    for (fam, level, rule) in [
        ("penrose-rhomb", 3u32, "B0123478/S01234678"),
        ("penrose-rhomb", 3u32, "B03/S23"),
        ("hat", 3u32, "B0/S6"),
        ("spectre", 3u32, "B03/S238"),
    ] {
        let spec = TilingSpec::new(fam).with_size(SizeSpec::Level(level));
        let d = degrees(&spec, Nb::Touch);
        let r = first_divergence(spec, rule, Nb::Touch, 6);
        println!("{fam:<14} level {level} {rule:<22} degrees {d:?}: {r:?}");
    }
}

// The project's own test `b0_emulation_matches_brute_force` (crates/jetcarp-core/tests/phase2_rules.rs)
// with the tiling changed from the square grid to 4.8.8, and the decoding `step_b0`'s comment describes.
#[test]
fn b0_emulation_matches_brute_force_on_4_8_8() {
    for rule in ["B03/S23", "B0123478/S01234678", "B0/S8"] {
        let (r, _) = jetcarp_core::rules::Rule::parse(rule).unwrap();
        let jetcarp_core::rules::Rule::LifeLike { birth, survive } = r else { panic!() };
        let mut w = World::new(TilingSpec::rect("oct", 12, 12, Boundary::Wrap), 11).unwrap();
        w.add_ca(CaSpec::new(rule).seed(SeedSpec::Random { density: 0.3 })).unwrap();
        let mut truth: Vec<u8> = w.fields[0].state.clone();
        let t = w.topo.clone();
        for g in 1..30u64 {
            w.step();
            truth = (0..t.len())
                .map(|i| {
                    let mut c = 0;
                    t.for_each_neighbor(i, Nb::Touch, |j| c += truth[j] as u32);
                    let m = if truth[i] == 1 { survive } else { birth };
                    ((m >> c) & 1) as u8
                })
                .collect();
            let decoded: Vec<u8> = (0..t.len())
                .map(|i| {
                    let s = w.fields[0].state[i];
                    let stays_complemented = survive >> t.degree(i, Nb::Touch) & 1 == 1;
                    if stays_complemented || g % 2 == 1 { 1 - s } else { s }
                })
                .collect();
            let wrong = decoded.iter().zip(&truth).filter(|(a, b)| a != b).count();
            assert_eq!(wrong, 0, "{rule} on 4.8.8: generation {g}: {wrong} of {} cells differ from the true rule", t.len());
        }
        println!("{rule} on 4.8.8: 29 generations match the true rule");
    }
}
