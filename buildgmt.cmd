@ECHO OFF
SETLOCAL enableextensions disabledelayedexpansion
REM ## SET VERSION TO DOWNLOAD
REM scrcpy
SET SCver=1.3
REM gnirehtet
SET RTver=2.3
REM Original ISO name (without .iso extension)
SET oISO=usb_drivers
ECHO ************************************************
ECHO ISO ^& Magisk Module Builder for Genymobile Tools 
ECHO ************************************************
ECHO.
REM ## DEFINE VARIABLES
SET errcode=0
SET GM=https://github.com/Genymobile/
SET SC=scrcpy
SET RT=gnirehtet
SET GHR=/releases/download/
SET SC32=%GM%%SC%%GHR%v%SCver%/%SC%-win32-v%SCver%.zip
SET SC64=%GM%%SC%%GHR%v%SCver%/%SC%-win64-v%SCver%.zip
SET RT64=%GM%%RT%%GHR%v%RTver%/%RT%-rust-win64-v%RTver%.zip
SET WGGH=--no-check-certificate --content-disposition
SET WG=-q --show-progress
SET oDIR=main\gmt\
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
SET /P ADBISO=Press (C) to Cancel, (E) to Extract from phone or (R) to try again [C,E,R): 
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
ECHO autorun.inf >tmp.lst
tools\7z.exe x -aoa -bso0 -omain original_iso\%oISO%.iso -ir@tmp.lst
IF %ERRORLEVEL% NEQ 0 (
    SET errcode = 11
	GOTO Error
)
DEL tmp.lst
ECHO.
ECHO * Building structure...
ECHO -- Adding files...
COPY tools\7z.* %oDIR% >NUL
ECHO -- Creating ISO...
SET errcode = 12
tools\mkisofs.exe -udf -r -duplicates-once -quiet -o mm/system/etc/%oISO%.iso main/
IF NOT EXIST %oISO%.iso GOTO Error
ECHO.
ECHO * Building Magisk Module...
tools\7z.exe a -mx9 gmt-mm.zip mm\*
IF %ERRORLEVEL% NEQ 0 (
    SET errcode = 12
	GOTO Error
)
:CleanUp
ECHO * Cleaning up...
ECHO -- Erasing files...
FOR /F "TOKENS=*" %%A IN ('DIR /A-D /B "main" ^| FINDSTR /I /V "autorun.inf"') DO DEL /Q /F "main\%%~A"
FOR /F "TOKENS=*" %%A IN ('DIR /A-D /B "%oDIR%" ^| FINDSTR /I /V "runme.cmd"') DO DEL /Q /F "%oDIR%\%%~A"
DEL /F /S /Q adbtmp >NUL
RD adbtmp >NUL
ECHO.
ECHO All done.
ECHO.
:Salir
TIMEOUT /T 10
EXIT /B %errcode%

:Error
ECHO error %errcode%.
ECHO Process aborted.
GOTO Salir
