# rc.5 wave on the Acer, R5's rows #128, #124's note and #134 (v0.4.2-rc.5.md, "R5"), after the long part.
#  128 (CLI)    jetcarp host tune --help and host help tune: only "Fit to this computer isn't in JETCARP 0.4.2..."
#  124          host login on with every JETCARP_* folder set (a test folder, the warning answered there): a note
#               names the variables the login item won't carry. Then the control with none set (the default folders,
#               whose answer the rc.4 sitting saved): no note. Each time: the Run value, any host it started, then
#               host stop and host login off, and the Run value gone.
#  128 (inst)   rc.5's own installer (jetcarp-installer.ps1 from the release, checked against SHA256SUMS), default
#               folder: -NoModifyPath, then -Uninstall: "(it wasn't on your PATH)".
#  134          A normal install (the user PATH changed), then the installed jetcarp's uninstall --yes --settings
#               --data on the default folders (not sacred on the Acer: Jimmie), then -Uninstall: "took it off your
#               PATH", and its kept line names only what is still there (Pictures\JETCARP is OneDrive's, left alone).
#               The user PATH (its raw value and kind) is compared before and after; its contents aren't logged.
# Not run as administrator; the registry is changed only by JETCARP itself (the Run value, the user PATH).
# ASCII only. Output: R5-rows.txt beside this script (the home folder as ~).
$ErrorActionPreference = 'Continue'
$UTF8 = New-Object Text.UTF8Encoding $false
$HERE = $PSScriptRoot
$T5 = "$env:USERPROFILE\jetcarp-rc5"
$EXE = "$env:USERPROFILE\jetcarp-rc-042c\bin\jetcarp.exe"
$INS = "$env:USERPROFILE\jetcarp-rc-042c\rc5-dl\jetcarp-installer.ps1"
$IDIR = Join-Path $env:LOCALAPPDATA 'Programs\jetcarp'
$OUTF = Join-Path $HERE 'R5-rows.txt'
$LOGD = "$T5\logs"
New-Item -ItemType Directory -Force $T5, $LOGD, "$T5\cwd" | Out-Null
Set-Location "$T5\cwd"
[IO.File]::WriteAllText($OUTF, '', $UTF8)
function Home([string]$s) { $s.Replace($env:USERPROFILE, '~').Replace($env:USERPROFILE.Replace('\', '\\'), '~') }
function W([string]$s) { $s = Home $s; [IO.File]::AppendAllText($OUTF, "$s`r`n", $UTF8); $s }
function Clear-Folders { foreach ($v in 'JETCARP_CONFIG_DIR','JETCARP_DATA_DIR','JETCARP_OUT','JETCARP_LIBRARY','JETCARP_RUNTIME_DIR','JETCARP_GPU','WGPU_BACKEND') { Remove-Item "Env:$v" -ErrorAction SilentlyContinue } }
function Set-Folders([string]$dir) {
  $env:JETCARP_CONFIG_DIR = "$dir\config"; $env:JETCARP_DATA_DIR = "$dir\data"; $env:JETCARP_OUT = "$dir\out"
  $env:JETCARP_LIBRARY = "$dir\library"; $env:JETCARP_RUNTIME_DIR = "$dir\run"
}
# A command through Start-Process with its own output files (a host it starts must not hold a pipe).
$script:N = 0
function Run([string]$exe, [string]$argLine, [int]$timeoutS = 180) {
  $script:N++
  $o = "$LOGD\r5-$($script:N)-out.txt"; $e = "$LOGD\r5-$($script:N)-err.txt"
  $shown = if ($exe -eq $EXE) { 'jetcarp' } elseif ($exe -eq 'powershell') { 'powershell' } else { $exe }
  W "`$ $shown $argLine" | Out-Null
  $p = Start-Process $exe -ArgumentList $argLine -RedirectStandardOutput $o -RedirectStandardError $e -NoNewWindow -PassThru -WorkingDirectory "$T5\cwd"
  $null = $p.Handle
  if (-not $p.WaitForExit($timeoutS * 1000)) { $code = 'none (timed out)'; try { $p.Kill() } catch {} } else { $code = $p.ExitCode }
  $txt = ([string](Get-Content $o -Raw -Encoding UTF8) + [string](Get-Content $e -Raw -Encoding UTF8)).TrimEnd()
  if ($txt) { foreach ($l in ($txt -split "`r?`n")) { W "  $l" | Out-Null } }
  W "  (exit $code)" | Out-Null
  $txt
}
function RunVal { $k = Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; @($k.GetValueNames() | Where-Object { $_ -match 'jetcarp' -or [string]$k.GetValue($_) -match 'jetcarp' } | ForEach-Object { "$_=$($k.GetValue($_))" }) -join '; ' }
function Procs { (Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId) $($_.Name) $($_.CommandLine)" }) -join ' | ' }
function RawPath { $k = Get-Item 'HKCU:\Environment'; [pscustomobject]@{ value = [string]$k.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames); kind = [string]$k.GetValueKind('Path') } }
function OnPath([string]$raw) { @($raw -split ';' | Where-Object { $_ -and $_.TrimEnd('\') -eq $IDIR.TrimEnd('\') }).Count -gt 0 }
function Defaults { "settings %APPDATA%\jetcarp: $(Test-Path (Join-Path $env:APPDATA 'jetcarp')); data %LOCALAPPDATA%\jetcarp: $(Test-Path (Join-Path $env:LOCALAPPDATA 'jetcarp')); pictures: $(Test-Path (Join-Path ([Environment]::GetFolderPath('MyPictures')) 'JETCARP')); program folder %LOCALAPPDATA%\Programs\jetcarp: $(Test-Path $IDIR)" }

W "#### R5 rows on the Acer: #128, #124's note, #134; $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-Null
W "rc.5: $(& $EXE --version); the installer: $((Get-FileHash $INS -Algorithm SHA256).Hash.ToLower().Substring(0,16))... (matched SHA256SUMS at download)" | Out-Null
W "jetcarp processes: [$(Procs)]; JETCARP Run value: [$(RunVal)]" | Out-Null

# ---------------------------------------------------------------- 128 (CLI)
W "`r`n### R5 #128: host tune --help, host help tune" | Out-Null
Clear-Folders
$null = Run $EXE 'host tune --help'
$null = Run $EXE 'host help tune'

# ---------------------------------------------------------------- 124
W "`r`n### R5 #124: host login on with every JETCARP_* folder set (~\jetcarp-rc5\h124, the warning answered there)" | Out-Null
$H124 = "$T5\h124"; if (Test-Path $H124) { Remove-Item -Recurse -Force $H124 }
New-Item -ItemType Directory -Force $H124 | Out-Null
Set-Folders $H124
$null = Run $EXE 'setup --seizure-warning no-disorder'
$null = Run $EXE 'host login on'
Start-Sleep -Seconds 5
W "JETCARP Run value: [$(RunVal)]; jetcarp processes: [$(Procs)]" | Out-Null
W "(the test folder's host, if login on started one:)" | Out-Null
$null = Run $EXE 'host status'
$null = Run $EXE 'host stop'
Clear-Folders
W "(the default folders' host, if login on started one:)" | Out-Null
$null = Run $EXE 'host status'
$null = Run $EXE 'host stop'
Set-Folders $H124
$null = Run $EXE 'host login off'
W "after: JETCARP Run value: [$(RunVal)]; jetcarp processes: [$(Procs)]" | Out-Null
W "`r`n### R5 #124, the control: no JETCARP_* folder set (the default folders; their answer from the rc.4 sitting)" | Out-Null
Clear-Folders
$null = Run $EXE 'setup --status'
$null = Run $EXE 'host login on'
Start-Sleep -Seconds 5
W "JETCARP Run value: [$(RunVal)]; jetcarp processes: [$(Procs)]" | Out-Null
$null = Run $EXE 'host stop'
$null = Run $EXE 'host login off'
W "after: JETCARP Run value: [$(RunVal)]; jetcarp processes: [$(Procs)]" | Out-Null

# ---------------------------------------------------------------- 128 (installer)
W "`r`n### R5 #128: rc.5's installer -NoModifyPath, then -Uninstall" | Out-Null
Clear-Folders
$p0 = RawPath
W "before: $(Defaults); the program folder on the user PATH: $(OnPath $p0.value); PATH kind $($p0.kind)" | Out-Null
$null = Run 'powershell' "-NoProfile -ExecutionPolicy Bypass -File `"$INS`" -NoModifyPath"
$p1 = RawPath
W "after the install: the program folder on the user PATH: $(OnPath $p1.value); user PATH unchanged: $($p1.value -eq $p0.value -and $p1.kind -eq $p0.kind)" | Out-Null
$null = Run "$IDIR\jetcarp.exe" '--version'
$null = Run 'powershell' "-NoProfile -ExecutionPolicy Bypass -File `"$INS`" -Uninstall"
$p2 = RawPath
W "after -Uninstall: $(Defaults); user PATH unchanged: $($p2.value -eq $p0.value -and $p2.kind -eq $p0.kind)" | Out-Null

# ---------------------------------------------------------------- 134
W "`r`n### R5 #134 (and #128's other half): a normal install, jetcarp uninstall --yes --settings --data, then -Uninstall" | Out-Null
$null = Run 'powershell' "-NoProfile -ExecutionPolicy Bypass -File `"$INS`""
$p3 = RawPath
W "after the install: the program folder on the user PATH: $(OnPath $p3.value); PATH kind $($p3.kind); $(Defaults)" | Out-Null
$null = Run "$IDIR\jetcarp.exe" '--version'
$null = Run "$IDIR\jetcarp.exe" 'uninstall'
$null = Run "$IDIR\jetcarp.exe" 'uninstall --yes --settings --data'
W "after jetcarp uninstall: $(Defaults)" | Out-Null
$null = Run 'powershell' "-NoProfile -ExecutionPolicy Bypass -File `"$INS`" -Uninstall"
$p4 = RawPath
W "after -Uninstall: $(Defaults); the program folder on the user PATH: $(OnPath $p4.value); user PATH back as before the install: $($p4.value -eq $p0.value -and $p4.kind -eq $p0.kind)" | Out-Null
W "jetcarp processes: [$(Procs)]; JETCARP Run value: [$(RunVal)]" | Out-Null
W "#### done $(Get-Date -Format 'HH:mm:ss')" | Out-Null
"t5_rows done"
