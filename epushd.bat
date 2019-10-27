@echo off

for /f "usebackq tokens=*" %%i IN (
  `powershell -NoProfile -ExecutionPolicy Unrestricted %~dp0ewd.ps1`
) DO (
  pushd %%i
  echo|set /p=%%i
)
