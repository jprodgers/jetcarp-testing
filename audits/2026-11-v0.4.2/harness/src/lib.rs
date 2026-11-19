//! Shared helpers for the independent audit harness. Nothing here calls JETCARP's own contact
//! or neighbour code: the geometry below is a separate implementation, with different tolerances
//! and a different method (segment/segment distance), used as a reference.

pub type P = [f64; 2];

pub fn sub(a: P, b: P) -> P {
    [a[0] - b[0], a[1] - b[1]]
}
pub fn dot(a: P, b: P) -> f64 {
    a[0] * b[0] + a[1] * b[1]
}
pub fn cross(a: P, b: P) -> f64 {
    a[0] * b[1] - a[1] * b[0]
}
pub fn norm(a: P) -> f64 {
    dot(a, a).sqrt()
}

pub fn poly_area(p: &[P]) -> f64 {
    let n = p.len();
    let mut s = 0.0;
    for i in 0..n {
        s += cross(p[i], p[(i + 1) % n]);
    }
    s.abs() / 2.0
}

pub fn bbox(p: &[P]) -> [f64; 4] {
    let mut b = [f64::INFINITY, f64::INFINITY, f64::NEG_INFINITY, f64::NEG_INFINITY];
    for q in p {
        b[0] = b[0].min(q[0]);
        b[1] = b[1].min(q[1]);
        b[2] = b[2].max(q[0]);
        b[3] = b[3].max(q[1]);
    }
    b
}

/// Distance from point `p` to segment `a`-`b`.
pub fn point_seg(p: P, a: P, b: P) -> f64 {
    let ab = sub(b, a);
    let l2 = dot(ab, ab);
    if l2 == 0.0 {
        return norm(sub(p, a));
    }
    let t = (dot(sub(p, a), ab) / l2).clamp(0.0, 1.0);
    norm(sub(p, [a[0] + t * ab[0], a[1] + t * ab[1]]))
}

/// Length of the collinear overlap of segments `a`-`b` and `c`-`d` (0 when they are not within
/// `tol` of one line), and the midpoint of that overlap.
pub fn seg_overlap(a: P, b: P, c: P, d: P, tol: f64) -> (f64, P) {
    let ab = sub(b, a);
    let l = norm(ab);
    if l == 0.0 {
        return (0.0, a);
    }
    let u = [ab[0] / l, ab[1] / l];
    let dc = cross(u, sub(c, a)).abs();
    let dd = cross(u, sub(d, a)).abs();
    if dc > tol || dd > tol {
        return (0.0, a);
    }
    let (tc, td) = (dot(u, sub(c, a)), dot(u, sub(d, a)));
    let lo = tc.min(td).max(0.0);
    let hi = tc.max(td).min(l);
    let m = (lo + hi) / 2.0;
    ((hi - lo).max(0.0), [a[0] + u[0] * m, a[1] + u[1] * m])
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Contact {
    None,
    /// Boundaries meet at isolated points only.
    Point,
    /// Boundaries share a stretch of positive length; its total length and one midpoint.
    Edge(f64, P),
}

/// Reference contact test between two simple polygons with disjoint interiors.
/// `tol` is the distance below which points coincide; a shared stretch must be longer than
/// `min_len` to count as an edge.
pub fn contact(p: &[P], q: &[P], tol: f64, min_len: f64) -> Contact {
    let (bp, bq) = (bbox(p), bbox(q));
    if bp[0] > bq[2] + tol || bq[0] > bp[2] + tol || bp[1] > bq[3] + tol || bq[1] > bp[3] + tol {
        return Contact::None;
    }
    let (n, m) = (p.len(), q.len());
    let mut shared = 0.0;
    let mut mid = [0.0, 0.0];
    let mut best = 0.0;
    let mut mind = f64::INFINITY;
    for i in 0..n {
        let (a, b) = (p[i], p[(i + 1) % n]);
        for j in 0..m {
            let (c, d) = (q[j], q[(j + 1) % m]);
            let (len, mp) = seg_overlap(a, b, c, d, tol);
            if len > min_len {
                shared += len;
                if len > best {
                    best = len;
                    mid = mp;
                }
            }
            let dmin = point_seg(a, c, d)
                .min(point_seg(b, c, d))
                .min(point_seg(c, a, b))
                .min(point_seg(d, a, b));
            mind = mind.min(dmin);
        }
    }
    if shared > min_len {
        Contact::Edge(shared, mid)
    } else if mind <= tol {
        Contact::Point
    } else {
        Contact::None
    }
}

/// Reference neighbour lists (touch, edge) for a set of polygons, by brute force over nearby
/// pairs found with a uniform grid.
pub fn reference_neighbours(polys: &[Vec<P>], tol: f64, min_len: f64) -> (Vec<Vec<usize>>, Vec<Vec<usize>>, Vec<Vec<(usize, P)>>) {
    let n = polys.len();
    let boxes: Vec<[f64; 4]> = polys.iter().map(|p| bbox(p)).collect();
    let mut maxd: f64 = 0.0;
    let mut all = [f64::INFINITY, f64::INFINITY, f64::NEG_INFINITY, f64::NEG_INFINITY];
    for b in &boxes {
        maxd = maxd.max(b[2] - b[0]).max(b[3] - b[1]);
        all[0] = all[0].min(b[0]);
        all[1] = all[1].min(b[1]);
        all[2] = all[2].max(b[2]);
        all[3] = all[3].max(b[3]);
    }
    let cell = maxd.max(1e-9) * 1.01;
    let cols = (((all[2] - all[0]) / cell).floor() as usize) + 1;
    let rows = (((all[3] - all[1]) / cell).floor() as usize) + 1;
    let mut grid: Vec<Vec<usize>> = vec![Vec::new(); cols * rows];
    let key = |b: &[f64; 4]| {
        let c = (((b[0] + b[2]) / 2.0 - all[0]) / cell).floor() as usize;
        let r = (((b[1] + b[3]) / 2.0 - all[1]) / cell).floor() as usize;
        (c.min(cols - 1), r.min(rows - 1))
    };
    for (i, b) in boxes.iter().enumerate() {
        let (c, r) = key(b);
        grid[r * cols + c].push(i);
    }
    let mut touch = vec![Vec::new(); n];
    let mut edge = vec![Vec::new(); n];
    let mut mids = vec![Vec::new(); n];
    for i in 0..n {
        let (c, r) = key(&boxes[i]);
        for rr in r.saturating_sub(2)..=(r + 2).min(rows - 1) {
            for cc in c.saturating_sub(2)..=(c + 2).min(cols - 1) {
                for &j in &grid[rr * cols + cc] {
                    if j == i {
                        continue;
                    }
                    match contact(&polys[i], &polys[j], tol, min_len) {
                        Contact::None => {}
                        Contact::Point => touch[i].push(j),
                        Contact::Edge(_, m) => {
                            touch[i].push(j);
                            edge[i].push(j);
                            mids[i].push((j, m));
                        }
                    }
                }
            }
        }
        touch[i].sort_unstable();
        edge[i].sort_unstable();
    }
    (touch, edge, mids)
}
