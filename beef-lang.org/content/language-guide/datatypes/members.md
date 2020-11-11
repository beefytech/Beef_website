+++
title = "Type Members"
weight = 10
+++

## Fields

Fields can be const, static, or instanced. Const fields represent values, but take no memory. Consts must evaluate to a constant value at compile time, given simple constant arithmetic evaluation. Using a const is equivalent to using its representative literal value. Static values are a single "global variable" value contained in the namespace of the defining type. Fields that are neither marked as static nor const are instanced fields, which define data contained within an instance of the defining type.

```C#
class Widget
{
	/* Static "shared" value */
	static int totalCount; 

	const int MaxWidgets = 64 * 1024;

	/* Normal "instanced* data field */
	int x;
	int y;
}
```

## Methods

Method overloading is supported in Beef. For generic overloads, multiple versions of the same generic method are allowed if the constraints are different. If multiple generic methods match, one can be considered "better" if its contraints are a superset of another method's constraints, otherwise the overload selection is ambiguous.

Parameter values are immutable unless 'ref', 'out', or 'mut' specifiers are used.

```C#
bool GetInt(out int outVal)
{
	outVal = 92;
	return true;
}

/* 'mut' can be used for generics that may be a value type or a reference type, but we need to have a mutable reference. 'mut' will have no effect on reference types but will be treated as a 'ref' for value types. */
bool DisposeVal<T>(mut T val) where T : IDisposable
{
	val.Dispose();
}

```

When it is convenient to have parameters treated as "initial values" that can be modified, there is variable shadowing functionality that semantically creates a modifiable copy of the parameter and a new shadow variable with the same name.

```C#
void Write(char8 c)
{
	var c;
	if (c == '\n')
		c = ' ';
	file.Write(c);

	/* Note that the original argument will still be available as "@c" and can be seen in 
	the debugger in debug builds */
}
```

Passing structs by immutable value is efficient, as it does not require a copy to be created at the callsite, so passing by reference is not needed for performance. In addition to platform-specific calling conventions that can pack small structs into ints, Beef may "splat" struct arguments, where something like a (double, double) tuple can be directly passed in two floating point registers rather than requiring it to be passed by struct reference as would be standard in C.

Methods can be defined which accept a variable number of arguments, using a "params" specifier on the last parameter. This is common with string-formatting methods like Console.WriteLine. The "params" type can be declared as either an array or a Span type. The "params" specifier can also be used on delegate or function types, which expands the parameter declaration to include the parameters declared in the delegate/function -- this is useful for generic argument forwarding, such as in the case of System.Event<T>.

```C#
/* Variable number of arguments */
void Draw(String format, params Object[] args)
{
	let str = scope String();
	/* The 'params' */
	str.AppendF(format, params args);	
}

/* Delegate argument forwarding */
public static rettype(T) SafeInvoke<T>(T dlg, params T p) where T : Delegate
{
	if (dlg == null)
		return default;
	return dlg(params p);
}
```

While backend optimizations will perform inlining, you can also explicitly inline methods by annotating them with [Inline]. This will cause direct inlining to occur, which will inline even in debug builds (which does not break debuggability) and ensures methods will be inlined in cases where they may otherwise not inline such as in cross-module calling with non-LTO linking.

```C#
class Collection
{
	[Inline]
	int GetLength()
	{
		return mLength;
	}

	void Clear()
	{
		mLength = 0;
	}
}

void Use(Collection c)
{	
	c.GetLength();

	/* Inline can be requested at the callsite, which creates a local 'always inline' 
	version of this method to call */
	c.[Inline]Clear();
}
```

Methods provide some safeties to protect against discarded return values. This can be useful to ensure that errors are handled, or that methods that return modified values are not mistaken for methods that modify the value in-place. Static warnings on discarded results can be emitted by adding a [NoDiscard] attribute to the method. Cases like protecting against unhandled errors can be handled by adding a 'ReturnValueDiscarded()' method to the returned type, which the compiler will call at runtime -- this is used on the built-in `Result` type (see [Error Handling]({{< ref "errors.md" >}})).

