//! T9: every spaceship scene the book publishes (docs/scenes/findings, docs/scenes/life-census),
//! re-run with this harness's own B/S stepper on a larger torus than the scene's own.
//!
//! JETCARP only places the pattern (its `paste_pattern` command) and supplies the neighbour graph,
//! which T3 checked against independent geometry. The rule is applied here by a naive loop. A
//! scene passes when, after exactly the stated period, the live cells are a non-trivial lattice
//! translate of the start, the pattern never touches itself around the torus, and no earlier
//! generation is a translate of the start (so the stated period is the true one).

use jetcarp_core::rules::Rule;
use jetcarp_core::*;
use std::collections::BTreeSet;

fn period_in(desc: &str) -> Option<u64> {
    let i = desc.find("period-")? + 7;
    let digits: String = desc[i..].chars().take_while(|c| c.is_ascii_digit()).collect();
    digits.parse().ok()
}

#[test]
fn published_spaceships_recur() {
    let repo = std::env::var("JETCARP_REPO").unwrap_or_else(|_| "../../../../jetcarp".into());
    let root = format!("{repo}/docs/scenes");
    let mut files: Vec<std::path::PathBuf> = Vec::new();
    for d in ["findings", "life-census"] {
        for e in std::fs::read_dir(format!("{root}/{d}")).unwrap() {
            let p = e.unwrap().path();
            if p.extension().is_some_and(|x| x == "json") {
                files.push(p);
            }
        }
    }
    files.sort();
    let mut ok = 0;
    let mut bad = Vec::new();
    let mut total_gens = 0u64;
    for f in &files {
        let text = std::fs::read_to_string(f).unwrap();
        let mut scene = Scene::from_json(&text).unwrap();
        let name = f.file_name().unwrap().to_string_lossy().to_string();
        let Some(p) = period_in(&scene.description) else {
            bad.push(format!("{name}: no period in the description"));
            continue;
        };
        // A bigger torus than the scene's, so the ship is far from its own images.
        let (w0, h0) = match scene.tiling.size {
            Some(SizeSpec::Rect { w, h }) => (w, h),
            _ => (0, 0),
        };
        let (w, h) = (w0.max(48) * 2 + 32, h0.max(48) * 2 + 32);
        scene.tiling.size = Some(SizeSpec::Rect { w, h });
        let world = match World::from_scene(&scene) {
            Ok(w) => w,
            Err(e) => {
                bad.push(format!("{name}: {e}"));
                continue;
            }
        };
        let ca = &world.cas[0];
        let (birth, survive) = match &ca.rule {
            Rule::LifeLike { birth, survive } => (*birth, *survive),
            other => {
                bad.push(format!("{name}: rule {other:?} is not a two-state B/S rule"));
                continue;
            }
        };
        assert_eq!(birth & 1, 0, "{name}: B0");
        let nb = ca.nb;
        let t = world.topo.clone();
        let g = t.lattice().unwrap().clone();
        let n = t.len();
        let start: Vec<u8> = world.fields[ca.field].state.clone();
        let pop0 = start.iter().filter(|&&s| s != 0).count();
        if pop0 == 0 || start.iter().any(|&s| s > 1) {
            bad.push(format!("{name}: start has {pop0} live cells or other states"));
            continue;
        }
        // Lattice coordinates (unsheared i, j, type) of live cells.
        let coords = |state: &[u8]| -> BTreeSet<(i32, i32, u32)> {
            state
                .iter()
                .enumerate()
                .filter(|(_, s)| **s != 0)
                .map(|(x, _)| {
                    let (u, j, k) = g.decompose(x);
                    (u + g.row_start[j as usize], j, k)
                })
                .collect()
        };
        let c0 = coords(&start);
        // Is `cur` a translate of the start by some lattice vector (on the torus)? Try every
        // vector that takes the first start cell to a current cell of the same type.
        let translate_of_start = |cur: &[u8]| -> Option<(i32, i32)> {
            let cc = coords(cur);
            if cc.len() != c0.len() {
                return None;
            }
            let a = *c0.iter().next().unwrap();
            'cand: for b in cc.iter().filter(|b| b.2 == a.2) {
                let (di, dj) = (b.0 - a.0, b.1 - a.1);
                for c in &c0 {
                    match g.resolve(c.0 + di, c.1 + dj, c.2) {
                        Some(x) if cur[x] != 0 => {}
                        _ => continue 'cand,
                    }
                }
                return Some((di, dj));
            }
            None
        };
        let mut cur = start.clone();
        let mut earlier = None;
        let mut max_extent = 0i32;
        for gen_no in 1..=p {
            let mut next = vec![0u8; n];
            for i in 0..n {
                let mut c = 0u32;
                t.for_each_neighbor(i, nb, |j| c += cur[j] as u32);
                let m = if cur[i] == 1 { survive } else { birth };
                next[i] = ((m >> c) & 1) as u8;
            }
            cur = next;
            total_gens += 1;
            // Extent in unit cells, to be sure the ship stays small against the torus.
            let cc = coords(&cur);
            if cc.is_empty() {
                break;
            }
            let (jmin, jmax) = (cc.iter().map(|c| c.1).min().unwrap(), cc.iter().map(|c| c.1).max().unwrap());
            let us: Vec<i32> = cur.iter().enumerate().filter(|(_, s)| **s != 0).map(|(x, _)| g.decompose(x).0).collect();
            let (umin, umax) = (*us.iter().min().unwrap(), *us.iter().max().unwrap());
            max_extent = max_extent.max(jmax - jmin + 1).max(umax - umin + 1);
            if gen_no < p && earlier.is_none() && translate_of_start(&cur).is_some() {
                earlier = Some(gen_no);
            }
        }
        match translate_of_start(&cur) {
            Some((0, 0)) => bad.push(format!("{name}: after {p} generations it is back where it started (an oscillator, not a ship)")),
            Some(_) if earlier.is_some() => bad.push(format!("{name}: already a translate of the start after {} generations, stated period {p}", earlier.unwrap())),
            Some(_) if max_extent as u32 * 2 > w.min(h) => bad.push(format!("{name}: grows to {max_extent} unit cells on a {w}x{h} torus, too large to be sure")),
            Some(_) => ok += 1,
            None => bad.push(format!("{name}: after {p} generations the live cells are not a translate of the start ({} cells then, {pop0} at the start)", cur.iter().filter(|&&s| s != 0).count())),
        }
    }
    println!("spaceship scenes: {}; verified independently: {ok}; generations stepped: {total_gens}", files.len());
    for b in &bad {
        println!("  {b}");
    }
    assert!(bad.is_empty());
}
