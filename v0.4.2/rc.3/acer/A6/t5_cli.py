"""A-6 (the Acer) Part 5, the command-line steps (the Mac's t5_cli.sh in Python for Windows).

5.1 odd scenes and damaged packs (made by t5_prep.py); 5.3 limits: the largest world on each GPU (the RTX and the
UHD) and on the CPU, with wall time and peak memory, and one cell more refused; 5.5 a read-only output folder
(write denied with icacls, as in t55_readonly.py).
"""
import ctypes
import ctypes.wintypes as wt
import json
import os
import subprocess
import sys
import time

import mcpc

ONLY = sys.argv[1] if len(sys.argv) > 1 else None  # "5.5": only the read-only part (rerun after run 1's icacls slip)

W, J = mcpc.W, mcpc.J
USER = os.environ["USERNAME"]
CWD = os.path.join(W, "cwd")
os.makedirs(CWD, exist_ok=True)


class PMC(ctypes.Structure):
    _fields_ = [("cb", wt.DWORD), ("PageFaultCount", wt.DWORD), ("PeakWorkingSetSize", ctypes.c_size_t),
                ("WorkingSetSize", ctypes.c_size_t), ("QuotaPeakPagedPoolUsage", ctypes.c_size_t),
                ("QuotaPagedPoolUsage", ctypes.c_size_t), ("QuotaPeakNonPagedPoolUsage", ctypes.c_size_t),
                ("QuotaNonPagedPoolUsage", ctypes.c_size_t), ("PagefileUsage", ctypes.c_size_t),
                ("PeakPagefileUsage", ctypes.c_size_t), ("PrivateUsage", ctypes.c_size_t)]


def mem(handle):
    c = PMC()
    c.cb = ctypes.sizeof(PMC)
    ok = ctypes.windll.kernel32.K32GetProcessMemoryInfo(wt.HANDLE(int(handle)), ctypes.byref(c), c.cb)
    return (c.PeakWorkingSetSize, c.PeakPagefileUsage) if ok else (0, 0)


def run(out, args, extra_env=None, timeout=900, measure=False):
    e = {**mcpc.env(), **(extra_env or {})}
    t0 = time.time()
    p = subprocess.Popen([J, *args], env=e, cwd=CWD, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
                         encoding="utf-8", errors="replace")
    peak = (0, 0)
    try:
        so, _ = p.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        p.kill()
        so, _ = p.communicate()
        so += f"\n[killed after {timeout} s]"
    if measure:
        peak = mem(p._handle)
    wall = time.time() - t0
    envs = " ".join(f"{k}={v}" for k, v in (extra_env or {}).items() if k.startswith(("JETCARP_GPU", "WGPU")))
    s = f"$ {envs + ' ' if envs else ''}jetcarp {' '.join(args)}\n{so.rstrip()}\nexit {p.returncode}"
    if measure:
        s += f"   [wall {wall:.1f} s, peak working set {peak[0] / 2**30:.2f} GB, peak private {peak[1] / 2**30:.2f} GB]"
    s = s.replace(W, "$W")
    print(s)
    out.write(s + "\n")
    out.flush()
    return p.returncode


odd = os.path.join(W, "odd")
packs = os.path.join(W, "packs")


def part55():
    """5.5 a read-only output folder on the command line."""
    RO = os.path.join(W, "ro-out-cli")
    os.makedirs(RO, exist_ok=True)
    with open(os.path.join(odd, "tiny.rhai"), "w") as f:
        f.write('let w = world(#{ tiling: "square", size: [32, 32] }); w.add_ca("Life", #{ seed: "random:0.3" }); w.step(5); w.save_png("tiny.png", #{ size: [64, 64] }); print("saved");\n')
    with open(os.path.join(mcpc.R, "5.5-readonly-cli.txt"), "w", encoding="utf-8") as out:
        p = subprocess.run(["icacls", RO, "/deny", f"{USER}:(OI)(CI)(WD,AD,WEA,WA)"], capture_output=True, text=True)
        out.write(f"(JETCARP_OUT=$W\\ro-out-cli, write denied with icacls (OI)(CI)(WD,AD,WEA,WA): exit {p.returncode})\n")
        ro = {"JETCARP_OUT": RO}
        good = os.path.join(odd, "good.json")
        try:
            run(out, ["script", os.path.join(odd, "tiny.rhai")], extra_env=ro)
            run(out, ["script", "--example", "hexw-all"], extra_env=ro)
            run(out, ["pile", "--grains", "1000"], extra_env=ro)
            run(out, ["wallpaper", good, "--size", "320x200"], extra_env=ro)
            run(out, ["wallpaper", "life", "--size", "320x200"], extra_env=ro)
            run(out, ["media", "render", "--scene", good, "--gens", "5"], extra_env=ro)
            run(out, ["run", good, "--gens", "5", "--png", os.path.join(RO, "x.png")], extra_env=ro)
            out.write(f"(left in the folder: {os.listdir(RO)})\n")
        finally:
            p = subprocess.run(["icacls", RO, "/remove:d", USER], capture_output=True, text=True)
            out.write(f"(icacls /remove:d: exit {p.returncode})\n")


