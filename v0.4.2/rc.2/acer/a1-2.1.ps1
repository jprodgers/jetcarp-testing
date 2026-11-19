# 2.1 (A1): the GPU explore search with no --gpu, 10 minutes, then its status and runs.
. "$PSScriptRoot\env2.ps1"
$log = "$OUTDIR\2.1-log.txt"
function Lg([string]$m) { "$(Get-Date -Format 'HH:mm:ss') $m" | Out-File -Encoding utf8 -Append $log }
Lg "start: search explore --families life_like,generations,jaca,cyclic --minutes 10 --label gpu-mix"
$t0 = Get-Date
$px = Start-Process -FilePath $J -ArgumentList "search explore --families life_like,generations,jaca,cyclic --minutes 10 --label gpu-mix" -NoNewWindow -PassThru -RedirectStandardOutput "$OUTDIR\2.1-explore.out" -RedirectStandardError "$OUTDIR\2.1-explore.err"
$null = $px.Handle
# Sample the process's CPU and working set every 15 s while it runs.
$prev = $null
while (-not $px.HasExited) {
  Start-Sleep 15
  try { $pp = Get-Process -Id $px.Id -ErrorAction Stop; $cpu = $pp.TotalProcessorTime.TotalSeconds; $d = if ($prev) { ($cpu - $prev) / 15 } else { 0 }; $prev = $cpu
    Lg ("ws {0:n0} MB, cpu {1:n1} cores" -f ($pp.WorkingSet64 / 1MB), $d) } catch {}
}
$px.WaitForExit()
Lg ("explore exit {0} after {1:n1} min" -f $px.ExitCode, ((Get-Date) - $t0).TotalMinutes)
& $J jobs status 1 > "$OUTDIR\2.1-status.txt" 2>&1
& $J jobs status 1 --json > "$OUTDIR\2.1-status.json" 2>&1
& $J jobs runs 1 --limit 0 --format csv --out "$OUTDIR\2.1-runs.csv" > "$OUTDIR\2.1-runs.out" 2>&1
Lg "done"
