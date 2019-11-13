@echo off

setlocal
set option=
if "%1" == "-m" set option=m
if "%1" == "--mixed" set option=m
"%EOPEN_ROOT%\bin\ebridge.exe" lsi %option%
endlocal
