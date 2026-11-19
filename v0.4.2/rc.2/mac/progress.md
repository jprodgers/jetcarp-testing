# v0.4.2-rc.2 on the Mac

| Step | Result | Notes |
|---|---|---|
| 0 Unpack, first doctor | pass | tar.gz sha256 f318a493… matches; `jetcarp 0.4.2-rc.2`; first doctor on the fresh folder: "passed (372 ms): 59 world rules …", saved, then "kept from before" (#17 fixed). Kept for 2.0 (`0-doctor-first.txt`) |
| 1.1 Parity (Metal) | pass | 371/371 CPU and GPU; 334 all on the GPU; 71 s |
| 1.2 Long-run parity (Metal) | pass | 40/40 CPU and GPU at 5,000 gens, all on the GPU; 64 s |
| 1.3 Test suite (Metal) | pass | tag 2d4b84c, `cargo test --release --workspace --no-fail-fast`: 991 passed, 0 failed, 33 ignored (screenshots, offscreen windows, timings, heavy); 11.5 min |
| 1.4 Long search, crash, resume, pack | pass except #49, #51, #53 | 272,936 runs in the first hour; never 0/s (median 75/s). `kill -9` at 60 min → `jobs wait` 6 after 45 s, `jobs status` still "running" (#49). Resume with no `--minutes` ran on (#51) to the script's 4 h cap: 1,120,514 + 17,733 confirmation runs. Memory 5.5 GB at the kill, 7.5 GB at the end, rising (#53). Unsealed pack sealed its newest 138,247 runs itself; 85 MB; import has every run (#35 pass); imported line "3,314 confirmed" vs 3,321 |
| 1.5 Desktop overnight | not run | needs 8 idle hours; Jimmie starts it |
| 1.6 Deterministic hunt | pass | 1,783 distinct, 760,892 objects; `finds` identical to the Framework's and the Acer's |

Next: Phase 2, sitting M-1 (2.0, 2.G1, 2.1–2.4) after the Acer's block. 1.5 when the Mac has 8 idle hours (Jimmie starts it).
