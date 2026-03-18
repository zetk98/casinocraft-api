@echo off
chcp 65001 >nul
REM CasinoCraft API Server - Update mods from pokermc build

echo ========================================
echo   Copy Mods from Pokermc Build
echo ========================================
echo.

REM Check if pokermc build exists
if not exist "..\pokermc\build\libs" (
    echo [!] Pokermc build directory not found!
    echo.
    echo Expected: ..\pokermc\build\libs\
    echo.
    echo Please build pokermc first:
    echo   cd ..\pokermc
    echo   gradlew build
    echo.
    pause
    exit /b 1
)

echo [*] Found pokermc build directory
echo.

REM Copy all JAR files
echo [*] Copying mod JAR files...
copy "..\pokermc\build\libs\*.jar" "mods\" >nul

if errorlevel 1 (
    echo [!] No JAR files found to copy
    pause
    exit /b 1
)

echo [OK] Copied files:

REM List copied files
dir /b "mods\*.jar"

echo.
echo [*] Updating mods.json...

REM Read current mods.json
if exist "mods.json" (
    powershell -Command "$mods = Get-Content mods.json | ConvertFrom-Json; $required = $mods.requiredMods; $required[0].size = (Get-Item mods\casinocraft-*.jar).Length; $required[0].sha256 = (Get-FileHash -Path mods\casinocraft-*.jar -Algorithm SHA256).Hash.ToLower(); $mods.requiredMods = $required; $mods | ConvertTo-Json -Depth 10 | Set-Content mods.json"
    echo [OK] Updated mods.json with file info
) else (
    echo [!] mods.json not found, skipping update
)

echo.
echo ========================================
echo   Hoan tat!
echo ========================================
echo.
echo Mods da copy va san sang.
echo API server se su dung cac file nay.
echo.
pause
