@SETLOCAL EnableDelayedExpansion

PUSHD %~dp0

@ECHO OFF
@SET SRCDIR=..\..\..\Beef
@SET SYMSTORE="C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\symstore.exe"
@SET PDBSTR="C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\srcsrv\pdbstr.exe"

@FOR %%i IN (pdb\*.pdb) DO (	
	..\..\bin\source_index.py %%i
	@IF !ERRORLEVEL! NEQ 0 GOTO:EOF
)
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

%SYMSTORE% add /f install\bin\*.dll /s c:\BeefSyms /t Beef /compress 
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SYMSTORE% add /f pdb\*.pdb /s c:\BeefSyms /t Beef /compress 
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

@REM size-only because the directory hash is really the 'unique' part
aws s3 sync --size-only c:\BeefSyms s3://symbols.beeflang.org
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