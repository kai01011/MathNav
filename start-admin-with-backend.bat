@echo off
echo ========================================
echo Starting MathNav Admin Panel + Backend
echo ========================================
echo.

echo Starting Backend Server...
start "MathNav Backend" cmd /k "cd web-admin-backend && npm start"

timeout /t 3 /nobreak > nul

echo Starting Admin Panel...
start "MathNav Admin Panel" cmd /k "cd web-admin && npm start"

echo.
echo ========================================
echo Both servers are starting!
echo ========================================
echo.
echo Backend: http://localhost:3001
echo Admin Panel: http://localhost:3000
echo.
echo Close this window when done.
echo.
pause
