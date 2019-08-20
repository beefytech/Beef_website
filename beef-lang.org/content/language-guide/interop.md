+++
title = "Interop"
weight = 6
+++

### Interop (FFI)
Beef allows for zero-overhead linking to static and dynamic libraries. Methods declared as 'extern' will create an external symbol reference which must be satisfied at link time. Beef can also import DLL methods when a C linking library is not available, using the [DllImport(...)] attribute.
 
```C#
/* Links to a method in an external library, with the following attributes:
  Import: Link to library 'wsock32.lib' when we use this method
  CLink: Don't use C++ mangling, use C link name for this method
  StdCall: Use stdcall calling convetion (WINAPI) */
[Import("wsock32.lib"), CLink, StdCall]
static extern int32 WSAGetLastError(); 
```

Beef also supports manaul foreign function interfacing (FFI) through System.FFI in the corlib.
