#!/usr/bin/env python3
"""Compare a JETCARP soup hunt of Conway's Life (16x16 soups at density 0.5, the hunt's defaults,
which are also Catagolue's C1 convention) with Catagolue's public census.
Usage: apg_compare.py LIB_LIST.json CATAGOLUE_TEXTCENSUS.csv
LIB_LIST.json is `jetcarp library list --json` after the hunt."""
import csv, json, math, sys
CH = "0123456789abcdefghijklmnopqrstuv"
def wechsler(cells):
    x0 = min(x for x, y in cells); y0 = min(y for x, y in cells)
    cells = {(x - x0, y - y0) for x, y in cells}
    w = max(x for x, y in cells) + 1; h = max(y for x, y in cells) + 1
    strips = []
    for s in range((h + 4) // 5):
        col = [sum(1 << (y - 5 * s) for y in range(5 * s, 5 * s + 5) if (x, y) in cells) for x in range(w)]
        while col and col[-1] == 0: col.pop()
        out = ""; i = 0
        while i < len(col):
            if col[i] == 0:
                j = i
                while j < len(col) and col[j] == 0: j += 1
                n = j - i
                while n > 0:
                    if n >= 4:
                        k = min(n, 39); out += "y" + CH[k - 4] if k - 4 < 32 else "y" + "wxyz"[k - 36]; n -= k
                    elif n == 3: out += "x"; n = 0
                    elif n == 2: out += "w"; n = 0
                    else: out += "0"; n = 0
                i = j
            else:
                out += CH[col[i]]; i += 1
        strips.append(out)
    while strips and strips[-1] == "": strips.pop()
    return "z".join(strips)
def orientations(cells):
    for sx in (1, -1):
        for sy in (1, -1):
            for swap in (False, True):
                yield {((y * sy, x * sx) if swap else (x * sx, y * sy)) for x, y in cells}
def apgcode(rec):
    best = None
    for ph in rec["phases"]:
        cells = set()
        for tok in ph.split():
            i, j, k, s = map(int, tok.split(","))
            cells.add((i, j))
        for o in orientations(cells):
            c = wechsler(o)
            if best is None or (len(c), c) < (len(best), best): best = c
    cls, p = rec["class"], rec["period"]
    pre = {"still_life": f"xs{rec['min_cells']}", "oscillator": f"xp{p}", "spaceship": f"xq{p}"}[cls]
    return f"{pre}_{best}"
assert wechsler({(0, 0), (1, 0), (0, 1), (1, 1)}) == "33"
recs = json.load(open(sys.argv[1]))
cat = {}
for r in csv.reader(open(sys.argv[2])):
    if r and r[0][:2] in ("xs", "xp", "xq"): cat[r[0]] = int(r[1])
ctot = sum(cat.values())
jt = sum(r["seen"] for r in recs)
rows = []
for r in recs:
    code = apgcode(r)
    rows.append((r["seen"], code, r.get("name") or "", cat.get(code)))
rows.sort(reverse=True)
print(f"JETCARP hunt: {jt} objects of {len(recs)} kinds. Catagolue b3s23/C1: {ctot:.4g} objects of {len(cat)} kinds.")
print(f"{'object':<22}{'apgcode':<18}{'JETCARP n':>10}{'JETCARP %':>11}{'Catagolue %':>13}{'z':>8}")
unknown = 0; chi = 0.0; dof = 0
for seen, code, name, c in rows:
    pj = seen / jt
    if c is None:
        unknown += 1; print(f"{name[:21]:<22}{code:<18}{seen:>10}{100*pj:>10.4f}%{'not found':>13}"); continue
    pc = c / ctot
    z = (seen - jt * pc) / math.sqrt(jt * pc * (1 - pc))
    if jt * pc >= 20: chi += z * z; dof += 1
    print(f"{name[:21]:<22}{code:<18}{seen:>10}{100*pj:>10.4f}%{100*pc:>12.4f}%{z:>8.2f}")
print(f"kinds not found in Catagolue's table: {unknown}; sum of z^2 over the {dof} kinds with an expected count of 20 or more: {chi:.1f}")
