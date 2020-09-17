+++
title = "Statements"
weight = 42
+++

### break/continue
We can stop executing a "for", "while", or "do" statement by using "break". We can skip to the next iteration of a "for" loop with "continue"; By default, these statements refer apply to the most-deeply nested applicable statement in the current scope, but we can use labels to refer to statements further out. This can be useful in situations such as breaking out of nested loops.

```C#
Y: for (int y < height)
	for (int x < width)
		if (Check(x, y))
			break Y;
```

### defer
Defer statements can be used to defer execution of method calls or of code blocks until a given scope is exited. When the deferred statement is a method call, the arguments (including `this`) are evaluated immediately.

```#C
/* The following will print "End:2 B:1 A:0". Note that the execution order is the opposite of the deferred order. */
{
	int i = 0;
	defer Console.WriteLine("A:{}", i);
	i++;
	defer Console.WriteLine("B:{}", i);
	i++;
	Console.WriteLine("End:{}", i);
}

/* The following will print "End:2 B:2 A:2". There were no arguments to evaluate at the defer location, so the 'i' value used in WriteLine is just the current value at the end of the scope. */
{
	int i = 0;
	defer
	{
		Console.WriteLine("A:{}", i);
	}
	i++;
	defer 
	{
		Console.WriteLine("B:{}", i);
	}
	i++;
	Console.WriteLine("End:{}", i);
}

/* The defer statement allows a scope target to be specified. The following will print numbers 9 through 0 when exiting from the containing method. */
{
	for (int i < 10)
	{
		defer:: Console.WriteLine("i={}", i);
	}
}
```

### delete

The `delete` statement releases allocated memory. (see [Memory Management]({{< ref "memory.md" >}}))

* `delete x` - releases memory allocated in the global allocator, referenced by `x`.
* `delete:a x` - releases memory allocated in custom allocator `a`.

When `x` is an object, calls the destructor.

### do
Allows for a non-looping block which can be broken out of, which can reduce 'if nesting' in some code patterns.

```C#
do
{
	char8 c = NextChar();
	if (c == 0)
		break;
	char8 op = NextChar();
	if (c != '+')
		break;
	char8 c2 = NextChar();
	if (c2 == 0)
		break;
	return c + c2;
}
```

### for
For loops are generally used to iterate through a collection or a number series. There are several forms available.

```C#
/* The classic C-style loop, with an initializer, a condition, and iterator */
for (int i = 0; i < count; i++)
{
}

/* A shorthand for the above */
for (int i < count)
{
}

/* Iterate through elements in a List<float> */
for (let val in intList)
{
}

/* The above is equivalent to */
var enumerator = intList.GetEnumerator();
while (enumerator.GetNext() case .Ok(let val))
{

}
enumerator.Dispose();

/* We can also iterate by refrence instead of by value */
for (var valRef in ref intList)
	valRef += 100;
```

### if

```C#
if (i > 0)
	Use(i);
else if (i == 0)
	Use(1);
else
	break;
```

### return

Returns a value from a method.

```C#
int GetSize()
{
	return mSize;
}
```

### switch

```C#
/* Note that 'break' is not required after a case */
switch (c)
{
case ' ':
	Space();
case '\n'
	NewLine();
default:
	Other();  
}

switch (c)
{
/* Cases can contain additional 'when' conditions */
case '\n' when isLastChar:
	SendCommand();
case 'A':
	WasA();
	/* 'fallthrough' continues into the next case block*/
	fallthrough;
case 'E', 'I', 'O', 'U':
	WasVowel();
}
```

Switches can be used for [pattern matching]({{<ref "pattern.md">}}) for enums and tuples.
```C#
/* Note that switches over enums that do not handle every case and have no 'default' case will give a "not exhaustive" compile error. Thus, if we added a new entry to the Shape definition, we would ensure that all switches will make modifications to handle it */
switch (shape)
{
case Square(let x, let y, let width, let height): 
	DrawSquare(x, y, width, height); 
case Circle: 
	IgnoreShape(); 
}
```

Switches can operate on non-integral types, as well.

```C#
switch (str)
{
case "TEST":
	PerformTest();
case "EXIT":
	Exit();
default:
	Fail();
}
```

### using
The `using` statement expresses scoped usage of values.

```C#
using (g.Open("Header"))
{
	g.Write("Hello");
}

/* These are equivalent */
{
	var res = g.Open("Header");
	g.Write("Hello");
	res.Dispose();
}

/* Or */
{
	defer g.Open("Header").Dispose();
	g.Write("Hello");
}
```

### Variable declarations

```C#
// Define mutable variable with an explicit type and without an assignment
int val; 
// Define multiple variables with an explicit type
int a, b;
// Define mutable variable with an explicit type and an initializer
int val2 = 123;
// Define mutable variable with an implicit type and an initializer 
var val3 = 1.2f;
// Define immutable variable with an implicit type and an initializer
let val4 = 2.3;
```

### while
Repeatedly excutes a statement as long as the condition is true.

```C#
while (i >= 0)
{
	i--;
}

bool wantsMore;
repeat
{
	wantsMore = Write();
}
while (wantsMore)
```
