$ewd = "$PSScriptRoot\..\bridge\ewd.ps1"
$path = (powershell -NoProfile -ExecutionPolicy Unrestricted $ewd)
$dir = [System.IO.Path]::GetDirectoryName($path)
$file = [System.IO.Path]::GetFileName($path)
$dirs = [System.IO.Directory]::GetDirectories($dir, $file)
if ($dirs.length -eq 1) {
  cd $path.TrimEnd("`r?`n")
} else {
  # Fallback when matching multiple unicode paths.
  # Characters that are invalid in the current code page are replaced with '?'.
  # Therefore, multiple folders may match. So switch the code page temporary.
  $encode = [Console]::OutputEncoding
  [Console]::OutputEncoding = [Text.Encoding]::UTF8
  $path = (powershell -NoProfile -ExecutionPolicy Unrestricted $ewd)
  cd $path.TrimEnd("`r?`n")
  [Console]::OutputEncoding = $encode
}
