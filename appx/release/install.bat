@echo off
setlocal enabledelayedexpansion

:: --- تنظیمات رنگ ---
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
  set "ESC=%%b"
)

set "COLOR_SUCCESS=%ESC%[92m"
set "COLOR_ERROR=%ESC%[91m"
set "COLOR_INFO=%ESC%[94m"
set "COLOR_RESET=%ESC%[0m"
set "BOLD=%ESC%[1m"

:: --- عنوان اسکریپت ---
echo %BOLD%%COLOR_INFO%===============================================%COLOR_RESET%
echo %BOLD%           Zenora WSL Installation Script%COLOR_RESET%
echo %BOLD%%COLOR_INFO%===============================================%COLOR_RESET%
echo.

:: --- بررسی دسترسی ادمین ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo %COLOR_INFO%[!] Requesting administrator privileges...%COLOR_RESET%
    powershell -command "Start-Process -Verb RunAs -FilePath '%~dpnx0'"
    exit /b
)

:: --- مرحله 1: تنظیمات ترمینال ویندوز ---
set "settingsFile=%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if not exist "%settingsFile%" (
    echo %COLOR_ERROR%[X] Windows Terminal settings file not found.%COLOR_RESET%
    goto :InstallCert
)

findstr /C:"\"acrylicOpacity\"" "%settingsFile%" >nul 2>&1 && (
    echo %COLOR_INFO%[~] Terminal settings already configured.%COLOR_RESET%
    goto :InstallCert
)

set "tempFile=%temp%\wt_settings_%random%.json"
set "found=0"
(
    for /f "tokens=1* delims=:" %%a in ('findstr /n "^" "%settingsFile%"') do (
        set "line=%%b"
        if defined line (
            if "!line:defaults={}=!" neq "!line!" (
                echo     "defaults": {
                echo         "fontSize": 12,
                echo         "useAcrylic": true,
                echo         "acrylicOpacity": 0.8
                echo     },
                set "found=1"
            ) else (
                echo !line!
            )
        ) else (
            echo.
        )
    )
) > "%tempFile%"

if %found% equ 0 (
    echo %COLOR_ERROR%[X] Could not modify Terminal settings.%COLOR_RESET%
    goto :InstallCert
)

move /y "%tempFile%" "%settingsFile%" >nul 2>&1
echo %COLOR_SUCCESS%[✓] Terminal settings updated!%COLOR_RESET%

:InstallCert
:: --- مرحله 2: نصب گواهی ---
set "certFile=%~dp0app\Zenora_WSL_1.0.0.0_x64.cer"

if not exist "%certFile%" (
    echo %COLOR_ERROR%[X] Certificate file not found!%COLOR_RESET%
    goto :InstallAppx
)

echo %COLOR_INFO%[~] Installing certificate...%COLOR_RESET%
powershell -command "Import-Certificate -FilePath '%certFile%' -CertStoreLocation Cert:\LocalMachine\Root" || (
    echo %COLOR_ERROR%[X] Failed to install certificate!%COLOR_RESET%
    goto :InstallAppx
)
echo %COLOR_SUCCESS%[✓] Certificate installed!%COLOR_RESET%

:InstallAppx
:: --- مرحله 3: نصب بسته ---
set "appxFile=%~dp0app\Zenora_WSL_1.0.0.0_x64.appx"

if not exist "%appxFile%" (
    echo %COLOR_ERROR%[X] APPX file not found!%COLOR_RESET%
    goto :Finish
)

echo %COLOR_INFO%[~] Installing APPX package...%COLOR_RESET%
powershell -command "Add-AppxPackage -Path '%appxFile%' -ErrorAction Stop" || (
    echo %COLOR_ERROR%[X] Failed to install package!%COLOR_RESET%
    goto :Finish
)
echo %COLOR_SUCCESS%[✓] Package installed!%COLOR_RESET%

:Finish
:: --- پیام نهایی ---
echo.
echo %BOLD%%COLOR_INFO%===============================================%COLOR_RESET%
echo %COLOR_SUCCESS%       INSTALLATION COMPLETED%COLOR_RESET%
echo %BOLD%%COLOR_INFO%===============================================%COLOR_RESET%
echo.
echo %COLOR_INFO%Press any key to close this window...%COLOR_RESET%
pause >nul

exit /b 0