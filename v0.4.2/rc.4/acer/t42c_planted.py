"""rc.4 wave on the Acer, R4's (private) part 4.2 row: files JETCARP names itself inside a checked folder.

(a) A-6's t42b_symlink.py again (F9's script on Windows), with rc.4's program, in ~\\jetcarp-rc4\\p42: a copy of
    A-6's folder's settings (the publisher key) and library, so its pack and search_runs calls have what they need.
    Its outputs land here as 4.2b-symlink*.
(b) New for rc.4 (d1f3478): a symbolic link planted at a name JETCARP chooses itself inside a folder it was given,
    leading outside: an animation's poster.png (media_render), its frames folder, and a pack export's pack.json
    (pack export), through MCP and the command line; one target missing, one an existing file. Each must be
    refused, naming the file as JETCARP would write it and not where the link leads, and nothing may be written
    where it leads. A control: a link that stays inside the output folder is followed.
    The suite's own tests of this are #[cfg(unix)], so this is their only check on Windows.
Symbolic links need Developer Mode here (on since rc.3 A-6). Output: 4.2c-planted.txt and .jsonl.

  python -X utf8 -B t42c_planted.py
"""
import json
import os
import runpy
import shutil
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
A6 = os.path.join(HERE, "..", "..", "v0.4.2-rc.3", "acer", "A6")
sys.path.insert(0, A6)
import mcpc  # noqa: E402

HOME = os.path.expanduser("~")
P = os.path.join(HOME, "jetcarp-rc4", "p42")
SRC6 = os.path.join(HOME, "jetcarp-rc-042c", "a6")
mcpc.W = P
mcpc.J = os.path.join(HOME, "jetcarp-rc-042c", "bin", "jetcarp.exe")
mcpc.R = HERE

if os.path.exists(P):
    shutil.rmtree(P)
shutil.copytree(os.path.join(SRC6, "config"), os.path.join(P, "config"))
shutil.copytree(os.path.join(SRC6, "library"), os.path.join(P, "library"), ignore=shutil.ignore_patterns("*-shm", "*-wal", "media"))
for d in ("data", "out", "run", "cwd", "outside"):
    os.makedirs(os.path.join(P, d), exist_ok=True)
OUT = os.path.join(P, "out")
AWAY = os.path.join(P, "outside", "planted")  # made after (a), so (a)'s count of what appeared outside stays its own
# A-6's script reads through a junction made by its earlier steps; make it here too.
subprocess.run(["cmd", "/c", "mklink", "/J", os.path.join(OUT, "link-outside"), os.path.join(P, "outside")], capture_output=True)

# (a)
print("== (a) A-6's t42b_symlink.py with rc.4", flush=True)
runpy.run_path(os.path.join(A6, "t42b_symlink.py"), run_name="__main__")
os.makedirs(AWAY, exist_ok=True)

# (b)
log = open(os.path.join(HERE, "4.2c-planted.txt"), "w", encoding="utf-8")


def say(s):
    s = s.replace(P, "$P").replace(P.replace("\\", "\\\\"), "$P").replace(P.replace("\\", "/"), "$P")
    s = s.replace(HOME, "~").replace(HOME.replace("\\", "\\\\"), "~")
    print(s, flush=True)
    log.write(s + "\n")
    log.flush()


MADE = set()  # junction targets this script made (empty folders), told apart from anything JETCARP writes


def plant(folder, name, target, is_dir=False):
    """A symbolic link; for a folder, a directory junction when symbolic links can't be made (Developer Mode
    off: Windows then needs administrator rights for one, and junctions need none). None when a file link
    can't be made: that case is skipped."""
    d = os.path.join(OUT, folder)
    os.makedirs(d, exist_ok=True)
    ln = os.path.join(d, name)
    kind = "symbolic link"
    try:
        os.symlink(target, ln, target_is_directory=is_dir)
    except OSError as e:
        if not is_dir:
            say(f"NOT planted (a file symbolic link: {e.__class__.__name__} {getattr(e, 'winerror', '')}, Developer Mode is off): {ln}; case skipped")
            return None
        os.makedirs(target, exist_ok=True)
        MADE.add(target)
        subprocess.run(["cmd", "/c", "mklink", "/J", ln, target], capture_output=True)
        kind = "directory junction"
    say(f"planted ({kind}): {ln} -> {target} ({'exists' if os.path.exists(target) else 'missing'})")
    return ln


