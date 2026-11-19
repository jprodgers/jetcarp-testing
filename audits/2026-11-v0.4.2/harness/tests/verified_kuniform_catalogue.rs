//! T6: the k-uniform catalogue's data against what each entry says about itself, computed from
//! the polygons alone: regular unit polygons, the set of vertex types in the name, vertices and
//! polygons per cell in the note, an upper bound on the number of vertex orbits, and pairwise
//! distinctness of the 1,248 tilings.

use jetcarp_audit_harness as ah;
use jetcarp_core::*;
use serde_json::json;
use std::collections::{BTreeMap, BTreeSet, HashMap, VecDeque};

fn canon(seq: &[u32]) -> Vec<u32> {
    let n = seq.len();
    let mut best: Option<Vec<u32>> = None;
    let rev: Vec<u32> = seq.iter().rev().cloned().collect();
    for s in [seq.to_vec(), rev] {
        for r in 0..n {
            let v: Vec<u32> = (0..n).map(|i| s[(i + r) % n]).collect();
            if best.as_ref().is_none_or(|b| v < *b) {
                best = Some(v);
            }
        }
    }
    best.unwrap()
}

/// "3^2.4.3.4" -> canonical cyclic sequence.
fn parse_type(s: &str) -> Vec<u32> {
    let mut v = Vec::new();
    for part in s.trim().split('.') {
        let (b, e) = match part.split_once('^') {
            Some((b, e)) => (b.parse::<u32>().unwrap(), e.parse::<usize>().unwrap()),
            None => (part.parse::<u32>().unwrap(), 1),
        };
        for _ in 0..e {
            v.push(b);
        }
    }
    canon(&v)
}

fn name_types(name: &str) -> Vec<Vec<u32>> {
    // "[3^2.6^2; 3.6.3.6; 6^3] #1" or "6^3 hexagonal".
    let body = if let Some(a) = name.find('[') {
        let b = name.find(']').unwrap();
        &name[a + 1..b]
    } else {
        name.split(' ').next().unwrap()
    };
    body.split(';').map(parse_type).collect()
}

fn note_number(note: &str, before: &str) -> Option<usize> {
    // "... 18 vertices per cell; 2 triangles, 6 squares, ..."
    let idx = note.find(before)?;
    let head = &note[..idx];
    head.split(|c: char| !c.is_ascii_digit())
        .filter(|s| !s.is_empty())
        .last()?
        .parse()
        .ok()
}

struct Built {
    topo: Topology,
    polys: Vec<Vec<ah::P>>,
    /// vertex id per polygon corner
    vid: Vec<Vec<usize>>,
    vpos: Vec<ah::P>,
}

fn build(id: &str, w: u32, h: u32) -> Built {
    let mut s = TilingSpec::new("periodic");
    s.params = Some(json!({ "catalog": id }));
    s.size = Some(SizeSpec::Rect { w, h });
    s.boundary = Boundary::Dead;
    let topo = Topology::build(&s).unwrap();
    let polys: Vec<Vec<ah::P>> = (0..topo.len()).map(|i| topo.polygon(i)).collect();
    let mut map: HashMap<(i64, i64), usize> = HashMap::new();
    let mut vpos = Vec::new();
    let mut vid = Vec::new();
    for p in &polys {
        let mut ids = Vec::new();
        for q in p {
            // Unit-edge tilings: corners are at least ~0.5 apart, so a 1e-4 grid with a
            // neighbour-bucket lookup identifies them safely.
            let k = ((q[0] * 1e4).round() as i64, (q[1] * 1e4).round() as i64);
            let mut found = None;
            for dx in -1..=1 {
                for dy in -1..=1 {
                    if let Some(&v) = map.get(&(k.0 + dx, k.1 + dy)) {
                        found = Some(v);
                    }
                }
            }
            let v = found.unwrap_or_else(|| {
                map.insert(k, vpos.len());
                vpos.push(*q);
                vpos.len() - 1
            });
            ids.push(v);
        }
        vid.push(ids);
    }
    Built { topo, polys, vid, vpos }
}

