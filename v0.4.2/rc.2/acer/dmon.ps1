# Sitting A-4 monitor: every -Every seconds, one line in $OUTDIR\2.D-monitor.txt with the host's status (JSON), its CPU
# (percent of the whole machine) and Windows' own per-process GPU engine use, per adapter, for the host and the app.
# Stops when $OUTDIR\dmon.stop appears, or after -Hours.
param([int]$Every = 5, [double]$Hours = 4)
. "$PSScriptRoot\env2.ps1"
$log = "$OUTDIR\2.D-monitor.txt"
$cores = [Environment]::ProcessorCount
# Adapter LUID (low part, hex) -> short name, from the DirectX registry keys (read only).
$names = @{}
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\DirectX' -ErrorAction SilentlyContinue | ForEach-Object {
  $k = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
  if ($k.AdapterLuid -and $k.Description) {
    $low = '{0:X8}' -f ([uint64]$k.AdapterLuid -band 0xFFFFFFFF)
    $short = if ($k.Description -match 'NVIDIA') { 'RTX' } elseif ($k.Description -match 'Intel') { 'UHD' } else { $k.Description.Substring(0, [Math]::Min(12, $k.Description.Length)) }
    $names[$low] = $short
  }
}
function GpuUse([int]$procId) {
  if (-not $procId) { return '' }
  $c = Get-Counter "\GPU Engine(pid_$($procId)_*)\Utilization Percentage" -ErrorAction SilentlyContinue
  if (-not $c) { return 'none' }
  $sums = @{}
  foreach ($s in $c.CounterSamples) {
    if ($s.InstanceName -match 'luid_0x[0-9a-f]+_0x([0-9a-f]+)_phys_\d+_eng_\d+_engtype_(\w+)') {
      $a = $names[$Matches[1].ToUpper()]; if (-not $a) { $a = $Matches[1] }
      $key = "$a/$($Matches[2])"; $sums[$key] = [double]$sums[$key] + $s.CookedValue
    }
  }
  ($sums.GetEnumerator() | Where-Object { $_.Value -ge 0.5 } | Sort-Object Value -Descending | ForEach-Object { '{0} {1:n0}%' -f $_.Key, $_.Value }) -join ', '
}
$end = (Get-Date).AddHours($Hours); $prevCpu = @{}; $prevT = Get-Date
"$(Get-Date -Format 'HH:mm:ss') monitor start; adapters: $(($names.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', '); $cores threads" | Out-File -Encoding utf8 -Append $log
while ((Get-Date) -lt $end -and -not (Test-Path "$OUTDIR\dmon.stop")) {
  $t0 = Get-Date
  $tmp = "$OUTDIR\dmon-status.json"
  $p = Start-Process $J -ArgumentList 'host status --json' -NoNewWindow -PassThru -RedirectStandardOutput $tmp -RedirectStandardError "$OUTDIR\dmon-status-err.txt"
  $null = $p.Handle; $p.WaitForExit()
  $st = $null; try { $st = Get-Content $tmp -Raw | ConvertFrom-Json } catch {}
  $hostId = if ($st -and $st.running) { [int]$st.pid } else { 0 }
  $appId = Get-CimInstance Win32_Process -Filter "Name='jetcarp.exe'" | Where-Object { $_.ExecutablePath -like "$T\bin\*" -and $_.CommandLine -match 'jetcarp\.exe"?\s*$' } | Select-Object -First 1 -ExpandProperty ProcessId
  $cpuText = ''
  if ($hostId) {
    $hp = Get-Process -Id $hostId -ErrorAction SilentlyContinue
    if ($hp) {
      $now = Get-Date; $cpu = $hp.TotalProcessorTime.TotalSeconds
      if ($prevCpu.ContainsKey($hostId)) { $cpuText = '{0:n1}%' -f (100 * ($cpu - $prevCpu[$hostId]) / ($now - $prevT).TotalSeconds / $cores) }
      $prevCpu[$hostId] = $cpu; $prevT = $now
    }
  }
  $g = "host: $(GpuUse $hostId)"; if ($appId) { $g += "; app: $(GpuUse $appId)" }
  if ($st -and $st.running) {
    $scr = foreach ($s in $st.screens) { $sg = $s.stage; "screen: $($sg.rotation) · $($sg.label) ($($sg.number) of $($sg.count)) · gen $($sg.generation) · $($sg.cells) cells of $($sg.cell_px) px$(if ($sg.tuned) { ' (tuned)' }) · $($sg.frame_rate) fps, $($sg.speed) gens/s$(if ($sg.paused) { ' · paused' }) · $($s.place)" }
    $state = "pid $hostId, $($st.memory_mb) MB, pacing $($st.pacing), max $($st.max_fps), fps $($st.fps)$(if ($st.paused) { ', PAUSED' })$(if ($st.paused_why) { ', why: ' + ($st.paused_why -join '; ') })$(if ($st.tuning.running) { ', TUNING' }), wallpaper $($st.wallpaper)"
    $line = "{0} cpu(host) {1,6} | gpu [{2}] | {3} | {4}" -f (Get-Date -Format 'HH:mm:ss'), $cpuText, $g, $state, ($scr -join ' || ')
  } else {
    $line = "{0} host not running ({1}) | gpu [{2}]" -f (Get-Date -Format 'HH:mm:ss'), ((Get-Content "$OUTDIR\dmon-status-err.txt" -Raw) -replace '\s+', ' ').Trim(), $g
  }
  $line | Out-File -Encoding utf8 -Append $log
  $wait = $Every - ((Get-Date) - $t0).TotalSeconds
  if ($wait -gt 0) { Start-Sleep -Milliseconds ([int]($wait * 1000)) }
}
"$(Get-Date -Format 'HH:mm:ss') monitor end" | Out-File -Encoding utf8 -Append $log
