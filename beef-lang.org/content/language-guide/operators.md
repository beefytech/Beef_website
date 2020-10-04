+++
title = "Operators"
+++

## Operators overview
These following operator groups are listed from the highest priority group to the lowest priority group.

### Primary operators
* `x.y` - member access
* `x..y` - cascading member access. Results in `x`, which is useful for chaining together method calls.
* `x?.y` - null conditional member access. Results in null if `x` is null.
* `f(x)` - method call
* `a[x]` - array indexing

### Unary operators {#unary}
* `x++` - postfix increment, increments x and results in result before the increment
* `x--` - postfix decrement, decrements x and results in result before the decrement
* `++x` - prefix increment, increments x and results in the new value
* `--x` - prefix decrement, decrements x and results in the new value
* `~x` - bitwise complement
* `!x` - logical negation
* `(T)x` - type casts `x` to type `T`
* `&x` - address of `x`
* `*x` - dereference pointer `x`

#### Multiplicative operators {#binary}
* `x * y` - multiplication
* `x / y` - division. If `x` and `y` are integers, results in an integer truncated toward zero.
* `x % y` - remaindier. If `x` and `y` are integers, results in the remaindier of the division `x / y`.

#### Additive operators
* `x + y` - addition
* `x - y` - subtraction

### Shift operators
* `x << y` - shift bits left
* `x >> y` - shift bits right. if `x` is signed, the left bits are filled with the sign bit.

### Spaceship operator
* `x <=> y` - results is negative if `x < y`, zero if `x == y`, positive if `x > y` 

### Comparison operators
* `x < y`
* `x > y`
* `x <= y`
* `x >= y`
* `x is T` - results in true if `x` can be cast to type `T`
* `x as T` - casts `x` to `T` if the cast is possible, otherwise results in null

### Logical AND operator
* `x & y` - bitwise AND

### Logical XOR operator
* `x ^ y` - bitwise XOR

### Logical OR operator
* `x | y` - bitwise OR   

### Equality operator

* `x == y`
* `x === y` - strict equality
* `x != y`
* `x !== y` - strict inequality

The strict equality operators can be used to check reference equality, skipping any equality operator overloads. For value types such as structs or tuples, the strict equality operator will perform a memberwise strict equality check.

### Conditional AND operator
* `x && y`

### Conditional OR operator
* `x || y`

### Null-coalescing operator
* `x ?? y` - results in `x` if it is non-null, otherwise results in `y`

### Conditional operator {#conditional}
* `x ? y : z` - results in `y` is `x` is true, otherwise results in `z`

### Assignment operators {#assignment}

Assignments result in the new value of `x`.

* `x = y`
* `x += y`
* `x -= y`
* `x *= y`
* `x /= y`
* `x %= y`
* `x |= y`
* `x ^= y`
* `x <<= y`
* `x >>= y`
* `x ??= y`
* `=> x` - Method binding operator

#### Type attribute operators {#typeattr}
* `sizeof(T)` - size of `T`. Note that reference types will always result in the native pointer size  
* `alignof(T)` - alignment of `T`
* `strideof(T)` - size of `T`, aligned to the alignment of `T`
* `decltype(x)` - type of `X`. Any expression is allowed, including method calls, but will only be evaluated to determine the type of `x` and won't generate any executable code.
* `nullable(T)` - `T` if `T` is already nullable, otherwise `T?`
* `rettype(T)` - return type of a delegate or function
* `alloctype(T)` - result of `new T()`, which will be `T` for reference types and `T*` for valuetypes

### Ref operators
* `ref x` - required for passing values into ref parameters or other values expecting `ref`
* `out x` - required for passing values into out parameters
* `var x` - create a new variable `x` from an out parameter
* `let x` - create a new const/readonly variable `x` from an out parameter

### Params operator
* params x - where x is a variadic parameter, will pass through those params to another variadic parameter. Where x is a delegate or function params, will expand those in place.

## Casting

The `(T)x` cast operator can directly perform many kinds of type conversions, but there are some special cases:
* Unboxing. `(T)obj` where `obj` is an `Object` and `T` is a valuetype will perform an boxing. This unboxing can fail at runtime in Debug mode (when Dynamic Cast Checks are enabled). You can use an `obj is T` check or a `obj as T?` expression to safely unbox.
* Retrieving an object's address: the expression `(void*)obj` where `obj` is an Object type is actually an unboxing request, not a type conversion. `System.Internal.UnsafeCastToPtr` can return the address of an Object as a `void*`.
* Casting to an unrelated type. Sometimes double-casts can be used to achieve what would otherwise be an illegal cast. For example, with `(void*)handle` where `handle` is a the typed primitive `struct Handle : int`, the cast directly to `void*` is not allowed, but `(void*)(int)handle` is allowed.

## Operator overloading

Structs and classes can provide operator overloads. Comparison operator selection is flexible, in that not all combination of <, <=, ==, !=, >, and >= need to be defined. The "inverse" of operators will be called if available, or if just the <=> operator is defined then that can be used for all comparison types as well.

```C#
struct Vector2
{
	float x;
	float y;

	public this(float x, float y)
	{
		this.x = x;
		this.y = y;
	}

	/* Binary + operator */
	public static Vector2 operator+(Vector2 lhs, Vector2 rhs)
	{
		return .(lhs.x, rhs.y);
	}

	/* Unary '-' operator */
	public static Vector2 operator-(Vector2 val)
	{
		return .(-val.x, -val.y);
	}

	/* Unary '++' operator */
	public static Vector2 operator++(Vector2 val)
	{
		return .(val.x + 1, val.y + 1);
	}

	/* Non-static unary '--' operator */
	public void operator--() mut
	{
		x--;
		y--;
	}

	/* Assignment '+=' operator */
	public void operator+=(Vector2 rhs) mut
	{
		x += rhs.x;
		y += rhs.y;
	}

	/* Comparison operator */
	public static int operator<=>(Vector2 lhs, Vector2 rhs)
	{
		/* Compare on X, or on Y if X's are equal */
		int cmp = lhs.x <=> rhs.x;
		if (cmp != 0)
			return cmp;
		return lhs.y <=> rhs.y;
	}

	/* Conversion operator from float[2] */
	public static operator Vector2(float[2] val)
	{
		return .(val[0], val[1]);
	}
}
```
