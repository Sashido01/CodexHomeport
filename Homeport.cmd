@echo off
REM Codex Homeport Windows launcher - PowerShell 7, no substitute Codex runtime.
where pwsh >nul 2>&1
if errorlevel 1 (
  echo PowerShell 7 is required. Install it using the official Microsoft distribution.
  pause
  exit /b 1
)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\homeport-menu.ps1"
if errorlevel 1 echo Homeport reported an error. See the message above.
pause
