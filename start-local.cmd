@echo off
setlocal
cd /d "%~dp0"

curl.exe --silent --fail --max-time 1 http://127.0.0.1:8000/admin.html -o nul >nul 2>nul
if not errorlevel 1 goto :open_admin

where py >nul 2>nul
if not errorlevel 1 (
    start "Signage Local Server" /D "%~dp0" py -m http.server 8000 --bind 127.0.0.1
    goto :wait_for_server
)

where python >nul 2>nul
if not errorlevel 1 (
    start "Signage Local Server" /D "%~dp0" python -m http.server 8000 --bind 127.0.0.1
    goto :wait_for_server
)

echo Python was not found. Install Python or use the VS Code Live Server extension.
pause
goto :end

:wait_for_server
for /l %%i in (1,1,15) do (
    curl.exe --silent --fail --max-time 1 http://127.0.0.1:8000/admin.html -o nul >nul 2>nul
    if not errorlevel 1 goto :open_admin
    timeout /t 1 /nobreak >nul
)
echo The local server did not start. Check whether port 8000 is already in use.
pause
goto :end

:open_admin
start "" "http://127.0.0.1:8000/admin.html"

:end
endlocal