# 2.7 (A7): jobs wait exit codes, memory caps, a killed detached hunt, the no-GPU note (#31), and jobs wait
# printing only changed lines (#32). rc.1's A7-steps.ps1 with rc.2 names; job ids are read from the output.
# Every jetcarp call goes through Start-Process with stdout/stderr redirected to files (no pipes: a detached
# hunt must not inherit one), and we wait on that process only. Names: no $r/$res ($RES is the results path).
. "$PSScriptRoot\env2.ps1"
$log = "$OUTDIR\2.7-log.txt"; "" | Out-File -Encoding utf8 $log
$n = 0
function L($m) { $line = "$(Get-Date -Format 'HH:mm:ss.fff') $m"; $line | Out-File -Encoding utf8 -Append $log; $line }
function JC([string]$argList, [int]$timeoutS = 0) {
  $script:n++; $o = "$OUTDIR\2.7-out\$($script:n).out"; $e = "$OUTDIR\2.7-out\$($script:n).err"
  "$argList" | Out-File -Encoding utf8 "$OUTDIR\2.7-out\$($script:n).cmd"
  $t0 = Get-Date
  $p = Start-Process -FilePath $J -ArgumentList $argList -NoNewWindow -PassThru -RedirectStandardOutput $o -RedirectStandardError $e
  $h = $p.Handle
  if ($timeoutS -gt 0) { if (-not $p.WaitForExit($timeoutS * 1000)) { return [pscustomobject]@{ code = 'TIMEOUT'; secs = $timeoutS; out = ''; err = '' } } } else { $p.WaitForExit() }
  $secs = ((Get-Date) - $t0).TotalSeconds
  [pscustomobject]@{ code = $p.ExitCode; secs = $secs; out = "$(Get-Content $o -Raw -ErrorAction SilentlyContinue)".Trim(); err = "$(Get-Content $e -Raw -ErrorAction SilentlyContinue)".Trim() }
}
function Show($label, $rv) { L ("{0} -> exit {1} in {2:n2} s" -f $label, $rv.code, $rv.secs); ((($rv.out + "`n" + $rv.err) -split "`r?`n") | Where-Object { $_ -notmatch '^\s*$' } | Select-Object -Last 12) | ForEach-Object { L "    $_" } }
function JobId($rv) { if ("$($rv.out)`n$($rv.err)" -match 'hunt (?:search )?job (\d+)') { [int]$Matches[1] } }
New-Item -ItemType Directory -Force "$OUTDIR\2.7-out" | Out-Null

# 1. A detached hunt that finishes; jobs wait -> 0 (and #32: only changed lines while it runs).
$rv = JC "search hunt --soups 3000 --detach --label wait-done"; Show "search hunt --soups 3000 --detach --label wait-done" $rv
$j1 = JobId $rv; L "job: $j1"
$rv = JC "jobs wait $j1"; Show "jobs wait $j1" $rv

# 2. A memory-capped hunt (foreground): should pause; jobs wait --timeout 5 -> 3.
$rv = JC "search hunt --soups 2000000 --max-rss-gb 0.05 --label capped" 600
Show "search hunt --soups 2000000 --max-rss-gb 0.05 --label capped" $rv
$j2 = JobId $rv; L "job: $j2"
if ($rv.code -eq 'TIMEOUT') { L "capped hunt still running after 600 s: stopping it"; Show "jobs stop $j2" (JC "jobs stop $j2"); Start-Sleep 5 }
$rv = JC "jobs status $j2"; Show "jobs status $j2" $rv
$rv = JC "jobs wait $j2 --timeout 5"; Show "jobs wait $j2 --timeout 5" $rv

# 3. A detached hunt killed with Stop-Process -Force; jobs wait --timeout 120 -> 6.
$rv = JC "search hunt --soups 2000000 --detach --label to-kill"; Show "search hunt --soups 2000000 --detach --label to-kill" $rv
$j3 = JobId $rv; L "job: $j3"
Start-Sleep 10
Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { L "  process $($_.ProcessId) (parent $($_.ParentProcessId)) $($_.Name): $($_.CommandLine)" }
$victim = Get-CimInstance Win32_Process -Filter "Name = 'jetcarp.exe'" | Where-Object { $_.CommandLine -like "*jobs resume $j3 *" } | Select-Object -First 1
L "killing $($victim.ProcessId) with Stop-Process -Force"
$tk = Get-Date; Stop-Process -Id $victim.ProcessId -Force
$rv = JC "jobs wait $j3 --timeout 120"; L ("  (killed {0:n1} s before wait returned)" -f ((Get-Date) - $tk).TotalSeconds); Show "jobs wait $j3 --timeout 120" $rv
$rv = JC "jobs wait $j3 --timeout 2"; Show "jobs wait $j3 --timeout 2" $rv
$rv = JC "jobs status $j3"; Show "jobs status $j3" $rv
Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { L "  left: $($_.ProcessId) $($_.Name): $($_.CommandLine)" }

# 4. Resume the killed job for a minute.
$rv = JC "jobs resume $j3 --minutes 1" 300; Show "jobs resume $j3 --minutes 1" $rv
$rv = JC "jobs status $j3"; Show "jobs status $j3 (after resume)" $rv

# 5. GPU off, hunt asked for --gpu: runs on the CPU and says so (#31).
$env:JETCARP_GPU = "off"
$rv = JC "search hunt --gpu --soups 500 --label no-gpu" 600; Show "JETCARP_GPU=off search hunt --gpu --soups 500 --label no-gpu" $rv
$j4 = JobId $rv
Remove-Item Env:JETCARP_GPU
$rv = JC "jobs status $j4"; Show "jobs status $j4" $rv
L "jobs: wait-done $j1, capped $j2, to-kill $j3, no-gpu $j4"
L "done"
