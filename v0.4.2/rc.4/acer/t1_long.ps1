# rc.4 wave on the Acer, the long unattended part (v0.4.2-rc.4.md "The wave"):
#  1.1 and 1.2  Parity with the release's own build (~\jetcarp-rc-042c\bin\jetcarp.exe, rc.4 from the zip): the 371
#               scenes x 300 generations and the 40 x 5,000, on RTX Vulkan, RTX DX12, UHD Vulkan, UHD DX12. The
#               pre-check's pre.ps1 loop, with the release build.
#  1.3          The suite on the tag: the source clone (~\jetcarp-rc-042c\src) checked out at v0.4.2-rc.4, then
#               t1_suite_rerun.ps1 (watcher for #120's box) with JETCARP_GPU=RTX; straight after it, host.rs serial
#               x10 (R4 #122, the Acer busy: t1_host_x10.ps1); then the suite with JETCARP_GPU=UHD.
# ASCII only. Never $t, $j, $r, $s, $b (they would clobber $T4 and friends). Logs under $T4\logs; t1_long.log there.
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
$UTF8 = New-Object Text.UTF8Encoding $false
$HERE = $PSScriptRoot
$T4 = "$env:USERPROFILE\jetcarp-rc4"
$SRC = "$env:USERPROFILE\jetcarp-rc-042c\src"
$REPO = (Resolve-Path "$HERE\..\..\..").Path
$BX = "$env:USERPROFILE\jetcarp-rc-042c\bin\jetcarp.exe"
$LOG = "$T4\logs"
New-Item -ItemType Directory -Force $T4, $LOG | Out-Null
Set-Location $T4
$MAIN = "$LOG\t1_long.log"
function L([string]$msg) { [IO.File]::AppendAllText($MAIN, "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg`r`n", $UTF8) }
function Procs { (Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId) $($_.Name)" }) -join ' | ' }
$env:JETCARP_CONFIG_DIR = "$T4\main\config"; $env:JETCARP_DATA_DIR = "$T4\main\data"; $env:JETCARP_OUT = "$T4\main\out"; $env:JETCARP_RUNTIME_DIR = "$T4\main\run"
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND, Env:JETCARP_LIBRARY -ErrorAction SilentlyContinue

L "=== rc.4 wave, long part, starts; build ${BX}: $(& $BX --version)"
L "jetcarp processes at start: $(Procs)"
$bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue; L "power: $(if ($bat) { "battery $($bat.EstimatedChargeRemaining)%, status $($bat.BatteryStatus) (2 = mains)" } else { 'n/a' })"
if (Test-Path "$T4\parity") { Remove-Item -Recurse -Force "$T4\parity" }
Copy-Item "$REPO\parity" "$T4\parity" -Recurse -Force
L ("parity copied from the repository: {0} scenes, long {1} scenes" -f (Import-Csv "$T4\parity\expected.csv").Count, (Import-Csv "$T4\parity\long\expected.csv").Count)

# ---------------------------------------------------------------- 1.1, 1.2 Parity with the release build
$adapters = @(@{ n = 'rtx-vulkan'; g = 'RTX'; k = $null }, @{ n = 'rtx-dx12'; g = 'RTX'; k = 'dx12' }, @{ n = 'uhd-vulkan'; g = 'UHD'; k = $null }, @{ n = 'uhd-dx12'; g = 'UHD'; k = 'dx12' })
foreach ($part in @(@{ step = '1.1'; dir = "$T4\parity"; gens = 300; want = '371 scenes: CPU matches 371, GPU matches 371' }, @{ step = '1.2'; dir = "$T4\parity\long"; gens = 5000; want = '40 scenes: CPU matches 40, GPU matches 40' })) {
  foreach ($a in $adapters) {
    $name = "$($part.step)-$($a.n)"
    try {
      $env:JETCARP_GPU = $a.g; if ($a.k) { $env:WGPU_BACKEND = $a.k } else { Remove-Item Env:WGPU_BACKEND -ErrorAction SilentlyContinue }
      L "=== $name (JETCARP_GPU=$($a.g) WGPU_BACKEND=$($a.k), $($part.gens) gens)"
      $t0 = Get-Date
      $outText = & "$T4\parity\parity.ps1" -J $BX -Dir $part.dir -Out "$LOG\$name.csv" -Gens $part.gens *>&1 | Out-String
      [IO.File]::WriteAllText("$LOG\$name.log", $outText, $UTF8)
      $last = ($outText -split "`r?`n" | Where-Object { $_ -match 'scenes: CPU matches' } | Select-Object -Last 1)
      $mism = @($outText -split "`r?`n" | Where-Object { $_ -match '^MISMATCH' }).Count
      $rows = Import-Csv "$LOG\$name.csv"
      $named = ($rows | Where-Object { [int]$_.gpu_gens -gt 0 } | Group-Object { ($_.gpu_backend -split ';')[0] } | Sort-Object Count -Descending | ForEach-Object { "$($_.Count)x $($_.Name)" }) -join ', '
      $allGpu = @($rows | Where-Object { [int]$_.gpu_gens -eq $part.gens }).Count
      L "$name adapters used: $named"
      L ("RESULT {0} : {1}: {2}; all {3} generations on the GPU in {4}; {5} MISMATCH lines; {6:n1} min" -f $name, $(if ($last -like "$($part.want)*" -and $mism -eq 0) { 'pass' } else { 'FAIL' }), $last, $part.gens, $allGpu, $mism, ((Get-Date) - $t0).TotalMinutes)
    } catch { L "RESULT $name : FAIL: $_" }
  }
}
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue

# ---------------------------------------------------------------- 1.3 The suite on the tag, host.rs x10
L "=== 1.3: the source at the tag"
L "before: $(git -C $SRC log --oneline -1) ($(git -C $SRC rev-parse --abbrev-ref HEAD))"
$co = & git -C $SRC checkout --detach v0.4.2-rc.4 2>&1 | Out-String
L "git checkout --detach v0.4.2-rc.4: $($co.Trim() -replace "`r?`n", ' / ')"
L "now: $(git -C $SRC log --oneline -1); status: [$((git -C $SRC status --short) -join ' ')]"
L "=== 1.3 RTX"
& "$HERE\t1_suite_rerun.ps1" -Gpu RTX -Tag tag -TimeoutS 10800 | Out-Null
L "RTX: $((Get-Content "$LOG\1-rerun-rtx-tag.log" | Select-String 'RESULT') -join ' ')"
L "=== R4 #122: host.rs serial x10, straight after the RTX suite"
& "$HERE\t1_host_x10.ps1" -Tag tag -Runs 10 | Out-Null
L "host.rs x10: $((Get-Content "$LOG\1-host-rs-tag-x10.txt" | Select-String 'RESULT') -join ' ')"
L "=== 1.3 UHD"
& "$HERE\t1_suite_rerun.ps1" -Gpu UHD -Tag tag -TimeoutS 10800 | Out-Null
L "UHD: $((Get-Content "$LOG\1-rerun-uhd-tag.log" | Select-String 'RESULT') -join ' ')"
L "jetcarp processes at the end: $(Procs)"
L "=== long part ends"
"t1_long done"
