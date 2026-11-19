"""F9 4.2b: a symlink inside the output folder. (1) reading through a symlinked folder; (2) a symlinked
file inside the output folder whose target is outside: does a save overwrite the target?"""
import json, os, mcpc
W = mcpc.W
victim = f"{W}/outside/victim.txt"
open(victim, "w").write("precious text outside the output folder\n")
ln = f"{W}/out/innocent.json"
if os.path.lexists(ln): os.remove(ln)
os.symlink(victim, ln)
out = open(f"{mcpc.R}/4.2b-symlink.txt", "w")
m = mcpc.Mcp(f"{mcpc.R}/4.2b-symlink.jsonl", maxlog=1500)
m.init()
for name, args in [
    ("world_new", {"path": "link-outside/good.json"}),
    ("files_list", {"file": "innocent.json"}),
    ("world_new", {"tiling": "square", "width": 16, "height": 16, "cas": ["Life"]}),
    ("world_status", {"save_path": "innocent.json"}),
]:
    err, txt, _ = m.call(name, args)
    s = f"== {name} {json.dumps(args)} -> isError={err}\n   {txt[:300]}".replace(W, "$W")
    print(s); out.write(s + "\n")
m.close()
s = f"$ ls -l $W/out/innocent.json; head -c 200 $W/outside/victim.txt\n{os.readlink(ln)}\n{open(victim).read()[:200]}".replace(W, "$W")
print(s); out.write(s + "\n")
out.close()
