"""rc.4 wave on the Acer, R4 #96 and #112 through MCP: host_control before and after the seizure warning is
answered, and whether tools/list offers Fit. A-6's mcpc.py (rc.3) with rc.4's program and the folder given
(config, data, out, library, run under it).

  python -X utf8 -B t0_mcp.py refuse|accepted <folder> <out-name>

refuse:   no answer saved, no host running: the calls that start or show scenes must name the warning.
accepted: the answer saved and a headless host running in that folder: they work; tune is refused (Fit is off).
          (wallpaper and login are left out here: on a running host they would change the desktop.)
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "v0.4.2-rc.3", "acer", "A6"))
import mcpc  # noqa: E402

mode, W, name = sys.argv[1], sys.argv[2], sys.argv[3]
HOME = os.path.expanduser("~")
mcpc.W = W
mcpc.J = os.path.join(HOME, "jetcarp-rc-042c", "bin", "jetcarp.exe")
out = open(os.path.join(HERE, name + ".txt"), "w", encoding="utf-8")


def say(s):
    s = s.replace(HOME, "~").replace(HOME.replace("\\", "\\\\"), "~")
    print(s, flush=True)
    out.write(s + "\n")
    out.flush()


m = mcpc.Mcp(os.path.join(HERE, name + ".jsonl"), maxlog=3000)
r = m.init()
say(f"[{mode}] folder {W}; server {r['result'].get('serverInfo') if r else None}")
tl = m.request("tools/list", {})
tools = tl["result"]["tools"]
hc = [t for t in tools if t["name"] == "host_control"][0]
props = hc["inputSchema"]["properties"]
schema = json.dumps(hc["inputSchema"])
say(f"tools/list: {len(tools)} tools; host_control's properties: {sorted(props)}")
say(f"host_control's action: {json.dumps(props.get('action'))}")
say(f"'tune' in host_control's schema: {'tune' in schema}; 'pick' or 'fps' properties: {'pick' in props}, {'fps' in props}")
say(f"'fit' or 'tune' in its description: {'fit ' in hc['description'].lower() or 'tune' in hc['description'].lower()}")
say(f"description: {hc['description']}")
calls = [{"action": "status"}, {"action": "resume"}, {"action": "next"}, {"action": "previous"},
         {"action": "rotation", "name": "A classic a day"}]
if mode == "refuse":
    calls += [{"action": "wallpaper", "on": True}, {"action": "login", "on": True}, {"action": "pause"}]
calls += [{"action": "tune", "dry_run": True}, {"action": "tune_stop"}, {"action": "tune_events"}, {"action": "tuning"}]
for a in calls:
    err, txt, _ = m.call("host_control", a, timeout=60)
    say(f"== host_control {json.dumps(a)} -> isError={err}\n   {txt[:500]}")
m.close()
out.close()
