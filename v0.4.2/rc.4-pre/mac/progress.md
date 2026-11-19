# The rc.4 pre-check on the Mac (af07766)

| Step | Result | Notes |
|---|---|---|
| Build | pass | 81 s, no warnings; `--version` says 0.4.2-rc.3 |
| Seizure warning | pass | `setup --seizure-warning no-disorder` saved the answer, exit 0 |
| Doctor | pass | self-test passed (187 ms) |
| 1.1 Parity (Metal) | pass | 371/371 CPU and GPU; 334 all on the GPU; 74 s |
| 1.2 Long-run parity (Metal) | pass | 40/40 CPU and GPU at 5,000 gens, all on the GPU; 63 s |
| 1.3 Suite (Metal) | pass | 1,058 passed, 0 failed, 39 ignored, in 143 binaries; 10 min (6 new ignores: 3 Fit tests for #112, 3 app shots) |
| 1.5 Soak, 8 h | pass | 18:03 to 02:03 UTC; alive 97/97, one pid; footprint 211 MB first hour and last (−0.06 MB/h, one 233 MB sample); generation moved in 96/96 intervals; 240 of 240 gen/s; CPU 64.5%; never held; one scene ("A classic a day") |
| #95 Display sleep | pass | held within 15 s ("dark"), generation frozen, CPU 0.1%, footprint 51 MB; running again within 12 s of Jimmie's sign-in |
