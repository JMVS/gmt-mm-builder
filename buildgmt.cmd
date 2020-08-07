@ECHO OFF
SETLOCAL enableextensions disabledelayedexpansion
REM ## SET VERSION TO DOWNLOAD IN CASE AUTO DETECTION FAILURE
REM scrcpy
SET SCver=1.5.1
REM gnirehtet
SET RTver=2.4
REM Original ISO name (without .iso extension)
SET oISO=usb_drivers
ECHO ************************************************
ECHO ISO ^& Magisk Module Builder for Genymobile Tools 
ECHO ************************************************
ECHO.
REM ## DEFINE VARIABLES
SET errcode=0
REM # URL constructor
SET HTTPRequest=https://github.com/Genymobile/app/releases
SET GH=github.com
SET GM=Genymobile
SET SC=scrcpy
SET RT=gnirehtet
CALL SET LGM=%%HTTPRequest:%GH%^=api.%GH%/repos%%
SET LGM=%LGM%/latest
CALL SET SC32=%%HTTPRequest:%GM%^=%GM%%/SC%%%
CALL SET SC32=%%SC32:app^=%SC%%%
SET SC32=%SC32%/download/v%SCver%/%SC%-win32-v%SCver%.zip
CALL SET SC64=%%SC32:32^=64%%
SET RT64=%SC32:~0,55%v%RTver%/%RT%-rust-win64-v%RTver%.zip
CALL SET RT64=%%RT64:%SC%^=%RT%%%
REM # wget arguments
SET WGGH=--no-check-certificate --content-disposition
SET WG=-q --show-progress
REM # Batch variables
SET oDIR=main\gmt\

ECHO * Getting latest releases...
<NUL set /p= -- %SC% x32: 
CALL :LatestRelease %LGM%, %SC%, 1
ECHO %APPVer%
IF NOT "%APPVer%"=="" (CALL SET SC32=%%HTTPRequest:app/releases^=%SC%/releases/latest/download/%APPVer%%%) ELSE (ECHO error 14, using v%SCver%...)
<NUL set /p= -- %SC% x64: 
CALL :LatestRelease %LGM%, %SC%, 2
ECHO %APPVer%
IF NOT "%APPVer%"=="" (CALL SET SC64=%%SC32:32^=64%%) ELSE (ECHO error 14, using v%SCver%...)
<NUL set /p= -- %RT% x64: 
CALL :LatestRelease %LGM%, %RT%, 3
ECHO %APPVer%
IF NOT "%APPVer%"=="" (CALL SET RT64=%%HTTPRequest:app/releases^=%RT%/releases/latest/download/%APPVer%%%) ELSE (ECHO error 14, using v%RTver%...)

ECHO * Downloading...
ECHO -- %SC% x32...
tools\wget.exe %WGGH% -O%oDIR%%SC%w32.zip %SC32% %WG%
IF NOT EXIST %oDIR%%SC%w32.zip (
    SET errcode = 1
	GOTO Error
)
ECHO.
ECHO -- %SC% x64...
tools\wget.exe %WGGH% -O%oDIR%%SC%w64.zip %SC64% %WG%
IF NOT EXIST %oDIR%%SC%w64.zip (
    SET errcode = 2
	GOTO Error
)
ECHO.
ECHO -- %RT% x64...
tools\wget.exe %WGGH% -O%oDIR%%RT%w64.zip %RT64% %WG%
IF NOT EXIST %oDIR%%RT%w64.zip (
    SET errcode = 3
	GOTO Error
)
ECHO.

ECHO -- Android Debug Bridge (ADB)...
tools\wget.exe -O%oDIR%adb.zip https://dl.google.com/android/repository/platform-tools-latest-windows.zip %WG%
IF NOT EXIST %oDIR%adb.zip (
    SET errcode = 4
	GOTO Error
)
ECHO.

ECHO * Updating archives...
ECHO -- %SC% x32...
tools\7z.exe d -bso0 %oDIR%%SC%w32.zip -ir@tools\adbfiles.lst
IF %ERRORLEVEL% NEQ 0 (
    SET errcode = 5
	GOTO Error
)
ECHO -- %SC% x64...
tools\7z.exe d -bso0 %oDIR%%SC%w64.zip -ir@tools\adbfiles.lst
IF %ERRORLEVEL% NEQ 0 (
    SET errcode = 6
	GOTO Error
)
ECHO -- %RT% x64...
tools\7z.exe d -bso0 %oDIR%%RT%w64.zip -ir@tools\adbfiles.lst
IF %ERRORLEVEL% NEQ 0 (
    SET errcode = 7
	GOTO Error
)
ECHO -- Android Debug Bridge (ADB)...
tools\7z.exe d -bso0 %oDIR%adb.zip -xr@tools\adbfiles.lst
IF %ERRORLEVEL% NEQ 0 (
    SET errcode = 8
	GOTO Error
)
ECHO.

