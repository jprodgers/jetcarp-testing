# rc.5 before the tag: the suite on the Framework (2026-11-17, 5:13–5:18 AM EST)

**Pass.** `cargo test --workspace --release --no-fail-fast` on `rc5-fixes` at **c976627** (rc.4's
cf5cbdf and the seven rc.5 fixes), in a scratch home (`env.sh suite5`: every `JETCARP_*` folder, `HOME`
and the XDG folders under `$W4/homes/suite5`), on the Radeon 8060S:

- **1,065 passed, 0 failed, 41 ignored**, in 143 test binaries; no build warnings.
- The new tests ran and passed:
  - `term::tests::the_line_is_erased_with_the_code_or_with_spaces` (#127);
  - `host_cmd::tests::a_login_item_s_missing_folders_are_named` (#124);
  - `docs::tests::entities_become_characters_outside_code` and `pages_are_served_without_html_entities` (#126);
  - `stdio::tests::an_unknown_action_is_refused_naming_the_actions` (#125);
  - (private) the hidden-store test.
- The macOS-only test of #131 (`cmd_m_minimises_through_appkit_not_egui`) runs on the Mac and CI's macOS job.
- Also clean: `gen-mcp.py --check`, `gen-cli.py --check`, `copy-mcp-resources.py --check` and `cargo fmt --check`.

`suite-tests.txt` lists every test line.
