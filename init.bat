@echo off

if not exist "%~dp0bin\ebridge.exe" goto :error

doskey eopen="explorer.exe" $*
doskey ewd="%~dp0cmd\ewd.bat" $*
doskey ecd="%~dp0cmd\ecd.bat" $*
doskey epushd="%~dp0cmd\epushd.bat" $*

goto :eof

:error
  echo ebridge.exe not found: '%~dp0bin\ebridge.exe' >&2
