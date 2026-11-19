# #69 check: host memory over three Fit sweeps, same load

Private headless GNOME 51 shell as in FD. Both runs were under the same load (the #53 A/B's two
explores were running), so both sweeps ended at 8 px.
- `fd4-run.log`: rc.2's host.
- `fd3-run.log`: the build with malloc_trim after a sweep (commit 0b18ca5).

| | wallpaper on | after tune | after pick own | after pick 3 |
|---|---|---|---|---|
| rc.2 | 111 MB | 141 MB | 312 MB | 376 MB |
| fix | 112 MB | 129 MB | 151 MB | 157 MB |

The real GNOME keys were unchanged in both runs.
