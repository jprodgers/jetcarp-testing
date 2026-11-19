# A2: GPU-screened explore runs replay the same on the CPU.
# For each run in A2-jaca.json and A2-life.json (jobs runs ... --measures all --format json): save its
# scene, run it on the CPU for the run's gens, and compare measures.density with the replay's
# population (sum of fields[].population) / cells, to 6 decimals. Then five of the scenes on the
# CPU and on the GPU world path: the hashes must agree.
# Usage: .\A2-check.ps1 -J <jetcarp.exe> [-Job 1]
param([string]$J, [int]$Job = 1)
New-Item -ItemType Directory -Force A2 | Out-Null
$runs = foreach ($f in "A2-jaca.json", "A2-life.json") { (Get-Content $f -Raw | ConvertFrom-Json).runs }
$res = foreach ($r in $runs) {
  $scene = "A2\$($r.id).json"
  & $J jobs scene $Job $r.id --save $scene | Out-Null
  $x = & $J run $scene --gens $r.gens --json --cpu | Out-String | ConvertFrom-Json
  $pop = ($x.fields | Measure-Object population -Sum).Sum
  $replay = $pop / $x.cells
  $stored = [double]$r.measures.density
  [pscustomobject]@{ run = $r.id; family = $r.family; rule = $r.rule; gens = $r.gens; cells = $r.cells;
    replay_cells = $x.cells; population = $pop; stored = [math]::Round($stored, 6); replay = [math]::Round($replay, 6);
    diff = [math]::Abs($stored - $replay); ok = ([math]::Abs($stored - $replay) -le 5e-7);
    cells_same = ($r.cells -eq $x.cells);
    backend = $x.backend }
}
$res | Export-Csv -NoTypeInformation A2-replays.csv
$bad = @($res | Where-Object { -not $_.ok })
"$($res.Count) runs: $($res.Count - $bad.Count) match to 6 decimals"
$bad | ForEach-Object { "MISMATCH run $($_.run) ($($_.family) $($_.rule)): stored $($_.stored), replay $($_.replay) ($($_.population) / $($_.replay_cells))" }

# Five scenes (three JACA, two Life-like): CPU against GPU hashes, and what the default picks.
$five = @($res | Where-Object family -eq jaca | Select-Object -First 3) + @($res | Where-Object family -eq life_like | Select-Object -First 2)
$hashes = foreach ($r in $five) {
  $scene = "A2\$($r.run).json"
  $c = & $J run $scene --gens $r.gens --json --cpu | Out-String | ConvertFrom-Json
  $g = & $J run $scene --gens $r.gens --json --gpu | Out-String | ConvertFrom-Json
  $d = & $J run $scene --gens $r.gens --json | Out-String | ConvertFrom-Json
  [pscustomobject]@{ run = $r.run; family = $r.family; gens = $r.gens; cells = $r.cells; cpu = $c.hash; gpu = $g.hash;
    default = $d.hash; same = ($c.hash -eq $g.hash -and $c.hash -eq $d.hash); gpu_backend = $g.backend; default_backend = $d.backend }
}
$hashes | Export-Csv -NoTypeInformation A2-hashes.csv
$hashes | Format-Table run, family, gens, cells, cpu, gpu, default, same -AutoSize | Out-String -Width 200
$hashes | ForEach-Object { "run $($_.run): --gpu -> $($_.gpu_backend); no flag -> $($_.default_backend)" }
