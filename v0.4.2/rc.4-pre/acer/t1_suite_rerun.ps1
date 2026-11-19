# rc.4 pre-check on the Acer, step 1 again: the whole suite with JETCARP_GPU=RTX (or the -Gpu given), after the first
# RTX run hung in host.rs on the saver's message box (1-suite-hang.txt) and timed out. The same command and scratch
# folders as pre.ps1, with a watcher: a 'JETCARP' message box (#32770) from a jetcarp.exe running `host serve --saver`
# is left up 10 s, logged with its text, then closed with WM_COMMAND IDOK (OK only closes it; it accepts nothing).
# Nothing else is touched. ASCII only. Output: $T2\logs\1-tests-<gpu>-<tag>.txt and 1-rerun-<gpu>-<tag>.log.
# After #120 (41f7f2f) no box should appear at all: the log counts any the watcher had to close.
#   -Gpu RTX -Tag 41f7f2f -TimeoutS 10800                     the whole suite
#   -Gpu UHD -Tag host-41f7f2f -Scope '-p jetcarp --test host'  host.rs alone
param([string]$Gpu = 'RTX', [int]$HoldS = 10, [int]$TimeoutS = 5400, [string]$Tag = 'rerun', [string]$Scope = '--workspace --no-fail-fast')
$ErrorActionPreference = 'Continue'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
$UTF8 = New-Object Text.UTF8Encoding $false
$T2 = "$env:USERPROFILE\jetcarp-rc4pre"
$SRC = "$env:USERPROFILE\jetcarp-rc-042c\src"
$LOG = "$T2\logs"
$g = $Gpu.ToLower()
$OUT = "$LOG\1-tests-$g-$Tag.txt"
$WL = "$LOG\1-rerun-$g-$Tag.log"
[IO.File]::WriteAllText($WL, '', $UTF8)
function L([string]$msg) { [IO.File]::AppendAllText($WL, "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg`r`n", $UTF8) }
Add-Type @'
using System; using System.Runtime.InteropServices; using System.Text; using System.Collections.Generic;
public class RerunW {
  public delegate bool P(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(P p, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr parent, P p, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, StringBuilder l);
  [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  public static List<string> Boxes() {
    var o = new List<string>();
    EnumWindows((h, l) => {
      var c = new StringBuilder(64); GetClassName(h, c, 64);
      var s = new StringBuilder(64); GetWindowText(h, s, 64);
      if (c.ToString() == "#32770" && s.ToString() == "JETCARP" && IsWindowVisible(h)) { uint p; GetWindowThreadProcessId(h, out p); o.Add(h.ToInt64() + " " + p); }
      return true; }, IntPtr.Zero);
    return o; }
  public static string Text(IntPtr dlg) {
    var all = new StringBuilder();
    EnumChildWindows(dlg, (h, l) => { int n = (int)SendMessage(h, 0x000E, IntPtr.Zero, IntPtr.Zero); var s = new StringBuilder(n + 1); SendMessage(h, 0x000D, (IntPtr)(n + 1), s); if (s.Length > 0) all.Append("[" + s.ToString().Split('\n')[0].Trim() + "] "); return true; }, IntPtr.Zero);
    return all.ToString(); }
}
'@
$env:JETCARP_CONFIG_DIR = "$T2\scratch-tests\config"; $env:JETCARP_DATA_DIR = "$T2\scratch-tests\data"; $env:JETCARP_OUT = "$T2\scratch-tests\out"; $env:JETCARP_RUNTIME_DIR = "$T2\scratch-tests\runtime"
Remove-Item Env:WGPU_BACKEND, Env:JETCARP_LIBRARY -ErrorAction SilentlyContinue
$env:JETCARP_GPU = $Gpu
L "=== cargo test --release $Scope, JETCARP_GPU=$Gpu, src $(git -C $SRC log --oneline -1); $(& "$SRC\target\release\jetcarp.exe" --version); watcher holds a box ${HoldS} s then closes it; timeout $TimeoutS s"
$t0 = Get-Date
$p = Start-Process cmd -ArgumentList "/c cargo test --release $Scope > `"$OUT`" 2>&1" -WorkingDirectory $SRC -NoNewWindow -PassThru
$null = $p.Handle
$seen = @{}
$closed = 0
while (-not $p.HasExited) {
  if (((Get-Date) - $t0).TotalSeconds -gt $TimeoutS) { L "TIMEOUT after $TimeoutS s; killing the tree"; & taskkill /PID $p.Id /T /F | Out-Null; break }
  foreach ($b in [RerunW]::Boxes()) {
    $h, $bp = $b -split ' '
    $proc = Get-CimInstance Win32_Process -Filter "ProcessId = $bp" -ErrorAction SilentlyContinue
    $cmdl = if ($proc) { [string]$proc.CommandLine } else { '' }
    if ($cmdl -notmatch 'jetcarp\.exe"?\s+host serve --saver') { if (-not $seen[$b]) { L "a JETCARP box from pid $bp left alone: $cmdl"; $seen[$b] = (Get-Date) }; continue }
    if (-not $seen[$b]) { $seen[$b] = Get-Date; L "box $h up from pid $bp ($($cmdl.Replace($env:USERPROFILE, '~'))): $([RerunW]::Text([IntPtr][long]$h))" }
    elseif ($seen[$b] -is [datetime] -and ((Get-Date) - $seen[$b]).TotalSeconds -ge $HoldS) {
      [void][RerunW]::PostMessage([IntPtr][long]$h, 0x0111, [IntPtr]1, [IntPtr]::Zero)
      $closed++; L ("box {0} closed with IDOK after {1:n0} s" -f $h, ((Get-Date) - $seen[$b]).TotalSeconds); $seen[$b] = 'closed'
    }
  }
  Start-Sleep -Milliseconds 1000
}
$p.WaitForExit()
$secs = ((Get-Date) - $t0).TotalSeconds
$txt = Get-Content $OUT -Encoding UTF8 -ErrorAction SilentlyContinue
# @() so that one test binary's line stays one row (without it PowerShell unrolls the single row into its 3 numbers:
# the UHD host.rs run on 41f7f2f was first counted "18 passed, 0 failed, 0 ignored in 3 test binaries").
$sums = @($txt | Select-String '^test result: \w+\. (\d+) passed; (\d+) failed; (\d+) ignored' | ForEach-Object { , @([int]$_.Matches[0].Groups[1].Value, [int]$_.Matches[0].Groups[2].Value, [int]$_.Matches[0].Groups[3].Value) })
$np = ($sums | ForEach-Object { $_[0] } | Measure-Object -Sum).Sum; $nf = ($sums | ForEach-Object { $_[1] } | Measure-Object -Sum).Sum; $ni = ($sums | ForEach-Object { $_[2] } | Measure-Object -Sum).Sum
$failedNames = ($txt | Select-String '^test (\S+) \.\.\. FAILED' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ', '
$crashed = ($txt | Select-String 'process didn''t exit successfully|STATUS_ACCESS_VIOLATION|0xc0000005' | ForEach-Object { $_.Line.Trim() }) -join ' / '
$code = if ($p.HasExited) { $p.ExitCode } else { 'killed' }
L ("RESULT 1-{0}-$Tag : {1}:{2} passed, {3} failed, {4} ignored in {5} test binaries; exit {6}, {7:n0} min; message boxes closed by the watcher: {8}{9}{10}" -f $g, $(if ($code -eq 0 -and $nf -eq 0) { 'pass' } else { 'FAIL' }), $np, $nf, $ni, @($sums).Count, $code, ($secs / 60), $closed, $(if ($failedNames) { "; failed: $failedNames" } else { '' }), $(if ($crashed) { "; crashed: $crashed" } else { '' }))
L "jetcarp processes at the end: $((Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%'" | ForEach-Object { "$($_.ProcessId) $($_.Name)" }) -join ' | ')"
"t1_suite_rerun done"
