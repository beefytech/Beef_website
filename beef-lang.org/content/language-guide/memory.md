+++
title = "Memory Management"
weight = 30
+++

## Memory Allocation {#allocating}
Allocations can be placed on the stack, the global allocator, or a custom allocator. Stack allocations use the "scope" keyword, which can specify a scope from the current scope (ie: code block) to the scope of the whole method (even in a loop).

```C#
static void Test(StreamReader fs)
{
	let strList = scope List<String>();
	for (let line in fs.Lines)
	{
		/* The scope of this string is the whole method */
		let lineStr = scope:: String(line);
		strList.Add(lineStr);
	}
	strList.Sort();
}

static void Test(StreamReader fs)
{
	Sort:
	{
		let strList = scope List<String>();
		for (let line in fs.Lines)
		{
			/* The scope of this string is the "Sort" scope */
			let lineStr = scope:Sort String(line);
			strList.Add(lineStr);
		}
		strList.Sort();
	}
}
```

Scoped allocations can dynamically increase stack size, and care must be used to ensure enough stack space is available for the given computation, just as recursive methods must ensure recursion depth won't exhaust the stack.

Allocations through the global allocator use the "new" keyword.

```C#
String AllocGlobalString(int len)
{
	return new String(len);
}
```

Allocations through a custom allocator uses the "new" keyword with a custom allocator instance specified.
```C#
String AllocCustomString(int len)
{
	return new:customAllocator String(len);
}
```

Custom allocations can allocate through mixins, which can even allow for conditionally allocating on the stack. The ScopedAlloc mixin, for example, will perform small allocations on the stack and large objects on the heap.
```C#
void ReadString(int reserveLen)
{
	String str = new:ScopedAlloc! String(reserveLen);
	UseString(str);	
}
```

### Global allocator
The global allocator is selected on a per-workspace basis. By default, the CRT malloc/free allocators are used, but any C-style global allocator can be used, such as TCMalloc or JEMalloc. In addition, Beef contains a special debug allocator which enables features such as real-time leak checking and hot compilation.

Beef allocations are C-style in that they are non-relocatable and there is no garbage collector.

### Releasing memory
Scoped allocations are automatically released at the end of the scope, but manual allocations must be manually released with the "delete" keyword. Similarly as with custom allocator allocations, the delete can specify a custom allocator target for releasing memory from custom allocators.

### Append allocations {#append}
Append allocations are a special category of allocations that can be placed in constructors, which can manually request additional memory to be allocated along with the allocation of the owning object. This is used in corlib for strings that accept a "size" argument and such.

```C#
class FloatArray
{
	int mLength;
	float* mPtr;

	[AllowAppend]
	public this(int length)
	{
		let ptr = append float[length]*;
		mLength = length;
		mFloats = ptr;
	}
}

/* Append allocations are guaranteed to occur immediately after the object's own memory (with respect to alignment). We can use this knowledge to calculate the storage location of the array rather than storing it internally */
class FloatArray
{
	int mLength;

	[AllowAppend]
	public this(int length)
	{
		let ptr = append float[length]*;
		mLength = length;
	}

	public float* Ptr
	{
		get
		{
			return (float*)(&mLength + 1);
		}
	}
}
```

Internally, append allocations work by creating a size-calculation function that is called before the allocation occurs. The compiler will attempt to perform constant evaluation on this function and the relevant arguments at the callsite, and can result in a fixed-sized allocation rather than a dynamic-sized one, which removed the extra call and can also be faster for some stack allocations.

Append-allocated memory does not need to be explicitly released, but object destructors can still be called via a `delete:append obj` statement.

### Boxing {#boxing}
All value types (primitives, structs, tuples, pointers, enums) can be 'boxed' into an Object, which can be useful for dynamic type handling and interface dispatching. Primitive types all have library-defined struct wrappers that are used for boxing (ie: the int32 primitive gets wrapped by System.Int32). Boxing is an allocating operation which implicitly occurs as a temporary stack allocation on a cast to System.Object, but long-term boxing and longer-lived stack allocations can be explicitly specified.

```C#
// Format calls rely on boxing to handle incoming types
Console.WriteLine("a + b = {}", a + b); 
Object a = 1.2f; // Implicitly boxed on stack to current scope on
Object b = scope box:: 2.3f; // Explicitly boxed on stack to method scope
Object c = new:allok box 4.5f; // Explicitly boxed through a custom allocator 'allok'
```
