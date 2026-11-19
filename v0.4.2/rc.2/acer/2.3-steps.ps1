# 2.3 (A3): CPU-only JACA explore; stop after ~5 min from another process, time jobs wait, resume at once
# (#16: it must be accepted straight away), then status. rc.1's A3-steps.ps1 with rc.2 file names.
. "$PSScriptRoot\env2.ps1"
$log = "$OUTDIR\2.3-log.txt"
function Lg($m) { $line = "$(Get-Date -Format 'HH:mm:ss.fff') $m"; $line | Out-File -Encoding utf8 -Append $log; $line }
function Native($argList) {
  # Run jetcarp with arguments, capturing stdout+stderr and the exit code (not for detached commands).
  $psi = New-Object Diagnostics.ProcessStartInfo $J, $argList
  $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true; $psi.UseShellExecute = $false
  $pr = [Diagnostics.Process]::Start($psi); $o = $pr.StandardOutput.ReadToEndAsync(); $e = $pr.StandardError.ReadToEnd(); $pr.WaitForExit()
  [pscustomobject]@{ code = $pr.ExitCode; out = ($o.Result + $e).Trim() }
}
"" | Out-File -Encoding utf8 $log
Lg "start: search explore --cpu --families jaca --minutes 10 --label cpu-jaca"
$ex = Start-Process -FilePath $J -ArgumentList "search explore --cpu --families jaca --minutes 10 --label cpu-jaca" -NoNewWindow -PassThru -RedirectStandardOutput "$OUTDIR\2.3-explore.out" -RedirectStandardError "$OUTDIR\2.3-explore.err"
$null = $ex.Handle
Start-Sleep -Seconds 300
Lg "explore still running: $(-not $ex.HasExited)"
$t0 = Get-Date
$stp = Native "jobs stop 2"; Lg "jobs stop 2 -> exit $($stp.code): $($stp.out)"
$wt = Native "jobs wait 2 --timeout 60"; $dt = ((Get-Date) - $t0).TotalSeconds
Lg ("jobs wait 2 --timeout 60 -> exit {0} after {1:n2} s from the stop: {2}" -f $wt.code, $dt, $wt.out)
Lg "explore process had exited when wait returned: $($ex.HasExited)"
$rs = Native "jobs resume 2 --minutes 4"
Lg "jobs resume 2 --minutes 4 -> exit $($rs.code)"
$rs.out | Out-File -Encoding utf8 "$OUTDIR\2.3-resume.txt"
$ex.WaitForExit(); Lg "first explore process: exit code $($ex.ExitCode)"
if ($rs.code -ne 0 -and $rs.out -match 'already') {
  Lg "refused (#16 not fixed?); waiting 10 s and resuming again"; Start-Sleep 10
  $rs = Native "jobs resume 2 --minutes 4"; Lg "second resume -> exit $($rs.code)"; $rs.out | Out-File -Encoding utf8 -Append "$OUTDIR\2.3-resume.txt"
}
$st = Native "jobs status 2"; $st.out | Out-File -Encoding utf8 "$OUTDIR\2.3-status.txt"; Lg "jobs status 2 -> exit $($st.code)"
$sj = Native "jobs status 2 --json"; $sj.out | Out-File -Encoding utf8 "$OUTDIR\2.3-status.json"
Lg "done"
