@echo off
:: Zenora WSL Complete Uninstaller - Final Fixed Version
:: This version properly handles admin elevation with no argument issues

set DISTRIBUTION_NAME=Zenora
set PACKAGE_NAME=52569scottxu.ZenoraLinux
set PACKAGE_PATH=.\app\Zenora_WSL_1.0.0.0_x64.appx

:: ============================================
:: Robust admin elevation method
:: ============================================
:: Check for admin rights
fltmc >nul 2>&1 || (
    echo Requesting administrator privileges...
    
    :: Use PowerShell with proper argument handling
    if "%~1"=="" (
        powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    ) else (
        powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs -ArgumentList '%~1'"
    )
    
    exit /b
)

:: ============================================
:: Main uninstallation process
:: ============================================
echo === Zenora WSL Complete Uninstallation ===
echo.

:: Step 1: Unregister WSL distribution
echo [1/3] Checking WSL distribution...
wsl.exe --list | find "%DISTRIBUTION_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo Terminating and unregistering %DISTRIBUTION_NAME% WSL distribution...
    wsl.exe --terminate %DISTRIBUTION_NAME% >nul 2>&1
    wsl.exe --unregister %DISTRIBUTION_NAME% >nul 2>&1
    if %errorlevel% equ 0 (
        echo [✓] Successfully unregistered WSL distribution.
    ) else (
        echo [×] Failed to unregister WSL distribution.
    )
) else (
    echo [i] %DISTRIBUTION_NAME% WSL distribution not found.
)
echo.

:: Step 2: Remove Appx package
echo [2/3] Removing Appx package...
powershell -NoProfile -Command "Get-AppxPackage -Name '%PACKAGE_NAME%' | Remove-AppxPackage -ErrorAction SilentlyContinue"
if %errorlevel% equ 0 (
    echo [✓] Successfully removed %PACKAGE_NAME% package.
) else (
    powershell -NoProfile -Command "Get-AppxPackage -Name '%PACKAGE_NAME%'"
    if %errorlevel% equ 0 (
        echo [×] Failed to remove %PACKAGE_NAME% package.
    ) else (
        echo [i] %PACKAGE_NAME% package not installed.
    )
)
echo.

:: Step 3: Clean up package file
echo [3/3] Cleaning up package files...
if exist "%PACKAGE_PATH%" (
    del /q /f "%PACKAGE_PATH%" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [✓] Removed package file: %PACKAGE_PATH%
    ) else (
        echo [×] Failed to remove package file.
    )
) else (
    echo [i] Package file not found at: %PACKAGE_PATH%
)

:: Additional cleanup
echo.
echo Performing final cleanup...
powershell -NoProfile -Command "& {
    Get-AppxPackage -Name '%PACKAGE_NAME%' -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue;
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like '*Zenora*' } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}" >nul 2>&1

echo.
echo === Uninstallation Complete ===
echo.
pause