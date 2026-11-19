# rc.4 pre-check on the Acer (NOTES 2026-11-16 7:25 PM EST): host.rs alone, serial, N times, straight after the RTX
# suite while the machine is warm, for #122 (host start straight after host stop). The same scratch folders as the
# suite. Each run's whole output is kept ($T2\logs\host-x10-<tag>\run-NN.txt) so a failure keeps its report.
# ASCII only. Output: $T2\logs\1-host-rs-<tag>-x10.txt.
param([string]$Tag = '29fea86', [int]$Runs = 10)
$ErrorActionPreference = 'Continue'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
$UTF8 = New-Object Text.UTF8Encoding $false
$T2 = "$env:USERPROFILE\jetcarp-rc4pre"
$SRC = "$env:USERPROFILE\jetcarp-rc-042c\src"
$LOG = "$T2\logs"
$RUND = "$LOG\host-x10-$Tag"
New-Item -ItemType Directory -Force $RUND | Out-Null
$OUT = "$LOG\1-host-rs-$Tag-x10.txt"
[IO.File]::WriteAllText($OUT, '', $UTF8)
function L([string]$msg) { $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg"; [IO.File]::AppendAllText($OUT, "$line`r`n", $UTF8); $line }
$env:JETCARP_CONFIG_DIR = "$T2\scratch-tests\config"; $env:JETCARP_DATA_DIR = "$T2\scratch-tests\data"; $env:JETCARP_OUT = "$T2\scratch-tests\out"; $env:JETCARP_RUNTIME_DIR = "$T2\scratch-tests\runtime"
Remove-Item Env:WGPU_BACKEND, Env:JETCARP_LIBRARY -ErrorAction SilentlyContinue
$env:JETCARP_GPU = 'RTX'
L "=== cargo test --release -p jetcarp --test host -- --test-threads=1, $Runs runs, src $(git -C $SRC log --oneline -1); $(& "$SRC\target\release\jetcarp.exe" --version)"
$pass = 0
for ($i = 1; $i -le $Runs; $i++) {
  $f = "$RUND\run-{0:d2}.txt" -f $i
  $t0 = Get-Date
  $p = Start-Process cmd -ArgumentList "/c cargo test --release -p jetcarp --test host -- --test-threads=1 > `"$f`" 2>&1" -WorkingDirectory $SRC -NoNewWindow -PassThru
  $null = $p.Handle
  if (-not $p.WaitForExit(900000)) { & taskkill /PID $p.Id /T /F | Out-Null; L ("run {0}: TIMEOUT after 15 min, killed" -f $i); continue }
  $txt = Get-Content $f -Encoding UTF8
  $res = ($txt | Select-String '^test result: .*' | ForEach-Object { $_.Line.Trim() }) -join ' '
  $failed = @($txt | Select-String '^test (\S+) \.\.\. FAILED' | ForEach-Object { $_.Matches[0].Groups[1].Value })
  $why = ($txt | Select-String 'panicked at .*|^(start|stop), round.*' | ForEach-Object { $_.Line.Trim() }) -join ' / '
  if ($p.ExitCode -eq 0 -and $failed.Count -eq 0) { $pass++ }
  L ("run {0}: exit {1} in {2:n0} s: {3}{4}" -f $i, $p.ExitCode, ((Get-Date) - $t0).TotalSeconds, $res, $(if ($failed.Count) { "; failed: $($failed -join ', '); $why" } else { '' }))
}
L "RESULT host.rs serial x$Runs on $Tag : $pass of $Runs passed"
L "jetcarp processes at the end: $((Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId) $($_.Name)" }) -join ' | ')"
"t1_host_x10 done"
