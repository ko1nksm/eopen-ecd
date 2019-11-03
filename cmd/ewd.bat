@echo off

setlocal
set ebridge="%~dp0..\bin\ebridge.exe"
"%ebridge%" pwd
if errorlevel 0 exit /b 1
echo.
endlocal
