# v0.4.2-rc.3, Phase 1 follow-up on the Acer: #52's UHD hang (1 of 30 in phase1.ps1, at "running 2 tests").
# 30 more UHD runs of the recovery test with --test-threads=1, so libtest names each test before it runs it and
# a hang shows which test. On a hang, sample the test process's CPU time and threads twice (spinning or blocked),
# then kill the tree. Same scratch folders and build as phase1.ps1.
# Variable names: never $t, $j, $r (they'd clobber $T, $J, $R).
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
$UTF8 = New-Object Text.UTF8Encoding $false
$T = "$env:USERPROFILE\jetcarp-rc-042c"
$LOG = "$T\logs"; $OUTD = "$LOG\1.3-52b"
New-Item -ItemType Directory -Force $OUTD | Out-Null
$MAIN = "$LOG\phase1b.log"
function L([string]$msg) { [IO.File]::AppendAllText($MAIN, "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg`r`n", $UTF8) }
$env:JETCARP_CONFIG_DIR = "$T\scratch-tests\config"; $env:JETCARP_DATA_DIR = "$T\scratch-tests\data"; $env:JETCARP_OUT = "$T\scratch-tests\out"; $env:JETCARP_RUNTIME_DIR = "$T\scratch-tests\runtime"
$env:JETCARP_GPU = 'UHD'
Remove-Item Env:WGPU_BACKEND -ErrorAction SilentlyContinue
L "=== #52 follow-up: 30 UHD runs with --test-threads=1"
$rows = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -le 30; $i++) {
  $f = "$OUTD\uhd-serial-$('{0:d2}' -f $i).txt"
  $t0 = Get-Date
  $p = Start-Process cmd -ArgumentList "/c cargo test --release -p jetcarp-gpu --test recovery -- --test-threads=1 > `"$f`" 2>&1" -WorkingDirectory "$T\src" -NoNewWindow -PassThru
  $null = $p.Handle
  $kind = 'ok'; $diag = ''
  if (-not $p.WaitForExit(120000)) {
    $kind = 'hang'
    $tp = Get-CimInstance Win32_Process -Filter "Name like 'recovery-%'" | Select-Object -First 1
    if ($tp) {
      $a1 = Get-Process -Id $tp.ProcessId -ErrorAction SilentlyContinue; $c1 = $a1.TotalProcessorTime.TotalSeconds
      Start-Sleep 10
      $a2 = Get-Process -Id $tp.ProcessId -ErrorAction SilentlyContinue; $c2 = $a2.TotalProcessorTime.TotalSeconds
      $diag = "test process $($tp.ProcessId): CPU {0:n2} s over 10 s, {1} threads, ws {2} MB, private {3} MB" -f ($c2 - $c1), $a2.Threads.Count, [math]::Round($a2.WorkingSet64 / 1MB), [math]::Round($a2.PrivateMemorySize64 / 1MB)
    } else { $diag = 'no recovery-*.exe process found' }
    & taskkill /PID $p.Id /T /F | Out-Null
  } elseif ($p.ExitCode -ne 0) { $kind = "fail($($p.ExitCode))" }
  $secs = ((Get-Date) - $t0).TotalSeconds
  $txt = try { [IO.File]::ReadAllText($f, $UTF8) } catch { '' }
  $last = (($txt -split "`r?`n") | Where-Object { $_ -match '^test ' } | Select-Object -Last 1)
  if ($kind -eq 'ok' -and $txt -notmatch 'test result: ok\.') { $kind = 'no result' }
  $rows.Add([pscustomobject]@{ run = $i; result = $kind; secs = [math]::Round($secs, 1); last_test_line = $last; diag = $diag })
  L ("UHD serial run {0}: {1} in {2:n1} s; last test line: '{3}' {4}" -f $i, $kind, $secs, $last, $diag)
}
$rows | Export-Csv -NoTypeInformation -Encoding UTF8 "$LOG\1.3-52b-runs.csv"
$nOk = @($rows | Where-Object result -eq 'ok').Count; $nHang = @($rows | Where-Object result -eq 'hang').Count
L "RESULT #52 follow-up UHD serial: $nOk of 30 ok, $nHang hung, $(30 - $nOk - $nHang) other"
L "=== #52 follow-up ends"
"follow-up done"
