//! T5: rule semantics against independent, deliberately naive reference implementations on the
//! square grid (where the literature fixes the answer), plus thread-count independence.

use jetcarp_core::rules::Rule;
use jetcarp_core::*;

fn sq(w: u32, h: u32, b: Boundary, rule: &str, seed: SeedSpec, rng: u64) -> World {
    let mut wd = World::new(TilingSpec::rect("square", w, h, b), rng).unwrap();
    wd.add_ca(CaSpec::new(rule).seed(seed)).unwrap();
    wd
}

/// Grid of the world's first field as rows; checks that cell index = j * w + u on the square grid.
fn grid(w: &World) -> (usize, usize, Vec<u8>) {
    let g = w.topo.lattice().unwrap();
    (g.w as usize, g.h as usize, w.fields[0].state.clone())
}

fn at(g: &[u8], w: usize, h: usize, x: i64, y: i64, b: Boundary) -> u8 {
    let (wi, hi) = (w as i64, h as i64);
    match b {
        Boundary::Wrap => g[(y.rem_euclid(hi) * wi + x.rem_euclid(wi)) as usize],
        _ if x < 0 || y < 0 || x >= wi || y >= hi => (b == Boundary::Live) as u8,
        _ => g[(y * wi + x) as usize],
    }
}

/// Reference Generations / Life-like step (states 2 = Life-like), neighbourhood given as offsets.
fn ref_bs(g: &[u8], w: usize, h: usize, b: Boundary, birth: u32, survive: u32, states: u8, hood: &[(i64, i64)]) -> Vec<u8> {
    let mut out = vec![0u8; g.len()];
    for y in 0..h as i64 {
        for x in 0..w as i64 {
            let s = g[(y as usize) * w + x as usize];
            let c = hood.iter().filter(|(dx, dy)| at(g, w, h, x + dx, y + dy, b) == 1).count() as u32;
            out[(y as usize) * w + x as usize] = if s == 0 {
                (birth >> c & 1) as u8
            } else if s == 1 {
                if survive >> c & 1 == 1 {
                    1
                } else if states > 2 {
                    2
                } else {
                    0
                }
            } else if s + 1 < states {
                s + 1
            } else {
                0
            };
        }
    }
    out
}

const MOORE: [(i64, i64); 8] = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)];
const VN: [(i64, i64); 4] = [(0, -1), (-1, 0), (1, 0), (0, 1)];

#[test]
fn life_like_and_generations_match_reference() {
    let mut cases = 0;
    for rule in ["B3/S23", "B36/S23", "B3678/S34678", "B2/S", "B1357/S1357", "B2/S/C3", "B2/S345/C4", "B3/S23V", "B13/S024V", "B2/S/C4V", "B3468/S0235678/C9"] {
        let (r, nb) = Rule::parse(rule).unwrap();
        let (birth, survive, states) = match r {
            Rule::LifeLike { birth, survive } => (birth, survive, 2),
            Rule::Generations { birth, survive, states } => (birth, survive, states),
            _ => unreachable!(),
        };
        let hood: &[(i64, i64)] = if nb == Some(Nb::Edge) { &VN } else { &MOORE };
        for b in [Boundary::Wrap, Boundary::Dead, Boundary::Live] {
            for (w, h) in [(8u32, 8u32), (17, 9), (40, 31)] {
                let mut wd = sq(w, h, b, rule, SeedSpec::Random { density: 0.37 }, 7 + w as u64);
                let (gw, gh, mut g) = grid(&wd);
                for gn in 1..=60 {
                    wd.step();
                    g = ref_bs(&g, gw, gh, b, birth, survive, states, hood);
                    assert_eq!(wd.fields[0].state, g, "{rule} {b:?} {w}x{h} generation {gn}");
                }
                cases += 1;
            }
        }
    }
    println!("life-like/generations cases matching the reference for 60 generations: {cases}");
}

