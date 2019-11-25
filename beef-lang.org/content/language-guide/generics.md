+++
title = "Generics"
weight = 70
+++

## Generics overview

Generics enable writing of code abstractions which can be applied to different types at compile time. List<T>, for example, is a basic list abstraction which allows for type-safe storage of values. Using a "List<int32>" type reference creates a specialized int32 list type. 

Methods can also be have generic parameters, allowing for them to be specialized either explicitly or implicitly based on callsite argument types.

```C#
public static T GetFirst<T>(List<T> list)
{
	return list[0];	
}
...
let intList = new List<int32>();
intList.Add(123);
let firstVal = GetFirst(intList);
```

Generic constraints can be specified, which describe the 'shape' of the type which the generic code is intended to work with. 

- Interface type - any number of interfaces can be specified for a generic parameter. The incoming type must declare implementations for all these interfaces.
- Class/struct type - a single concrete type can be specified, which the incoming type must derive from.
- Delegate type - the incoming type can either be an instance of this delegate type, or it can be a method reference whose signature conforms to the delegate (see Method References)
- "operator T <op> T2" - type must result from binary operation between the specified types
- "operator <op> T" - type must result from unary operation on the specified
- "operator implicit T" - type must be implicitly convertible from the specified type
- "operator explicit T" - type must be explicitly convertible from the specified type
- "class" - type must be class
- "struct" - type must be a value type
- "struct* - type must be a pointer to a value type
- "new" - type must define an accessible default constructor
- "delete" - type must define an accessible destructor
- "const" - type must be a constant value - see "Const Generics"
- "var" - type is unconstrained. This can be useful for certain kinds of "duck typing", and can generate patterns similar to C++ templates, but in general produces less useful errors and a less pleasant development experience 

```C#
public static T Abs<T>(T value) where T : IOpComparable, IOpNegatable
{
    if (value < default)
        return -value;
    else
		return value;
} 
```

```C#
/* This method can eliminate runtime branching by specializing at compile time by incoming array size */
public static float GetSum<TCount>(float[TCount] vals) where TCount : const int
{
	if (vals.Count == 0)
	{
		return 0;
	}
	else if (vals.Count == 1)
	{
		return vals[0];
	}
	else
	{
		float total = 0;
		for (let val in vals)
			total += val;
		return total;
	}
}
```