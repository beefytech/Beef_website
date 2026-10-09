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

* Microsoft C++ build tools for Visual Studio 2017 or later. You can install just Microsoft Visual C++ Build Tools or the entire Visual Studio suite from https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022.
* Platform Toolset 141 (VS2017)
* Windows SDK 10.0.17763.0
* CMake 3.15 or newer
* Python 3.6 or newer
* Git command line tools

#### Build Steps
* Execute bin/build.bat

The build results will be in IDE/dist

---

### Building on Linux and macOS

#### Requirements

* CMake 3.15 or newer
* LLVM 22.1 (development package, e.g. `llvm-22-dev`)
* A C/C++ compiler (gcc or clang), `make`, and Git
* Optional: Ninja, for faster builds

Additional requirements for building the IDE (Linux):

* SDL3 development package (e.g. `libsdl3-dev`). The IDE loads `libSDL3.so` at runtime, which is normally provided by the development package.
* LLDB 22 development package and `lldb-server` (e.g. `liblldb-22-dev` and `lldb-22`) for debugging support. If LLDB isn't found, the IDE still builds but without a debugger. If `lldb-server` is installed in an unusual location, set `LLDB_DEBUGGER_PATH`.

### Build Steps

* Build the command-line tools with `bin/build.sh`
* Build the command-line tools and the IDE with `bin/build.sh ide`

The build results will be in IDE/dist, and the IDE can be run with `IDE/dist/BeefIDE`. The build also runs the compiler test suite.

Other options: `bin/build.sh clean` removes previous build output, and `no_ffi` disables FFI support.

To install, run `bin/install.sh` (installs to /opt/BeefLang by default, or pass a destination path). The IDE is included if it was built.

The IDE is supported on Windows and Linux. On macOS, only the command-line tools such as BeefBuild are currently supported.