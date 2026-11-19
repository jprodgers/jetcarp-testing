#!/usr/bin/env python3
"""One `jetcarp mcp` (or `mcp --app`) connection: initialize, then each call in turn; prints each reply.

python3 mcpcall.py <jetcarp> [--app] list                     # tools/list: each tool's name, and its schema's properties
python3 mcpcall.py <jetcarp> [--app] call <tool> '<json args>' [call <tool> '<json>' ...]
(The JETCARP_* variables of the caller apply.)
"""
import json, subprocess, sys

a = sys.argv[1:]
J = a.pop(0)
cmd = [J, "mcp"]
if a and a[0] == "--app":
    cmd.append(a.pop(0))
p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1)
n = 0


def rpc(method, params=None):
    global n
    n += 1
    p.stdin.write(json.dumps({"jsonrpc": "2.0", "id": n, "method": method, "params": params or {}}) + "\n")
    p.stdin.flush()
    while True:
        line = p.stdout.readline()
        if not line:
            return None
        try:
            m = json.loads(line)
        except ValueError:
            continue
        if m.get("id") == n:
            return m


init = rpc("initialize", {"protocolVersion": "2025-06-18", "capabilities": {}, "clientInfo": {"name": "rc4-mac", "version": "1"}})
si = (init or {}).get("result", {}).get("serverInfo", {})
print(f"# server {si.get('name')} {si.get('version')}")
p.stdin.write(json.dumps({"jsonrpc": "2.0", "method": "notifications/initialized"}) + "\n")
p.stdin.flush()
while a:
    what = a.pop(0)
    if what == "list":
        r = rpc("tools/list")
        for t in (r or {}).get("result", {}).get("tools", []):
            print(f"{t['name']}: {json.dumps(t.get('inputSchema', {}).get('properties', {}))}")
    elif what == "call":
        tool, args = a.pop(0), json.loads(a.pop(0))
        r = rpc("tools/call", {"name": tool, "arguments": args})
        res = (r or {}).get("result", {})
        txt = " ".join(c.get("text", "") for c in res.get("content", []))
        print(f"> {tool} {json.dumps(args)}\nisError {res.get('isError')}: {txt if r else 'no reply'}" + (f"\nerror: {r['error']}" if r and 'error' in r else ""))
p.stdin.close()
try:
    p.wait(10)
except subprocess.TimeoutExpired:
    p.kill()
