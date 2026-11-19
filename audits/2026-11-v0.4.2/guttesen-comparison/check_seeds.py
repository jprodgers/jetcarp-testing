#!/usr/bin/env python3
"""Runs the three Kagome configurations H. S. Guttesen sent (the large glider G, the bouncer B1 and
the glider gun) in the reference on his lattice, and writes what JETCARP's engine must show.

    GUTTESEN_REPO=/path/to/Games_of_life python3 -I check_seeds.py work/jetcarp-lattice-dump.txt seeds work

`seeds` holds G.txt, B1.txt and gun.txt: his cell strings ("x y T" triples), which came by email
and are not in this repository. For each, `work/expected-<name>.txt` gets every generation's live
cells in JETCARP's coordinates, and a line says how to run the engine test on it.
"""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ref_lattice import Lattice, parse, find_period
import gmap

DUMP, SEEDS, WORK = sys.argv[1], sys.argv[2], sys.argv[3]
lat = Lattice("kagome")
H = gmap.geom_from_reference(lat); J = gmap.geom_from_jetcarp_dump(DUMP, "trihex")
f = gmap.preferred(gmap.find_maps(H, J))
load = lambda n: parse(open(os.path.join(SEEDS, n + ".txt")).read())


def run(live, gens):
    hist = [set(live)]
    for _ in range(gens):
        hist.append(lat.step(hist[-1]))
    return hist


def expected(name, hist):
    mapped = [{f(c) for c in s} for s in hist]
    xs = [2 * i + j for s in mapped for (i, j, k) in s]; js = [j for s in mapped for (i, j, k) in s]
    h = (max(js) - min(js) + 1) + 40
    w = math.ceil((max(xs) - min(xs)) / 2) + 40
    dj = h // 2 - (max(js) + min(js)) // 2
    di = (w - ((max(xs) + min(xs)) // 2 + dj)) // 2
    out = os.path.join(WORK, "expected-%s.txt" % name)
    with open(out, "w") as fh:
        for g, s in enumerate(mapped):
            fh.write(str(g) + " " + " ".join("%d,%d,%d" % (i + di, j + dj, k) for (i, j, k) in sorted(s)) + "\n")
    print("  engine test: GUTT_FAMILY=trihex GUTT_W=%d GUTT_H=%d GUTT_FILE=%s cargo test --release --test guttesen_run_expected -- --nocapture" % (w, h, out))


print("--- G, the large glider")
G = load("G"); p = find_period(lat, G, 400)
hist = run(G, 400)
pops = [len(s) for s in hist[:p[0]]]
print("  %d cells; first return to a translate of itself: %d generations, moved by (%d, %d) in his coordinates" % (len(G), p[0], p[1], p[2]))
print("  cells over one period: %d to %d" % (min(pops), max(pops)))
print("  holds for 10 periods:", all(hist[k * p[0]] == lat.shifted(G, k * p[1], k * p[2]) for k in range(1, 11)))
expected("G", hist)

print("--- B1, the bouncer")
B = load("B1"); hist = run(B, 464)
first = next(g for g in range(1, 465) if hist[g] == hist[0])
print("  %d cells; first exact repeat of the start: generation %d; repeats at every multiple up to 464: %s"
      % (len(B), first, all(hist[k * first] == hist[0] for k in range(1, 464 // first + 1))))
expected("B1", hist)

print("--- the glider gun")
gun = load("gun"); hist = run(gun, 276 * 9)
for g in range(0, 276 * 9 + 1, 276):
    s = hist[g]
    print("  generation %4d: %3d cells, his y from %5d to %5d" % (g, len(s), min(c[1] for c in s), max(c[1] for c in s)))
core = lambda s: frozenset(c for c in s if abs(c[1]) <= 60)
print("  the gun itself (his y from -60 to 60) repeats every 276 generations from generation 276 on:",
      all(core(hist[g]) == core(hist[g + 276]) for g in range(276, 276 * 8 + 1)))
newest = {c for c in hist[-1] if -9 <= c[0] <= -6 and 0 <= c[1] <= 4}
print("  newest glider at generation %d: %d cells; alone, (period, dx, dy) = %s" % (276 * 9, len(newest), find_period(lat, newest, 50)))
stream = lambda s: len([c for c in s if -9 <= c[0] <= -6 and c[2] == 0 and c[1] > 0]) // 2   # two hexagons each at this phase
print("  gliders in the outgoing stream at generations 0, 276, ..., %d: %s" % (276 * 9, [stream(hist[g]) for g in range(0, 276 * 9 + 1, 276)]))
expected("gun", hist[:1105])
