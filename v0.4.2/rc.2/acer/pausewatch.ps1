# Step 7 watcher: every 2 s, log the host's pause reasons, its generation and the power state (on mains or battery) to
# $OUTDIR\2.D-pauses.txt, writing only when something changes (and a heartbeat every minute).
# Stops after -Minutes or when $OUTDIR\pausewatch.stop appears.
param([int]$Minutes = 20)
. "$PSScriptRoot\env2.ps1"
$log = "$OUTDIR\2.D-pauses.txt"
Add-Type -AssemblyName System.Windows.Forms
$end = (Get-Date).AddMinutes($Minutes); $prev = ''; $beat = Get-Date; $prevGen = $null
"$(Get-Date -Format 'HH:mm:ss') pausewatch start" | Out-File -Encoding utf8 -Append $log
while ((Get-Date) -lt $end -and -not (Test-Path "$OUTDIR\pausewatch.stop")) {
  $ps = [Windows.Forms.SystemInformation]::PowerStatus
  $power = "power $($ps.PowerLineStatus), battery $([Math]::Round($ps.BatteryLifePercent * 100))%"
  $st = $null; try { $st = & $J host status --json | ConvertFrom-Json } catch {}
  if ($st -and $st.running) {
    $gen = $st.screens[0].stage.generation
    $moving = if ($null -ne $prevGen) { if ($gen -gt $prevGen) { 'moving' } else { 'still' } } else { '?' }
    $prevGen = $gen
    $why = if ($st.paused_why) { $st.paused_why -join '; ' } else { '-' }
    $state = "paused_why: $why | paused $($st.paused) | generations $moving | $power"
  } else { $state = "host not running | $power" }
  if ($state -ne $prev -or ((Get-Date) - $beat).TotalSeconds -ge 60) {
    "$(Get-Date -Format 'HH:mm:ss') $state$(if ($st) { " | gen $gen" })" | Out-File -Encoding utf8 -Append $log
    $prev = $state; $beat = Get-Date
  }
  Start-Sleep 2
}
"$(Get-Date -Format 'HH:mm:ss') pausewatch end" | Out-File -Encoding utf8 -Append $log
