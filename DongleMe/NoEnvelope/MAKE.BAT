@echo off
\masm32\bin\rc /v dongleme_dlg.rc
\masm32\bin\ml.exe /c /coff /Cp /nologo dongleme.asm
\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /OUT:xyl-dongleme1.exe dongleme.obj dongleme_dlg.res
del dongleme_dlg.res
del dongleme.obj
pause