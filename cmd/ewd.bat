@echo off

setlocal
"%EOPEN_ROOT%\bin\ebridge.exe" pwd
if errorlevel 1 exit /b 1
echo.
endlocal
