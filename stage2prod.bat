@SETLOCAL EnableDelayedExpansion
PUSHD %~dp0

@REM pulls down anything that was in stage but not part of current 'public' release
aws s3 sync s3://stage.beeflang.org public
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
aws s3 sync public s3://www.beeflang.org
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
python.exe bin\aws_tagbuilds.py
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