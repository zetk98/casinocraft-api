@echo off
chcp 65001 >nul
REM CasinoCraft API Server - Git Setup Only (No push)
REM Script nay chi setup git, KHONG push

echo ========================================
echo   Git Repository Setup - No Push
echo ========================================
echo.

REM Check git
where git >nul 2>&1
if errorlevel 1 (
    echo [!] Git chua duoc cai dat!
    echo.
    echo Hay cai Git tai: https://git-scm.com/downloads
    pause
    exit /b 1
)

echo [OK] Git da duoc tim thay
echo.

REM Navigate to script directory
cd /d "%~dp0"

REM Check if already initialized
if exist ".git" (
    echo [INFO] Git repository da ton tai
    echo.
    echo Ban co muon reinitialize? (xoa va lam lai)
    set /p REINIT="Reinitialize (y/n)? "
    if /i not "%REINIT%"=="y" goto :end
    rmdir /s /q .git 2>nul
    echo [OK] Da xoa .git folder
    echo.
)

echo [*] Initializing git repository...
echo.

git init

echo [*] Adding files to git...
git add .

echo [*] Creating initial commit...
for /f "tokens=2-4 delims=/ " %%a in ('wmic datetime ^|sort') do set datetime=%%a
git commit -m "Initial commit - CasinoCraft API Server - %datetime%"

echo.
echo [SUCCESS] Git repository da duoc setup!
echo.
echo Next step: Add GitHub remote and push
echo.

echo Chay len nay va nhap GitHub URL khi duoc hoi:
set /p GITHUB_URL="Nhap GitHub URL (https://github.com/USERNAME/casinocraft-api.git): "

if not "%GITHUB_URL%"=="" (
    git remote add origin %GITHUB_URL%
    echo [OK] Remote added: %GITHUB_URL%
    echo.
    echo Bay gio co the push code len GitHub:
    echo   git push -u origin main
    echo.
    echo Sau do push:
    echo   1. Vao railway.app
    echo   2. Deploy from GitHub repo
    echo.
) else (
    echo [CANCELLED] Khong nhap URL
    echo.
    echo De add remote thu cong:
    echo   git remote add origin https://github.com/USERNAME/casinocraft-api.git
    echo.
)

:end
echo ========================================
pause
