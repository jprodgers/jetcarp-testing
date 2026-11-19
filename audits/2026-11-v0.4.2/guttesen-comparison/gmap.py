#!/usr/bin/env python3
"""Matching two descriptions of the same tiling, tile for tile.

A description ("geometry") gives two lattice vectors, and for each tile of the unit cell its
centre, its number of corners and its neighbours. `find_maps(src, dst)` returns every way of
laying src on dst that sends lattice to lattice and tile centres to tile centres: one map for each
rotation or reflection the tiling allows. Each map is exact in integers:

    (x, y, s)  ->  (x*U00 + y*U10 + m_s,  x*U01 + y*U11 + n_s,  k_s)

and is accepted only if it also carries every tile's neighbours onto the neighbours the other
description lists (checked on a block of unit cells), so a map is a proven isomorphism of the two
neighbour graphs, not a fit by eye.
"""
import itertools, math


class Geom:
    def __init__(self, name, b1, b2, centres, corners, offsets):
        self.name, self.b1, self.b2 = name, b1, b2
        self.centres = centres      # centre of each tile of unit cell (0, 0)
        self.corners = corners      # number of corners of each tile
        self.offsets = offsets      # per tile: sorted list of (dx, dy, tile) neighbours
        self.n = len(centres)

    def neighbours(self, c):
        x, y, s = c
        return {(x + dx, y + dy, t) for dx, dy, t in self.offsets[s]}

    def centre(self, c):
        x, y, s = c
        return (self.centres[s][0] + x * self.b1[0] + y * self.b2[0],
                self.centres[s][1] + x * self.b1[1] + y * self.b2[1])


def geom_from_reference(lat):
    """From the reference lattice class (H. S. Guttesen's definitions)."""
    cen = [lat.centroid((0, 0, s)) for s in range(lat.nsub)]
    cor = [len(lat.xs[s]) for s in range(lat.nsub)]
    return Geom("guttesen-" + lat.name, (lat.dx0, lat.dy0), (lat.dx1, lat.dy1), cen, cor,
                [list(o) for o in lat._offsets])


def geom_from_jetcarp_dump(path, family):
    """From the dump JETCARP's engine printed (tests/g1_dump_lattice.rs)."""
    cells = {}
    for line in open(path):
        if not line.startswith("CELL " + family + " "):
            continue
        head, pts, nbs = [p.strip() for p in line.split("|")]
        _, _, i, j, k, interior, degree = head.split()
        poly = [tuple(float(v) for v in p.split(",")) for p in pts.split()]
        nb = [tuple(int(v) for v in p.split(",")) for p in nbs.split()]
        cells[(int(i), int(j), int(k))] = (interior == "1", poly, nb)
    ntypes = 1 + max(c[2] for c in cells)
    cen = lambda c: (sum(p[0] for p in cells[c][1]) / len(cells[c][1]), sum(p[1] for p in cells[c][1]) / len(cells[c][1]))
    # A unit cell well inside the patch, all of whose tiles are interior.
    base = next((i, j) for (i, j, k) in sorted(cells) if all(cells.get((i + a, j + b, t), (False,))[0]
                for a in (0, 1) for b in (0, 1) for t in range(ntypes)))
    i0, j0 = base
    o = cen((i0, j0, 0)); p1 = cen((i0 + 1, j0, 0)); p2 = cen((i0, j0 + 1, 0))
    b1 = (p1[0] - o[0], p1[1] - o[1]); b2 = (p2[0] - o[0], p2[1] - o[1])
    centres, corners, offsets = [], [], []
    for k in range(ntypes):
        c = cen((i0, j0, k))
        centres.append((c[0] - i0 * b1[0] - j0 * b2[0], c[1] - i0 * b1[1] - j0 * b2[1]))
        corners.append(len(cells[(i0, j0, k)][1]))
        offsets.append(sorted((a - i0, b - j0, t) for a, b, t in cells[(i0, j0, k)][2]))
    g = Geom("jetcarp-" + family, b1, b2, centres, corners, offsets)
    # The offsets must be the same at every interior tile (the tiling is periodic).
    for (i, j, k), (interior, _, nb) in cells.items():
        if interior:
            assert sorted((a - i, b - j, t) for a, b, t in nb) == offsets[k], (i, j, k)
    return g


def _solve(b1, b2, v):
    det = b1[0] * b2[1] - b1[1] * b2[0]
    return ((v[0] * b2[1] - v[1] * b2[0]) / det, (b1[0] * v[1] - b1[1] * v[0]) / det)


class Map:
    def __init__(self, U, per_tile, det, angle):
        self.U, self.per_tile, self.det, self.angle = U, per_tile, det, angle

    def __call__(self, c):
        x, y, s = c
        m, n, k = self.per_tile[s]
        return (x * self.U[0][0] + y * self.U[1][0] + m, x * self.U[0][1] + y * self.U[1][1] + n, k)

    def describe(self):
        return "%s by %d degrees" % ("reflection, then turn" if self.det < 0 else "turn", round(self.angle))