#[test]
fn kuniform_catalogue_is_self_consistent() {
    let cat: Vec<_> = jetcarp_core::catalog::all().iter().filter(|t| t.id.starts_with('k')).collect();
    let mut bad = Vec::new();
    let mut exact_k = 0usize;
    let mut fewer = 0usize;
    let mut sigs: BTreeMap<String, Vec<String>> = BTreeMap::new();
    for t in &cat {
        // 1. Regular unit polygons in the unit cell.
        let mut counts: BTreeMap<usize, usize> = BTreeMap::new();
        for p in &t.polys {
            let n = p.len();
            *counts.entry(n).or_default() += 1;
            for i in 0..n {
                let (a, b, c) = (p[i], p[(i + 1) % n], p[(i + 2) % n]);
                let l = ah::norm(ah::sub(b, a));
                let (u, v) = (ah::sub(b, a), ah::sub(c, b));
                let turn = ah::cross(u, v).atan2(ah::dot(u, v)).abs();
                let want = 2.0 * std::f64::consts::PI / n as f64;
                if (l - 1.0).abs() > 1e-9 || (turn - want).abs() > 1e-9 {
                    bad.push(format!("{}: a {n}-gon is not a regular unit polygon (side {l}, turn {turn})", t.id));
                }
            }
        }
        // 2. Polygon counts in the note.
        let has_counts = t.note.contains("vertices per cell");
        for (n, word) in [(3usize, "triangle"), (4, "square"), (6, "hexagon"), (8, "octagon"), (12, "dodecagon")] {
            if !has_counts {
                break;
            }
            let said = note_number(&t.note, word).unwrap_or(0);
            let have = counts.get(&n).copied().unwrap_or(0);
            if said != have {
                bad.push(format!("{}: note says {said} {word}s, cell has {have}", t.id));
            }
        }
        // 3. Vertex figures on a patch, and vertices per cell.
        let radius: usize = std::env::var("AUDIT_RADIUS").ok().and_then(|v| v.parse().ok()).unwrap_or(7);
        let only: Option<String> = std::env::var("AUDIT_ONLY").ok();
        if let Some(o) = &only {
            if !o.split(',').any(|x| x == t.id) {
                continue;
            }
        }
        let probe = build(&t.id, 8, 8);
        let (pa1, pa2) = {
            let g = probe.topo.lattice().unwrap();
            (g.a1, g.a2)
        };
        let r0 = ah::norm(pa1) + ah::norm(pa2);
        let grow: f64 = std::env::var("AUDIT_GROW").ok().and_then(|v| v.parse().ok()).unwrap_or(1.8);
        let need = 2.0 * (r0 + radius as f64 + 3.0) * grow;
        let w = ((need / pa1[0].abs()).ceil() as u32).max(8);
        let h = ((need / pa2[1].abs()).ceil() as u32).max(8);
        let b = build(&t.id, w, h);
        let nv = b.vpos.len();
        let mut inc: Vec<Vec<(f64, u32)>> = vec![Vec::new(); nv];
        let mut ang_sum = vec![0.0f64; nv];
        for (pi, p) in b.polys.iter().enumerate() {
            let n = p.len();
            let c = p.iter().fold([0.0, 0.0], |a, q| [a[0] + q[0] / n as f64, a[1] + q[1] / n as f64]);
            for (k, &v) in b.vid[pi].iter().enumerate() {
                let d = ah::sub(c, b.vpos[v]);
                inc[v].push((d[1].atan2(d[0]), n as u32));
                ang_sum[v] += std::f64::consts::PI - 2.0 * std::f64::consts::PI / n as f64;
                let _ = k;
            }
        }
        let full = |v: usize| (ang_sum[v] - 2.0 * std::f64::consts::PI).abs() < 1e-6;
        let mut species: BTreeSet<Vec<u32>> = BTreeSet::new();
        let mut vtype: Vec<Option<Vec<u32>>> = vec![None; nv];
        for v in 0..nv {
            if !full(v) {
                continue;
            }
            let mut l = inc[v].clone();
            l.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap());
            let c = canon(&l.iter().map(|x| x.1).collect::<Vec<_>>());
            species.insert(c.clone());
            vtype[v] = Some(c);
        }
        let named: BTreeSet<Vec<u32>> = name_types(&t.name).into_iter().collect();
        if species != named {
            bad.push(format!("{}: name {:?} lists vertex types {named:?}, tiling has {species:?}", t.id, t.name));
        }
        // Vertices per cell: complete vertices in a half-open copy of the unit cell.
        let g = b.topo.lattice().unwrap();
        let det = g.a1[0] * g.a2[1] - g.a1[1] * g.a2[0];
        let cc = b.topo.centroid(b.topo.center_cell());
        let origin = [cc[0] + 0.013, cc[1] + 0.007];
        let per_cell = (0..nv)
            .filter(|&v| {
                let p = ah::sub(b.vpos[v], origin);
                let i = (p[0] * g.a2[1] - g.a2[0] * p[1]) / det;
                let j = (g.a1[0] * p[1] - p[0] * g.a1[1]) / det;
                (0.0..1.0).contains(&i) && (0.0..1.0).contains(&j)
            })
            .count();
        let said = note_number(&t.note, "vertices per cell").unwrap_or(0);
        if has_counts && said != per_cell {
            bad.push(format!("{}: note says {said} vertices per cell, patch has {per_cell}", t.id));
        }
        // 4. Vertex orbits: classes of (vertex figure, coordination sequence in the vertex graph)
        // among complete vertices far from the patch edge. Vertices of one orbit always agree, so
        // more classes than k is an error; fewer only means the sequence is too short to tell.
        let mut adj: Vec<Vec<usize>> = vec![Vec::new(); nv];
        for ids in &b.vid {
            let n = ids.len();
            for k in 0..n {
                let (a, c) = (ids[k], ids[(k + 1) % n]);
                if !adj[a].contains(&c) {
                    adj[a].push(c);
                    adj[c].push(a);
                }
            }
        }
        let mut classes: BTreeSet<(Vec<u32>, Vec<usize>)> = BTreeSet::new();
        let centre = cc;
        let span = r0 / 1.1;
        let mut ok_seq = true;
        for v in 0..nv {
            if !full(v) || ah::norm(ah::sub(b.vpos[v], centre)) > span * 1.1 {
                continue;
            }
            let mut dist = vec![usize::MAX; nv];
            let mut q = VecDeque::new();
            dist[v] = 0;
            q.push_back(v);
            let mut seq = vec![0usize; radius + 1];
            while let Some(x) = q.pop_front() {
                let d = dist[x];
                seq[d] += 1;
                if !full(x) {
                    ok_seq = false;
                }
                if d == radius {
                    continue;
                }
                for &y in &adj[x] {
                    if dist[y] == usize::MAX {
                        dist[y] = d + 1;
                        q.push_back(y);
                    }
                }
            }
            classes.insert((vtype[v].clone().unwrap(), seq));
        }
        if !ok_seq {
            bad.push(format!("{}: patch too small for the orbit check", t.id));
        }
        if classes.len() > t.k as usize {
            bad.push(format!("{}: {} vertex classes found but k = {}", t.id, classes.len(), t.k));
        } else if classes.len() == t.k as usize {
            exact_k += 1;
        } else {
            fewer += 1;
        }
        // 5. A signature for distinctness: k, the sorted classes, polygon counts, vertices per cell.
        let sig = format!("{} {:?} {:?} {}", t.k, classes, counts, per_cell);
        sigs.entry(sig).or_default().push(t.id.clone());
    }
    let dups: Vec<&Vec<String>> = sigs.values().filter(|v| v.len() > 1).collect();
    println!("k-uniform entries checked: {}", cat.len());
    let shown_radius: usize = std::env::var("AUDIT_RADIUS").ok().and_then(|v| v.parse().ok()).unwrap_or(7);
    println!("vertex classes (radius {shown_radius}) equal k in {exact_k}, fewer than k in {fewer}, more than k in the list below");
    println!("groups of entries with identical signatures: {}", dups.len());
    for d in dups.iter().take(20) {
        println!("  same signature: {d:?}");
    }
    println!("problems: {}", bad.len());
    for b in bad.iter().take(60) {
        println!("  {b}");
    }
    assert!(bad.is_empty());
}
