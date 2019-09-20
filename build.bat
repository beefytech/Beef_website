@SETLOCAL EnableDelayedExpansion
PUSHD %~dp0

cd www.beef-lang.org
..\bin\hugo
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
cd ..\beef-lang.org
..\bin\hugo
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
cd ..

@MKDIR beef-lang.org\static\doxygen
@MKDIR beef-lang.org\static\doxygen\corlib
@REM ALLOW TO FAIL ^

..\Beef\IDE\dist\BeefBuild -workspace=..\Beef\BeefTools\DocPrep
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
@REM ..\Beef\IDE\dist\DocPrep ..\Beef\BeefLibs\corlib\src temp
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
cd bin
doxygen corlib.cfg
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
cd ..

GOTO :DONE

:HADERROR
@ECHO =================FAILED=================
POPD
EXIT /b %ERRORLEVEL%

:DONE
@ENDLOCAL
POPD
EXIT /B 0