# Log JETCARP's app process (jetcarpw.exe started from the test bin) every 5 s: pid, working set, CPU, windows.
# Stops when the file appmon.stop appears in the output folder, or after 4 hours.
. "$PSScriptRoot\env2.ps1"
$log = "$OUTDIR\app-mon.txt"
$end = (Get-Date).AddHours(4); $prev = @{}
while ((Get-Date) -lt $end -and -not (Test-Path "$OUTDIR\appmon.stop")) {
  # The app is the jetcarp.exe that jetcarpw.exe starts with no arguments (jobs and the host have arguments).
  $ids = Get-CimInstance Win32_Process -Filter "Name='jetcarp.exe'" | Where-Object { $_.ExecutablePath -like "$T\bin\*" -and $_.CommandLine -match 'jetcarp\.exe"?\s*$' } | ForEach-Object ProcessId
  $ps = foreach ($i in $ids) { Get-Process -Id $i -ErrorAction SilentlyContinue }
  if (-not $ps) { "$(Get-Date -Format 'HH:mm:ss') no app process" | Out-File -Encoding utf8 -Append $log }
  foreach ($p in $ps) {
    $cpu = $p.TotalProcessorTime.TotalSeconds; $d = if ($prev.ContainsKey($p.Id)) { ($cpu - $prev[$p.Id]) / 5 } else { 0 }; $prev[$p.Id] = $cpu
    "{0} pid {1} ws {2:n0} MB private {3:n0} MB cpu {4:n2} cores threads {5} title '{6}'" -f (Get-Date -Format 'HH:mm:ss'), $p.Id, ($p.WorkingSet64 / 1MB), ($p.PrivateMemorySize64 / 1MB), $d, $p.Threads.Count, $p.MainWindowTitle | Out-File -Encoding utf8 -Append $log
  }
  Start-Sleep 5
}
