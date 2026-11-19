"""R4: call MCP tools on `jetcarp mcp` in the current (env.sh) environment and print each result.

usage: mcall.py LOG.jsonl CALLS_JSON [--tool-schema NAME] [--resource URI]... [--maxlog N]
CALLS_JSON is a list of [tool, arguments] pairs. --tool-schema prints that tool's entry from
tools/list first; --resource reads a resource and prints its text (first 400 chars and its length).
"""
import json
import sys

import mcpc

args = sys.argv[1:]
log, calls = args[0], json.loads(args[1])
schemas = [args[i + 1] for i, a in enumerate(args) if a == "--tool-schema"]
resources = [args[i + 1] for i, a in enumerate(args) if a == "--resource"]
maxlog = int(next((args[i + 1] for i, a in enumerate(args) if a == "--maxlog"), 6000))  # 0: every line whole
m = mcpc.Mcp(log, maxlog=maxlog)
init = m.init()
print("initialize ->", "ok" if init and "result" in init else init)
if schemas:
    r = m.request("tools/list")
    tools = r["result"]["tools"]
    print(f"tools/list -> {len(tools)} tools: {', '.join(t['name'] for t in tools)}")
    for name in schemas:
        t = next((t for t in tools if t["name"] == name), None)
        print(f"== {name} in tools/list:")
        print(json.dumps(t, indent=2) if t else "   (not listed)")
for uri in resources:
    r = m.request("resources/read", {"uri": uri})
    if r and "result" in r:
        text = "".join(c.get("text", "") for c in r["result"].get("contents", []))
        print(f"== resources/read {uri} -> {len(text)} chars")
        print(text[:400])
    else:
        print(f"== resources/read {uri} -> {json.dumps(r)[:600]}")
for name, a in calls:
    err, txt, _ = m.call(name, a)
    print(f"== tools/call {name} {json.dumps(a)} -> isError={err}")
    print("   " + txt.strip().replace("\n", "\n   "))
rc = m.close()
print(f"server exit {rc}")
