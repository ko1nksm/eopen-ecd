@echo off

popd
if errorlevel 1 exit /b 1

setlocal

set pwd="%cd%"
set value=%pwd:~-2,1%
call :match \
if %ret% == match set pwd=%pwd:~0,-1%\"
"%EOPEN_ROOT%\bin\ebridge.exe" open %pwd% b
if errorlevel 1 exit /b 1

endlocal

:match
  set expect=%*
  setlocal enabledelayedexpansion
  if !value! == !expect! endlocal & set ret=match & exit /b
  endlocal & set ret=unmatch & exit /b
