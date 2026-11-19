# Logs of the November 2026 audit

| File | What it is |
|---|---|
| `harness-run.txt` | Output of the audit's harness (`../harness`) at `a3e829a`: the eleven `verified_*` suites pass, the three `finding_*` suites fail as the filed issues describe |
| `project-test-suite.txt` | The project's own test suite as the audit ran it: totals, each test binary, the one failure |
| `clippy-summary.txt` | Clippy's warnings by kind |
| `minimum-rust.txt` | Which toolchains load the workspace, and the check on 1.95 with the manifest change |
| `parity-300-cpu.csv`, `parity-5000-cpu.csv` | The published parity sets (`../../../v0.4.2/parity`) re-run on the audit machine's CPU: 371 scenes for 300 generations, 40 for 5,000 |
| `parity-300-swgpu.csv` | The 371 scenes on the CPU and on Mesa's llvmpipe (`JETCARP_GPU=software`) |
| `catagolue-comparison.txt` | Two soup hunts of Conway's Life against Catagolue's public census, object by object |

The scripts that made the parity and Catagolue files are in `../scripts`.
