# rc.4 wave on the Acer, the sitting with Jimmie: #96 after the answer (wallpaper on, login on, saver install) and
# #120 (Windows' own screen saver Preview with the warning unanswered), in Jimmie's account on the DEFAULT folders
# (no JETCARP_* variables): what Windows starts (the login entry, the .scr) finds JETCARP only there. Jimmie, 2026-11-17:
# JETCARP's data and settings on this laptop aren't sacred, so no copies are kept. rc.4 is named by its full path
# (`jetcarp` on the PATH is Scoop's 0.4.1). Steps, one per run, since Jimmie looks between them:
#   refused   the three commands refused in the default folders (no answer there yet), the desktop unchanged
#   answer    setup --seizure-warning no-disorder
#   wallpaper host start, wallpaper on, status; then wallpaper off, stop: the desktop's own picture back
#   login     login on (the Run value), then login off (gone)
#   saver     saver install (Screen Saver Settings opens), then the answer set aside (photosensitivity.json renamed)
#   watch     JETCARP message boxes, with their text, for -Seconds (left for Jimmie to close)
#   remove    saver remove, the answer put back
# ASCII only (PowerShell 5.1). Output: s2-desktop.txt beside this script, the home folder written as ~.
param([Parameter(Mandatory)][string]$Step, [int]$Seconds = 120)
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$UTF8 = New-Object Text.UTF8Encoding $false
$HERE = $PSScriptRoot
$T4 = "$env:USERPROFILE\jetcarp-rc4"
$B = "$env:USERPROFILE\jetcarp-rc-042c\bin\jetcarp.exe"
$LOG = "$T4\logs"
$CFG = "$env:APPDATA\jetcarp"
New-Item -ItemType Directory -Force $T4, $LOG | Out-Null
Set-Location $T4
Get-ChildItem Env: | Where-Object { $_.Name -like 'JETCARP_*' -or $_.Name -eq 'WGPU_BACKEND' } | ForEach-Object { Remove-Item "Env:$($_.Name)" }
$script:OUTF = Join-Path $HERE 's2-desktop.txt'
function W([string]$s) { $s = $s.Replace($env:USERPROFILE, '~'); [IO.File]::AppendAllText($script:OUTF, "$s`r`n", $UTF8); $s }
function Procs { (Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%' or Name like 'JETCARP%'" | ForEach-Object { "$($_.ProcessId) $($_.Name) $($_.CommandLine)".Replace($env:USERPROFILE, '~') }) -join ' | ' }
Add-Type @'
using System; using System.Runtime.InteropServices; using System.Text; using System.Collections.Generic;
public class S2W {
  public delegate bool P(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(P p, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr w, P p, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  // Visible dialog boxes (#32770) of the given processes: "hwnd pid | title | the texts of their static controls".
  public static List<string> Boxes(HashSet<uint> pids) {
    var o = new List<string>();
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      var c = new StringBuilder(64); GetClassName(h, c, 64);
      if (pids.Contains(p) && c.ToString() == "#32770" && IsWindowVisible(h)) {
        var t = new StringBuilder(256); GetWindowText(h, t, 256);
        var texts = new List<string>();
        EnumChildWindows(h, (k, m) => { var cc = new StringBuilder(64); GetClassName(k, cc, 64);
          if (cc.ToString() == "Static") { var s = new StringBuilder(4096); GetWindowText(k, s, 4096); if (s.Length > 0) texts.Add(s.ToString()); }
          return true; }, IntPtr.Zero);
        o.Add(h.ToInt64() + " " + p + " | " + t + " | " + String.Join(" / ", texts));
      }
      return true; }, IntPtr.Zero);
    return o; }
}
'@
$script:N = 0
function J([string]$argLine, [int]$timeoutS = 120) {
  $script:N++
  $stamp = Get-Date -Format 'HHmmss'
  $o = "$LOG\s2-$stamp-$($script:N)-out.txt"; $e = "$LOG\s2-$stamp-$($script:N)-err.txt"
  W "`$ jetcarp $argLine"
  $t0 = Get-Date
  $p = Start-Process $B -ArgumentList $argLine -RedirectStandardOutput $o -RedirectStandardError $e -NoNewWindow -PassThru -WorkingDirectory $T4
  $null = $p.Handle
  if (-not $p.WaitForExit($timeoutS * 1000)) { W "(no exit within $timeoutS s)"; $code = 'none' } else { $code = $p.ExitCode }
  $txt = ([string](Get-Content $o -Raw -Encoding UTF8) + [string](Get-Content $e -Raw -Encoding UTF8)).TrimEnd()
  if ($txt) { W $txt | Out-Null }
  W ("(exit {0}, {1:n1} s)" -f $code, ((Get-Date) - $t0).TotalSeconds) | Out-Null
}
function Desk([string]$when) {
  $run = Get-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
  $jr = @($run.GetValueNames() | Where-Object { $_ -match 'jetcarp' -or [string]$run.GetValue($_) -match 'jetcarp' } | ForEach-Object { "$_=$($run.GetValue($_))" }) -join '; '
  $d = Get-ItemProperty 'HKCU:\Control Panel\Desktop'
  $tw = Get-Item "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper" -ErrorAction SilentlyContinue
  $twh = if ($tw) { (Get-FileHash $tw.FullName -Algorithm SHA256).Hash.Substring(0, 12) + ' ' + $tw.LastWriteTime.ToString('s') } else { 'none' }
  $scr = Test-Path "$env:LOCALAPPDATA\JETCARP\JETCARP.scr"
  $hp = if (Test-Path "$CFG\host-program") { ((Get-Content "$CFG\host-program") -join ' ') } else { 'none' }
  $ph = if (Test-Path "$CFG\photosensitivity.json") { (Get-Content "$CFG\photosensitivity.json" -Raw) -replace '\s+', ' ' } else { 'none' }
  W "desktop $when`: JETCARP Run values [$jr]; SCRNSAVE.EXE [$($d.'SCRNSAVE.EXE')], active $($d.ScreenSaveActive), timeout $($d.ScreenSaveTimeOut) s; wallpaper picture $twh; JETCARP.scr $scr; host-program [$hp]; photosensitivity.json [$ph]; jetcarp processes [$(Procs)]" | Out-Null
}

W ""
W "#### s2 $Step, $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $(& $B --version), the default folders (no JETCARP_* variables)"
switch ($Step) {
  'refused' {
    Desk 'before'
    J 'paths'
    J 'host wallpaper on'
    J 'host login on'
    J 'host saver install'
    Desk 'after'
  }
  'answer' {
    J 'setup --seizure-warning no-disorder'
    J 'setup --status'
    Desk 'after'
  }
  'wallpaper' {
    Desk 'before'
    J 'host start'
    J 'host wallpaper on'
    Start-Sleep 20
    J 'host status'
    Desk 'with the wallpaper on'
    J 'host wallpaper off'
    J 'host stop'
    Start-Sleep 3
    Desk 'after'
  }
  'login' {
    Desk 'before'
    J 'host login on'
    Desk 'after login on'
    J 'host login off'
    Desk 'after login off'
  }
  'saver' {
    Desk 'before'
    J 'host saver install'
    J 'host saver status'
    Desk 'after saver install'
    if (Test-Path "$CFG\photosensitivity.json") { Rename-Item "$CFG\photosensitivity.json" 'photosensitivity.json.aside'; W 'the answer set aside: photosensitivity.json renamed photosensitivity.json.aside' }
    Desk 'with the answer set aside'
  }
  'watch' {
    W "watching for JETCARP message boxes for $Seconds s (left open for Jimmie)"
    $seen = @{}
    $end = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $end) {
      $pids = New-Object 'System.Collections.Generic.HashSet[uint32]'
      Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%' or Name like 'JETCARP%'" | ForEach-Object { [void]$pids.Add([uint32]$_.ProcessId) }
      $pr = Procs
      if ($pr -and -not $seen.ContainsKey("p:$pr")) { $seen["p:$pr"] = 1; W "$(Get-Date -Format 'HH:mm:ss') processes: $pr" | Out-Null }
      foreach ($bx in [S2W]::Boxes($pids)) { if (-not $seen.ContainsKey($bx)) { $seen[$bx] = 1; W "$(Get-Date -Format 'HH:mm:ss') BOX: $bx" | Out-Null } }
      Start-Sleep -Milliseconds 300
    }
    W "boxes seen: $(@($seen.Keys | Where-Object { $_ -notlike 'p:*' }).Count)"
  }
  'remove' {
    Desk 'before'
    J 'host saver remove'
    J 'host saver status'
    if (Test-Path "$CFG\photosensitivity.json.aside") { Rename-Item "$CFG\photosensitivity.json.aside" 'photosensitivity.json'; W 'the answer put back' }
    Desk 'after'
  }
  default { W "unknown step $Step" }
}
