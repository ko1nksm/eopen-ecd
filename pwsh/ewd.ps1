$ErrorActionPreference = "Stop"
$ebridge = "$PSScriptRoot\..\bin\ebridge.exe"
if (($args.Length -gt 0) -and (($args[0] = "-m") -or ($args[0] = "--mixed"))) {
  [Console]::Write((& "$ebridge" pwd).Replace("\", "/"))
} else {
  [Console]::Write((& "$ebridge" pwd))
}
if ($LASTEXITCODE -ne 0) { exit 1 }
[Console]::WriteLine()
