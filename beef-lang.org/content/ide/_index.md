+++
title = "IDE"
alwaysopen = true
weight = 50
+++

## Overview

The Beef IDE is specially designed for working for Beef, but includes a general-purpose debugger, suitable for debugging a native application written in any language. 

### IDE features
* Autocompletion
* Refactoring tools - symbol rename, fixits, go to definition, find references, etc
* Navigation tools - class view, dropdown member list, open file in workspace, find in files, etc
* Hot code changes
* Spell checker
* Built-in code testing
* Code reformatting
* Program self-debugging API (ie: requesting profiling)

### General debugger features

* Launch external executables or attach to existing process
* Utilize native system debug information (ie: PDB files on Windows)
* Windows minidump loading
* Symbol server and source server support
* Inline debug info support (properly viewing stack traces with inlined methods, step in/out of inlined methods, etc)
* Debug visualizers (built-in definitions for many C++ STL types)   
* Autocomplete while typing debug expressions
* Step filters for stepping over "uninteresting" functions
* Conditional breakpoints
* Memory breakpoints
* Memory viewer
* Disassembly view
* Profiler
