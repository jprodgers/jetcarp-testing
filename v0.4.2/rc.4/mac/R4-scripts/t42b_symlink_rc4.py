"""R4 on the Mac (a), private: rc.3's F9 4.2b (t42b_symlink.py) again, against rc.4. A symlink inside the output folder:
(1) reading through a symlinked folder; (2) a symlinked file inside the output folder whose target is
outside: does a save overwrite the target? Run from t42b_planted_rc4.sh (the lib.sh environment)."""
import json
import os

import mcpc

H = mcpc.H
OUT = os.environ["JETCARP_OUT"]
os.makedirs(f"{H}/outside", exist_ok=True)
victim = f"{H}/outside/victim.txt"
open(victim, "w").write("precious text outside the output folder\n")
ln = f"{OUT}/innocent.json"
if os.path.lexists(ln):
    os.remove(ln)
os.symlink(victim, ln)
lo = f"{OUT}/link-outside"
if not os.path.lexists(lo):
    os.symlink(f"{H}/outside", lo)
out = open(f"{mcpc.R}/4.2b-symlink-rc4.txt", "w")
s = ("R4 (a) rc.3's t42b_symlink.py again, on rc.4 (MCP log: 4.2b-symlink-rc4.jsonl)\n"
     "$ ln -s $H/outside/victim.txt $H/out/innocent.json; ln -s $H/outside $H/out/link-outside\n")
print(s, end=""); out.write(s)
m = mcpc.Mcp(f"{mcpc.R}/4.2b-symlink-rc4.jsonl", maxlog=1500)
m.init()
for name, args in [
    ("world_new", {"path": "link-outside/good.json"}),
    ("files_list", {"file": "innocent.json"}),
    ("world_new", {"tiling": "square", "width": 16, "height": 16, "cas": ["Life"]}),
    ("world_status", {"save_path": "innocent.json"}),
]:
    err, txt, _ = m.call(name, args)
    s = f"== {name} {json.dumps(args)} -> isError={err}\n   {txt[:300]}"
    print(s); out.write(s + "\n")
m.close()
s = mcpc.sub(f"$ readlink $H/out/innocent.json; cat $H/outside/victim.txt\n{os.readlink(ln)}\n{open(victim).read()[:200]}")
print(s); out.write(s + "\n")
out.close()