if ONLY == "5.5":
    part55()
    sys.exit(0)

# 5.1 odd scenes
with open(os.path.join(mcpc.R, "5.1-scenes-cli.txt"), "w", encoding="utf-8") as out:
    for f in ["truncated", "unknown-rule", "unknown-rule-name", "future-format", "future-format-huge", "empty"]:
        run(out, ["run", os.path.join(odd, f + ".json"), "--gens", "10"])
        run(out, ["verify", os.path.join(odd, f + ".json")])

# 5.1 damaged packs on the command line
imp = os.path.join(W, "import-lib")
os.makedirs(imp, exist_ok=True)
with open(os.path.join(mcpc.R, "5.1-packs-cli.txt"), "w", encoding="utf-8") as out:
    for n in ["good", "truncated", "truncated-manifest", "onebyte", "onebyte-part", "unsigned", "other-signer"]:
        out.write(f"\n#### {n}\n")
        run(out, ["pack", "info", os.path.join(packs, n)])
        run(out, ["pack", "check", os.path.join(packs, n)], timeout=600)
        run(out, ["pack", "--library", os.path.join(imp, f"{n}.sqlite"), "import", os.path.join(packs, n)], timeout=600)
    out.write("\n#### unsigned, with --allow-unsigned\n")
    run(out, ["pack", "--library", os.path.join(imp, "unsigned-allowed.sqlite"), "import", os.path.join(packs, "unsigned"), "--allow-unsigned"], timeout=600)

# 5.3 limits: the program's lattice limit is 256,000,000 cells
lim = os.path.join(W, "limits")
os.makedirs(lim, exist_ok=True)


def mk(name, size):
    json.dump({"format": 1, "name": name, "tiling": {"family": "square", "size": size, "boundary": "wrap"}, "rng_state": 5,
               "cas": [{"id": 1, "name": "Life", "rule": "B3/S23", "seed": {"random": {"density": 0.3}}}]},
              open(os.path.join(lim, name + ".json"), "w"), indent=1)


mk("max-16000x16000", {"rect": {"w": 16000, "h": 16000}})
mk("over-16001x16000", {"rect": {"w": 16001, "h": 16000}})
mk("over-37x6918919", {"rect": {"w": 37, "h": 6918919}})  # the smallest rect over 256M (256,000,001 is prime)
mk("over-cells-256000001", {"cells": 256000001})
with open(os.path.join(mcpc.R, "5.3-over-limit.txt"), "w", encoding="utf-8") as out:
    for f in ["over-16001x16000", "over-37x6918919", "over-cells-256000001"]:
        run(out, ["run", os.path.join(lim, f + ".json"), "--gens", "1", "--gpu"], extra_env={"JETCARP_GPU": "RTX"})
with open(os.path.join(mcpc.R, "5.3-max-world.txt"), "w", encoding="utf-8") as out:
    mx = os.path.join(lim, "max-16000x16000.json")
    run(out, ["run", mx, "--gens", "20", "--gpu"], extra_env={"JETCARP_GPU": "RTX"}, measure=True)
    run(out, ["run", mx, "--gens", "20", "--gpu"], extra_env={"JETCARP_GPU": "UHD"}, measure=True)
    run(out, ["run", mx, "--gens", "20", "--cpu", "--threads", "12"], measure=True)

part55()
