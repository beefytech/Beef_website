@SETLOCAL EnableDelayedExpansion

for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
     set dow=%%i
     set month=%%j
     set day=%%k
     set year=%%l
)

@SET SRCDIR=..\..\..\Beef
@SET CURVER=0.43.6 (Nightly %month%/%day%/%year%)
@SET DESTNAME=BeefSetup_0_43_6__%month%_%day%_%year%.exe

PUSHD %~dp0

@if not exist install goto NoRMDIR
rmdir /S /Q pdb
rmdir /S /Q install
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
:NoRMDIR
mkdir pdb
mkdir install
IF %ERRORLEVEL% == 0 GOTO COPY
ping -n 5 127.0.0.1 > NUL
mkdir pdb
mkdir install
IF %ERRORLEVEL% NEQ 0 GOTO FAILED

:COPY

%SRCDIR%\IDE\dist\BeefBuild_d -proddir=%SRCDIR%\BeefTools\BeefPerf -config=Release
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SRCDIR%\IDE\dist\BeefBuild_d -proddir=%SRCDIR%\BeefTools\BeefCon -config=Release
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

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
xcopy %SRCDIR%\IDE\dist\BeefCon.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\BeefDbgVis.toml install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\Beef*RT*.dll install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\Beef*RT*.lib install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\TCMalloc*.dll install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\TCMalloc*.lib install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\JEMalloc*.dll install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\JEMalloc*.lib install\bin\
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
mkdir install\bin\lib
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /y %SRCDIR%\IDE\dist\lib\x86 install\bin\lib\x86\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /y %SRCDIR%\IDE\dist\lib\x64 install\bin\lib\x64\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /y %SRCDIR%\IDE\dist\shaders install\bin\shaders\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /y %SRCDIR%\IDE\dist\images install\bin\images\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /e /y %SRCDIR%\IDE\dist\llvm install\bin\llvm\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /y %SRCDIR%\IDE\dist\fonts install\bin\fonts\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
mkdir install\wasm\
xcopy /e /y %SRCDIR%\wasm\src install\wasm\src\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\wasm\build_wasm.bat install\wasm\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\wasm\fetch_wasm.bat install\wasm\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
mkdir install\__user
mkdir install\__user\bin
copy %SRCDIR%\IDE\dist\BeefConfig_install.toml install\__user\bin\BeefConfig.toml
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\userdict_install.txt install\__user\bin\userdict.txt
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\IDE\dist\en_*.* install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
mkdir install\bin\CrashDumps
echo Minidump directory > install\bin\CrashDumps\placeholder.txt
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

mkdir install\BeefManaged
copy %SRCDIR%\BeefManaged\BeefManaged.toml install\BeefManaged\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /e %SRCDIR%\BeefLibs\* install\BeefLibs\ /exclude:xexclude.txt
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /e ..\..\Samples\* install\Samples\ /exclude:xexclude.txt
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

copy %SRCDIR%\bin\curl.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\bin\tar.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\bin\vswhere.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\bin\BfAeDebug.exe install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
copy %SRCDIR%\bin\AeDebug.reg install\bin\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
xcopy /e /y %SRCDIR%\bin\Git install\bin\Git\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

@ECHO Copying PDBs...
copy dist\*.pdb pdb\
copy %SRCDIR%\IDE\dist\*.pdb pdb\
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

cd install

FOR /F "tokens=* USEBACKQ" %%F IN (`git --git-dir=..\%SRCDIR%\.git rev-parse HEAD`) DO (
SET GITVER=%%F
)
..\..\..\bin\rcedit bin\BeefIDE.exe --set-version-string "FileVersion" "%CURVER%"
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
..\..\..\bin\rcedit bin\BeefIDE.exe --set-version-string "ProductVersion" %GITVER%
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
..\..\..\bin\rcedit bin\BeefIDE_d.exe --set-version-string "FileVersion" "%CURVER%"
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
..\..\..\bin\rcedit bin\BeefIDE_d.exe --set-version-string "ProductVersion" %GITVER%
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
..\..\..\bin\rcedit bin\BeefBuild.exe --set-version-string "FileVersion" "%CURVER%"
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
..\..\..\bin\rcedit bin\BeefBuild.exe --set-version-string "ProductVersion" %GITVER%
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
..\..\..\bin\rcedit bin\BeefBuild_d.exe --set-version-string "FileVersion" "%CURVER%"
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
..\..\..\bin\rcedit bin\BeefBuild_d.exe --set-version-string "ProductVersion" %GITVER%
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

@ECHO Signing installed files...
@FOR %%i IN (bin\Beef*RT64.dll) DO (
     CALL %SRCDIR%\..\bin\sign.bat %%i
     @IF !ERRORLEVEL! NEQ 0 GOTO:EOF
)

@ECHO Cleaning up old BeefNightly files (older than 90 days)
ForFiles /p "C:\BeefNightly" /s /d -90 /c "cmd /c del /q @file"
ForFiles /p "C:\BeefNightly" /s /d -90 /c "cmd /c rmdir @file" 2> nul
@REM Clear error in case no files were deleted
cd.

@SET SRCDIR=..\..\..\Beef
@SET SYMSTORE="C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\symstore.exe"
@SET PDBSTR="C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\srcsrv\pdbstr.exe"

cd ..
@FOR %%i IN (pdb\*.pdb) DO (
	..\..\bin\source_index.py %%i
	@IF !ERRORLEVEL! NEQ 0 GOTO:EOF
)
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

%SYMSTORE% add /f dist\*.dll /s c:\BeefNightly /t Beef /compress
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SYMSTORE% add /f dist\*.exe /s c:\BeefNightly /t Beef /compress
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SYMSTORE% add /f install\bin\*.dll /s c:\BeefNightly /t Beef /compress
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SYMSTORE% add /f install\bin\*.exe /s c:\BeefNightly /t Beef /compress
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SYMSTORE% add /f pdb\*.pdb /s c:\BeefNightly /t Beef /compress
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

:ZIP
cd install
del ..\InstallData.zip
"C:\Program Files\7-Zip\7z.exe" a -r ..\InstallData.zip
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
cd ..

IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
..\..\bin\rcedit dist\Stub.exe --set-version-string "FileVersion" "%CURVER%"
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
..\..\bin\rcedit dist\Stub.exe --set-file-version "%CURVER%"
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
..\..\bin\rcedit dist\Stub.exe --set-version-string "ProductVersion" %GITVER%
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR

echo 1 > BeefSetup_Salt.txt
copy /b dist\Stub.exe + InstallData.zip + BeefSetup_Salt.txt C:\BeefNightly\%DESTNAME%
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
@call ..\..\bin\sign.bat C:\BeefNightly\%DESTNAME%
IF %ERRORLEVEL% NEQ 0 GOTO HADERROR
copy /y C:\BeefNightly\%DESTNAME% C:\BeefNightly\BeefSetup.exe

%SRCDIR%\IDE\dist\BeefBuild -run -workspace=../NightlyIndex
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

aws s3 cp c:\BeefNightly\BeefSetup.exe s3://nightly.beeflang.org --cache-control "public, max-age=600"
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
aws s3 cp c:\BeefNightly\index.html s3://nightly.beeflang.org --cache-control "public, max-age=600"
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

@REM size-only because the directory hash is really the 'unique' part
aws s3 sync --size-only c:\BeefNightly s3://nightly.beeflang.org
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