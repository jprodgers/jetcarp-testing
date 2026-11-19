# rc.5 wave on the Acer, R5 #127's last part: output sent to a file is unchanged, with no escape code in it.
# A fresh folder (~\jetcarp-rc5\n127-file): pack import of the starter pack, then a quarter-minute explore, each sent
# to a file by cmd's redirection (stdout and stderr), and the explore once more by Start-Process's (stdout and
# stderr in two files; PowerShell 5.1's *> would rewrite the bytes as UTF-16). Each file's
# bytes are counted: ESC (0x1B), a carriage return not followed by a line feed, and the ellipsis a narrow line ends in.
# ASCII only. Output: 127-file.txt beside this script (the home folder written as ~).
$ErrorActionPreference = 'Continue'
$UTF8 = New-Object Text.UTF8Encoding $false
$HERE = $PSScriptRoot
$F = "$env:USERPROFILE\jetcarp-rc5\n127-file"
if (Test-Path $F) { Remove-Item -Recurse -Force $F }
New-Item -ItemType Directory -Force $F | Out-Null
$JX = "$env:USERPROFILE\jetcarp-rc-042c\bin\jetcarp.exe"
$OUTF = Join-Path $HERE '127-file.txt'
$env:JETCARP_CONFIG_DIR = "$F\config"; $env:JETCARP_DATA_DIR = "$F\data"; $env:JETCARP_OUT = "$F\out"
$env:JETCARP_LIBRARY = "$F\library"; $env:JETCARP_RUNTIME_DIR = "$F\run"
Remove-Item Env:JETCARP_GPU, Env:COLUMNS -ErrorAction SilentlyContinue
Set-Location "$env:USERPROFILE\jetcarp-rc-042c\bin"
[IO.File]::WriteAllText($OUTF, "#### R5 #127: output sent to a file, rc.5 ($(& $JX --version)), $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n", $UTF8)
function Count([string]$label, [string]$file) {
  $b = [IO.File]::ReadAllBytes($file)
  $esc = 0; $cr = 0; $lines = 0
  for ($k = 0; $k -lt $b.Length; $k++) {
    if ($b[$k] -eq 0x1B) { $esc++ }
    if ($b[$k] -eq 0x0D -and ($k + 1 -ge $b.Length -or $b[$k + 1] -ne 0x0A)) { $cr++ }
    if ($b[$k] -eq 0x0A) { $lines++ }
  }
  $txt = [Text.Encoding]::UTF8.GetString($b)
  $ell = ([regex]::Matches($txt, [string][char]0x2026)).Count
  $prog = @($txt -split "`r?`n" | Where-Object { $_ -match '^explore \d+: ' }).Count
  [IO.File]::AppendAllText($OUTF, "### $label`r`n$($b.Length) bytes, $lines lines; ESC bytes: $esc; carriage returns without a line feed: $cr; ellipses: $ell; progress lines (explore N: ...): $prog`r`n", $UTF8)
  [IO.File]::AppendAllText($OUTF, (($txt.Replace($env:USERPROFILE, '~') -split "`r?`n" | ForEach-Object { "  |$_" }) -join "`r`n") + "`r`n", $UTF8)
}
cmd /c "`"$JX`" pack import packs\jetcarp-starter > `"$F\import-cmd.txt`" 2>&1"
Count 'cmd: jetcarp pack import packs\jetcarp-starter > file 2>&1' "$F\import-cmd.txt"
cmd /c "`"$JX`" search explore --minutes 0.25 > `"$F\explore-cmd.txt`" 2>&1"
Count 'cmd: jetcarp search explore --minutes 0.25 > file 2>&1' "$F\explore-cmd.txt"
Start-Process $JX -ArgumentList 'search explore --minutes 0.25' -RedirectStandardOutput "$F\explore-sp-out.txt" -RedirectStandardError "$F\explore-sp-err.txt" -NoNewWindow -Wait
Count 'PowerShell: Start-Process jetcarp search explore --minutes 0.25, stdout to a file' "$F\explore-sp-out.txt"
Count 'PowerShell: the same, stderr to a file' "$F\explore-sp-err.txt"
"t127_file done"
