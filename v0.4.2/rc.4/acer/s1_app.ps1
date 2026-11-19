# rc.4 wave on the Acer, the sitting with Jimmie: R4's app rows.
# Opens rc.4's app (jetcarp.exe with no subcommand, as a tester opens it) on the sitting's own folder
# ~\jetcarp-rc4\s1 (every JETCARP_* folder set), waits for it to close, and logs how it ended and what
# the settings folder holds then (photosensitivity.json above all).
#   powershell -NoProfile -ExecutionPolicy Bypass -File s1_app.ps1 -Name 96-first [-Fresh]
param([string]$Name = 'app', [switch]$Fresh)
$ErrorActionPreference = 'Stop'
$HERE = Split-Path -Parent $MyInvocation.MyCommand.Path
$S = "$HOME\jetcarp-rc4\s1"
$J = "$HOME\jetcarp-rc-042c\bin\jetcarp.exe"
$LOG = "$HERE\s1-app.txt"
function W([string]$s) { $s = $s.Replace($HOME, '~'); Add-Content -Path $LOG -Value $s -Encoding UTF8; Write-Output $s }
if ($Fresh -and (Test-Path $S)) { Remove-Item -Recurse -Force $S }
foreach ($d in 'config', 'data', 'out', 'library', 'run', 'cwd') { New-Item -ItemType Directory -Force "$S\$d" | Out-Null }
$env:JETCARP_CONFIG_DIR = "$S\config"; $env:JETCARP_DATA_DIR = "$S\data"; $env:JETCARP_OUT = "$S\out"
$env:JETCARP_LIBRARY = "$S\library"; $env:JETCARP_RUNTIME_DIR = "$S\run"
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue
W ""
W "#### $Name, $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $(& $J --version)$(if ($Fresh) { ', a fresh folder' })"
W "folders: JETCARP_CONFIG_DIR, _DATA_DIR, _OUT, _LIBRARY, _RUNTIME_DIR = $S\config, \data, \out, \library, \run"
W "settings before: $((Get-ChildItem "$S\config" -Force | ForEach-Object Name) -join ', ')"
$t0 = Get-Date
$p = Start-Process -FilePath $J -WorkingDirectory "$S\cwd" -PassThru
W "app started: pid $($p.Id)"
$p.WaitForExit()
W "app ended: exit $($p.ExitCode) after $([int]((Get-Date) - $t0).TotalSeconds) s, $(Get-Date -Format 'HH:mm:ss')"
W "settings after: $((Get-ChildItem "$S\config" -Force | ForEach-Object Name) -join ', ')"
$ph = "$S\config\photosensitivity.json"
if (Test-Path $ph) { W "photosensitivity.json: $((Get-Content $ph -Raw).Trim())" } else { W "photosensitivity.json: none" }
W "jetcarp processes left: $((Get-Process jetcarp, jetcarpw -ErrorAction SilentlyContinue | ForEach-Object { "$($_.Id) $($_.Name)" }) -join '; ')"
