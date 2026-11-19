# The Framework: rc.4 pre-check on `release-0.4.2` (af07766)

2026-11-16, 12:34–12:49 PM EST. A local release build of af07766 (it reports `0.4.2-rc.3`; the
version bump comes at the tag). Scratch folders with every `JETCARP_*` set.

| Check | Radeon 8060S (RADV, Vulkan) | llvmpipe (Vulkan) |
|---|---|---|
| 1.1: 371 scenes × 300 generations | CPU 371/371, GPU 371/371, 334 wholly on the GPU | CPU 371/371, GPU 371/371, 334 wholly on the GPU |
| 1.2: 40 scenes × 5,000 generations | 40/40, all 40 wholly on the GPU | 40/40, all 40 wholly on the GPU |
| 1.3: the suite (`cargo test --release --workspace --no-fail-fast`) | 1,059 passed, 0 failed, 39 ignored | 1,059 passed, 0 failed, 39 ignored |

Both `expected.csv` files stand. Files: `log.txt`, `1.1-*.csv`, `1.2-*.csv`, `suite-*.txt`,
`run-output.txt`.

## The suite again on 29fea86 (8:05 PM EST)

#122 changed `host stop` on every system, so the suite ran again on the branch head:
- **Radeon:** 1,059 passed, 0 failed, 41 ignored.
- **llvmpipe:** 1,059 passed, 0 failed, 41 ignored.

The two ignored tests more than on af07766 are the book's new screenshot tests from d8ed2fb (`shots_ai_control`, `offscreen_setup_wizard_running`). Parity stands from af07766, since nothing since then touches stepping. Outputs: `suite-radeon-29fea86.txt` and `suite-llvmpipe-29fea86.txt`.
