#!/usr/bin/env python3
"""Reference Life on H. S. Guttesen's lattices, written from the definitions in his repository
(henrisro313/Games_of_life: AbstractLattice.java, Kagome.java, SkewSquare.java) and sharing no
code with it or with JETCARP.

A cell is (x, y, sub): the unit cell (x, y) and the tile within it. A tile's outline is a list of
integer points, moved by x*(dx0, dy0) + y*(dx1, dy1). Two tiles are neighbours when they share an
outline point (an edge or a corner). The rule is B3/S23 on the unbounded plane.
"""
import os, re, sys

# The lattice definitions are read from his repository, which the reader clones; nothing from it is
# copied here. GUTTESEN_REPO names the folder (default: ./Games_of_life).
JAVA = {"kagome": "Kagome.java", "snubsq": "SkewSquare.java"}


def read_java(name):
    """(dx0, dy0, dx1, dy1, xs, ys) from the `super(...)` call of the lattice's constructor."""
    repo = os.environ.get("GUTTESEN_REPO", "Games_of_life")
    src = open(os.path.join(repo, JAVA[name])).read()
    call = src[src.index("super(") + 6:]
    head, rest = call.split("new int[][]", 1)
    dx0, dy0, dx1, dy1 = [int(v) for v in re.findall(r"-?\d+", head)]
    first, second = rest.split("new int[][]", 1)
    rows = lambda t: [[int(v) for v in re.findall(r"-?\d+", r)] for r in re.findall(r"\{([-\d,\s]+)\}", t)]
    xs, ys = rows(first), rows(second[:second.index(");")])
    assert xs and len(xs) == len(ys) and all(len(a) == len(b) for a, b in zip(xs, ys))
    return dx0, dy0, dx1, dy1, xs, ys


class Lattice:
    def __init__(self, name):
        self.name = name
        self.dx0, self.dy0, self.dx1, self.dy1, self.xs, self.ys = read_java(name)
        self.nsub = len(self.xs)
        # Which (dx, dy, sub) tiles touch tile `sub` of unit cell (0, 0): found once, by
        # comparing outlines over a block of unit cells, then reused by translation.
        self._offsets = self._find_offsets()

    def outline(self, cell):
        x, y, s = cell
        ox = x * self.dx0 + y * self.dx1
        oy = x * self.dy0 + y * self.dy1
        return [(px + ox, py + oy) for px, py in zip(self.xs[s], self.ys[s])]

    def centroid(self, cell):
        o = self.outline(cell)
        return (sum(p[0] for p in o) / len(o), sum(p[1] for p in o) / len(o))

    def _find_offsets(self):
        r = 3
        at = {}
        for x in range(-r, r + 1):
            for y in range(-r, r + 1):
                for s in range(self.nsub):
                    for p in self.outline((x, y, s)):
                        at.setdefault(p, set()).add((x, y, s))
        offs = []
        for s in range(self.nsub):
            nb = set()
            for p in self.outline((0, 0, s)):
                nb |= at[p]
            nb.discard((0, 0, s))
            offs.append(sorted(nb))
        return offs

    def neighbours(self, cell):
        x, y, s = cell
        return [(x + dx, y + dy, t) for dx, dy, t in self._offsets[s]]

    def degree(self, sub):
        return len(self._offsets[sub])

    def step(self, live):
        count = {}
        for c in live:
            for n in self.neighbours(c):
                count[n] = count.get(n, 0) + 1
        return {c for c, k in count.items() if k == 3 or (k == 2 and c in live)}

    def shifted(self, live, dx, dy):
        return {(x + dx, y + dy, s) for x, y, s in live}


def parse(text, letters="ABCDEF"):
    t = text.split()
    assert len(t) % 3 == 0, "cells come in triples"
    return {(int(t[i]), int(t[i + 1]), letters.index(t[i + 2])) for i in range(0, len(t), 3)}


def normal(live):
    """The cells moved so that the smallest (x, y) is (0, 0), and by how much they were moved."""
    mx = min(c[0] for c in live)
    my = min(c[1] for c in live if c[0] == mx)
    return frozenset((x - mx, y - my, s) for x, y, s in live), (mx, my)


def find_period(lat, live, limit):
    """First generation p <= limit at which the pattern is a translate of the start: (p, dx, dy)."""
    start, at0 = normal(live)
    cur = set(live)
    for g in range(1, limit + 1):
        cur = lat.step(cur)
        if not cur:
            return None
        n, at = normal(cur)
        if n == start:
            return g, at[0] - at0[0], at[1] - at0[1]
    return None


if __name__ == "__main__":
    lat = Lattice(sys.argv[1])
    print(lat.name, "tiles per unit cell:", lat.nsub, "neighbour counts:", [lat.degree(s) for s in range(lat.nsub)])
