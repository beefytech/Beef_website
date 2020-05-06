@SETLOCAL EnableDelayedExpansion
@SET SRCDIR=..\..\..\Beef
@SET CURVER=0.42.3
@SET DESTNAME=BeefSetup_0_42_3.exe

PUSHD %~dp0

@if not exist install goto NoRMDIR
rmdir /S /Q pdb
rmdir /S /Q install
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
:NoRMDIR
mkdir pdb
mkdir install
IF %ERRORLEVEL% == 0 GOTO COPY
timeout 2
mkdir pdb
mkdir install
IF %ERRORLEVEL% NEQ 0 GOTO FAILED

:COPY
xcopy dist\BeefInstallElevated.exe install\__installer\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy dist\BeefInstallUI.dll install\__installer\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy dist\BeefySysLib64.dll install\__installer\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy dist\license.txt install\__installer\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /e dist\images\* install\__installer\images\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /e dist\shaders\* install\__installer\shaders\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /e dist\sounds\* install\__installer\sounds\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

xcopy %SRCDIR%\LICENSE.TXT install\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy %SRCDIR%\LICENSES.TXT install\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy %SRCDIR%\readme.TXT install\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy dist\BeefUninstall.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy dist\BeefInstallElevated.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy %SRCDIR%\IDE\dist\BeefIDE.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy %SRCDIR%\IDE\dist\BeefIDE_d.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy %SRCDIR%\IDE\dist\BeefBuild.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy %SRCDIR%\IDE\dist\BeefBuild_d.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy %SRCDIR%\IDE\dist\BeefPerf.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\BeefDbgVis.toml install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\Beef*RT*.dll install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\Beef*RT*.lib install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\Beef*Dbg*.dll install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\Beef*Dbg*.lib install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\BeefySysLib64.dll install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\BeefySysLib64_d.dll install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\IDEHelper64.dll install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\IDEHelper64_d.dll install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /y %SRCDIR%\IDE\dist\shaders install\bin\shaders\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /y %SRCDIR%\IDE\dist\images install\bin\images\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /e /y %SRCDIR%\IDE\dist\llvm install\bin\llvm\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /y %SRCDIR%\IDE\dist\fonts install\bin\fonts\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\BeefConfig_install.toml install\bin\BeefConfig.toml
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\userdict_install.txt install\bin\userdict.txt
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\en_*.* install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
mkdir install\bin\CrashDumps
echo Minidump directory > install\bin\CrashDumps\placeholder.txt
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

xcopy /e %SRCDIR%\BeefLibs\* install\BeefLibs\ /exclude:xexclude.txt
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /e ..\..\Samples\* install\Samples\ /exclude:xexclude.txt
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

copy %SRCDIR%\bin\vswhere.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\bin\BfAeDebug.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\bin\AeDebug.reg install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

@IF "%1" NEQ "rel" goto SETVER
@ECHO Copying PDBs...
copy dist\*.pdb pdb\
copy /y %SRCDIR%\IDE\dist\*.pdb pdb\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
:SETVER

cd install

FOR /F "tokens=* USEBACKQ" %%F IN (`git --git-dir=..\%SRCDIR%\.git rev-parse HEAD`) DO (
SET GITVER=%%F
)
..\..\..\bin\rcedit bin\BeefIDE.exe --set-version-string "ProductVersion" %GITVER%
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
..\..\..\bin\rcedit bin\BeefIDE_d.exe --set-version-string "ProductVersion" %GITVER%
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
..\..\..\bin\rcedit bin\BeefBuild.exe --set-version-string "ProductVersion" %GITVER%
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
..\..\..\bin\rcedit bin\BeefBuild_d.exe --set-version-string "ProductVersion" %GITVER%
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

@IF "%1" NEQ "rel" goto ZIP
@ECHO Storing symbols...
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
@call ..\storesyms.bat
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR

:ZIP
cd install
del ..\InstallData.zip
"C:\Program Files\7-Zip\7z.exe" a -r ..\InstallData.zip
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
cd ..

IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
..\..\bin\rcedit dist\Stub.exe --set-version-string "FileVersion" %CURVER%
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
..\..\bin\rcedit dist\Stub.exe --set-file-version %CURVER%
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
..\..\bin\rcedit dist\Stub.exe --set-version-string "ProductVersion" %GITVER%
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR

@IF "%1" NEQ "rel" goto SETUP_NOREL
aws s3api head-object --bucket www.beeflang.org --key setup/%DESTNAME%
IF %ERRORLEVEL% NEQ 0 GOTO SETUP_NO_PROD_EXIST
@ECHO ERROR: File %DESTNAME% has already been submitted to production!
exit /b 1
:SETUP_NO_PROD_EXIST
@mkdir ..\..\public\setup\
@REM ALLOW TO FAIL ^
@echo Creating installer at ..\..\public\setup\%DESTNAME%
copy /b dist\Stub.exe + InstallData.zip ..\..\public\setup\%DESTNAME%
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
..\..\bin\sign.bat ..\..\public\setup\%DESTNAME%
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR

@git hash-object ..\..\public\setup\%DESTNAME%
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
GOTO :DONE

:SETUP_NOREL
copy /b dist\Stub.exe + InstallData.zip BeefSetup.exe
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
GOTO :DONE

:HADERROR
@ECHO =================FAILED=================
POPD
EXIT /b %ERRORLEVEL%

:DONE
@ENDLOCAL
POPD
EXIT /B 0