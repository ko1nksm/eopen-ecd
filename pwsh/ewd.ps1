$ErrorActionPreference = "Stop"
$ebridge = "$PSScriptRoot\..\bin\ebridge.exe"
& "$ebridge" pwd
if ($LASTEXITCODE -ne 0) { exit 1 }
[Console]::WriteLine()
