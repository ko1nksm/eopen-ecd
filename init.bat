@echo off

set EOPEN_ROOT=%~dp0
set EOPEN_ROOT=%EOPEN_ROOT:~0,-1%

if not exist "%EOPEN_ROOT%\bin\ebridge.exe" goto :error

doskey ewd="%EOPEN_ROOT%\cmd\ewd.bat" $*
doskey ecd="%EOPEN_ROOT%\cmd\ecd.bat" $*
doskey epushd="%EOPEN_ROOT%\cmd\epushd.bat" $*
doskey epopd="%EOPEN_ROOT%\cmd\epopd.bat" $*

goto :eof

:error
  echo ebridge.exe not found: '%EOPEN_ROOT%\bin\ebridge.exe' >&2
