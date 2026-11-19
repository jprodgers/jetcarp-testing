//! T4: aperiodic patches (Penrose P2/P3, hat, spectre) against independent geometry, and the
//! textbook facts each should satisfy.

use jetcarp_audit_harness as ah;
use jetcarp_core::*;
use std::collections::{BTreeMap, BTreeSet, HashMap};

fn nbrs(t: &Topology, i: usize, nb: Nb) -> Vec<usize> {
    let mut v = Vec::new();
    t.for_each_neighbor(i, nb, |j| v.push(j));
    v
}

fn perimeter(p: &[ah::P]) -> f64 {
    (0..p.len()).map(|i| ah::norm(ah::sub(p[(i + 1) % p.len()], p[i]))).sum()
}

/// Do two polygons' boundaries cross properly (a sign of overlapping tiles)?
fn crosses(p: &[ah::P], q: &[ah::P]) -> bool {
    let tol = 1e-7;
    for i in 0..p.len() {
        let (a, b) = (p[i], p[(i + 1) % p.len()]);
        for j in 0..q.len() {
            let (c, d) = (q[j], q[(j + 1) % q.len()]);
            let d1 = ah::cross(ah::sub(b, a), ah::sub(c, a));
            let d2 = ah::cross(ah::sub(b, a), ah::sub(d, a));
            let d3 = ah::cross(ah::sub(d, c), ah::sub(a, c));
            let d4 = ah::cross(ah::sub(d, c), ah::sub(b, c));
            if (d1 > tol && d2 < -tol || d1 < -tol && d2 > tol) && (d3 > tol && d4 < -tol || d3 < -tol && d4 > tol) {
                return true;
            }
        }
    }
    false
}

fn canon(seq: &[i64]) -> Vec<i64> {
    let n = seq.len();
    let mut best: Option<Vec<i64>> = None;
    let rev: Vec<i64> = seq.iter().rev().cloned().collect();
    for s in [seq.to_vec(), rev] {
        for r in 0..n {
            let v: Vec<i64> = (0..n).map(|i| s[(i + r) % n]).collect();
            if best.as_ref().is_none_or(|b| v < *b) {
                best = Some(v);
            }
        }
    }
    best.unwrap()
}

