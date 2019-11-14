$ErrorActionPreference = "Stop"
$ebridge = "$PSScriptRoot\..\bin\ebridge.exe"
if (($args.Length -gt 0) -and (($args[0] -match "-m") -or ($args[0] -match "--mixed"))) {
  & "$ebridge" pwd unicode m
} else {
  & "$ebridge" pwd unicode
}
if ($LASTEXITCODE -ne 0) { exit 1 }
