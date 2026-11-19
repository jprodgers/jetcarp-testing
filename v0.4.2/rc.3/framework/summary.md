# v0.4.2-rc.3 Phase 1 on the Framework

Run by `~/Documents/jetcarp-dev/work/0.4.2-rc3/phase1.sh`, 7:01 PM to 11:07 PM EST, 2026-11-15. The rc.3 Linux
build (`5199040f…7179d539`). Every folder was under the work folder (`JETCARP_CONFIG_DIR`, `_DATA_DIR`, `_OUT`,
`_RUNTIME_DIR`); nothing touched the real settings, library or pictures.

| Step | Result | Notes |
|---|---|---|
| F1 version, doctor | pass | `jetcarp 0.4.2-rc.3`; first doctor ran the self-test, the second kept it |
| #48 doctor with `JETCARP_GPU=llvmpipe` | pass | tests llvmpipe only; the Radeon's GL adapter is listed with no failure |
| #21 `JETCARP_GPU=nosuchgpu` | pass | says no such adapter was found and uses the best one |
| 1.1 parity, 371 scenes | pass | 371/371 CPU and GPU, on the Radeon and on llvmpipe |
| 1.2 long parity, 40 × 5,000 | pass | 40/40, all on the GPU, on both |
| 1.6 hunt | pass | 1,783 distinct, 760,892 objects, identical to the Mac and the Acer |
| 1.4 #49 status after `kill -9` | pass | `stale` 2 s after the kill, resumable |
| 1.4 #50 `jobs wait` after `resume --detach` | pass | exit 5 (still running) |
| 1.4 #51 resume with no budget | pass | "2 h 59 min left of its 4 h 0 min"; it ended at 3 h 59 min in all |
| 1.4 #53 memory | pass | 2.2 GB at 1 h, 2.5 GB at 2 h, 3.1 GB at 3 h, 3.6 GB at 4 h, for 2.1M runs (rc.2's A/B: 4.7 GB at 1.06M runs before the fix, 2.55 GB after) |
| 1.4 #54 pack and import | pass | 4,943 confirmed and 66,570 elites on both sides; 2,111,460 runs imported |

**New: #81 (0.4.3).** After the resume, five 5-minute readings jumped to 5–6.3 GB and fell back by the next. None
in the first hour. `--max-rss-gb` stops at the first reading over the cap, so a cap near the steady level would
pause the search at a peak.
