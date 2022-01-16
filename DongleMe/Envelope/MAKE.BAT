@echo off
\masm32\bin\rc /v dongleme_dlg.rc
\masm32\bin\ml.exe /c /coff /Cp /nologo dongleme_envelope.asm
\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /OUT:DongleMe.exe dongleme_envelope.obj dongleme_dlg.res
del dongleme_dlg.res
del dongleme_envelope.obj
pause