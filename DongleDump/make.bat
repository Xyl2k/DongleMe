@echo off
\masm32\bin\rc /v dongleDump_dlg.rc
\masm32\bin\ml.exe /c /coff /Cp /nologo dongleDump.asm
\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /OUT:Dongle_Dump.exe dongleDump.obj dongleDump_dlg.res
del dongleDump_dlg.res
del dongleDump.obj
pause