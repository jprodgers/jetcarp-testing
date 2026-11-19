//! T10: the Abelian sandpile on tilings whose cells have different degrees, and on aperiodic
//! patches with open edges, against one-at-a-time toppling (any order gives the same stable pile).
use jetcarp_core::*;

fn check(spec: TilingSpec, nb: Nb, grains: u64, label: &str) {
    let mut w = World::new(spec, 1).unwrap();
    w.add_ca(CaSpec::new("Sandpile").nb(nb).seed(SeedSpec::Pile { grains })).unwrap();
    let t = w.topo.clone();
    let n = t.len();
    let c = t.center_cell();
    let lattice = t.lattice().is_some();
    let mut h = vec![0u64; n];
    h[c] = grains;
    let mut lost = 0u64;
    let sink = |i: usize| !lattice && t.is_open(i);
    if sink(c) {
        println!("{label}: the centre cell is open, skipped");
        return;
    }
    let mut stack = vec![c];
    while let Some(i) = stack.pop() {
        let d = t.degree(i, nb) as u64;
        while d > 0 && h[i] >= d {
            h[i] -= d;
            let mut present = 0u64;
            let mut targets = Vec::new();
            t.for_each_neighbor(i, nb, |j| {
                present += 1;
                targets.push(j);
            });
            lost += d - present; // slots past a dead lattice edge
            for j in targets {
                if sink(j) {
                    lost += 1;
                } else {
                    h[j] += 1;
                    if h[j] >= t.degree(j, nb) as u64 {
                        stack.push(j);
                    }
                }
            }
        }
    }
    let mut sweeps = 0;
    loop {
        let before = w.fields[0].height.clone();
        w.step();
        sweeps += 1;
        if w.fields[0].height == before || sweeps > 500_000 {
            break;
        }
    }
    let eng: Vec<u64> = w.fields[0].height.iter().map(|&x| x as u64).collect();
    let diff = eng.iter().zip(&h).filter(|(a, b)| a != b).count();
    println!("{label}: {n} cells, {grains} grains, {sweeps} sweeps, lost engine {} reference {lost}, cells differing {diff}", w.fields[0].lost);
    assert_eq!(diff, 0, "{label}: stable pile differs");
    assert_eq!(w.fields[0].lost, lost, "{label}: lost grains");
    assert_eq!(eng.iter().sum::<u64>() + lost, grains, "{label}: conservation");
}

#[test]
fn sandpiles_on_mixed_degree_tilings_and_patches() {
    check(TilingSpec::rect("trihex", 20, 20, Boundary::Dead), Nb::Edge, 30_000, "trihex edge, dead");
    check(TilingSpec::rect("oct", 16, 16, Boundary::Dead), Nb::Edge, 30_000, "4.8.8 edge, dead");
    check(TilingSpec::rect("cairo", 16, 16, Boundary::Dead), Nb::Touch, 40_000, "cairo touch, dead");
    check(TilingSpec::rect("snubsq", 14, 14, Boundary::Dead), Nb::Edge, 20_000, "snub square edge, dead");
    for fam in ["penrose-rhomb", "penrose-kd", "hat", "spectre"] {
        check(TilingSpec::new(fam).with_size(SizeSpec::Level(3)), Nb::Edge, 20_000, &format!("{fam} level 3 edge"));
        check(TilingSpec::new(fam).with_size(SizeSpec::Level(4)), Nb::Touch, 60_000, &format!("{fam} level 4 touch"));
    }
}
