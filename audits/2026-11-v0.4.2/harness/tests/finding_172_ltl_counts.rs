//! Finding filed as jprodgers/jetcarp#172: Larger than Life drops counts above the square
//! grid's neighbourhood size. Fails at a3e829a; should pass once the issue is fixed.
use jetcarp_core::rules::Rule;
use jetcarp_core::*;

#[test]
fn larger_than_life_counts_above_the_square_grid_maximum() {
    // On triangles with touch neighbours a cell has 12 neighbours at range 1, more than the
    // square grid's 8. Are counts 9 to 12 expressible?
    let (r, _) = Rule::parse("R1,C2,S2-3,B9-12").unwrap();
    println!("parsed 'R1,C2,S2-3,B9-12' as '{}'", r.notation());
    let mut w = World::new(TilingSpec::rect("triangle", 12, 12, Boundary::Wrap), 1).unwrap();
    w.add_ca(CaSpec::new("R1,C2,S0-12,B9-12").seed(SeedSpec::Random { density: 0.9 })).unwrap();
    let t = w.topo.clone();
    let before = w.fields[0].state.clone();
    w.step();
    let mut should_be_born = 0;
    let mut born = 0;
    for i in 0..t.len() {
        if before[i] == 0 {
            let mut c = 0;
            t.for_each_neighbor(i, Nb::Touch, |j| c += before[j] as u32);
            if (9..=12).contains(&c) {
                should_be_born += 1;
                born += w.fields[0].state[i] as u32;
            }
        }
    }
    println!("triangles, touch degree {}: dead cells with 9-12 live neighbours: {should_be_born}; born under B9-12: {born}", t.degree(0, Nb::Touch));
    assert_eq!(born, should_be_born, "B9-12 is silently dropped on a tiling whose cells have 12 neighbours");
}
