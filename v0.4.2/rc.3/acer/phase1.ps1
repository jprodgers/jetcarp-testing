# v0.4.2-rc.3, Phase 1 on the Acer (unattended): 0 unpack and check, then 1.6, 1.1, 1.2, 1.3 (the suite on each
# adapter, then #52's 30 + 30 recovery runs), 1.4 (240 min; a hard kill at ~1 h; a resume with no --minutes;
# the pack with no seal and an import).
# Each step carries on if one before failed; everything is logged under $T\logs.
# Variable names: never $t, $j, $r (PowerShell names ignore case: they'd clobber $T, $J, $R); no $pid/$home/$input.
# Function names: none is a built-in alias (checked with Get-Alias).
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$UTF8 = New-Object Text.UTF8Encoding $false
$T = "$env:USERPROFILE\jetcarp-rc-042c"
$R = "C:\Users\jimmi\OneDrive\Documents\GitHub\jetcarp-rc"
$J = "$T\bin\jetcarp.exe"
$LOG = "$T\logs"
$TAG = "v0.4.2-rc.3"; $ZIP = "jetcarp-0.4.2-rc.3-x86_64-pc-windows-msvc.zip"; $COMMIT = '400d41d'
$NOTE_HEAD = '002e42d2'; $NOTE_TAIL = '74ec9e39'   # the start note's hash, first and last 8 digits
New-Item -ItemType Directory -Force $T, "$T\bin", $LOG | Out-Null
Set-Location $T
function UseTestFolders { $env:JETCARP_CONFIG_DIR = "$T\config"; $env:JETCARP_DATA_DIR = "$T\data"; $env:JETCARP_OUT = "$T\out"; $env:JETCARP_RUNTIME_DIR = "$T\runtime" }
function UseScratchFolders { $env:JETCARP_CONFIG_DIR = "$T\scratch-tests\config"; $env:JETCARP_DATA_DIR = "$T\scratch-tests\data"; $env:JETCARP_OUT = "$T\scratch-tests\out"; $env:JETCARP_RUNTIME_DIR = "$T\scratch-tests\runtime" }
UseTestFolders
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND, Env:JETCARP_LIBRARY -ErrorAction SilentlyContinue
$MAIN = "$LOG\phase1.log"
$SUM = [ordered]@{}
function L([string]$msg) { [IO.File]::AppendAllText($MAIN, "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg`r`n", $UTF8) }
function Res([string]$step, [string]$text) { $SUM[$step] = $text; L "RESULT $step : $text"; $SUM.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" } | Set-Content -Encoding utf8 "$LOG\summary.txt" }
function ReadText([string]$f) { try { [IO.File]::ReadAllText($f, $UTF8) } catch { '' } }
function CountRows([string]$f) { if (-not (Test-Path $f)) { return -1 }; $n = 0; foreach ($ln in [IO.File]::ReadLines($f)) { $n++ }; [math]::Max(0, $n - 1) }
# Run jetcarp with output to files (no pipes: detached children must not hold one), wait on it only.
function JX([string]$argList, [string]$base, [int]$timeoutS = 0, [switch]$noKill) {
  $o = "$LOG\$base.out"; $e = "$LOG\$base.err"; $t0 = Get-Date
  $p = Start-Process -FilePath $J -ArgumentList $argList -NoNewWindow -PassThru -RedirectStandardOutput $o -RedirectStandardError $e
  $null = $p.Handle
  $done = if ($timeoutS -gt 0) { $p.WaitForExit($timeoutS * 1000) } else { $p.WaitForExit(); $true }
  if (-not $done -and -not $noKill) { try { Stop-Process -Id $p.Id -Force } catch {} }
  $code = if ($done) { $p.ExitCode } else { 'TIMEOUT' }
  $secs = ((Get-Date) - $t0).TotalSeconds
  L ("jetcarp {0} -> exit {1} in {2:n1} s ({3})" -f $argList, $code, $secs, $base)
  [pscustomobject]@{ code = $code; secs = $secs; out = (ReadText $o); err = (ReadText $e); proc = $p }
}
# A shell command (cargo, git) with output to one file, with a timeout that kills its whole tree.
function SX([string]$cmdLine, [string]$outFile, [string]$dir, [int]$timeoutS) {
  $t0 = Get-Date
  $p = Start-Process cmd -ArgumentList "/c $cmdLine > `"$outFile`" 2>&1" -WorkingDirectory $dir -NoNewWindow -PassThru
  $null = $p.Handle
  if (-not $p.WaitForExit($timeoutS * 1000)) { L "TIMEOUT after $timeoutS s: $cmdLine; killing its tree"; & taskkill /PID $p.Id /T /F | Out-Null; return [pscustomobject]@{ code = 'TIMEOUT'; secs = ((Get-Date) - $t0).TotalSeconds } }
  $secs = ((Get-Date) - $t0).TotalSeconds; L ("{0} -> exit {1} in {2:n1} min" -f $cmdLine, $p.ExitCode, ($secs / 60))
  [pscustomobject]@{ code = $p.ExitCode; secs = $secs }
}
function DeskState { $d = Get-ItemProperty 'HKCU:\Control Panel\Desktop'; $run = ((Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run).PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join ';'; "WallPaper=$($d.WallPaper)|SCRNSAVE=$($d.'SCRNSAVE.EXE')|Run=$run" }
function Procs { (Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId)<-$($_.ParentProcessId) $($_.Name) $(($_.CommandLine -split ' jobs ')[1])" }) -join ' | ' }
function Median($list) { if (-not $list -or $list.Count -eq 0) { return $null }; $a = @($list | Sort-Object); $a[[int][math]::Floor($a.Count / 2)] }

L "=== Phase 1 starts on $env:COMPUTERNAME; test folder $T"
$bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue; L "power: $(if ($bat) { "battery $($bat.EstimatedChargeRemaining)%, status $($bat.BatteryStatus) (2 = mains)" } else { 'n/a' })"
L "jetcarp processes at start: $(Procs)"
L "folders: CONFIG $env:JETCARP_CONFIG_DIR, DATA $env:JETCARP_DATA_DIR, OUT $env:JETCARP_OUT, RUNTIME $env:JETCARP_RUNTIME_DIR"
$desk0 = DeskState; L "desktop state at start: $desk0"
$everydayLock = Test-Path "$env:LOCALAPPDATA\jetcarp\host.lock"; L "everyday host.lock present at start: $everydayLock"

# ---------------------------------------------------------------- 0. Unpack and check
$ok0 = $false
try {
  L "=== 0. unpack"
  Invoke-WebRequest "https://github.com/jprodgers/jetcarp/releases/download/$TAG/$ZIP" -OutFile "$T\$ZIP" -UseBasicParsing
  Invoke-WebRequest "https://github.com/jprodgers/jetcarp/releases/download/$TAG/SHA256SUMS" -OutFile "$T\SHA256SUMS" -UseBasicParsing
  $h = (Get-FileHash "$T\$ZIP" -Algorithm SHA256).Hash.ToLower()
  $want = ((Get-Content "$T\SHA256SUMS") | Where-Object { $_ -match [regex]::Escape($ZIP) + '$' }) -replace '\s.*$', ''
  L "zip sha256 $h; SHA256SUMS says $want; the start note says $NOTE_HEAD…$NOTE_TAIL"
  if ($h -ne $want) { throw "hash mismatch against SHA256SUMS" }
  if (-not ($h.StartsWith($NOTE_HEAD) -and $h.EndsWith($NOTE_TAIL))) { throw "hash differs from the start note's" }
  Unblock-File "$T\$ZIP"
  Expand-Archive "$T\$ZIP" -DestinationPath "$T\unpacked" -Force
  $inner = Get-ChildItem "$T\unpacked" -Directory | Select-Object -First 1
  if ($inner) { Move-Item "$($inner.FullName)\*" "$T\bin\" -Force } else { Move-Item "$T\unpacked\*" "$T\bin\" -Force }
  Remove-Item "$T\unpacked" -Recurse -Force
  L "bin: $((Get-ChildItem "$T\bin" | ForEach-Object Name) -join ', ')"
  $ver = & $J --version; L "version: $ver"
  if ($ver -ne 'jetcarp 0.4.2-rc.3') { throw "unexpected version '$ver'" }
  $d1 = JX "doctor" "0-doctor-first" 300; $d2 = JX "doctor" "0-doctor-second" 300
  L ("doctor first {0:n1} s (exit {1}), second {2:n1} s (exit {3}); gpu-checks.json written: {4}" -f $d1.secs, $d1.code, $d2.secs, $d2.code, (Test-Path "$T\config\gpu-checks.json"))
  L "where.exe jetcarp: $(where.exe jetcarp)"
  Copy-Item "$R\parity" "$T\parity" -Recurse -Force
  L ("parity copied: {0} scenes, long {1} scenes" -f (Import-Csv "$T\parity\expected.csv").Count, (Import-Csv "$T\parity\long\expected.csv").Count)
  $ok0 = $true
  Res "0 unpack" ("pass: sha256 {0}…{1} (SHA256SUMS and the start note), {2}; doctor {3:n0} s then {4:n0} s" -f $h.Substring(0,8), $h.Substring($h.Length - 8), $ver, $d1.secs, $d2.secs)
} catch { Res "0 unpack" "FAIL: $_"; L "cannot go on without the candidate" }
if (-not $ok0) { L "=== Phase 1 ends (no candidate)"; exit 1 }

# ---------------------------------------------------------------- 1.6 Hunt determinism
try {
  L "=== 1.6"
  $x = JX "search hunt --rules B3/S23,B36/S23,B2/S34 --tilings square,hex --soups 20000 --seed 4242 --label det --json" "1.6-hunt" 3600
  $job16 = $null
  if ("$($x.out)$($x.err)" -match 'hunt job (\d+)') { $job16 = $Matches[1] }
  if (-not $job16) { try { $job16 = ($x.out | ConvertFrom-Json).job } catch {} }
  L "1.6 job: $job16"
  $st16 = JX "jobs status $job16 --json" "1.6-status" 120
  Copy-Item "$LOG\1.6-status.out" "$LOG\1.6-status.json" -Force
  $line = ($st16.out | ConvertFrom-Json).line
  $m = [regex]::Match($line, '([\d,]+) objects \(ships ([\d,]+), osc ([\d,]+), still ([\d,]+)\), ([\d,]+) distinct')
  $got = if ($m.Success) { "{0} distinct, {1} objects (ships {2}, osc {3}, still {4})" -f $m.Groups[5].Value, $m.Groups[1].Value, $m.Groups[2].Value, $m.Groups[3].Value, $m.Groups[4].Value } else { $line }
  $fw = "1,783 distinct, 760,892 objects (ships 51,012, osc 236,468, still 473,412)"
  Res "1.6 hunt" ("{0}: {1} (rc.2 on all three: {2}); exit {3}, {4:n0} s" -f $(if ($got -eq $fw) { 'pass' } else { 'FAIL' }), $got, $fw, $x.code, $x.secs)
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

# ---------------------------------------------------------------- 1.3 The whole test suite on real GPUs
try {
  L "=== 1.3"
  if (-not (Test-Path "$T\src")) { $c = SX "git clone -q --depth 1 -b $TAG https://github.com/jprodgers/jetcarp.git `"$T\src`"" "$LOG\1.3-clone.txt" $T 1800 }
  $head = "$(git -C "$T\src" log --oneline -1)"; L "src at: $head"
  if (-not $head.StartsWith($COMMIT)) { L "WARNING: the clone is not at $COMMIT" }
  UseScratchFolders   # the tests make their own folders; JETCARP's own folders point at a scratch place
  foreach ($g in 'RTX', 'UHD') {
    $env:JETCARP_GPU = $g
    $f = "$LOG\1.3-tests-$($g.ToLower()).txt"
    $c = SX "cargo test --release --workspace --no-fail-fast" $f "$T\src" 10800
    $txt = Get-Content $f -Encoding UTF8 -ErrorAction SilentlyContinue
    $sums = $txt | Select-String '^test result: \w+\. (\d+) passed; (\d+) failed; (\d+) ignored' | ForEach-Object { , @([int]$_.Matches[0].Groups[1].Value, [int]$_.Matches[0].Groups[2].Value, [int]$_.Matches[0].Groups[3].Value) }
    $np = ($sums | ForEach-Object { $_[0] } | Measure-Object -Sum).Sum; $nf = ($sums | ForEach-Object { $_[1] } | Measure-Object -Sum).Sum; $ni = ($sums | ForEach-Object { $_[2] } | Measure-Object -Sum).Sum
    $failedNames = ($txt | Select-String '^test (\S+) \.\.\. FAILED' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ', '
    $crashed = ($txt | Select-String 'process didn''t exit successfully|STATUS_ACCESS_VIOLATION|0xc0000005' | ForEach-Object { $_.Line.Trim() }) -join ' / '
    $ignNames = ($txt | Select-String '^test (\S+) \.\.\. ignored' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ', '
    L "1.3 $g ignored: $ignNames"
    if ($crashed) { L "1.3 $g crashed binaries: $crashed" }
    Res "1.3-$($g.ToLower())" ("{0}: {1} passed, {2} failed, {3} ignored in {4} test binaries; exit {5}, {6:n0} min{7}{8}" -f $(if ($c.code -eq 0 -and $nf -eq 0) { 'pass' } else { 'FAIL' }), $np, $nf, $ni, @($sums).Count, $c.code, ($c.secs / 60), $(if ($failedNames) { "; failed: $failedNames" } else { '' }), $(if ($crashed) { "; crashed: $crashed" } else { '' }))
  }
} catch { Res "1.3" "FAIL: $_" }

# ---------------------------------------------------------------- 1.3 #52: the GPU recovery test, 30 runs on each adapter
try {
  L "=== 1.3 #52"
  UseScratchFolders
  Remove-Item Env:JETCARP_GPU -ErrorAction SilentlyContinue
  # Build first: -p jetcarp-gpu alone can unify features differently from --workspace, and a rebuild must not eat a run's 2 minutes.
  $b52 = SX "cargo test --release -p jetcarp-gpu --test recovery --no-run" "$LOG\1.3-52-build.txt" "$T\src" 3600
  $runs52 = New-Object System.Collections.Generic.List[object]
  foreach ($g in 'RTX', 'UHD') {
    $env:JETCARP_GPU = $g
    for ($i = 1; $i -le 30; $i++) {
      $f = "$LOG\1.3-52-$($g.ToLower())-$('{0:d2}' -f $i).txt"
      $c = SX "cargo test --release -p jetcarp-gpu --test recovery" $f "$T\src" 120
      $txt = ReadText $f
      $okm = [regex]::Match($txt, 'test result: ok\. (\d+) passed; 0 failed')
      $kind = if ($c.code -eq 'TIMEOUT') { 'hang' } elseif ($txt -match '0xc0000005|STATUS_ACCESS_VIOLATION') { 'crash' } elseif ($c.code -eq 0 -and $okm.Success) { 'ok' } else { "fail" }
      $runs52.Add([pscustomobject]@{ adapter = $g; run = $i; result = $kind; exit = $c.code; secs = [math]::Round($c.secs, 1); passed = $(if ($okm.Success) { $okm.Groups[1].Value } else { '' }) })
      L "1.3 #52 $g run $i : $kind (exit $($c.code), $([math]::Round($c.secs, 1)) s)"
    }
  }
  $runs52 | Export-Csv -NoTypeInformation -Encoding UTF8 "$LOG\1.3-52-runs.csv"
  foreach ($g in 'RTX', 'UHD') {
    $grp = @($runs52 | Where-Object adapter -eq $g)
    $nOk = @($grp | Where-Object result -eq 'ok').Count; $nCrash = @($grp | Where-Object result -eq 'crash').Count; $nHang = @($grp | Where-Object result -eq 'hang').Count; $nFail = @($grp | Where-Object result -eq 'fail').Count
    $secsOk = @($grp | Where-Object result -eq 'ok' | ForEach-Object secs)
    Res "1.3 #52 $g" ("{0}: {1} of {2} ok, {3} crashed, {4} hung, {5} failed otherwise; median {6} s a run (build first: exit {7})" -f $(if ($nOk -eq $grp.Count -and $grp.Count -eq 30) { 'pass' } else { 'FAIL' }), $nOk, $grp.Count, $nCrash, $nHang, $nFail, (Median $secsOk), $b52.code)
  }
} catch { Res "1.3 #52" "FAIL: $_" }
UseTestFolders
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue
$desk13 = DeskState; L "desktop state after 1.3 unchanged: $($desk13 -eq $desk0)"; if ($desk13 -ne $desk0) { L "desktop state now: $desk13" }

# ---------------------------------------------------------------- 1.4 A long search with a crash in the middle (240 min)
$job = $null
function Worker { @(Get-CimInstance Win32_Process -Filter "Name='jetcarp.exe'" | Where-Object { $_.CommandLine -match " jobs resume $job( |$)" }) }
$prog = "$LOG\1.4-progress.txt"; $memCsv = "$LOG\1.4-memory.csv"
[IO.File]::WriteAllText($memCsv, "time,wall_min,phase,elapsed_min,status,rss_gb,worker,ws_mb,private_mb`r`n", $UTF8)
$rates = New-Object System.Collections.Generic.List[int]; $peakWs = 0; $peakPriv = 0; $lastMem = [datetime]::MinValue; $start = Get-Date
function Probe([string]$phase, [string]$base = '1.4-probe', [switch]$memRow) {
  $st = JX "jobs status $job --json" $base 60
  $js = $null; try { $js = $st.out | ConvertFrom-Json } catch {}
  $wk = Worker | Select-Object -First 1
  $ws = 0; $pv = 0; $wid = ''
  if ($wk) { $wid = $wk.ProcessId; $pp = Get-Process -Id $wk.ProcessId -ErrorAction SilentlyContinue; if ($pp) { $ws = [math]::Round($pp.WorkingSet64 / 1MB); $pv = [math]::Round($pp.PrivateMemorySize64 / 1MB) } }
  if ($ws -gt $script:peakWs) { $script:peakWs = $ws }; if ($pv -gt $script:peakPriv) { $script:peakPriv = $pv }
  $line = if ($js) { $js.line } else { "(no status) $($st.err)" }
  if (($phase -eq 'run' -or $phase -eq 'resumed') -and $line -match '\(([\d,]+)/s\)') { $script:rates.Add([int]($Matches[1] -replace ',', '')) }
  $el = if ($js) { [math]::Round([double]$js.progress.elapsed_s / 60, 1) } else { '' }
  $rss = if ($js -and $null -ne $js.progress.rss_gb) { [math]::Round([double]$js.progress.rss_gb, 3) } else { '' }
  $extra = if ($js) { "status $($js.status), stale $($js.stale), resumable $($js.resumable), elapsed $el min, rss $rss GB" } else { '' }
  [IO.File]::AppendAllText($prog, ("{0} +{1:f1} min [{2}] worker {3} ws {4} MB priv {5} MB | {6} | {7}`r`n" -f (Get-Date -Format 'HH:mm:ss'), ((Get-Date) - $script:start).TotalMinutes, $phase, $wid, $ws, $pv, $extra, $line), $UTF8)
  if ($memRow -or ((Get-Date) - $script:lastMem).TotalMinutes -ge 4.9) {
    $script:lastMem = Get-Date
    [IO.File]::AppendAllText($memCsv, ("{0},{1:f1},{2},{3},{4},{5},{6},{7},{8}`r`n" -f (Get-Date -Format 's'), ((Get-Date) - $script:start).TotalMinutes, $phase, $el, $(if ($js) { $js.status } else { '' }), $rss, $wid, $ws, $pv), $UTF8)
  }
  return $js
}
function RowKeys([string]$f) { $k = [string[]](Import-Csv $f | ForEach-Object { "$($_.rule)|$($_.tiling)|$($_.rng)|$($_.score)" }); if (-not $k) { $k = [string[]]@() }; [Array]::Sort($k, [StringComparer]::Ordinal); , $k }
try {
  L "=== 1.4"
  $x = JX "search explore --minutes 240 --label long --detach" "1.4-start" 120
  if ("$($x.out)$($x.err)" -match 'job (\d+)') { $job = $Matches[1] }
  if (-not $job) { $lst = (JX "jobs list --json" "1.4-list" 60).out | ConvertFrom-Json; $arr = if ($lst.jobs) { $lst.jobs } else { $lst }; $job = ($arr | Where-Object kind -eq 'explore' | Select-Object -First 1).job }
  $start = Get-Date
  Start-Sleep 5
  L "1.4 job: $job; processes: $(Procs)"
  # Phase A: run for about an hour, probing each minute (memory every 5), then kill the search's process hard.
  while (((Get-Date) - $start).TotalMinutes -lt 60) { $null = Probe 'run'; Start-Sleep 55 }
  $jsKill = Probe 'before kill' -memRow
  $memAt1h = if ($jsKill) { $jsKill.progress.rss_gb } else { $null }
  $null = JX "jobs list --json" "1.4-list-before-kill" 60
  $victims = Worker
  L "processes before the kill: $(Procs)"
  $victims | ForEach-Object { L "killing $($_.ProcessId): $($_.CommandLine)"; Stop-Process -Id $_.ProcessId -Force }
  $tk = Get-Date; $killed = ($victims.Count -gt 0)
  # #49: jobs status should say stale within seconds.
  $obs = New-Object System.Collections.Generic.List[string]; $firstStale = $null
  foreach ($at in 1, 3, 5, 10, 20, 30) {
    while (((Get-Date) - $tk).TotalSeconds -lt $at) { Start-Sleep -Milliseconds 200 }
    $sec = ((Get-Date) - $tk).TotalSeconds
    $js = Probe "after kill +$at s" "1.4-status-kill-$at"
    Copy-Item "$LOG\1.4-status-kill-$at.out" "$LOG\1.4-status-kill-$at.json" -Force
    $isStale = [bool]($js -and (($js.stale -eq $true) -or ("$($js.status)" -match 'stale')))
    if ($isStale -and $null -eq $firstStale) { $firstStale = $sec }
    $obs.Add(("+{0:n1} s: status {1}, stale {2}, resumable {3}" -f $sec, $js.status, $js.stale, $js.resumable))
  }
  $lk = JX "jobs list --json" "1.4-list-after-kill" 60
  $listTxt = '?'; try { $lj = $lk.out | ConvertFrom-Json; $arr = if ($lj.jobs) { $lj.jobs } else { $lj }; $row = $arr | Where-Object { "$($_.job)" -eq "$job" } | Select-Object -First 1; if ($row) { $listTxt = "status $($row.status), stale $($row.stale)" } } catch {}
  $null = JX "jobs list" "1.4-list-after-kill-text" 60
  $null = JX "jobs status $job" "1.4-status-after-kill-text" 60
  $w = JX "jobs wait $job --timeout 180" "1.4-wait-after-kill" 240
  L ("1.4 after the kill: {0}; jobs list: {1}; jobs wait exit {2} at +{3:n1} s" -f ($obs -join ' / '), $listTxt, $w.code, ((Get-Date) - $tk).TotalSeconds)
  # Phase B: resume detached with no --minutes (#51), and jobs wait straight after (#50 wants 5).
  $rs = JX "jobs resume $job --detach" "1.4-resume" 120
  $w50 = JX "jobs wait $job --timeout 2" "1.4-wait-after-resume" 30
  $rStart = Get-Date
  $rsSays = ("$($rs.out) $($rs.err)" -replace '\s+', ' ').Trim()
  L ("1.4 resume: exit {0} in {1:n1} s, says: {2}; jobs wait --timeout 2 straight after: exit {3}; processes: {4}" -f $rs.code, $rs.secs, $rsSays, $w50.code, (Procs))
  $endCode = $null; $capped = $false
  while (((Get-Date) - $rStart).TotalMinutes -lt 200) {
    $null = Probe 'resumed'
    $ww = JX "jobs wait $job --timeout 60" "1.4-wait" 90
    if ($ww.code -eq 5) { continue }
    if ($ww.code -eq 6 -and (Worker).Count -gt 0) { L "jobs wait said gone (6) while a worker runs: $(Procs)"; Start-Sleep 30; continue }
    $endCode = $ww.code; break
  }
  if ($null -eq $endCode) { $capped = $true; L "1.4 still running 200 min after the resume: jobs stop"; $null = JX "jobs stop $job" "1.4-stop" 60; $null = JX "jobs wait $job --timeout 300" "1.4-wait-stop" 330; $endCode = 'cut' }
  $tEnd = Get-Date
  $null = Probe 'end' -memRow
  L "1.4 ended: wait exit $endCode, $([math]::Round(($tEnd - $rStart).TotalMinutes, 1)) min after the resume, $([math]::Round(($tEnd - $start).TotalMinutes, 1)) min after the start; processes: $(Procs)"
  $fin = JX "jobs status $job --json" "1.4-status-final" 120; Copy-Item "$LOG\1.4-status-final.out" "$LOG\1.4-status-final.json" -Force
  $null = JX "jobs status $job" "1.4-status-final-text" 60
  $fj = $fin.out | ConvertFrom-Json
  $elMin = [double]$fj.progress.elapsed_s / 60
  $srcRuns = [int]$fj.progress.screened + [int]$fj.progress.confirmed
  $srcConf = $fj.progress.confirmed_elites
  $zero = @($rates | Where-Object { $_ -eq 0 }).Count
  $rateTxt = if ($rates.Count) { "{0} probes: {1} at 0/s, median {2}/s" -f $rates.Count, $zero, (Median $rates) } else { 'no rates' }
  # Memory at 1 h (the kill), 2 h and 4 h of search, from the 5-minute log (rows with a live worker).
  $memRows = @(Import-Csv $memCsv | Where-Object { [int]$_.ws_mb -gt 0 -and $_.elapsed_min -ne '' })
  $m2 = $memRows | Sort-Object { [math]::Abs([double]$_.elapsed_min - 120) } | Select-Object -First 1
  $m4 = $memRows | Sort-Object { [double]$_.elapsed_min } | Select-Object -Last 1
  $memTxt = "1 h {0} GB; 2 h {1} GB (ws {2} MB, private {3} MB, at {4} min); end {5} GB (ws {6} MB, private {7} MB, at {8} min); peak ws {9} MB, private {10} MB" -f $memAt1h, $m2.rss_gb, $m2.ws_mb, $m2.private_mb, $m2.elapsed_min, $m4.rss_gb, $m4.ws_mb, $m4.private_mb, $m4.elapsed_min, $peakWs, $peakPriv
  $null = JX "jobs runs $job --limit 0 --format csv --out `"$LOG\1.4-src-runs-stage1.csv`"" "1.4-src-runs1" 900
  $null = JX "jobs runs $job --stage 2 --limit 0 --format csv --out `"$LOG\1.4-src-runs-stage2.csv`"" "1.4-src-runs2" 900
  $src1 = CountRows "$LOG\1.4-src-runs-stage1.csv"; $src2 = CountRows "$LOG\1.4-src-runs-stage2.csv"
  L "1.4 source: status $($fj.status); elapsed $([math]::Round($elMin, 1)) min; screened $($fj.progress.screened) + confirmed $($fj.progress.confirmed) = $srcRuns; csv stage 1 $src1, stage 2 $src2; confirmed elites $srcConf; $memTxt; $rateTxt"
  Res "1.4 run" ("{0} runs (screened {1} + confirmation {2}); {3}; memory {4}" -f $srcRuns, $fj.progress.screened, $fj.progress.confirmed, $rateTxt, $memTxt)
  Res "1.4 #49 stale" ("{0}: first stale at {1}; {2}; jobs list after 30 s: {3}; jobs wait exit {4} (killed: {5})" -f $(if ($null -ne $firstStale -and $firstStale -le 10) { 'pass' } else { 'FAIL' }), $(if ($null -ne $firstStale) { "+{0:n1} s" -f $firstStale } else { 'never in 30 s' }), ($obs -join ' / '), $listTxt, $w.code, $killed)
  Res "1.4 #50 wait" ("{0}: jobs wait --timeout 2 straight after jobs resume --detach exited {1} (want 5); the resume exited {2} in {3:n1} s" -f $(if ("$($w50.code)" -eq '5') { 'pass' } else { 'FAIL' }), $w50.code, $rs.code, $rs.secs)
  Res "1.4 #51 budget" ("{0}: the resume ended by itself: {1} (wait exit {2}), {3:n1} min after it; search time in all {4:n1} min (want ~240); status {5}; the resume said: {6}" -f $(if (-not $capped -and $elMin -ge 228 -and $elMin -le 252) { 'pass' } else { 'FAIL' }), (-not $capped), $endCode, ($tEnd - $rStart).TotalMinutes, $elMin, $fj.status, $rsSays)

  # The pack, with no jobs seal, and an import into a fresh library (#35, #54).
  $null = JX "pack key --name `"rc.3 test publisher`"" "1.4-pack-key" 60
  $ex = JX "pack export --to `"$T\P14-pack`" --feed rc3-long --no-media" "1.4-pack-export" 1800
  $packBytes = (Get-ChildItem "$T\P14-pack" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
  $sealMsg = (("$($ex.out)$($ex.err)" -split "`r?`n") | Where-Object { $_ -match 'seal' } | Select-Object -First 1)
  $ck = JX "pack check `"$T\P14-pack`"" "1.4-pack-check" 1800
  New-Item -ItemType Directory -Force "$T\import14" | Out-Null
  $im = JX "pack import `"$T\P14-pack`" --library `"$T\import14\library.sqlite`"" "1.4-pack-import" 1800
  $il = (JX "jobs list --library `"$T\import14\library.sqlite`" --json" "1.4-import-list" 120).out
  $ijob = $null; try { $ilj = $il | ConvertFrom-Json; $arr = if ($ilj.jobs) { $ilj.jobs } else { $ilj }; $ijob = ($arr | Where-Object { $_.kind -eq 'explore' } | Select-Object -First 1).job } catch {}
  L "1.4 imported explore job: $ijob"
  $null = JX "jobs runs $ijob --library `"$T\import14\library.sqlite`" --limit 0 --format csv --out `"$LOG\1.4-import-runs-stage1.csv`"" "1.4-import-runs1" 900
  $null = JX "jobs runs $ijob --library `"$T\import14\library.sqlite`" --stage 2 --limit 0 --format csv --out `"$LOG\1.4-import-runs-stage2.csv`"" "1.4-import-runs2" 900
  $imp1 = CountRows "$LOG\1.4-import-runs-stage1.csv"; $imp2 = CountRows "$LOG\1.4-import-runs-stage2.csv"
  $is = JX "jobs status $ijob --library `"$T\import14\library.sqlite`" --json" "1.4-import-status" 120; Copy-Item "$LOG\1.4-import-status.out" "$LOG\1.4-import-status.json" -Force
  $isj = $null; try { $isj = $is.out | ConvertFrom-Json } catch {}
  $impRuns = if ($isj) { [int]$isj.progress.screened + [int]$isj.progress.confirmed } else { -1 }
  $impConf = if ($isj) { $isj.progress.confirmed_elites } else { $null }
  $same = 'not compared'
  $hasCols = "$(Get-Content "$LOG\1.4-src-runs-stage1.csv" -TotalCount 1)" -match '(^|,)"?rule"?(,|$)'
  if ($hasCols -and $imp1 -eq $src1 -and $imp2 -eq $src2) {
    $ka = RowKeys "$LOG\1.4-src-runs-stage1.csv"; $kb = RowKeys "$LOG\1.4-import-runs-stage1.csv"
    $same = ($ka.Count -eq $kb.Count)
    if ($same) { for ($i = 0; $i -lt $ka.Count; $i++) { if ($ka[$i] -cne $kb[$i]) { $same = $false; L "first differing row key: $($ka[$i]) vs $($kb[$i])"; break } } }
  } elseif (-not $hasCols) { $same = 'no rule column' }
  L "1.4 import: runs $impRuns (csv $imp1 + $imp2), confirmed elites $impConf; same stage-1 rows: $same"
  $packPass = ($ex.code -eq 0) -and ($ck.code -eq 0) -and ($im.code -eq 0) -and ($src1 -gt 0) -and ($imp1 -eq $src1) -and ($imp2 -eq $src2) -and ($same -eq $true)
  Res "1.4 pack #35" ("{0}: pack {1:n1} MB, export exit {2} ('{3}'), check {4}, import {5}; runs {6} = {7} (csv {8} + {9} = {10} + {11}); same stage-1 rows: {12}" -f $(if ($packPass) { 'pass' } else { 'FAIL' }), ($packBytes / 1MB), $ex.code, $sealMsg, $ck.code, $im.code, $srcRuns, $impRuns, $src1, $src2, $imp1, $imp2, $same)
  Res "1.4 #54 confirmed" ("{0}: confirmed elites, search {1}, import {2}" -f $(if ($null -ne $srcConf -and "$srcConf" -eq "$impConf") { 'pass' } else { 'FAIL' }), $srcConf, $impConf)
} catch { Res "1.4" "FAIL: $_ (line $($_.InvocationInfo.ScriptLineNumber))" }

$deskEnd = DeskState; L "desktop state at end unchanged: $($deskEnd -eq $desk0)"; if ($deskEnd -ne $desk0) { L "desktop state now: $deskEnd" }
L "everyday host.lock present at end: $(Test-Path "$env:LOCALAPPDATA\jetcarp\host.lock") (at start: $everydayLock)"
L "jetcarp processes at end: $(Procs)"
L "=== Phase 1 ends"
"phase 1 done"
