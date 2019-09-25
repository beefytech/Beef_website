+++
title = "The Basics"
weight = 1
+++

## Compilation Model

The Beef compilation context is a workspace, which consists of multiple projects. A project can either be a library or it can produce a binary such as an executable or dll. Sources are parsed, passed through a limited preprocessor, compiled, and a collection of object files are built for types and methods which are referenced, which are then linked into the target binaries. The workspace-wide compilation model allows per-workspace settings to affect compilations of specific groups of methods or types, modifiying preprocessor and compilation settings (ie: optimization level) of code even when it's contained in referenced third-party libraries. 

Incremental compilation is supported, with a dependency graph rebuilding only potentially-affected objects, and with a backend cache to avoid rebuilding objects with no functional changes. Incremental compilation can be disabled for creating reproducible builds.

Beef supports multiple compiler backends, including LLVM and a custom "enhanced debug" (Og+) backend which performs some code optimizations which do not adversely impact debuggability and has some improvements in emitted debug information over LLVM. 

Multiple linkers are supported, including system linkers and the LLVM linker which can be used for link-time optimimied builds (LLVM LTO/ThinLTO).
