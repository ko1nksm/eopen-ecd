Pop-Location
$dir = Get-Location | Convert-Path
& "$env:EOPEN_ROOT\bin\ebridge.exe" "open" $dir b
