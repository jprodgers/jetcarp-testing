# rc.5 wave on the Acer, A-7 (Part 3 in a new Windows account, Jimmie hands-on): from Jimmie's own account, write
# down every jetcarp process in any session (pid, name, session, start time when readable) whenever the set changes,
# and each save of the notes file in C:\Users\Public. Writes a7-procs.txt beside this script. ASCII only.
#   powershell -NoProfile -ExecutionPolicy Bypass -File a7_watch.ps1 [-Hours 4]
param([double]$Hours = 4)
$UTF8 = New-Object Text.UTF8Encoding $false
$OUTF = Join-Path $PSScriptRoot 'a7-procs.txt'
$NOTES = 'C:\Users\Public\jetcarp-a7-notes.txt'
function L([string]$s) { [IO.File]::AppendAllText($OUTF, "$(Get-Date -Format 'HH:mm:ss') $s`r`n", $UTF8) }
L "=== watching jetcarp processes in every session; my session is $((Get-Process -Id $PID).SessionId)"
$last = ''; $lastNotes = $null; $end = (Get-Date).AddHours($Hours)
while ((Get-Date) -lt $end) {
  $now = @(Get-Process -Name 'jetcarp*' -ErrorAction SilentlyContinue | Sort-Object Id | ForEach-Object {
    $st = try { $_.StartTime.ToString('HH:mm:ss') } catch { '?' }
    "$($_.Id) $($_.ProcessName) s$($_.SessionId) from $st" }) -join ' | '
  if ($now -ne $last) { L "jetcarp processes: [$now]"; $last = $now }
  $n = Get-Item $NOTES -ErrorAction SilentlyContinue
  if ($n -and $n.LastWriteTime -ne $lastNotes) { L "notes file saved ($($n.Length) bytes, $($n.LastWriteTime.ToString('HH:mm:ss')))"; $lastNotes = $n.LastWriteTime }
  Start-Sleep -Seconds 10
}
L "=== done"
