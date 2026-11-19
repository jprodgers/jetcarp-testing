# Run every parity scene on this machine's CPU and GPU and compare with the Framework's CPU hashes.
# Usage: .\parity.ps1 -J <jetcarp.exe> -Dir <parity folder> -Out <results.csv> [-Gens 5000]
# (Set $env:JETCARP_GPU first to choose an adapter, e.g. "UHD" or "RTX".)
param([string]$J, [string]$Dir, [string]$Out, [int]$Gens = 300)
$rows = Import-Csv (Join-Path $Dir "expected.csv")
$res = New-Object System.Collections.Generic.List[object]
foreach ($r in $rows) {
  $f = Join-Path $Dir "scenes\$($r.n).json"
  $got = @{}
  foreach ($mode in @("cpu", "gpu")) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $txt = & $J run $f --gens $Gens --json "--$mode" 2>$null | Out-String
    $sw.Stop()
    try { $d = $txt | ConvertFrom-Json; $got[$mode] = @($d.hash, [string]$d.backend, $sw.Elapsed.TotalSeconds) }
    catch { $got[$mode] = @("ERROR", $txt.Trim(), $sw.Elapsed.TotalSeconds) }
  }
  $b = $got["gpu"][1]
  $gpuGens = 0
  if ($b -match '(\d+) of (\d+) generations on the cpu') { $gpuGens = [int]$Matches[2] - [int]$Matches[1] }
  elseif ($b.StartsWith("gpu")) { $gpuGens = $Gens }
  $o = [pscustomobject]@{ n = $r.n; id = $r.id; expected = $r.hash; cpu = $got["cpu"][0]; gpu = $got["gpu"][0];
    cpu_ok = ($got["cpu"][0] -eq $r.hash); gpu_ok = ($got["gpu"][0] -eq $r.hash); gpu_gens = $gpuGens;
    cpu_s = [math]::Round($got["cpu"][2], 3); gpu_s = [math]::Round($got["gpu"][2], 3);
    gpu_backend = $b.Substring(0, [math]::Min(160, $b.Length)) }
  if (-not ($o.cpu_ok -and $o.gpu_ok)) { Write-Host "MISMATCH $($o | ConvertTo-Json -Compress)" }
  $res.Add($o)
}
$res | Export-Csv -NoTypeInformation $Out
$badCpu = ($res | Where-Object { -not $_.cpu_ok }).Count
$badGpu = ($res | Where-Object { -not $_.gpu_ok }).Count
$onGpu = ($res | Where-Object { $_.gpu_gens -eq $Gens }).Count
"$($res.Count) scenes: CPU matches $($res.Count - $badCpu), GPU matches $($res.Count - $badGpu); all $Gens generations on the GPU in $onGpu"
