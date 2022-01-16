@if not exist devcon.exe goto NotFound

@regedit /s keyr
@devcon remove root\rfndvbus
@if exist %systemroot%\system32\drivers\rfndvbus.sys del %systemroot%\system32\drivers\rfndvbus.sys
@goto aExit

:NotFound
REM Files missing, please use original package!!!

:aExit
@pause

