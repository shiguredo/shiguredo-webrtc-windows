docker-compose -f docker-compose.yml build -m 16G webrtc || exit /b

docker-compose -f docker-compose.yml down
docker-compose -f docker-compose.yml up --no-start webrtc || exit /b
for /f "usebackq tokens=*" %%i in (`docker-compose -f docker-compose.yml ps -q webrtc`) do @set CONTAINER=%%i
docker cp %CONTAINER%:C:\webrtc\build\obj\webrtc.lib .\webrtc.lib || exit /b
docker-compose -f docker-compose.yml down
