# rc.5's before-the-tag check on the Mac: #131 (NOTES, 2026-11-17 5:14 AM; `v0.4.2-rc.5.md`, "Before the tag", step 3)

MacBook Pro M2 Max, macOS 27.2.1, the built-in display. `rc5-fixes` at **c976627** (#124), built in
`~/jetcarp-rc-042c/src` (`cargo build --release -p jetcarp`: exit 0 in 41 s, no warnings; `build.txt`) and copied to
`~/jetcarp-rc4/rc5/jetcarp`. `--version` still says 0.4.2-rc.4, as the branch's crates do until the bump. The app ran
in a test folder of its own, `~/jetcarp-rc4/homes/app131` (the warning answered and setup done there), with Jimmie at
the Mac. Script: `t131_cmdm.py` (rc.4's R4 #87 scripts, three cycles in one session).

## #131, ⌘M then a restore: pass (`131-cmdm.txt`, `.json`, `.jsonl`)

A 512 x 512 Life world at speed 30, `world_status` through `jetcarp mcp --app` every 2 s, the window's on-screen flag,
and, while the window was back, a capture of it every 2 s by its id, compared with the one before.

| Cycle | Minimised | After the restore | Jimmie |
|---|---|---|---|
| 1. **⌘M**, 32 s | 16 polls, all answered, 30.1 gens/s, CPU 3% | **8 of 8 captures changed**, 30.1 gens/s, CPU 39% | "it moved" |
| 2. **The yellow button**, 24 s | 12 polls, 30.2 gens/s, CPU 5% | 6 of 6 changed, 30.0 gens/s, CPU 46% | "it moved" |
| 3. **⌘M**, the world paused (by the script, as cycle 3 began), 26 s | 13 polls, 0 gens/s | a zoom at +10 s and a pan at +20 s: 15 of 15 changed, CPU 14% | "It scrolled and panned" |

- **The toolbar's generation matches `world_status`:** the capture 4 s after the first restore shows "gen 2682"
  (`131-r1-004s.jpg`), taken 0.2 s after `world_status` said 2,676 (30 a second). On rc.4 the toolbar stayed at the
  generation of the ⌘M (#87's run 2: "gen 1273" against 4,214).
- rc.4's freeze is gone: after ⌘M and a restore the window draws again at once, as after the yellow button.
- (Jimmie read the pause in cycle 3 as the restore stopping it; the script paused the world 14 s after the second
  restore, which fell as Jimmie pressed ⌘M.)

## The unit test: passes with --release; panics in a debug build (`131-unit-test-debug.txt`)

- `cargo test -p jetcarp-app cmd_m_minimises`, as the plan writes it (a debug build): **FAILED**. Not on its
  assertions, which pass: the test then drops egui's output, and epaint 0.37 panics on dropping it ("Dropped
  TexturesDelta with 1 unapplied deltas. Deltas need to be handled. If you want to drop this intentionally call `clear`
  before dropping.", `epaint-0.37.0/src/textures.rs:337`), a `debug_assert!`.
- `cargo test --release -p jetcarp-app cmd_m_minimises`: **ok**. CI (`ci.yml` line 72, `release.yml` line 173) and the
  suite run the tests with `--release`, so they pass it.
- So a test fix, not a #131 fix: clear `out.textures_delta` (or the whole output) before it's dropped. Then the plan's
  command passes too.

Captures: three kept as JPEG (`131-r1-004s`, `131-r2-004s`, `131-r3-014s`); every capture's sha256 in
`131-captures.sha256`.
