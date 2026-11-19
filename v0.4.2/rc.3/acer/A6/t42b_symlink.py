"""A-6 (the Acer) 4.2b: links inside the output folder (the Mac's / Framework's t42b_symlink.py on Windows).

(1) Reading through a linked folder (a directory junction, which needs no rights).
(2) A file symbolic link inside the output folder whose target is outside: does a save overwrite the target?
    Making one needs administrator rights or Developer Mode on Windows; if it can't be made, that is recorded.
(3) For information: a hard link inside the output folder to a file outside. The rc.4 fix leaves hard links out
    (a hard link is the file itself), so this is not a pass/fail case.
"""
import json
import os

import mcpc

W = mcpc.W
OUT = os.path.join(W, "out")
outside = os.path.join(W, "outside")
os.makedirs(outside, exist_ok=True)
out = open(os.path.join(mcpc.R, "4.2b-symlink.txt"), "w", encoding="utf-8")


def say(s):
    s = s.replace(W, "$W").replace(W.replace("\\", "\\\\"), "$W")
    print(s)
    out.write(s + "\n")
    out.flush()


victim = os.path.join(outside, "victim.txt")
open(victim, "w").write("precious text outside the output folder\n")
ln = os.path.join(OUT, "innocent.json")
if os.path.lexists(ln):
    os.remove(ln)
try:
    os.symlink(victim, ln)
    sym = True
    say(f"file symlink made: {ln} -> {victim}")
except OSError as e:
    sym = False
    say(f"file symlink NOT made ({e.__class__.__name__}: {e}); case (2) skipped")

victim2 = os.path.join(outside, "victim-hard.txt")
open(victim2, "w").write("precious text outside, reached by a hard link\n")
hl = os.path.join(OUT, "innocent-hard.json")
if os.path.lexists(hl):
    os.remove(hl)
os.link(victim2, hl)
say(f"hard link made: {hl} = {victim2}")

m = mcpc.Mcp(os.path.join(mcpc.R, "4.2b-symlink.jsonl"), maxlog=1500)
m.init()
cases = [("world_new", {"path": "link-outside/good.json"}), ("world_new", {"path": "link-outside\\good.json"})]
if sym:
    cases += [("files_list", {"file": "innocent.json"}), ("world_new", {"tiling": "square", "width": 16, "height": 16, "cas": ["Life"]}),
              ("world_status", {"save_path": "innocent.json"})]
cases += [("world_new", {"tiling": "square", "width": 16, "height": 16, "cas": ["Life"]}),
          ("files_list", {"file": "innocent-hard.json"}), ("world_status", {"save_path": "innocent-hard.json"})]
for name, args in cases:
    err, txt, _ = m.call(name, args)
    say(f"== {name} {json.dumps(args)} -> isError={err}\n   {txt[:300]}")
m.close()

# (4) A directory symbolic link (not a junction) inside the output folder, pointing outside: the write suite's main
# tools, and a read. (Only when symbolic links can be made: Developer Mode, turned on by Jimmie for run 2.)
if sym:
    import time as _t
    start = _t.time() - 2
    dl = os.path.join(OUT, "link-sym")
    if os.path.lexists(dl):
        os.rmdir(dl)
    os.symlink(outside, dl, target_is_directory=True)
    say(f"directory symlink made: {dl} -> {outside}")
    m = mcpc.Mcp(os.path.join(mcpc.R, "4.2b-symlink-dir.jsonl"), maxlog=1500)
    m.init()
    m.call("world_new", {"tiling": "square", "width": 16, "height": 16, "cas": ["Life"]})
    script_png = 'let w = world(#{ tiling: "square", size: [16, 16] }); w.add_ca("Life", #{ seed: "random:0.3" }); w.save_png("link-sym/s.png", #{ size: [32, 32] }); print("wrote");'
    for name, args in [
        ("world_new", {"path": "link-sym/good.json"}),
        ("world_new", {"tiling": "square", "width": 16, "height": 16, "cas": ["Life"]}),
        ("world_status", {"save_path": "link-sym/scene.json"}),
        ("world_render", {"max_side": 64, "save_path": "link-sym\\pic.png"}),
        ("world_render", {"wallpaper": {"size": "320x200", "out": "link-sym/wall.png"}}),
        ("run_script", {"script": script_png, "max_seconds": 20}),
        ("run_script", {"script": 'write_text("link-sym/t.txt", "x"); print("wrote");', "max_seconds": 20}),
        ("search_runs", {"job": 3, "csv": "link-sym/runs.csv", "limit": 5}),
        ("media_render", {"quickstart": "life", "gens": 5, "out": "link-sym/media"}),
        ("pack", {"export": {"to": "link-sym/export", "publish": {"feed": "f9-sym", "no_media": True, "no_searches": True}}}),
        ("search_start", {"pile": {"tiling": "square", "grains": 500, "out": "link-sym/piles"}, "wait_s": 30}),
        ("files_list", {"path": "link-sym"}),
    ]:
        err, txt, _ = m.call(name, args)
        say(f"== [dir symlink] {name} {json.dumps(args)[:200]} -> isError={err}\n   {txt[:300]}")
    m.close()
    new = []
    for root, dirs, files in os.walk(outside):
        for fn in dirs + files:
            p = os.path.join(root, fn)
            if os.path.getmtime(p) >= start and fn not in ("victim.txt", "victim-hard.txt"):
                new.append(p)
    say(f"#### written in $W\\outside through the directory symlink: {len(new)}" + "".join(f"\n   {p}" for p in new))
if sym:
    say(f"$ the file link and its target afterwards\n{os.readlink(ln) if os.path.islink(ln) else '(no longer a link)'}\n{open(victim).read()[:200]}")
say(f"$ the hard link's outside file afterwards ({os.path.getsize(victim2)} bytes)\n{open(victim2, errors='replace').read()[:200]}")
out.close()
