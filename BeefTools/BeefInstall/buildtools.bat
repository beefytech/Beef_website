@SETLOCAL EnableDelayedExpansion
@SET SRCDIR=..\..\..\Beef

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

GOTO :DONE

:HADERROR
@ECHO =================FAILED=================
POPD
EXIT /b %ERRORLEVEL%

:DONE
@ENDLOCAL
POPD
EXIT /B 0