//! T3: every periodic tiling's neighbour graph against an independent geometric reference, plus
//! structural invariants (symmetry, no self loops, edge ⊆ touch, area).

use jetcarp_audit_harness as ah;
use jetcarp_core::families::{FAMILIES, FamilyKind};
use jetcarp_core::*;
use serde_json::json;

fn periodic_specs() -> Vec<(String, TilingSpec)> {
    let mut v = Vec::new();
    for f in FAMILIES {
        if f.kind == FamilyKind::Aperiodic || f.id == "periodic" {
            continue;
        }
        v.push((f.id.to_string(), TilingSpec::new(f.id)));
    }
    for t in jetcarp_core::catalog::all() {
        let mut s = TilingSpec::new("periodic");
        s.params = Some(json!({ "catalog": t.id }));
        v.push((format!("periodic:{}", t.id), s));
    }
    for num in 1..=93u32 {
        if let Some(id) = jetcarp_core::isohedral::id_for(num) {
            v.push((id.to_string(), TilingSpec::new(id)));
        }
    }
    v
}

fn nbrs(t: &Topology, i: usize, nb: Nb) -> Vec<usize> {
    let mut v = Vec::new();
    t.for_each_neighbor(i, nb, |j| v.push(j));
    v
}

#[test]
fn counts_of_tilings() {
    let cat = jetcarp_core::catalog::all();
    let ih = (1..=93u32).filter(|&n| jetcarp_core::isohedral::id_for(n).is_some()).count();
    let ku: Vec<_> = cat.iter().filter(|t| t.id.starts_with('k')).collect();
    println!("catalog entries: {} (k-uniform ids: {}), isohedral types: {ih}, families: {}", cat.len(), ku.len(), FAMILIES.len());
    for k in 1..=6u32 {
        println!("  k={k}: {}", ku.iter().filter(|t| t.k == k).count());
    }
    assert_eq!(ih, 81);
    assert_eq!(ku.len(), 1248);
}

/// Wrapped tori: the graph must be symmetric with matching multiplicities, without self loops or
/// repeated neighbours, edge ⊆ touch, and the tiles' areas must add up to the torus.
#[test]
fn torus_graph_invariants() {
    let mut bad = Vec::new();
    let mut checked = 0;
    for (name, spec) in periodic_specs() {
        for (w, h) in [(8u32, 8u32), (9, 11)] {
            let mut s = spec.clone();
            s.size = Some(SizeSpec::Rect { w, h });
            s.boundary = Boundary::Wrap;
            let t = match Topology::build(&s) {
                Ok(t) => t,
                Err(e) => {
                    bad.push(format!("{name} {w}x{h}: build failed: {e}"));
                    continue;
                }
            };
            checked += 1;
            let n = t.len();
            let g = t.lattice().unwrap();
            let cell_area = (g.a1[0] * g.a2[1] - g.a1[1] * g.a2[0]).abs();
            let area: f64 = (0..n).map(|i| ah::poly_area(&t.polygon(i))).sum();
            let want = cell_area * (w * h) as f64;
            if (area - want).abs() > 1e-6 * want {
                bad.push(format!("{name} {w}x{h}: tile areas sum to {area}, torus area {want}"));
            }
            for nb in [Nb::Touch, Nb::Edge] {
                let lists: Vec<Vec<usize>> = (0..n).map(|i| nbrs(&t, i, nb)).collect();
                let mut selfloop = 0;
                let mut dup = 0;
                let mut asym = 0;
                for i in 0..n {
                    if lists[i].len() != t.degree(i, nb) {
                        bad.push(format!("{name} {w}x{h} {nb:?}: wrapped cell {i} lists {} of {} slots", lists[i].len(), t.degree(i, nb)));
                    }
                    let mut s = lists[i].clone();
                    s.sort_unstable();
                    if s.contains(&i) {
                        selfloop += 1;
                    }
                    if s.windows(2).any(|p| p[0] == p[1]) {
                        dup += 1;
                    }
                    for &j in &lists[i] {
                        let a = lists[i].iter().filter(|&&x| x == j).count();
                        let b = lists[j].iter().filter(|&&x| x == i).count();
                        if a != b {
                            asym += 1;
                        }
                    }
                }
                if selfloop + dup + asym > 0 {
                    bad.push(format!("{name} {w}x{h} {nb:?}: {selfloop} self loops, {dup} cells with repeated neighbours, {asym} asymmetric links"));
                }
            }
            for i in 0..n {
                let tl = nbrs(&t, i, Nb::Touch);
                if nbrs(&t, i, Nb::Edge).iter().any(|j| !tl.contains(j)) {
                    bad.push(format!("{name} {w}x{h}: cell {i} has an edge neighbour that is not a touch neighbour"));
                    break;
                }
            }
        }
    }
    println!("tori checked: {checked}; problems: {}", bad.len());
    for b in bad.iter().take(60) {
        println!("  {b}");
    }
    assert!(bad.is_empty());
}

