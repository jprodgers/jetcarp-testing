# 2.2 (A2): GPU-screened explore runs replay the same on the CPU (rc.1's A2-check.ps1, rc.2 file names).
# For 20 JACA and 10 Life-like runs of job 1 (jobs runs ... --measures all --format json): save each scene,
# run it on the CPU for the run's gens, and compare measures.density with the replay's population
# (sum of fields[].population) / cells, to 6 decimals. Then five of the scenes on the CPU, on the GPU
# world path and with no flag: the hashes must agree.
. "$PSScriptRoot\env2.ps1"
$Job = 1
Set-Location $OUTDIR
New-Item -ItemType Directory -Force "$OUTDIR\2.2" | Out-Null
& $J jobs runs $Job --family jaca --limit 20 --measures all --format json > "$OUTDIR\2.2-jaca.json"
& $J jobs runs $Job --family life_like --limit 10 --measures all --format json > "$OUTDIR\2.2-life.json"
$runs = foreach ($f in "2.2-jaca.json", "2.2-life.json") { (Get-Content "$OUTDIR\$f" -Raw | ConvertFrom-Json).runs }
$rows = foreach ($run in $runs) {
  $scene = "$OUTDIR\2.2\$($run.id).json"
  & $J jobs scene $Job $run.id --save $scene | Out-Null
  $x = & $J run $scene --gens $run.gens --json --cpu | Out-String | ConvertFrom-Json
  $pop = ($x.fields | Measure-Object population -Sum).Sum
  $replay = $pop / $x.cells
  $stored = [double]$run.measures.density
  [pscustomobject]@{ run = $run.id; family = $run.family; rule = $run.rule; gens = $run.gens; cells = $run.cells;
    replay_cells = $x.cells; population = $pop; stored = [math]::Round($stored, 6); replay = [math]::Round($replay, 6);
    diff = [math]::Abs($stored - $replay); ok = ([math]::Abs($stored - $replay) -le 5e-7);
    cells_same = ($run.cells -eq $x.cells); backend = $x.backend }
}
$rows | Export-Csv -NoTypeInformation "$OUTDIR\2.2-replays.csv"
$bad = @($rows | Where-Object { -not $_.ok })
"$(@($rows).Count) runs: $(@($rows).Count - $bad.Count) match to 6 decimals"
$bad | ForEach-Object { "MISMATCH run $($_.run) ($($_.family) $($_.rule)): stored $($_.stored), replay $($_.replay) ($($_.population) / $($_.replay_cells))" }
"runs whose cells differ from the replay's: $(@($rows | Where-Object { -not $_.cells_same }).Count)"

# Five scenes (three JACA, two Life-like): CPU against GPU hashes, and what the default picks.
$five = @($rows | Where-Object family -eq jaca | Select-Object -First 3) + @($rows | Where-Object family -eq life_like | Select-Object -First 2)
$hashes = foreach ($row in $five) {
  $scene = "$OUTDIR\2.2\$($row.run).json"
  $c = & $J run $scene --gens $row.gens --json --cpu | Out-String | ConvertFrom-Json
  $g = & $J run $scene --gens $row.gens --json --gpu | Out-String | ConvertFrom-Json
  $d = & $J run $scene --gens $row.gens --json | Out-String | ConvertFrom-Json
  [pscustomobject]@{ run = $row.run; family = $row.family; gens = $row.gens; cells = $row.cells; cpu = $c.hash; gpu = $g.hash;
    default = $d.hash; same = ($c.hash -eq $g.hash -and $c.hash -eq $d.hash); gpu_backend = $g.backend; default_backend = $d.backend }
}
$hashes | Export-Csv -NoTypeInformation "$OUTDIR\2.2-hashes.csv"
$hashes | Format-Table run, family, gens, cells, cpu, gpu, default, same -AutoSize | Out-String -Width 200
$hashes | ForEach-Object { "run $($_.run): --gpu -> $($_.gpu_backend); no flag -> $($_.default_backend)" }
