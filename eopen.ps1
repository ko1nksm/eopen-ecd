Param([switch] $new, [string] $path)

Add-Type -AssemblyName System.Web
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
  [DllImport("user32.dll")]
  public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

  [DllImport("user32.dll")]
  [return: MarshalAs(UnmanagedType.Bool)]
  public static extern bool SetForegroundWindow(IntPtr hWnd);

  [DllImport("user32.dll")]
  public static extern bool SetWindowPos(
      IntPtr hWnd,
      IntPtr hWndInsertAfter,
      int X,
      int Y,
      int cx,
      int cy,
      UInt32 uFlags
  );
}
"@

if (-Not $new) {
  $explorer = Get-Process -Name explorer | Where-Object MainWindowTitle -ne ""
}
$type = [type]::GetTypeFromProgID("Shell.Application")
$shell = [Activator]::CreateInstance($type)
if ($explorer.length -eq 0) {
  [void]$shell.Open($path)
} else {
  $window = $shell.windows() | Where-Object HWND -eq $explorer.MainWindowHandle
  $window.Navigate($path)
  if (Test-Path "$path" -PathType Container) {
    $hwnd = $explorer.MainWindowHandle
    [void][Win32]::ShowWindow($hwnd, 9) # SW_RESTORE
    [void][Win32]::SetForegroundWindow($hwnd)
    [void][Win32]::SetWindowPos($hwnd, -1, 0, 0, 0, 0, 0x0003); # HWND_TOPMOST
    [void][Win32]::SetWindowPos($hwnd, -2, 0, 0, 0, 0, 0x0043); # HWND_NOTOPMOST
  }
}

# Do not remove this comment. See below.
# https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/14127231
