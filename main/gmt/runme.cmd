@ECHO OFF
SET GMTVer=0.1
SET errcode=1
SETLOCAL enableextensions disabledelayedexpansion
REM BATCH author: J_M_V_S at xda-developers.com
TITLE Genymobile tools for OP3T
ECHO **********************************************************
ECHO Genymobile tools for OP3T by J_M_V_S at xda-developers.com
ECHO **********************************************************
ECHO.
ECHO Used parts of the 7-Zip program (www.7-zip.org)
ECHO 7-Zip is licensed under the GNU LGPL license 
ECHO.
ECHO scrcpy ^& gnirehtet by Romain Vimont
ECHO Copyright (C) 2018 Genymobile
ECHO.
ECHO Initializing...
<NUL SET /p dummy=- Setting variables...
SET errcode=4
SET basDir=%~dp0
rem SET srcDir=%basDir%win%OS%
SET desDir=%LOCALAPPDATA%\gmt
SET build=%desDir%\version.txt
rem SET ZExt=%basDir%7z.exe e -aoa -bd -bso0 -r0 -o%desDir% %basDir%
ECHO OK.
<NUL SET /p dummy=- Checking running instances...
SET errcode=2
tasklist /fi "imagename eq scrcpy-noconsole.exe" |find ":" > nul
IF %ERRORLEVEL% EQU 1 GOTO Error
tasklist /fi "imagename eq scrcpy.exe" |find ":" > nul
IF %ERRORLEVEL% EQU 1 GOTO Error
ECHO OK.
tasklist /fi "imagename eq adb.exe" |find ":" > nul
IF %ERRORLEVEL% EQU 1 CALL :KillADB
<NUL SET /p dummy=- Quering architecture type...
SET errcode=3
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && SET OS=32 || SET OS=64
ECHO OK (x%OS%).
<NUL SET /p dummy=- Checking version...
SET errcode=5
IF NOT EXIST %build% GOTO nexDir
SET /P curGMTVer=<%build%
IF %curGMTVer% GEQ %GMTVer% GOTO extDir
<NUL SET /p dummy=updating...
DEL %build% 2>NUL
:nexDir
ECHO OK.
<NUL SET /p dummy=- Checking destination...
SET errcode=6
IF NOT EXIST %desDir% mkdir %desDir% >NUL
ECHO %GMTVer% > %build%
ECHO OK.
<NUL SET /p dummy=- Extracting x%OS% files to temp folder...
SET errcode=7
rem %ZExt%scrcpyw%OS%.zip *.*
%basDir%7z.exe e %basDir%scrcpyw%OS%.zip *.* -o%desDir% -aoa -bso0 -r0
IF %ERRORLEVEL% GEQ 2 GOTO Error
ECHO OK.
<NUL SET /p dummy=- Extracting common files to temp folder...
SET errcode=8
rem %ZExt%adb.zip *.* >NUL 2>&1
%basDir%7z.exe e %basDir%adb.zip *.* -o%desDir% -aoa -bso0 -r0
IF %ERRORLEVEL% GEQ 2 GOTO Error
:extDir
ECHO OK.
<NUL SET /p dummy=- Checking extracted files...
SET errcode=9
FOR %%a IN (adb.exe AdbWinApi.dll AdbWinUsbApi.dll avcodec-58.dll avformat-58.dll avutil-56.dll scrcpy-noconsole.exe scrcpy-server.jar scrcpy.exe SDL2.dll swresample-3.dll) DO (IF NOT EXIST %desDir%\%%a GOTO Error)
ECHO OK.

:Exec
ECHO.
ECHO Executing...
<NUL SET /p dummy=- Running scrcpy (no console), please wait...
REM SET errcode=11
start /D %desDir% scrcpy-noconsole.exe
rem CD %desDir%
rem start scrcpy-noconsole.exe
rem CD %basDir%
:Exit
EXIT /B %errorcode%

:Error
ECHO error.
ECHO.
ECHO Program exists with error number: %errcode%.
ECHO.
PAUSE
GOTO Exit

:KillADB
<NUL SET /p dummy=- Killing other ADB instances...
SET errcode=10
for /f "usebackq skip=1 tokens=*" %%i in (`wmic process where "name='adb.exe'" get ExecutablePath ^| findstr /r /v "^$"`) do (SET ADB=%%i)
%ADB% kill-server
IF %ERRORLEVEL% NEQ 0 <NUL SET /p dummy=warning %errcode% NOT 
ECHO OK.
GOTO :EOF
