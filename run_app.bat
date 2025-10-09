@echo off
:menu
cls
echo ========================================
echo      FitQuest Flutter App Launcher
echo ========================================
echo.
echo Select where to run the app:
echo.
echo 1. Chrome (Port 3000)
echo 2. Edge (Port 3000)
echo 3. Windows Desktop
echo 4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto chrome
if "%choice%"=="2" goto edge
if "%choice%"=="3" goto windows
if "%choice%"=="4" goto exit
echo Invalid choice. Please try again.
pause
goto menu

:chrome
echo.
echo Starting on Chrome...
flutter run -d chrome --web-port=3000 --web-hostname=localhost
goto end

:edge
echo.
echo Starting on Edge...
flutter run -d edge --web-port=3000 --web-hostname=localhost
goto end

:windows
echo.
echo Starting on Windows Desktop...
flutter run -d windows
goto end

:exit
echo.
echo Goodbye!
goto end

:end
pause
