# rc.4 wave on the Acer, 1.5 (the soak): a picture of the host's own wallpaper window (class JetcarpDesktopSurface,
# a child of the desktop's WorkerW), taken with PrintWindow(PW_RENDERFULLCONTENT), so nothing else on the screen is
# in it. Run in its own process with a time limit (t15_soak.ps1 kills it if it hangs). Prints one line.
#   powershell -NoProfile -ExecutionPolicy Bypass -File t15_shot.ps1 -HostPid N -Out file.jpg
param([Parameter(Mandatory)][int]$HostPid, [Parameter(Mandatory)][string]$Out)
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @'
using System; using System.Runtime.InteropServices; using System.Text; using System.Collections.Generic; using System.Drawing;
public class T15Shot {
  public delegate bool P(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(P p, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr w, P p, IntPtr l);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint f);
  public static IntPtr Surface(uint pid) { IntPtr found = IntPtr.Zero;
    P visit = (h, l) => { uint p; GetWindowThreadProcessId(h, out p); var c = new StringBuilder(64); GetClassName(h, c, 64);
      if (p == pid && c.ToString() == "JetcarpDesktopSurface") found = h; return true; };
    EnumWindows((h, l) => { visit(h, l); EnumChildWindows(h, visit, IntPtr.Zero); return true; }, IntPtr.Zero);
    return found; }
  public static string Shot(uint pid, string file) {
    IntPtr h = Surface(pid); if (h == IntPtr.Zero) return "no JetcarpDesktopSurface window";
    RECT r; GetWindowRect(h, out r); int w = r.R - r.L, ht = r.B - r.T; if (w <= 0 || ht <= 0) return "an empty window";
    using (var bmp = new Bitmap(w, ht)) {
      bool ok; using (var g = Graphics.FromImage(bmp)) { var hdc = g.GetHdc(); ok = PrintWindow(h, hdc, 2); g.ReleaseHdc(hdc); }
      long sum = 0; int n = 0, lit = 0; for (int y = 0; y < ht; y += 17) for (int x = 0; x < w; x += 17) { var c = bmp.GetPixel(x, y); int v = c.R + c.G + c.B; sum += v; n++; if (v > 60) lit++; }
      var enc = Array.Find(System.Drawing.Imaging.ImageCodecInfo.GetImageEncoders(), e => e.MimeType == "image/jpeg");
      var ps = new System.Drawing.Imaging.EncoderParameters(1); ps.Param[0] = new System.Drawing.Imaging.EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 80L);
      bmp.Save(file, enc, ps);
      return "PrintWindow " + ok + ", " + w + "x" + ht + ", mean " + (sum / (3.0 * n)).ToString("F1") + ", lit " + (100.0 * lit / n).ToString("F1") + "%"; } }
}
'@
[T15Shot]::Shot([uint32]$HostPid, $Out)
