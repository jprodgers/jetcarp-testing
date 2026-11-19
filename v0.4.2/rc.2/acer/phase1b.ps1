# v0.4.2-rc.2, Phase 1 follow-up on the Acer: finish 1.4 (phase1.ps1's wait loop saw the resumed job as
# gone 0.2 s after `jobs resume --detach`, and `jobs resume` without --minutes has no end), then rerun the
# RTX crash in 1.3 (tests\recovery.rs, STATUS_ACCESS_VIOLATION).
# Variable names: never $t, $j or $r (PowerShell names ignore case).
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$T = "$env:USERPROFILE\jetcarp-rc-042b"
$J = "$T\bin\jetcarp.exe"
$LOG = "$T\logs"
Set-Location $T
$env:JETCARP_CONFIG_DIR = "$T\config"; $env:JETCARP_DATA_DIR = "$T\data"; $env:JETCARP_OUT = "$T\out"
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND, Env:JETCARP_LIBRARY -ErrorAction SilentlyContinue
$MAIN = "$LOG\phase1b.log"
$SUM = [ordered]@{}
$job = 2
function L([string]$msg) { $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg"; $line | Out-File -Encoding utf8 -Append $MAIN }
function Res([string]$step, [string]$text) { $SUM[$step] = $text; L "RESULT $step : $text" }
function JX([string]$argList, [string]$base, [int]$timeoutS = 0, [switch]$noKill) {
  $o = "$LOG\$base.out"; $e = "$LOG\$base.err"; $t0 = Get-Date
  $p = Start-Process -FilePath $J -ArgumentList $argList -NoNewWindow -PassThru -RedirectStandardOutput $o -RedirectStandardError $e
  $null = $p.Handle
  $done = if ($timeoutS -gt 0) { $p.WaitForExit($timeoutS * 1000) } else { $p.WaitForExit(); $true }
  if (-not $done -and -not $noKill) { try { Stop-Process -Id $p.Id -Force } catch {} }
  $code = if ($done) { $p.ExitCode } else { 'TIMEOUT' }
  $secs = ((Get-Date) - $t0).TotalSeconds
  L ("jetcarp {0} -> exit {1} in {2:n1} s ({3})" -f $argList, $code, $secs, $base)
  [pscustomobject]@{ code = $code; secs = $secs; out = "$(Get-Content $o -Raw -ErrorAction SilentlyContinue)"; err = "$(Get-Content $e -Raw -ErrorAction SilentlyContinue)"; proc = $p }
}
function Procs { (Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId)<-$($_.ParentProcessId) $($_.Name) $(($_.CommandLine -split ' jobs ')[1])" }) -join ' | ' }
function Worker { Get-CimInstance Win32_Process -Filter "Name='jetcarp.exe'" | Where-Object { $_.CommandLine -like "*jobs resume $job *" } }
$prog = "$LOG\1.4-progress.txt"
$peakWs = 0; $rates = New-Object System.Collections.Generic.List[int]
function Probe([string]$tagName, [string]$base = '1.4b-probe') {
  $st = JX "jobs status $job --json" $base 60
  try { $js = $st.out | ConvertFrom-Json } catch { $js = $null }
  $w = Worker | Select-Object -First 1
  $ws = 0; if ($w) { $pp = Get-Process -Id $w.ProcessId -ErrorAction SilentlyContinue; if ($pp) { $ws = [math]::Round($pp.WorkingSet64 / 1MB) } }
  if ($ws -gt $script:peakWs) { $script:peakWs = $ws }
  $line = if ($js) { $js.line } else { "(no status) $($st.err)" }
  if ($tagName -eq 'resumed' -and $line -match '\((\d+)/s\)') { $script:rates.Add([int]$Matches[1]) }
  $extra = if ($js) { "status $($js.status), stale $($js.stale), resumable $($js.resumable), elapsed $([math]::Round([double]$js.progress.elapsed_s)) s" } else { '' }
  ("{0} [{1}] ws {2} MB | {3} | {4}" -f (Get-Date -Format 'HH:mm:ss'), $tagName, $ws, $extra, $line) | Out-File -Encoding utf8 -Append $prog
  return $js
}

L "=== Phase 1 follow-up starts; processes: $(Procs)"
try {
  # 1. Let the resumed session run to about 2 hours of search in all (elapsed_s 7200), probing each minute.
  $cap = (Get-Date).AddMinutes(75)
  while ($true) {
    $js = Probe 'resumed'
    if (-not (Worker)) { L "the resumed worker is gone before the 2 h mark"; break }
    if ($js -and [double]$js.progress.elapsed_s -ge 7170) { break }
    if ((Get-Date) -gt $cap) { L "wall-clock cap reached"; break }
    Start-Sleep 60
  }
  $rateTxt = if ($rates.Count) { "{0} probes after the resume: {1} at 0/s, median {2}/s" -f $rates.Count, ($rates | Where-Object { $_ -eq 0 }).Count, (($rates | Sort-Object)[[int][math]::Floor($rates.Count / 2)]) } else { 'no rates' }
  L "1.4b rates: $rateTxt; peak working set after the resume $peakWs MB"

  # 2. A second hard kill at the 2 h mark, watched closely: what jobs status says, and when.
  $victims = @(Worker)
  L "processes before the second kill: $(Procs)"
  $victims | ForEach-Object { L "killing $($_.ProcessId): $($_.CommandLine)"; Stop-Process -Id $_.ProcessId -Force }
  $tk = Get-Date
  $obs = New-Object System.Collections.Generic.List[string]
  foreach ($at in 2, 15, 30, 45, 60, 90, 120) {
    while (((Get-Date) - $tk).TotalSeconds -lt $at) { Start-Sleep -Milliseconds 250 }
    $js = Probe "after kill +$at s" "1.4b-status-kill-$at"
    $txt = JX "jobs status $job" "1.4b-status-kill-$at-text" 60
    $first = "$(($txt.out -split "`r?`n") | Select-Object -Skip 1 -First 1)".Trim()
    $obs.Add(("+{0} s: json status {1}, stale {2}, resumable {3}; text '{4}'" -f $at, $js.status, $js.stale, $js.resumable, $first))
    L "+$at s processes: $(Procs)"
  }
  $obs | ForEach-Object { L "1.4b after kill $_" }
  $w2 = JX "jobs wait $job --timeout 60" "1.4b-wait-after-kill" 90

  # 3. End the job cleanly: one more session of a minute, in the foreground (it stops at a checkpoint).
  $fr = JX "jobs resume $job --minutes 1" "1.4b-resume-final" 900 -noKill
  if ($fr.code -eq 'TIMEOUT') { L "the 1-minute session is still going after 15 min: jobs stop"; $null = JX "jobs stop $job" "1.4b-stop" 60; $fr.proc.WaitForExit(300000) | Out-Null }
  $endWait = JX "jobs wait $job --timeout 60" "1.4b-wait-end" 90
  $fin = JX "jobs status $job --json" "1.4b-status-final" 120; Copy-Item "$LOG\1.4b-status-final.out" "$LOG\1.4b-status-final.json" -Force
  $fint = JX "jobs status $job" "1.4b-status-final-text" 60
  $fj = $fin.out | ConvertFrom-Json
  $mem = if ("$($fint.out)" -match '([\d.]+) GB of memory') { "$($Matches[1]) GB" } else { '?' }
  $srcRuns = [int]$fj.progress.screened + [int]$fj.progress.confirmed
  $null = JX "jobs runs $job --limit 0 --format csv --out `"$LOG\1.4b-src-runs-stage1.csv`"" "1.4b-src-runs1" 600
  $null = JX "jobs runs $job --stage 2 --limit 0 --format csv --out `"$LOG\1.4b-src-runs-stage2.csv`"" "1.4b-src-runs2" 600
  $src1 = [math]::Max(0, (Get-Content "$LOG\1.4b-src-runs-stage1.csv" -ErrorAction SilentlyContinue | Measure-Object -Line).Lines - 1)
  $src2 = [math]::Max(0, (Get-Content "$LOG\1.4b-src-runs-stage2.csv" -ErrorAction SilentlyContinue | Measure-Object -Line).Lines - 1)
  L "1.4b final: status $($fj.status), resume-final exit $($fr.code), wait exit $($endWait.code); screened $($fj.progress.screened) + confirmed $($fj.progress.confirmed) = $srcRuns; csv stage 1 $src1, stage 2 $src2; elapsed $([math]::Round([double]$fj.progress.elapsed_s / 60)) min; $mem"

  # 4. The pack, with no jobs seal, and an import into a fresh library.
  $ex = JX "pack export --to `"$T\P14b-pack`" --feed rc2-long --no-media" "1.4b-pack-export" 1800
  $packBytes = (Get-ChildItem "$T\P14b-pack" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
  $sealMsg = (("$($ex.out)$($ex.err)" -split "`r?`n") | Where-Object { $_ -match 'seal' } | Select-Object -First 1)
  $ck = JX "pack check `"$T\P14b-pack`"" "1.4b-pack-check" 1800
  New-Item -ItemType Directory -Force "$T\import14b" | Out-Null
  $im = JX "pack import `"$T\P14b-pack`" --library `"$T\import14b\library.sqlite`"" "1.4b-pack-import" 1800
  $il = (JX "jobs list --library `"$T\import14b\library.sqlite`" --json" "1.4b-import-list" 120).out
  $ijob = $null; try { $ilj = $il | ConvertFrom-Json; $arr = if ($ilj.jobs) { $ilj.jobs } else { $ilj }; $ijob = ($arr | Where-Object { $_.kind -eq 'explore' } | Select-Object -First 1).job } catch {}
  L "1.4b imported explore job: $ijob"
  $null = JX "jobs runs $ijob --library `"$T\import14b\library.sqlite`" --limit 0 --format csv --out `"$LOG\1.4b-import-runs-stage1.csv`"" "1.4b-import-runs1" 600
  $null = JX "jobs runs $ijob --library `"$T\import14b\library.sqlite`" --stage 2 --limit 0 --format csv --out `"$LOG\1.4b-import-runs-stage2.csv`"" "1.4b-import-runs2" 600
  $imp1 = [math]::Max(0, (Get-Content "$LOG\1.4b-import-runs-stage1.csv" -ErrorAction SilentlyContinue | Measure-Object -Line).Lines - 1)
  $imp2 = [math]::Max(0, (Get-Content "$LOG\1.4b-import-runs-stage2.csv" -ErrorAction SilentlyContinue | Measure-Object -Line).Lines - 1)
  $is = JX "jobs status $ijob --library `"$T\import14b\library.sqlite`" --json" "1.4b-import-status" 120
  $impRuns = try { $isj = $is.out | ConvertFrom-Json; [int]$isj.progress.screened + [int]$isj.progress.confirmed } catch { -1 }
  $same = $false
  if ($imp1 -eq $src1 -and $imp2 -eq $src2) {
    $a1 = Import-Csv "$LOG\1.4b-src-runs-stage1.csv" | ForEach-Object { "$($_.rule)|$($_.tiling)|$($_.rng)|$($_.score)" } | Sort-Object
    $b1 = Import-Csv "$LOG\1.4b-import-runs-stage1.csv" | ForEach-Object { "$($_.rule)|$($_.tiling)|$($_.rng)|$($_.score)" } | Sort-Object
    $same = -not (Compare-Object $a1 $b1 -SyncWindow 0 | Select-Object -First 1)
  }
  $pass = ($ex.code -eq 0) -and ($ck.code -eq 0) -and ($im.code -eq 0) -and ($src1 -gt 0) -and ($imp1 -eq $src1) -and ($imp2 -eq $src2)
  Res "1.4b end and pack" ("{0}: job ended '{1}' after {2} min; source runs {3} (screened {4} + confirmed {5}; csv {6} + {7}); memory at end {8}; {9}; pack {10:n1} MB, export exit {11} ('{12}'), check {13}, import {14}; imported runs {15} (csv {16} + {17}, same rows: {18})" -f $(if ($pass) { 'pass' } else { 'FAIL' }), $fj.status, [math]::Round([double]$fj.progress.elapsed_s / 60), $srcRuns, $fj.progress.screened, $fj.progress.confirmed, $src1, $src2, $mem, $rateTxt, ($packBytes / 1MB), $ex.code, $sealMsg, $ck.code, $im.code, $impRuns, $imp1, $imp2, $same)
  Res "1.4b status after the second kill" ($obs -join ' / ')
} catch { Res "1.4b" "FAIL: $_" }

# 5. The RTX crash in 1.3: rerun the same test binary, in the same scratch environment.
try {
  L "=== recovery reruns"
  $bin = Get-ChildItem "$T\src\target\release\deps\recovery-*.exe" | Select-Object -First 1
  $env:JETCARP_CONFIG_DIR = "$T\scratch-tests\config"; $env:JETCARP_DATA_DIR = "$T\scratch-tests\data"; $env:JETCARP_OUT = "$T\scratch-tests\out"
  $env:CARGO_MANIFEST_DIR = "$T\src\crates\jetcarp-gpu"
  $runs = @()
  foreach ($case in @(@{ g = 'RTX'; a = '--nocapture'; n = 5 }, @{ g = 'RTX'; a = '--nocapture --test-threads=1'; n = 3 }, @{ g = 'UHD'; a = '--nocapture'; n = 3 })) {
    $env:JETCARP_GPU = $case.g
    for ($i = 1; $i -le $case.n; $i++) {
      $base = "1.3-recovery-$($case.g.ToLower())-$(if ($case.a -match 'threads') { 'serial' } else { 'par' })-$i"
      $p = Start-Process -FilePath $bin.FullName -ArgumentList $case.a -WorkingDirectory "$T\src\crates\jetcarp-gpu" -NoNewWindow -PassThru -RedirectStandardOutput "$LOG\$base.out" -RedirectStandardError "$LOG\$base.err"
      $null = $p.Handle
      if (-not $p.WaitForExit(600000)) { Stop-Process -Id $p.Id -Force; $code = 'TIMEOUT' } else { $code = '0x{0:X8}' -f $p.ExitCode }
      $okNames = (Select-String -Path "$LOG\$base.out" -Pattern '^test (\S+) \.\.\. ok' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ','
      L "$base exit $code; ok: $okNames"
      $runs += [pscustomobject]@{ case = "$($case.g) $($case.a)"; code = $code; ok = $okNames }
    }
  }
  $txt = ($runs | Group-Object case | ForEach-Object { $c = $_.Group; "{0}: {1} of {2} crashed ({3})" -f $_.Name, ($c | Where-Object { $_.code -ne '0x00000000' }).Count, $c.Count, (($c | ForEach-Object code) -join ' ') }) -join '; '
  Res "1.3 recovery reruns" $txt
} catch { Res "1.3 recovery reruns" "FAIL: $_" }
$env:JETCARP_CONFIG_DIR = "$T\config"; $env:JETCARP_DATA_DIR = "$T\data"; $env:JETCARP_OUT = "$T\out"
Remove-Item Env:JETCARP_GPU, Env:CARGO_MANIFEST_DIR -ErrorAction SilentlyContinue

L "jetcarp processes at end: $(Procs)"
$SUM.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" } | Set-Content -Encoding utf8 "$LOG\summary-b.txt"
L "=== Phase 1 follow-up ends"
"phase 1 follow-up done"
