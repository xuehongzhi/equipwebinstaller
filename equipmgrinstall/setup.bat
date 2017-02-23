@echo off
@setlocal EnableDelayedExpansion 
cd /d %~dp0
SET BuildDir=%~dp0
SET BuildDir=%BuildDir:~0,-1%
if not exist  %WINDIR%\system32\nssm.exe (
  copy nssm.exe %WINDIR%\system32\nssm.exe
)
del /s/q nssm.exe

set serv_name=equipmgrweb
set status=0 
nssm status %serv_name%
if %status% EQU 0 (
   %WINDIR%\system32\nssm install %serv_name% "waitress-serve.exe" "--port=8001 main.wsgi:application"
   %WINDIR%\system32\nssm set %serv_name% AppDirectory "%BuildDir%"
)

set reboot = false
Echo wscript.Echo MsgBox ("安装程序要重启系统，是否重启", 36, "提示")>tmp.vbs
For /f %%i in ('cscript /nologo tmp.vbs') do If %%i==6 set reboot=true
Del /q tmp.vbs
if "%reboot%" == "true" (
   shutdown /r
)
start /b "" cmd /c del "%~f0"&exit /b
goto end
:end
