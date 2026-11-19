# 2.4 (A4): the smart JACA search with parents from job 2 (no reviews, so its best runs: #25).
. "$PSScriptRoot\env2.ps1"
$log = "$OUTDIR\2.4-log.txt"
function Lg($m) { $line = "$(Get-Date -Format 'HH:mm:ss') $m"; $line | Out-File -Encoding utf8 -Append $log; $line }
"" | Out-File -Encoding utf8 $log
Lg "start: search explore --gpu --families jaca --parents-from 2 --reviewed keep,maybe --minutes 6 --label smart-jaca"
$px = Start-Process -FilePath $J -ArgumentList "search explore --gpu --families jaca --parents-from 2 --reviewed keep,maybe --minutes 6 --label smart-jaca" -NoNewWindow -PassThru -RedirectStandardOutput "$OUTDIR\2.4-explore.out" -RedirectStandardError "$OUTDIR\2.4-explore.err"
$null = $px.Handle
Start-Sleep 20
& $J jobs status 3 > "$OUTDIR\2.4-status-early.txt" 2>&1
$px.WaitForExit()
Lg "explore exit $($px.ExitCode)"
& $J jobs status 3 > "$OUTDIR\2.4-status.txt" 2>&1
& $J jobs status 3 --json > "$OUTDIR\2.4-status.json" 2>&1
& $J jobs runs 3 --limit 0 --format csv --out "$OUTDIR\2.4-runs.csv" > "$OUTDIR\2.4-runs.out" 2>&1
& $J jobs runs 3 --family jaca --limit 5 --measures all --format csv --out "$OUTDIR\2.4-runs-signs.csv" > $null 2>&1
Lg "done"
