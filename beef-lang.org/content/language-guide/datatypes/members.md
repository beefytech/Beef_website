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

Anonymous field access is supported through 'using' fields. Field marked as 'using' can have their member fields accessed without qualifying them with the field's name. These have a protection level for the named field itself and different protection level for its anonymous use. With `public using private Vector2 mPosition`, for example, `mPosition` has private protection, but, through anonymous use, the field's `X` and `Y` members are publicly accessible.

Anonymous field access can provide some of the same benefits of inheritance but constructed through composition.

```C#
struct Vector2
{
	public float X;
	public float Y;
}

struct Entity
{
	/* 'mX' can be accessed directly or through 'mPosition.mX'. Note that protection is not directly specified for anonymous access,
	so it uses the protection (public) from the named field */
	using public Vector2 mPosition;
	public int32 mHealth;
}
```

Append fields are an optimization that allows reference type fields to have their data statically included inside the owner. This allows for the field to semantically behave as a reference type still, but without the indirection of a reference type (since the data offset is statically known) and without requiring its own separate allocation.

```C#
/* An allocation of 'User' includes data for the two members strings plus the specified space for their internal buffers */
class User
{
	public append String mName = .(256);
	public append String mPassword = .(32);
}
```

## Methods

Method overloading is supported in Beef. For generic overloads, multiple versions of the same generic method are allowed if the constraints are different. If multiple generic methods match, one can be considered "better" if its contraints are a superset of another method's constraints, otherwise the overload selection is ambiguous.

Parameter values are immutable unless `ref`, `out`, or `mut` specifiers are used. The `in` specifier can be used to explicitly request a parameter to be passed as an immutable reference, but note that this disables the ability to pass smaller structs by value even when that would be more efficient, so `in` should only be used when the specific semantics are required.

```C#
bool GetInt(out int outVal)
{
	outVal = 92;
	return true;
}

/* 'mut' can be used for generics that may be a value type or a reference type, but we need to have a mutable reference.
'mut' will have no effect on reference types but will be treated as a 'ref' for value types. */
bool DisposeVal<T>(mut T val) where T : IDisposable
{
	val.Dispose();
}

/* Methods can return 'ref' or 'readonly ref' values */
readonly ref int Get()
{
	return ref mVal;
}
```

Methods can be invoked with argument names. Named arguments can occur in any order, and they can be mixed with normal "positional" arguments, with some restrictions.

```C#
static void Method(int a, int b, int c) {}

/* Legal */
Method(1, 2, 3);
Method(a:1, b:2, c:3);
Method(a:1, 2, c:3);
Method(c:3, b:2, a:1);

/* Illegal */
Method(a:1, a:2, b:3, c:4);
Method(b:2, 1, 3);
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

By default, "larger" structs are passed as immutable refrences and "smaller" structs are passed as immutable values. Structs such as a `Vector3` can be passed directly in XMM registers on X86.

### Variable argument counts {#params}

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

Generic tuple params allow for per-argument generic specialization. Generally speaking, comptime code generation will be employed here to create a method body which is specialized to the incoming argument types. For an advanced example, see the fast string formatting test implementation at https://github.com/beefytech/Beef/blob/master/IDEHelper/Tests/src/Params.bf

```C#

void HandleArgs<TArgs>(params TArgs args) where TArgs : Tuple
{
}

HandleArgs("String", 1, 2.3f);

```

Beef supports C-compatible variable arguments. This is less safe than `params` since the argument count and argument types are unknown, but it can be useful for C interop.

```C#
/* external C method 'void Log_External(char*, va_list)' */
[CLink]
static extern void Log_External(char8* format, void* varArgs);

public static void Log(String format, ...)
{
	VarArgs vaArgs = .();
	vaArgs.Start!();
	Log_External(format, vaArgs.ToVAList());
	vaArgs.End!();
	return result;
}

public static void HandleVarArgInts(int count, ...)
{
	VarArgs vaArgs = .();
	vaArgs.Start!();
	for (int i < count)
		Dispay(vaArgs.Get!<int>())
	vaArgs.End!();
	return result;
}
```

### Inlining

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

### Discarded return values

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

	public int Right
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
	uint32 Color { get; set; } = 0xBFBF;
}

struct IntRef
{
	int* mValue;

	public ref int Ref
	{
		get
		{
			return ref *mValue;
		}

		/* Without the 'ref' specifier, the set method would take an 'int' value rather than a 'ref int' */
		set ref mut
		{
			mValue = &value;
		}
	}

	public ref int Value => ref *mValue;
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
By default, struct and class members are 'private', meaning they can only be accessed internally by that type. A 'protected' member can be accessed by derived types, and 'public' can be accessed by anyone. An 'internal' member can be access from files specifying `using internal <namespace>`. A 'protected internal' member is the most-accessible combination of 'protected' and 'internal'. Note that even types within the same namespace need to explicitly specify `using internal` to access internal members of each other.

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
