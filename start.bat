@echo off
chcp 65001 >nul
REM CasinoCraft API Server - Start script

echo ========================================
echo   CasinoCraft API Server
echo ========================================
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo [!] Node.js khong tim thay!
    echo.
    echo Vui long cai Node.js: https://nodejs.org/
    pause
    exit /b 1
)

echo [i] Node version:
node --version
echo.

REM Check if dependencies are installed
if not exist "node_modules" (
    echo [*] Cai dat dependencies...
    npm install
    echo.
)

REM Create mods directory if not exists
if not exist "mods" (
    echo [*] Tao mods directory...
    mkdir mods
    echo [OK] Da tao mods directory
    echo.
)

REM Copy mods from pokermc build if available
if exist "..\pokermc\build\libs\casinocraft-*.jar" (
    echo [*] Copy mod files from pokermc build...
    copy "..\pokermc\build\libs\casinocraft-*.jar" "mods\" >nul
    echo [OK] Da copy mod files
    echo.
)

REM Start server
echo [*] Khoi dong API server...
echo.
echo Server se chay o: http://localhost:3000
echo.
echo API Endpoints:
echo   GET  /api/health
echo   GET  /api/mods/required
echo   GET  /api/news
echo   GET  /api/launcher/update
echo.
echo Press Ctrl+C de dung server
echo.
echo ========================================
echo.

node server.js
