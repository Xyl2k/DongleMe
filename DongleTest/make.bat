@echo off
\masm32\bin\rc /v dongleTest_dlg.rc
\masm32\bin\ml.exe /c /coff /Cp /nologo dongleTest.asm
\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /OUT:Dongle_Test.exe dongleTest.obj dongleTest_dlg.res
del dongleTest_dlg.res
del dongleTest.obj
pause