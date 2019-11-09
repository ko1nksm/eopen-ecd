@echo off

set ebridge=%EOPEN_ROOT%\bin\ebridge.exe
set skip=no
set dir=%*

call :dir
if errorlevel 1 exit /b 1

%cmd% %dir%
if errorlevel 1 exit /b 1

set pwd="%cd%"
set value=%pwd:~-2,1%
call :match \
if %ret% == match set pwd=%pwd:~0,-1%\"
if %skip% == no "%ebridge%" open %pwd% b
if errorlevel 1 exit /b 1

endlocal & cd /D "%cd%"
exit /b 0

:dir
  set ewd=no
  if not defined dir set dir=%USERPROFILE% && exit /b

  set value=%dir%
  call :match :
  if %ret% == match set skip=yes & set ewd=yes & set dir=%dir:~1%

  set value=%dir:~0,2%
  call :match :\
  if %ret% == match set ewd=yes & set dir=%dir:~1%
  call :match :/
  if %ret% == match set ewd=yes & set dir=%dir:~1%

  set value=%dir:~0,3%
  call :match ":\
  if %ret% == match set ewd=yes & set dir="%dir:~2%
  call :match ":/
  if %ret% == match set ewd=yes & set dir="%dir:~2%

  set value=%dir:~0,3%
  call :match :"\
  if %ret% == match set ewd=yes & set dir=%dir:~2%
  call :match :"/
  if %ret% == match set ewd=yes & set dir=%dir:~2%

  if %ewd% == yes call :ewd & exit /b

  exit /b

:ewd
  set ewd=
  for /f "usebackq tokens=*" %%i IN (`"%ebridge%" pwd auto`) do set ewd=%%i
  if not defined ewd exit /b 1

  set ewd="%ewd%"%dir%

  set /a count=0
  for /d %%i in (%ewd%) do set /a count=count+1
  if "%count%" == "1" set dir=%ewd% & exit /b

  rem Fallback when matching multiple unicode paths.
  rem Characters that are invalid in the current code page are replaced with '?'.
  rem Therefore, multiple folders may match. So switch the code page temporary.
  for /f "usebackq tokens=*" %%i IN (`"%ebridge%" chcp 65001`) DO set cp=%%i
  for /f "usebackq tokens=*" %%i IN (`"%ebridge%" pwd`) DO set ewd=%%i
  "%ebridge%" chcp %cp% > NUL
  set dir="%ewd%"%dir%
  exit /b

:match
  set expect=%*
  setlocal enabledelayedexpansion
  if !value! == !expect! endlocal & set ret=match & exit /b
  endlocal & set ret=unmatch & exit /b
