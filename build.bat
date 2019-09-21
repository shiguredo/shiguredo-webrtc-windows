docker-compose -f docker-compose.yml build -m 16G webrtc || exit /b

docker-compose -f docker-compose.yml down
docker-compose -f docker-compose.yml up --no-start webrtc || exit /b
for /f "usebackq tokens=*" %%i in (`docker-compose -f docker-compose.yml ps -q webrtc`) do @set CONTAINER=%%i
mkdir debug > NUL 2>&1
docker cp %CONTAINER%:C:\webrtc\build_debug\obj\webrtc.lib .\debug\webrtc.lib || exit /b
mkdir release > NUL 2>&1
docker cp %CONTAINER%:C:\webrtc\build_release\obj\webrtc.lib .\release\webrtc.lib || exit /b
mkdir include > NUL 2>&1
docker cp %CONTAINER%:C:\include . || exit /b
docker-compose -f docker-compose.yml down
