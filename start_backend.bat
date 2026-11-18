@echo off
title Captain Vision Backend
echo ========================================================
echo   Starting Captain Vision Backend on http://0.0.0.0:8000
echo   (Accessible locally on http://127.0.0.1:8000 and from Android emulator on http://10.0.2.2:8000)
echo ========================================================
cd /d "c:\captin-vision-backend"

if exist "venv\Scripts\python.exe" (
    "venv\Scripts\python.exe" -m uvicorn app.main:app --host 0.0.0.0 --port 8000
) else if exist ".venv\Scripts\python.exe" (
    ".venv\Scripts\python.exe" -m uvicorn app.main:app --host 0.0.0.0 --port 8000
) else (
    echo [ERROR] Python virtual environment not found in c:\captin-vision-backend.
    pause
)
