"""A-6 (the Acer) 5.5: a read-only output folder (and, beyond the plan, a read-only library) through MCP and the CLI.

The Mac's t55_readonly.py on Windows: chmod 555 has no effect on a Windows folder, so the folder gets an access
rule denying this user write access (icacls /deny <user>:(OI)(CI)(WD,AD,WEA,WA), removed afterwards; run 1 used (W), which includes SYNCHRONIZE and so also blocked listing the folder), and the library file
the read-only attribute as well.
"""
import json
import os
import shutil
import sqlite3
import subprocess

import mcpc

W = mcpc.W
USER = os.environ["USERNAME"]
RO = os.path.join(W, "ro-out")
out = open(os.path.join(mcpc.R, "5.5-readonly-mcp.txt"), "w", encoding="utf-8")


def say(s):
    s = s.replace(W, "$W").replace(W.replace("\\", "\\\\"), "$W")
    print(s)
    out.write(s + "\n")
    out.flush()


def deny(d):
    p = subprocess.run(["icacls", d, "/deny", f"{USER}:(OI)(CI)(WD,AD,WEA,WA)"], capture_output=True, text=True)
    say(f"(icacls /deny write on {d}: exit {p.returncode})")


def undeny(d):
    p = subprocess.run(["icacls", d, "/remove:d", USER], capture_output=True, text=True)
    say(f"(icacls /remove:d on {d}: exit {p.returncode})")


os.makedirs(RO, exist_ok=True)
deny(RO)
try:
    open(os.path.join(RO, "probe.txt"), "w").write("x")
    say("!! the folder is still writable: the deny rule did not take")
except OSError as e:
    say(f"(a write by this script is refused: {e.__class__.__name__}: {e.strerror})")

say(f"#### MCP with JETCARP_OUT={RO} (write denied)")
m = mcpc.Mcp(os.path.join(mcpc.R, "5.5-readonly-mcp.jsonl"), maxlog=1500, extra_env={"JETCARP_OUT": RO})
m.init()
scene = {"format": 1, "tiling": {"family": "square", "size": {"rect": {"w": 32, "h": 32}}}, "cas": [{"rule": "B3/S23", "seed": {"random": {"density": 0.3}}}]}
for name, args in [
    ("world_new", {"tiling": "square", "width": 32, "height": 32, "cas": ["Life"]}),
    ("world_status", {"save_path": "a.json"}),
    ("world_render", {"max_side": 64, "save_path": "a.png"}),
    ("world_render", {"wallpaper": {"size": "320x200"}}),
    ("run_script", {"script": 'let w = world(#{ tiling: "square", size: [32, 32] }); w.add_ca("Life", #{ seed: "random:0.3" }); w.save_png("x.png", #{ size: [64, 64] });'}),
    ("run_script", {"script": 'out_dir("ro"); print("made");'}),
    ("search_start", {"pile": {"grains": 1000}, "wait_s": 30}),
    ("media_render", {"scene": scene, "gens": 5}),
    ("search_runs", {"job": 3, "csv": "runs.csv", "limit": 3}),
    ("pack", {"publish": {"feed": "f9-ro", "to": "ro-store", "no_media": True, "no_searches": True}}),
    ("pack", {"site": {"to": "ro-site", "render": False}}),
    ("files_list", {}),
]:
    err, txt, _ = m.call(name, args, timeout=120)
    say(f"== {name} {json.dumps(args)[:200]} -> isError={err}\n   " + txt[:300].replace("\n", "\n   "))
m.close()
try:
    say(f"(left in the read-only folder: {os.listdir(RO)})")
finally:
    undeny(RO)

# A read-only library: a copy of the A-6 library (SQLite's own backup, so the WAL is folded in), the file read-only
# and its folder write-denied
lib = os.path.join(W, "ro-lib")
if os.path.exists(lib):
    undeny(lib)
    for fn in os.listdir(lib):
        os.chmod(os.path.join(lib, fn), 0o666)
    shutil.rmtree(lib)
os.makedirs(lib)
src = sqlite3.connect(os.path.join(W, "library", "library.sqlite"))
dst = sqlite3.connect(os.path.join(lib, "library.sqlite"))
src.backup(dst)
dst.close()
src.close()
os.chmod(os.path.join(lib, "library.sqlite"), 0o444)  # the read-only attribute
deny(lib)
say(f"#### a read-only library: {lib} (library.sqlite read-only, the folder write-denied)")
env = {**mcpc.env(), "JETCARP_LIBRARY": lib}
for args in (["library", "list", "--limit", "2"], ["search", "hunt", "--soups", "100", "--threads", "4"]):
    p = subprocess.run([mcpc.J, *args], env=env, capture_output=True, text=True, timeout=120, cwd=os.path.join(W, "cwd"))
    say(f"$ JETCARP_LIBRARY=$W\\ro-lib jetcarp {' '.join(args)}\n{p.stdout[-700:].rstrip()}\n{p.stderr[-700:].rstrip()}\nexit {p.returncode}")
m = mcpc.Mcp(os.path.join(mcpc.R, "5.5-readonly-lib-mcp.jsonl"), maxlog=1500, extra_env={"JETCARP_LIBRARY": lib})
m.init()
for name, args in [
    ("library_query", {"limit": 1}),
    ("library_curate", {"id": "aab843d7ff96817d170d6725fb23e37c", "changes": {"rating": 5}}),
    ("search_start", {"hunt": {"soups": 100}, "threads": 4, "wait_s": 30}),
    ("media_render", {"pattern": "aab843d7ff96817d170d6725fb23e37c", "force": True}),
]:
    err, txt, _ = m.call(name, args, timeout=120)
    say(f"== [read-only library] {name} {json.dumps(args)[:200]} -> isError={err}\n   " + txt[:400].replace("\n", "\n   "))
m.close()
say(f"(in the read-only library folder afterwards: {os.listdir(lib)})")
undeny(lib)
os.chmod(os.path.join(lib, "library.sqlite"), 0o666)
out.close()
