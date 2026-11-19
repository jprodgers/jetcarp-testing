# rc.4 pre-check on the Acer, step 3: the branch's PowerShell installer (packaging\install.ps1).
# Its syntax with PowerShell's own parser, then installs and uninstalls into scratch folders from a local folder
# holding rc.3's release zip and SHA256SUMS (the source has @VERSION@ and @REPO@ placeholders, so -Version and
# -DownloadUrl are given). A: -NoModifyPath (no registry change). B: the default, which adds the folder to the user
# PATH and -Uninstall takes it off: the user PATH (raw, unexpanded, and its registry type) is saved first and compared
# after; if it differs, the saved value is put back and that is recorded. C: refusals.
# ASCII only. Output: 3-installer.txt beside this script, or the name given (-OutName 3-installer-117.txt).
# Since #117 (the recheck): each run also says whether a refusal printed one line (no "At ..."/CategoryInfo block),
# and whether it left a jetcarp-* folder in %TEMP%; C adds a refusal inside the download step (an empty folder).
param([string]$OutName = '3-installer.txt')
$ErrorActionPreference = 'Continue'
$UTF8 = New-Object Text.UTF8Encoding $false
$T2 = "$env:USERPROFILE\jetcarp-rc4pre"
$INS = "$env:USERPROFILE\jetcarp-rc-042c\src\packaging\install.ps1"
$DL = "$env:USERPROFILE\jetcarp-rc-042c"          # holds jetcarp-0.4.2-rc.3-x86_64-pc-windows-msvc.zip and SHA256SUMS
$OUTF = Join-Path $PSScriptRoot $OutName
[IO.File]::WriteAllText($OUTF, '', $UTF8)
function W([string]$s) { $s = $s.Replace($env:USERPROFILE, '~'); [IO.File]::AppendAllText($OUTF, "$s`r`n", $UTF8); $s }
function RawPath { $k = Get-Item 'HKCU:\Environment'; [pscustomobject]@{ value = [string]$k.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames); kind = [string]$k.GetValueKind('Path') } }
function TempDirs { @(Get-ChildItem -Directory -Force $env:TEMP -Filter 'jetcarp-*' -ErrorAction SilentlyContinue | ForEach-Object Name) }
function RunIns([string]$label, [string[]]$insArgs) {
  W "`r`n#### $label"
  W ("$ powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1 " + ($insArgs -join ' '))
  $o = "$T2\logs\ins-out.txt"; $e = "$T2\logs\ins-err.txt"
  $tmp0 = TempDirs
  $p = Start-Process powershell -ArgumentList (@('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$INS`"") + $insArgs) -RedirectStandardOutput $o -RedirectStandardError $e -NoNewWindow -PassThru
  $null = $p.Handle; [void]$p.WaitForExit(300000)
  $txt = ((Get-Content $o -Raw) + (Get-Content $e -Raw)).TrimEnd()
  W $txt
  W "exit $($p.ExitCode)"
  $newTmp = @(TempDirs | Where-Object { $tmp0 -notcontains $_ })
  $block = ($txt -match '(?m)^At .*install\.ps1') -or ($txt -match 'CategoryInfo')
  $nlines = @($txt -split "`r?`n" | Where-Object { $_.Trim() }).Count
  if ($p.ExitCode -ne 0) { W "(refusal: $nlines non-empty line(s); PowerShell error block: $block)" }
  W "(new jetcarp-* folders in %TEMP%: $(if ($newTmp.Count) { $newTmp -join ', ' } else { 'none' }))"
}

W "#### 3. The PowerShell installer, $((git -C "$env:USERPROFILE\jetcarp-rc-042c\src" log --oneline -1)), $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
W "sha256 of install.ps1: $((Get-FileHash $INS -Algorithm SHA256).Hash.ToLower())"
$errs = $null; $toks = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($INS, [ref]$toks, [ref]$errs)
W "Parser::ParseFile errors: $(@($errs).Count)"
foreach ($x in @($errs)) { W "  line $($x.Extent.StartLineNumber): $($x.Message)" }
W "(PowerShell $($PSVersionTable.PSVersion))"

$before = RawPath
W "user PATH before: type $($before.kind), $($before.value.Length) characters, $(@($before.value -split ';').Count) entries; has %PNPM_HOME%: $($before.value -like '*%PNPM_HOME%*')"

# A: no PATH change
RunIns 'A: install with -NoModifyPath' @('-Version', '0.4.2-rc.3', '-DownloadUrl', "`"$DL`"", '-InstallDir', "`"$T2\inst-a\jetcarp`"", '-NoModifyPath')
W "inst-a: $((Get-ChildItem "$T2\inst-a\jetcarp" -Force -ErrorAction SilentlyContinue | ForEach-Object Name) -join ', ')"
W "marker: $((Get-Content "$T2\inst-a\jetcarp\.jetcarp-installer" -ErrorAction SilentlyContinue) -join ' | ')"
W "jetcarp --version from it: $(& "$T2\inst-a\jetcarp\jetcarp.exe" --version)"
$mid = RawPath; W "user PATH unchanged by A: $($mid.value -ceq $before.value -and $mid.kind -eq $before.kind)"
RunIns 'A: -Uninstall' @('-Version', '0.4.2-rc.3', '-InstallDir', "`"$T2\inst-a\jetcarp`"", '-Uninstall')
W "inst-a left: $(if (Test-Path "$T2\inst-a") { (Get-ChildItem -Force "$T2\inst-a" | ForEach-Object Name) -join ', ' } else { '(gone, with its parent)' })"

# B: the default, with the user PATH
RunIns 'B: install, adding to the user PATH' @('-Version', '0.4.2-rc.3', '-DownloadUrl', "`"$DL`"", '-InstallDir', "`"$T2\inst-b\jetcarp`"")
$after = RawPath
$added = $after.value.Substring([math]::Min($before.value.Length, $after.value.Length))
W "user PATH after install: type $($after.kind), $(@($after.value -split ';').Count) entries; still has %PNPM_HOME% unexpanded: $($after.value -like '*%PNPM_HOME%*'); starts with the old value: $($after.value.StartsWith($before.value.TrimEnd(';')))"
W "  what was added at the end: '$added'"
RunIns 'B: the same install again (an update in place)' @('-Version', '0.4.2-rc.3', '-DownloadUrl', "`"$DL`"", '-InstallDir', "`"$T2\inst-b\jetcarp`"")
$again = RawPath; W "user PATH after the second install: entries $(@($again.value -split ';').Count) (no duplicate: $(@($again.value -split ';' | Where-Object { $_ -like '*inst-b*' }).Count -eq 1))"
RunIns 'B: -Uninstall' @('-Version', '0.4.2-rc.3', '-InstallDir', "`"$T2\inst-b\jetcarp`"", '-Uninstall')
$end = RawPath
$same = ($end.value -ceq $before.value) -and ($end.kind -eq $before.kind)
W "user PATH after -Uninstall: type $($end.kind); identical to before (value and type): $same"
if (-not $same) {
  W "  differs: before $($before.value.Length) characters ($($before.kind)), after $($end.value.Length) ($($end.kind))"
  $bset = @($before.value -split ';'); $eset = @($end.value -split ';')
  W "  entries only before: $((Compare-Object $bset $eset | Where-Object SideIndicator -eq '<=' | ForEach-Object { "'$($_.InputObject)'" }) -join ', ')"
  W "  entries only after: $((Compare-Object $bset $eset | Where-Object SideIndicator -eq '=>' | ForEach-Object { "'$($_.InputObject)'" }) -join ', ')"
  Set-ItemProperty -Path 'HKCU:\Environment' -Name 'Path' -Value $before.value -Type ExpandString
  $fixed = RawPath; W "  put the saved value back: identical now: $(($fixed.value -ceq $before.value) -and ($fixed.kind -eq $before.kind))"
}
W "inst-b left: $(if (Test-Path "$T2\inst-b") { (Get-ChildItem -Force "$T2\inst-b" | ForEach-Object Name) -join ', ' } else { '(gone, with its parent)' })"

# C: refusals
New-Item -ItemType Directory -Force "$T2\not-mine" | Out-Null; Set-Content "$T2\not-mine\keep.txt" 'not the installer''s'
RunIns 'C: install into a folder the installer did not make (non-empty)' @('-Version', '0.4.2-rc.3', '-DownloadUrl', "`"$DL`"", '-InstallDir', "`"$T2\not-mine`"", '-NoModifyPath')
W "not-mine afterwards: $((Get-ChildItem -Force "$T2\not-mine" | ForEach-Object Name) -join ', ')"
RunIns 'C: -Uninstall where nothing was installed' @('-Version', '0.4.2-rc.3', '-InstallDir', "`"$T2\nothing-here`"", '-Uninstall')
RunIns 'C: a version that is not one' @('-Version', 'banana', '-DownloadUrl', "`"$DL`"", '-InstallDir', "`"$T2\inst-c`"", '-NoModifyPath')
RunIns 'C: a version with no files in the download folder' @('-Version', '0.4.2-rc.4', '-DownloadUrl', "`"$DL`"", '-InstallDir', "`"$T2\inst-c`"", '-NoModifyPath')
New-Item -ItemType Directory -Force "$T2\empty-dl" | Out-Null
RunIns 'C: -DownloadUrl an empty folder (a refusal inside the download step)' @('-Version', '0.4.2-rc.3', '-DownloadUrl', "`"$T2\empty-dl`"", '-InstallDir', "`"$T2\inst-c`"", '-NoModifyPath')
$sumsOnly = "$T2\sums-only"; New-Item -ItemType Directory -Force $sumsOnly | Out-Null; Copy-Item "$DL\SHA256SUMS" $sumsOnly -Force
RunIns 'C: -DownloadUrl a folder with SHA256SUMS but no zip (refused after the first download)' @('-Version', '0.4.2-rc.3', '-DownloadUrl', "`"$sumsOnly`"", '-InstallDir', "`"$T2\inst-c`"", '-NoModifyPath')
W "inst-c made by the refusals: $(Test-Path "$T2\inst-c")"
W "jetcarp-* folders in %TEMP% now: $(@(TempDirs).Count) ($((TempDirs) -join ', '))"
W "logs folder intact after C: $(Test-Path "$T2\logs\pre.log")"
W "#### end $(Get-Date -Format 'HH:mm:ss')"
