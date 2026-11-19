"""F9 4.3: bad input for each tool. A missing or wrong-typed argument must give an error a person can
act on, never a crash or an opaque message. The server is restarted if it ever dies (a crash)."""
import json
import mcpc

PID = "aab843d7ff96817d170d6725fb23e37c"  # a pattern in the F9 library (4.1)
CASES = [
    # help
    ("help", {"topic": "nope"}), ("help", {"topic": 5}), ("help", {"page": "nope/nothing"}),
    ("help", {"schema": "nope/nothing"}), ("help", {"bogus": 1}),
    # reference
    ("reference", {"what": "nope"}), ("reference", {"what": "tilings", "limit": "abc"}),
    ("reference", {"family": 7}),
    # world_new
    ("world_new", {"tiling": "nope"}), ("world_new", {"width": "abc", "height": 10}),
    ("world_new", {"cas": ["NotARule"]}), ("world_new", {"width": -5, "height": 10}),
    ("world_new", {"width": 0, "height": 0}), ("world_new", {"cells": 99999999}),
    ("world_new", {"path": "missing.json"}), ("world_new", {"scene": "not json"}),
    ("world_new", {"scene": {"format": 1}}), ("world_new", {"pattern": "nope"}),
    ("world_new", {"quickstart": "nope"}), ("world_new", {"cas": 5}),
    ("world_new", {"boundary": "sideways"}), ("world_new", {"rng_seed": "seven"}),
    ("world_new", {"tiling": "spectre", "level": 99}),
    # world_status (a world exists from here on)
    ("world_new", {"tiling": "square", "width": 32, "height": 32, "cas": ["Life"]}),
    ("world_status", {"scene": "yes"}), ("world_status", {"save_path": 5}),
    ("world_status", {"save_path": ""}),
    # world_read
    ("world_read", {"format": "nope"}), ("world_read", {"ca": 99}), ("world_read", {"ca": "nobody"}),
    ("world_read", {"x": "a"}), ("world_read", {"cell": {"x": 1}}), ("world_read", {"cell": {"x": 1000, "y": 1000}}),
    ("world_read", {"x": 0, "y": 0, "width": 100000}), ("world_read", {"format": "objects", "max_period": 99999}),
    # world_edit
    ("world_edit", {}), ("world_edit", {"cells": {"pattern": 5}}), ("world_edit", {"paste": {}}),
    ("world_edit", {"paste": {"id": "nope"}}), ("world_edit", {"commands": [{"op": "nope"}]}),
    ("world_edit", {"commands": "not json"}), ("world_edit", {"cells": {"rle": "this is not rle !!"}}),
    ("world_edit", {"cells": {"cells": [[1]]}}), ("world_edit", {"cells": {"cells": [[1000, 1000]]}}),
    ("world_edit", {"reseed": {"mode": "nope"}}), ("world_edit", {"cells": {"pattern": "O", "x": 0, "y": 0}, "paste": {"id": "glider"}}),
    # world_step
    ("world_step", {"generations": -1}), ("world_step", {"generations": "lots"}),
    ("world_step", {"generations": 2000000}), ("world_step", {"generations": 1e12}),
    ("world_step", {"generations": 1.5}),
    # world_render
    ("world_render", {"max_side": 10}), ("world_render", {"max_side": "big"}),
    ("world_render", {"wallpaper": {"size": "huge"}}), ("world_render", {"wallpaper": "4K"}),
    # run_script
    ("run_script", {}), ("run_script", {"script": 5}), ("run_script", {"script": "let x = ;"}),
    ("run_script", {"script": "loop { }", "max_seconds": 2}), ("run_script", {"script": "print(1);", "max_seconds": 10000}),
    ("run_script", {"script": "print(1);", "params": "not a map"}),
    ("run_script", {"script": 'let w = world(#{ tiling: "square", size: [5000, 5000] });'}),
    # library_query
    ("library_query", {"kind": "nope"}), ("library_query", {"id": "nonexistent"}),
    ("library_query", {"limit": "x"}), ("library_query", {"class": "nope"}),
    ("library_query", {"order": "nope"}), ("library_query", {"limit": 100000}),
    # library_curate
    ("library_curate", {}), ("library_curate", {"id": "nope", "changes": {"rating": 4}}),
    ("library_curate", {"id": PID, "changes": {"rating": 9}}), ("library_curate", {"id": PID, "changes": {"state": "nope"}}),
    ("library_curate", {"id": PID}), ("library_curate", {"id": PID, "changes": "rating 4"}),
    ("library_curate", {"quickstart": {"pattern": "nope"}}),
    # search_start
    ("search_start", {}), ("search_start", {"hunt": {"rules": ["NotARule"]}}), ("search_start", {"hunt": 5}),
    ("search_start", {"hunt": {"soups": "many"}}), ("search_start", {"hunt": {"soups": 10}, "ants": {}}),
    ("search_start", {"resume": 999}), ("search_start", {"hunt": {"soups": 10}, "threads": -1}),
    ("search_start", {"hunt": {"bogus_setting": 1}}), ("search_start", {"explore": {"tilings": "nope"}, "budget": {"minutes": 0.1}}),
    ("search_start", {"hunt": {"soups": 10}, "budget": {"minutes": "soon"}}), ("search_start", {"resume": 1}),
    ("search_start", {"pile": {"grains": "lots"}}),
    # job_status
    ("job_status", {"job": 999}), ("job_status", {"job": "abc"}), ("job_status", {"job": 1, "wait_s": 9999}),
    ("job_status", {"status": "nope"}),
    # job_stop
    ("job_stop", {}), ("job_stop", {"job": "abc"}), ("job_stop", {"job": 999}), ("job_stop", {"job": 1}),
    ("job_stop", {"job": None}),
    # search_runs
    ("search_runs", {"job": 999}), ("search_runs", {"job": 1}), ("search_runs", {"try": {}}),
    ("search_runs", {"try": {"tiling": "hex", "rule": "NotARule"}}), ("search_runs", {"job": 3, "sheet": {"ids": "a"}}),
    ("search_runs", {"job": 3, "scene": {}}), ("search_runs", {"job": 3, "scene": {"run": 99999999}}),
    ("search_runs", {"job": 3, "review": {"run": 1, "verdict": "great"}}), ("search_runs", {"job": 3, "order": "nope"}),
    # media_render
    ("media_render", {}), ("media_render", {"pattern": "nope"}), ("media_render", {"format": "mp4", "pattern": PID}),
    ("media_render", {"scene": "not json"}), ("media_render", {"quickstart": "nope"}),
    # pack
    ("pack", {}), ("pack", {"info": {}}), ("pack", {"info": {"path": "nope"}}), ("pack", {"publish": {"to": "f9/x"}}),
    ("pack", {"publish": {"feed": "bad feed!", "to": "f9/x"}}), ("pack", {"check": {"path": 5}}),
    ("pack", {"info": "f9/store"}), ("pack", {"info": {"path": "f9/store"}, "check": {"path": "f9/store"}}),
    ("pack", {"import": {"path": "f9/store", "verify": "maybe"}}),
    # files_list
    ("files_list", {"root": "nope"}), ("files_list", {"path": "nope"}), ("files_list", {"file": "nope.json"}),
    ("files_list", {"file": "library.sqlite", "root": "catalog"}), ("files_list", {"limit": -3}),
]

