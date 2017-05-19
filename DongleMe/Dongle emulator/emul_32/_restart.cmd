@if not exist devcon.exe goto NotFound

@devcon restart root\rfndvbus

@goto aExit

:NotFound
REM Files missing, please use original package!!!

:aExit
@pause

