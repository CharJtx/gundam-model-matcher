@echo off
setlocal
cd /d "%~dp0"
if exist ".venv\Scripts\python.exe" (
  ".venv\Scripts\python.exe" app.py --open %*
) else (
  python app.py --open %*
)
if errorlevel 1 pause
endlocal
