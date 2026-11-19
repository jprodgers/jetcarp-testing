"""A-6 (the Acer) 4.2: writes (and reads) outside the output and library folders are refused unless --allow'ed.

The Mac's / Framework's t42_folders.py on Windows. Session A: no --allow. Session B: --allow $W\\allowed.
Every path argument that writes or reads a file is tried with an absolute path outside, a ..\\ escape, a link
inside the output folder that points outside (a directory junction: this Windows has no Developer Mode, so a
symbolic link needs administrator rights), %TEMP%, and Windows spellings: forward slashes, the \\\\?\\ prefix,
the 8.3 short name, a drive-relative path (C:name), and the output folder spelled in capitals (inside: should
work). Afterwards every outside folder is listed for files newer than the start.
"""
import ctypes
import json
import os
import shutil
import subprocess
import time

import mcpc

W = mcpc.W
OUT = os.path.join(W, "out")
OUTSIDE = os.path.join(W, "outside")
ALLOWED = os.path.join(W, "allowed")
TMPD = os.path.join(os.environ["TEMP"], "f9-jetcarp-outside")
CWD = os.path.join(W, "cwd")
for d in (OUTSIDE, ALLOWED, CWD):
    os.makedirs(d, exist_ok=True)
link = os.path.join(OUT, "link-outside")
if not os.path.exists(link):
    subprocess.run(["cmd", "/c", "mklink", "/J", link, OUTSIDE], capture_output=True)
START = time.time() - 2

buf = ctypes.create_unicode_buffer(1024)
ctypes.windll.kernel32.GetShortPathNameW(OUTSIDE, buf, 1024)
SHORT = buf.value

log = open(os.path.join(mcpc.R, "4.2-folders.txt"), "w", encoding="utf-8")
log.write(f"$W = {W}\nlink-outside: {'junction' if os.path.isdir(link) else 'NOT MADE'}; 8.3 name of outside: {SHORT.replace(W, '$W') if SHORT else '(none)'}\n")


def rec(m, label, name, args, n=500):
    err, txt, raw = m.call(name, args, timeout=120)
    s = f"== [{label}] {name} {json.dumps(args)[:300]}\n   isError={err}\n   " + txt[:n].replace("\n", "\n   ")
    s = s.replace(W, "$W").replace(W.replace("\\", "\\\\"), "$W").replace(W.replace("\\", "/"), "$W")
    print(s)
    log.write(s + "\n")
    log.flush()
    return err, txt


def rh(p):
    """A path as a Rhai string body (a backslash is an escape there)."""
    return p.replace("\\", "\\\\")


def world(m):
    m.call("world_new", {"tiling": "square", "width": 32, "height": 32, "cas": ["Life"]})


SCRIPT_WRITE = 'let w = world(#{ tiling: "square", size: [32, 32] }); w.add_ca("Life", #{ seed: "random:0.3" }); w.step(5); w.save_png("PATH", #{ size: [64, 64] }); print("wrote");'
SCRIPT_OUTDIR = 'out_dir("PATH"); let w = world(#{ tiling: "square", size: [32, 32] }); w.add_ca("Life", #{ seed: "random:0.3" }); w.save_scene("s.json"); print("wrote");'
SCRIPT_TEXT = 'write_text("PATH", "hello"); print("wrote");'
SCRIPT_READ = 'let w = load_scene("PATH"); print(`read ${w.population()}`);'


def sep(d):
    return "/" if ("/" in d and "\\" not in d) else "\\"


def suite(m, label, targets):
    """targets: list of (tag, dir) to write into."""
    world(m)
    for tag, d in targets:
        s = sep(d)
        j = lambda name: d + s + name
        rec(m, f"{label} {tag}", "world_status", {"save_path": j("scene.json")})
        rec(m, f"{label} {tag}", "world_render", {"max_side": 64, "save_path": j("pic.png")})
        rec(m, f"{label} {tag}", "world_render", {"wallpaper": {"size": "320x200", "out": j("wall.png")}})
        rec(m, f"{label} {tag}", "run_script", {"script": SCRIPT_WRITE.replace("PATH", rh(j("script.png"))), "max_seconds": 20})
        rec(m, f"{label} {tag}", "run_script", {"script": SCRIPT_TEXT.replace("PATH", rh(j("text.txt"))), "max_seconds": 20})
        rec(m, f"{label} {tag}", "run_script", {"script": SCRIPT_OUTDIR.replace("PATH", rh(j("scriptdir"))), "max_seconds": 20})
        rec(m, f"{label} {tag}", "search_runs", {"job": 3, "csv": j("runs.csv"), "limit": 5})
        rec(m, f"{label} {tag}", "search_runs", {"job": 3, "sheet": {"ids": [1, 2], "png": j("sheet.png"), "px": 64}})
        rec(m, f"{label} {tag}", "search_runs", {"job": 3, "scene": {"run": 1, "save": j("run.json")}})
        rec(m, f"{label} {tag}", "search_runs", {"try": {"tiling": "square", "rule": "B3/S23", "cells": 2000, "gens": 50, "png": j("try.png")}})
        rec(m, f"{label} {tag}", "search_runs", {"refit": {"jobs": [3], "out": j("model.json")}})
        rec(m, f"{label} {tag}", "media_render", {"scene": {"format": 1, "tiling": {"family": "square", "size": {"rect": {"w": 32, "h": 32}}}, "cas": [{"rule": "B3/S23", "seed": {"random": {"density": 0.3}}}]}, "gens": 5, "out": j("media")})
        rec(m, f"{label} {tag}", "pack", {"publish": {"feed": "f9-folders", "to": j("store"), "no_media": True, "no_searches": True}})
        rec(m, f"{label} {tag}", "pack", {"export": {"to": j("export"), "publish": {"feed": "f9-folders", "no_media": True, "no_searches": True}}})
        rec(m, f"{label} {tag}", "pack", {"site": {"to": j("site"), "render": False}})
        rec(m, f"{label} {tag}", "search_start", {"pile": {"tiling": "square", "grains": 1000, "out": j("piles")}, "wait_s": 30})
        rec(m, f"{label} {tag}", "files_list", {"path": d})


