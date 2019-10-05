@SETLOCAL EnableDelayedExpansion
@SET SRCDIR=..\..\..\Beef

PUSHD %~dp0

%SRCDIR%\IDE\dist\BeefBuild -workspace=Stub -config=Debug -platform=Win64
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SRCDIR%\IDE\dist\BeefBuild -workspace=Stub -config=Release -platform=Win64
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SRCDIR%\IDE\dist\BeefBuild -workspace=StubUI -config=Debug -platform=Win64
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SRCDIR%\IDE\dist\BeefBuild -workspace=StubUI -config=Release -platform=Win64
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SRCDIR%\IDE\dist\BeefBuild -workspace=Elevated -config=Debug -platform=Win64
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SRCDIR%\IDE\dist\BeefBuild -workspace=Elevated -config=Release -platform=Win64
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SRCDIR%\IDE\dist\BeefBuild -workspace=Uninstall -config=Debug -platform=Win64
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SRCDIR%\IDE\dist\BeefBuild -workspace=Uninstall -config=Release -platform=Win64
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

call ..\..\bin\sign.bat dist\BeefInstallElevated.exe
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
call ..\..\bin\sign.bat dist\BeefUninstall.exe
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
@REM call ..\..\bin\sign.bat dist\Stub.exe
@REM @IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

GOTO :DONE

:HADERROR
@ECHO =================FAILED=================
POPD
EXIT /b %ERRORLEVEL%

:DONE
@ENDLOCAL
POPD
EXIT /B 0