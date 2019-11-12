@echo off

setlocal
for /f "usebackq tokens=*" %%i IN (`"%EOPEN_ROOT%\bin\ebridge.exe" pwd`) do set ewd=%%i
if "%1" == "-m" set ewd=%ewd:\=/%
if "%1" == "--mixed" set ewd=%ewd:\=/%
echo %ewd%
if errorlevel 1 exit /b 1
endlocal
