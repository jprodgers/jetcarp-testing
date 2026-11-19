# rc.5 wave on the Acer, A-8 (v0.4.2-rc.4.md Phase 2; 2.MM without Fit, #112's monitor change, #130), with Jimmie.
# rc.5's host in its own folder (~\jetcarp-rc5\a8, every JETCARP_* set; the warning answered there), on Jimmie's own
# desktop, with the AOC plugged in on the left of the laptop's screen.
#   -Step start   fresh folder, the answer, host start, screen 0 on monitor 0 ("A classic a day", the default),
#                 screen 1 on monitor 1 ("Classics, hourly"), then a status
#   -Step status  host status (text, and each screen from the JSON), the monitors Windows sees, the host's
#                 wallpaper windows and a picture of each, host.json's hash, the host's GPU use
#   -Step watch   host status --json every second for -Seconds, one line whenever something changes (and every
#                 10 s): pid, held, each screen's monitor, canvas, grid, cells, cell size, scene and generation, any
#                 tune/fit key, and the monitors Windows sees. host.json's hash at both ends
#   -Step start   (again, with -Keep) host start on the same folder, for #130 (the AOC unplugged first)
#   -Step stop    host stop, and the desktop picture's hash
# Writes a8.txt beside this script (the home folder as ~). ASCII only.
param([Parameter(Mandatory)][ValidateSet('start','status','watch','stop')][string]$Step,
      [int]$Seconds = 120, [string]$Label = '', [switch]$Keep)
