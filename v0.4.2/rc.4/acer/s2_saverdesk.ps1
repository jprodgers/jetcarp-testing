# rc.4 wave on the Acer, #120: the windows on Windows' Screen-saver desktop, where a screen saver (and any message
# box it shows) runs, so EnumWindows on the Default desktop doesn't see them. Appends them to s2-desktop.txt.
#   powershell -NoProfile -ExecutionPolicy Bypass -File s2_saverdesk.ps1 -Label "..."
param([string]$Label = '')
$UTF8 = New-Object Text.UTF8Encoding $false
$OUTF = Join-Path $PSScriptRoot 's2-desktop.txt'
Add-Type @'
using System; using System.Runtime.InteropServices; using System.Text; using System.Collections.Generic;
public class S2E {
  public delegate bool P(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)] public static extern IntPtr OpenDesktop(string n, uint f, bool inh, uint acc);
  [DllImport("user32.dll")] public static extern bool CloseDesktop(IntPtr d);
  [DllImport("user32.dll")] public static extern bool EnumDesktopWindows(IntPtr d, P p, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr w, P p, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  public static List<string> On(string desk) { var o = new List<string>();
    IntPtr d = OpenDesktop(desk, 0, false, 0x0040 | 0x0001);
    if (d == IntPtr.Zero) { o.Add("OpenDesktop(" + desk + ") failed: " + Marshal.GetLastWin32Error()); return o; }
    EnumDesktopWindows(d, (h, l) => { uint p; GetWindowThreadProcessId(h, out p); var c = new StringBuilder(128); GetClassName(h, c, 128); var t = new StringBuilder(256); GetWindowText(h, t, 256);
      var texts = new List<string>();
      EnumChildWindows(h, (k, m) => { var cc = new StringBuilder(64); GetClassName(k, cc, 64); var s = new StringBuilder(4096); GetWindowText(k, s, 4096); if (s.Length > 0) texts.Add(cc + ":" + s); return true; }, IntPtr.Zero);
      o.Add(p + " " + c + " [" + t + "] visible=" + IsWindowVisible(h) + " :: " + String.Join(" / ", texts)); return true; }, IntPtr.Zero);
    CloseDesktop(d); return o; }
}
'@
$procs = (Get-CimInstance Win32_Process -Filter "Name like 'jetcarp%' or Name like 'JETCARP%'" | ForEach-Object { "$($_.ProcessId) $($_.Name) $($_.CommandLine)" }) -join ' | '
$win = [S2E]::On('Screen-saver')
$lines = @("$(Get-Date -Format 'HH:mm:ss') $Label", "  jetcarp processes: [$procs]", "  windows on the Screen-saver desktop: $($win.Count)") + ($win | ForEach-Object { '  ' + ($_ -replace "(\r?\n)+", ' / ') })
$text = (($lines -join "`r`n") + "`r`n").Replace($env:USERPROFILE, '~')
[IO.File]::AppendAllText($OUTF, $text, $UTF8)
$text
