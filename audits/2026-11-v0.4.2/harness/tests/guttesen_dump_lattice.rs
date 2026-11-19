//! Prints, for JETCARP's kagome ("trihex") and snub-square ("snubsq") tilings, each tile's lattice
//! coordinates (i, j, k) as patterns use them, its outline, and its neighbours (cells sharing an
//! edge or a corner) in the same coordinates. Used to match JETCARP's coordinates with
//! H. S. Guttesen's, tile for tile.
use jetcarp_core::*;
use std::collections::HashMap;

#[test]
fn dump() {
    for fam in ["trihex", "snubsq"] {
        let spec = TilingSpec::rect(fam, 12, 12, Boundary::Dead);
        let t = Topology::build(&spec).unwrap();
        let g = t.lattice().expect("lattice storage");
        let mut of: HashMap<usize, (i32, i32, u32)> = HashMap::new();
        for j in -2..14 {
            for i in -20..20 {
                for k in 0..g.ntypes {
                    if let Some(idx) = g.resolve(i, j, k) {
                        of.insert(idx, (i, j, k));
                    }
                }
            }
        }
        assert_eq!(of.len(), t.len(), "every cell has lattice coordinates");
        let mut idxs: Vec<usize> = of.keys().copied().collect();
        idxs.sort_unstable();
        for idx in idxs {
            let (i, j, k) = of[&idx];
            let p = t.polygon(idx);
            let pts: Vec<String> = p.iter().map(|q| format!("{:.9},{:.9}", q[0], q[1])).collect();
            let mut nb: Vec<String> = Vec::new();
            t.for_each_neighbor(idx, Nb::Touch, |n| {
                let (a, b, c) = of[&n];
                nb.push(format!("{a},{b},{c}"));
            });
            let interior = t.is_interior(idx);
            println!("CELL {fam} {i} {j} {k} {} {} | {} | {}", interior as u8, t.degree(idx, Nb::Touch), pts.join(" "), nb.join(" "));
        }
    }
}
