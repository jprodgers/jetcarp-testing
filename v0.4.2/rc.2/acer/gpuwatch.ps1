# Step 6 watcher: when host.json's or gpu.json's GPU setting changes, wait 4 s, then log host status (its GPU note and
# screen line) and doctor's three GPU lines to 2.D-log.txt, with the full outputs in 2.D-out. Stops after -Minutes or
# when $OUTDIR\gpuwatch.stop appears.
param([int]$Minutes = 20)
. "$PSScriptRoot\dlib.ps1"
function Setting { $h = (Get-Content "$env:JETCARP_CONFIG_DIR\host.json" -Raw | ConvertFrom-Json).gpu; $s = (Get-Content "$env:JETCARP_CONFIG_DIR\gpu.json" -Raw | ConvertFrom-Json).gpu; "desktop background '$h', shared '$s'" }
$prev = Setting; DLog "gpuwatch start: $prev"
$end = (Get-Date).AddMinutes($Minutes); $n = 0
while ((Get-Date) -lt $end -and -not (Test-Path "$OUTDIR\gpuwatch.stop")) {
  Start-Sleep 1
  $now = try { Setting } catch { $prev }
  if ($now -ne $prev) {
    $n++; DLog "gpuwatch: setting changed: $now (was $prev)"; $prev = $now
    Start-Sleep 4
    $st = JRun "host status" "20-gpuwatch-$n-status"
    $dr = JRun "doctor" "20-gpuwatch-$n-doctor"
    DLog ("gpuwatch {0}: status says: {1}" -f $n, (($st | Where-Object { $_ -match 'note: GPU|screen 0|^running' }) -join ' || '))
    DLog ("gpuwatch {0}: doctor says: {1}" -f $n, (($dr | Where-Object { $_ -match '^GPU:|the app:|the desktop background:' }) -join ' || '))
  }
}
DLog "gpuwatch end"
