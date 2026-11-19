#!/usr/bin/env python3
"""Helpers for phase1.sh (v0.4.2-rc.3 on the Mac). Read-only: they parse files jetcarp wrote."""
import csv, json, re, sys
from collections import Counter

csv.field_size_limit(1 << 30)


def load(path):
    try:
        with open(path) as f:
            return json.load(f)
    except Exception:
        return None


def get(d, dotted):
    for k in dotted.split("."):
        d = d.get(k) if isinstance(d, dict) else None
    return d


def cmd_get(path, key):
    v = get(load(path), key)
    print("" if v is None else v)


def cmd_status(path):
    """One |-separated line (empty fields kept): status, stale, resumable, elapsed min, rss GB, runs/s, the status line."""
    d = load(path)
    if not isinstance(d, dict):
        print("|".join(["?"] * 6 + ["(no status)"]))
        return
    p = d.get("progress") or {}
    el = p.get("elapsed_s", d.get("elapsed_s"))
    rss = p.get("rss_gb")
    print("|".join([
        str(d.get("status", "")), str(d.get("stale", "")), str(d.get("resumable", "")),
        "" if el is None else f"{el / 60:.1f}", "" if rss is None else f"{rss:.3f}",
        "" if d.get("per_s") is None else f"{d['per_s']:.0f}", str(d.get("line", "")),
    ]))


def cmd_footprint(path):
    """MB from `footprint -f bytes --noCategories`."""
    try:
        txt = open(path).read()
    except Exception:
        txt = ""
    m = re.search(r"phys_footprint:\s+(\d+) B", txt) or re.search(r"Footprint:\s+(\d+) B", txt)
    print(f"{int(m.group(1)) / 2**20:.0f}" if m else "")


def cmd_listjob(path, kind):
    d = load(path)
    if isinstance(d, dict):
        d = d.get("jobs", d)
    for j in d or []:
        if isinstance(j, dict) and j.get("kind") == kind:
            print(j.get("job", j.get("id", "")))
            return
    print("")


def cmd_listrow(path, job):
    d = load(path)
    if isinstance(d, dict):
        d = d.get("jobs", d)
    for j in d or []:
        if isinstance(j, dict) and str(j.get("job", j.get("id"))) == str(job):
            print(f"status {j.get('status')}, stale {j.get('stale')}")
            return
    print("not listed")


KEY = ("stage", "family", "tiling", "nb", "rule", "seed", "cells", "gens", "rng", "origin", "fate", "score")


def rows(path):
    with open(path, newline="") as f:
        r = csv.DictReader(f)
        missing = [k for k in KEY if k not in (r.fieldnames or [])]
        if missing:
            raise SystemExit(f"no column(s) {missing} in {path}")
        return Counter(tuple(row[k] for k in KEY) for row in r)


def cmd_samerows(a, b):
    """Are two runs CSVs the same runs (ids aside)? Prints 'True', or 'False: ...'."""
    ca, cb = rows(a), rows(b)
    if ca == cb:
        print("True")
    else:
        only_a, only_b = ca - cb, cb - ca
        print(f"False: {sum(only_a.values())} only in the search, {sum(only_b.values())} only in the import;"
              f" e.g. {next(iter(only_a), None)} / {next(iter(only_b), None)}")


HUNT_KEYS = ("by_class", "distinct", "objects", "died", "exploded", "settled", "unsettled", "new_patterns", "groups")


def cmd_samefinds(a, b):
    """Do two hunt status JSONs have the same finds (per-group counts, classes, distinct)?"""
    da, db = load(a), load(b)
    if not (isinstance(da, dict) and isinstance(db, dict)):
        print("False: unreadable")
        return
    pa, pb = da.get("progress") or {}, db.get("progress") or {}
    differ = [k for k in HUNT_KEYS if pa.get(k) != pb.get(k)]
    if da.get("finds") != db.get("finds"):
        differ.append("finds")
    newest = "same" if pa.get("newest") == pb.get("newest") else "differs"
    print(f"{not differ}: {'differ in ' + ', '.join(differ) if differ else 'all of ' + ', '.join(HUNT_KEYS) + ' the same'}; newest list {newest}")


if __name__ == "__main__":
    globals()["cmd_" + sys.argv[1]](*sys.argv[2:])
