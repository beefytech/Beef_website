+++
title = "Expressions"
weight = 4
+++

### Allocations

`new` and `scope` keywords are used for allocation (see [Memory Management]({{< ref "memory.md" >}}))

### append

The `append` expression allocates memory immediately after an object's allocated memory, and can only be used in a constructor. (See [Memory Management]({{< ref "memory.md#append" >}}))

An `append` allocation can be used in any way a `new` allocation can be used.  (See [new]({{< ref "#new" >}}))

### Assignment operations

See [Assignment operators]({{< ref "operators.md#assignment" >}})

### Binary operations

See [Binary operators]({{< ref "operators.md#binary" >}})

### Bind expression =>

The `=>` expression is used for method binding (see [Method References]({{< ref "datatypes/methodrefs.md" >}}))

### box

The `box` expression allocates an object which wraps a value type. (See [Memory Management (boxing)]({{< ref "memory.md#boxing" >}}))

* `scope box x` - boxes `x` in current scope
* `scope:s box x` - boxes `x` in scope `s`
* `new box x` - boxes `x` in global allocator
* `new:a box x` - boxes `x` in custom allocator `a`  

### case

`case` expressions can be used for pattern matching outside switches. (See [Pattern Matching]{{<ref "pattern.md" >}}))

### Cast expression

* `(T)x` casts value `x` to type `T`

### Conditional operator
* `x ? y : z` - results in `y` is `x` is true, otherwise results in `z`

### Conditional variable declarations
Variable declarations can be use as boolean expressions in 'if' statements for nullable types. These can be used with certain types of binary operations in the cases where a 'true' overall 'if' result ensures that the conditional variable declaration was also evaluated and resulted in 'true'. 

```C#
/* Simple conditional variable declaration */
if (let name = GetName())
{

}

/* 'Complex' conditional variable declaration */
if ((let name = GetName()) && (isEnabled))
{

}

/* This is ILLEGAN since "force" can cause the block to be entered even if the conditional variable declaration fails */
if ((let name == GetName() || (force))
{

}
```

### default

Every type has a "default" value, which is always zero-initialization.

```C#
// Default can specify a type and results in a default-initialized value
var str = default(String);
// Default will use the "expected" type if there is no explicit default type specified
String str2 = default;
```

### Expression blocks
Expression blocks end with an expression that is not terminated by a semicolon.
```C#
Console.WriteLine("Result={}", 
	{ 
		GetByRef(let val);
		val 
	});
```	

### Index expressions

* 'y = x[i]' - Indexes value `x` by index `i`. If `x` is a pointer, is equivalent to `y = *(x + i)`. Otherwise, calls the `get` method on the `this[int]` indexer property.
* `x[i] = y` - Indexes value `x` by index `i`. If `x` is a pointer, is equivalent to `*(x + i) = y`. Otherwise, calls the `set` method on the `this[int]` indexer property if there is a `set` method, otherwise calls `get` method if it returns a `ref` value.

### Literals

* `123` - number
* `0x1234` - hex number
* `0x1234'5678` - number with a seperator, which can be placed anywhere
* `0x'1234` - int64 hex number, because of "0x'".
* `0x1234L` - int64 hex number
* `0x1234UL` - uint64 hex number
* `'c'` - char8
* `'😃'` - char32
* 1.2f - float
* 2.3 - double
* "Hello" - String

### new {#new}

The `new` expression allocates memory in the global allocator or in a custom allocator. (See [Memory Management]({{< ref "memory.md#allocating" >}}))

* `new T(...)` - allocates instance of `T` in the global allocator. Result is `T` if `T` is a reference type, otherwise result is `T*`
* `new T[i]` - allocates type `T[]` with array size `i`
* `new T[i] (...)` - allocates type `T[]` with array size `i` and with an initializer
* `new T[] (...)` - allocates type `T[]` whose size is based on the number of initializers
* `new T[i]*` - allocates `i` contiguous instances of `T` in the global allocator, a returns a `T*` pointer to the first element. Note that the allocation size is typeof(T).InstanceStride*i for convenience, though technically this allocates extra padding to the end of the last element.
* `new box x` - boxes value `x` in the global allocator. (See [Memory Management (boxing)]({{< ref "memory.md#boxing" >}}))

All `new` operations can also accept a custom allocator argument.

* `new:a T(....)` allocates an instance of `T` in custom allocator `a` where `a` is an identifier.
* `new:(a) T(...)` allocates an instance of `T` in custom allocator `a` where `a` is any expression. 

### Parentheses expression

Adding parentheses around expressions can be used for changing order of operations for complex expressions.

```C#
int a = 1 + 2 * 3; // The multiply happens before the add here, resulting in 7
int b = (1 + 2) * 3; // The add happens before the multiply here, resulting in 9
``` 

### scope

The `scope` expression allocates memory on the stack, in a scope contained in an executing method. (See [Memory Management]({{< ref "memory.md#allocating" >}}))

A `scope` allocation can be used in any way a `new` allocation can be used.  (See [new]({{< ref "#new" >}}))

### this

`this` is a special variable name, which represents the current instance in instance methods. If the defining type is a struct then `this` is a value type (not a pointer), which is mutable for "mut" methods and immutable otherwise.

### Tuple expression

The tuple expression is a paranthesized expression containing multiple comma-seperated values, and optionally field names. (See [Data Types (Tuples)]({{< ref "datatypes/_index.md#tuples" >}})))

### Unary operations

See [unary operators]({{< ref "operators.md#unary" >}})

### Uninitialized '?'

When assigned to a variable or field, `?` will cause the value to be treated as if it had an assignment but without (necessarily) any actual operation. This can be useful in cases such as with "buffer" type arrays that don't need to be zero-initialized before use. 
