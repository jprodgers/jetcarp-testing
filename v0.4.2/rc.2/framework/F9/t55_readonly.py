"""F9 5.5: a read-only output folder (and, beyond the plan, a read-only library) through MCP and the CLI."""
import json, os, shutil, subprocess, mcpc
W = mcpc.W
RO = f"{W}/ro-out"
out = open(f"{mcpc.R}/5.5-readonly-mcp.txt", "w")
def say(s):
    s = s.replace(W, "$W"); print(s); out.write(s + "\n")
say(f"#### MCP with JETCARP_OUT={RO} (chmod 555)")
m = mcpc.Mcp(f"{mcpc.R}/5.5-readonly-mcp.jsonl", maxlog=1500, extra_env={"JETCARP_OUT": RO})
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

# A read-only library: a copy of the F9 library in a folder made read-only, the file 444
lib = f"{W}/ro-lib"
if os.path.exists(lib):
    subprocess.run(["chmod", "-R", "u+w", lib])
    shutil.rmtree(lib)
os.makedirs(lib)
subprocess.run([mcpc.J, "library", "--help"], capture_output=True)
# copy with sqlite's own backup so the WAL is folded in
import sqlite3
src = sqlite3.connect(f"{W}/library/library.sqlite"); dst = sqlite3.connect(f"{lib}/library.sqlite")
src.backup(dst); dst.close(); src.close()
os.chmod(f"{lib}/library.sqlite", 0o444); os.chmod(lib, 0o555)
say(f"#### a read-only library: {lib} (folder 555, library.sqlite 444)")
env = {**mcpc.env(), "JETCARP_LIBRARY": lib}
for args in (["library", "list", "--limit", "2"], ["search", "hunt", "--soups", "100", "--threads", "4"], ["library", "curate", "--help"]):
    if args[-1] == "--help":
        continue
    p = subprocess.run([mcpc.J, *args], env=env, capture_output=True, text=True, timeout=120)
    say(f"$ JETCARP_LIBRARY=$W/ro-lib jetcarp {' '.join(args)}\n{p.stdout[-700:].rstrip()}\n{p.stderr[-700:].rstrip()}\nexit {p.returncode}")
m = mcpc.Mcp(f"{mcpc.R}/5.5-readonly-lib-mcp.jsonl", maxlog=1500, extra_env={"JETCARP_LIBRARY": lib})
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
out.close()
