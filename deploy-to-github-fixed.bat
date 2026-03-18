@echo off
chcp 65001 >nul
REM CasinoCraft API Server - Fixed Push Script
REM Fix lỗi CMD tắt ngay lập

echo ========================================
echo   CasinoCraft API - Push to GitHub
echo ========================================
echo.

REM Check git is installed
where git >nul 2>&1
if errorlevel 1 (
    echo [!] Git chua duoc cai dat!
    echo.
    echo Hay cai Git tai: https://git-scm.com/downloads
    echo.
    echo Sau khi cai xong, chay lai script nay.
    pause
    exit /b 1
)

echo [i] Git da duoc tim thay:
where git
echo.

REM Navigate to script directory
cd /d "%~dp0"

REM Check if .git exists
if not exist ".git" (
    echo [*] Step 1: Khoi tao Git repository...
    echo.
    call :init_git
) else (
    echo [*] Git repository da ton tai
    echo.
)

REM Add files
echo [*] Step 2: Them files vao git...
echo.
git add .

if errorlevel 1 (
    echo [!] Git add that bai!
    pause
    exit /b 1
)

echo [OK] Files da duoc add
echo.

REM Commit
echo [*] Step 3: Commit changes...
echo.

for /f "tokens=2-4 delims=/ " %%a in ('wmic datetime ^|sort') do set datetime=%%a
set commit_msg=Update CasinoCraft API Server - %datetime%

git commit -m "%commit_msg%"

if errorlevel 1 (
    echo [!] Git commit that bai!
    echo.
    echo Co the co the sai xay ra.
    echo.
    goto :push_retry
) else (
    echo [OK] Committed: %commit_msg%
    echo.
)

REM Push
:push_retry
echo [*] Step 4: Push len GitHub...
echo.
echo Bat dau push...
echo.

git push -u origin main

if errorlevel 1 (
    echo.
    echo [!] Push that bai!
    echo.
    echo NGUYEN nhan:
    echo   1. GitHub chua ton tai?
    echo      - Vao: https://github.com/new
    echo      - Tao ten repository: casinocraft-api
    echo.
    echo   2. Remote chua duoc configure?
    echo      - Chay script nay, nhap GitHub URL khi duoc hoi
    echo.
    echo   3. Authentication that bai?
    echo      - Su dung Personal Access Token thay password
    echo      - Vao: https://github.com/settings/tokens
    echo      - Generate: classic, repo (full control)
    echo.
    set /p TRY_AGAIN="Co muon thu lai khong? (y/n): "
    if /i "%TRY_AGAIN%"=="y" goto :push_retry
) else (
    echo.
    echo [SUCCESS] Da push code len GitHub thanh cong!
    echo.
    echo Bước tiếp theo - Deploy lên Railway:
    echo   1. Vào https://railway.app/
    echo   2. Login bang GitHub
    echo   3. New Project → Deploy from GitHub repo
    echo   4. Chọn casinocraft-api repository
    echo.
    echo Railway URL se la: https://casinocraft-api.up.railway.app
    echo.
)

goto :end

:init_git
echo Dang khoi tao git repository...
git init

echo.
set /p GITHUB_URL="Nhap GitHub URL (https://github.com/USERNAME/casinocraft-api.git): "

if "%GITHUB_URL%"=="" (
    echo.
    echo [!] Ban chua nhap URL!
    echo.
    echo Hay:
    echo   1. Tao repository tren GitHub truoc
    echo   2. Copy URL tu GitHub
    echo   3. Chay lai script nay va nhap URL
    echo.
    pause
    exit /b 1
)

git remote add origin %GITHUB_URL%

if errorlevel 1 (
    echo [!] Khong the them remote! Co the xay ra...
) else (
    echo [OK] Remote da duoc them: %GITHUB_URL%
)

echo.
echo Tiep tuc, chay lai script nay va bat "tiep tuc" khi duoc hoi...

:end
echo.
echo ========================================
pause
