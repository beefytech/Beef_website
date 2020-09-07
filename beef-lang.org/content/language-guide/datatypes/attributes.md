+++
title = "Attributes"
weight = 11
+++

## Type attributes
- [CRepr] - marks struct as C-compatible
- [Ordered] - disables reordering of fields (which can occur to reduce field alignment padding)
- [Packed] - omits field alignment padding
- [Union] - for structs, creates a union

## Member attributes
- [Reflect] - forces reflection data to be emitted for this member
- [NoShow] - omit this field from autocompletion

## Static field or method attributes
- [CLink] - uses C link name rather than C++-style mangling
- [LinkName] - overrides link name explicitly

## Constructor attributes
- [AllowAppend] - allows for append allocations

## Method attributes
- [AlwaysInclude] - indicates that even if this method would have been skipped by compile-on-demand, it should be included in the build anyway. This can be useful for methods that are meant to be called by reflection.
- [Checked] - indicates that this method performs runtime checks such as validating arguments (ie: bounds checks)
- [Commutable] - this attribute creates an additional version of this method where the first two arguments are transposed. This can be useful for creating operators whose operations are commutable.
- [CVarArgs] - passes variable-length 'params' in C-style varargs
- [DisableChecks] - indicates that calls within this method should call the Unchecked verion of methods when possible (optimization)
- [DisableObjectAccessChecks] - indicates that object access checks should be disabled within this method (optimization)
- [Error] - throws a compilation error when the method is called (a more generalized form of [Obsolete])
- [Export] - this method will be exported
- [Import] - imports a method from the specified DLL. This can be used when a DLL's lib file is not available.
- [Inline] - inlines the function even on unoptimized builds
- [Intrinsic] - ties a method to an intrinsic (generally only used in system libraries)
- [NoDiscard] - throw a warning at callsites if the return value of this method isn't used
- [NoReturn] - denotes that this method will not return
- [Obsolete] - marks a method as obsolete, throwning either a warning or error
- [Optimized] - compiles method with optimizations enabled
- [SkipCall] - disables code generation for invocations of this method, and for evaluation of the arguments
- [StdCall] - uses the stdcall convention instead of the default of cdecl
- [Test] - marks a method as being a test method
- [Unchecked] - indicates that this method omits runtime checks (generally for increased performance)
- [Warn] - throws a compilation warning when the method is called (a more generalized form of [Obsolete])

## Static field attributes
- [ThreadStatic] - marks this field as being a thread local static field

## Member access attributes
- [Friend] - allow access to private members
- [SkipAccessCheck] - omits object access checks for the target of this member access (optimization)

## Code block attributes
- [IgnoreErrors] - Silently ignore errors in this code block