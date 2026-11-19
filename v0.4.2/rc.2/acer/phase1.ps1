# v0.4.2-rc.2, Phase 1 on the Acer (unattended): 0 unpack and check, then 1.6, 1.1, 1.2, 1.3, 1.4.
# Each step carries on if one before failed; everything is logged under $T\logs.
# Variable names: never $t, $j or $r (PowerShell names ignore case: they'd clobber $T, $J, $R).
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$T = "$env:USERPROFILE\jetcarp-rc-042b"
$R = "C:\Users\jimmi\OneDrive\Documents\GitHub\jetcarp-rc"
$J = "$T\bin\jetcarp.exe"
$LOG = "$T\logs"
$TAG = "v0.4.2-rc.2"; $ZIP = "jetcarp-0.4.2-rc.2-x86_64-pc-windows-msvc.zip"
New-Item -ItemType Directory -Force $T, "$T\bin", $LOG | Out-Null
Set-Location $T
$env:JETCARP_CONFIG_DIR = "$T\config"; $env:JETCARP_DATA_DIR = "$T\data"; $env:JETCARP_OUT = "$T\out"
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND, Env:JETCARP_LIBRARY -ErrorAction SilentlyContinue
$MAIN = "$LOG\phase1.log"
$SUM = [ordered]@{}
function L([string]$msg) { $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg"; $line | Out-File -Encoding utf8 -Append $MAIN }
function Res([string]$step, [string]$text) { $SUM[$step] = $text; L "RESULT $step : $text" }
# Run jetcarp with output to files (no pipes: detached children must not hold one), wait on it only.
function JX([string]$argList, [string]$base, [int]$timeoutS = 0) {
  $o = "$LOG\$base.out"; $e = "$LOG\$base.err"; $t0 = Get-Date
  $p = Start-Process -FilePath $J -ArgumentList $argList -NoNewWindow -PassThru -RedirectStandardOutput $o -RedirectStandardError $e
  $null = $p.Handle
  $done = if ($timeoutS -gt 0) { $p.WaitForExit($timeoutS * 1000) } else { $p.WaitForExit(); $true }
  if (-not $done) { try { Stop-Process -Id $p.Id -Force } catch {} }
  $code = if ($done) { $p.ExitCode } else { 'TIMEOUT' }
  $secs = ((Get-Date) - $t0).TotalSeconds
  L ("jetcarp {0} -> exit {1} in {2:n1} s ({3})" -f $argList, $code, $secs, $base)
  [pscustomobject]@{ code = $code; secs = $secs; out = "$(Get-Content $o -Raw -ErrorAction SilentlyContinue)"; err = "$(Get-Content $e -Raw -ErrorAction SilentlyContinue)" }
}
# A shell command (cargo, git) with output to one file, with a timeout that kills its whole tree.
function SX([string]$cmdLine, [string]$outFile, [string]$dir, [int]$timeoutS) {
  $t0 = Get-Date
  $p = Start-Process cmd -ArgumentList "/c $cmdLine > `"$outFile`" 2>&1" -WorkingDirectory $dir -NoNewWindow -PassThru
  $null = $p.Handle
  if (-not $p.WaitForExit($timeoutS * 1000)) { L "TIMEOUT after $timeoutS s: $cmdLine; killing its tree"; & taskkill /PID $p.Id /T /F | Out-Null; return [pscustomobject]@{ code = 'TIMEOUT'; secs = $timeoutS } }
  $secs = ((Get-Date) - $t0).TotalSeconds; L ("{0} -> exit {1} in {2:n1} min" -f $cmdLine, $p.ExitCode, ($secs / 60))
  [pscustomobject]@{ code = $p.ExitCode; secs = $secs }
}
function DeskState { $d = Get-ItemProperty 'HKCU:\Control Panel\Desktop'; $run = ((Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run).PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join ';'; "WallPaper=$($d.WallPaper)|SCRNSAVE=$($d.'SCRNSAVE.EXE')|Run=$run" }

L "=== Phase 1 starts on $env:COMPUTERNAME; test folder $T"
$bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue; L "power: $(if ($bat) { "battery $($bat.EstimatedChargeRemaining)%, status $($bat.BatteryStatus) (2 = mains)" } else { 'n/a' })"
L "jetcarp processes at start: $((Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | Measure-Object).Count)"
$desk0 = DeskState; L "desktop state at start: $desk0"

# ---------------------------------------------------------------- 0. Unpack and check
$ok0 = $false
try {
  L "=== 0. unpack"
  Invoke-WebRequest "https://github.com/jprodgers/jetcarp/releases/download/$TAG/$ZIP" -OutFile "$T\$ZIP"
  Invoke-WebRequest "https://github.com/jprodgers/jetcarp/releases/download/$TAG/SHA256SUMS" -OutFile "$T\SHA256SUMS"
  $h = (Get-FileHash "$T\$ZIP" -Algorithm SHA256).Hash.ToLower()
  $want = ((Get-Content "$T\SHA256SUMS") | Where-Object { $_ -match [regex]::Escape($ZIP) + '$' }) -replace '\s.*$', ''
  L "zip sha256 $h; SHA256SUMS says $want"
  if ($h -ne $want) { throw "hash mismatch" }
  Unblock-File "$T\$ZIP"
  Expand-Archive "$T\$ZIP" -DestinationPath "$T\unpacked" -Force
  $inner = Get-ChildItem "$T\unpacked" -Directory | Select-Object -First 1
  Move-Item "$($inner.FullName)\*" "$T\bin\" -Force; Remove-Item "$T\unpacked" -Recurse -Force
  $ver = & $J --version; L "version: $ver"
  if ($ver -ne 'jetcarp 0.4.2-rc.2') { throw "unexpected version '$ver'" }
  $d1 = JX "doctor" "0-doctor-first" 300; $d2 = JX "doctor" "0-doctor-second" 300
  L ("doctor first {0:n1} s, second {1:n1} s; gpu-checks.json written: {2}" -f $d1.secs, $d2.secs, (Test-Path "$T\config\gpu-checks.json"))
  L "where.exe jetcarp: $(where.exe jetcarp)"
  Copy-Item "$R\parity" "$T\parity" -Recurse -Force
  L ("parity copied: {0} scenes, long {1} scenes" -f (Import-Csv "$T\parity\expected.csv").Count, (Import-Csv "$T\parity\long\expected.csv").Count)
  $ok0 = $true
  Res "0 unpack" ("pass: sha256 {0}…, {1}; doctor {2:n0} s then {3:n0} s" -f $h.Substring(0,8), $ver, $d1.secs, $d2.secs)
} catch { Res "0 unpack" "FAIL: $_"; L "cannot go on without the candidate"; }
if (-not $ok0) { $SUM.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" } | Set-Content -Encoding utf8 "$LOG\summary.txt"; exit 1 }

# ---------------------------------------------------------------- 1.6 Hunt determinism
try {
  L "=== 1.6"
  $x = JX "search hunt --rules B3/S23,B36/S23,B2/S34 --tilings square,hex --soups 20000 --seed 4242 --label det --json" "1.6-hunt" 3600
  $job16 = $null
  if ("$($x.out)$($x.err)" -match 'hunt job (\d+)') { $job16 = $Matches[1] }
  if (-not $job16) { try { $job16 = ($x.out | ConvertFrom-Json).job } catch {} }
  L "1.6 job: $job16"
  $s = JX "jobs status $job16 --json" "1.6-status" 120
  Copy-Item "$LOG\1.6-status.out" "$LOG\1.6-status.json" -Force
  $line = ($s.out | ConvertFrom-Json).line
  $m = [regex]::Match($line, '([\d,]+) objects \(ships ([\d,]+), osc ([\d,]+), still ([\d,]+)\), ([\d,]+) distinct')
  $got = if ($m.Success) { "{0} distinct, {1} objects (ships {2}, osc {3}, still {4})" -f $m.Groups[5].Value, $m.Groups[1].Value, $m.Groups[2].Value, $m.Groups[3].Value, $m.Groups[4].Value } else { $line }
  $fw = "1,783 distinct, 760,892 objects (ships 51,012, osc 236,468, still 473,412)"
  Res "1.6 hunt" ("{0}: {1} (Framework: {2}); exit {3}, {4:n0} s" -f $(if ($got -eq $fw) { 'pass' } else { 'FAIL' }), $got, $fw, $x.code, $x.secs)
} catch { Res "1.6 hunt" "FAIL: $_" }

# ---------------------------------------------------------------- 1.1 and 1.2 Parity on every GPU
$adapters = @(@{ n = 'rtx-vulkan'; g = 'RTX'; b = $null }, @{ n = 'rtx-dx12'; g = 'RTX'; b = 'dx12' }, @{ n = 'uhd-vulkan'; g = 'UHD'; b = $null }, @{ n = 'uhd-dx12'; g = 'UHD'; b = 'dx12' })
foreach ($part in @(@{ step = '1.1'; dir = "$T\parity"; gens = 300; want = '371 scenes: CPU matches 371, GPU matches 371' }, @{ step = '1.2'; dir = "$T\parity\long"; gens = 5000; want = '40 scenes: CPU matches 40, GPU matches 40' })) {
  foreach ($a in $adapters) {
    $name = "$($part.step)-$($a.n)"
    try {
      $env:JETCARP_GPU = $a.g; if ($a.b) { $env:WGPU_BACKEND = $a.b } else { Remove-Item Env:WGPU_BACKEND -ErrorAction SilentlyContinue }
      L "=== $name (JETCARP_GPU=$($a.g) WGPU_BACKEND=$($a.b), $($part.gens) gens)"
      $t0 = Get-Date
      $outText = & "$T\parity\parity.ps1" -J $J -Dir $part.dir -Out "$LOG\$name.csv" -Gens $part.gens *>&1 | Out-String
      $outText | Out-File -Encoding utf8 "$LOG\$name.log"
      $last = ($outText -split "`r?`n" | Where-Object { $_ -match 'scenes: CPU matches' } | Select-Object -Last 1)
      $mism = ($outText -split "`r?`n" | Where-Object { $_ -match '^MISMATCH' }).Count
      $rows = Import-Csv "$LOG\$name.csv"
      $named = ($rows | Where-Object { [int]$_.gpu_gens -gt 0 } | Group-Object { ($_.gpu_backend -split ';')[0] } | Sort-Object Count -Descending | ForEach-Object { "$($_.Count)x $($_.Name)" }) -join ', '
      L "$name adapters used: $named"
      Res $name ("{0}: {1}; {2} MISMATCH lines; {3:n1} min" -f $(if ($last -like "$($part.want)*" -and $mism -eq 0) { 'pass' } else { 'FAIL' }), $last, $mism, ((Get-Date) - $t0).TotalMinutes)
    } catch { Res $name "FAIL: $_" }
  }
}
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue

# ---------------------------------------------------------------- 1.3 The whole test suite on real GPUs
try {
  L "=== 1.3"
  if (-not (Test-Path "$T\src")) { $c = SX "git clone -q --depth 1 -b $TAG https://github.com/jprodgers/jetcarp.git `"$T\src`"" "$LOG\1.3-clone.txt" $T 1800 }
  L "src at: $(git -C "$T\src" log --oneline -1)"
  # A scratch environment: the tests make their own folders; JETCARP's own folders point at a scratch place.
  $env:JETCARP_CONFIG_DIR = "$T\scratch-tests\config"; $env:JETCARP_DATA_DIR = "$T\scratch-tests\data"; $env:JETCARP_OUT = "$T\scratch-tests\out"
  foreach ($g in 'RTX', 'UHD') {
    $env:JETCARP_GPU = $g
    $f = "$LOG\1.3-tests-$($g.ToLower()).txt"
    $c = SX "cargo test --release --workspace --no-fail-fast" $f "$T\src" 10800
    $txt = Get-Content $f -ErrorAction SilentlyContinue
    $sums = $txt | Select-String '^test result: \w+\. (\d+) passed; (\d+) failed; (\d+) ignored' | ForEach-Object { , @([int]$_.Matches[0].Groups[1].Value, [int]$_.Matches[0].Groups[2].Value, [int]$_.Matches[0].Groups[3].Value) }
    $p = ($sums | ForEach-Object { $_[0] } | Measure-Object -Sum).Sum; $fl = ($sums | ForEach-Object { $_[1] } | Measure-Object -Sum).Sum; $ig = ($sums | ForEach-Object { $_[2] } | Measure-Object -Sum).Sum
    $failedNames = ($txt | Select-String '^test (\S+) \.\.\. FAILED' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ', '
    $ignNames = ($txt | Select-String '^test (\S+) \.\.\. ignored' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ', '
    L "1.3 $g ignored: $ignNames"
    Res "1.3-$($g.ToLower())" ("{0}: {1} passed, {2} failed, {3} ignored in {4} test binaries; exit {5}, {6:n0} min{7}" -f $(if ($c.code -eq 0 -and $fl -eq 0) { 'pass' } else { 'FAIL' }), $p, $fl, $ig, @($sums).Count, $c.code, ($c.secs / 60), $(if ($failedNames) { "; failed: $failedNames" } else { '' }))
  }
} catch { Res "1.3" "FAIL: $_" }
$env:JETCARP_CONFIG_DIR = "$T\config"; $env:JETCARP_DATA_DIR = "$T\data"; $env:JETCARP_OUT = "$T\out"
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue
$desk13 = DeskState; L "desktop state after 1.3 unchanged: $($desk13 -eq $desk0)"; if ($desk13 -ne $desk0) { L "desktop state now: $desk13" }

# ---------------------------------------------------------------- 1.4 A long search with a crash in the middle
try {
  L "=== 1.4"
  $x = JX "search explore --minutes 120 --label long --detach" "1.4-start" 120
  $job = $null; if ("$($x.out)$($x.err)" -match 'job (\d+)') { $job = $Matches[1] }
  if (-not $job) { $lst = (JX "jobs list --json" "1.4-list" 60).out | ConvertFrom-Json; $job = ($lst.jobs | Where-Object kind -eq 'explore' | Select-Object -First 1).job }
  L "1.4 job: $job"
  $start = Get-Date; $killed = $false; $peakWs = 0; $rates = New-Object System.Collections.Generic.List[int]
  $prog = "$LOG\1.4-progress.txt"
  function Probe([string]$tagName) {
    $st = JX "jobs status $job --json" "1.4-probe" 60
    try { $js = $st.out | ConvertFrom-Json } catch { $js = $null }
    $proc = Get-CimInstance Win32_Process -Filter "Name='jetcarp.exe'" | Where-Object { $_.CommandLine -like "*jobs resume $job *" } | Select-Object -First 1
    $ws = 0; if ($proc) { $pp = Get-Process -Id $proc.ProcessId -ErrorAction SilentlyContinue; if ($pp) { $ws = [math]::Round($pp.WorkingSet64 / 1MB) } }
    if ($ws -gt $script:peakWs) { $script:peakWs = $ws }
    $line = if ($js) { $js.line } else { "(no status) $($st.err)" }
    if ($line -match '\((\d+)/s\)') { $script:rates.Add([int]$Matches[1]) }
    ("{0} +{1:n0} min [{2}] ws {3} MB | {4}" -f (Get-Date -Format 'HH:mm:ss'), ((Get-Date) - $start).TotalMinutes, $tagName, $ws, $line) | Out-File -Encoding utf8 -Append $prog
    return $js
  }
  # Phase A: run for about an hour, probing each minute, then kill the search's process hard.
  while (((Get-Date) - $start).TotalMinutes -lt 60) { $null = Probe 'run'; Start-Sleep 60 }
  $victims = Get-CimInstance Win32_Process -Filter "Name='jetcarp.exe'" | Where-Object { $_.CommandLine -like "*jobs resume $job *" }
  $victims | ForEach-Object { L "killing $($_.ProcessId): $($_.CommandLine)"; Stop-Process -Id $_.ProcessId -Force }
  $tk = Get-Date; $killed = [bool]$victims
  $w = JX "jobs wait $job --timeout 180" "1.4-wait-after-kill" 240
  L ("1.4 wait after kill: exit {0}, {1:n1} s after the kill" -f $w.code, ((Get-Date) - $tk).TotalSeconds)
  $sk = JX "jobs status $job" "1.4-status-after-kill" 60
  $resumable = ("$($sk.out)$($sk.err)" -match 'resum')
  # Phase B: resume detached and wait to the end of the budget.
  $rs = JX "jobs resume $job --detach" "1.4-resume" 120
  $rStart = Get-Date; $endCode = $null
  while (((Get-Date) - $rStart).TotalMinutes -lt 110) {
    $null = Probe 'resumed'
    $ww = JX "jobs wait $job --timeout 60" "1.4-wait" 90
    if ($ww.code -ne 5) { $endCode = $ww.code; break }
  }
  if ($null -eq $endCode) { L "1.4 still running after 110 min of resume: stopping it"; $null = JX "jobs stop $job" "1.4-stop" 60; $null = JX "jobs wait $job --timeout 120" "1.4-wait-stop" 150; $endCode = 'cut' }
  $fin = JX "jobs status $job --json" "1.4-status-final" 120; Copy-Item "$LOG\1.4-status-final.out" "$LOG\1.4-status-final.json" -Force
  $fint = JX "jobs status $job" "1.4-status-final-text" 60
  $fj = $fin.out | ConvertFrom-Json
  $srcRuns = [int]$fj.progress.screened + [int]$fj.progress.confirmed
  $mem = if ("$($fint.out)" -match '([\d.]+) GB of memory') { "$($Matches[1]) GB" } else { '?' }
  $zero = ($rates | Where-Object { $_ -eq 0 }).Count
  $rateTxt = if ($rates.Count) { "rate in {0} probes: {1} at 0/s, median {2}/s" -f $rates.Count, $zero, (($rates | Sort-Object)[[int][math]::Floor($rates.Count / 2)]) } else { 'no rates' }
  $sr = JX "jobs runs $job --limit 0 --format csv --out `"$LOG\1.4-src-runs.csv`"" "1.4-src-runs" 600
  $srcCsv = [math]::Max(0, (Get-Content "$LOG\1.4-src-runs.csv" -ErrorAction SilentlyContinue | Measure-Object -Line).Lines - 1)
  L "1.4 source: screened $($fj.progress.screened) + confirmed $($fj.progress.confirmed) = $srcRuns; jobs runs csv rows $srcCsv; end exit $endCode; $mem; peak working set $peakWs MB; $rateTxt"
  # The pack, with no jobs seal, and an import into a fresh library.
  $null = JX "pack key --name `"rc.2 test publisher`"" "1.4-pack-key" 60
  $ex = JX "pack export --to `"$T\P14-pack`" --feed rc2-long --no-media" "1.4-pack-export" 1800
  $packBytes = (Get-ChildItem "$T\P14-pack" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
  $sealMsg = (("$($ex.out)$($ex.err)" -split "`r?`n") | Where-Object { $_ -match 'seal' } | Select-Object -First 1)
  $ck = JX "pack check `"$T\P14-pack`"" "1.4-pack-check" 1800
  New-Item -ItemType Directory -Force "$T\import14" | Out-Null
  $im = JX "pack import `"$T\P14-pack`" --library `"$T\import14\library.sqlite`"" "1.4-pack-import" 1800
  $il = (JX "jobs list --library `"$T\import14\library.sqlite`" --json" "1.4-import-list" 120).out
  $ijob = $null; try { $ilj = $il | ConvertFrom-Json; $arr = if ($ilj.jobs) { $ilj.jobs } else { $ilj }; $ijob = ($arr | Where-Object { $_.kind -eq 'explore' } | Select-Object -First 1).job } catch {}
  if (-not $ijob -and $il -match '"job"\s*:\s*(\d+)[^}]*"kind"\s*:\s*"explore"') { $ijob = $Matches[1] }
  L "1.4 imported explore job: $ijob"
  $ir = JX "jobs runs $ijob --library `"$T\import14\library.sqlite`" --limit 0 --format csv --out `"$LOG\1.4-import-runs.csv`"" "1.4-import-runs" 600
  $impCsv = [math]::Max(0, (Get-Content "$LOG\1.4-import-runs.csv" -ErrorAction SilentlyContinue | Measure-Object -Line).Lines - 1)
  $is = JX "jobs status $ijob --library `"$T\import14\library.sqlite`" --json" "1.4-import-status" 120
  $impRuns = try { $isj = $is.out | ConvertFrom-Json; [int]$isj.progress.screened + [int]$isj.progress.confirmed } catch { -1 }
  $pass = $killed -and ($w.code -eq 6) -and $resumable -and ($ex.code -eq 0) -and ($ck.code -eq 0) -and ($im.code -eq 0) -and ($impCsv -eq $srcCsv) -and ($impCsv -gt 0)
  Res "1.4 long search" ("{0}: runs {1} (jobs runs {2}); killed at ~60 min, wait exit {3}, resumable {4}, resumed to the end (exit {5}); {6}; memory at end {7} (peak working set {8} MB); pack {9:n1} MB, export exit {10} ('{11}'), check {12}, import {13}; imported runs {14} (jobs runs {15})" -f $(if ($pass) { 'pass' } else { 'FAIL' }), $srcRuns, $srcCsv, $w.code, $resumable, $endCode, $rateTxt, $mem, $peakWs, ($packBytes / 1MB), $ex.code, $sealMsg, $ck.code, $im.code, $impRuns, $impCsv)
} catch { Res "1.4 long search" "FAIL: $_" }

$deskEnd = DeskState; L "desktop state at end unchanged: $($deskEnd -eq $desk0)"
L "jetcarp processes at end: $((Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId) $($_.CommandLine)" }) -join ' | ')"
$SUM.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" } | Set-Content -Encoding utf8 "$LOG\summary.txt"
L "=== Phase 1 ends"
"phase 1 done"
