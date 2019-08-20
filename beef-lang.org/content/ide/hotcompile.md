+++
title = "Hot Compiling"
+++

## Hot compile overview

While a Beef application is being executed through the IDE, "hot" changes to the source code is allowed. When a compile is requested and completes successfully, the resulting new object files (if any) will be hot-patched into the running executable. The modified methods are patched in by (safely) inserting jumps to the new method at the start of the old methods. This means that old code can be running alongside new code for long-running methods since the new code will only be "switched to" for methods called after the hot patch, which is expected and supported by the IDE by keeping a mapping of old source code for stepping through replaced methods, for remapping new breakpoints to old replaced methods, etc.

Many other compiler features have special debugger support for hot code changes, including adding and removing virtual methods, adding new string literals to the string intern table, adding new dll-imported methods, changing reflection information, maintaining function pointer address equality, and so on.

Changes to data layouts of structs and classes are also allowed if the program can be hot patched to exclusively use the new data layout, thus any active allocations of the old layout, or any usage of the old layout in the active callstack will result in a compilation error (but NOT a runtime data corruption or crash).
