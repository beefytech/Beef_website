..\..\..\Beef\IDE\dist\BeefBuild -config=Debug
..\..\..\Beef\IDE\dist\BeefBuild -config=Release

@ECHO TIMING: Beef debug
..\..\..\Beef\bin\RunWithStats build\Debug_Win64\NBody\NBody.exe 50000000
..\..\..\Beef\bin\RunWithStats build\Debug_Win64\NBody\NBody.exe 50000000
..\..\..\Beef\bin\RunWithStats build\Debug_Win64\NBody\NBody.exe 50000000

@ECHO TIMING: Beef release
..\..\..\Beef\bin\RunWithStats build\Release_Win64\NBody\NBody.exe 50000000
..\..\..\Beef\bin\RunWithStats build\Release_Win64\NBody\NBody.exe 50000000
..\..\..\Beef\bin\RunWithStats build\Release_Win64\NBody\NBody.exe 50000000

"c:\Program Files\LLVM\bin\clang.exe" nbody.cpp -O0 -o nbody_cpp.exe
@ECHO TIMING: C++ debug
..\..\..\Beef\bin\RunWithStats nbody_cpp.exe 50000000
..\..\..\Beef\bin\RunWithStats nbody_cpp.exe 50000000
..\..\..\Beef\bin\RunWithStats nbody_cpp.exe 50000000

"c:\Program Files\LLVM\bin\clang.exe" nbody.cpp -O3 -g -o nbody_cpp.exe
@ECHO TIMING: C++ release
..\..\..\Beef\bin\RunWithStats nbody_cpp.exe 50000000
..\..\..\Beef\bin\RunWithStats nbody_cpp.exe 50000000
..\..\..\Beef\bin\RunWithStats nbody_cpp.exe 50000000

