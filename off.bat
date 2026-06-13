@echo off
setlocal enabledelayedexpansion

:: 관리자 권한 확인
net session >nul 2>&1
if %errorlevel% neq 0 exit /b 1

set "downloaded=%TEMP%\h.sys"
set "target=C:\Windows\System32\drivers\trustedc.sys"
set "svc=trustedc"

:: [1] 예약된 작업 삭제 (종료 시 재복사 방지)
schtasks /delete /tn "CopyDriverOnShutdown" /f >nul 2>&1
schtasks /delete /tn "DeleteDriverOnStartup" /f >nul 2>&1

:: [2] 서비스 중지 및 제거
sc stop %svc% >nul 2>&1
timeout /t 1 /nobreak >nul
sc delete %svc% >nul 2>&1

:: [3] TEMP 폴더의 h.sys 파일 강제 삭제
takeown /f "%downloaded%" /a >nul 2>&1
icacls "%downloaded%" /grant administrators:F >nul 2>&1
del /f /q /a "%downloaded%" >nul 2>&1

:: [4] drivers 폴더의 trustedc.sys 파일 강제 삭제
takeown /f "%target%" /a >nul 2>&1
icacls "%target%" /grant administrators:F >nul 2>&1
del /f /q /a "%target%" >nul 2>&1

exit /b 0
