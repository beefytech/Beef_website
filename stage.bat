@SETLOCAL EnableDelayedExpansion
PUSHD %~dp0

aws s3 sync public s3://stage.beeflang.org
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