#[test]
fn larger_than_life_matches_reference_on_squares() {
    // Bosco's rule in both notations, a von Neumann rule, and a multi-state rule.
    let cases: &[(&str, i64, bool, u32, u32, u32, u32, u8)] = &[
        // (rule, range, moore, s_lo, s_hi, b_lo, b_hi, states) with the centre NOT counted.
        ("R5,C2,S33-57,B34-45", 5, true, 33, 57, 34, 45, 2),
        ("R5,C0,M1,S34..58,B34..45,NM", 5, true, 33, 57, 34, 45, 2),
        ("R3,C2,S6-11,B7-9,NN", 3, false, 6, 11, 7, 9, 2),
        ("R2,C4,S5-9,B6-8", 2, true, 5, 9, 6, 8, 4),
    ];
    for &(rule, r, moore, slo, shi, blo, bhi, states) in cases {
        for b in [Boundary::Wrap, Boundary::Dead, Boundary::Live] {
            let mut wd = sq(48, 40, b, rule, SeedSpec::Random { density: 0.45 }, 3);
            let (w, h, mut g) = grid(&wd);
            for gn in 1..=25 {
                wd.step();
                let mut out = vec![0u8; g.len()];
                for y in 0..h as i64 {
                    for x in 0..w as i64 {
                        let mut c = 0u32;
                        for dy in -r..=r {
                            for dx in -r..=r {
                                if (dx, dy) == (0, 0) || (!moore && dx.abs() + dy.abs() > r) {
                                    continue;
                                }
                                c += (at(&g, w, h, x + dx, y + dy, b) == 1) as u32;
                            }
                        }
                        let s = g[y as usize * w + x as usize];
                        out[y as usize * w + x as usize] = if s == 0 {
                            (c >= blo && c <= bhi) as u8
                        } else if s == 1 {
                            if c >= slo && c <= shi {
                                1
                            } else if states > 2 {
                                2
                            } else {
                                0
                            }
                        } else if s + 1 < states {
                            s + 1
                        } else {
                            0
                        };
                    }
                }
                g = out;
                assert_eq!(wd.fields[0].state, g, "{rule} {b:?} generation {gn}");
            }
        }
    }
}

#[test]
fn elementary_rules_match_reference() {
    for rule in [30u32, 90, 110, 184, 73] {
        for b in [Boundary::Wrap, Boundary::Dead] {
            let mut wd = sq(101, 80, b, &format!("W{rule}"), SeedSpec::TopCenter, 1);
            for _ in 0..79 {
                wd.step();
            }
            let (w, h, g) = grid(&wd);
            let mut row: Vec<u8> = g[..w].to_vec();
            assert_eq!(row.iter().map(|&x| x as u32).sum::<u32>(), 1, "one seed cell in the top row");
            for y in 1..h {
                let next: Vec<u8> = (0..w as i64)
                    .map(|x| {
                        let rd = |x: i64| at(&row, w, 1, x, 0, b) as u32;
                        ((rule >> (rd(x - 1) << 2 | rd(x) << 1 | rd(x + 1))) & 1) as u8
                    })
                    .collect();
                assert_eq!(&g[y * w..(y + 1) * w], &next[..], "W{rule} {b:?} row {y}");
                row = next;
            }
        }
    }
}

#[test]
fn langtons_ant_builds_its_highway() {
    // Langton's ant: on a white cell turn right, on a black cell turn left, flip the cell, step.
    // After about 10,000 steps it settles into the "highway": a 104-step cycle that moves it two
    // cells diagonally. The engine's convention for "right" may mirror the usual drawing, which
    // only mirrors the path; the highway and its period are the same either way.
    let mut wd = sq(400, 400, Boundary::Dead, "Ant RL", SeedSpec::Ants { count: 1 }, 1);
    let g = wd.topo.lattice().unwrap().clone();
    let pos = |w: &World| {
        let (u, j, _) = g.decompose(w.cas[0].agents[0].cell as usize);
        (u as i64, j as i64)
    };
    // Reference ant, both chiralities.
    let run_ref = |right: i64, steps: usize| -> ((i64, i64), u64) {
        let (mut x, mut y) = (200i64, 200i64);
        let dirs = [(0i64, -1i64), (1, 0), (0, 1), (-1, 0)];
        let mut d = 0i64;
        let mut black = std::collections::HashSet::new();
        let mut first = true;
        let _ = &mut first;
        for _ in 0..steps {
            if black.contains(&(x, y)) {
                d = (d - right).rem_euclid(4);
                black.remove(&(x, y));
            } else {
                d = (d + right).rem_euclid(4);
                black.insert((x, y));
            }
            x += dirs[d as usize].0;
            y += dirs[d as usize].1;
        }
        ((x, y), black.len() as u64)
    };
    let start = pos(&wd);
    for _ in 0..11000 {
        wd.step();
    }
    let p0 = pos(&wd);
    let pop0 = wd.fields[0].population();
    for _ in 0..104 {
        wd.step();
    }
    let p1 = pos(&wd);
    let d = (p1.0 - p0.0, p1.1 - p0.1);
    println!("ant start {start:?}; after 11000 steps at {p0:?} with {pop0} black cells; 104 steps later moved by {d:?}");
    assert_eq!((d.0.abs(), d.1.abs()), (2, 2), "the highway moves 2 cells diagonally every 104 steps");
    // The number of black cells after 11,000 steps does not depend on chirality or start heading.
    let (_, ref_pop) = run_ref(1, 11000);
    let (_, ref_pop_m) = run_ref(-1, 11000);
    assert_eq!(ref_pop, ref_pop_m);
    assert_eq!(pop0, ref_pop, "black cells after 11,000 steps");
}

