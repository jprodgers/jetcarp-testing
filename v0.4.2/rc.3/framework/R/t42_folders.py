"""F9 4.2: writes (and reads) outside the output and library folders are refused unless --allow'ed.

Session A: no --allow. Session B: --allow <f9>/allowed. Every path argument that writes or reads a
file is tried with an absolute path outside, a ../ escape, and a symlink inside the output folder
that points outside. Afterwards the outside folder is listed: it must hold only what B was allowed
to write.
"""
import json
import os
import subprocess

import mcpc

W = mcpc.W
OUT = f"{W}/out"
OUTSIDE = f"{W}/outside"
ALLOWED = f"{W}/allowed"
os.makedirs(OUTSIDE, exist_ok=True)
os.makedirs(ALLOWED, exist_ok=True)
link = f"{OUT}/link-outside"
if not os.path.islink(link):
    os.symlink(OUTSIDE, link)

log = open(f"{mcpc.R}/4.2-folders.txt", "w", encoding="utf-8")


def rec(m, label, name, args, n=500):
    err, txt, raw = m.call(name, args, timeout=120)
    s = f"== [{label}] {name} {json.dumps(args)[:260]}\n   isError={err}\n   " + txt[:n].replace("\n", "\n   ")
    print(s)
    log.write(s + "\n")
    log.flush()
    return err, txt


def world(m):
    m.call("world_new", {"tiling": "square", "width": 32, "height": 32, "cas": ["Life"]})


SCRIPT_WRITE = 'let w = world(#{ tiling: "square", size: [32, 32] }); w.add_ca("Life", #{ seed: "random:0.3" }); w.step(5); w.save_png("PATH", #{ size: [64, 64] }); print("wrote");'
SCRIPT_OUTDIR = 'out_dir("PATH"); let w = world(#{ tiling: "square", size: [32, 32] }); w.add_ca("Life", #{ seed: "random:0.3" }); w.save_scene("s.json"); print("wrote");'
SCRIPT_TEXT = 'write_text("PATH", "hello"); print("wrote");'
SCRIPT_READ = 'let w = load_scene("PATH"); print(`read ${w.population()}`);'


def suite(m, label, targets):
    """targets: list of (tag, dir) to write into."""
    world(m)
    for tag, d in targets:
        rec(m, f"{label} {tag}", "world_status", {"save_path": f"{d}/scene.json"})
        rec(m, f"{label} {tag}", "world_render", {"max_side": 64, "save_path": f"{d}/pic.png"})
        rec(m, f"{label} {tag}", "world_render", {"wallpaper": {"size": "320x200", "out": f"{d}/wall.png"}})
        rec(m, f"{label} {tag}", "run_script", {"script": SCRIPT_WRITE.replace("PATH", f"{d}/script.png"), "max_seconds": 20})
        rec(m, f"{label} {tag}", "run_script", {"script": SCRIPT_TEXT.replace("PATH", f"{d}/text.txt"), "max_seconds": 20})
        rec(m, f"{label} {tag}", "run_script", {"script": SCRIPT_OUTDIR.replace("PATH", f"{d}/scriptdir"), "max_seconds": 20})
        rec(m, f"{label} {tag}", "search_runs", {"job": 3, "csv": f"{d}/runs.csv", "limit": 5})
        rec(m, f"{label} {tag}", "search_runs", {"job": 3, "sheet": {"ids": [1, 2], "png": f"{d}/sheet.png", "px": 64}})
        rec(m, f"{label} {tag}", "search_runs", {"job": 3, "scene": {"run": 1, "save": f"{d}/run.json"}})
        rec(m, f"{label} {tag}", "search_runs", {"try": {"tiling": "square", "rule": "B3/S23", "cells": 2000, "gens": 50, "png": f"{d}/try.png"}})
        rec(m, f"{label} {tag}", "search_runs", {"refit": {"jobs": [3], "out": f"{d}/model.json"}})
        rec(m, f"{label} {tag}", "media_render", {"scene": {"format": 1, "tiling": {"family": "square", "size": {"rect": {"w": 32, "h": 32}}}, "cas": [{"rule": "B3/S23", "seed": {"random": {"density": 0.3}}}]}, "gens": 5, "out": f"{d}/media"})
        rec(m, f"{label} {tag}", "pack", {"publish": {"feed": "f9-folders", "to": f"{d}/store", "no_media": True, "no_searches": True}})
        rec(m, f"{label} {tag}", "pack", {"export": {"to": f"{d}/export", "publish": {"feed": "f9-folders", "no_media": True, "no_searches": True}}})
        rec(m, f"{label} {tag}", "pack", {"site": {"to": f"{d}/site", "render": False}})
        rec(m, f"{label} {tag}", "search_start", {"pile": {"tiling": "square", "grains": 1000, "out": f"{d}/piles"}, "wait_s": 30})
        rec(m, f"{label} {tag}", "files_list", {"path": d})


