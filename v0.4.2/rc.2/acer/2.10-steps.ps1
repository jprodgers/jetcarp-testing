# 2.10 (A10): packs with schema-2 runs, with no jobs seal (#35), the imported line (#37), an export that takes
# a running search (refused), and A10-pack.zip for the other machines. Outputs in 2.10-out\<n>.out/.err.
. "$PSScriptRoot\env2.ps1"
Set-Location $OUTDIR
$log = "$OUTDIR\2.10-log.txt"; "" | Out-File -Encoding utf8 $log
$n = 0
function L($m) { $line = "$(Get-Date -Format 'HH:mm:ss.fff') $m"; $line | Out-File -Encoding utf8 -Append $log; $line }
function JC([string]$argList, [int]$timeoutS = 1800) {
  $script:n++; $o = "$OUTDIR\2.10-out\$($script:n).out"; $e = "$OUTDIR\2.10-out\$($script:n).err"
  "$argList" | Out-File -Encoding utf8 "$OUTDIR\2.10-out\$($script:n).cmd"
  $t0 = Get-Date
  $p = Start-Process -FilePath $J -ArgumentList $argList -NoNewWindow -PassThru -RedirectStandardOutput $o -RedirectStandardError $e
  $h = $p.Handle; if (-not $p.WaitForExit($timeoutS * 1000)) { return [pscustomobject]@{ code = 'TIMEOUT'; secs = $timeoutS; out = ''; err = '' } }
  [pscustomobject]@{ code = $p.ExitCode; secs = ((Get-Date) - $t0).TotalSeconds; out = "$(Get-Content $o -Raw -ErrorAction SilentlyContinue)".Trim(); err = "$(Get-Content $e -Raw -ErrorAction SilentlyContinue)".Trim() }
}
function Show($label, $rv) { L ("{0} -> exit {1} in {2:n2} s" -f $label, $rv.code, $rv.secs); ((($rv.out + "`n" + $rv.err) -split "`r?`n") | Where-Object { $_ -notmatch '^\s*$' } | Select-Object -Last 16) | ForEach-Object { L "    $_" } }
function Rows([string]$f) { [math]::Max(0, (Get-Content $f -ErrorAction SilentlyContinue | Measure-Object -Line).Lines - 1) }
New-Item -ItemType Directory -Force "$OUTDIR\2.10-out" | Out-Null

# The plan's line for job 3's folder, then its uuid.
$st = JC "jobs status 3 --json"; $sj = $st.out | ConvertFrom-Json
$folder = $sj.folder; if (-not $folder) { $folder = $sj.progress.folder }
$uuid = if ($sj.spec.uuid) { $sj.spec.uuid } else { Split-Path $folder -Leaf }
L "jobs status 3 --json: .folder = '$($sj.folder)'; progress.folder = '$($sj.progress.folder)'; uuid $uuid"
L ("job 3: screened {0} + confirmed {1}" -f $sj.progress.screened, $sj.progress.confirmed)
L "job 3's search folder before the export: $((Get-ChildItem $folder -Recurse -File | ForEach-Object { "$($_.FullName.Substring($folder.Length + 1)) $($_.Length)" }) -join '; ')"
$null = JC "jobs runs 3 --limit 0 --format csv --out `"$OUTDIR\2.10-src-runs1.csv`""
$null = JC "jobs runs 3 --stage 2 --limit 0 --format csv --out `"$OUTDIR\2.10-src-runs2.csv`""
L "job 3 runs csv: stage 1 $(Rows "$OUTDIR\2.10-src-runs1.csv"), stage 2 $(Rows "$OUTDIR\2.10-src-runs2.csv")"

