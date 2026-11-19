# F9 on the Framework: Part 4 (MCP) and Part 5 (robustness), v0.4.2-rc.2

Sun Nov 15, 12:49–13:05 EST. Run by a helper session with the F9 folders under
`~/Documents/jetcarp-dev/work/0.4.2-rc2/f9/` (`$W` below) and a test publisher key. Nothing in the real
settings, library, host, app or GNOME was touched. The main session re-ran F1 and F2 by hand and got the
same results.

| Step | Result | Key evidence |
|---|---|---|
| 4.1 Every tool once | pass | 18 of 21 tools, `resources/list` (116) and `resources/read`; server exit 0, no stderr (`4.1-every-tool.txt`) |
| 4.1 host_control, app_display, use_app | skipped | Left for FD and F7 |
| 4.2 Outside paths refused | pass | Absolute, `../`, `/tmp`, not-yet-allowed: every write and read refused, naming the allowed folders (97 calls) |
| 4.2 `--allow DIR` | pass | Allowed folder works; other outside paths still refused |
| 4.2 A symlink inside the output folder | **fail** | 15 of 16 write tools write through it, and reads go through too; only `files_list` refuses (private advisory) |
| 4.3 Bad input | pass, rough edges | 124 bad calls and 8 protocol oddities: no crash, server stayed up (#68) |
| 4.4 A search outlives the MCP process | pass | Detached hunt (job 4) and default explore (job 5) ran as `jobs resume N` and kept going after the server exited; stopped from a new MCP session and from the CLI |
| 4.4b A job on the server's own thread at exit | **fail** | Left `running`, later `stale`; `jobs status` and MCP `job_status` still say running (#64) |
| 5.1 Odd scenes | pass | Truncated, unknown rule, future `format`, `format` beyond u32, empty file: clear errors, exit 1, via `run`, `verify`, MCP `world_new` and `media_render` (one weak message: #67) |
| 5.1 Odd packs | pass | Truncated part, truncated manifest, one byte in the manifest (signature fails even with `--allow-unsigned`), one byte in a part, unsigned and other-signer refused; unsigned imports with `--allow-unsigned`. Same through MCP. The original F10-pack unchanged. Rough edges #66 |
| 5.2 Two programs on one library | pass | CLI explore (job 10) and MCP hunt (job 11) at once; both listings saw both; MCP `job_stop 10` ended the CLI process in 1.8 s; `jobs stop 11` paused the MCP job. App part left for F7 |
| 5.3 Largest world on the GPU | pass | The program's own limit (256,000,000 cells) binds before the GPU's (2 GiB buffers). 16000×16000 on the GPU: 20 generations in 2.5 s, max RSS 1.74 GB, hash `cc44c111d4811d0e`, same as `--cpu` |
| 5.3 One cell over the limit | pass (CLI); **fail** (MCP) | CLI refuses 16001×16000 and 37×6918919: "grid is larger than 256 million cells". MCP `world_new` with width and height skips its 4,000,000-cell limit (#63) |
| 5.3 64M host world; 5.4 driver reset | skipped | Host left for FD; 5.4 is Windows only |
| 5.5 Read-only output folder | pass (CLI); partly fail (MCP) | CLI gives "Permission denied" naming the folder; 4 MCP tools blame the folder rule and name a `.keep` probe file (#65) |
| Extra: read-only library | rough edge | Can't even be read: "attempt to write a readonly database" (#67) |

Notes (not bugs):
- `publish` always signs (an empty settings folder makes a key), so the unsigned packs were made by emptying `sigs/`
  in a copy, and by signing a copy with another key; both are refused.
- A scene asking for `{"cells": 256000001}` gets 16000×16000 (256,000,000 cells): `cells` is approximate.
- `run_script out_dir("/abs/path")` makes a safely named folder inside the output folder, not that path.

Files:
- **Client:** `mcpc.py`
- **MCP tests:** `t41_every_tool.py`, `t42_folders.py`, `t42b_symlink.py`, `t43_bad_input.py`, `t43b_followups.py`,
  `t44_long_job.py`, `t44b_in_server_job.py`, `t51_mcp_odd.py`, `t52_two_programs.py`, `t53_mcp_limits.py`,
  `t53b_mcp_over.py`, `t55_readonly.py`
- **CLI steps of part 5:** `t5_cli.sh`
- **Results:** `4.x-*.txt` and `5.x-*.txt`; one line per call in `4.2-summary.txt` and `4.3-summary.txt`
- **Transcripts:** `*.jsonl`
