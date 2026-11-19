"""A-6 (the Acer): R's command-line rows #47, #57, #66, #67 (the Mac's r_cli.sh and r66.sh in Python for Windows).
Every folder is under $W."""
import json
import os
import shutil
import subprocess
import time

import mcpc

W, J = mcpc.W, mcpc.J
C = os.path.join(W, "cli")
os.makedirs(C, exist_ok=True)
out = open(os.path.join(mcpc.R, "r-cli.txt"), "w", encoding="utf-8")


def say(s):
    s = s.replace(W, "$W")
    print(s)
    out.write(s + "\n")
    out.flush()


def cli(*args, timeout=180, quiet=False, tail=None):
    p = subprocess.run([J, *args], env=mcpc.env(), cwd=C, capture_output=True, text=True, encoding="utf-8",
                       errors="replace", timeout=timeout)
    text = (p.stdout + p.stderr).rstrip()
    if tail:
        text = "\n".join(text.splitlines()[-tail:])
    if not quiet:
        say(f"$ jetcarp {' '.join(args)}   [{time.strftime('%H:%M:%S')}]\n{text}\nexit {p.returncode}")
    return p


def job_of(label):
    p = cli("jobs", "list", "--label", label, "--json", quiet=True)
    try:
        d = json.loads(p.stdout)
        d = d if isinstance(d, list) else d.get("jobs", [])
        return str(d[0]["job"]) if d else ""
    except Exception as e:
        say(f"(could not read the job of {label}: {e}; stdout {p.stdout[:200]})")
        return ""


def gone(name):
    left = [x for x in os.listdir(C) if name.lower() in x.lower()]
    say(f"(entries in $W\\cli naming {name}: {left if left else 'none'})")


say("#### #47 explore --limit help")
p = cli("search", "explore", "--help", quiet=True)
lines = p.stdout.splitlines()
for i, l in enumerate(lines):
    if "--limit" in l:
        say("\n".join(lines[i:i + 3]))

say("\n#### #57 pack export refuses a running search; a refused export leaves no folder")
cli("search", "hunt", "--rules", "B3/S23", "--tilings", "square", "--soups", "300", "--quiet", tail=2)
cli("search", "explore", "--detach", "--minutes", "3", "--label", "r57", tail=1)
time.sleep(5)
cli("jobs", "list", tail=6)
cli("pack", "export", "--to", os.path.join(C, "p57"), "--feed", "r57", "--no-media")
gone("p57")
j57 = job_of("r57")
say(f"stopping job {j57}")
cli("jobs", "stop", j57, tail=1)
cli("jobs", "wait", j57, "--timeout", "60", tail=1)

say("\n#### #57 b: a search running with nothing stored yet (a fresh explore, exported at once)")
cli("search", "explore", "--detach", "--minutes", "1", "--label", "r57b", tail=1)
cli("pack", "export", "--to", os.path.join(C, "p57b"), "--feed", "r57b", "--no-media")
gone("p57b")
j57b = job_of("r57b")
cli("jobs", "stop", j57b, tail=1)
cli("jobs", "wait", j57b, "--timeout", "60", tail=1)

say("\n#### #66 a signed pack, then a tampered copy and an unsigned copy (no search running)")
cli("jobs", "list", tail=5)
cli("pack", "export", "--to", os.path.join(C, "good66"), "--feed", "r66", "--no-media", tail=2)
for n in ("onebyte66", "unsigned66"):
    d = os.path.join(C, n)
    if os.path.exists(d):
        shutil.rmtree(d)
    shutil.copytree(os.path.join(C, "good66"), d)
pj = os.path.join(C, "onebyte66", "pack.json")
b = bytearray(open(pj, "rb").read())
j = b.find(b'"r66"')
say(f"(onebyte66: pack.json byte {j + 3} changed, \"r66\" -> \"r67\")" if j > 0 else "(!! \"r66\" not found in pack.json)")
if j > 0:
    b[j + 3] = ord("7")
    open(pj, "wb").write(b)
for root, _, files in os.walk(os.path.join(C, "unsigned66", "sigs")):
    for fn in files:
        os.remove(os.path.join(root, fn))
for n in ("good66", "onebyte66", "unsigned66"):
    say(f"-- pack info {n}")
    cli("pack", "info", os.path.join(C, n), tail=8)
for n in ("onebyte66", "unsigned66"):
    say(f"-- pack import {n}")
    cli("pack", "--library", os.path.join(C, f"imp-{n}.sqlite"), "import", os.path.join(C, n), tail=3)

say("\n#### #67 a malformed rule names its CA and file; a read-only library can be read")
bad = os.path.join(C, "bad-rule.json")
open(bad, "w").write('{"format":1,"name":"bad rule","tiling":{"family":"square","size":{"rect":{"w":32,"h":32}},"boundary":"wrap"},"rng_state":3,\n'
                     ' "cas":[{"id":1,"name":"Lifeish","rule":"B3/S23/Q9 Frobnicate","seed":{"random":{"density":0.3}}}]}\n')
cli("run", bad, "--gens", "5")
cli("verify", bad)
ro = os.path.join(C, "ro.sqlite")
if os.path.exists(ro):
    os.chmod(ro, 0o666)
    os.remove(ro)
import sqlite3
s = sqlite3.connect(os.path.join(W, "library", "library.sqlite"))
d = sqlite3.connect(ro)
s.backup(d)
d.close()
s.close()
os.chmod(ro, 0o444)
cli("library", "--library", ro, "list", tail=4)
os.chmod(ro, 0o666)
out.close()
