@echo off
REM Quick script to update and push to GitHub
REM Dùng sau khi da co GitHub repository

echo ========================================
echo   Push to GitHub - Quick Script
echo ========================================
echo.

echo 1. Adding files to git...
git add .

echo 2. Committing changes...
for /f "tokens=2-4 delims=/ " %%a in ('wmic datetime ^|sort') do set datetime=%%a')
git commit -m "Update CasinoCraft API Server - %datetime%"

echo 3. Pushing to GitHub...
git push

echo.
if errorlevel 1 (
    echo [!] Push failed!
    echo.
    echo Common issues:
    echo   - GitHub authentication failed
    echo   - Repository doesn't exist
    echo.
    echo Solutions:
    echo   - Make sure repo exists on GitHub first
    echo   - Use Personal Access Token for password
    echo.
) else (
    echo [SUCCESS] Pushed to GitHub successfully!
)

echo.
pause