#[test]
fn aperiodic_patches() {
    let mut bad = Vec::new();
    for fam in ["penrose-kd", "penrose-rhomb", "hat", "spectre"] {
        for level in 1..=5u32 {
            let spec = TilingSpec::new(fam).with_size(SizeSpec::Level(level));
            let t = match Topology::build(&spec) {
                Ok(t) => t,
                Err(e) => {
                    bad.push(format!("{fam} level {level}: {e}"));
                    continue;
                }
            };
            let n = t.len();
            let want = jetcarp_core::aperiodic::tile_count(fam, level);
            if want != Some(n) {
                bad.push(format!("{fam} level {level}: {n} tiles, tile_count says {want:?}"));
            }
            let polys: Vec<Vec<ah::P>> = (0..n).map(|i| t.polygon(i)).collect();
            let (rt, re, _) = ah::reference_neighbours(&polys, 1e-7, 1e-5);
            // Symmetry of the engine's lists.
            let mut asym = 0;
            for i in 0..n {
                for nb in [Nb::Touch, Nb::Edge] {
                    for j in nbrs(&t, i, nb) {
                        if !nbrs(&t, j, nb).contains(&i) {
                            asym += 1;
                        }
                    }
                }
            }
            // Engine lists against the reference: for every cell that is not open, the engine's
            // lists must be the complete geometric ones; open cells may list fewer, never others.
            let (mut td, mut ed, mut extra, mut open, mut gaps, mut cross) = (0, 0, 0, 0, 0, 0);
            let mut mirrored = 0usize;
            for i in 0..n {
                let mut jt = nbrs(&t, i, Nb::Touch);
                jt.sort_unstable();
                let mut je = nbrs(&t, i, Nb::Edge);
                je.sort_unstable();
                if jt.iter().any(|j| !rt[i].contains(j)) || je.iter().any(|j| !re[i].contains(j)) {
                    extra += 1;
                }
                if t.transform(i).det() < 0.0 {
                    mirrored += 1;
                }
                for &j in &rt[i] {
                    if j > i && crosses(&polys[i], &polys[j]) {
                        cross += 1;
                    }
                }
                if t.is_open(i) {
                    open += 1;
                    continue;
                }
                if jt != rt[i] {
                    td += 1;
                }
                if je != re[i] {
                    ed += 1;
                }
                // No gaps: a closed cell's whole boundary is shared with its edge neighbours.
                let shared: f64 = re[i]
                    .iter()
                    .map(|&j| match ah::contact(&polys[i], &polys[j], 1e-7, 1e-5) {
                        ah::Contact::Edge(l, _) => l,
                        _ => 0.0,
                    })
                    .sum();
                if (shared - perimeter(&polys[i])).abs() > 1e-5 {
                    gaps += 1;
                }
            }
            let (ed_set, td_set) = t.degree_sets();
            println!(
                "{fam:<14} level {level}: {n:>6} tiles, {open:>5} open, mirrored {mirrored:>5} ({:.4}), interior degrees edge {ed_set:?} touch {td_set:?}; differ touch {td} edge {ed}, extra {extra}, asym {asym}, gaps {gaps}, crossings {cross}",
                mirrored as f64 / n as f64
            );
            if td + ed + extra + asym + gaps + cross > 0 {
                bad.push(format!("{fam} level {level}: touch {td} edge {ed} extra {extra} asym {asym} gaps {gaps} crossings {cross}"));
            }
            // Penrose vertex figures: angles at each complete vertex in units of 36 degrees.
            if fam.starts_with("penrose") && level >= 3 {
                let mut map: HashMap<(i64, i64), usize> = HashMap::new();
                let mut inc: Vec<Vec<(f64, i64)>> = Vec::new();
                for (pi, p) in polys.iter().enumerate() {
                    let m = p.len();
                    let c = p.iter().fold([0.0, 0.0], |a, q| [a[0] + q[0] / m as f64, a[1] + q[1] / m as f64]);
                    for k in 0..m {
                        let (a, b, d) = (p[(k + m - 1) % m], p[k], p[(k + 1) % m]);
                        let (u, v) = (ah::sub(a, b), ah::sub(d, b));
                        // Interior angle at b; reflex when the corner turns the other way from the polygon.
                        let mut ang = ah::cross(u, v).atan2(ah::dot(u, v)).abs().to_degrees();
                        let orient: f64 = (0..m).map(|x| ah::cross(p[x], p[(x + 1) % m])).sum();
                        let turn = ah::cross(ah::sub(b, a), ah::sub(d, b));
                        if turn * orient < 0.0 {
                            ang = 360.0 - ang;
                        }
                        let key = ((b[0] * 1e4).round() as i64, (b[1] * 1e4).round() as i64);
                        let mut found = None;
                        for dx in -1..=1 {
                            for dy in -1..=1 {
                                if let Some(&x) = map.get(&(key.0 + dx, key.1 + dy)) {
                                    found = Some(x);
                                }
                            }
                        }
                        let vi = found.unwrap_or_else(|| {
                            map.insert(key, inc.len());
                            inc.push(Vec::new());
                            inc.len() - 1
                        });
                        let dir = ah::sub(c, b);
                        // Use the bisector direction to order tiles around the vertex.
                        let bis = [u[0] / ah::norm(u) + v[0] / ah::norm(v), u[1] / ah::norm(u) + v[1] / ah::norm(v)];
                        let dirn = if ah::norm(bis) > 1e-9 && (ang < 180.0) { bis } else { dir };
                        inc[vi].push((dirn[1].atan2(dirn[0]), (ang / 36.0).round() as i64 + 100 * t.shape_of(pi) as i64));
                        if ((ang / 36.0).round() - ang / 36.0).abs() > 1e-6 {
                            bad.push(format!("{fam} level {level}: a corner angle of {ang} degrees"));
                        }
                    }
                }
                let mut figures: BTreeMap<Vec<i64>, usize> = BTreeMap::new();
                for l in &inc {
                    if l.iter().map(|x| x.1 % 100).sum::<i64>() != 10 {
                        continue;
                    }
                    let mut l = l.clone();
                    l.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap());
                    *figures.entry(canon(&l.iter().map(|x| x.1).collect::<Vec<_>>())).or_default() += 1;
                }
                println!("    complete vertex figures (corner angle / 36 deg, +100 for shape 1): {figures:?}");
                let kinds: BTreeSet<&Vec<i64>> = figures.keys().collect();
                if level >= 4 && kinds.len() != 7 {
                    bad.push(format!("{fam} level {level}: {} vertex figures, a Penrose tiling has 7", kinds.len()));
                }
            }
        }
    }
    for b in &bad {
        println!("PROBLEM {b}");
    }
    assert!(bad.is_empty());
}
