# R4 #104 helper: read another console's text, row by row, into a file (FreeConsole, AttachConsole to a process on
# that console, then ReadConsoleOutputCharacter on CONOUT$). Run it as its own powershell process, since it gives up
# its own console. ASCII only.   powershell -NoProfile -File t104_read.ps1 <pid on that console> <out.txt>
param([int]$ConPid, [string]$Out)
Add-Type @'
using System; using System.Runtime.InteropServices; using System.Text;
public static class ConRead {
  [StructLayout(LayoutKind.Sequential)] public struct COORD { public short X, Y; }
  [StructLayout(LayoutKind.Sequential)] public struct RECT16 { public short L, T, R, B; }
  [StructLayout(LayoutKind.Sequential)] public struct CSBI { public COORD Size; public COORD Cursor; public short Attr; public RECT16 Win; public COORD Max; }
  [DllImport("kernel32.dll")] public static extern bool FreeConsole();
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool AttachConsole(uint pid);
  [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)] public static extern IntPtr CreateFile(string n, uint a, uint s, IntPtr sa, uint d, uint f, IntPtr t);
  [DllImport("kernel32.dll")] public static extern bool GetConsoleScreenBufferInfo(IntPtr h, out CSBI i);
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode)] public static extern bool ReadConsoleOutputCharacter(IntPtr h, StringBuilder b, uint n, COORD c, out uint r);
  [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
  [DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m);
  public static string Read(uint pid) {
    FreeConsole();
    if (!AttachConsole(pid)) return "AttachConsole failed: " + Marshal.GetLastWin32Error();
    IntPtr h = CreateFile("CONOUT$", 0xC0000000, 3, IntPtr.Zero, 3, 0, IntPtr.Zero);
    CSBI i; GetConsoleScreenBufferInfo(h, out i);
    var all = new StringBuilder();
    uint mode; GetConsoleMode(h, out mode);
    all.Append("(buffer " + i.Size.X + " columns; window " + (i.Win.R - i.Win.L + 1) + " x " + (i.Win.B - i.Win.T + 1) + "; cursor row " + i.Cursor.Y + "; output mode 0x" + mode.ToString("x") + ")\n");
    for (short y = 0; y <= i.Cursor.Y; y++) {
      var b = new StringBuilder(i.Size.X); uint r; var c = new COORD(); c.X = 0; c.Y = y;
      ReadConsoleOutputCharacter(h, b, (uint)i.Size.X, c, out r);
      string row = b.ToString(); if (row.Length > (int)r) row = row.Substring(0, (int)r);
      all.Append(y.ToString("D3") + "|" + row.TrimEnd() + "\n");
    }
    CloseHandle(h); FreeConsole();
    return all.ToString(); }
}
'@
$txt = [ConRead]::Read([uint32]$ConPid)
[IO.File]::WriteAllText($Out, $txt, (New-Object Text.UTF8Encoding $false))
