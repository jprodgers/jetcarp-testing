# A7: jobs wait exit codes, memory caps, a killed detached hunt, the no-GPU fallback (#10).
# Every jetcarp call goes through Start-Process with stdout/stderr redirected to files (no pipes:
# a detached hunt must not inherit one), and we wait on that process only.
. "$PSScriptRoot\env.ps1"
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue
$log = "$T\A7-log.txt"; "" | Out-File -Encoding utf8 $log
$n = 0
function L($s) { $line = "$(Get-Date -Format 'HH:mm:ss.fff') $s"; $line | Out-File -Encoding utf8 -Append $log; $line }
function JC([string]$argList, [int]$timeoutS = 0) {
  $script:n++; $o = "$T\A7-out\$($script:n).out"; $e = "$T\A7-out\$($script:n).err"
  $t0 = Get-Date
  $p = Start-Process -FilePath $J -ArgumentList $argList -NoNewWindow -PassThru -RedirectStandardOutput $o -RedirectStandardError $e
  $h = $p.Handle  # keep a handle so ExitCode is available
  if ($timeoutS -gt 0) { if (-not $p.WaitForExit($timeoutS * 1000)) { return [pscustomobject]@{ code = 'TIMEOUT'; secs = $timeoutS; out = ''; pid = $p.Id } } } else { $p.WaitForExit() }
  $secs = ((Get-Date) - $t0).TotalSeconds
  $text = ((Get-Content $o -Raw -ErrorAction SilentlyContinue) + (Get-Content $e -Raw -ErrorAction SilentlyContinue))
  [pscustomobject]@{ code = $p.ExitCode; secs = $secs; out = "$text".Trim(); pid = $p.Id }
}
function Show($label, $r) { L ("{0} -> exit {1} in {2:n2} s" -f $label, $r.code, $r.secs); ($r.out -split "`r?`n" | Where-Object { $_ -notmatch '^\s*$' } | Select-Object -Last 12) | ForEach-Object { L "    $_" } }
New-Item -ItemType Directory -Force "$T\A7-out" | Out-Null

# 1. A detached hunt that finishes; jobs wait -> 0.
$r = JC "search hunt --soups 3000 --detach --label wait-done"; Show "search hunt --soups 3000 --detach --label wait-done" $r
$r = JC "jobs wait 5"; Show "jobs wait 5" $r

# 2. A memory-capped hunt (foreground): should pause; jobs wait --timeout 5 -> 3.
$r = JC "search hunt --soups 2000000 --max-rss-gb 0.05 --label capped" 600
if ($r.code -eq 'TIMEOUT') { L "capped hunt still running after 600 s: stopping job 6"; Show "jobs stop 6" (JC "jobs stop 6"); Start-Sleep 5 }
Show "search hunt --soups 2000000 --max-rss-gb 0.05 --label capped" $r
$r = JC "jobs status 6"; Show "jobs status 6" $r
$r = JC "jobs wait 6 --timeout 5"; Show "jobs wait 6 --timeout 5" $r

# 3. A detached hunt killed with Stop-Process -Force; jobs wait --timeout 120 -> 6.
$r = JC "search hunt --soups 2000000 --detach --label to-kill"; Show "search hunt --soups 2000000 --detach --label to-kill" $r
Start-Sleep 10
$procs = Get-CimInstance Win32_Process -Filter "Name = 'jetcarp.exe'" | Select-Object ProcessId, CreationDate, CommandLine
$procs | ForEach-Object { L "  process $($_.ProcessId) started $($_.CreationDate): $($_.CommandLine)" }
$victim = $procs | Sort-Object CreationDate -Descending | Select-Object -First 1
L "killing $($victim.ProcessId) with Stop-Process -Force"
$tk = Get-Date; Stop-Process -Id $victim.ProcessId -Force
$r = JC "jobs wait 7 --timeout 120"; L ("  (killed {0:n1} s before wait returned)" -f ((Get-Date) - $tk).TotalSeconds); Show "jobs wait 7 --timeout 120" $r
$r = JC "jobs wait 7 --timeout 2"; Show "jobs wait 7 --timeout 2" $r
$r = JC "jobs status 7"; Show "jobs status 7" $r

# 4. Resume the killed job for a minute.
$r = JC "jobs resume 7 --minutes 1" 300; Show "jobs resume 7 --minutes 1" $r
$r = JC "jobs status 7"; Show "jobs status 7 (after resume)" $r

# 5. GPU off, hunt asked for --gpu: should run on the CPU with a note (#10).
$env:JETCARP_GPU = "off"
$r = JC "search hunt --gpu --soups 500 --label no-gpu" 600; Show "JETCARP_GPU=off search hunt --gpu --soups 500 --label no-gpu" $r
Remove-Item Env:JETCARP_GPU
L "done"