/// Dead-edge patches: for interior cells, JETCARP's neighbour sets must equal the reference
/// geometry's, at much tighter tolerances than JETCARP's own (1e-4 / 5e-4).
#[test]
fn neighbours_match_reference_geometry() {
    let mut bad = Vec::new();
    let mut cells = 0usize;
    let mut tilings = 0usize;
    let mut orient_pos = 0usize;
    let mut orient_neg = 0usize;
    let mut orient_bad = Vec::new();
    let mut shortest_shared: f64 = f64::INFINITY;
    let mut shortest_name = String::new();
    for (name, spec) in periodic_specs() {
        let mut s = spec.clone();
        s.size = Some(SizeSpec::Rect { w: 10, h: 10 });
        s.boundary = Boundary::Dead;
        let Ok(t) = Topology::build(&s) else {
            bad.push(format!("{name}: build failed"));
            continue;
        };
        tilings += 1;
        let n = t.len();
        let polys: Vec<Vec<ah::P>> = (0..n).map(|i| t.polygon(i)).collect();
        let (rt, re, mids) = ah::reference_neighbours(&polys, 1e-8, 1e-6);
        let mut t_bad = 0;
        let mut e_bad = 0;
        let mut first = String::new();
        for i in 0..n {
            if !t.is_interior(i) {
                continue;
            }
            cells += 1;
            let mut jt = nbrs(&t, i, Nb::Touch);
            jt.sort_unstable();
            let mut je = nbrs(&t, i, Nb::Edge);
            je.sort_unstable();
            if jt != rt[i] {
                t_bad += 1;
                if first.is_empty() {
                    first = format!("cell {i}: touch engine {jt:?} reference {:?}", rt[i]);
                }
            }
            if je != re[i] {
                e_bad += 1;
                if first.is_empty() {
                    first = format!("cell {i}: edge engine {je:?} reference {:?}", re[i]);
                }
            }
            for &(j, _) in &mids[i] {
                if let ah::Contact::Edge(len, _) = ah::contact(&polys[i], &polys[j], 1e-8, 1e-6) {
                    if len < shortest_shared {
                        shortest_shared = len;
                        shortest_name = name.clone();
                    }
                }
            }
            // Slot order: the engine lists edge neighbours in one rotational sense. Walk the
            // engine's order and add up the turning of the shared-boundary midpoints about the
            // cell's vertex average; one full turn, of the same sign everywhere, is consistent.
            let order = nbrs(&t, i, Nb::Edge);
            if order.len() >= 3 && je == re[i] {
                let c = {
                    let p = &polys[i];
                    let k = p.len() as f64;
                    p.iter().fold([0.0, 0.0], |a, q| [a[0] + q[0] / k, a[1] + q[1] / k])
                };
                let ang: Vec<f64> = order
                    .iter()
                    .map(|j| {
                        let m = mids[i].iter().find(|x| x.0 == *j).unwrap().1;
                        (m[1] - c[1]).atan2(m[0] - c[0])
                    })
                    .collect();
                let mut total = 0.0;
                for k in 0..ang.len() {
                    let mut d = ang[(k + 1) % ang.len()] - ang[k];
                    while d > std::f64::consts::PI {
                        d -= 2.0 * std::f64::consts::PI;
                    }
                    while d < -std::f64::consts::PI {
                        d += 2.0 * std::f64::consts::PI;
                    }
                    total += d;
                }
                let turns = total / (2.0 * std::f64::consts::PI);
                if (turns - 1.0).abs() < 1e-6 {
                    orient_pos += 1;
                } else if (turns + 1.0).abs() < 1e-6 {
                    orient_neg += 1;
                } else if orient_bad.len() < 20 {
                    orient_bad.push(format!("{name} cell {i}: edge slots wind {turns:.3} turns"));
                }
            }
        }
        if t_bad + e_bad > 0 {
            bad.push(format!("{name}: {t_bad} interior cells differ in touch, {e_bad} in edge; first: {first}"));
        }
    }
    println!("tilings checked: {tilings}; interior cells compared: {cells}; tilings with differences: {}", bad.len());
    println!("edge-slot winding: +1 turn in {orient_pos} cells, -1 turn in {orient_neg} cells, other in {} (first 20 shown)", orient_bad.len());
    for b in &orient_bad {
        println!("  {b}");
    }
    println!("shortest shared boundary that counts as an edge: {shortest_shared:.6} ({shortest_name})");
    for b in bad.iter().take(60) {
        println!("  {b}");
    }
    assert!(bad.is_empty());
}
