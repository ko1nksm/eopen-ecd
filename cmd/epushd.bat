@echo off

setlocal
set ewd="%~dp0..\bridge\ewd.ps1"
set pwsh=powershell -NoProfile -ExecutionPolicy Unrestricted
for /f "usebackq tokens=*" %%i IN (`%pwsh% %ewd%`) DO set dir=%%i

set /a count=0
for /d %%i in (%dir%) do set /a count=count+1

if "%count%" == "1" (
  endlocal & pushd %dir% & cd
  exit /b
)

rem Fallback when matching multiple unicode paths.
rem Characters that are invalid in the current code page are replaced with '?'.
rem Therefore, multiple folders may match. So switch the code page temporary.
for /f "usebackq tokens=*" %%i IN (`chcp`) DO set cp=%%i
chcp 65001 > NUL
for /f "usebackq tokens=*" %%i IN (`%pwsh% %ewd%`) DO set dir=%%i
chcp %cp:*: =% > NUL
endlocal & pushd %dir% & cd
