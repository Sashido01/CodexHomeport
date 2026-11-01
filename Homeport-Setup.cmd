@echo off
setlocal
where pwsh.exe >nul 2>&1
if errorlevel 1 (
  echo PowerShell 7 is required. Install it from the official Microsoft source.
  pause
  exit /b 1
)
pwsh.exe -NoProfile -File "%~dp0scripts\bootstrap.ps1" -Apply
set "result=%ERRORLEVEL%"
if not "%result%"=="0" echo Setup failed. See the result above.
echo For official Desktop installation, see docs\ru\BOOTSTRAP.md.
pause
exit /b %result%
