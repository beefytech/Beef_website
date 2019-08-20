+++
title = "The Basics"
weight = 1
+++

## Compilation Model

The Beef compilation context is a 'workspace', which consists of multiple 'projects'. A project can be an executable target or a library. Sources are parsed, passing through a limited preprocessor, and a collection of object files are build for types and methods which are referenced on demand. The workspace-wide compilation model allows per-workspace settings to affect compilations of specific groups of methods or types, modifiying preprocessor and compilation settings (ie: optimization level) of code contained in referenced libraries. Multiple linkers are supported, including system linkers and the LLVM linker which can be used for link-time optimimied builds (LLVM LTO/ThinLTO).

Beef supports multiple compiler backends, including LLVM and a custom "enhanced debug" (Og+) backend which performing some code optimizations which do not adversely impact debuggability and has some improvements in emitted debug information over LLVM. 
