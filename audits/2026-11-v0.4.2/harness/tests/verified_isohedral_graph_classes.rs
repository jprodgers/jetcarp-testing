//! T12: the book says the 81 isohedral types have only eleven neighbour graphs (30 the square
//! grid, 19 the hexagonal grid, 8 the triangular grid, 3 Cairo, ...). Classify them here by an
//! invariant computed from scratch: the coordination sequences (edge graph and touch graph) from
//! every tile of a unit cell on a large torus, and compare with the reference lattices.
use jetcarp_core::*;
use std::collections::{BTreeMap, BTreeSet, VecDeque};

fn seqs(spec: TilingSpec, radius: usize) -> BTreeSet<(Vec<usize>, Vec<usize>)> {
    let mut s = spec;
    s.boundary = Boundary::Wrap;
    // Unit cells of isohedral types hold up to 12 tiles; 40x40 cells keeps radius 9 clear of the wrap.
    s.size = Some(SizeSpec::Rect { w: 40, h: 40 });
    let t = Topology::build(&s).unwrap();
    let g = t.lattice().unwrap();
    let nt = g.ntypes as usize;
    let centre = t.center_cell() - t.center_cell() % nt;
    let mut out = BTreeSet::new();
    for k in 0..nt {
        let mut both = Vec::new();
        for nb in [Nb::Edge, Nb::Touch] {
            let mut dist = vec![u32::MAX; t.len()];
            let mut q = VecDeque::new();
            dist[centre + k] = 0;
            q.push_back(centre + k);
            let mut seq = vec![0usize; radius + 1];
            while let Some(i) = q.pop_front() {
                let d = dist[i] as usize;
                seq[d] += 1;
                if d == radius {
                    continue;
                }
                t.for_each_neighbor(i, nb, |j| {
                    if dist[j] == u32::MAX {
                        dist[j] = d as u32 + 1;
                        q.push_back(j);
                    }
                });
            }
            both.push(seq);
        }
        out.insert((both[0].clone(), both[1].clone()));
    }
    out
}

#[test]
fn isohedral_types_fall_into_eleven_graphs() {
    let radius = 9;
    let mut classes: BTreeMap<BTreeSet<(Vec<usize>, Vec<usize>)>, Vec<String>> = BTreeMap::new();
    let mut not_transitive = Vec::new();
    for num in 1..=93u32 {
        if let Some(id) = jetcarp_core::isohedral::id_for(num) {
            let s = seqs(TilingSpec::new(id), radius);
            if s.len() != 1 {
                not_transitive.push(id.to_string());
            }
            classes.entry(s).or_default().push(id.to_string());
        }
    }
    let refs: Vec<(&str, BTreeSet<(Vec<usize>, Vec<usize>)>)> = ["square", "hex", "triangle", "cairo", "brick", "oct", "trihex"]
        .iter()
        .map(|f| (*f, seqs(TilingSpec::new(f), radius)))
        .collect();
    println!("isohedral types: {}; distinct graph classes: {}", classes.values().map(|v| v.len()).sum::<usize>(), classes.len());
    let mut sizes: Vec<(usize, String, String)> = Vec::new();
    for (sig, ids) in &classes {
        let named: Vec<&str> = refs.iter().filter(|(_, s)| s == sig).map(|(n, _)| *n).collect();
        let e = &sig.iter().next().unwrap().0;
        sizes.push((ids.len(), format!("{named:?}"), format!("edge degree {} seq {:?}", e[1], &e[1..5])));
    }
    sizes.sort_by(|a, b| b.0.cmp(&a.0));
    for (n, named, d) in &sizes {
        println!("  {n:>2} types: same graph as {named:<22} {d}");
    }
    println!("types whose tiles do not all have the same sequences (not tile-transitive as built): {not_transitive:?}");
    assert_eq!(classes.len(), 11);
}
