# rc.4 wave on the Acer, R4 #104: progress lines fit the terminal. A window 60 columns wide runs
# `jetcarp --version`, `jetcarp pack import` of the starter pack into a fresh library, then a half-minute
# `jetcarp search explore`. Its text is read row by row (t104_read.ps1, which also gives the console's output mode)
# during the explore and at the end: a line wider than the window wraps, and a carriage return then leaves its first
# row behind.
#   -Term conhost (the old console window) or wt (Windows Terminal, Windows 11's default terminal, 60 x 50 by --size)
#   -Shell cmd or ps (Windows PowerShell 5.1)
# The program is named by its full path: a bare jetcarp.exe ran Scoop's shim (0.4.1) in the first try, as this
# session sets NoDefaultCurrentDirectoryInExePath. The window ends by itself when this script leaves a "go" file
# (never killed: Windows Terminal may host other windows in the same process).
# ASCII only. Output: 104-narrow-<term>-<shell>.txt beside this script (the home folder written as ~).
param([string]$Term = 'conhost', [string]$Shell = 'cmd')
$ErrorActionPreference = 'Continue'
$UTF8 = New-Object Text.UTF8Encoding $false
$HERE = $PSScriptRoot
$tag = "$Term-$Shell"
$N4 = "$env:USERPROFILE\jetcarp-rc4\n104-$tag"
if (Test-Path $N4) { Remove-Item -Recurse -Force $N4 }
New-Item -ItemType Directory -Force $N4 | Out-Null
$JX = "$env:USERPROFILE\jetcarp-rc-042c\bin\jetcarp.exe"
$go = "$N4\go.txt"
if ($Shell -eq 'cmd') {
  $run = "$N4\run104.cmd"
  @"
@echo off
title JETCARP-104
$(if ($Term -eq 'conhost') { 'mode con: cols=60 lines=50' } else { 'rem (Windows Terminal: the size comes from wt --size)' })
set JETCARP_CONFIG_DIR=$N4\config
set JETCARP_DATA_DIR=$N4\data
set JETCARP_OUT=$N4\out
set JETCARP_LIBRARY=$N4\library
set JETCARP_RUNTIME_DIR=$N4\run
set JETCARP_GPU=
set COLUMNS=
cd /d "$env:USERPROFILE\jetcarp-rc-042c\bin"
echo $ jetcarp --version
"$JX" --version
echo $ jetcarp pack import packs\jetcarp-starter
"$JX" pack import packs\jetcarp-starter
echo $ jetcarp search explore --minutes 0.5
"$JX" search explore --minutes 0.5
echo done-104
:wait
if exist "$go" exit /b 0
ping -n 2 127.0.0.1 >nul
goto wait
"@ | Set-Content -Encoding ASCII $run
  $shellLine = "cmd.exe /c `"$run`""
} else {
  $run = "$N4\run104.ps1"
  @"
`$Host.UI.RawUI.WindowTitle = 'JETCARP-104'
$(if ($Term -eq 'conhost') { 'mode con: cols=60 lines=50' } else { '# (Windows Terminal: the size comes from wt --size)' })
`$env:JETCARP_CONFIG_DIR = '$N4\config'; `$env:JETCARP_DATA_DIR = '$N4\data'; `$env:JETCARP_OUT = '$N4\out'
`$env:JETCARP_LIBRARY = '$N4\library'; `$env:JETCARP_RUNTIME_DIR = '$N4\run'
Remove-Item Env:JETCARP_GPU, Env:COLUMNS -ErrorAction SilentlyContinue
Set-Location '$env:USERPROFILE\jetcarp-rc-042c\bin'
'`$ jetcarp --version'; & '$JX' --version
'`$ jetcarp pack import packs\jetcarp-starter'; & '$JX' pack import packs\jetcarp-starter
'`$ jetcarp search explore --minutes 0.5'; & '$JX' search explore --minutes 0.5
'done-104'
while (-not (Test-Path '$go')) { Start-Sleep 1 }
"@ | Set-Content -Encoding ASCII $run
  $shellLine = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$run`""
}
$OUTF = Join-Path $HERE "104-narrow-$tag.txt"
[IO.File]::WriteAllText($OUTF, "#### R4 #104: progress lines in a 60-column window, $Term with $Shell, rc.4, $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); COLUMNS unset; each row prefixed with its number`r`n", $UTF8)
if ($Term -eq 'conhost') { Start-Process conhost.exe -ArgumentList $shellLine | Out-Null }
else { Start-Process wt.exe -ArgumentList "--size 60,50 $shellLine" | Out-Null }
$sh = $null
for ($k = 0; $k -lt 30 -and -not $sh; $k++) { Start-Sleep 1; $sh = Get-CimInstance Win32_Process -Filter "Name = 'cmd.exe' or Name = 'powershell.exe'" | Where-Object { $_.CommandLine -like "*run104*" -and $_.CommandLine -like "*$tag*" } | Select-Object -First 1 }
if (-not $sh) { [IO.File]::AppendAllText($OUTF, "(the window's shell was not found)`r`n", $UTF8); "t104 ${tag}: no shell"; exit 1 }
$parent = Get-CimInstance Win32_Process -Filter "ProcessId = $($sh.ParentProcessId)"
[IO.File]::AppendAllText($OUTF, "(the shell, $($sh.Name), runs under $($parent.Name))`r`n", $UTF8)
function Snap([string]$label) {
  $f = "$N4\snap.txt"
  Start-Process powershell -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$HERE\t104_read.ps1`"", $sh.ProcessId, "`"$f`"" -WindowStyle Hidden -Wait
  $txt = [IO.File]::ReadAllText($f, [Text.Encoding]::UTF8).Replace($env:USERPROFILE, '~')
  [IO.File]::AppendAllText($OUTF, "#### $label, $(Get-Date -Format 'HH:mm:ss')`r`n$txt`r`n", $UTF8)
}
$t0 = Get-Date
$snapped = $false
while (((Get-Date) - $t0).TotalSeconds -lt 240) {
  Start-Sleep 2
  $ex = Get-CimInstance Win32_Process -Filter "ParentProcessId = $($sh.ProcessId) and Name = 'jetcarp.exe'" | Where-Object { $_.CommandLine -match 'explore' }
  if ($ex -and -not $snapped) { Start-Sleep 15; Snap 'during the explore (15 s in)'; $snapped = $true }
  if ($snapped -and -not (Get-CimInstance Win32_Process -Filter "ParentProcessId = $($sh.ProcessId) and Name = 'jetcarp.exe'")) { break }
}
Start-Sleep 2
Snap 'at the end'
Set-Content $go 'go'
"t104 $tag done"
