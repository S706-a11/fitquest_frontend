@echo off
echo ========================================
echo    FitQuest Flutter App - Port 3000
echo ========================================
echo.
echo Starting Flutter web app on port 3000...
echo.
echo App will open at: http://localhost:3000
echo Backend API should be at: http://localhost:5105
echo.
flutter run -d chrome --web-port=3000 --web-hostname=localhost
