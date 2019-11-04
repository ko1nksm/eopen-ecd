if (Test-Path "$PSScriptRoot\bin\ebridge.exe") {
  Set-Alias eopen "explorer.exe"
  Set-Alias ewd "$PSScriptRoot\pwsh\ewd.ps1"
  Set-Alias ecd "$PSScriptRoot\pwsh\ecd.ps1"
  Set-Alias epushd "$PSScriptRoot\pwsh\epushd.ps1"
} else {
  [Console]::Error.WriteLine("ebridge.exe not found: '$PSScriptRoot\bin\ebridge.exe'")
}
