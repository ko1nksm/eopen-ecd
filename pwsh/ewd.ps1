$ErrorActionPreference = "Stop"
$ebridge = "$PSScriptRoot\..\bin\ebridge.exe"
if (($args.Length -gt 0) -and (($args[0] = "-m") -or ($args[0] = "--mixed"))) {
  & "$ebridge" pwd auto m
} else {
  & "$ebridge" pwd auto
}
if ($LASTEXITCODE -ne 0) { exit 1 }
