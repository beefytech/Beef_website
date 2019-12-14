+++
title = "Platforms"
alwaysopen = true
weight = 42
+++

### Tier 1 platforms:
The following platform names are natively recognized by Beef, and Beef can act as a complete build system for these platforms. These platforms do not allow cross-compilation between them, as they all require access to system-native linkers and libraries. 

- Win32 - Windows x86
- Win64 - Windows x64
- Linux32 - Linux x86
- Linux64 - Linux x64
- macOS - macOS x64

### Tier 2 platforms:
These are cross-platform targets denoted by LLVM target triples. For these platforms, the Beef compiler is invoked by some exterior build process, whereby it generates a lib file which can then be linked into the final target by the exterior build process. The Beef runtime must have already been compiled ahead of time for the given platform and also linked in through the exterior build process.

- iOS - (early alpha) Supported architectures include AArch64 and x64-based simulators. The Beef runtime can be built on macOS via bin/build_ios.sh.
- Android - (early alpha) Supported architectures include AArch64, ARM7, and x86/x64-based simulators. The Beef runtime can be built on Windows via bin/build_android.bat.

### Tier 3 platforms:
Like Tier 2 platforms, these platforms are denoted by LLVM target triples, but there's no built-in Beef runtime support. While the Beef compiler can generate machine code for these architectures, there may be missing symbols from the Beef runtime, depending on which parts of corlib were used. This list can be trivially expanded to include additional LLVM-supported targets, but expanding this list has limited benefit vs. expanding the Tier 2 and Tier 1 lists.

- arm7 - arm7-*
- aarch64 - aarch64-*, arm64-*
- x86 - x86-*, i686-*
- x64 - x86_64-* 