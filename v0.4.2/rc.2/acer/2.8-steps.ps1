# 2.8 (A8): rules, names and progress. Every call's stdout and stderr go to 2.8-out\<n>.out/.err.
. "$PSScriptRoot\env2.ps1"
Set-Location $OUTDIR
$log = "$OUTDIR\2.8-log.txt"; "" | Out-File -Encoding utf8 $log
$n = 0
function L($m) { $line = "$(Get-Date -Format 'HH:mm:ss.fff') $m"; $line | Out-File -Encoding utf8 -Append $log; $line }
function JC([string]$argList) {
  $script:n++; $o = "$OUTDIR\2.8-out\$($script:n).out"; $e = "$OUTDIR\2.8-out\$($script:n).err"
  "$argList" | Out-File -Encoding utf8 "$OUTDIR\2.8-out\$($script:n).cmd"
  $t0 = Get-Date
  $p = Start-Process -FilePath $J -ArgumentList $argList -NoNewWindow -PassThru -RedirectStandardOutput $o -RedirectStandardError $e
  $h = $p.Handle; $p.WaitForExit()
  [pscustomobject]@{ code = $p.ExitCode; secs = ((Get-Date) - $t0).TotalSeconds; out = "$(Get-Content $o -Raw -ErrorAction SilentlyContinue)".Trim(); err = "$(Get-Content $e -Raw -ErrorAction SilentlyContinue)".Trim() }
}
function Show($label, $rv) { L ("{0} -> exit {1} in {2:n2} s" -f $label, $rv.code, $rv.secs); ((($rv.out + "`n" + $rv.err) -split "`r?`n") | Where-Object { $_ -notmatch '^\s*$' } | Select-Object -Last 14) | ForEach-Object { L "    $_" } }
New-Item -ItemType Directory -Force "$OUTDIR\2.8-out" | Out-Null

Show 'search try --tiling square --rule "B47/S13568V/4"' (JC 'search try --tiling square --rule "B47/S13568V/4"')
Show 'search try --tiling square --rule "B3/S23V/C4"' (JC 'search try --tiling square --rule "B3/S23V/C4"')
Show 'search try --tiling square --rule "B4v7/S2"' (JC 'search try --tiling square --rule "B4v7/S2"')
# The two V rules again, saved, to read the neighbourhood from the scene.
Show 'try B47/S13568V/4 --json --save' (JC "search try --tiling square --rule `"B47/S13568V/4`" --json --save `"$OUTDIR\2.8-B47_S13568V_4.json`"")
Show 'try B3/S23V/C4 --json --save' (JC "search try --tiling square --rule `"B3/S23V/C4`" --json --save `"$OUTDIR\2.8-B3_S23V_C4.json`"")
foreach ($f in '2.8-B47_S13568V_4.json', '2.8-B3_S23V_C4.json') { if (Test-Path "$OUTDIR\$f") { try { $sc = Get-Content "$OUTDIR\$f" -Raw | ConvertFrom-Json; L "  $f cas: $(($sc.cas | ConvertTo-Json -Compress -Depth 3))" } catch { L "  $f unreadable: $_" } } }
Set-Content "$OUTDIR\2.8-rules.txt" "B3/S23`nB36/S23`nB4x/S2`nB2/S"
Show 'search hunt --rules "" --rules-file 2.8-rules.txt --soups 20' (JC "search hunt --rules `"`" --rules-file `"$OUTDIR\2.8-rules.txt`" --soups 20")
$rv = JC "search hunt --rules B3/S23,B36/S23,B2/S34 --tilings square,hex --soups 30 --label groups"; Show "search hunt --rules B3/S23,B36/S23,B2/S34 --tilings square,hex --soups 30 --label groups" $rv
L ("groups progress lines: " + ((($rv.err -split "[\r\n]+") | Where-Object { $_ -match 'groups' } | Select-Object -Last 2) -join ' || '))
Show "jobs list" (JC "jobs list")
L "done"
