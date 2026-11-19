# Parity set for v0.4.2-rc.1

Every built-in Quick Start scene of JETCARP 0.4.2 (`scenes/<n>.json`, `scenes/index.json` gives
each one's Quick Start id), with the Framework's CPU hash after 300 generations in `expected.csv`.

- **The check:** each machine runs every scene on its own CPU (`--cpu`) and its own GPU (`--gpu`), and
  both hashes must equal `expected.csv`.
- **Runners:** `parity.py` (Linux, macOS; Python 3, standard library) and `parity.ps1` (Windows
  PowerShell). Set `JETCARP_GPU` first to choose an adapter (`RTX`, `UHD`, …).
- **`expected.csv` was made with the candidate itself,** v0.4.2-rc.1's Linux build
  (`jetcarp-0.4.2-rc.1-x86_64-unknown-linux-gnu.tar.gz`, SHA-256 ef294524…), on the Framework's CPU:
  364 scenes. On the Framework's Radeon, 327 run all 300 generations on the GPU, 1 partly, and 36 are
  CPU-only, with 0 mismatches. The development build gave the same 364 hashes.
- **Scenes 364–370: sandpiles that drop grains** (added after rc.1's wave, for
  [#20](https://github.com/jprodgers/jetcarp/issues/20): drops ran wrong on the Intel UHD's GPU and
  no scene had one). These are the Acer's six G2 drop scenes and one whose drop saturates the centre
  cell. Their CPU hashes come from the development build on the Framework and equal the Acer's from
  the rc.1 Windows build. On the UHD's GPU, rc.1 fails 365–369 (the Acer's G2).
- **rc.2 (2026-11-15):** v0.4.2-rc.2's Linux build (SHA-256 29279d2a…) gives every one of the 371
  hashes on the Framework's CPU, so `expected.csv` stands as it is. Its Radeon and llvmpipe also match
  all 371, with all 300 generations on the GPU in 334.

## `long/`: long-run parity (rc.2)

40 of the scenes, spread across the named classics, B/S rules, JACA, tilings, sandpiles and two
drop scenes, chosen among those that are quick on the CPU. `long/expected.csv` holds each one's CPU
hash after **5,000 generations**. Run `parity.py <jetcarp> long <out.csv> --gens 5000` (Windows:
`parity.ps1 … -Gens 5000`). The first `expected.csv` was made with the development build of the rc.2
commit (51a1428) on the Framework, where the Radeon also matched 40 of 40, all on the GPU. v0.4.2-rc.2's
Linux build (`jetcarp-0.4.2-rc.2-x86_64-unknown-linux-gnu.tar.gz`, SHA-256 29279d2a…) gives the same 40
hashes on the Framework's CPU, so the file stands as it is.
