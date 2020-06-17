+++
title = "Projects and Workspaces"
alwaysopen = true
weight = 41
+++

## General macros

- $(BeefPath) - Beef install path
- $(Slash str) - Slashes the input string
- $(Var varName) - Contents of variable 'varName'
- $(VSToolPath) - Visual Studio tool path
- $(VSToolPath_x64) - Visual Studio tool path for x64
- $(VSToolPath_x86) - Visual Studio tool path for x86

## Workspace macros

- $(Configuration) - Currently selected build configuration
- $(Platform) - Currently select selected build platform
- $(WorkspaceDir) - Workspace directory

## Project macros

- $(Arguments) - Command arguments for Debugging
- $(BuildDir) - Build directory, contains object files and other build artifacts
- $(LinkFlags) - The default link flags
- $(ProjectDir) - Directory that contains this project
- $(ProjectName) - Project name
- $(TargetDir) - Directory of the target binary
- $(TargetPath) - Target binary that this project configuration builds
- $(WorkingDir) - Working directory for Debugging

## Prebuild/Postbuild Commands
- CopyFilesIfNewer(srcPath, destPath) - Copies files only if the date is newer. Recursive and works with wildcards.
- CopyToDependents(srcPath) - For any projects dependent on this library, copy this files to their target directory.
- CreateFile(path, text) - Writes 'text' to file 'path'
- DeleteFile(path) - Deletes file 'path'
- DelTree(path) - Deletes path recursively
- Echo(text) - Writes 'text' to the Output window or console
- ReadFile(path, varName) - Reads the contents of file 'path' and assigns it to variable 'varName'
- RenameFile(srcPath, destPath) - Renames file 'srcPath' to 'destPath'
- SetVal(varName, value) - Sets variable 'varName' to 'value'
- ShowFile(path) - Opens file 'path' in the IDE editor
- Sleep(timeMS) - Delays for timeMS milliseconds