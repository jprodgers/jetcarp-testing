//! T13: do the ordinary stepper and HashLife agree on B0 rules on a mixed-degree torus? And
//! which of them, if either, equals the true rule (plain synchronous B/S, brute force)?
use jetcarp_core::hashlife::{self, Options};
use jetcarp_core::rules::Rule;
use jetcarp_core::*;

fn mk(fam: &str, rule: &str) -> World {
    let mut w = World::new(TilingSpec::rect(fam, 16, 16, Boundary::Wrap), 4242).unwrap();
    w.add_ca(CaSpec::new(rule).seed(SeedSpec::Random { density: 0.35 })).unwrap();
    w
}

#[test]
fn stepper_hashlife_and_truth_on_b0_rules() {
    println!("{:<8} {:<20} {:>5}  stepper==hashlife  stepper==truth  hashlife==truth (truth compared under the engine's own decoding for that generation)", "tiling", "rule", "gens");
    let mut disagreements = 0;
    for (fam, rule) in [("square", "B0/S8"), ("square", "B03/S23"), ("hex", "B0/S6"), ("oct", "B03/S23"), ("oct", "B0123478/S01234678"), ("oct", "B0/S8"), ("oct", "B0/S4"), ("trihex", "B0/S6V"), ("snubsq", "B03/S2,3,9")] {
        for gens in [2u64, 4, 6, 16, 64] {
            let mut a = mk(fam, rule);
            let mut b = mk(fam, rule);
            if let Some(p) = hashlife::torus_problem(&b) {
                println!("{fam:<8} {rule:<20} HashLife refuses: {p}");
                break;
            }
            let (birth, survive) = match Rule::parse(rule).unwrap().0 {
                Rule::LifeLike { birth, survive } => (birth, survive),
                _ => unreachable!(),
            };
            let t = a.topo.clone();
            let nb = a.cas[0].nb;
            let mut truth = a.fields[0].state.clone();
            for _ in 0..gens {
                a.step();
                truth = (0..t.len())
                    .map(|i| {
                        let mut c = 0u32;
                        t.for_each_neighbor(i, nb, |j| c += truth[j] as u32);
                        (((if truth[i] == 1 { survive } else { birth }) >> c) & 1) as u8
                    })
                    .collect();
            }
            hashlife::jump_world(&mut b, gens, &Options::default()).unwrap();
            // gens is even, so a cell without S_d stores its true state; a cell with S_d stores the complement.
            let dec = |x: &Vec<u8>| -> Vec<u8> {
                (0..t.len()).map(|i| if survive >> (t.degree(i, nb) as u32) & 1 == 1 { 1 - x[i] } else { x[i] }).collect()
            };
            let same = a.fields[0].state == b.fields[0].state;
            let st = dec(&a.fields[0].state) == truth;
            let ht = dec(&b.fields[0].state) == truth;
            if !same {
                disagreements += 1;
            }
            println!("{fam:<8} {rule:<20} {gens:>5}  {same:<17}  {st:<14}  {ht}");
        }
    }
    println!("stepper/HashLife disagreements: {disagreements}");
}
