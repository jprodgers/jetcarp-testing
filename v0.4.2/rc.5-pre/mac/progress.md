# rc.5's before-the-tag check on the Mac (rc5-fixes, c976627)

| Step | Result | Notes |
|---|---|---|
| Build | pass | 41 s, no warnings; `--version` says 0.4.2-rc.4 until the bump |
| #131 ⌘M, then a restore | pass | draws again at once (8 of 8 captures changed), the toolbar's generation matching `world_status`; the yellow button the same; paused: zoom and pan draw |
| #131's unit test | pass with --release; FAILS in debug | the assertions pass; epaint's debug-only drop check panics (the test should clear the textures delta) |
