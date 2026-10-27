@echo off
setlocal
cd /d "%~dp0"
set PORT=8000

:check_port
curl.exe --silent --fail --max-time 1 --get --data-urlencode "root=%CD%" http://127.0.0.1:%PORT%/__media-root-check -o nul >nul 2>nul
if not errorlevel 1 goto :open_pages

curl.exe --silent --fail --max-time 1 http://127.0.0.1:%PORT%/admin.html -o nul >nul 2>nul
if not errorlevel 1 (
    set /a PORT+=1
)
if %PORT% GTR 8010 goto :no_free_port
if not errorlevel 1 goto :check_port

where py >nul 2>nul
if not errorlevel 1 (
    start "Signage Local Server" /D "%~dp0" py "%~dp0local-server.py" %PORT%
    goto :wait_for_server
)

where python >nul 2>nul
if not errorlevel 1 (
    start "Signage Local Server" /D "%~dp0" python "%~dp0local-server.py" %PORT%
    goto :wait_for_server
)

where node >nul 2>nul
if not errorlevel 1 (
    start "Signage Local Server" /D "%~dp0" node "%~dp0local-server.js" %PORT%
    goto :wait_for_server
)

echo Python or Node.js was not found. Install one of them or use the VS Code Live Server extension.
pause
goto :end

:wait_for_server
for /l %%i in (1,1,15) do (
    curl.exe --silent --fail --max-time 1 --get --data-urlencode "root=%CD%" http://127.0.0.1:%PORT%/__media-root-check -o nul >nul 2>nul
    if not errorlevel 1 goto :open_pages
    timeout /t 1 /nobreak >nul
)
echo The local server did not start on port %PORT%.
pause
goto :end

:no_free_port
echo No free local port was found between 8000 and 8010.
pause
goto :end

:open_pages
echo Admin page: http://127.0.0.1:%PORT%/admin.html
echo Signage page: http://127.0.0.1:%PORT%/index.html
start "" "http://127.0.0.1:%PORT%/admin.html"
start "" "http://127.0.0.1:%PORT%/index.html"

:end
endlocal
