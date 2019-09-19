@SETLOCAL EnableDelayedExpansion
@ECHO OFF
@SET SRCDIR=..\..\..\Beef
@SET SYMSTORE="C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\symstore.exe"
@SET PDBSTR="C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\srcsrv\pdbstr.exe"

@FOR %%i IN (%SRCDIR%\IDE\dist\*.pdb) DO (	
	..\..\bin\source_index.py %%i
	@IF !ERRORLEVEL! NEQ 0 GOTO:EOF
)
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR

%SYMSTORE% add /f %SRCDIR%\IDE\dist\*.dll /s c:\BeefSyms /t Beef /compress 
@IF !ERRORLEVEL! NEQ 0 GOTO HADERROR
%SYMSTORE% add /f %SRCDIR%\IDE\dist\*.pdb /s c:\BeefSyms /t Beef /compress 
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