ECHO * Extracting files...
:FindISO
IF NOT EXIST original_iso\%oISO%.iso GOTO ISONFound
:ISOFound
ECHO -- Original ISO found...
GOTO ExtractISO
:ISONFound
ECHO -- WARNING: Original ISO not found (original_iso\%oISO%.iso).
ECHO    Please obtain and place ISO in the correct folder and filename.
ECHO    If you have already configured your phone
ECHO    (USB Drivers installed, USB Debugging enabled and PC authorized)
ECHO    we can try to extract the ISO directly from your phone.
ECHO    Make sure the device is connected to this computer before continuing.
ECHO    NOTE: No modification will be done to any partition.
:AskExtISO
SET /P ADBISO=Press (C) to Cancel, (E) to Extract from phone or (R) to try again [C,E,R]: 
IF /I "%ADBISO:~,1%" EQU "C" GOTO CleanUp
IF /I "%ADBISO:~,1%" EQU "R" GOTO FindISO
IF /I "%ADBISO:~,1%" EQU "E" GOTO ExtISO
SET errcode = 9
ECHO Invalid.
GOTO AskExtISO
:ExtISO
ECHO -- Pulling ISO from device...
ECHO ---- Extracting ADB...
tools\7z.exe e -bso0 %oDIR%adb.zip -oadbtmp
IF %ERRORLEVEL% NEQ 0 (
    SET errcode = 10
	GOTO Error
)
ECHO ---- Executing pulling command...
adbtmp\adb.exe pull /system/etc/usb_drivers.iso original_iso\%oISO%.iso
ECHO ---- Cleaning up...
adbtmp\adb.exe kill-server
GOTO FindISO
:ExtractISO
ECHO.
ECHO -- Extracting original ISO contents...
tools\7z.exe x -aoa -bso0 -omain original_iso\%oISO%.iso
IF %ERRORLEVEL% NEQ 0 (
    SET errcode = 11
	GOTO Error
)
ECHO -- Cleaning structure...
DEL main\autorun.inf 2>NUL
REN main\autorun.mod autorun.inf
ECHO.
ECHO * Building structure...
ECHO -- Adding files...
COPY tools\7z.* %oDIR% >NUL
ECHO -- Creating ISO...(safe to ignore "Warning: creating filesystem that does not conform to ISO-9660.")
SET errcode = 12
tools\mkisofs.exe -iso-level 2 -J -l -D -N -joliet-long -relaxed-filenames -r -V "OnePlus" -duplicates-once -quiet -o mm\system\etc\%oISO%.iso main/
IF NOT EXIST mm\system\etc\%oISO%.iso GOTO Error
ECHO.
ECHO * Building Magisk Module...
DEL mm\system\etc\placeholder 2>NUL
DEL gmt-mm.zip 2>NUL
ECHO -- Creating module...
tools\7z.exe a -mx9 -bso0 gmt-mm.zip .\mm\*
IF %ERRORLEVEL% NEQ 0 (
    SET errcode = 13
	GOTO Error
)
:CleanUp
ECHO.
ECHO * Cleaning up...
ECHO -- Erasing files...
REN main\autorun.inf autorun.mod >NUL
FOR /F "TOKENS=*" %%A IN ('DIR /A-D /B "main" ^| FINDSTR /I /V "autorun.mod"') DO DEL /Q /F "main\%%~A"
FOR /F "TOKENS=*" %%A IN ('DIR /A-D /B "%oDIR%" ^| FINDSTR /I /V "runme.cmd"') DO DEL /Q /F "%oDIR%\%%~A"
DEL /F /S /Q adbtmp 2>NUL
RD adbtmp 2>NUL
ECHO.
ECHO All done.
ECHO.
:EndScript
TIMEOUT /T 10
EXIT /B %errcode%
ENDLOCAL

:Error
ECHO error %errcode%.
ECHO Process aborted.
ECHO.
GOTO EndScript

:LatestRelease
SETLOCAL
SET LGM="%~1"
CALL SET LGM=%%LGM:app^=%~2%%%
tools\wget.exe %LGM% -Olatest.json -q
tools\jq.exe -r ".assets [%~3].name" latest.json >app.ver
ENDLOCAL
SET /p AVC= < app.ver
IF NOT x%AVC:%~2%=%==x%AVC% (SET APPVer=%AVC%) ELSE (SET "APPVer=")
DEL app.ver >NUL
DEL latest.json >NUL
SET "APPVerCheck="
EXIT /B 0