```C#

[NoDiscard]
char8 ToUpperCase(char8 c);

void ToUpperCase(String str)
{
	for (var c in ref str.RawChars)
	{
		/* OOPS- a 'value discarded' warning is thrown here. 'c = ToUpperCase(c)' was intended */
		ToUpperCase(c);
	}
}

```

## Mixins
Mixins are kinds of methods that get "mixed in" to the callsite directly, rather than being "called". This can be useful for not only eliminating call overhead, but the semantics are different than called methods since statements declared in a mixin such as "break" can break from structured blocks in the caller itself, and a "return" will return from the caller itself.

```C#
static mixin Inc(int* val)
{
	if (val == null)
		return false;
	(*val)++;
}

static bool Inc3(int* a, int* b, int* c)
{
	Inc!(a);
	Inc!(b);
	Inc!(c);
	return true;
}
```

Mixin parameter types can also be "unconstrained" by declaring their type as `var`. This can be useful for creating generalized macro-like helpers. Mixins can also be implemeneted with generic parameters with constraints, which can help for either generating more useful errors or for overload selection when multiple overloaded versions of a mixin are available, but does not affect code generation. There is no performance penalty for using `var`, as the mixin will expand the same way at the callsite -- the only difference is in what errors occur at the callsite expression itself vs inside the expanded mixin.

When mixin parameter types are specified, the parameter will be mutable if the caller passes in a mutable value that matches the specified type. If not, a type conversion will occur and the parameter will be immutable.

Mixins do not declare return types since they don't return, but they can result in a value using "expression block" syntax where the mixin definition block ends with an expression not terminated by a semicolon.

```C#
static mixin Max(var a, var b)
{
	(a > b) ? a : b
}
``` 

### Mixin targets

For operations in the mixin definition that allow for a scope target (ie: break, continue, scope allocation), the special `mixin` target can be specified which allows for a scope target to be specified at the mixin callsite.

```C#
static mixin AllocString()
{
	scope:mixin String()
}

void Use()
{
	String outerStr = null;

	while (IsRunning())
	WhileBody:
	{
		String whileStr = null;

		if (Check())
		{
			// Allocs string in current scope
			let localStr = AllocString!();
	
			// Allocs string in the scope of the 'while' body
			whileStr = AllocString!:WhileBody();

			// Allocs string in method scope
			outerStr = AllocString!::();
		}
	}
}
```

## Properties

Properties are a way to add named values to a type where a getter and/or setter method can be defined.

```C#
struct Square
{
	int x;
	int y;
	int width;
	int height;

	int Right
	{
		get
		{
			return x + width;
		}

		/* Note the requirement of 'mut' here */
		set mut
		{
			width = value - x;
		}
	}

	/* Allow 'Left' to be returned by reference, which implicitly allows setting the value 
	through assignment but also allows it to be passed by reference to other methods */
	ref int Left
	{
		get
		{
			return ref x;
		}
	}

	/* This property definition implicitly creates a member variable and the appropriate 
	get/set methods */
	uint32 Color { get; set; }
}
```

Index operators are implemented properties with one or more index parameters.

```C#
public ReadOnlyList<T>
{
	public T this[int idx]
	{
		get
		{
			return mList[idx];
		}
	}
}
```

## Member access
By default, struct and class members are 'private', meaning they can only be accessed internally by that type. A 'protected' member can be accessed by derived types, and 'public' can be accessed by anyone. An 'internal' member can be access from files specifying `using internal <namespace>`. Note that even types within the same namespace need to explicitly specify `using internal` to access internal members of each other.

```C#
/* This allows us to access 'internal' members anywhere within the 'GameEngine' namespace */
using internal GameEngine;

class Widget
{
	private int32 id;
	protected Rect pos;
	public uint32 color;
	internal void* impl;
}

class Button : Widget
{
	/* This class can access 'pos' and 'color' but not 'id' */
}

static void Main()
{
	var button = new Button();
	/* We can only access 'button.color' */

	/* The [Friend] attribute allows us to access members which are normally hidden */
	int32 id = button.[Friend]id;
	/* Note that the 'friend' relationship is inverted from C++ here - the user is 
	promising to be friendly rather than the defining types declaring its friends */
}
```
