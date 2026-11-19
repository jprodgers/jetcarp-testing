# rc.4 wave on the Acer, R4 #117 (the Windows installer's refusals are one line) with the released installer,
# jetcarp-installer.ps1 from the v0.4.2-rc.4 release (checked against SHA256SUMS). The pre-check's t3_installer.ps1,
# cut to what R4 asks: install into a folder it didn't make, and -Uninstall where nothing is installed (each: one
# line, exit 1, no PowerShell error block, no jetcarp-* folder left in %TEMP%), plus the two refusals inside the
# download step. Also one install with -NoModifyPath and its -Uninstall (no registry change), for the wording #103
# asks about (the plan does #103 itself from A-7's account). -DownloadUrl is the folder holding rc.4's zip and
# SHA256SUMS as downloaded from the release, so the installer's own default version (0.4.2-rc.4) is used.
# ASCII only. Output: 117-installer.txt beside this script.
$ErrorActionPreference = 'Continue'
$UTF8 = New-Object Text.UTF8Encoding $false
$T4 = "$env:USERPROFILE\jetcarp-rc4"
$DL = "$env:USERPROFILE\jetcarp-rc-042c\rc4-dl"
$INS = "$DL\jetcarp-installer.ps1"
$IW = "$T4\inst"
$OUTF = Join-Path $PSScriptRoot '117-installer.txt'
New-Item -ItemType Directory -Force "$T4\logs", $IW | Out-Null
[IO.File]::WriteAllText($OUTF, '', $UTF8)
function W([string]$s) { $s = $s.Replace($env:USERPROFILE, '~'); [IO.File]::AppendAllText($OUTF, "$s`r`n", $UTF8); $s }
function RawPath { $k = Get-Item 'HKCU:\Environment'; [pscustomobject]@{ value = [string]$k.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames); kind = [string]$k.GetValueKind('Path') } }
function TempDirs { @(Get-ChildItem -Directory -Force $env:TEMP -Filter 'jetcarp-*' -ErrorAction SilentlyContinue | ForEach-Object Name) }
$script:N = 0
function RunIns([string]$label, [string[]]$insArgs) {
  $script:N++
  W "`r`n#### $label"
  W ("$ powershell -NoProfile -ExecutionPolicy Bypass -File jetcarp-installer.ps1 " + ($insArgs -join ' '))
  $o = "$T4\logs\ins-$($script:N)-out.txt"; $e = "$T4\logs\ins-$($script:N)-err.txt"
  $tmp0 = TempDirs
  $p = Start-Process powershell -ArgumentList (@('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$INS`"") + $insArgs) -RedirectStandardOutput $o -RedirectStandardError $e -NoNewWindow -PassThru
  $null = $p.Handle; [void]$p.WaitForExit(300000)
  $txt = ([string](Get-Content $o -Raw) + [string](Get-Content $e -Raw)).TrimEnd()
  W $txt | Out-Null
  W "exit $($p.ExitCode)" | Out-Null
  $newTmp = @(TempDirs | Where-Object { $tmp0 -notcontains $_ })
  $block = ($txt -match '(?m)^At .*\.ps1') -or ($txt -match 'CategoryInfo')
  $nlines = @($txt -split "`r?`n" | Where-Object { $_.Trim() }).Count
  if ($p.ExitCode -ne 0) { W "(refusal: $nlines non-empty line(s); PowerShell error block: $block)" | Out-Null }
  W "(new jetcarp-* folders in %TEMP%: $(if ($newTmp.Count) { $newTmp -join ', ' } else { 'none' }))" | Out-Null
}

W "#### R4 #117: the released PowerShell installer's refusals, $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
W "installer: jetcarp-installer.ps1 from the v0.4.2-rc.4 release, sha256 $((Get-FileHash $INS -Algorithm SHA256).Hash.ToLower())"
W "its default version and repository: $((Select-String -Path $INS -Pattern '^\s*(if \(-not \$Version\).*|\$Repo\s*=.*)' | ForEach-Object { $_.Line.Trim() }) -join ' | ')"
$errs = $null; $toks = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($INS, [ref]$toks, [ref]$errs)
W "Parser::ParseFile errors: $(@($errs).Count) (PowerShell $($PSVersionTable.PSVersion))"
$before = RawPath
W "jetcarp-* folders in %TEMP% at the start: $(@(TempDirs).Count) (test suites' leftovers, #121)"

# The refusals R4 names
New-Item -ItemType Directory -Force "$IW\not-mine" | Out-Null; Set-Content "$IW\not-mine\keep.txt" 'not the installer''s'
RunIns 'install into a folder the installer did not make (non-empty)' @('-DownloadUrl', "`"$DL`"", '-InstallDir', "`"$IW\not-mine`"", '-NoModifyPath')
W "not-mine afterwards: $((Get-ChildItem -Force "$IW\not-mine" | ForEach-Object Name) -join ', ')"
RunIns '-Uninstall where nothing was installed' @('-InstallDir', "`"$IW\nothing-here`"", '-Uninstall')
# Inside the download step
New-Item -ItemType Directory -Force "$IW\empty-dl" | Out-Null
RunIns '-DownloadUrl an empty folder (a refusal inside the download step)' @('-DownloadUrl', "`"$IW\empty-dl`"", '-InstallDir', "`"$IW\inst-c`"", '-NoModifyPath')
New-Item -ItemType Directory -Force "$IW\sums-only" | Out-Null; Copy-Item "$DL\SHA256SUMS" "$IW\sums-only" -Force
RunIns '-DownloadUrl a folder with SHA256SUMS but no zip (refused after the first download)' @('-DownloadUrl', "`"$IW\sums-only`"", '-InstallDir', "`"$IW\inst-c`"", '-NoModifyPath')
W "inst-c made by the refusals: $(Test-Path "$IW\inst-c")"

# An install and its uninstall, no PATH change (the wording; #103)
RunIns 'install with -NoModifyPath' @('-DownloadUrl', "`"$DL`"", '-InstallDir', "`"$IW\inst-a\jetcarp`"", '-NoModifyPath')
W "inst-a: $((Get-ChildItem "$IW\inst-a\jetcarp" -Force -ErrorAction SilentlyContinue | ForEach-Object Name) -join ', ')"
W "jetcarp --version from it: $(& "$IW\inst-a\jetcarp\jetcarp.exe" --version)"
RunIns '-Uninstall of that install' @('-InstallDir', "`"$IW\inst-a\jetcarp`"", '-Uninstall')
W "inst-a left: $(if (Test-Path "$IW\inst-a") { (Get-ChildItem -Force "$IW\inst-a" | ForEach-Object Name) -join ', ' } else { '(gone, with its parent)' })"
$end = RawPath
W "`r`nuser PATH unchanged (value and type): $(($end.value -ceq $before.value) -and ($end.kind -eq $before.kind))"
W "jetcarp-* folders in %TEMP% at the end: $(@(TempDirs).Count)"
W "#### end $(Get-Date -Format 'HH:mm:ss')"
"t117 done"
