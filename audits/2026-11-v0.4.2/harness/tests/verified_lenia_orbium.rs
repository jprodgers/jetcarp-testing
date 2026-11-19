//! T8: Lenia sanity. With Chan's standard Orbium parameters the built-in orbium must persist as a
//! compact glider: mass roughly steady, moving at a steady speed. A wrong kernel or growth
//! function makes it die or blow up within a few dozen steps.
use jetcarp_core::*;

#[test]
fn orbium_glides() {
    let mut w = World::new(TilingSpec::rect("square", 128, 128, Boundary::Wrap), 1).unwrap();
    w.add_ca(CaSpec::new("Lenia R=13,T=10,b=1,m=0.15,s=0.015").seed(SeedSpec::Lenia { name: "orbium".into(), scale: 1.0 }))
        .unwrap();
    let g = w.topo.lattice().unwrap().clone();
    let com = |w: &World| {
        // Circular mean on the torus.
        let (mut sx, mut cx, mut sy, mut cy, mut m) = (0.0f64, 0.0f64, 0.0f64, 0.0f64, 0.0f64);
        for (i, &v) in w.fields[0].value.iter().enumerate() {
            let (u, j, _) = g.decompose(i);
            let (ax, ay) = (u as f64 / 128.0 * std::f64::consts::TAU, j as f64 / 128.0 * std::f64::consts::TAU);
            sx += v as f64 * ax.sin();
            cx += v as f64 * ax.cos();
            sy += v as f64 * ay.sin();
            cy += v as f64 * ay.cos();
            m += v as f64;
        }
        (sx.atan2(cx) / std::f64::consts::TAU * 128.0, sy.atan2(cy) / std::f64::consts::TAU * 128.0, m)
    };
    let mut track = Vec::new();
    for gn in 0..=400 {
        if gn % 50 == 0 {
            track.push(com(&w));
        }
        w.step();
    }
    let masses: Vec<f64> = track.iter().map(|t| t.2).collect();
    println!("orbium mass every 50 generations: {:?}", masses.iter().map(|m| (m * 10.0).round() / 10.0).collect::<Vec<_>>());
    let mut speeds = Vec::new();
    for k in 1..track.len() {
        let wrapd = |d: f64| ((d + 64.0).rem_euclid(128.0)) - 64.0;
        let (dx, dy) = (wrapd(track[k].0 - track[k - 1].0), wrapd(track[k].1 - track[k - 1].1));
        speeds.push((dx * dx + dy * dy).sqrt() / 50.0);
    }
    println!("speed (cells per generation) per 50-generation window: {:?}", speeds.iter().map(|s| (s * 1000.0).round() / 1000.0).collect::<Vec<_>>());
    let m0 = masses[1];
    assert!(masses[1..].iter().all(|m| (m / m0 - 1.0).abs() < 0.05), "mass drifts: {masses:?}");
    let s0 = speeds[1];
    assert!(s0 > 0.05 && speeds[1..].iter().all(|s| (s / s0 - 1.0).abs() < 0.1), "speed not steady: {speeds:?}");
}
