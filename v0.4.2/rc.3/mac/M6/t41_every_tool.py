"""F9 4.1: every MCP tool once (host_control, app_display and use_app skipped: they need the desktop or the app)."""
import json
import re
import sys

import mcpc

out = open(f"{mcpc.R}/4.1-every-tool.txt", "w", encoding="utf-8")


def show(name, args, res, n=600):
    err, txt, raw = res
    line = f"== {name} {json.dumps(args)[:300]}\n   isError={err}\n   " + txt[:n].replace("\n", "\n   ") + ("\n   ..." if len(txt) > n else "")
    print(line)
    out.write(line + "\n")
    out.flush()
    return txt


m = mcpc.Mcp(f"{mcpc.R}/4.1-every-tool.jsonl", maxlog=3000)
init = m.init()
out.write(f"initialize: {json.dumps(init['result']['serverInfo'])} protocol {init['result']['protocolVersion']}\n")


def call(name, args, n=600, timeout=300):
    res = m.call(name, args, timeout=timeout)
    show(name, args, res, n)
    return res


# Help and reference
call("help", {})
call("help", {"topic": "searches"}, 300)
call("help", {"schema": "search_start/hunt"}, 300)
call("help", {"page": "guides/searching"}, 300)
call("reference", {})
call("reference", {"what": "tilings", "search": "k2-", "limit": 5})
call("reference", {"what": "palettes"}, 300)

# Worlds
call("world_new", {"tiling": "square", "width": 64, "height": 64, "boundary": "wrap", "cas": [{"rule": "Life", "seed": "empty"}], "name": "f9-glider"})
call("world_edit", {"cells": {"pattern": ".O.\n..O\nOOO", "x": 10, "y": 10}})
call("world_step", {"generations": 8})
call("world_read", {})
call("world_read", {"format": "objects"})
call("world_render", {"max_side": 256, "save_path": "f9/glider.png"})
call("world_status", {"save_path": "f9/glider-scene.json"})
call("world_status", {"scene": True}, 400)
call("world_new", {"tiling": "hex", "width": 60, "height": 60, "cas": ["B24/S35"]})
call("world_step", {"generations": 200, "stop_when_settled": True})

# Scripts
call("run_script", {"script": 'let w = world(#{ tiling: "hex", size: [60, 40], boundary: "wrap", rng_seed: 7 }); w.add_ca("B2/S34", #{ seed: "random:0.35" }); w.step(50); print(`pop ${w.population()} hash ${w.hash()}`);', "max_seconds": 30})
call("run_script", {"script": 'print("hello from f9");', "check_only": True})

# Searches: a short hunt that fills the library, then its status and finds
r = call("search_start", {"hunt": {"rules": ["B3/S23"], "soups": 3000}, "threads": 16, "wait_s": 180, "label": "f9-hunt"}, 900, timeout=400)
hunt_job = None
mm = re.search(r"job (\d+)", r[1])
if mm:
    hunt_job = int(mm.group(1))
call("job_status", {})
call("job_status", {"job": hunt_job or 1, "finds": 5})
call("job_status", {"job": hunt_job or 1, "report": True}, 500)

# A longer hunt, stopped with job_stop
r = call("search_start", {"hunt": {"rules": ["B36/S23"], "soups": 10000000}, "threads": 8, "label": "f9-stop-me"})
mm = re.search(r"job (\d+)", r[1])
stop_job = int(mm.group(1)) if mm else None
import time

time.sleep(5)
call("job_stop", {"job": stop_job})
call("job_status", {"job": stop_job, "wait_s": 60})

# Library
r = call("library_query", {"limit": 5})
ids = re.findall(r"\b([0-9a-f]{12,})\b", r[1])
pid = ids[0] if ids else "block"
out.write(f"   (pattern id used below: {pid})\n")
call("library_query", {"kind": "summary"})
call("library_query", {"id": pid}, 500)
call("library_curate", {"id": pid, "changes": {"rating": 4, "append_notes": "F9 test: rated through MCP", "add_tags": ["f9"]}})
call("library_query", {"tag": "f9"})

# Media
call("media_render", {"pattern": pid, "poster": True})
call("media_render", {"quickstart": "life", "gens": 30, "out": "f9/media-life"})

# An explore search for search_runs (GPU, 16 threads, a minute)
r = call("search_start", {"explore": {"tilings": "square,hex", "families": "life_like"}, "budget": {"minutes": 1}, "threads": 16, "gpu": True, "label": "f9-explore", "wait_s": 150}, 900, timeout=300)
mm = re.search(r"job (\d+)", r[1])
ex_job = int(mm.group(1)) if mm else None
call("job_status", {"job": ex_job, "wait_s": 120}, 500, timeout=200)
r = call("search_runs", {"job": ex_job, "limit": 5}, 900)
run_ids = [int(x) for x in re.findall(r"(?m)^\s*#?(\d+)\s", r[1])][:3]
out.write(f"   (run ids used below: {run_ids})\n")
call("search_runs", {"job": ex_job, "sheet": {"ids": run_ids or [1, 2, 3], "png": "f9/sheet.png", "px": 120}})
call("search_runs", {"job": ex_job, "scene": {"run": (run_ids or [1])[0], "save": "f9/run-scene.json"}}, 400)
call("search_runs", {"try": {"tiling": "hex", "rule": "B2/S34", "cells": 4000, "gens": 200, "png": "f9/try.png"}})
call("search_runs", {"job": ex_job, "review": {"run": (run_ids or [1])[0], "verdict": "maybe", "note": "F9 test review"}})

# Packs: publish (a test key in the F9 settings folder), info, check, export, site, import
call("pack", {"publish": {"feed": "f9-test", "to": "f9/store", "title": "F9 test store", "no_media": True}}, 800, timeout=600)
call("pack", {"info": {"path": "f9/store"}}, 800)
call("pack", {"check": {"path": "f9/store"}}, 800, timeout=600)
call("pack", {"export": {"from": "f9/store", "to": "f9/export"}}, 800, timeout=600)
call("pack", {"site": {"to": "f9/site", "render": False}}, 800, timeout=600)
call("pack", {"import": {"path": "f9/export", "verify": "sample", "sample": 50}}, 800, timeout=600)

# Files
call("files_list", {})
call("files_list", {"path": "f9"})
call("files_list", {"root": "catalog"})
call("files_list", {"file": "f9/glider-scene.json"}, 300)

# Resources
r = m.request("resources/list", {})
res = r["result"]["resources"] if r and "result" in r else []
out.write(f"== resources/list: {len(res)} resources; first: {[x['uri'] for x in res[:5]]}\n")
r = m.request("resources/read", {"uri": "jetcarp://schema/search_start/hunt"})
out.write(f"== resources/read jetcarp://schema/search_start/hunt: {json.dumps(r)[:300]}\n")

out.write("== skipped: host_control, app_display, use_app (they touch the desktop or need the app; later sittings)\n")
rc = m.close()
out.write(f"server exit {rc}; stderr lines: {len(m.stderr)}: {' | '.join(m.stderr)[:2000]}\n")
out.close()
