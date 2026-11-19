//! T11: JACA against a reference written from the book's definition (docs/src/automata/jaca.md,
//! "What it is"): contact, blast, then each sign's own B/S rule with cancelling births.
use jetcarp_core::rules::Rule;
use jetcarp_core::*;
use std::collections::VecDeque;

fn run(spec: TilingSpec, rule: &str, gens: usize, label: &str) -> (bool, bool) {
    let mut w = World::new(spec, 77).unwrap();
    w.add_ca(CaSpec::new(rule).seed(SeedSpec::Signed { density: 0.35, negative: 0.5 })).unwrap();
    let j = match &w.cas[0].rule {
        Rule::Jaca(j) => (**j).clone(),
        o => panic!("{o:?}"),
    };
    let nb = w.cas[0].nb;
    let t = w.topo.clone();
    let n = t.len();
    // Two readings of "destroyed" for EMPTY cells inside a blast: births suppressed (a) or not (b).
    let mut cur_a = w.fields[0].state.clone();
    let mut cur_b = cur_a.clone();
    let (mut ok_a, mut ok_b) = (true, true);
    let step = |cur: &Vec<u8>, suppress_births: bool| -> Vec<u8> {
        let mut contact = vec![false; n];
        for i in 0..n {
            if cur[i] != 0 {
                let opp = 3 - cur[i];
                let mut c = false;
                t.for_each_neighbor(i, nb, |k| c |= cur[k] == opp);
                contact[i] = c;
            }
        }
        // Blast zone: within `blast` steps of a contact cell (the contact cells themselves at 0).
        let mut dist = vec![u32::MAX; n];
        let mut q = VecDeque::new();
        for i in 0..n {
            if contact[i] {
                dist[i] = 0;
                q.push_back(i);
            }
        }
        while let Some(i) = q.pop_front() {
            if dist[i] >= j.blast as u32 {
                continue;
            }
            t.for_each_neighbor(i, nb, |k| {
                if dist[k] == u32::MAX {
                    dist[k] = dist[i] + 1;
                    q.push_back(k);
                }
            });
        }
        (0..n)
            .map(|i| {
                let zone = dist[i] != u32::MAX;
                let (mut p, mut m) = (0u32, 0u32);
                t.for_each_neighbor(i, nb, |k| {
                    p += (cur[k] == 1) as u32;
                    m += (cur[k] == 2) as u32;
                });
                match cur[i] {
                    0 => {
                        if zone && suppress_births {
                            0
                        } else {
                            let bp = j.pos_birth >> p & 1 == 1;
                            let bn = j.neg_birth >> m & 1 == 1;
                            match (bp, bn) {
                                (true, false) => 1,
                                (false, true) => 2,
                                _ => 0,
                            }
                        }
                    }
                    1 => (!zone && j.pos_survive >> p & 1 == 1) as u8,
                    _ => {
                        if !zone && j.neg_survive >> m & 1 == 1 {
                            2
                        } else {
                            0
                        }
                    }
                }
            })
            .collect()
    };
    for _ in 0..gens {
        w.step();
        cur_a = step(&cur_a, true);
        cur_b = step(&cur_b, false);
        ok_a &= w.fields[0].state == cur_a;
        ok_b &= w.fields[0].state == cur_b;
        if !ok_a {
            cur_a = w.fields[0].state.clone();
        }
        if !ok_b {
            cur_b = w.fields[0].state.clone();
        }
    }
    println!("{label:<34} {rule:<34} blast {}: births suppressed in the blast zone matches = {ok_a}; not suppressed matches = {ok_b}", j.blast);
    (ok_a, ok_b)
}

#[test]
fn jaca_matches_the_books_definition() {
    let mut any_bad = false;
    let mut readings = (0, 0);
    for (fam, sz) in [("square", None), ("hex", None), ("trihex", None), ("cairo", None), ("penrose-rhomb", Some(3u32)), ("hat", Some(3))] {
        for rule in ["JACA B3/S23", "JACA +B3/S23 -B36/S23", "JACA B2/S", "JACA B27/S013", "JACA B16/S1378 blast 1", "JACA B3/S23 blast 2", "JACA B13/S234V blast 3"] {
            let spec = match sz {
                Some(l) => TilingSpec::new(fam).with_size(SizeSpec::Level(l)),
                None => TilingSpec::rect(fam, 16, 16, Boundary::Wrap),
            };
            let (a, b) = run(spec, rule, 40, fam);
            any_bad |= !(a || b);
            readings.0 += a as u32;
            readings.1 += b as u32;
        }
    }
    println!("cases matching reading (a) births suppressed in the zone: {}; reading (b) not suppressed: {}", readings.0, readings.1);
    assert!(!any_bad, "the engine matches neither reading of the book's definition in some case");
}
