# A minimal MCP client over stdio for `jetcarp mcp --app`: initialize, tools/list, and optional tool calls.
# Usage: mcpclient.ps1 -Out file.jsonl [-Call name] [-CallArgs '{"k":1}']
param([string]$Out, [string]$Call = '', [string]$CallArgs = '{}')
. "$PSScriptRoot\env2.ps1"
$psi = New-Object Diagnostics.ProcessStartInfo $J, "mcp --app"
$psi.RedirectStandardInput = $true; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true; $psi.UseShellExecute = $false
$psi.StandardOutputEncoding = [Text.Encoding]::UTF8
[Console]::InputEncoding = New-Object Text.UTF8Encoding $false   # so .NET's own stdin writer adds no byte-order mark
$pr = [Diagnostics.Process]::Start($psi)
$errTask = $pr.StandardError.ReadToEndAsync()
# stdin without a byte-order mark (PowerShell's default writer adds one, which the server can't parse).
$sw = New-Object IO.StreamWriter($pr.StandardInput.BaseStream, (New-Object Text.UTF8Encoding $false)); $sw.NewLine = "`n"; $sw.AutoFlush = $true
function Send($obj) { $line = ($obj | ConvertTo-Json -Compress -Depth 10); $sw.WriteLine($line); ">> $line" | Out-File -Encoding utf8 -Append $Out }
$script:pending = $null
function Recv([int]$id) {
  $deadline = (Get-Date).AddSeconds(30)
  while ((Get-Date) -lt $deadline) {
    if (-not $script:pending) { $script:pending = $pr.StandardOutput.ReadLineAsync() }
    if (-not $script:pending.Wait(30000)) { return $null }
    $line = $script:pending.Result; $script:pending = $null; if ($null -eq $line) { return $null }
    "<< $line" | Out-File -Encoding utf8 -Append $Out
    try { $m = $line | ConvertFrom-Json } catch { continue }
    if ($m.id -eq $id) { return $m }
  }
}
"" | Out-File -Encoding utf8 $Out
Send @{ jsonrpc = '2.0'; id = 1; method = 'initialize'; params = @{ protocolVersion = '2025-06-18'; capabilities = @{}; clientInfo = @{ name = 'rc2-acer-test'; version = '1' } } }
$init = Recv 1
"initialize: server $($init.result.serverInfo.name) $($init.result.serverInfo.version), protocol $($init.result.protocolVersion)"
Send @{ jsonrpc = '2.0'; method = 'notifications/initialized' }
Send @{ jsonrpc = '2.0'; id = 2; method = 'tools/list'; params = @{} }
$tl = Recv 2
$names = @($tl.result.tools | ForEach-Object { $_.name })
"tools: $($names.Count): $($names -join ', ')"
if ($Call) {
  Send @{ jsonrpc = '2.0'; id = 3; method = 'tools/call'; params = @{ name = $Call; arguments = ($CallArgs | ConvertFrom-Json) } }
  $cr = Recv 3
  $txt = ($cr.result.content | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text }) -join "`n"
  "call $Call -> isError $($cr.result.isError): $($txt.Substring(0, [Math]::Min(1500, $txt.Length)))"
  if ($cr.error) { "error: $($cr.error | ConvertTo-Json -Compress)" }
}
$sw.Close(); if (-not $pr.WaitForExit(10000)) { $pr.Kill() }
"mcp exit $($pr.ExitCode); stderr: $($errTask.Result)"
