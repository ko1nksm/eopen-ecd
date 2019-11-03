try {
  $ErrorActionPreference = "Stop"
  $ebridge = "$PSScriptRoot\..\bin\ebridge.exe"
  $path = ""
  $path = (& "$ebridge" pwd auto)
  if ($LASTEXITCODE -ne 0) { exit 1 }
  $dir = [System.IO.Path]::GetDirectoryName($path)
  $file = [System.IO.Path]::GetFileName($path)
  $dirs = [System.IO.Directory]::GetDirectories($dir, $file)
  if ($dirs.length -eq 1) {
    Push-Location $path
    [Console]::WriteLine($path)
  } else {
    # Fallback when matching multiple unicode paths.
    # Characters that are invalid in the current code page are replaced with '?'.
    # Therefore, multiple folders may match. So switch the code page temporary.
    $encode = [Console]::OutputEncoding
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    $path = (& "$ebridge" pwd)
    Push-Location $path
    [Console]::WriteLine($path)
    [Console]::OutputEncoding = $encode
  }
} catch {
  [Console]::Error.WriteLine("Unable to move to '" + $path + "'")
}