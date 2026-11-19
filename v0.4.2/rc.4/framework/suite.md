# The suite on the Framework for rc.4

The plan's rule ("The suite (1.3)"): the pre-check's run on the branch counts for rc.4 if no Rust code changed between its commit and the tag other than the version bump.

The pre-check's last run was on **29fea86** (`results/v0.4.2-rc4-pre/framework/suite-*-29fea86.txt`):
- Radeon: 1,059 passed, 0 failed, 41 ignored.
- llvmpipe: 1,059 passed, 0 failed, 41 ignored.

The tag `v0.4.2-rc.4` is on **cf5cbdf**, whose only change from 29fea86 is the version (`Cargo.toml` and `Cargo.lock`, "Release 0.4.2-rc.4"). So that run is the Framework's suite for rc.4.
