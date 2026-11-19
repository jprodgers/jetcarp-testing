//! Runs a pattern in JETCARP's engine and compares it, generation by generation and cell by cell,
//! with the cells an outside reference says should be live.
//!
//! Input (file named by GUTT_FILE): one line per generation to check, in increasing order:
//!   <generation> <i,j,k> <i,j,k> ...
//! in JETCARP's lattice coordinates. The first line must be generation 0 and is the start.
//! GUTT_FAMILY, GUTT_W, GUTT_H give the tiling (dead edges; the pattern must stay inside).
use jetcarp_core::*;
use std::collections::BTreeSet;

fn env(k: &str) -> String {
    std::env::var(k).unwrap_or_else(|_| panic!("set {k}"))
}

#[test]
fn run() {
    let Ok(file) = std::env::var("GUTT_FILE") else {
        eprintln!("GUTT_FILE not set: nothing to do");
        return;
    };
    let fam = env("GUTT_FAMILY");
    let w: u32 = env("GUTT_W").parse().unwrap();
    let h: u32 = env("GUTT_H").parse().unwrap();
    let rule = std::env::var("GUTT_RULE").unwrap_or_else(|_| "B3/S23".into());
    let spec = TilingSpec::rect(&fam, w, h, Boundary::Dead);
    let mut world = World::new(spec, 1).unwrap();
    let id = world.add_ca(CaSpec::new(&rule).nb(Nb::Touch).seed(SeedSpec::Empty)).unwrap();
    let topo = world.topo.clone();
    let g = topo.lattice().expect("lattice storage");
    let text = std::fs::read_to_string(&file).unwrap();
    let mut lines = text.lines().filter(|l| !l.trim().is_empty());
    let parse = |line: &str| -> (u64, BTreeSet<u32>) {
        let mut it = line.split_whitespace();
        let generation: u64 = it.next().unwrap().parse().unwrap();
        let mut set = BTreeSet::new();
        for tok in it {
            let v: Vec<i64> = tok.split(',').map(|x| x.parse().unwrap()).collect();
            let idx = g
                .resolve(v[0] as i32, v[1] as i32, v[2] as u32)
                .unwrap_or_else(|| panic!("generation {generation}: cell {tok} is outside the {w} by {h} patch"));
            assert!(topo.is_interior(idx), "generation {generation}: cell {tok} is on the patch's edge");
            set.insert(idx as u32);
        }
        (generation, set)
    };
    let (g0, start) = parse(lines.next().unwrap());
    assert_eq!(g0, 0);
    world
        .apply(Command::SetCells { id, cells: start.iter().map(|&c| [c, 1]).collect() })
        .unwrap();
    let live = |w: &World| -> BTreeSet<u32> {
        w.fields[0].state.iter().enumerate().filter(|(_, s)| **s != 0).map(|(i, _)| i as u32).collect()
    };
    assert_eq!(live(&world), start, "the start was set as given");
    let (mut cur, mut checked, mut bad, mut cells) = (0u64, 0u64, 0u64, 0u64);
    let mut first_bad: Option<(u64, usize, usize)> = None;
    for line in lines {
        let (generation, want) = parse(line);
        assert!(generation > cur);
        while cur < generation {
            world.step();
            cur += 1;
        }
        let got = live(&world);
        checked += 1;
        cells += want.len() as u64;
        if got != want {
            bad += 1;
            if first_bad.is_none() {
                first_bad = Some((generation, got.difference(&want).count(), want.difference(&got).count()));
            }
        }
    }
    println!(
        "RESULT family={fam} patch={w}x{h} cells_in_patch={} rule={rule} start_cells={} generations_checked={checked} last_generation={cur} live_cells_compared={cells} generations_that_differ={bad} first_difference={:?} final_population={} final_hash={}",
        topo.len(),
        start.len(),
        first_bad,
        live(&world).len(),
        world.hash_hex()
    );
    assert_eq!(bad, 0, "JETCARP and the reference disagree");
}
