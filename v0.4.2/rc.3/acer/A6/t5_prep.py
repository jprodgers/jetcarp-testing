"""A-6 (the Acer): the files Part 5 (and part 4.2's reads) need, made before any test uses them.

The Mac's t5_cli.sh made these after 4.2 had run; here they come first. Odd scenes in $W/odd, damaged copies of
the Framework's rc.2 pack (unzipped in $W/packs-src, never changed) in $W/packs. "other-signer" is a copy whose
signature file is replaced by a valid SSH signature of its pack.json by another Ed25519 key (ssh-keygen,
namespace jetcarp-manifest), so the signature is well formed but not the publisher's.
"""
import json
import os
import shutil
import subprocess

import mcpc

W, J = mcpc.W, mcpc.J
log = open(os.path.join(mcpc.R, "5.0-prep.txt"), "w", encoding="utf-8")


def say(s):
    s = s.replace(W, "$W")
    print(s)
    log.write(s + "\n")
    log.flush()


def run(*args, **kw):
    p = subprocess.run([J, *args], env=mcpc.env(), capture_output=True, text=True, encoding="utf-8", errors="replace", **kw)
    say(f"$ jetcarp {' '.join(args)}\n{p.stdout.rstrip()}\n{p.stderr.rstrip()}\nexit {p.returncode}")
    return p


# Odd scenes
odd = os.path.join(W, "odd")
os.makedirs(odd, exist_ok=True)
good = {
    "format": 1,
    "name": "F9 good scene",
    "tiling": {"family": "square", "size": {"rect": {"w": 64, "h": 64}}, "boundary": "wrap"},
    "rng_state": 9,
    "cas": [{"id": 1, "name": "Life", "rule": "B3/S23", "seed": {"random": {"density": 0.3}}}],
}
with open(os.path.join(odd, "good.json"), "w", encoding="utf-8") as f:
    json.dump(good, f, indent=2)
run("run", os.path.join(odd, "good.json"), "--gens", "100", "--save", os.path.join(odd, "good-saved.json"))
raw = open(os.path.join(odd, "good-saved.json"), "rb").read()
open(os.path.join(odd, "truncated.json"), "wb").write(raw[:400])
s = json.load(open(os.path.join(odd, "good-saved.json"), encoding="utf-8"))
s["cas"][0]["rule"] = "B3/S23/Q9 Frobnicate"; s["name"] = "unknown rule"; s.pop("record", None); s["commands"] = []
json.dump(s, open(os.path.join(odd, "unknown-rule.json"), "w", encoding="utf-8"), indent=1)
s = json.load(open(os.path.join(odd, "good-saved.json"), encoding="utf-8"))
s["cas"][0]["rule"] = "Frobnicator"; s.pop("record", None); s["commands"] = []
json.dump(s, open(os.path.join(odd, "unknown-rule-name.json"), "w", encoding="utf-8"), indent=1)
s = json.load(open(os.path.join(odd, "good-saved.json"), encoding="utf-8"))
s["format"] = 2; s["jetcarp_version"] = "9.0.0"
json.dump(s, open(os.path.join(odd, "future-format.json"), "w", encoding="utf-8"), indent=1)
s["format"] = 99999999999
json.dump(s, open(os.path.join(odd, "future-format-huge.json"), "w", encoding="utf-8"), indent=1)
open(os.path.join(odd, "empty.json"), "wb").close()
say("odd scenes: " + ", ".join(sorted(os.listdir(odd))))

# Damaged packs: copies of the Framework's rc.2 F10-pack
P0 = os.path.join(W, "packs-src", "F10-pack")
packs = os.path.join(W, "packs")
os.makedirs(packs, exist_ok=True)
for n in ["good", "truncated", "onebyte", "unsigned", "truncated-manifest", "onebyte-part", "other-signer"]:
    d = os.path.join(packs, n)
    if os.path.exists(d):
        shutil.rmtree(d)
    shutil.copytree(P0, d)
f = os.path.join(packs, "truncated", "searches", "39fd769d-bfa3-492f-bcb3-1ffd617e203e", "runs", "part-000001.parquet")
with open(f, "r+b") as fh:
    fh.truncate(os.path.getsize(f) // 2)
with open(os.path.join(packs, "truncated-manifest", "pack.json"), "r+b") as fh:
    fh.truncate(300)
p = os.path.join(packs, "onebyte", "pack.json")
b = bytearray(open(p, "rb").read()); j = b.find(b'"title":"rc.2') + len(b'"title":"rc.'); b[j] = ord("3"); open(p, "wb").write(b)
p = os.path.join(packs, "onebyte-part", "tables", "rules", "part-000001.parquet")
b = bytearray(open(p, "rb").read()); b[len(b) // 2] ^= 1; open(p, "wb").write(b)
for root, _, files in os.walk(os.path.join(packs, "unsigned", "sigs")):
    for fn in files:
        os.remove(os.path.join(root, fn))
# other-signer
kdir = os.path.join(W, "other-key")
os.makedirs(kdir, exist_ok=True)
key = os.path.join(kdir, "id_ed25519")
if not os.path.exists(key):
    subprocess.run(["ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-C", "someone else", "-f", key], capture_output=True)
man = os.path.join(packs, "other-signer", "pack.json")
q = subprocess.run(["ssh-keygen", "-Y", "sign", "-n", "jetcarp-manifest", "-f", key, man], capture_output=True, text=True)
sigdir = os.path.join(packs, "other-signer", "sigs")
old = [fn for fn in os.listdir(sigdir) if fn.endswith(".sig")]
if q.returncode == 0 and old:
    shutil.move(man + ".sig", os.path.join(sigdir, old[0]))
    say(f"other-signer: sigs/{old[0]} replaced by a signature of pack.json by another key (ssh-keygen exit 0)")
else:
    say(f"other-signer: ssh-keygen failed (exit {q.returncode}): {q.stderr.strip()}")
say("packs: " + ", ".join(sorted(os.listdir(packs))))
log.close()
