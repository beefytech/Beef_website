+++
title = "Introduction"
weight = 1
+++

## Beef Overview

Beef is a performance-oriented compiled programming language. The syntax and core library design derives from C#, but there are many semantic differences due to differing design goals. The language has been developed hand-in-hand with its IDE environment, and careful attention has been paid to the holistic pleasurability of developing Beef applications. The intended audience is the performance-minded developer who values simplicity, code readability, fast development iteration, and good debuggability.

## Design goals
* High performance execution
 * No GC or ref counting overhead
 * Minimal runtime 
 * Compiled (no JIT delays)
* Control over memory
 * Extensive support for custom allocators
 * Enhanced control over stack memory
* Low-friction interop with C and C++
 * Statically or dynamically link to normal C/C++ libraries
 * Support for C/C++ structure layouts and calling conventions
* Prefer verbosity over conciseness when it aides clarity, readability, or discoverability
* Enable fluid iterative development
 * Fast incremental compilation and linking
 * Runtime code compilation (code hot swapping), including data layout changes
* Familiar syntax and programming paradigms for intended audience (C-family)
* Good debugability
 * Emits standard debug information (PDB/DWARF)
 * Emphasis on good execution speed of debug builds
* Well-suited to IDE-based workflow
 * Compiler as a service
 * Fast and reliable autocomplete results
 * Fast and trustworthy refactorability (ie: renaming symbols)
* Leverage LLVM infrastructure
 * Battle-hardened backend optimizer
 * ThinLTO link time optimization support 