#[test]
fn sandpile_matches_reference_and_conserves_grains() {
    for grains in [1u64, 4, 5, 64, 1000, 20000] {
        let mut wd = World::new(TilingSpec::rect("square", 41, 41, Boundary::Dead), 1).unwrap();
        wd.add_ca(CaSpec::new("Sandpile").seed(SeedSpec::Pile { grains })).unwrap();
        let n = 41usize;
        let c = wd.topo.center_cell();
        assert_eq!(wd.fields[0].height[c] as u64, grains);
        // Reference: topple one cell at a time (any order gives the same result: the model is Abelian).
        let mut h = vec![0u64; n * n];
        h[c] = grains;
        let mut lost = 0u64;
        let mut stack = vec![c];
        while let Some(i) = stack.pop() {
            while h[i] >= 4 {
                h[i] -= 4;
                let (x, y) = ((i % n) as i64, (i / n) as i64);
                for (dx, dy) in VN {
                    let (nx, ny) = (x + dx, y + dy);
                    if nx < 0 || ny < 0 || nx >= n as i64 || ny >= n as i64 {
                        lost += 1;
                    } else {
                        let j = ny as usize * n + nx as usize;
                        h[j] += 1;
                        if h[j] >= 4 {
                            stack.push(j);
                        }
                    }
                }
            }
        }
        let mut gens = 0;
        loop {
            let before = wd.fields[0].height.clone();
            wd.step();
            gens += 1;
            if wd.fields[0].height == before || gens > 200000 {
                break;
            }
        }
        let eng: Vec<u64> = wd.fields[0].height.iter().map(|&x| x as u64).collect();
        assert_eq!(eng, h, "stable sandpile of {grains} grains");
        assert_eq!(wd.fields[0].lost, lost, "grains lost over the edge, {grains} grains");
        assert_eq!(eng.iter().sum::<u64>() + wd.fields[0].lost, grains, "grains are conserved");
        println!("sandpile {grains} grains: stable after {gens} sweeps, {} lost", lost);
    }
}

#[test]
fn results_do_not_depend_on_thread_count() {
    let run = |threads: usize, fam: &str, rule: &str| -> (String, Vec<u8>) {
        let pool = rayon::ThreadPoolBuilder::new().num_threads(threads).build().unwrap();
        pool.install(|| {
            let mut w = World::new(TilingSpec::new(fam).with_size(SizeSpec::Cells(40000)).with_boundary(Boundary::Wrap), 99).unwrap();
            w.add_ca(CaSpec::new(rule)).unwrap();
            for _ in 0..40 {
                w.step();
            }
            (w.hash_hex(), w.fields[0].state.clone())
        })
    };
    for (fam, rule) in [
        ("square", "B3/S23"),
        ("trihex", "B2/S34"),
        ("snubsq", "Cyclic 8/2"),
        ("hex", "ForestFire 0.02/0.0005"),
        ("cairo", "Hodgepodge 100/2/3/28"),
        ("square", "R5,C2,S33-57,B34-45"),
        ("rhombitrihex", "B03/S23"),
        ("square", "Lenia R=13,T=10,b=1,m=0.15,s=0.015"),
        ("hex", "JACA B3/S23"),
    ] {
        let a = run(1, fam, rule);
        let b = run(4, fam, rule);
        let c = run(3, fam, rule);
        assert_eq!(a, b, "{fam} {rule}: 1 thread vs 4");
        assert_eq!(a, c, "{fam} {rule}: 1 thread vs 3");
    }
}
