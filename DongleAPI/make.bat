@echo off
\masm32\bin\rc /v dongle_api_dlg.rc
\masm32\bin\ml.exe /c /coff /Cp /nologo dongleapi.asm
\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /OUT:dongle_API.exe dongleapi.obj dongle_api_dlg.res
del dongle_api_dlg.res
del dongleapi.obj
pause