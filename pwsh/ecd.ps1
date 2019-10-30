
$encode = [Console]::OutputEncoding
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$ewd = "$PSScriptRoot\ewd.ps1"
cd (powershell -NoProfile -ExecutionPolicy Unrestricted $ewd).TrimEnd("`r?`n")
[Console]::OutputEncoding = $encode
