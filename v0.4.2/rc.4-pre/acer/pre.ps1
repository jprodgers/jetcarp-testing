# rc.4 pre-check on the Acer (NOTES 2026-11-16 12:30 PM EST), the long unattended part: parity with the branch
# build (371 scenes x 300 generations and 40 x 5,000, on RTX Vulkan, RTX DX12, UHD Vulkan, UHD DX12), then the
# whole suite with JETCARP_GPU=RTX and =UHD. Phase 1's (rc.3) helpers. Everything is logged under $T2\logs.
# ASCII only (PowerShell 5.1 reads a BOM-less script as ANSI). Never $t, $j, $r, $s (they would clobber $T2...).
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$UTF8 = New-Object Text.UTF8Encoding $false
$T2 = "$env:USERPROFILE\jetcarp-rc4pre"
$SRC = "$env:USERPROFILE\jetcarp-rc-042c\src"
$REPO = "C:\Users\jimmi\OneDrive\Documents\GitHub\jetcarp-rc"
$BX = "$SRC\target\release\jetcarp.exe"
$LOG = "$T2\logs"
New-Item -ItemType Directory -Force $T2, $LOG | Out-Null
Set-Location $T2
function UseTestFolders { $env:JETCARP_CONFIG_DIR = "$T2\config"; $env:JETCARP_DATA_DIR = "$T2\data"; $env:JETCARP_OUT = "$T2\out"; $env:JETCARP_RUNTIME_DIR = "$T2\runtime" }
function UseScratchFolders { $env:JETCARP_CONFIG_DIR = "$T2\scratch-tests\config"; $env:JETCARP_DATA_DIR = "$T2\scratch-tests\data"; $env:JETCARP_OUT = "$T2\scratch-tests\out"; $env:JETCARP_RUNTIME_DIR = "$T2\scratch-tests\runtime" }
UseTestFolders
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND, Env:JETCARP_LIBRARY -ErrorAction SilentlyContinue
$MAIN = "$LOG\pre.log"
$SUM = [ordered]@{}
function L([string]$msg) { [IO.File]::AppendAllText($MAIN, "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg`r`n", $UTF8) }
function Res([string]$step, [string]$text) { $SUM[$step] = $text; L "RESULT $step : $text"; $SUM.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" } | Set-Content -Encoding utf8 "$LOG\summary.txt" }
function SX([string]$cmdLine, [string]$outFile, [string]$dir, [int]$timeoutS) {
  $t0 = Get-Date
  $p = Start-Process cmd -ArgumentList "/c $cmdLine > `"$outFile`" 2>&1" -WorkingDirectory $dir -NoNewWindow -PassThru
  $null = $p.Handle
  if (-not $p.WaitForExit($timeoutS * 1000)) { L "TIMEOUT after $timeoutS s: $cmdLine; killing its tree"; & taskkill /PID $p.Id /T /F | Out-Null; return [pscustomobject]@{ code = 'TIMEOUT'; secs = ((Get-Date) - $t0).TotalSeconds } }
  $secs = ((Get-Date) - $t0).TotalSeconds; L ("{0} -> exit {1} in {2:n1} min" -f $cmdLine, $p.ExitCode, ($secs / 60))
  [pscustomobject]@{ code = $p.ExitCode; secs = $secs }
}
function Procs { (Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId) $($_.Name)" }) -join ' | ' }

L "=== rc.4 pre-check, long part, starts; src $(git -C $SRC log --oneline -1); build $BX"
L "version: $(& $BX --version)"
L "jetcarp processes at start: $(Procs)"
$bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue; L "power: $(if ($bat) { "battery $($bat.EstimatedChargeRemaining)%, status $($bat.BatteryStatus) (2 = mains)" } else { 'n/a' })"
Copy-Item "$REPO\parity" "$T2\parity" -Recurse -Force
L ("parity copied from the repository: {0} scenes, long {1} scenes" -f (Import-Csv "$T2\parity\expected.csv").Count, (Import-Csv "$T2\parity\long\expected.csv").Count)

# ---------------------------------------------------------------- 2. Parity with the branch build
$adapters = @(@{ n = 'rtx-vulkan'; g = 'RTX'; b = $null }, @{ n = 'rtx-dx12'; g = 'RTX'; b = 'dx12' }, @{ n = 'uhd-vulkan'; g = 'UHD'; b = $null }, @{ n = 'uhd-dx12'; g = 'UHD'; b = 'dx12' })
foreach ($part in @(@{ step = '2.371'; dir = "$T2\parity"; gens = 300; want = '371 scenes: CPU matches 371, GPU matches 371' }, @{ step = '2.40'; dir = "$T2\parity\long"; gens = 5000; want = '40 scenes: CPU matches 40, GPU matches 40' })) {
  foreach ($a in $adapters) {
    $name = "$($part.step)-$($a.n)"
    try {
      $env:JETCARP_GPU = $a.g; if ($a.b) { $env:WGPU_BACKEND = $a.b } else { Remove-Item Env:WGPU_BACKEND -ErrorAction SilentlyContinue }
      L "=== $name (JETCARP_GPU=$($a.g) WGPU_BACKEND=$($a.b), $($part.gens) gens)"
      $t0 = Get-Date
      $outText = & "$T2\parity\parity.ps1" -J $BX -Dir $part.dir -Out "$LOG\$name.csv" -Gens $part.gens *>&1 | Out-String
      [IO.File]::WriteAllText("$LOG\$name.log", $outText, $UTF8)
      $last = ($outText -split "`r?`n" | Where-Object { $_ -match 'scenes: CPU matches' } | Select-Object -Last 1)
      $mism = @($outText -split "`r?`n" | Where-Object { $_ -match '^MISMATCH' }).Count
      $rows = Import-Csv "$LOG\$name.csv"
      $named = ($rows | Where-Object { [int]$_.gpu_gens -gt 0 } | Group-Object { ($_.gpu_backend -split ';')[0] } | Sort-Object Count -Descending | ForEach-Object { "$($_.Count)x $($_.Name)" }) -join ', '
      L "$name adapters used: $named"
      Res $name ("{0}: {1}; {2} MISMATCH lines; {3:n1} min" -f $(if ($last -like "$($part.want)*" -and $mism -eq 0) { 'pass' } else { 'FAIL' }), $last, $mism, ((Get-Date) - $t0).TotalMinutes)
    } catch { Res $name "FAIL: $_" }
  }
}
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue

# ---------------------------------------------------------------- 1. The whole suite on each GPU
try {
  L "=== 1. the suite"
  UseScratchFolders
  foreach ($g in 'RTX', 'UHD') {
    $env:JETCARP_GPU = $g
    $f = "$LOG\1-tests-$($g.ToLower()).txt"
    $c = SX "cargo test --release --workspace --no-fail-fast" $f $SRC 10800
    $txt = Get-Content $f -Encoding UTF8 -ErrorAction SilentlyContinue
    $sums = $txt | Select-String '^test result: \w+\. (\d+) passed; (\d+) failed; (\d+) ignored' | ForEach-Object { , @([int]$_.Matches[0].Groups[1].Value, [int]$_.Matches[0].Groups[2].Value, [int]$_.Matches[0].Groups[3].Value) }
    $np = ($sums | ForEach-Object { $_[0] } | Measure-Object -Sum).Sum; $nf = ($sums | ForEach-Object { $_[1] } | Measure-Object -Sum).Sum; $ni = ($sums | ForEach-Object { $_[2] } | Measure-Object -Sum).Sum
    $failedNames = ($txt | Select-String '^test (\S+) \.\.\. FAILED' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ', '
    $crashed = ($txt | Select-String 'process didn''t exit successfully|STATUS_ACCESS_VIOLATION|0xc0000005' | ForEach-Object { $_.Line.Trim() }) -join ' / '
    $ignNames = ($txt | Select-String '^test (\S+) \.\.\. ignored' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ', '
    L "1 $g ignored: $ignNames"
    if ($crashed) { L "1 $g crashed binaries: $crashed" }
    Res "1-suite-$($g.ToLower())" ("{0}: {1} passed, {2} failed, {3} ignored in {4} test binaries; exit {5}, {6:n0} min{7}{8}" -f $(if ($c.code -eq 0 -and $nf -eq 0) { 'pass' } else { 'FAIL' }), $np, $nf, $ni, @($sums).Count, $c.code, ($c.secs / 60), $(if ($failedNames) { "; failed: $failedNames" } else { '' }), $(if ($crashed) { "; crashed: $crashed" } else { '' }))
  }
} catch { Res "1-suite" "FAIL: $_" }
Remove-Item Env:JETCARP_GPU -ErrorAction SilentlyContinue
L "jetcarp processes at the end: $(Procs)"
L "=== long part ends"
"pre.ps1 done"
