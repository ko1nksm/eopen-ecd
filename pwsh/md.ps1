Param($cmd, $path)
$ErrorActionPreference = "Stop"
$ebridge = "$PSScriptRoot\..\bin\ebridge.exe"
$skip = $FALSE

if ($NULL -eq $path) { $path = $env:USERPROFILE }

if ($path -match "^(:|:[/\\].*)$") {
  $ewd = ""
  $ewd = (& "$ebridge" pwd auto)
  if ($LASTEXITCODE -ne 0) { exit 1 }
  if ($NULL -eq $ewd) { exit 1 }

  try {
    $current = Get-Location
    Set-Location $path
    Set-Location $current
  } catch {
    # Fallback when matching multiple unicode paths.
    # Characters that are invalid in the current code page are replaced with '?'.
    # Therefore, multiple folders may match. So switch the code page temporary.
    $encode = [Console]::OutputEncoding
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    $ewd = (& "$ebridge" pwd)
    [Console]::OutputEncoding = $encode
  }

  if ($path -eq ":") {
    $skip = $TRUE
    $path = $ewd
  } else {
    $path = ($ewd -replace "\\$", "") + $path.Substring(1)
  }
}

& $cmd $path
if ($skip) { exit 0 }
$dir = Get-Location | Convert-Path
& "$ebridge" "open" $dir b
