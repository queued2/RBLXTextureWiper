@echo off
setlocal enabledelayedexpansion
title Bootstrapper Texture Eraser

:: Force Admin
>nul 2>&1 net session
if %errorLevel% neq 0 (
    echo Requesting Administrator rights...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "ARCHIVE_BASE=%~dp0archive"
set "LOG_FILE=%~dp0cleanup.log"

if not exist "%ARCHIVE_BASE%" mkdir "%ARCHIVE_BASE%"

:bootstrapper_menu
cls
echo ================================================
echo           Bootstrapper Texture Eraser
echo                (by queued2)
echo ================================================
echo.
echo  1. Fishstrap
echo  2. Bloxstrap
echo  3. Voidstrap
echo  4. Lunastrap
echo  5. Exit
echo.
set /p bootChoice="Enter choice (1-5): "

if "%bootChoice%"=="1" set "BOOTSTRAP=Fishstrap" & goto select_version
if "%bootChoice%"=="2" set "BOOTSTRAP=Bloxstrap" & goto select_version
if "%bootChoice%"=="3" set "BOOTSTRAP=Voidstrap" & goto select_version
if "%bootChoice%"=="4" set "BOOTSTRAP=Lunastrap" & goto select_version
if "%bootChoice%"=="5" goto end
goto bootstrapper_menu

:select_version
set "VERSION_DIR=%USERPROFILE%\AppData\Local\%BOOTSTRAP%\Versions"
for /d %%i in ("%VERSION_DIR%\version-*") do set "TARGET_DIR=%%i"

:selection_menu
cls
echo Cleaning for: %BOOTSTRAP%
echo Version folder: %TARGET_DIR%
echo.
echo  1. Delete surface textures (e.g studs in baseplate games)
echo  2. Delete particle textures
echo  3. Delete sky textures (sun, moon, etc; good for Gray Sky fflag)
echo  4. Back
echo.
set /p choice="Enter choice (1-4): "

if "%choice%"=="1" set "PATH_TO_DELETE=%TARGET_DIR%\PlatformContent\pc\textures" & goto confirm
if "%choice%"=="2" set "PATH_TO_DELETE=%TARGET_DIR%\content\textures\particles" & goto confirm
if "%choice%"=="3" set "PATH_TO_DELETE=%TARGET_DIR%\content\sky" & goto confirm
if "%choice%"=="4" goto bootstrapper_menu
goto selection_menu

:confirm
if not exist "%PATH_TO_DELETE%" (
    echo Path not found: "%PATH_TO_DELETE%"
    pause
    goto selection_menu
)

echo.
echo Selected: %PATH_TO_DELETE%
set /p archiveChoice="Archive (zip) before deleting? (Y/N): "

if /i "%archiveChoice%"=="Y" goto archive
if /i "%archiveChoice%"=="N" goto deletefiles
goto confirm

:archive
set "DATESTAMP=%date:~-4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%"
set "ARCHIVE_FILE=%ARCHIVE_BASE%\%BOOTSTRAP%_%DATESTAMP%.zip"

echo.
echo Archiving to "%ARCHIVE_FILE%" ...
powershell -NoLogo -NoProfile -Command "Compress-Archive -Path '%PATH_TO_DELETE%\*' -DestinationPath '%ARCHIVE_FILE%' -Force"
if errorlevel 1 (
    echo Archive failed. Continuing...
) else (
    echo Archive complete.
)
goto deletefiles

:deletefiles
echo.
echo Deleting all contents of: "%PATH_TO_DELETE%"
echo Log: %LOG_FILE%

for /f "delims=" %%f in ('dir /b /s "%PATH_TO_DELETE%" 2^>nul') do (
    echo Deleted: %%f >> "%LOG_FILE%"
)

rmdir /s /q "%PATH_TO_DELETE%"
mkdir "%PATH_TO_DELETE%"

echo.
echo Deletion complete.
pause
goto selection_menu

:end
echo.
echo Exiting...
timeout /t 2 >nul
exit
