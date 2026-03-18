@echo off
chcp 65001 >nul
REM CasinoCraft API Server - Pre-flight Check
REM Script kiem tra truoc khi push len GitHub

echo ========================================
echo   Pre-Flight Check - GitHub Deployment
echo ========================================
echo.

echo [CHECK 1] Git installed?
where git >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Git NOT FOUND
    echo.
    echo Hay cai Git tai: https://git-scm.com/download/win
    echo.
    goto :end
) else (
    echo [PASS] Git found:
    where git
    echo.
)

echo [CHECK 2] Node.js installed? (for API server)
where node >nul 2>&1
if errorlevel 1 (
    echo [WARN] Node.js NOT FOUND
    echo Can still deploy but API server won't work locally
) else (
    echo [PASS] Node.js found:
    node --version
    echo.
)

echo [CHECK 3] Project files exist?
if exist "server.js" (
    echo [PASS] server.js found
) else (
    echo [FAIL] server.js NOT FOUND
    goto :end
)

if exist "package.json" (
    echo [PASS] package.json found
) else (
    echo [FAIL] package.json NOT FOUND
    goto :end
)

if exist "mods.json" (
    echo [PASS] mods.json found
) else (
    echo [WARN] mods.json NOT FOUND (will use defaults)
)

echo.
echo [CHECK 4] .git directory?
if exist ".git" (
    echo [WARN] .git already exists
    echo Repository may have been initialized
) else (
    echo [INFO] .git NOT FOUND
    Will need to initialize on first push
)

echo.
echo [CHECK 5] GitHub repository?
echo [INFO] Make sure you created repository on GitHub:
echo   1. Go to: https://github.com/new
echo   2. Name: casinocraft-api
echo   3. Create (NO README, NO .gitignore)
echo   4. Copy URL when created
echo.

echo ========================================
echo.

if exist ".git" (
    echo Remote repositories configured:
    git remote -v
    echo.
) else (
    echo [ACTION] Next: Run deploy-to-github-fixed.bat
)

echo.
echo [INFO] Common issues when pushing fails:
echo   1. Authentication error → Use Personal Access Token
   2. Repository not found → Create on GitHub first
echo   3. SSL errors → Check internet connection
echo.

:end
echo ========================================
pause
