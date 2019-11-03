@echo off

setlocal
set ebridge="%~dp0..\bin\ebridge.exe"
for /f "usebackq tokens=*" %%i IN (`"%ebridge%" pwd auto`) DO set dir=%%i
if errorlevel 0 exit /b 1

set /a count=0
for /d %%i in ("%dir%") do set /a count=count+1

if "%count%" == "1" (
  endlocal & cd "%dir%" & cd
  exit /b
)

rem Fallback when matching multiple unicode paths.
rem Characters that are invalid in the current code page are replaced with '?'.
rem Therefore, multiple folders may match. So switch the code page temporary.
for /f "usebackq tokens=*" %%i IN (`"%ebridge%" chcp 65001`) DO set cp=%%i
for /f "usebackq tokens=*" %%i IN (`"%ebridge%" pwd`) DO set dir=%%i
"%ebridge%" chcp %cp% > NUL
endlocal & cd %dir% & cd
