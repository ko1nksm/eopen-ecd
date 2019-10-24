@echo off

for /f "usebackq tokens=*" %%i IN (
  `powershell -ExecutionPolicy Unrestricted %~dp0ewd.ps1`
) DO cd /D %%i