def reads(m, label, d):
    rec(m, f"{label} read", "world_new", {"path": os.path.join(d, "good.json")})
    rec(m, f"{label} read", "run_script", {"script": SCRIPT_READ.replace("PATH", rh(os.path.join(d, "good.json"))), "max_seconds": 10})
    rec(m, f"{label} read", "run_script", {"script": f'let t = read_text("{rh(os.path.join(d, "rules.txt"))}"); print(t);', "max_seconds": 10})
    rec(m, f"{label} read", "files_list", {"file": os.path.join(d, "good.json")})
    rec(m, f"{label} read", "pack", {"info": {"path": os.path.join(d, "..", "packs", "good")}})
    rec(m, f"{label} read", "pack", {"check": {"path": os.path.join(d, "..", "packs", "good")}})
    rec(m, f"{label} read", "library_curate", {"quickstart": {"scene": os.path.join(d, "good.json"), "title": "outside"}})
    rec(m, f"{label} read", "search_start", {"search": {"rules_file": os.path.join(d, "rules.txt"), "soups": 2}, "wait_s": 20})


with open(os.path.join(OUTSIDE, "rules.txt"), "w") as f:
    f.write("B36/S23\n")
shutil.copy(os.path.join(W, "odd", "good.json"), os.path.join(OUTSIDE, "good.json"))

# Session A: no --allow
a = mcpc.Mcp(os.path.join(mcpc.R, "4.2-folders-a.jsonl"), maxlog=1500, cwd=CWD)
a.init()
log.write("#### Session A: jetcarp mcp (no --allow); the server's working folder is $W\\cwd\n")
targets = [
    ("abs-outside", OUTSIDE),
    ("dotdot", "..\\outside"),
    ("dotdot-fwd", "../outside"),
    ("junction", "link-outside"),
    ("tmp", TMPD),
    ("allowed-without-flag", ALLOWED),
    ("fwd-slashes", OUTSIDE.replace("\\", "/")),
    ("long-prefix", "\\\\?\\" + OUTSIDE),
    ("drive-relative", OUTSIDE[:2] + "f9-drive-relative"),
]
if SHORT and SHORT.lower() != OUTSIDE.lower():
    targets.append(("short-8.3", SHORT))
suite(a, "A", targets)
reads(a, "A", OUTSIDE)
rec(a, "A sys", "files_list", {"file": "C:\\Windows\\System32\\drivers\\etc\\hosts"})
rec(a, "A sys", "files_list", {"path": "C:\\Windows"})
rec(a, "A sys", "world_new", {"path": "C:\\Windows\\win.ini"})
rec(a, "A inside", "world_status", {"save_path": "f9-inside\\scene.json"})
rec(a, "A inside", "world_status", {"save_path": os.path.join(OUT.upper(), "f9-inside-caps", "scene.json")})
rec(a, "A inside", "world_status", {"save_path": OUT.replace("\\", "/") + "/f9-inside-fwd/scene.json"})
a.close()

# Session B: --allow $W\allowed
b = mcpc.Mcp(os.path.join(mcpc.R, "4.2-folders-b.jsonl"), args=["--allow", ALLOWED], maxlog=1500, cwd=CWD)
b.init()
log.write("#### Session B: jetcarp mcp --allow $W\\allowed\n")
suite(b, "B", [("allowed", ALLOWED), ("allowed-caps", ALLOWED.upper()), ("still-outside", OUTSIDE)])
shutil.copy(os.path.join(W, "odd", "good.json"), os.path.join(ALLOWED, "good.json"))
reads(b, "B allowed", ALLOWED)
b.close()


def newer(top):
    found = []
    for root, dirs, files in os.walk(top):
        for fn in files + dirs:
            p = os.path.join(root, fn)
            try:
                if os.path.getmtime(p) >= START:
                    found.append(p)
            except OSError:
                pass
    return found


for top in (OUTSIDE, TMPD, CWD, os.path.join(OUTSIDE[:3], "f9-drive-relative")):
    got = newer(top) if os.path.exists(top) else ["(folder does not exist)"]
    log.write(f"#### written in {top.replace(W, '$W')} since the start: {len(got)}\n")
    for p in got:
        log.write(f"   {p.replace(W, '$W')}\n")
log.write("#### the allowed folder:\n")
for root, dirs, files in os.walk(ALLOWED):
    if root.count(os.sep) - ALLOWED.count(os.sep) < 2:
        for fn in dirs + files:
            log.write(f"   {os.path.join(root, fn).replace(W, '$W')}\n")
log.close()
