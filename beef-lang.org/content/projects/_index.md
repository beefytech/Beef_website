+++
title = "Projects and Workspaces"
alwaysopen = true
weight = 41
+++

## General macros

- $(BeefPath) - Beef install path
- $(Slash str) - Slashes the input string
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