out = open(f"{mcpc.R}/4.3-bad-input.txt", "w", encoding="utf-8")
m = mcpc.Mcp(f"{mcpc.R}/4.3-bad-input.jsonl", maxlog=1500)
m.init()
n = 0
for name, args in CASES:
    n += 1
    err, txt, raw = m.call(name, args, timeout=60)
    crash = m.p.poll() is not None
    s = f"== {n}. {name} {json.dumps(args)}\n   isError={err}{'  SERVER DIED' if crash else ''}\n   " + txt[:420].replace("\n", "\n   ")
    print(s)
    out.write(s + "\n")
    out.flush()
    if crash or raw is None:
        out.write(f"   !! server exit {m.p.poll()}, stderr: {m.stderr[-5:]}\n")
        m.close()
        m = mcpc.Mcp(f"{mcpc.R}/4.3-bad-input-{n}.jsonl", maxlog=1500)
        m.init()
        m.call("world_new", {"tiling": "square", "width": 32, "height": 32, "cas": ["Life"]})

# Protocol-level oddities
m.note("protocol oddities")
for label, raw in [
    ("unknown tool", json.dumps({"jsonrpc": "2.0", "id": 9001, "method": "tools/call", "params": {"name": "nope", "arguments": {}}})),
    ("arguments a list", json.dumps({"jsonrpc": "2.0", "id": 9002, "method": "tools/call", "params": {"name": "help", "arguments": [1, 2]}})),
    ("arguments a string", json.dumps({"jsonrpc": "2.0", "id": 9003, "method": "tools/call", "params": {"name": "help", "arguments": "topic=overview"}})),
    ("no params", json.dumps({"jsonrpc": "2.0", "id": 9004, "method": "tools/call"})),
    ("unknown method", json.dumps({"jsonrpc": "2.0", "id": 9005, "method": "tools/frobnicate", "params": {}})),
    ("not JSON", "{this is not json"),
    ("after the bad line, still alive?", json.dumps({"jsonrpc": "2.0", "id": 9006, "method": "tools/call", "params": {"name": "world_status", "arguments": {}}})),
    ("resource that does not exist", json.dumps({"jsonrpc": "2.0", "id": 9007, "method": "resources/read", "params": {"uri": "jetcarp://nope"}})),
]:
    m.send_raw(raw)
    want = json.loads(raw).get("id") if raw.startswith("{\"") else None
    if want is None:
        r = m.recv(None, timeout=5)  # a parse error carries id null
    else:
        r = m.recv(want, timeout=30)
    s = f"== protocol: {label}\n   >> {raw[:200]}\n   << {json.dumps(r)[:420] if r else '(nothing within the timeout; see the jsonl)'}"
    print(s)
    out.write(s + "\n")
rc = m.close()
out.write(f"server exit {rc}; stderr: {m.stderr[-10:]}\n")
out.close()
