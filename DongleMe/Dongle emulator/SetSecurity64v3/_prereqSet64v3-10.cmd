@ECHO OFF

ECHO User Account Control (UAC) and TESTSIGNING ON automation script
ECHO.
ECHO.
ECHO This batch script set requirements for success install
ECHO unsigned drivers (like dongle emulators) on Microsoft x64 OS.
ECHO Required for Windows Vista x64, Windows 7 x64, Windows 8 x64
ECHO and Windows 10 x64.
ECHO.
ECHO YOU MUST RUN THIS SCRIPT AS ADMINISTRATOR
ECHO.
ECHO USAGE: Right click on script "Run as administrator"
ECHO.
ECHO Press any key to continue execution or Ctrl+C to stop
ECHO.
pause

set BCDCL32=%windir%\Sysnative\bcdedit.exe
set BCDCL64=%windir%\system32\bcdedit.exe

cd /d "%~dp0"

if "%PROCESSOR_ARCHITEW6432%"=="" goto fNative
set BCDCLWORK=%BCDCL32%
goto fMain

:fNative
set BCDCLWORK=%BCDCL64%

:fMain
ECHO.
ECHO BCDEdit.exe path is %BCDCLWORK%
if not exist %BCDCLWORK% goto NotFound

ECHO.
REM ECHO Get backup of changed registry keys...
REM REG EXPORT HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching Backup1.reg
REM REG EXPORT HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System Backup0.reg

ECHO.
ECHO Device Installation Settings...
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v SearchOrderConfig /t reg_dword /d 0 /f 

ECHO.
ECHO User Account Control (UAC) settings...
REM REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorUser /t reg_dword /d 3 /f 

REM Windows 10
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t reg_dword /d 0 /f 
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t reg_dword /d 0 /f 
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t reg_dword /d 0 /f 

ECHO.
ECHO Change testsigning settings...

REM Show Boot Configuration Data (BCD) info...
REM %BCDCLWORK%

REM This enable testsigning...
%BCDCLWORK% -set TESTSIGNING ON

REM This disable testsigning...
REM %BCDCLWORK% -set TESTSIGNING OFF

goto aExit

:NotFound
ECHO.
ECHO BCDEdit.exe not found on system. No changes made to system!!!
goto fExit

:aExit
ECHO.
ECHO Please restart computer to apply new settings!!!

:fExit
ECHO.
pause
