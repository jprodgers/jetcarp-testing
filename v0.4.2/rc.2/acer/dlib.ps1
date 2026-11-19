# Sitting A-4 (2.D) helpers: run the test build's jetcarp with its output in files, logging each command, its exit code,
# its time and its output to $OUTDIR\2.D-log.txt. Dot-source after nothing else (it loads env2.ps1).
. "$PSScriptRoot\env2.ps1"
$DLOG = "$OUTDIR\2.D-log.txt"
$DOUT = "$OUTDIR\2.D-out"
New-Item -ItemType Directory -Force $DOUT | Out-Null
function DLog([string]$text) { "$(Get-Date -Format 'HH:mm:ss.fff') $text" | Out-File -Encoding utf8 -Append $DLOG }
function JRun([string]$argText, [string]$tag) {
  $o = "$DOUT\$tag.txt"; $e = "$DOUT\$tag-err.txt"
  $sw = [Diagnostics.Stopwatch]::StartNew()
  $p = Start-Process $J -ArgumentList $argText -NoNewWindow -PassThru -RedirectStandardOutput $o -RedirectStandardError $e
  $null = $p.Handle; $p.WaitForExit(); $sw.Stop()
  $head = "[$tag] $argText -> exit $($p.ExitCode) in $([Math]::Round($sw.Elapsed.TotalSeconds, 2)) s"
  DLog $head
  $lines = @(Get-Content $o -ErrorAction SilentlyContinue) + @(Get-Content $e -ErrorAction SilentlyContinue)
  foreach ($l in $lines) { DLog "    $l" }
  $head; $lines
}
