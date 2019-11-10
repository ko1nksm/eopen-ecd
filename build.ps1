$ErrorActionPreference = "Stop"

Set-Location "$PSScriptRoot"

New-Item "tmp", "dist" -ItemType Directory -Force | Out-Null
function build($plartform) {
  Set-Location src\
  msbuild.exe /p:Configuration="Release;Platform=$plartform" /m
  if ($LASTEXITCODE -ne 0) { throw "Build failed." }
  Set-Location ..\

  $ebridge = "src\$plartform\Release\ebridge.exe"
  $version = (Get-Content src\version.h) -replace '^.*?"|".*?$',""
  $name="eopen-ecd-$version-$plartform"

  Remove-Item "tmp\$name" -Recurse -ErrorAction Ignore
  New-Item "tmp\$name", "tmp\$name\bin" -ItemType Directory | Out-Null

  $files = @(
    "README.md"
    "CHANGELOG.md"
    "LICENSE"
    "init.bat"
    "init.ps1"
    "init.sh"
    "cmd"
    "pwsh"
    "wsl"
  )

  Copy-Item -Path $files -Recurse -Destination "tmp\$name"
  Copy-Item -Path "$ebridge" -Destination "tmp\$name\bin"

  Compress-Archive -Path "tmp\$name" -DestinationPath "dist\$name.zip" -Force
}

foreach($plartform in $args){
  build $plartform
}

Get-ChildItem dist
Write-Output "Generated"
