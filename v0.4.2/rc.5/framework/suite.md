# The suite and parity on rc.5 (the Framework, 2026-11-17, 8:48–8:59 AM EST)

Run on the host (`R5-scripts/host-suite-parity.sh`), in a scratch home, with Jimmie's session in front. The earlier
7:32 run had no GPU (`no-gpu-0732/`), and the VS Code sandbox still found no Vulkan device after the session came back.

- **The suite on the tag `v0.4.2-rc.5` (c0db1ab):** 1,065 passed, 0 failed, 41 ignored, no build warnings, on the
  Radeon 8060S (`suite-tests.txt`).
- **Parity with the release build** (sha256 `68c920e4…`, as `SHA256SUMS`; `log.txt`):
  - 1.1, 371 scenes × 300 generations: 371/371 CPU and GPU on the Radeon (Vulkan), and the same on llvmpipe;
  - 1.2, 40 scenes × 5,000 generations: 40/40 on both.
