@echo off

setlocal
set ewd=powershell -NoProfile -ExecutionPolicy Unrestricted "%~dp0ewd.ps1"
for /f "usebackq tokens=*" %%i IN (`%ewd%`) DO set dir=%%i

set /a count=0
for /d %%i in (%dir%) do set /a count=count+1

if "%count%" == "1" (
  endlocal & cd %dir% & cd
  exit /b
)

rem Fallback when matching multiple unicode paths.
rem Characters that are invalid in the current code page are replaced with '?'.
rem Therefore, multiple folders may match. So switch the code page temporary.
for /f "usebackq tokens=*" %%i IN (`chcp`) DO set cp=%%i
chcp 65001 > NUL
for /f "usebackq tokens=*" %%i IN (`%ewd%`) DO set dir=%%i
chcp %cp:*: =% > NUL
endlocal & cd %dir% & cd
