@echo off

if "%1" == "" (
  call :build x86 x64 arm arm64
  goto :eof
)

:build
  powershell -NoProfile -ExecutionPolicy Unrestricted %~dp0build.ps1 %*
