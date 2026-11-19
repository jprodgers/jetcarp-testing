//! Canonical pattern ids rest on the tiling's symmetries (`pattern::canonical_symmetries`): a
//! pattern and its image under a symmetry get one id. That is only sound if every map the engine
//! calls a symmetry really is an automorphism of the neighbour graph, so that it commutes with
//! every counting rule. Check exactly that, from the offset tables, for every periodic tiling and
//! both neighbourhoods; and report how many symmetries each kind of tiling has.
use jetcarp_core::families::{FAMILIES, FamilyKind};
use jetcarp_core::objects::LCell;
use jetcarp_core::*;
use serde_json::json;
use std::collections::{BTreeMap, BTreeSet};

#[test]
fn every_cell_map_is_a_graph_automorphism() {
    let mut specs: Vec<(String, TilingSpec)> = Vec::new();
    for f in FAMILIES {
        if f.kind != FamilyKind::Aperiodic && f.id != "periodic" {
            specs.push((f.id.to_string(), TilingSpec::new(f.id)));
        }
    }
    for t in jetcarp_core::catalog::all() {
        let mut s = TilingSpec::new("periodic");
        s.params = Some(json!({ "catalog": t.id }));
        specs.push((t.id.clone(), s));
    }
    for num in 1..=93u32 {
        if let Some(id) = jetcarp_core::isohedral::id_for(num) {
            specs.push((id.to_string(), TilingSpec::new(id)));
        }
    }
    let mut bad = Vec::new();
    let mut maps_checked = 0usize;
    let mut orders: BTreeMap<usize, usize> = BTreeMap::new();
    let mut named: BTreeMap<&str, usize> = BTreeMap::new();
    for (name, spec) in &specs {
        let mut s = spec.clone();
        s.size = Some(SizeSpec::Rect { w: 8, h: 8 });
        s.boundary = Boundary::Dead;
        let t = Topology::build(&s).unwrap();
        let g = t.lattice().unwrap();
        for nb in [Nb::Touch, Nb::Edge] {
            let maps = jetcarp_core::pattern::canonical_symmetries(&t, nb, true);
            if nb == Nb::Touch {
                *orders.entry(maps.len()).or_default() += 1;
                for n in ["square", "hex", "triangle", "oct", "trihex", "cairo", "brick"] {
                    if name == n {
                        named.insert(n, maps.len());
                    }
                }
            }
            let offs = &g.offsets[nb as usize];
            for (mi, m) in maps.iter().enumerate() {
                maps_checked += 1;
                // A permutation of the tile types.
                let p: BTreeSet<u32> = m.perm.iter().cloned().collect();
                if p.len() != g.ntypes as usize || m.perm.len() != g.ntypes as usize {
                    bad.push(format!("{name} {nb:?} map {mi}: not a permutation of the tile types"));
                    continue;
                }
                let det = m.m[0] * m.m[3] - m.m[1] * m.m[2];
                if det.abs() != 1 {
                    bad.push(format!("{name} {nb:?} map {mi}: matrix determinant {det}"));
                }
                'cells: for (i, j) in [(0, 0), (1, 0), (0, 1), (3, -2)] {
                    for k in 0..g.ntypes {
                        let c = LCell { i, j, k, s: 1 };
                        let mc = m.apply(&c);
                        let image_of_nbrs: BTreeSet<(i32, i32, u32)> = offs[k as usize]
                            .iter()
                            .map(|o| {
                                let x = m.apply(&LCell { i: i + o.di, j: j + o.dj, k: o.k, s: 1 });
                                (x.i, x.j, x.k)
                            })
                            .collect();
                        let nbrs_of_image: BTreeSet<(i32, i32, u32)> =
                            offs[mc.k as usize].iter().map(|o| (mc.i + o.di, mc.j + o.dj, o.k)).collect();
                        if image_of_nbrs != nbrs_of_image || image_of_nbrs.len() != offs[k as usize].len() {
                            bad.push(format!("{name} {nb:?} map {mi}: neighbours of tile ({i},{j},{k}) are not carried to the neighbours of its image"));
                            break 'cells;
                        }
                    }
                }
            }
        }
    }
    println!("tilings: {}; cell maps checked (both neighbourhoods): {maps_checked}; not automorphisms: {}", specs.len(), bad.len());
    println!("symmetry counts (touch) for some tilings: {named:?}");
    println!("number of tilings by symmetry count (touch): {orders:?}");
    for b in bad.iter().take(20) {
        println!("  {b}");
    }
    assert!(bad.is_empty());
    assert_eq!(named.get("square"), Some(&8));
    assert_eq!(named.get("hex"), Some(&12));
}
