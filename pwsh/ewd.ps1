$explorer = Get-Process -Name explorer | Where-Object MainWindowTitle -ne ""
if ($explorer.length -eq 0) {
  [Console]::Error.WriteLine('Explorer is not running. (Is "Launch folder windows in a separete process" enabled?)')
  exit 1
}
$type = [Type]::GetTypeFromProgID("Shell.Application")
$shell = [Activator]::CreateInstance($type)
$window = $shell.windows() | Where-Object HWND -eq $explorer.MainWindowHandle
$location = [Regex]::Replace($window.LocationURL, "%(..)", {
  [convert]::ToChar([convert]::ToInt32($args.groups[1].value, 16))
})

$path = ""
if ($location.StartsWith("file:///")) {
  $path = $location.Substring(8)
} elseif ($location.StartsWith("file://")) {
  $path = $location.Substring(5)
}

if ($path -ne "") {
  [Console]::Write($path.Replace("/","\"), [Text.Encoding]::Unicode)
} else {
  [Console]::Error.WriteLine("Invalid explorer path.")
  exit 1
}

# Do not remove this comment. See below.
# https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/14127231