$ErrorActionPreference = 'Continue'
$UTF8 = New-Object Text.UTF8Encoding $false
$HERE = $PSScriptRoot
$OUTF = Join-Path $HERE 'a8.txt'
$S = "$env:USERPROFILE\jetcarp-rc5\a8"
$EXE = "$env:USERPROFILE\jetcarp-rc-042c\bin\jetcarp.exe"
$LOGD = "$S\logs"
function Home([string]$s) { $s.Replace($env:USERPROFILE, '~').Replace($env:USERPROFILE.Replace('\', '\\'), '~') }
function W([string]$s) { $s = Home "$(Get-Date -Format 'HH:mm:ss') $s"; [IO.File]::AppendAllText($OUTF, "$s`r`n", $UTF8); $s }
function Folders {
  $env:JETCARP_CONFIG_DIR = "$S\config"; $env:JETCARP_DATA_DIR = "$S\data"; $env:JETCARP_OUT = "$S\out"
  $env:JETCARP_LIBRARY = "$S\library"; $env:JETCARP_RUNTIME_DIR = "$S\run"
  Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue
}
# A jetcarp command through Start-Process with its own output files (a host that `host start` leaves running would
# keep a pipe open).
$script:N = 0
function Jx([string]$argLine, [int]$timeoutS = 90) {
  $script:N++
  $o = "$LOGD\j-$Step-$($script:N)-out.txt"; $e = "$LOGD\j-$Step-$($script:N)-err.txt"
  $p = Start-Process $EXE -ArgumentList $argLine -RedirectStandardOutput $o -RedirectStandardError $e -NoNewWindow -PassThru -WorkingDirectory "$S\cwd"
  $null = $p.Handle
  if (-not $p.WaitForExit($timeoutS * 1000)) { $code = 'none (timed out)' } else { $code = $p.ExitCode }
  $txt = ([string](Get-Content $o -Raw -Encoding UTF8) + [string](Get-Content $e -Raw -Encoding UTF8)).TrimEnd()
  W "`$ jetcarp $argLine   (exit $code)" | Out-Null
  if ($txt) { foreach ($l in ($txt -split "`r?`n")) { W "  $l" | Out-Null } }
  $txt
}
function StatusJson { try { (& $EXE host status --json 2>$null | Out-String) | ConvertFrom-Json } catch { $null } }
function HostJsonHash { $f = "$S\config\host.json"; if (Test-Path $f) { (Get-FileHash $f -Algorithm SHA256).Hash.Substring(0, 12) } else { 'none' } }
function WallHash { $tw = Get-Item "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper" -ErrorAction SilentlyContinue; if ($tw) { (Get-FileHash $tw.FullName -Algorithm SHA256).Hash.Substring(0, 12) + ' ' + $tw.LastWriteTime.ToString('s') } else { 'none' } }
# Every key whose name has tune or fit in it, anywhere in the status.
function TuneKeys($o, [string]$path = '') {
  $found = @()
  if ($o -is [System.Management.Automation.PSCustomObject]) {
    foreach ($p in $o.PSObject.Properties) { $q = "$path.$($p.Name)"; if ($p.Name -match 'tune|fit') { $found += $q }; $found += TuneKeys $p.Value $q }
  } elseif ($o -is [array]) { $i = 0; foreach ($x in $o) { $found += TuneKeys $x "$path[$i]"; $i++ } }
  $found
}
function Screens($st) {
  if (-not $st) { return 'no status' }
  $parts = @(); $i = 0
  foreach ($sc in $st.screens) {
    $g = $sc.stage
    $parts += ("s{0} mon={1} place={2} hidden={3} canvas={4} grid={5} cells={6} px={7} [{8}] gen={9} {10}/{11} sim={12}" -f $i, $sc.monitor, $sc.place, $sc.hidden, ($g.canvas -join 'x'), ($g.grid -join 'x'), $g.cells, $g.cell_px, $g.label, $g.generation, $g.measured_speed, $g.speed, $sc.simulation.on)
    $i++
  }
  "pid=$($st.pid) held=[$($st.held -join ',')] paused=$($st.paused) monitors=[$($st.monitors -join ', ')] :: " + ($parts -join ' || ')
}
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
function WinMonitors { ([System.Windows.Forms.Screen]::AllScreens | ForEach-Object { "$($_.DeviceName) $($_.Bounds.X),$($_.Bounds.Y) $($_.Bounds.Width)x$($_.Bounds.Height)$(if ($_.Primary) { ' primary' })" }) -join '; ' }
Add-Type -ReferencedAssemblies System.Drawing @'
using System; using System.Runtime.InteropServices; using System.Text; using System.Collections.Generic; using System.Drawing;
public class A8W {
  public delegate bool P(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(P p, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr w, P p, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint f);
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(IntPtr v);
  [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern IntPtr MonitorFromWindow(IntPtr h, uint f);
  [DllImport("shcore.dll")] public static extern int GetDpiForMonitor(IntPtr m, int t, out uint x, out uint y);
  // Each wallpaper window: where it is, the DPI Windows gives the window, and its monitor's effective DPI.
  public static string Placement(uint pid) { var o = new List<string>(); int i = 0;
    foreach (var h in Surfaces(pid)) { uint x, y; IntPtr m = MonitorFromWindow(h, 2); GetDpiForMonitor(m, 0, out x, out y);
      o.Add("w" + i + " " + Rect(h) + " dpi " + GetDpiForWindow(h) + " mon-dpi " + x); i++; }
    return String.Join("; ", o.ToArray()); }
  public static List<IntPtr> Surfaces(uint pid) { var found = new List<IntPtr>();
    P visit = (h, l) => { uint p; GetWindowThreadProcessId(h, out p); var c = new StringBuilder(64); GetClassName(h, c, 64);
      if (p == pid && c.ToString() == "JetcarpDesktopSurface" && !found.Contains(h)) found.Add(h); return true; };
    EnumWindows((h, l) => { visit(h, l); EnumChildWindows(h, visit, IntPtr.Zero); return true; }, IntPtr.Zero);
    return found; }
  public static string Rect(IntPtr h) { RECT r; GetWindowRect(h, out r); return r.L + "," + r.T + " " + (r.R - r.L) + "x" + (r.B - r.T) + (IsWindowVisible(h) ? "" : " (hidden)"); }
  public static string Shot(IntPtr h, string file) {
    RECT r; GetWindowRect(h, out r); int w = r.R - r.L, ht = r.B - r.T; if (w <= 0 || ht <= 0) return "an empty window";
    using (var bmp = new Bitmap(w, ht)) {
      bool ok; using (var g = Graphics.FromImage(bmp)) { var hdc = g.GetHdc(); ok = PrintWindow(h, hdc, 2); g.ReleaseHdc(hdc); }
      long sum = 0; int n = 0; for (int y = 0; y < ht; y += 17) for (int x = 0; x < w; x += 17) { var c = bmp.GetPixel(x, y); sum += c.R + c.G + c.B; n++; }
      using (var half = new Bitmap(bmp, w / 2, ht / 2)) {
        var enc = Array.Find(System.Drawing.Imaging.ImageCodecInfo.GetImageEncoders(), e => e.MimeType == "image/jpeg");
        var ps = new System.Drawing.Imaging.EncoderParameters(1); ps.Param[0] = new System.Drawing.Imaging.EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 80L);
        half.Save(file, enc, ps); }
      return "PrintWindow " + ok + ", " + w + "x" + ht + ", mean " + (sum / (3.0 * n)).ToString("F1"); } }
}
'@
# Per-monitor aware (v2), so monitor bounds and DPIs are the real ones; system-aware if that isn't available.
if (-not [A8W]::SetProcessDpiAwarenessContext([IntPtr](-4))) { [void][A8W]::SetProcessDPIAware() }
function Gpu([int]$procId) {
  if (-not $procId) { return '' }
  $c = Get-Counter "\GPU Engine(pid_$($procId)_*)\Utilization Percentage" -SampleInterval 2 -MaxSamples 2 -ErrorAction SilentlyContinue
  if (-not $c) { return 'no GPU counters' }
  $by = @{}; foreach ($smp in $c[-1].CounterSamples) { if ($smp.InstanceName -match 'engtype_(\w+)') { $k = $Matches[1]; $by[$k] = [double]$by[$k] + $smp.CookedValue } }
  ($by.Keys | Sort-Object | ForEach-Object { '{0} {1:N1}%' -f $_, $by[$_] }) -join ', '
}
function Look([string]$tag) {
  $st = StatusJson
  W "-- status $tag" | Out-Null
  $null = Jx 'host status'
  W "screens (JSON): $(Screens $st)" | Out-Null
  $tk = @(TuneKeys $st); W "tune/fit keys in the status: $($tk.Count) $($tk -join ', ')" | Out-Null
  W "Windows' monitors: $(WinMonitors)" | Out-Null
  W "host.json $(HostJsonHash); desktop picture $(WallHash)" | Out-Null
  if ($st -and $st.pid) {
    $i = 0
    foreach ($h in [A8W]::Surfaces([uint32]$st.pid)) {
      $f = Join-Path $HERE ("shot-{0}-{1}.jpg" -f ($tag -replace '[^A-Za-z0-9]+', '-'), $i)
      W "wallpaper window $i at $([A8W]::Rect($h)): $([A8W]::Shot($h, $f)) -> $(Split-Path $f -Leaf)" | Out-Null
      $i++
    }
    if ($i -eq 0) { W "no JetcarpDesktopSurface window" | Out-Null }
    W "the host's GPU use: $(Gpu ([int]$st.pid))" | Out-Null
  }
}

New-Item -ItemType Directory -Force $S, $LOGD, "$S\cwd" | Out-Null
Folders
Set-Location "$S\cwd"
switch ($Step) {
  'start' {
    if (-not $Keep) {
      W "=== A-8 start $Label (fresh folder ~\jetcarp-rc5\a8)" | Out-Null
      Get-ChildItem $S -Exclude logs, cwd -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
      $null = Jx '--version'
      $null = Jx 'setup --seizure-warning no-disorder'
      W "Windows' monitors: $(WinMonitors)" | Out-Null
      $null = Jx 'host start' 120
      Start-Sleep -Seconds 5
      $null = Jx 'host wallpaper on --screen 0 --monitor 0'
      $null = Jx 'host wallpaper on --screen 1 --monitor 1 --rotation "Classics, hourly"'
      Start-Sleep -Seconds 10
      Look 'two-screens'
    } else {
      W "=== A-8 start again on the same folder $Label" | Out-Null
      W "Windows' monitors: $(WinMonitors); host.json $(HostJsonHash)" | Out-Null
      $null = Jx 'host start' 120
      Start-Sleep -Seconds 10
      Look 'restarted-10s'
      Start-Sleep -Seconds 30
      Look 'restarted-45s'
    }
  }
  'status' { Look $Label }
  'watch' {
    W "=== watch $Label for $Seconds s; host.json $(HostJsonHash)" | Out-Null
    $last = ''; $t0 = Get-Date; $beat = $t0
    while (((Get-Date) - $t0).TotalSeconds -lt $Seconds) {
      $st = StatusJson
      $tk = if ($st) { @(TuneKeys $st).Count } else { '-' }
      $pl = if ($st -and $st.pid) { [A8W]::Placement([uint32]$st.pid) } else { '' }
      $line = "$(Screens $st) | tune/fit keys $tk | windows: $pl | Windows: $(WinMonitors)"
      # Generations always move: compare without them, but write them down.
      $cmp = $line -replace 'gen=\d+ ', '' -replace '\d+(\.\d+)?/', ''
      if ($cmp -ne $last -or ((Get-Date) - $beat).TotalSeconds -ge 10) { W $line | Out-Null; $last = $cmp; $beat = Get-Date }
      Start-Sleep -Milliseconds 1000
    }
    W "=== watch $Label done; host.json $(HostJsonHash)" | Out-Null
  }
  'stop' {
    W "=== stop $Label" | Out-Null
    $null = Jx 'host stop'
    Start-Sleep -Seconds 4
    W "after: jetcarp processes [$((Get-Process jetcarp* -ErrorAction SilentlyContinue | ForEach-Object { "$($_.Id) $($_.ProcessName)" }) -join ', ')]; desktop picture $(WallHash)" | Out-Null
  }
}
