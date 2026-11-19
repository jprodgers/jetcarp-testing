# 2.6 (A6): the scored search (job 4), its status, and its runs with every measure.
. "$PSScriptRoot\env2.ps1"
Set-Location $OUTDIR
$px = Start-Process -FilePath $J -ArgumentList "search explore --gpu --families jaca --score `"$OUTDIR\2.6-model.json`" --minutes 3 --label scored" -NoNewWindow -PassThru -RedirectStandardOutput "$OUTDIR\2.6-explore.out" -RedirectStandardError "$OUTDIR\2.6-explore.err"
$null = $px.Handle; $px.WaitForExit()
"explore exit $($px.ExitCode)" | Out-File -Encoding utf8 "$OUTDIR\2.6-scored-log.txt"
& $J jobs status 4 > "$OUTDIR\2.6-status4.txt" 2>&1
& $J jobs status 4 --json > "$OUTDIR\2.6-status4.json" 2>&1
& $J jobs runs 4 --measures all --format csv --limit 0 --out "$OUTDIR\2.6-all.csv" > "$OUTDIR\2.6-all.out" 2>&1
& $J jobs runs 4 --measures all --format json --limit 5 > "$OUTDIR\2.6-five.json" 2>&1
"done" | Out-File -Encoding utf8 -Append "$OUTDIR\2.6-scored-log.txt"
