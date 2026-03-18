@echo off
chcp 65001 >nul
REM Upload ALL mods to Railway API

echo ========================================
echo   Upload All Mods to Railway API
echo ========================================
echo.

cd /d "%~dp0"

REM Copy all mods from TLauncher directory
echo [*] Copying mods from TLauncher...
set MODS_SOURCE=C:\Users\tuan2\AppData\Roaming\.tlauncher\legacy\Minecraft\game\mods

if not exist "%MODS_SOURCE%" (
    echo [!] Mods source not found: %MODS_SOURCE%
    pause
    exit /b 1
)

REM Create mods directory if not exists
if not exist "mods" mkdir mods

REM Copy all JAR files
copy /Y "%MODS_SOURCE%\*.jar" "mods\" >nul 2>&1

echo [OK] Copied all JAR files to mods/
echo.

REM Count mods
for %%f in (mods\*.jar) do set /a count+=1
echo [*] Total mods: %count%
echo.

REM Generate mods.json with all mods
echo [*] Generating mods.json...

powershell -Command ^
  "$baseUrl = 'https://casinocraft-api-production.up.railway.app';" ^
  "$mods = dir 'mods\*.jar' | ForEach-Object {" ^
    "  $fileName = $_.Name;" ^
    "  $modId = $fileName -replace '\.jar$', '';" ^
    "  $hash = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash.ToLower();" ^
    "  $size = $_.Length;" ^
    "  $url = \"$baseUrl/mods/$fileName\";" ^
    "  $required = if ($fileName -match 'fabric-api|casinocraft') { $true } else { $false };" ^
    "  @{" ^
    "    id = $modId;" ^
    "    name = $modId;" ^
    "    version = '1.0.0';" ^
    "    url = $url;" ^
    "    sha256 = $hash;" ^
    "    size = $size;" ^
    "    required = $required;" ^
    "    filename = $fileName" ^
    "  }" ^
    "};" ^
  "$requiredMods = $mods | Where-Object { $_.required -eq $true };" ^
  "$optionalMods = $mods | Where-Object { $_.required -eq $false };" ^
  "$modsJson = @{" ^
    "  serverVersion = '1.0.0';" ^
    "  minecraftVersion = '1.21.1';" ^
    "  loader = 'fabric';" ^
    "  loaderVersion = '0.15.11';" ^
    "  requiredMods = @($requiredMods);" ^
    "  optionalMods = @($optionalMods)" ^
    "};" ^
  "$modsJson | ConvertTo-Json -Depth 10 | Out-File -FilePath 'mods.json' -Encoding utf8;"

echo [OK] Generated mods.json
echo.

REM Add to git
echo [*] Adding to git...
git add mods/
git add mods.json

echo [*] Committing...
git commit -m "Add all mods for auto-update launcher"

echo [*] Pushing to GitHub...
git push

echo.
echo ========================================
echo [SUCCESS] All mods uploaded!
echo ========================================
echo.
echo Total mods uploaded: %count%
echo.
echo Railway will redeploy automatically.
echo API URL: https://casinocraft-api-production.up.railway.app
echo.
pause
