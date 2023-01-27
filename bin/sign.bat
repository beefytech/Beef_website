@ECHO OFF
if EXIST "%~dp0\sign_local.bat" (
	"%~dp0\sign_local.bat" %1
)

@SETLOCAL EnableDelayedExpansion
@SET BINPATH=C:\Program Files (x86)\Windows Kits\10\bin\10.0.17763.0\x64

:DOSIGN
@ECHO Signing %1...
"%BINPATH%\signtool" sign /tr http://timestamp.sectigo.com /td sha256 /fd sha256 /a %1