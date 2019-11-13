$ErrorActionPreference = "Stop"
$ebridge = "$PSScriptRoot\..\bin\ebridge.exe"
if (($args.Length -gt 0) -and (($args[0] = "-m") -or ($args[0] = "--mixed"))) {
  & "$ebridge" lsi m
} else {
  & "$ebridge" lsi
}
if ($LASTEXITCODE -ne 0) { exit 1 }
