@if not exist devcon.exe goto NotFound
@if not exist keys goto NotFound
@if not exist rfndvbus.cat goto NotFound
@if not exist rfndvbus.inf goto NotFound
@if not exist rfndvbus.sys goto NotFound

rem @regedit /s keysa

@REG QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\R4ndKeys\Dumps\5F0E5CA0 /v Signature > NUL

@IF %errorlevel%==0 GOTO DoInstall
@IF %errorlevel%==1 GOTO SkipInstall

:DoInstall
@echo Install in progress...
@echo Please wait...
@regedit /s keys
rem @regedit /s keysd
@devcon remove root\rfndvbus
@devcon install rfndvbus.inf root\rfndvbus
@goto aExit

:SkipInstall
@echo.
@echo Emulator activation is missing. Do you forget your security . reg???
@echo Skipping installation!!!
@goto aExit

:NotFound
@echo.
@echo Files missing, please use original package!!!
@goto aExit

:aExit
@pause
