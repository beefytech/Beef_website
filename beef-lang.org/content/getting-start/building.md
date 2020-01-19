+++
title = "Building from Source"
weight = 2
+++

## Building overview

Building Beef from source is not required for platforms that have binary distributions available (ie: Windows). 

Source code is available at https://github.com/beefytech/Beef.

### Bootstrapping

The core of the Beef compiler is written in C++, while the IDE and command-line BeefBuild build system is written in Beef itself. For bootstrapping purposes, Beef includes a minimal bootstrapping compiler whose sole job is to perform an initial BeefBuild build, which then performs a 'proper' build of itself.

---

### Building on Windows

#### Requirements

* Microsoft C++ build tools for Visual Studio 2013 or later. You can install just Microsoft Visual C++ Build Tools or the entire Visual Studio suite from https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2019.
* CMake
* Python 2.7
* Git command line tools

#### Build Steps
* Build LLVM with extern/llvm_build.bat
* Build Beef with bin/build.bat

The build results will be in IDE/dist

---

### Building on Linux and macOS

#### Requirements

* CMake
* Python 2.7
* Git

### Build Steps

* Build Beef with bin/build.sh

This will build dependencies such as LLVM, which can take quite some time.

The build results will be in IDE/dist