def find_maps(src, dst, tol=0.12, block=3):
    edge = lambda g: min(math.dist(g.centre((0, 0, s)), g.centre(c)) for s in range(g.n) for c in g.neighbours((0, 0, s)))
    scale = edge(dst) / edge(src)
    out = []
    rng = range(-2, 3)
    for U in itertools.product(rng, repeat=4):
        U = ((U[0], U[1]), (U[2], U[3]))
        det = U[0][0] * U[1][1] - U[0][1] * U[1][0]
        if abs(det) != 1:
            continue
        # The linear map A with A*src.b1 = U00*dst.b1 + U01*dst.b2 and A*src.b2 = U10*dst.b1 + U11*dst.b2.
        t1 = (U[0][0] * dst.b1[0] + U[0][1] * dst.b2[0], U[0][0] * dst.b1[1] + U[0][1] * dst.b2[1])
        t2 = (U[1][0] * dst.b1[0] + U[1][1] * dst.b2[0], U[1][0] * dst.b1[1] + U[1][1] * dst.b2[1])
        sdet = src.b1[0] * src.b2[1] - src.b1[1] * src.b2[0]
        A = (((t1[0] * src.b2[1] - t2[0] * src.b1[1]) / sdet, (-t1[0] * src.b2[0] + t2[0] * src.b1[0]) / sdet),
             ((t1[1] * src.b2[1] - t2[1] * src.b1[1]) / sdet, (-t1[1] * src.b2[0] + t2[1] * src.b1[0]) / sdet))
        # A must be a turn or a reflection times `scale`, within a few per cent.
        col1 = math.hypot(A[0][0], A[1][0]); col2 = math.hypot(A[0][1], A[1][1])
        dotp = A[0][0] * A[0][1] + A[1][0] * A[1][1]
        if abs(col1 / scale - 1) > 0.04 or abs(col2 / scale - 1) > 0.04 or abs(dotp) / (col1 * col2) > 0.04:
            continue
        adet = A[0][0] * A[1][1] - A[0][1] * A[1][0]
        angle = math.degrees(math.atan2(A[1][0], A[0][0])) % 360
        ap = lambda p: (A[0][0] * p[0] + A[0][1] * p[1], A[1][0] * p[0] + A[1][1] * p[1])
        for k0 in range(dst.n):
            if dst.corners[k0] != src.corners[0]:
                continue
            a0 = ap(src.centres[0])
            T = (dst.centres[k0][0] - a0[0], dst.centres[k0][1] - a0[1])
            per, used, ok = [], set(), True
            for s in range(src.n):
                p = ap(src.centres[s]); p = (p[0] + T[0], p[1] + T[1])
                hit = None
                for k in range(dst.n):
                    if dst.corners[k] != src.corners[s] or k in used:
                        continue
                    m, n = _solve(dst.b1, dst.b2, (p[0] - dst.centres[k][0], p[1] - dst.centres[k][1]))
                    if abs(m - round(m)) < tol and abs(n - round(n)) < tol:
                        hit = (round(m), round(n), k); break
                if hit is None:
                    ok = False; break
                used.add(hit[2]); per.append(hit)
            if not ok:
                continue
            f = Map(U, per, 1 if adet > 0 else -1, angle)
            # Proof: neighbours go to neighbours, on a block of unit cells.
            good = all({f(c) for c in src.neighbours((x, y, s))} == dst.neighbours(f((x, y, s)))
                       for x in range(-block, block + 1) for y in range(-block, block + 1) for s in range(src.n))
            if good and not any(g.U == f.U and g.per_tile == f.per_tile for g in out):
                out.append(f)
    return out


def step(geom, live, birth=(3,), survive=(2, 3)):
    count = {}
    for c in live:
        for n in geom.neighbours(c):
            count[n] = count.get(n, 0) + 1
    return {c for c, k in count.items() if (k in survive if c in live else k in birth)}


def translate_normal(cells):
    """A set of (i, j, k) moved so its smallest (j, i) lattice position is (0, 0)."""
    j0 = min(c[1] for c in cells)
    i0 = min(c[0] for c in cells if c[1] == j0)
    return tuple(sorted((c[0] - i0, c[1] - j0, c[2]) for c in cells))


def canonical(geom, syms, live, period):
    """The smallest translate-normal form over every phase and every symmetry of the tiling."""
    best, cur = None, set(live)
    for _ in range(period):
        for f in syms:
            t = translate_normal({f(c) for c in cur})
            if best is None or t < best:
                best = t
        cur = step(geom, cur)
    return best


def ship(geom, live, limit=400):
    """(period, di, dj) of the first return of `live` to a translate of itself, else None."""
    start = translate_normal(live)
    j0 = min(c[1] for c in live); i0 = min(c[0] for c in live if c[1] == j0)
    cur = set(live)
    for g in range(1, limit + 1):
        cur = step(geom, cur)
        if not cur:
            return None
        if translate_normal(cur) == start:
            j1 = min(c[1] for c in cur); i1 = min(c[0] for c in cur if c[1] == j1)
            return g, i1 - i0, j1 - j0
    return None


def preferred(maps):
    """One of the maps, the same one every time: no reflection, and the smallest turn."""
    return min(maps, key=lambda m: (m.det < 0, min(m.angle, 360 - m.angle), m.U, tuple(m.per_tile)))
