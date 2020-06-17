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
* `=> x` - Method binding operator

#### Type attribute operators {#typeattr}
* `sizeof(T)` - size of `T`. Note that reference types will always result in the native pointer size  
* `alignof(T)` - alignment of `T`
* `strideof(T)` - size of `T`, aligned to the alignment of `T`
* `decltype(x)` - type of `X`. Any expression is allowed, including method calls, but will only be evaluated to determine the type of `x` and won't generate any executable code.
* `nullable(T)` - `T` if `T` is already nullable, otherwise `T?`
* `rettype(T)` - return type of a delegate or function

### Ref operators
* `ref x` - required for passing values into ref parameters or other values expecting `ref`
* `out x` - required for passing values into out parameters

### Params operator
* params x - where x is a variadic parameter, will pass through those params to another variadic parameter. Where x is a delegate or function params, will expand those in place.

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

	public static Vector2 operator+(Vector2 lhs, Vector2 rhs)
	{
		return .(lhs.x, rhs.y);
	}

	public static Vector2 operator-(Vector2 val)
	{
		return .(-val.x, -val.y);
	}

	public static int operator<=>(Vector2 lhs, Vector2 rhs)
	{
		/* Compare on X, or on Y if X's are equal */
		int cmp = lhs.x <=> rhs.x;
		if (cmp != 0)
			return cmp;
		return lhs.y <=> rhs.y;
	}
}
```
