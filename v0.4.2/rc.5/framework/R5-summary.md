# R5 on the Framework: rc.5's release build (2026-11-17, from 7:31 AM EST)

`jetcarp 0.4.2-rc.5` from the pre-release's Linux archive (its sha256 matches `SHA256SUMS`), in scratch homes under
`$W5/homes` (every `JETCARP_*` folder, `HOME` and the XDG folders). Script: `R5-scripts/r5_cli_mcp.sh`; output:
`R5-cli-mcp.txt`.

| # | Check | Result |
|---|---|---|
| 128 | `host tune --help` and `host help tune` | **pass**: each prints only "Fit to this computer isn't in JETCARP 0.4.2: it returns, faster, in 0.4.3. Each scene shows at its own size." (exit 0); `host tune` refuses with it (exit 1) |
| 126 | Book pages over MCP | **pass**: `help {"page": "reference/mcp"}` and `resources/read jetcarp://docs/reference/mcp` read `L<level>` and `find:<id>`, with no `&lt;` left |
| 125 | `host_control`: an unknown action; `resume` before the warning | **pass**: `{"action": "start"}` refused, naming the twelve actions, before and after the warning is answered; with the warning unanswered, `wallpaper` is refused with the warning, and `resume` reaches the host ("not running"), as `jetcarp host resume` does |
| 124 | `host login on` with `JETCARP_*` set | **pass**: "note: the login item starts the host with the default folders; JETCARP_CONFIG_DIR, …, JETCARP_OUT are not passed on to it"; the entry written in this home's XDG folder, then removed |
| — | (private) see the withheld files | (private) see the withheld files |
