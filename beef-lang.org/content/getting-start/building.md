+++
title = "Building from Source"
weight = 2
+++

## Building overview

Building Beef from source is not required for platforms that have binary distributions available (ie: Windows). 

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

### Building on Linux

#### Requirements

* CMake
* Python 2.7
* Git

### Build Steps

* Build LLVM with exern/llvm_build.sh
* Build Beef with bin/build.sh

The build results will be in IDE/dist