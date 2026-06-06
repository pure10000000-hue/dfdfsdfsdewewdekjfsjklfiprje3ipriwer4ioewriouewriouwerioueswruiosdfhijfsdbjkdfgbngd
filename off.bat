@echo off
setlocal enabledelayedexpansion

:: 관리자 권한 확인 (권한이 없으면 즉시 종료)
net session >nul 2>&1
if %errorlevel% neq 0 exit /b 1

:: 경로 및 서비스 이름 설정
set "downloaded=%TEMP%\h.sys"
set "target=C:\Windows\System32\drivers\trustedc.sys"
set "svc=trustedc"

:: [1] 커널 드라이버 서비스 중지 및 삭제
sc stop %svc% >nul 2>&1
timeout /t 1 /nobreak >nul
sc delete %svc% >nul 2>&1

:: [2] 예약된 작업(Scheduled Tasks) 삭제
schtasks /delete /tn "CopyDriverOnShutdown" /f >nul 2>&1
schtasks /delete /tn "DeleteDriverOnStartup" /f >nul 2>&1

:: [3] 드라이버 파일 권한 기본값 복구 및 제거
:: 파일이 사용 중이거나 잠겨있을 수 있으므로 강제 삭제 시도
if exist "%target%" (
    takeown /f "%target%" /a >nul 2>&1
    icacls "%target%" /grant administrators:F >nul 2>&1
    del /f /q "%target%" >nul 2>&1
)

:: 임시 다운로드 파일 제거
if exist "%downloaded%" (
    del /f /q "%downloaded%" >nul 2>&1
)

exit /b 0