def snapshot():
    found = {}
    for root, dirs, files in os.walk(AWAY):
        for fn in dirs + files:
            p = os.path.join(root, fn)
            found[p] = (os.path.getsize(p), os.path.getmtime(p)) if os.path.isfile(p) else ("dir",)
    return found


def judge(text, planted):
    refused = "may only write inside" in text
    names = planted in text or planted.replace("\\", "/") in text or planted.replace("\\", "\\\\") in text
    leaks = "outside" in text.replace("link leads out of it", "")
    return f"refused: {refused}; names the planted file: {names}; names where it leads: {leaks}"


victim = os.path.join(AWAY, "victim-poster.png")
open(victim, "w").write("precious: not a poster\n")
os.makedirs(os.path.join(AWAY, "frames"), exist_ok=True)
say(f"#### (b) planted links, rc.4 ({subprocess.run([mcpc.J, '--version'], capture_output=True, text=True).stdout.strip()}), {time.strftime('%Y-%m-%d %H:%M:%S')}")
STORE_MCP = os.path.join(AWAY, "store-mcp")  # (c) the hidden store beside an export: existing folders, so a write shows
STORE_CLI = os.path.join(AWAY, "store-cli")
os.makedirs(STORE_MCP, exist_ok=True)
os.makedirs(STORE_CLI, exist_ok=True)
before = snapshot()
victim_text = open(victim).read()

cases = [
    ("mcp", plant("lk-media", "poster.png", os.path.join(AWAY, "lk-media-poster.png")), "media_render",
     {"quickstart": "life", "out": "lk-media"}),
    ("mcp", plant("lk-media2", "poster.png", victim), "media_render", {"quickstart": "life", "out": "lk-media2", "force": True}),
    ("mcp", plant("lk-frames", "frames", os.path.join(AWAY, "frames"), is_dir=True), "media_render",
     {"quickstart": "life", "out": "lk-frames", "frames": True}),
    ("mcp", plant("lk-export", "pack.json", os.path.join(AWAY, "pack.json")), "pack",
     {"export": {"to": "lk-export", "publish": {"feed": "p42", "no_media": True, "no_searches": True}}}),
    ("mcp", plant("lk-index", "index", os.path.join(AWAY, "index"), is_dir=True), "pack",
     {"export": {"to": "lk-index", "publish": {"feed": "p42i", "no_media": True, "no_searches": True}}}),
    # (c) the Mac's extra case (NOTES 10:26 PM): the hidden store JETCARP keeps beside an export's folder
    ("mcp", plant("", ".lk-store.store", STORE_MCP, is_dir=True), "pack",
     {"export": {"to": "lk-store", "publish": {"feed": "p42s", "no_media": True, "no_searches": True}}}),
]
m = mcpc.Mcp(os.path.join(HERE, "4.2c-planted.jsonl"), maxlog=2000)
m.init()
for _, planted, tool, args in cases:
    if planted is None:
        continue
    err, txt, _ = m.call(tool, args, timeout=300)
    say(f"== MCP {tool} {json.dumps(args)} -> isError={err}\n   {txt[:400]}\n   [{judge(txt, planted)}]")

