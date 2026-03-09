@echo off
setlocal

set TOOLS=C:\source\i3xtools\tools
set VOLUMES=C:\source\i3xtools\demos\demo01-config\volumes

echo Starting i3xdb (ERP) on port 8080...
start "i3xdb" %TOOLS%\i3xdb\target\release\i3xdb-server.exe --config %VOLUMES%\i3xdb\config.yaml --connection sqlite://%VOLUMES%\i3xdb\precision_cnc.db --port 8080

echo Starting i3xmt Okuma on port 8081...
start "i3xmt-okuma" %TOOLS%\i3xmt-companion\target\release\i3xmt-server.exe --broker mqtts://mqtt.russwaddell.com:8883 --device OKUMA.123456 --config %VOLUMES%\i3xmt\okuma-config.yaml --tls-insecure --port 8081

echo Starting i3xmt Mazak on port 8082...
start "i3xmt-mazak" %TOOLS%\i3xmt-companion\target\release\i3xmt-server.exe --broker mqtts://mqtt.russwaddell.com:8883 --device Mazak --config %VOLUMES%\i3xmt\mazak-config.yaml --tls-insecure --port 8082

timeout /t 3 /nobreak >nul

echo Starting i3xag (aggregator) on port 9000...
start "i3xag" %TOOLS%\i3xag\target\release\i3xag-server.exe --config %VOLUMES%\i3xag\localhost-config.yaml

echo.
echo All services started:
echo   i3xdb        http://localhost:8080
echo   i3xmt-okuma  http://localhost:8081
echo   i3xmt-mazak  http://localhost:8082
echo   i3xag        http://localhost:9000
echo.
echo Close this window or press Ctrl+C to stop.
pause
