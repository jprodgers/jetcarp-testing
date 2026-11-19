# rc.4 wave on the Acer, 1.5: the desktop overnight soak (v0.4.2-rc.2.md "1.5 The desktop overnight"; v0.4.2-rc.4.md
# Phase 2, "A idle"). rc.4's host as the desktop background for -Hours, nobody using the laptop; a sample every
# -IntervalS seconds:
#   - `host status --json` (all of it, to soak-status.jsonl): generation, scene, memory, measured speed, held, paused;
#   - the host process: CPU (percent of one core and of the machine), working set, private bytes, handles, threads;
#   - Windows' per-process GPU counters: engine use per adapter (\GPU Engine(pid_N_*)), dedicated and shared memory;
#   - the power source.
# Every hour: a picture of the host's own wallpaper window (t15_shot.ps1, nothing else on the screen), and a commit
# and push of the soak's files (git's messages kept outside the repository). At the end: soak-summary.txt; the host
# is LEFT RUNNING, for Jimmie to look at before it is stopped and the wallpaper checked.
# Rotation: Jimmie's choice (2026-11-17), "Classics, hourly", so the soak also covers scene changes (the Mac's soak,
# on "A classic a day", kept one scene: its question 4). Folder ~\jetcarp-rc4\soak, every JETCARP_* set.
# ASCII only (PowerShell 5.1).
#   powershell -NoProfile -ExecutionPolicy Bypass -File t15_soak.ps1 [-Hours 8] [-IntervalS 300] [-Rotation "Classics, hourly"]
param([double]$Hours = 8, [int]$IntervalS = 300, [string]$Rotation = 'Classics, hourly', [switch]$NoPush)
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$UTF8 = New-Object Text.UTF8Encoding $false
$HERE = $PSScriptRoot
$REPO = (Resolve-Path "$HERE\..\..\..").Path
$S = "$env:USERPROFILE\jetcarp-rc4\soak"
$B = "$env:USERPROFILE\jetcarp-rc-042c\bin\jetcarp.exe"
$LOGD = "$S\logs"
New-Item -ItemType Directory -Force $LOGD, "$S\cwd" | Out-Null
$env:JETCARP_CONFIG_DIR = "$S\config"; $env:JETCARP_DATA_DIR = "$S\data"; $env:JETCARP_OUT = "$S\out"
$env:JETCARP_LIBRARY = "$S\library"; $env:JETCARP_RUNTIME_DIR = "$S\run"
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue
Set-Location "$S\cwd"
$LOGF = "$HERE\soak.log"; $CSV = "$HERE\soak.csv"; $JL = "$HERE\soak-status.jsonl"
$cores = [Environment]::ProcessorCount
function Home([string]$s) { $s.Replace($env:USERPROFILE, '~').Replace($env:USERPROFILE.Replace('\', '\\'), '~') }
function L([string]$s) { $s = Home "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $s"; [IO.File]::AppendAllText($LOGF, "$s`r`n", $UTF8); $s }
# A jetcarp command through Start-Process with its own output files: `host start` leaves a host that would keep a
# pipe open (never pipe it).
$script:N = 0
function Jx([string]$argLine, [int]$timeoutS = 90) {
  $script:N++
  $o = "$LOGD\j-$($script:N)-out.txt"; $e = "$LOGD\j-$($script:N)-err.txt"
  $p = Start-Process $B -ArgumentList $argLine -RedirectStandardOutput $o -RedirectStandardError $e -NoNewWindow -PassThru -WorkingDirectory "$S\cwd"
  $null = $p.Handle
  if (-not $p.WaitForExit($timeoutS * 1000)) { $code = 'none (timed out)' } else { $code = $p.ExitCode }
  $txt = ([string](Get-Content $o -Raw -Encoding UTF8) + [string](Get-Content $e -Raw -Encoding UTF8)).TrimEnd()
  [pscustomobject]@{ code = $code; text = $txt }
}
# Adapter LUID (low part) -> RTX/UHD, from the DirectX registry keys (read only), as rc.2's dmon.ps1.
$names = @{}
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\DirectX' -ErrorAction SilentlyContinue | ForEach-Object {
  $k = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
  if ($k.AdapterLuid -and $k.Description) {
    $low = '{0:X8}' -f ([uint64]$k.AdapterLuid -band 0xFFFFFFFF)
    $names[$low] = if ($k.Description -match 'NVIDIA') { 'RTX' } elseif ($k.Description -match 'Intel') { 'UHD' } else { $k.Description }
  }
}
function Gpu([int]$procId) {
  $r = [ordered]@{ use = ''; total = 0.0; dedicated_mb = ''; shared_mb = '' }
  if (-not $procId) { return $r }
  $c = Get-Counter "\GPU Engine(pid_$($procId)_*)\Utilization Percentage" -SampleInterval 2 -MaxSamples 3 -ErrorAction SilentlyContinue
  $sums = @{}
  if ($c) {
    $ns = @($c).Count
    foreach ($set in $c) { foreach ($s in $set.CounterSamples) {
      if ($s.InstanceName -match 'luid_0x[0-9a-f]+_0x([0-9a-f]+)_phys_\d+_eng_\d+_engtype_(\w+)') {
        $a = $names[$Matches[1].ToUpper()]; if (-not $a) { $a = $Matches[1] }
        $key = "$a/$($Matches[2])"; $sums[$key] = [double]$sums[$key] + $s.CookedValue / $ns
      } } }
  }
  $r.use = ($sums.GetEnumerator() | Where-Object { $_.Value -ge 0.5 } | Sort-Object Value -Descending | ForEach-Object { '{0} {1:n1}%' -f $_.Key, $_.Value }) -join ', '
  $r.total = [math]::Round((($sums.Values | Measure-Object -Sum).Sum) + 0, 1)
  $m = Get-Counter "\GPU Process Memory(pid_$($procId)_*)\Dedicated Usage", "\GPU Process Memory(pid_$($procId)_*)\Shared Usage" -ErrorAction SilentlyContinue
  if ($m) {
    $r.dedicated_mb = [math]::Round((($m.CounterSamples | Where-Object { $_.Path -match 'dedicated' } | Measure-Object CookedValue -Sum).Sum) / 1MB, 1)
    $r.shared_mb = [math]::Round((($m.CounterSamples | Where-Object { $_.Path -match 'shared' } | Measure-Object CookedValue -Sum).Sum) / 1MB, 1)
  }
  $r
}
function Wallpic {
  $tw = Get-Item "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper" -ErrorAction SilentlyContinue
  if ($tw) { (Get-FileHash $tw.FullName -Algorithm SHA256).Hash.Substring(0, 12) + ' ' + $tw.LastWriteTime.ToString('s') } else { 'none' }
}
function Shot([int]$hostPid, [string]$name) {
  $out = "$HERE\$name"
  $p = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$HERE\t15_shot.ps1`" -HostPid $hostPid -Out `"$out`"" -NoNewWindow -PassThru -RedirectStandardOutput "$LOGD\shot-out.txt" -RedirectStandardError "$LOGD\shot-err.txt"
  $null = $p.Handle
  if (-not $p.WaitForExit(40000)) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue; return "$name : the capture hung (killed after 40 s)" }
  "$name : " + ((Get-Content "$LOGD\shot-out.txt", "$LOGD\shot-err.txt" -Raw -ErrorAction SilentlyContinue) -join ' ').Trim()
}
function Push([string]$msg) {
  if ($NoPush) { return 'skipped (-NoPush)' }
  $mf = "$S\commit-msg.txt"
  [IO.File]::WriteAllText($mf, "$msg`n`nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`n", $UTF8)
  $g = "$LOGD\git.txt"
  & cmd /c "git -C `"$REPO`" add results/v0.4.2-rc4/acer/soak* >> `"$g`" 2>&1"
  & cmd /c "git -C `"$REPO`" commit -q -F `"$mf`" >> `"$g`" 2>&1"
  & cmd /c "git -C `"$REPO`" pull --rebase -q >> `"$g`" 2>&1"
  if ($LASTEXITCODE -ne 0) { & cmd /c "git -C `"$REPO`" rebase --abort >> `"$g`" 2>&1"; return "pull failed (rebase aborted; the commit stays local)" }
  & cmd /c "git -C `"$REPO`" push -q >> `"$g`" 2>&1"
  if ($LASTEXITCODE -ne 0) { return "push failed (see $g)" }
  "pushed $((& git -C $REPO log --oneline -1) -replace '\s.*', '')"
}

# ---------------------------------------------------------------- start
L "=== 1.5 soak starts: $(& $B --version); rotation `"$Rotation`"; $Hours h, a sample every $IntervalS s; folder $S"
$ac = (powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE | Select-String 'Current AC').ToString().Trim()
$vi = (powercfg /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE | Select-String 'Current AC').ToString().Trim()
$bat = Get-CimInstance Win32_Battery | Select-Object -First 1
L "power: $((powercfg /getactivescheme) -replace '.*\((.*)\).*', '$1'); sleep on mains $ac; display off on mains $vi; battery $($bat.EstimatedChargeRemaining)%, status $($bat.BatteryStatus) (2 = mains)" | Out-Null
Add-Type -AssemblyName System.Windows.Forms
L "monitors: $(([System.Windows.Forms.Screen]::AllScreens | ForEach-Object { "$($_.DeviceName) $($_.Bounds.Width)x$($_.Bounds.Height)" }) -join ', '); adapters (LUID low part): $(($names.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', '); $cores threads" | Out-Null
$d = Get-ItemProperty 'HKCU:\Control Panel\Desktop'
$wp0 = Wallpic
L "desktop before: wallpaper picture $wp0; SCRNSAVE.EXE [$($d.'SCRNSAVE.EXE')]; jetcarp processes: $((Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId) $($_.CommandLine)" }) -join ' | ')" | Out-Null
$r = Jx 'host stop'; L "host stop (any earlier host in this folder): exit $($r.code): $($r.text)" | Out-Null
$r = Jx 'host start'; L "host start: exit $($r.code): $($r.text -replace '\s*\r?\n\s*', ' / ')" | Out-Null
$r = Jx "host rotation `"$Rotation`""; L "host rotation `"$Rotation`": exit $($r.code): $($r.text -replace '\s*\r?\n\s*', ' / ')" | Out-Null
$r = Jx 'host wallpaper on'; L "host wallpaper on: exit $($r.code): $($r.text -replace '\s*\r?\n\s*', ' / ')" | Out-Null
Start-Sleep 10
[IO.File]::WriteAllText($CSV, "t,elapsed_h,alive,pid,uptime_s,memory_mb,ws_mb,private_mb,handles,threads,cpu_core_pct,cpu_machine_pct,gpu_total_pct,gpu_use,gpu_dedicated_mb,gpu_shared_mb,rotation,scene,number,count,generation,cells,cell_px,speed,measured_speed,simulation,held,paused,wallpaper,power`r`n", $UTF8)
[IO.File]::WriteAllText($JL, '', $UTF8)

# ---------------------------------------------------------------- samples
$t0 = Get-Date
$nSamples = [int][math]::Floor($Hours * 3600 / $IntervalS)
$prevCpu = $null; $prevT = $null; $prevPid = 0
for ($k = 0; $k -le $nSamples; $k++) {
  $due = $t0.AddSeconds($k * $IntervalS)
  $wait = ($due - (Get-Date)).TotalMilliseconds
  if ($wait -gt 0) { Start-Sleep -Milliseconds ([int]$wait) }
  $now = Get-Date
  $r = Jx 'host status --json' 60
  $st = $null; try { $st = $r.text | ConvertFrom-Json } catch {}
  [IO.File]::AppendAllText($JL, (Home ('{"t": "' + $now.ToString('s') + '", "k": ' + $k + ', "exit": "' + $r.code + '", "status": ' + $(if ($st) { $r.text.Trim() } else { ($r.text | ConvertTo-Json -Compress) }) + '}')) + "`n", $UTF8)
  $alive = [bool]($st -and $st.running)
  $hpid = if ($alive) { [int]$st.pid } else { 0 }
  $ws = ''; $pv = ''; $hd = ''; $th = ''; $cc = ''; $cm = ''
  if ($hpid) {
    $hp = Get-Process -Id $hpid -ErrorAction SilentlyContinue
    if ($hp) {
      $ws = [math]::Round($hp.WorkingSet64 / 1MB, 1); $pv = [math]::Round($hp.PrivateMemorySize64 / 1MB, 1); $hd = $hp.HandleCount; $th = $hp.Threads.Count
      $cpu = $hp.TotalProcessorTime.TotalSeconds
      if ($prevPid -eq $hpid -and $prevT) { $dt = ($now - $prevT).TotalSeconds; $cc = [math]::Round(100 * ($cpu - $prevCpu) / $dt, 1); $cm = [math]::Round($cc / $cores, 2) }
      $prevCpu = $cpu; $prevT = $now; $prevPid = $hpid
    }
  }
  $g = Gpu $hpid
  $sg = if ($alive -and $st.screens) { $st.screens[0].stage } else { $null }
  $sim = if ($alive -and $st.screens) { "$($st.screens[0].simulation.on) $($st.screens[0].simulation.adapter)" } else { '' }
  $held = if ($alive) { ((@($st.held) + @($st.held_why)) | Where-Object { $_ }) -join '; ' } else { '' }
  $paused = if ($alive) { "$($st.paused) $((@($st.paused_why)) -join '; ')".Trim() } else { '' }
  $bat = Get-CimInstance Win32_Battery | Select-Object -First 1
  $pw = "$($bat.BatteryStatus)/$($bat.EstimatedChargeRemaining)%"
  $f = @($now.ToString('s'), [math]::Round(($now - $t0).TotalHours, 3), $alive, $hpid, $(if ($alive) { $st.uptime_s }), $(if ($alive) { $st.memory_mb }), $ws, $pv, $hd, $th, $cc, $cm, $g.total, $g.use, $g.dedicated_mb, $g.shared_mb,
    $(if ($sg) { $sg.rotation }), $(if ($sg) { $sg.label }), $(if ($sg) { $sg.number }), $(if ($sg) { $sg.count }), $(if ($sg) { $sg.generation }), $(if ($sg) { $sg.cells }), $(if ($sg) { [math]::Round($sg.cell_px, 2) }),
    $(if ($sg) { $sg.speed }), $(if ($sg) { [math]::Round([double]$sg.measured_speed, 2) }), $sim, $held, $paused, $(if ($alive) { $st.wallpaper }), $pw)
  [IO.File]::AppendAllText($CSV, (($f | ForEach-Object { '"' + ([string]$_).Replace('"', "'") + '"' }) -join ',') + "`r`n", $UTF8)
  $line = "k=$k alive=$alive pid=$hpid mem=$(if ($alive) { $st.memory_mb })MB ws=$ws priv=$pv cpu=$cc% gpu=[$($g.use)] $(if ($sg) { "$($sg.label) ($($sg.number) of $($sg.count)) gen $($sg.generation) $($sg.cells) cells, $([math]::Round([double]$sg.measured_speed, 1)) of $($sg.speed)" }) held=[$held] paused=[$paused] power=$pw"
  if (($k % 12) -eq 0 -or -not $alive) { L $line | Out-Null }
  if (($k % 12) -eq 0 -and $hpid) {
    $hh = '{0:D2}' -f [int]($k * $IntervalS / 3600)
    L ("shot " + (Shot $hpid "soak-shot-${hh}h.jpg")) | Out-Null
    if ($k -gt 0 -and $k -lt $nSamples) { L ("hourly push: " + (Push "Acer: rc.4 1.5 soak, hour $([int]($k * $IntervalS / 3600)) of $Hours")) | Out-Null }
  }
}

# ---------------------------------------------------------------- the end: a summary; the host left running
$rows = Import-Csv $CSV
$nRows = $rows.Count; $al = @($rows | Where-Object { $_.alive -eq 'True' })
$pids = @($al | ForEach-Object { $_.pid } | Sort-Object -Unique)
function Med($xs) { $v = @($xs | Where-Object { $_ -ne '' } | ForEach-Object { [double]$_ } | Sort-Object); if ($v.Count -eq 0) { return '' }; $v[[int][math]::Floor(($v.Count - 1) / 2)] }
function MinMax($xs) { $v = @($xs | Where-Object { $_ -ne '' } | ForEach-Object { [double]$_ }); if ($v.Count -eq 0) { return '' }; "$(($v | Measure-Object -Minimum).Minimum)-$(($v | Measure-Object -Maximum).Maximum)" }
function Slope($rs, $col) { $pts = @($rs | Where-Object { $_.$col -ne '' }); $m = $pts.Count; if ($m -lt 3) { return '' }
  $sx = 0.0; $sy = 0.0; $sxx = 0.0; $sxy = 0.0; foreach ($p in $pts) { $x = [double]$p.elapsed_h; $y = [double]$p.$col; $sx += $x; $sy += $y; $sxx += $x * $x; $sxy += $x * $y }
  [math]::Round(($m * $sxy - $sx * $sy) / ($m * $sxx - $sx * $sx), 2) }
$first = @($al | Where-Object { [double]$_.elapsed_h -le 1.0 }); $last = @($al | Where-Object { [double]$_.elapsed_h -ge ($Hours - 1.0) })
$stalls = 0; $changes = @(); $prev = $null
foreach ($r0 in $al) { if ($prev) { if ($r0.scene -ne $prev.scene) { $changes += "$($r0.t) $($prev.scene) -> $($r0.scene) ($($r0.number) of $($r0.count))" } elseif ([double]$r0.generation -le [double]$prev.generation) { $stalls++ } }; $prev = $r0 }
$scenes = @($al | Group-Object scene | ForEach-Object { $g0 = $_.Group; "$($_.Name): $($_.Count) samples, $($g0[0].cells) cells of $($g0[0].cell_px) px, $(@($g0 | ForEach-Object { $_.simulation } | Sort-Object -Unique) -join ' / '), measured speed $(MinMax ($g0 | ForEach-Object { $_.measured_speed })) of $($g0[0].speed), CPU median $(Med ($g0 | ForEach-Object { $_.cpu_core_pct }))% of a core, GPU median $(Med ($g0 | ForEach-Object { $_.gpu_total_pct }))%" })
$heldN = @($al | Where-Object { $_.held -ne '' }).Count; $pausedN = @($al | Where-Object { $_.paused -notlike 'False*' }).Count
$sum = @(
  "rc.4 1.5 soak on the Acer: $(& $B --version), rotation `"$Rotation`", $($rows[0].t) to $($rows[-1].t), a sample every $IntervalS s",
  "alive: $($al.Count) of $nRows samples; host pids: $($pids -join ', ')",
  "host status memory_mb: first hour median $(Med ($first | ForEach-Object { $_.memory_mb })), last hour median $(Med ($last | ForEach-Object { $_.memory_mb })), range $(MinMax ($al | ForEach-Object { $_.memory_mb })), slope $(Slope $al 'memory_mb') MB/h",
  "private bytes (MB): first hour median $(Med ($first | ForEach-Object { $_.private_mb })), last hour median $(Med ($last | ForEach-Object { $_.private_mb })), range $(MinMax ($al | ForEach-Object { $_.private_mb })), slope $(Slope $al 'private_mb') MB/h",
  "working set (MB): first hour median $(Med ($first | ForEach-Object { $_.ws_mb })), last hour median $(Med ($last | ForEach-Object { $_.ws_mb })), range $(MinMax ($al | ForEach-Object { $_.ws_mb }))",
  "GPU dedicated (MB): first hour median $(Med ($first | ForEach-Object { $_.gpu_dedicated_mb })), last hour median $(Med ($last | ForEach-Object { $_.gpu_dedicated_mb })), range $(MinMax ($al | ForEach-Object { $_.gpu_dedicated_mb })); shared: range $(MinMax ($al | ForEach-Object { $_.gpu_shared_mb }))",
  "handles: range $(MinMax ($al | ForEach-Object { $_.handles })), slope $(Slope $al 'handles')/h; threads: range $(MinMax ($al | ForEach-Object { $_.threads }))",
  "CPU (% of one core): median $(Med ($al | ForEach-Object { $_.cpu_core_pct })), range $(MinMax ($al | ForEach-Object { $_.cpu_core_pct })); GPU (all engines, %): median $(Med ($al | ForEach-Object { $_.gpu_total_pct })), range $(MinMax ($al | ForEach-Object { $_.gpu_total_pct }))",
  "intervals where the same scene's generation didn't move: $stalls; samples held: $heldN; paused: $pausedN; power: $(@($rows | ForEach-Object { ($_.power -split '/')[0] } | Sort-Object -Unique) -join ', ') (2 = mains)",
  "scene changes: $($changes.Count)") + ($changes | ForEach-Object { "  $_" }) + @("scenes:") + ($scenes | ForEach-Object { "  $_" }) + @(
  "wallpaper picture: before $wp0, now (host still running) $(Wallpic)",
  "jetcarp processes now: $((Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId) $($_.CommandLine)" }) -join ' | ')",
  "The host is left running: Jimmie looks, then it is stopped and the wallpaper checked.")
[IO.File]::WriteAllText("$HERE\soak-summary.txt", (Home (($sum -join "`r`n") + "`r`n")), $UTF8)
L "=== soak ends; summary in soak-summary.txt" | Out-Null
L ("final push: " + (Push "Acer: rc.4 1.5 soak, $Hours h: the samples and summary")) | Out-Null
