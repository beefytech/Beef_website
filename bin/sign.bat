@ECHO OFF
PUSHD %~dp0
if EXIST "sign_local.bat" (
	sign_local.bat %1
)
POPD

@SETLOCAL EnableDelayedExpansion
@SET BINPATH=C:\Program Files (x86)\Windows Kits\10\bin\10.0.17763.0\x64

:DOSIGN
@ECHO Signing %1...
"%BINPATH%\signtool" sign /tr http://timestamp.comodoca.com /td sha256 /fd sha256 /a %1