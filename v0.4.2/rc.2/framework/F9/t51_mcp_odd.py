"""F9 5.1 through MCP: the odd scenes (world_new path, world_new scene, media_render scene) and the
damaged packs (pack info, check, import) with --allow for the folders that hold them."""
import json, mcpc
W = mcpc.W
out = open(f"{mcpc.R}/5.1-mcp-odd.txt", "w")
def say(s):
    s = s.replace(W, "$W"); print(s); out.write(s + "\n")
m = mcpc.Mcp(f"{mcpc.R}/5.1-mcp-odd.jsonl", args=["--allow", f"{W}/odd", "--allow", f"{W}/packs"], maxlog=1500,
             extra_env={"JETCARP_LIBRARY": f"{W}/import-lib-mcp"})
m.init()
cases = []
for f in ["truncated", "unknown-rule", "unknown-rule-name", "future-format", "future-format-huge", "empty"]:
    cases.append(("world_new", {"path": f"{W}/odd/{f}.json"}))
cases.append(("world_new", {"scene": open(f"{W}/odd/truncated.json").read()}))
cases.append(("world_new", {"scene": json.load(open(f"{W}/odd/future-format.json"))}))
cases.append(("media_render", {"scene": json.load(open(f"{W}/odd/unknown-rule-name.json")), "out": f"{W}/odd/media"}))
for p in ["truncated", "truncated-manifest", "onebyte", "onebyte-part", "unsigned", "other-signer"]:
    cases.append(("pack", {"info": {"path": f"{W}/packs/{p}"}}))
    cases.append(("pack", {"check": {"path": f"{W}/packs/{p}"}}))
    cases.append(("pack", {"import": {"path": f"{W}/packs/{p}", "sample": 20}}))
cases.append(("pack", {"import": {"path": f"{W}/packs/unsigned", "allow_unsigned": True, "sample": 20}}))
cases.append(("pack", {"import": {"path": f"{W}/packs/onebyte", "allow_unsigned": True, "sample": 20}}))
for name, args in cases:
    err, txt, _ = m.call(name, args, timeout=300)
    a = json.dumps(args)
    say(f"== {name} {a[:160]}{'...' if len(a) > 160 else ''} -> isError={err}{'  SERVER DIED' if m.p.poll() is not None else ''}\n   " + txt[:400].replace("\n", "\n   "))
m.close()
say(f"server exit {m.p.returncode}")
out.close()
