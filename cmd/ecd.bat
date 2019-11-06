@echo off

setlocal
set cmd=cd /D
call "%~dp0md.bat" %*
if errorlevel 1 exit /b 1
endlocal & cd /D %cd%
