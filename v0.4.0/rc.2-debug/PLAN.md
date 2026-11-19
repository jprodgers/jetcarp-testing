# Before rc2: a Windows-only host problem to pin down (Acer)

GitHub's Windows CI shows one problem that only a real Windows machine can pin down. Please run
this on the Acer before the rc2 tests. It needs Rust (the Acer has it) and about 20 minutes, most
of it building.

## What CI shows

`jetcarp host start --headless` starts the background host through `jetcarpw.exe`, using new
launch code (`spawn_detached` in `crates/jetcarp-display/src/autostart.rs`: `CreateProcessW` with
only the null device inherited, so a pipe around `host start` no longer hangs). The host answers
that it is running, but the next `jetcarp host status` gets "connection forcibly closed" (10054),
and the host's process is gone.

A host started directly (`jetcarp host serve --headless`) keeps running. Its exit crash
(0xC0000005) is fixed on main by touching nothing on the GPU at exit.

## Steps

In PowerShell, not as administrator:

```powershell
cd $env:TEMP
git clone https://github.com/jprodgers/jetcarp jetcarp-debug
cd jetcarp-debug
cargo build --release --features jetcarp/windows-launcher
# Keep everything away from the real folders:
$d = "$env:TEMP\jetcarp-debug-home"; New-Item -ItemType Directory -Force $d | Out-Null
$env:JETCARP_CONFIG_DIR = "$d\config"; $env:JETCARP_DATA_DIR = "$d\data"
$env:JETCARP_OUT = "$d\out"; $env:JETCARP_LIBRARY = "$d\library"; $env:JETCARP_RUNTIME_DIR = "$d\run"
```

1. **The test.**
   `cargo test --release --features jetcarp/windows-launcher -p jetcarp --test host -- host_start runs_scenes --nocapture`.
   Save the output to `results/rc2-debug/acer/01-tests.txt`.
2. **By hand.**
   `.\target\release\jetcarp.exe host start --headless`, then `.\target\release\jetcarp.exe host status`,
   then `Get-Process jetcarp*`. Is the host still running? Save the output.
3. **If it died:** open Event Viewer → Windows Logs → Application, and look for "Application Error"
   or "Windows Error Reporting" entries for `jetcarp.exe` at that time. Copy the faulting module
   name, exception code and offset into `results/rc2-debug/acer/03-crash.txt`.
4. **Without `--headless`:** `.\target\release\jetcarp.exe host start`, then status, then stop. Does
   this host live?
5. **Through the old way:** `.\target\release\jetcarpw.exe host serve --headless` started from
   Explorer or `Start-Process`. Does a host started like that live?
6. **Clean up:** `.\target\release\jetcarp.exe host stop`, and remove `$env:TEMP\jetcarp-debug*`.

Push the results and a short note in `NOTES.md`. The main session decides from them whether rc2
keeps the new launch code or goes back to rc1's.
