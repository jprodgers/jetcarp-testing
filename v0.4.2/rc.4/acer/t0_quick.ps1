# rc.4 wave on the Acer (NOTES 2026-11-16 9:50 PM EST; v0.4.2-rc.4.md "The wave"): the quick unattended part.
#  0    The upgrade from rc.3: rc.4's zip (already checked against SHA256SUMS) put in place of rc.3's programs in
#       ~\jetcarp-rc-042c\bin, where rc.3's zip was unpacked; then rc.4 on rc.3's own settings and library (Phase 1's
#       test folders): version, paths, setup status, doctor, jobs, library, and host start (refused: no answer yet).
#  96   The seizure warning with a fresh settings folder: each command that starts or shows scenes is refused, and
#       MCP's host_control too; the desktop (JETCARP Run values, the screen saver, the wallpaper) is the same before
#       and after. Then the answer is saved, and a headless host and MCP work. (wallpaper on, login on and saver
#       install after the answer change the desktop and the registry: they wait for Jimmie.)
#  112  Fit hidden: help, host tune, MCP's schema; rc.1's host.json (the only one on this laptop with saved sizes)
#       on a window host.   84, 85: doctor with the GPU off; paths.   122: start/stop/start x10, headless.
#  116  The 64M-cell scene (A-6's) on a window host, which runs on the UHD: the status text and JSON.
# ASCII only (PowerShell 5.1). Every folder has config, data, out, library and run (mcpc.py's layout). Output files
# beside this script, the home folder written as ~. Never $b/$j/$w/$t (they would clobber $B and friends).
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
$UTF8 = New-Object Text.UTF8Encoding $false
$HERE = $PSScriptRoot
$T4 = "$env:USERPROFILE\jetcarp-rc4"
$R3 = "$env:USERPROFILE\jetcarp-rc-042c"
$B = "$R3\bin\jetcarp.exe"
$UNZ = "$R3\rc4-dl\unz\jetcarp-0.4.2-rc.4-x86_64-pc-windows-msvc"
$LOG = "$T4\logs"
New-Item -ItemType Directory -Force $T4, $LOG | Out-Null
Set-Location $T4
$script:OUTF = $null
$script:N = 0
function NewOut([string]$name) { $script:OUTF = Join-Path $HERE $name; [IO.File]::WriteAllText($script:OUTF, '', $UTF8) }
function W([string]$s) { $s = $s.Replace($env:USERPROFILE, '~'); [IO.File]::AppendAllText($script:OUTF, "$s`r`n", $UTF8); $s }
function Procs { (Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId) $($_.Name) $($_.CommandLine)".Replace($env:USERPROFILE, '~') }) -join ' | ' }
function Folders([string]$dir) {
  $env:JETCARP_CONFIG_DIR = "$dir\config"; $env:JETCARP_DATA_DIR = "$dir\data"; $env:JETCARP_OUT = "$dir\out"
  $env:JETCARP_LIBRARY = "$dir\library"; $env:JETCARP_RUNTIME_DIR = "$dir\run"
  Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue
  W "(folders: JETCARP_CONFIG_DIR, _DATA_DIR, _OUT, _LIBRARY, _RUNTIME_DIR = $dir\config, \data, \out, \library, \run)"
}
Add-Type @'
using System; using System.Runtime.InteropServices; using System.Text; using System.Collections.Generic;
public class R4W {
  public delegate bool P(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(P p, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  public static List<string> Boxes() {
    var o = new List<string>();
    EnumWindows((h, l) => { var c = new StringBuilder(64); GetClassName(h, c, 64); var s = new StringBuilder(64); GetWindowText(h, s, 64);
      if (c.ToString() == "#32770" && s.ToString() == "JETCARP" && IsWindowVisible(h)) { uint p; GetWindowThreadProcessId(h, out p); o.Add(h.ToInt64() + " " + p); }
      return true; }, IntPtr.Zero);
    return o; }
}
'@
# A jetcarp command, its output and exit code written down. Each call has its own output files: a host that
# `host start` leaves running may keep the files it inherited open.
function J([string]$argLine, [int]$timeoutS = 180) {
  $script:N++
  $o = "$LOG\j-$($script:N)-out.txt"; $e = "$LOG\j-$($script:N)-err.txt"
  W "`$ jetcarp $argLine"
  $t0 = Get-Date
  $p = Start-Process $B -ArgumentList $argLine -RedirectStandardOutput $o -RedirectStandardError $e -NoNewWindow -PassThru -WorkingDirectory $T4
  $null = $p.Handle
  if (-not $p.WaitForExit($timeoutS * 1000)) {
    $bx = [R4W]::Boxes(); W "(no exit within $timeoutS s; JETCARP message boxes up: $($bx.Count))"
    foreach ($x in $bx) { $h = ($x -split ' ')[0]; [void][R4W]::PostMessage([IntPtr][long]$h, 0x0111, [IntPtr]1, [IntPtr]::Zero); W "(closed box $x with IDOK)" }
    Start-Sleep 2; if (-not $p.HasExited) { & taskkill /PID $p.Id /T /F | Out-Null; W '(killed)' }
    $code = 'none'
  } else { $code = $p.ExitCode }
  $txt = ([string](Get-Content $o -Raw -Encoding UTF8) + [string](Get-Content $e -Raw -Encoding UTF8)).TrimEnd()
  if ($txt) { W $txt | Out-Null }
  W ("(exit {0}, {1:n1} s)" -f $code, ((Get-Date) - $t0).TotalSeconds) | Out-Null
  $script:LastText = $txt; $script:LastCode = $code
}
# The desktop state that the refused commands must not touch. Only JETCARP's own values are written down; the
# rest (other programs' Run values, the wallpaper's path) is compared but not logged.
function Desk {
  $run = Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
  $all = ($run.GetValueNames() | Sort-Object | ForEach-Object { "$_=$($run.GetValue($_))" }) -join ';'
  $jr = @($run.GetValueNames() | Where-Object { $_ -match 'jetcarp' -or [string]$run.GetValue($_) -match 'jetcarp' } | ForEach-Object { "$_=$($run.GetValue($_))" }) -join '; '
  $d = Get-ItemProperty 'HKCU:\Control Panel\Desktop'
  $tw = Get-Item "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper" -ErrorAction SilentlyContinue
  $twh = if ($tw) { (Get-FileHash $tw.FullName -Algorithm SHA256).Hash.Substring(0, 12) + ' ' + $tw.LastWriteTime.ToString('s') } else { 'none' }
  $scr = Test-Path "$env:LOCALAPPDATA\JETCARP\JETCARP.scr"
  $full = "$all|$($d.'SCRNSAVE.EXE')|$($d.ScreenSaveActive)|$($d.WallPaper)|$($d.WallpaperStyle)|$twh|$scr"
  $safe = "JETCARP Run values: [$jr]; SCRNSAVE.EXE: [$($d.'SCRNSAVE.EXE')]; ScreenSaveActive $($d.ScreenSaveActive); the wallpaper picture $twh, style $($d.WallpaperStyle); JETCARP.scr in %LOCALAPPDATA%\JETCARP: $scr; jetcarp processes: [$(Procs)]"
  [pscustomobject]@{ full = $full; safe = $safe }
}

# ---------------------------------------------------------------- 0. The upgrade
NewOut '0-upgrade.txt'
W "#### 0. The upgrade from rc.3 to rc.4, $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
W "rc.3 as installed: $(& $B --version); jetcarp.exe sha256 $((Get-FileHash $B -Algorithm SHA256).Hash.ToLower().Substring(0,16))...; $((Get-ChildItem -Recurse -File "$R3\bin").Count) files in bin"
W "jetcarp processes before: [$(Procs)]"
$desk0 = Desk; W "desktop before: $($desk0.safe)"
W "rc.4's zip unpacked to $UNZ; each of its files copied over rc.3's at the same place in $R3\bin (Copy-Item -Force)"
foreach ($f in Get-ChildItem -Recurse -File $UNZ) { $dst = "$R3\bin" + $f.FullName.Substring($UNZ.Length); New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null; Copy-Item -LiteralPath $f.FullName -Destination $dst -Force }
$bad = @(); $nf = 0
foreach ($f in Get-ChildItem -Recurse -File $UNZ) { $nf++; $rel = $f.FullName.Substring($UNZ.Length); $dst = "$R3\bin$rel"; if (-not (Test-Path $dst) -or (Get-FileHash $dst).Hash -ne (Get-FileHash $f.FullName).Hash) { $bad += $rel } }
$extra = @(Get-ChildItem -Recurse -File "$R3\bin" | Where-Object { -not (Test-Path ($UNZ + $_.FullName.Substring("$R3\bin".Length))) } | ForEach-Object { $_.FullName.Substring("$R3\bin".Length) })
W "rc.4's $nf files in place; differing from the zip: $($bad.Count) $($bad -join ', '); in bin but not in rc.4's zip: $($extra.Count) $($extra -join ', ')"
W "jetcarp.exe sha256 now $((Get-FileHash $B -Algorithm SHA256).Hash.ToLower().Substring(0,16))..."
W "`r`n#### rc.4 on rc.3's settings and library (Phase 1's test folders)"
$env:JETCARP_CONFIG_DIR = "$R3\config"; $env:JETCARP_DATA_DIR = "$R3\data"; $env:JETCARP_OUT = "$R3\out"; $env:JETCARP_RUNTIME_DIR = "$R3\runtime"
Remove-Item Env:JETCARP_LIBRARY, Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue
W "(folders: JETCARP_CONFIG_DIR, _DATA_DIR, _OUT, _RUNTIME_DIR = $R3\config, \data, \out, \runtime; as rc.3's Phase 1)"
J '--version'
J 'paths'
J 'setup --status'
J 'doctor'
J 'jobs list'
$script:N++; $lf = "$LOG\j-$($script:N)-library.txt"
& $B library list > $lf 2>&1; $lc = $LASTEXITCODE
W "`$ jetcarp library list   (exit $lc; $(@(Get-Content $lf).Count) lines; the first 4:)"; Get-Content $lf -TotalCount 4 | ForEach-Object { W "  $_" | Out-Null }
J 'host start'
J 'host status'
$desk1 = Desk; W "desktop after: $($desk1.safe)"; W "desktop unchanged: $($desk0.full -eq $desk1.full)"

# ---------------------------------------------------------------- 96. The seizure warning, fresh folder
NewOut '96-warning.txt'
$F96 = "$T4\f96"
if (Test-Path $F96) { Remove-Item -Recurse -Force $F96 }
New-Item -ItemType Directory -Force $F96 | Out-Null
W "#### R4 #96: the photosensitive seizure warning, with a fresh settings folder, $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Folders $F96
$desk0 = Desk; W "desktop before: $($desk0.safe)"
J 'setup --status'
W "`r`n## Refused before the answer"
J 'host start'
J 'host start --headless'
J 'host wallpaper on'
J 'host login on'
J 'host saver install'
J 'host start --saver'
W '(the plan names `host start --saver`; host start has no --saver, so also what a screen saver runs:)'
J 'host serve --saver --seconds 1' 30
J 'host status'
W "`r`n## MCP host_control, no answer and no host (96-mcp-refuse.txt)"
& python -X utf8 -B "$HERE\t0_mcp.py" refuse $F96 96-mcp-refuse 2>&1 | ForEach-Object { W "  $_" } | Out-Null
$desk1 = Desk; W "desktop after the refusals: $($desk1.safe)"; W "desktop unchanged: $($desk0.full -eq $desk1.full)"
W "photosensitivity.json before the answer: $(Test-Path "$F96\config\photosensitivity.json")"
W "`r`n## The answer"
J 'setup --seizure-warning no-disorder'
W "photosensitivity.json:"; W ([string](Get-Content "$F96\config\photosensitivity.json" -Raw -ErrorAction SilentlyContinue)) | Out-Null
J 'setup --status'
W "`r`n## After the answer (headless: the desktop untouched)"
J 'host start --headless'
Start-Sleep 3
J 'host status'
W "`r`n## MCP host_control with the answer and a headless host (96-mcp-accepted.txt)"
& python -X utf8 -B "$HERE\t0_mcp.py" accepted $F96 96-mcp-accepted 2>&1 | ForEach-Object { W "  $_" } | Out-Null
J 'host status'
J 'host stop'
$desk2 = Desk; W "desktop at the end: $($desk2.safe)"; W "desktop unchanged: $($desk0.full -eq $desk2.full)"

# ---------------------------------------------------------------- 112. Fit is hidden
NewOut '112-fit.txt'
W "#### R4 #112: Fit to this computer is hidden, $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Folders $F96
$script:N++; $hf = "$LOG\j-$($script:N)-hosthelp.txt"; & $B host --help > $hf 2>&1
W "`$ jetcarp host --help   (exit $LASTEXITCODE): lines naming tune: [$((Select-String -Path $hf -Pattern 'tune' | ForEach-Object { $_.Line.Trim() }) -join ' / ')]; its commands: $((Select-String -Path $hf -Pattern '^  (\w[\w-]*) ' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ', ')"
J 'host tune'
J 'host tune --dry-run'
J 'host tune --help'
W "(MCP's schema and tune calls: 96-mcp-refuse.txt and 96-mcp-accepted.txt)"
W "`r`n## rc.1's host.json with its saved sizes, on a window host"
$H112 = "$T4\h112"
if (Test-Path $H112) { Remove-Item -Recurse -Force $H112 }
New-Item -ItemType Directory -Force "$H112\config" | Out-Null
$hj = [IO.File]::ReadAllText("$env:USERPROFILE\jetcarp-rc-042\config\host.json")
W "The Acer has no rc.3 host.json with saved sizes (no Fit ran here under rc.3). rc.1's (~\jetcarp-rc-042\config\host.json, 2026-11-14) saved 16 px for the three scenes of 'Until it settles' (design 3 px), for a 1920 x 1080 wallpaper. A copy, with the screen's place 'wallpaper' made 'window' and its rotation 'Classics, hourly' made 'Until it settles' (the tuned one), so the tuned scenes are what it shows:"
$hj = $hj.Replace('"rotation": "Classics, hourly",', '"rotation": "Until it settles",').Replace('"place": "wallpaper"', '"place": "window"')
[IO.File]::WriteAllText("$H112\config\host.json", $hj, $UTF8)
Folders $H112
J 'setup --seizure-warning no-disorder'
J 'host start'
Start-Sleep 15
J 'host status'
J 'host status --json'
foreach ($k in 1, 2) { J 'host next'; Start-Sleep 8; J 'host status' }
J 'host stop'
W "host.json after the host (tuning block kept?): $(([IO.File]::ReadAllText("$H112\config\host.json")) -match '"tuning"')"

# ---------------------------------------------------------------- 84, 85
NewOut '84-85.txt'
W "#### R4 #84 (doctor with the GPU off) and #85 (paths names the runtime folder), $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Folders $F96
$env:JETCARP_GPU = 'off'; W '(JETCARP_GPU=off)'
J 'doctor'
Remove-Item Env:JETCARP_GPU
W '(JETCARP_GPU unset, for comparison)'
J 'doctor'
J 'paths'
J 'paths --json'

# ---------------------------------------------------------------- 122. start, stop, start x10
NewOut '122-start-stop.txt'
W "#### R4 #122: host start --headless; host stop; host start --headless, ten times in a row, $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$H122 = "$T4\h122"
if (Test-Path $H122) { Remove-Item -Recurse -Force $H122 }
New-Item -ItemType Directory -Force $H122 | Out-Null
Folders $H122
J 'setup --seizure-warning no-disorder'
$ok = 0
for ($i = 1; $i -le 10; $i++) {
  W "`r`n## round $i"
  J 'host start --headless'; $c1 = $script:LastCode
  J 'host stop'
  J 'host start --headless'; $c2 = $script:LastCode
  J 'host stop'
  if ($c1 -eq 0 -and $c2 -eq 0) { $ok++ }
}
W "`r`nRESULT #122: both starts worked in $ok of 10 rounds; jetcarp processes at the end: [$(Procs)]"

# ---------------------------------------------------------------- 116. The speed a screen reaches
NewOut '116-measured-speed.txt'
W "#### R4 #116: host status gives the speed a screen reaches (a window host, on the UHD), $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$H116 = "$T4\h116"
if (Test-Path $H116) { Remove-Item -Recurse -Force $H116 }
New-Item -ItemType Directory -Force "$H116\config\rotations", "$H116\big" | Out-Null
Copy-Item "$R3\a6\big\life-64m.json" "$H116\big\"
$rot = [IO.File]::ReadAllText("$R3\a6\config\rotations\big-64m.json").Replace(($R3 + '\a6\big').Replace('\', '\\'), ($H116 + '\big').Replace('\', '\\'))
[IO.File]::WriteAllText("$H116\config\rotations\big-64m.json", $rot, $UTF8)
$hj = [IO.File]::ReadAllText("$R3\a6\config\host.json").Replace('"rotation": "A classic a day"', '"rotation": "Big 64M"')
[IO.File]::WriteAllText("$H116\config\host.json", $hj, $UTF8)
W "A-6's rotation 'Big 64M' (one 8000 x 8000 Life scene, refill off) on one window screen; A-6 saw 3.9 generations a second against 30 asked."
Folders $H116
J 'setup --seizure-warning no-disorder'
J 'host start'
Start-Sleep 30
J 'host status'
J 'host status --json'
Start-Sleep 30
J 'host status'
J 'host status --json'
J 'host stop'
W "`r`njetcarp processes at the end: [$(Procs)]"
"t0_quick done"