def reads(m, label, d):
    rec(m, f"{label} read", "world_new", {"path": f"{d}/good.json"})
    rec(m, f"{label} read", "run_script", {"script": SCRIPT_READ.replace("PATH", f"{d}/good.json"), "max_seconds": 10})
    rec(m, f"{label} read", "run_script", {"script": f'let t = read_text("{d}/rules.txt"); print(t);', "max_seconds": 10})
    rec(m, f"{label} read", "files_list", {"file": f"{d}/good.json"})
    rec(m, f"{label} read", "pack", {"info": {"path": f"{d}/../packs/good"}})
    rec(m, f"{label} read", "pack", {"check": {"path": f"{d}/../packs/good"}})
    rec(m, f"{label} read", "library_curate", {"quickstart": {"scene": f"{d}/good.json", "title": "outside"}})
    rec(m, f"{label} read", "search_start", {"search": {"rules_file": f"{d}/rules.txt", "soups": 2}, "wait_s": 20})


with open(f"{OUTSIDE}/rules.txt", "w") as f:
    f.write("B36/S23\n")
subprocess.run(["cp", f"{W}/odd/good.json", f"{OUTSIDE}/good.json"])

# Session A: no --allow
a = mcpc.Mcp(f"{mcpc.R}/4.2-folders-a.jsonl", maxlog=1500)
a.init()
log.write("#### Session A: jetcarp mcp (no --allow)\n")
suite(a, "A", [("abs-outside", OUTSIDE), ("dotdot", "../outside"), ("symlink", "link-outside"), ("tmp", "/tmp/f9-jetcarp-outside"), ("allowed-without-flag", ALLOWED)])
reads(a, "A", OUTSIDE)
rec(a, "A sys", "files_list", {"file": "/etc/passwd"})
rec(a, "A sys", "files_list", {"path": "/etc"})
rec(a, "A sys", "world_new", {"path": "/etc/hostname"})
rec(a, "A inside", "world_status", {"save_path": "f9-inside/scene.json"})
a.close()

# Session B: --allow <f9>/allowed
b = mcpc.Mcp(f"{mcpc.R}/4.2-folders-b.jsonl", args=["--allow", ALLOWED], maxlog=1500)
b.init()
log.write(f"#### Session B: jetcarp mcp --allow {ALLOWED}\n")
suite(b, "B", [("allowed", ALLOWED), ("still-outside", OUTSIDE)])
subprocess.run(["cp", f"{W}/odd/good.json", f"{ALLOWED}/good.json"])
reads(b, "B allowed", ALLOWED)
b.close()

ls = subprocess.run(["find", OUTSIDE, "/tmp/f9-jetcarp-outside", "-newer", f"{mcpc.R}/t42_folders.py"], capture_output=True, text=True)
log.write(f"#### files written outside (find {OUTSIDE} /tmp/f9-jetcarp-outside -newer t42_folders.py):\n{ls.stdout}{ls.stderr}\n")
ls = subprocess.run(["find", ALLOWED, "-maxdepth", "2"], capture_output=True, text=True)
log.write(f"#### the allowed folder:\n{ls.stdout}\n")
log.close()
