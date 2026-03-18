@echo off
chcp 65001 >nul
REM Auto-upload mod JAR to Railway API
REM Script nay copy JAR tu pokermc/build vao mods/ va push len GitHub

echo ========================================
echo   Upload Mod to Railway API
echo ========================================
echo.

REM Navigate to script directory
cd /d "%~dp0"

REM Check if mods directory exists
if not exist "mods" (
    echo [*] Creating mods directory...
    mkdir mods
)

REM Get JAR file from pokermc
set JAR_SOURCE=D:\pokermc\build\libs\casinocraft-1.5.0.jar

if not exist "%JAR_SOURCE%" (
    echo [!] JAR file not found: %JAR_SOURCE%
    echo.
    echo Hay build mod truoc:
    echo   cd D:\pokermc
    echo   gradlew build
    echo.
    pause
    exit /b 1
)

echo [*] Found JAR: %JAR_SOURCE%
echo.

REM Copy to mods directory
echo [*] Copying JAR to mods directory...
copy /Y "%JAR_SOURCE%" "mods\casinocraft-1.5.0.jar"

if errorlevel 1 (
    echo [!] Copy failed!
    pause
    exit /b 1
)

echo [OK] Copied to mods\casinocraft-1.5.0.jar
echo.

REM Calculate SHA256
echo [*] Calculating SHA256...
powershell -Command "$hash = (Get-FileHash -Path 'mods\casinocraft-1.5.0.jar' -Algorithm SHA256).Hash.ToLower(); $content = Get-Content 'mods.json' -Raw | ConvertFrom-Json; $content.requiredMods[0].version = '1.5.0'; $content.requiredMods[0].url = 'https://casinocraft-api-production.up.railway.app/mods/casinocraft-1.5.0.jar'; $content.requiredMods[0].sha256 = $hash; $content.requiredMods[0].size = (Get-Item 'mods\casinocraft-1.5.0.jar').Length; $content | ConvertTo-Json -Depth 10 | Set-Content 'mods.json'"

echo [OK] Updated mods.json
echo.

REM Git add, commit, push
echo [*] Pushing to GitHub...
git add mods/
git add mods.json
git commit -m "Update mod to v1.5.0"
git push

echo.
echo [SUCCESS] Mod uploaded and pushed to GitHub!
echo Railway will auto-redeploy with the new mod.
echo.
echo Download URL:
echo   https://casinocraft-api-production.up.railway.app/mods/casinocraft-1.5.0.jar
echo.

echo ========================================
pause
