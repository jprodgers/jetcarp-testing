# rc.4 wave on the Acer, after 1.5 (the soak): does the host's generation start again when Langton's ant walks off
# the edge? The soak's 05h picture showed an early blob while host status said generation 357,338, never reset.
# On the soak's host (still running): `host next` until Quick Start langtons-ant shows, then host status every 2 s
# for $Seconds, and a picture of the wallpaper window every 10 s (t15_shot.ps1) with the share of blue (ant) cells.
# Writes soak-ant.txt; pictures go to $ShotDir.
#   powershell -NoProfile -ExecutionPolicy Bypass -File t15_ant.ps1 -ShotDir <folder>
param([Parameter(Mandatory)][string]$ShotDir, [int]$Seconds = 180)
Add-Type -AssemblyName System.Drawing
$UTF8 = New-Object Text.UTF8Encoding $false
$HERE = $PSScriptRoot
$S = "$env:USERPROFILE\jetcarp-rc4\soak"
$B = "$env:USERPROFILE\jetcarp-rc-042c\bin\jetcarp.exe"
$env:JETCARP_CONFIG_DIR = "$S\config"; $env:JETCARP_DATA_DIR = "$S\data"; $env:JETCARP_OUT = "$S\out"
$env:JETCARP_LIBRARY = "$S\library"; $env:JETCARP_RUNTIME_DIR = "$S\run"
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue
Set-Location "$S\cwd"
New-Item -ItemType Directory -Force $ShotDir | Out-Null
$OUTF = "$HERE\soak-ant.txt"
function Home([string]$s) { $s.Replace($env:USERPROFILE, '~').Replace($env:USERPROFILE.Replace('\', '\\'), '~') }
function L([string]$s) { $s = Home "$(Get-Date -Format 'HH:mm:ss.f') $s"; [IO.File]::AppendAllText($OUTF, "$s`r`n", $UTF8); $s }
function St { $j = (& $B host status --json 2>&1 | Out-String); try { $j | ConvertFrom-Json } catch { $null } }
function Blue([string]$file) {
  $bmp = [Drawing.Bitmap]::FromFile($file); $n = 0; $hit = 0
  try { for ($y = 0; $y -lt $bmp.Height; $y += 4) { for ($x = 0; $x -lt $bmp.Width; $x += 4) { $c = $bmp.GetPixel($x, $y); $n++; if ($c.B -gt 150 -and $c.B -gt $c.R + 40) { $hit++ } } } }
  finally { $bmp.Dispose() }
  '{0:N3}%' -f (100.0 * $hit / $n)
}
L "=== the ant's restarts: $(& $B --version)"
$st = St; L "now: $($st.screens[0].stage.label) ($($st.screens[0].stage.number) of $($st.screens[0].stage.count)), generation $($st.screens[0].stage.generation), pid $($st.pid)"
for ($i = 0; $i -lt 8 -and $st.screens[0].stage.label -ne 'Quick Start langtons-ant'; $i++) {
  $o = (& $B host next 2>&1 | Out-String).Trim(); Start-Sleep -Seconds 3; $st = St
  L "host next -> exit $LASTEXITCODE [$o]; now $($st.screens[0].stage.label), generation $($st.screens[0].stage.generation)"
}
if ($st.screens[0].stage.label -ne 'Quick Start langtons-ant') { L "langtons-ant never came up; stopping"; exit 1 }
$t0 = Get-Date; $k = 0
while (((Get-Date) - $t0).TotalSeconds -lt $Seconds) {
  $st = St; $g = $st.screens[0].stage
  $line = "t+{0,5:N1}s gen {1,7} speed {2:N2} label {3} building {4} caption [{5}]" -f ((Get-Date) - $t0).TotalSeconds, $g.generation, $g.measured_speed, $g.label, $g.building, ($g.caption -join ' / ')
  if ($k % 5 -eq 0) {
    $f = Join-Path $ShotDir ('ant-{0:D3}.jpg' -f [int]((Get-Date) - $t0).TotalSeconds)
    $p = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$HERE\t15_shot.ps1`" -HostPid $($st.pid) -Out `"$f`"" -NoNewWindow -PassThru -RedirectStandardOutput "$ShotDir\shot-out.txt"
    if ($p.WaitForExit(40000) -and (Test-Path $f)) { $line += " | shot $(Split-Path $f -Leaf) blue $(Blue $f)" } else { try { $p.Kill() } catch {}; $line += " | shot timed out" }
  }
  L $line; $k++; Start-Sleep -Milliseconds 1500
}
L "=== done"