# Control: a link that stays inside the output folder is followed.
inside = os.path.join(OUT, "inside-target")
os.makedirs(os.path.join(inside, "frames"), exist_ok=True)
ctl = plant("lk-inside", "frames", os.path.join(inside, "frames"), is_dir=True)
err, txt, _ = m.call("media_render", {"quickstart": "life", "out": "lk-inside", "frames": True}, timeout=300)
nfr = len(os.listdir(os.path.join(inside, "frames"))) if os.path.isdir(os.path.join(inside, "frames")) else "no folder"
say(f"== MCP media_render (a frames link to elsewhere in the output folder, so out of the folder given: refused by design) -> isError={err}\n   {txt[:300]}\n   [frames written where it leads: {nfr}]")
# The control: a link that stays inside the folder given is followed.
real = os.path.join(OUT, "lk-inside2", "real-frames")
os.makedirs(real, exist_ok=True)
plant("lk-inside2", "frames", real, is_dir=True)
err, txt, _ = m.call("media_render", {"quickstart": "life", "out": "lk-inside2", "frames": True}, timeout=300)
fr = os.path.join(OUT, "lk-inside2", "frames")
say(f"== MCP media_render (control, a frames link that stays inside the folder given) -> isError={err}\n   {txt[:300]}\n   [frames written where it leads, inside: {len(os.listdir(real))}; lk-inside2\\frames still a link: {os.path.islink(fr)}, frames in it: {len(os.listdir(fr)) if os.path.isdir(fr) else 0}]")
m.close()

# The command line, the same names
env = mcpc.env()
for folder, name, is_dir, argv in [
    ("lk-media-cli", "poster.png", False, ["media", "render", "--quickstart", "life", "--out", os.path.join(OUT, "lk-media-cli")]),
    ("lk-frames-cli", "frames", True, ["media", "render", "--quickstart", "life", "--out", os.path.join(OUT, "lk-frames-cli")]),
    ("lk-export-cli", "pack.json", False, ["pack", "export", "--to", os.path.join(OUT, "lk-export-cli"), "--feed", "p42-cli", "--no-media", "--no-searches"]),
    ("lk-index-cli", "index", True, ["pack", "export", "--to", os.path.join(OUT, "lk-index-cli"), "--feed", "p42i-cli", "--no-media", "--no-searches"]),
    ("", ".lk-store-cli.store", True, ["pack", "export", "--to", os.path.join(OUT, "lk-store-cli"), "--feed", "p42s-cli", "--no-media", "--no-searches"]),
]:
    target = STORE_CLI if name == ".lk-store-cli.store" else os.path.join(AWAY, f"{folder}-{name}")
    planted = plant(folder, name, target, is_dir=is_dir)
    if planted is None:
        continue
    r = subprocess.run([mcpc.J, *argv], env=env, cwd=os.path.join(P, "cwd"), capture_output=True, text=True, encoding="utf-8")
    txt = (r.stdout + r.stderr).strip()
    say(f"== $ jetcarp {' '.join(argv)} -> exit {r.returncode}\n   {txt[-400:]}\n   [{judge(txt, planted)}]")

after = snapshot()
new = sorted(set(after) - set(before) - MADE)
changed = sorted(p for p in before if p in after and before[p] != after[p])
say(f"#### where the links lead ($P\\outside\\planted): new entries {len(new)} {new}; changed {len(changed)} {changed}")
say(f"the junction targets this script made, still empty: {all(not os.listdir(d) for d in MADE if d.startswith(AWAY))} ({len([d for d in MADE if d.startswith(AWAY)])})")
say(f"the existing target unchanged: {open(victim).read() == victim_text}; the frames folder there empty: {not os.listdir(os.path.join(AWAY, 'frames'))}")
for nm, d in (("MCP", STORE_MCP), ("command line", STORE_CLI)):
    files = [os.path.relpath(os.path.join(r, f), d) for r, _, fs in os.walk(d) for f in fs]
    say(f"(c) the hidden store's link ({nm}): files written where it leads: {len(files)} {files[:6]}{' ...' if len(files) > 6 else ''}")
say(f"jetcarp processes left: {mcpc.procs('jetcarp') or 'none'}")
log.close()
