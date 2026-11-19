# Poll the app's world over one `jetcarp mcp --app` connection: world_status every -Every seconds, one log line each
# (time, generation, gens/s since the last poll, cells, playing, tiling, rules, population), and a PrintWindow
# screenshot of the app every -ShotEvery seconds. Stops after -Seconds, or when $OUTDIR\poll.stop appears.
# Usage: mcppoll.ps1 -Out log.txt -ShotDir folder -ProcId N [-Seconds 900] [-Every 5] [-ShotEvery 10]
param([string]$Out, [string]$ShotDir, [int]$ProcId, [int]$Seconds = 900, [int]$Every = 5, [int]$ShotEvery = 10)
. "$PSScriptRoot\env2.ps1"
New-Item -ItemType Directory -Force $ShotDir | Out-Null
$psi = New-Object Diagnostics.ProcessStartInfo $J, "mcp --app"
$psi.RedirectStandardInput = $true; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true; $psi.UseShellExecute = $false
$psi.StandardOutputEncoding = [Text.Encoding]::UTF8
[Console]::InputEncoding = New-Object Text.UTF8Encoding $false
$pr = [Diagnostics.Process]::Start($psi)
$errTask = $pr.StandardError.ReadToEndAsync()
$sw = New-Object IO.StreamWriter($pr.StandardInput.BaseStream, (New-Object Text.UTF8Encoding $false)); $sw.NewLine = "`n"; $sw.AutoFlush = $true
function Send($obj) { $sw.WriteLine(($obj | ConvertTo-Json -Compress -Depth 10)) }
$script:pending = $null
function Recv([int]$id) {
  $deadline = (Get-Date).AddSeconds(30)
  while ((Get-Date) -lt $deadline) {
    if (-not $script:pending) { $script:pending = $pr.StandardOutput.ReadLineAsync() }
    if (-not $script:pending.Wait(30000)) { return $null }
    $line = $script:pending.Result; $script:pending = $null; if ($null -eq $line) { return $null }
    try { $m = $line | ConvertFrom-Json } catch { continue }
    if ($m.id -eq $id) { return $m }
  }
}
function Log($s) { "$(Get-Date -Format 'HH:mm:ss') $s" | Out-File -Encoding utf8 -Append $Out }
Send @{ jsonrpc = '2.0'; id = 1; method = 'initialize'; params = @{ protocolVersion = '2025-06-18'; capabilities = @{}; clientInfo = @{ name = 'rc2-acer-poll'; version = '1' } } }
$init = Recv 1
Log "start: server $($init.result.serverInfo.name) $($init.result.serverInfo.version); every $Every s, shots every $ShotEvery s, for $Seconds s"
Send @{ jsonrpc = '2.0'; method = 'notifications/initialized' }
$end = (Get-Date).AddSeconds($Seconds); $id = 10; $prevGen = $null; $prevT = $null; $nextShot = Get-Date
while ((Get-Date) -lt $end -and -not (Test-Path "$OUTDIR\poll.stop") -and -not $pr.HasExited) {
  $id++; $t0 = Get-Date
  Send @{ jsonrpc = '2.0'; id = $id; method = 'tools/call'; params = @{ name = 'world_status'; arguments = @{} } }
  $r = Recv $id
  if (-not $r) { Log "no reply"; break }
  try {
    $w = $r.result.content[0].text | ConvertFrom-Json
    $gen = [int64]$w.generation
    $rate = if ($null -ne $prevGen -and $gen -ge $prevGen) { '{0:n1}' -f (($gen - $prevGen) / ($t0 - $prevT).TotalSeconds) } else { '-' }
    $prevGen = $gen; $prevT = $t0
    $pop = ($w.fields | Measure-Object population -Sum).Sum
    $rules = ($w.cas | ForEach-Object { $_.rule }) -join ' + '
    $ap = Get-Process -Id $ProcId -ErrorAction SilentlyContinue
    $mem = if ($ap) { 'ws {0:n0} MB private {1:n0} MB' -f ($ap.WorkingSet64 / 1MB), ($ap.PrivateMemorySize64 / 1MB) } else { 'app gone' }
    Log ("gen {0} rate {1}/s cells {2} playing {3} tiling {4} rules '{5}' pop {6} scene '{7}' {8}" -f $gen, $rate, $w.cells, $w.host.playing, $w.tiling.id, $rules, $pop, $w.host.scene_name, $mem)
  } catch { Log "parse error: $($_.Exception.Message)" }
  if ((Get-Date) -ge $nextShot) {
    $nextShot = (Get-Date).AddSeconds($ShotEvery)
    try { & "$PSScriptRoot\shot-title.ps1" -ProcId $ProcId -Out "$ShotDir\shot-$(Get-Date -Format 'HHmmss').png" | Out-Null } catch { Log "shot failed: $($_.Exception.Message)" }
  }
  $wait = $Every - ((Get-Date) - $t0).TotalSeconds
  if ($wait -gt 0) { Start-Sleep -Milliseconds ([int]($wait * 1000)) }
}
$sw.Close(); if (-not $pr.WaitForExit(10000)) { $pr.Kill() }
Log "end; mcp exit $($pr.ExitCode); stderr: $($errTask.Result.Trim())"
