@echo off
popd
if errorlevel 1 exit /b 1
setlocal
set pwd=%cd%
if %pwd:~-1,1% == \ set pwd=%pwd%\
"%EOPEN_ROOT%\bin\ebridge.exe" open "%pwd%" b
endlocal
