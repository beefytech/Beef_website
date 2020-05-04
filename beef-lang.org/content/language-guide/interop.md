+++
title = "Interop"
weight = 60
+++

### Interop (FFI)
Beef allows for zero-overhead linking to static and dynamic libraries. Methods declared as 'extern' will create an external symbol reference which must be satisfied at link time. Beef can also import DLL methods when a C linking library is not available, using the `[Import(...)]` attribute. By default, C++-compatible name mangling is used, but a method's link name can be override with [CLink] or [LinkName].
 
```C#
/* Links to a method in an external library, with the following attributes:
  Import: Link to library 'wsock32.lib' when we use this method
  CLink: Don't use C++ mangling, use C link name for this method
  StdCall: Use stdcall calling convetion (WINAPI) */
[Import("wsock32.lib"), CLink, StdCall]
static extern int32 WSAGetLastError(); 
```

Struct layouts do not, by default, match C struct layouts due to field reordering (to reduce alignment gaps) and because Beef seperates the concepts of struct size from stride -- Beef structs omit alignment padding at the end. The `[CRepr]`attribute can be used to create structs that match C for interop purposes.

By default, the system 'cdecl' calling convention will be used by Beef, unless methods are marked with `[StdCall]`, whereby the system 'stdcall' convention will be used.

If the CRT allocator is required for FFI, note that the workspace can define the global allocator so the CRT's allocator may not be used. In this case, you can either manage FFI memory through `System.Internal.StdMalloc` and `System.Internal.StdFree`, or you can use the `System.gCRTAlloc` custom allocator.

Beef also supports manual and dynamic foreign function interfacing (FFI) through System.FFI in the corlib.

### ABI Stability

Beef does not provide general ABI stability except for that which is provided by the generalized FFI C interop -- not even seperate compilations of exactly the same code are guaranteed to generate stable ABI boundaries. The following is a partial list of ABI breaks that can occur even without code changes within an ABI-boundary library:

- Workspace debug settings can affect the size and contents of objects. These settings include 'Object Debug Flags', 'Realtime Leak Check', 'Enable Hot Compilation', 'Large Strings', and 'Large Collections'.
- User programs and libraries can add type extensions that change the data layout of system types
- Fast dynamic casting relies on generating a workspace-wide inheritance-ordered type id
- Devirtualizations may occur that rely on complete inheritance knowledge at the callsite
- Reflection data is incompatible across ABI boundaries
- The string literal address equality guarantee breaks
- Compile-on-demand also affects vtable layouts, since omitted methods do not occupy a vtable entry
- Global allocator selection occurs at the workspace level

While languages such as C++ do not 'officially' provide a stable ABI, its seperate 'compilation module' approach can be amenable to a "soft" ABI which allows for a usable ABI boundary assuming you can guarantee both sides of the boundary (lib and lib user) are compiled with "compatible settings" including compiler versions, compatible headers included, relevant compatible preprocessor flags, memory management being carefully handled, etc. While this is somewhat stronger ABI stability than Beef, it is not nearly strong enough to satisfy the general goals of ABI stability, however, which include the ability of a library author to provide binary library updates with security or performance enhancements that can be used without user program recompilation, and to provide system-level libraries whose binary footprints do not need to be included with user programs (a primary goal of Swift ABI stability).

<sup>Further reading: https://gankra.github.io/blah/swift-abi/</sup>