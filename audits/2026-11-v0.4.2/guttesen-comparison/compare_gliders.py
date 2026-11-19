#!/usr/bin/env python3
"""Are JETCARP's published kagome and snub-square ships H. S. Guttesen's gliders, cell for cell?

His gliders are read from the animations in his repository (GlidersAndPuffers.zip). JETCARP's are
the patterns of the two scenes in its book. Both are put in JETCARP's coordinates by a map proven
to carry neighbours to neighbours, and compared in every phase under every symmetry of the tiling.

    GUTTESEN_REPO=/path/to/Games_of_life  JETCARP_REPO=/path/to/jetcarp \\
        python3 -I compare_gliders.py work/jetcarp-lattice-dump.txt [seeds-folder]

The dump is what `cargo test --release --test guttesen_dump_lattice -- --nocapture` prints (the
harness beside this folder). With a seeds folder holding gun.txt, the small glider his gun sends
out is compared as well.
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ref_lattice import Lattice, parse, find_period
import gmap, gif_decode

DUMP = sys.argv[1]
SEEDS = sys.argv[2] if len(sys.argv) > 2 else None
JETCARP = os.environ.get("JETCARP_REPO", "jetcarp")


def one(title, lattice, family, member, scene_name, extra=None):
    print("=== " + title)
    lat = Lattice(lattice)
    H = gmap.geom_from_reference(lat); J = gmap.geom_from_jetcarp_dump(DUMP, family)
    maps = gmap.find_maps(H, J); syms = gmap.find_maps(J, J)
    f = gmap.preferred(maps)
    print("maps from his lattice to JETCARP's that carry neighbours to neighbours:", len(maps),
          "| symmetries of JETCARP's tiling found the same way:", len(syms))
    print("map used:", f.describe(), "| U =", f.U, "| per tile -> (di, dj, k):", f.per_tile)
    r = gif_decode.decode(gif_decode.frames_from_repo("GlidersAndPuffers.zip", member), lattice)
    print("his animation %s: picture %s, %d frames, %d remainders tried, corners on grey %.3f, centres off grey %.3f, %d whole tiles in view"
          % (member, r["size"], r["frames"], r["remainders"], r["score"][0], r["score"][1], r["tiles"]))
    print("  frames that are not the next generation of the frame before:", r["breaks"] or "none")
    assert not r["breaks"]
    his = r["gens"][0]
    print("  his glider, frame 0: %d cells; in the reference on his lattice (period, dx, dy) = %s" % (len(his), find_period(lat, his, 200)))
    hJ = {f(c) for c in his}
    print("  in JETCARP's coordinates:", " ".join("%d,%d,%d" % c for c in sorted(hJ)))
    sp = gmap.ship(J, hJ, 200)
    print("  stepped on JETCARP's own neighbour lists: (period, di, dj) =", sp)
    scene = json.load(open(os.path.join(JETCARP, "docs", "scenes", "tilings", scene_name)))
    cells = scene["commands"][0]["pattern"]["cells"]
    jc = {tuple(int(v) for v in t.split(",")[:3]) for t in cells.split()}
    sj = gmap.ship(J, jc, 200)
    print("JETCARP's published pattern (%s): %d cells; (period, di, dj) = %s" % (scene_name, len(jc), sj))
    ca = gmap.canonical(J, syms, hJ, sp[0]); cb = gmap.canonical(J, syms, jc, sj[0])
    print("SAME OBJECT, cell for cell, over every phase and every symmetry of the tiling:", ca == cb)
    cur, hits = set(hJ), []
    for ph in range(sp[0]):
        for s in syms:
            if gmap.translate_normal({s(c) for c in cur}) == gmap.translate_normal(jc):
                hits.append("his frame %d, %s" % (ph, s.describe()))
        cur = gmap.step(J, cur)
    print("  JETCARP's pattern is:", "; or ".join(hits) if hits else "no phase of his under any symmetry")

    def pops(a, n):
        out = [len(a)]
        for _ in range(n - 1):
            a = gmap.step(J, a); out.append(len(a))
        return out
    print("  cells per generation over one period: his", pops(set(hJ), sp[0]), "| JETCARP's", pops(set(jc), sj[0]))
    if extra is not None:
        print("  the glider his gun sends out (seed received from the author) is the same object:",
              gmap.canonical(J, syms, {f(c) for c in extra}, sp[0]) == ca)
    return ca == cb


small = None
if SEEDS:
    lat = Lattice("kagome")
    cur = parse(open(os.path.join(SEEDS, "gun.txt")).read())
    for g in range(276 * 9):
        cur = lat.step(cur)
    small = {c for c in cur if -9 <= c[0] <= -6 and 0 <= c[1] <= 4}   # the newest glider, just clear of the gun
a = one("Kagome (3.6.3.6): the small glider g", "kagome", "trihex", "GlidersAndPuffers/glider_Kagome.gif", "glider-guttesen-kagome.json", small)
b = one("Snub square (3.3.4.3.4): the period-8 glider", "snubsq", "snubsq", "GlidersAndPuffers/glider_SkewSquare.gif", "glider-guttesen-snubsq.json")
print("\nRESULT kagome_same=%s snubsq_same=%s" % (a, b))
sys.exit(0 if a and b else 1)
