$env:EOPEN_ROOT=$PSScriptRoot
if (Test-Path "$env:EOPEN_ROOT\bin\ebridge.exe") {
  Set-Alias eopen "explorer.exe"
  Set-Alias ewd "$env:EOPEN_ROOT\pwsh\ewd.ps1"
  Set-Alias ecd "$env:EOPEN_ROOT\pwsh\ecd.ps1"
  Set-Alias epushd "$env:EOPEN_ROOT\pwsh\epushd.ps1"
  Set-Alias epopd "$env:EOPEN_ROOT\pwsh\epopd.ps1"
} else {
  [Console]::Error.WriteLine("ebridge.exe not found: '$env:EOPEN_ROOT\bin\ebridge.exe'")
}
