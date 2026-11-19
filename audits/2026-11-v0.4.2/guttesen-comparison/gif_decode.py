#!/usr/bin/env python3
"""Reads the live cells out of an animation written by Guttesen's GenericLife.createAnimatedGif.

His program draws one pixel per lattice unit: each tile's outline at its lattice coordinates less
the corner of a bounding box, filled teal when live and white when dead, with grey outlines. The
box's corner is not recorded, but it only matters up to a lattice translation, so each possible
remainder is tried and the one whose outlines land on the grey pixels is kept. The read is then
checked against the rule: each frame must be the next generation of the one before.
"""
import io, os, sys, zipfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from PIL import Image, ImageSequence
from ref_lattice import Lattice

GRID, DEAD, LIVE = (128, 128, 128), (255, 255, 255), (0, 176, 146)


def frames_from_repo(archive, member):
    """Frames of one animation inside one of the archives of his repository."""
    repo = os.environ.get("GUTTESEN_REPO", "Games_of_life")
    data = zipfile.ZipFile(os.path.join(repo, archive)).read(member)
    return [f.convert("RGB").copy() for f in ImageSequence.Iterator(Image.open(io.BytesIO(data)))]


def cells_in_view(lat, w, h, off):
    """Tiles whose whole outline lies in the picture: (cell, outline in pixels, centre pixel)."""
    det = lat.dx0 * lat.dy1 - lat.dy0 * lat.dx1
    corners = [(px + off[0], py + off[1]) for px in (0, w) for py in (0, h)]
    sol = [((px * lat.dy1 - py * lat.dx1) / det, (lat.dx0 * py - lat.dy0 * px) / det) for px, py in corners]
    x0, x1 = int(min(s[0] for s in sol)) - 3, int(max(s[0] for s in sol)) + 3
    y0, y1 = int(min(s[1] for s in sol)) - 3, int(max(s[1] for s in sol)) + 3
    out = []
    for x in range(x0, x1 + 1):
        for y in range(y0, y1 + 1):
            for s in range(lat.nsub):
                o = [(px - off[0], py - off[1]) for px, py in lat.outline((x, y, s))]
                if all(0 <= px < w and 0 <= py < h for px, py in o):
                    cx = sum(p[0] for p in o) / len(o); cy = sum(p[1] for p in o) / len(o)
                    out.append(((x, y, s), o, (int(round(cx)), int(round(cy)))))
    return out


def decode(frames, lattice):
    lat = Lattice(lattice)
    w, h = frames[0].size
    px0 = frames[0].load()
    det = lat.dx0 * lat.dy1 - lat.dy0 * lat.dx1
    n = abs(det)                      # the number of different remainders
    best, seen = None, set()
    for bx in range(n):
        for by in range(n):
            key = ((bx * lat.dy1 - by * lat.dx1) % n, (lat.dx0 * by - lat.dy0 * bx) % n)
            if key in seen:
                continue
            seen.add(key)
            cells = cells_in_view(lat, w, h, (bx, by))
            on_grid = sum(1 for _, o, _ in cells for p in o if px0[p[0], p[1]] == GRID)
            total = sum(len(o) for _, o, _ in cells)
            off_grid = sum(1 for _, _, c in cells if px0[c[0], c[1]] != GRID)
            score = (on_grid / total, off_grid / len(cells))
            if best is None or score > best[0]:
                best = (score, (bx, by))
    score, off = best
    cells = cells_in_view(lat, w, h, off)
    gens = []
    for f in frames:
        px = f.load()
        live = set()
        for c, _, ctr in cells:
            v = px[ctr[0], ctr[1]]
            if v == LIVE:
                live.add(c)
            elif v != DEAD:
                raise SystemExit(f"unexpected colour {v} at the centre of {c}")
        gens.append(live)
    bad = [g for g in range(len(gens) - 1) if lat.step(gens[g]) != gens[g + 1]]
    return dict(lat=lat, size=(w, h), frames=len(frames), corner=off, remainders=len(seen), score=score,
                tiles=len(cells), gens=gens, breaks=bad)
