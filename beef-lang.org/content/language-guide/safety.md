+++
title = "Safety Features"
weight = 2
+++

Beef supports a variety of optional safety features, many of which can be disabled for specified groups of code for "mixed safety" builds (ie: so performance-critical code can disable some checks while less performance-critical or less tested code can run with more safety checks).

By default, the following checks are enabled for all code in Debug builds and they are disabled in Release builds.

### Bounds checking
Bounds checking is implemented in the standard library for arrays, collections, spans, and strings. In many cases these are implemented by having one [Checked] accessor that performs bounds checks and another [Unchecked] accessor that does not bounds check. This allows bounds checking to be selected at the callsite rather than being determined collection-wide.

```C#
	// Disable bounds checking for this specific index
	int val = arr[[Unchecked]i];
```

```C#
	// Don't do any checks in this method
	[DisableChecks]
	void Calculate()
	{
		int val = arr[i];
	}
```

### Dynamic cast checking
Explicit object casts to an invalid derived type will be caught at runtime.

### Memory leaks
Leaks can be detected in realtime with the debug memory manager. Reachable memory will be continuously traced at runtime and memory which is no longer reachable but has not been properly freed will be immediately reported as a leak, along with the code location where the allocation occured. The stack trace depth for this allocation tracing is adjustable.

### Double free / use after free
When the debug memory manager is enabled, objects which have been requested to be freed will be marked as 'freed' but the memory will not be phyiscally reclaimed until there are no more references to the memory that it occupies. Any attempt to use the memory after it has been marked as freed is guaranteed to immediately fail, and the value of that freed object and it's allocation stack trace will be valid and visible in the debugger.
