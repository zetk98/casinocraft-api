@echo off
chcp 65001 >nul
REM CasinoCraft API Server - Push to GitHub
REM Script này sẽ giúp bạn push code lên GitHub một cách tự động

echo ========================================
echo   CasinoCraft API - GitHub Deployment
echo ========================================
echo.

REM Check if .git exists
if not exist ".git" (
    echo [*] Step 1: Initialize Git repository
    echo.
    git init
    echo.
    echo [OK] Git repository initialized
    echo.
)

REM Check if remote exists
git remote -v >nul 2>&1
if errorlevel 1 (
    echo [!] Git remote not configured!
    echo.
    echo Vui lam cac buoc sau:
    echo.
    echo   1. Vao GitHub: https://github.com/new
    echo   2. Ten repository: casinocraft-api
    echo   3. Click "Create repository"
    echo   4. Copy GitHub URL (https://github.com/USERNAME/casinocraft-api.git)
    echo.
    echo   Sau do hoan tat, chay lai script nay va nhap URL vao day:
    echo.
    set /p GITHUB_URL="Nhap GitHub URL cua ban: "

    if not "%GITHUB_URL%"=="" (
        git remote add origin "%GITHUB_URL%"
        echo [OK] Remote added: %GITHUB_URL%
        echo.
        echo Tiep tuc: git push -u origin main
        git push -u origin main
    )
) else (
    echo [*] Git remote already configured
    echo.
    git remote -v
    echo.
)

REM Add files
echo [*] Step 2: Add files to git
echo.
git add .

echo [*] Step 3: Commit changes
git commit -m "Update CasinoCraft API Server - %date% %time%"
echo.

echo [*] Step 4: Push to GitHub
echo.
echo Bat dau push...
git push
echo.

if errorlevel 1 (
    echo.
    echo [!] Push that bai! Co the loi xay ra:
    echo.
    echo 1. Ban chua GitHub account? Dang ky tai: https://github.com/
    echo 2. Ban chua configure SSH key? Hoac hay dung Personal Access Token
    echo 3. Repository chua duoc create?
    echo.
    echo Giai phap:
    echo.
    echo Cach 1: Dung GitHub Desktop (de nhat)
    echo Cach 2: Dung Personal Access Token
    echo.
    echo Cach tao Personal Access Token:
    echo   1. Vao: https://github.com/settings/tokens
    echo   2. Click "Generate new token" (classic)
    echo   3. Select scopes: repo (full control)
    echo   4. Generate va copy token
    echo   5. Khi push: nhap Password = GitHub token
    echo.
    set /p TRY_AGAIN="Co muon thu lai khong? (y/n): "
    if /i "%TRY_AGAIN%"=="y" (
        git push
    )
) else (
    echo.
    echo [OK] Push thanh cong!
    echo.
    echo Bước tiếp theo:
    echo   1. Vào Railway: https://railway.app
    echo   2. New Project → Deploy from GitHub repo
    echo   3. Chọn casinocraft-api repository
    echo.
)

pause
