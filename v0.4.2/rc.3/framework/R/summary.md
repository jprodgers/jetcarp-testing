# R on the Framework (rc.3): a check of every fix, the unattended rows

Run 1:02–1:15 AM EST, 2026-11-16, with rc.3's Linux build, every folder under
`~/Documents/jetcarp-dev/work/0.4.2-rc3/r/` (`JETCARP_CONFIG_DIR`, `_DATA_DIR`, `_OUT`, `_LIBRARY`,
`_RUNTIME_DIR`). The MCP scripts are rc.2's F9 ones, pointed at rc.3 (`mcpc.py`, `t4*.py`, `t5*.py`). The
command-line rows are `r_cli.sh`, `r66.sh` and `r-56.txt`.

| # | Check | Result | Evidence |
|---|---|---|---|
| 47 | `search explore --help`: `--limit` says an explore finishes its step | pass | `r-cli.txt` |
| 48 | doctor with `JETCARP_GPU=llvmpipe`: no Radeon GL failure | pass | `../F1-doctor-llvmpipe.txt` |
| 49–51, 53, 54 | in 1.4 | pass | `../summary.md` |
| 56 | `jobs clips --sample 48` on a 4-minute JACA search | pass | "categories: Battles 46, Frozen at once 2" (`r-56.txt`) |
| 57 | `pack export` refuses a running search, leaves no folder | **pass, with a straggler (fixed)** | refused, no `--to` folder; but the hidden `.<name>.store` beside it was left, empty. Fixed for rc.4 in efe1a03 (a regression from my rc.3 merge); #57's test now checks it |
| 63 | MCP `world_new` over 4,000,000 cells | pass | "4096 x 4096 on trihex is 50,331,648 cells … (try 1154 x 1154)" (`5.3b-mcp-over-limit.txt`) |
| 64 | the MCP server's own search left paused at exit | pass | "hunt 5 is paused", `jobs wait` exit 3 (`4.4b-in-server-job.txt`) |
| 65 | read-only output folder: "Permission denied" in every MCP tool | pass | 10 of 10 writing tools name the path with "Permission denied (os error 13)" (`5.5-readonly-mcp.txt`, run against a real 555 folder) |
| 66 | tampered pack: signature doesn't verify; unsigned refusal names `--allow-unsigned` | pass | `r-66.txt` |
| 67 | a malformed rule names its CA and file; a read-only library reads | pass | "bad-rule.json: CA 1 'Lifeish': rule 'B3/S23/Q9 Frobnicate': …"; `library list` on a 444 file works; MCP writes say it is read-only |
| 68 | MCP argument errors name the argument | pass | "`threads` must be at least 0 (got -1)", "help: `topic` must be text (got 5)" (`4.3-bad-input.txt`) |
| — | (private) a symlink in the output folder | pass | refused, the file outside untouched (`4.2b-symlink.txt`) |

Not unattended (left for F-1 to F-3 with Jimmie): #58–#62 (the app) and #69–#76, #78 (the desktop).
#73 is covered by the cards check (`NOTES.md`, 11:15 PM). #52 is the Acer's.

Notes:
- `t42_folders.py`'s `--allow` reads said "No such file": rc.2's step made the files by hand. The guard let the reads through, which is what matters.
- `t55_readonly.py`'s first run made its folder writable (rc.2 made it 555 in a separate step); rerun against `ro-out-555`.
