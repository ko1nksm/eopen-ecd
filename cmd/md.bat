@echo off

setlocal
set ebridge="%~dp0..\bin\ebridge.exe"
set skip=no

call :path %*
if errorlevel 1 exit /b 1

%cmd% %dest%
if errorlevel 1 exit /b 1

set pwd=%cd%
if %pwd:~-1,1% == \ set pwd=%pwd%\
if %skip% == no "%ebridge%" open "%pwd%" b
if errorlevel 1 exit /b 1

endlocal & cd /D %cd%

exit /b

:path
  set dest=%*
  if not defined dest set dest=%USERPROFILE% && exit /b

  if %dest%%dest% == :: set skip=yes && call :ewd && exit /b
  set pre=%dest:~0,2%
  set pre=%pre:/=\%
  if %pre%%pre% == :\:\ call :ewd && exit /b
  set pre=%dest:~0,3%
  set pre=%pre:/=\%
  if %pre%%pre% == :"\:"\ call :ewd && exit /b

  exit /b

:ewd
  set pwd=
  for /f "usebackq tokens=*" %%i IN (`"%ebridge%" pwd auto`) do set pwd=%%i
  if not defined pwd exit /b 1

  set dir="%pwd%"%dest:~1%

  set /a count=0
  for /d %%i in ("%dir%") do set /a count=count+1
  if "%count%" == "1" set dest=%dir% && exit /b

  rem Fallback when matching multiple unicode paths.
  rem Characters that are invalid in the current code page are replaced with '?'.
  rem Therefore, multiple folders may match. So switch the code page temporary.
  for /f "usebackq tokens=*" %%i IN (`"%ebridge%" chcp 65001`) DO set cp=%%i
  for /f "usebackq tokens=*" %%i IN (`"%ebridge%" pwd`) DO set pwd=%%i
  "%ebridge%" chcp %cp% > NUL
  set dest="%pwd%"%dest:~1%
  exit /b
