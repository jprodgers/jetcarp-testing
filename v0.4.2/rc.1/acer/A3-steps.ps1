# A3: CPU-only JACA explore; stop after ~5 min from another process, time jobs wait, resume, status.
. "$PSScriptRoot\env.ps1"
Remove-Item Env:JETCARP_GPU, Env:WGPU_BACKEND -ErrorAction SilentlyContinue
$log = "$T\A3-log.txt"
function L($s) { $line = "$(Get-Date -Format 'HH:mm:ss.fff') $s"; $line | Out-File -Encoding utf8 -Append $log; $line }
function Native($argList) {
  # Run jetcarp with arguments, capturing stdout+stderr and the exit code.
  $psi = New-Object Diagnostics.ProcessStartInfo $J, $argList
  $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true; $psi.UseShellExecute = $false
  $p = [Diagnostics.Process]::Start($psi); $o = $p.StandardOutput.ReadToEndAsync(); $e = $p.StandardError.ReadToEnd(); $p.WaitForExit()
  [pscustomobject]@{ code = $p.ExitCode; out = ($o.Result + $e).Trim() }
}
"" | Out-File -Encoding utf8 $log
L "start: search explore --cpu --families jaca --minutes 10 --label cpu-jaca"
$ex = Start-Process cmd -ArgumentList "/c `"`"$J`" search explore --cpu --families jaca --minutes 10 --label cpu-jaca > `"$T\A3-explore.txt`" 2>&1`"" -NoNewWindow -PassThru
Start-Sleep -Seconds 300
L "explore still running: $(-not $ex.HasExited)"
$t0 = Get-Date
$s = Native "jobs stop 2"; L "jobs stop 2 -> exit $($s.code): $($s.out)"
$w = Native "jobs wait 2 --timeout 60"; $dt = ((Get-Date) - $t0).TotalSeconds
L ("jobs wait 2 --timeout 60 -> exit {0} after {1:n2} s from the stop: {2}" -f $w.code, $dt, $w.out)
L "explore process had exited when wait returned: $($ex.HasExited)"
# The plan's resume, straight after wait returns (#16 may refuse it on rc.1).
$watch = Start-Job -ScriptBlock { param($id, $t0) $p = Get-Process -Id $id -ErrorAction SilentlyContinue; if ($p) { $p.WaitForExit() }; ((Get-Date) - $t0).TotalSeconds } -ArgumentList $ex.Id, $t0
$r = Native "jobs resume 2 --minutes 4"
L "jobs resume 2 --minutes 4 -> exit $($r.code)"
$ex.WaitForExit(); L ("first explore process: exit code {0}; it had exited {1:n2} s after the stop" -f $ex.ExitCode, (Receive-Job $watch -Wait))
$r.out | Out-File -Encoding utf8 "$T\A3-resume.txt"
if ($r.code -ne 0 -and $r.out -match 'already') {
  L "refused (#16); waiting 10 s and resuming again"; Start-Sleep 10
  $r = Native "jobs resume 2 --minutes 4"; L "second resume -> exit $($r.code)"; $r.out | Out-File -Encoding utf8 -Append "$T\A3-resume.txt"
}
$st = Native "jobs status 2"; $st.out | Out-File -Encoding utf8 "$T\A3-status.txt"; L "jobs status 2 -> exit $($st.code)"
L "done"