Show 'pack key --name "RC tester (Acer)"' (JC 'pack key --name "RC tester (Acer)"')
$ex = JC "pack export --to `"$OUTDIR\A10-pack`" --feed rc-acer --title `"rc.2 test, Acer`" --search $uuid --no-media"; Show "pack export --to A10-pack --feed rc-acer --title `"rc.2 test, Acer`" --search $uuid --no-media" $ex
L "pack: $((Get-ChildItem "$OUTDIR\A10-pack" -Recurse -File | Measure-Object Length -Sum).Sum) bytes in $((Get-ChildItem "$OUTDIR\A10-pack" -Recurse -File).Count) files"
L "job 3's search folder after the export: $((Get-ChildItem $folder -Recurse -File | ForEach-Object { "$($_.FullName.Substring($folder.Length + 1)) $($_.Length)" }) -join '; ')"
$ck = JC "pack check `"$OUTDIR\A10-pack`""; Show "pack check A10-pack" $ck; $ck.out + "`n" + $ck.err | Out-File -Encoding utf8 "$OUTDIR\2.10-check.txt"
New-Item -ItemType Directory -Force "$OUTDIR\import10" | Out-Null
$im = JC "pack import `"$OUTDIR\A10-pack`" --library `"$OUTDIR\import10\library.sqlite`""; Show "pack import A10-pack --library import10" $im; $im.out + "`n" + $im.err | Out-File -Encoding utf8 "$OUTDIR\2.10-import.txt"
$jl = JC "jobs list --library `"$OUTDIR\import10\library.sqlite`""; Show "jobs list --library import10" $jl
$jlj = (JC "jobs list --library `"$OUTDIR\import10\library.sqlite`" --json").out | ConvertFrom-Json
$arr = if ($jlj.jobs) { $jlj.jobs } else { $jlj }; $ijob = ($arr | Where-Object { $_.kind -eq 'explore' } | Select-Object -First 1).job
L "imported explore job: $ijob"
Show "jobs status $ijob --library import10" (JC "jobs status $ijob --library `"$OUTDIR\import10\library.sqlite`"")
Show "jobs runs --library import10 --measures sign_balance,sign_sorted --limit 5" (JC "jobs runs $ijob --library `"$OUTDIR\import10\library.sqlite`" --measures sign_balance,sign_sorted --limit 5")
$null = JC "jobs runs $ijob --library `"$OUTDIR\import10\library.sqlite`" --limit 0 --format csv --out `"$OUTDIR\2.10-imp-runs1.csv`""
$null = JC "jobs runs $ijob --library `"$OUTDIR\import10\library.sqlite`" --stage 2 --limit 0 --format csv --out `"$OUTDIR\2.10-imp-runs2.csv`""
L "imported runs csv: stage 1 $(Rows "$OUTDIR\2.10-imp-runs1.csv"), stage 2 $(Rows "$OUTDIR\2.10-imp-runs2.csv")"
$a1 = Import-Csv "$OUTDIR\2.10-src-runs1.csv" | ForEach-Object { "$($_.rule)|$($_.tiling)|$($_.rng)|$($_.origin)|$($_.fate)" } | Sort-Object
$b1 = Import-Csv "$OUTDIR\2.10-imp-runs1.csv" | ForEach-Object { "$($_.rule)|$($_.tiling)|$($_.rng)|$($_.origin)|$($_.fate)" } | Sort-Object
L "stage-1 rows identical (rule, tiling, rng, origin, fate) after sorting: $(-not (Compare-Object $a1 $b1 -SyncWindow 0 | Select-Object -First 1))"

# An export that takes a running search must be refused.
$rs = JC "search explore --families life_like --minutes 3 --detach --label running-export"; Show "search explore --families life_like --minutes 3 --detach --label running-export" $rs
$rj = if ("$($rs.out)`n$($rs.err)" -match 'job (\d+)') { $Matches[1] }
Start-Sleep 15
$rst = (JC "jobs status $rj --json").out | ConvertFrom-Json; L "job $rj status: $($rst.status); uuid $($rst.spec.uuid)"
$rx = JC "pack export --to `"$OUTDIR\A10-running`" --feed rc-acer-running --search $($rst.spec.uuid) --no-media"; Show "pack export (the running search $rj)" $rx
L "A10-running exists afterwards: $(Test-Path "$OUTDIR\A10-running")"
Show "jobs stop $rj" (JC "jobs stop $rj"); Show "jobs wait $rj --timeout 120" (JC "jobs wait $rj --timeout 120" 150)

# The zip for the other machines (tar.exe -a: forward slashes), unzipped again and checked.
Remove-Item "$OUTDIR\A10-pack.zip" -ErrorAction SilentlyContinue
Push-Location $OUTDIR; & tar.exe -a -c -f A10-pack.zip A10-pack; Pop-Location
L ("A10-pack.zip {0:n2} MB, sha256 {1}" -f ((Get-Item "$OUTDIR\A10-pack.zip").Length / 1MB), (Get-FileHash "$OUTDIR\A10-pack.zip").Hash.ToLower())
$un = "$OUTDIR\A10-unzip"; Remove-Item $un -Recurse -Force -ErrorAction SilentlyContinue; New-Item -ItemType Directory -Force $un | Out-Null
& tar.exe -x -f "$OUTDIR\A10-pack.zip" -C $un
Show "pack check (unzipped)" (JC "pack check `"$un\A10-pack`"")
L "done"
