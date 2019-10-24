Add-Type -AssemblyName System.Web

$explorer = Get-Process -Name explorer | Where-Object MainWindowTitle -ne ""
if ($explorer.length -eq 0) {
  [Console]::Error.WriteLine('Explorer is not running. (Is "Launch folder windows in a separete process" enabled?)')
  exit 1
}
$type = [type]::GetTypeFromProgID("Shell.Application")
$shell = [Activator]::CreateInstance($type)
$window = $shell.windows() | Where-Object HWND -eq $explorer.MainWindowHandle
$location = [System.Web.HttpUtility]::UrlDecode($window.LocationURL)

if ($location.StartsWith("file:///")) {
  Write-Host -NoNewline $location.Substring(8).Replace("/","\")
} elseif ($location.StartsWith("file://")) {
  Write-Host -NoNewline $location.Substring(5).Replace("/","\")
} else {
  [Console]::Error.WriteLine("Invalid explorer path.")
  exit 1
}

# Do not remove this comment. See below.
# https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/14127231
