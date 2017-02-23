@echo off
@setlocal EnableDelayedExpansion
set MajorVersion=1
set MinorVersion=0
set Version3=1
set SVNVersion=
set equipmgrweb=equipmgrweb

cd /d %~dp0
del /s /Q equipmgrinstall\equipmgr 
del /s /Q equipmgrinstall\staticfiles
del /s /Q equipmgrinstall\main

call :getsvn

for /f "delims=" %%i in ('dir /a /b /s "equipmgrinstall"') do (
set dirname=%%i
set dirname=!dirname:out=!
set dirname=!dirname:nssm.exe=!
set dirname=!dirname:setup.bat=!
set dirname=!dirname:sfx.conf=!
if "!dirname!"=="%%i" (
    del /s/q %%i
)
)

xcopy /YIE %equipmgrweb% equipmgrinstall 2>nul
cd /d equipmgrinstall
call d:\pyenv\py34\pywithdj\scripts\activate
python -m compileall .
move main\settings.py main\settings
call :extractpyc
move main\settings main\settings.py
call :collectstatic
D:\cygwin64\bin\sed -i 's/DEBUG = True/DEBUG = False/' main\settings.py
D:\cygwin64\bin\sed -i "s/'HOST': 'devserv'/'HOST': 'localhost'/" main\settings.py
echo|set /p=#version=%MajorVersion%.%MinorVersion%.%Version3%.!SVNVersion!>>main\settings.py


set rarpath="d:\Program Files (x86)\WinRAR"
cd /d %1
set FILENAME=out\equipmgrinstaller-%MajorVersion%.%MinorVersion%.%Version3%.!SVNVersion!.exe
@echo %FILENAME%
%rarpath%\Rar.exe a -r -sfx -m5 -z"sfx.conf" %FILENAME% equipmgr main staticfiles manage.py run.bat requirements.txt nssm.exe setup.bat

goto :end

:getsvn
svn update %equipmgrweb%
for /F "eol=- usebackq tokens=1,2,* delims=r|" %%i in (`svn log -l 1 %equipmgrweb%`) do (
    if "!SVNVersion!" ==  "" (
	  set SVNVersion=%%i
	)
)
goto :eof

:collectstatic
python manage.py collectstatic  --noinput
rmdir /s/q static
rmdir /s/q equipmgr\static
rmdir /s/q main\__pycache__
goto :eof

:extractpyc
for /f "delims=" %%i in ('dir /ad /b /s "."') do (
if exist "%%i\\__pycache__" (
set dirname=%%i
set dirname=!dirname:migrations=!
if "!dirname!"=="%%i" (
  for /f "delims=." %%k in ('dir /a-d /b  *.pyc "%%i\\__pycache__"') do (
	 set f="%%i\\__pycache__\\%%k.cpython-34.pyc"
	 if exist !f! (
	 	copy /Y !f! "%%i\\%%k.pyc"> nul 2>nul
	 )	 
  )
  del /f /q "%%i\\*.py"> nul 2>nul

)
  rmdir /s /q "%%i\\__pycache__"> nul 2>nul
)
)
del /f /q main\settings.pyc> nul 2>null
goto :eof


:end
