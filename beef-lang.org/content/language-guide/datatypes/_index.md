+++
title = "Data Types"
weight = 3
alwaysopen = true
+++

## Primitive data types
The following primitive types are available in Beef:

#### Integer types

* int
* int8
* int16
* int32
* int64
* uint
* uint8
* uint16
* uint32
* uint64

The native platform integer width is used for int and uint, and these are treated as unique types and not just aliases to their explicitly-sized counterparts (ie: int64/uint64).

#### Floating point types

* float
* double

#### Character types

Character types only specify size but not encoding. The char8 data type, for instance, may be used to specify a byte of UTF8 data or an ASCII character, depending on context.

* char8
* char16
* char32

#### Valueless type

* void

#### Boolean type

* bool

## Structs
Struct types are user-defined collections of values, similar to structs in C. Structs can contain fields, properties, methods, and can define other inner types. For C++ programmers, structs are C++ PODS and cannot contain virtual methods or copy constructors. 

```C#
struct Vector
{
	public float x;
	public float y;

	// Default constructor - constructors must set all fields
	// "this = default;" is equivalent to "x = 0; y = 0;"
	public this()
	{
		this = default;
	}

	// Constructor that takes values
	public this(float x, float y)
	{
		this.x = x;
		this.y = y;
	}

	// Property to calculate the Length
	public float Length
	{
		get
		{
			return Math.Sqrt(x*x + y*y);
		}
	}

	// Methods of structs need to be declared as 'mut' to be able to modify the struct
	public void SetZero() mut
	{
		x = 0;
		y = 0;
	}
}
```

Structs can be zero-sized, which allows for efficient use of some types of generic patterns which require other approaches in C++ which doesn't allow zero-sized structs. Also, Beef structs are designed to provide fewer "alignment holes" than their C counterparts: fields are ordered by field alignment size (but otherwise in declaration other), and struct size and stride are seperate concepts in Beef whereas C struct size is always aligned to the largest element alignment, thus is equivalent to stride in C. Field reordering can be disabled with the [Ordered] attribute, and structs can be marked for full C interop with [CRepr]. Field alignment packing can be disabled with [Packed]. Unions can be created with [Union].

```C#
	struct StructA
	{
		int32 i;
		int64 j;
	}

	struct StructB : StructA
	{
		int8 k;
	}

	struct StructC : StructB
	{
		int8 l;
	}

	/* In Beef, StructC only occupies 14 bytes but in C it is either 24 or 32 bytes 
	 (implementation dependent).
	
	 Beef:
	 sizeof(StructA) = 12 strideof(StructA) = 16
	 sizeof(StructB) = 13 strideof(StructB) = 16 
	 sizeof(StructC) = 14 strideof(StructC) = 16
	 
	 C/C++:
	 sizeof(StructA) = 16
	 sizeof(StructB) = 24
	 sizeof(StructB) = 32 (or 24)
	 
	 In Beef, the data size is smaller due to field reordering eliminating alignment 
	 padding. In C, the 'k' field byte added in StructB causes an 	  extra 7 bytes of 
	 padding. The 'l' field byte added in StructC creates yet another 7 bytes of padding 
	 on some compilers (VC) while other compilers will fit 'l' into the previous padding 
	 (Clang/GCC). */
```

Opaque struct definitionss can be created by simply not supplying a body, which create types that can be used for interop which disallows direct allocation (since the size is unknown).


## Tuple types {#tuples}

Tuples are a different kind of struct. Their syntax allows for more concise representation of certain types of code patterns, but they cannot define properties or methods.

```C#
let tup = (1, 2); // Unnamed members
int sum = tup.0 + tup.1; // Access by position
let (first, second) = tup; // Decompose into new variables
let coords = (x: 2, y: 3); // Named members
let len = Math.Sqrt(coords.x*coords.x + coords.y*coords.y); // Access by name 
 ```

Tuples allow for implicit conversions where, field by field, the types are the same and one of the fields is named and the other field is unnamed.

## Class
Classes are reference types (as in C#, Swift, and Java) and are conceptually similar to structs, but they are always prefixed with a typeclass pointer which is used for virtual method calls, dynamic typing, and dynamic interface dispatching. All user classes derive from the System.Object class at their root.

```C#
abstract class Shape
{
	float x;
	float y;

	public abstract void Draw();
}

class Circle : Shape
{
	float radius;

	public override void Draw()
	{
		DrawCircle(x, y, radius);
	}

	// Unlike structs, methods that modify classes do not need to be declared as 'mut'
	public void DoubleSize()
	{
		radius *= 2;
	}
}
```

Classes can define destructors, and individual fields can define field destructors, which are a convenience to more closely associate their destruction with their initialization.

```C#
public Button : Widget
{
	String mLabel = new String() ~ delete _; // "_" is an alias to "mLabel" here 

	public ~this()
	{
		RemoveWidget(this);

		// Field destructors run after this, reverse of initialization order
	}
}
```

### Arrays

There are several forms of arrays supported in Beef. Array classes, sized array types, Spans, and raw pointers. 

```C#
/* Allocates a float array class */
float[] floatArr = new float[3];  

/* Allocates a 2D float array class */
float[,] floatArr2D = new float[3, 2];  

/* This is a fixed-size array, which is much like a tuple with four values */
float[4] sizedFloatArr = .(100, 200, 300, 400);

/* A span is a ptr/size value type pair */
Span<float> floatSpan = floatArr;

/* Raw pointer. The "*" at the end denotes a raw array allocation rather than a float[] object */
float* floatPtr = new float[3]*;
```

### Enums
Enum types in Beef can be used to represent a collection of named integral constants.

```C#
enum Direction
{
	North,
	East,
	South,
	West
}
// Note that we did not need to fully qualify "Direction.South", because the "Direction" was the expected type of the initializer so it was already inferred
Direction facing = .South;
```

Enums can also be defined in a more verbose syntax that allows adding methods, properties just like you would to struct value types.

```C#
enum Direction
{
	case North;
	case East;
	case South;
	case West;

	public Direction Opposite
	{
		get
		{
			switch (this)
			{
			case .North: return .South;
			case .East: return .West;
			case .South: return .North;
			case .West: return .East;
			}
		}
	}
}
```

Enums can allow for multiple values to behave as a set of flags, as well, and support type-safe bitwise binary operations and define a convenience "HasFlag" method to check if a given set of flags is set or not.

Enums can also define associated data for each case, which makes them behave as a type-safe "discriminated" union.

```C#
enum Shape
{
	case None;
	case Square(int x, int y, int width, int height);
	case Circle(int x, int y, int radius);
}
Shape drawShape = .Circle(10, 20, 5);
...
switch (drawShape)
{
case .None:
case .Square(let x, let y, let width, let height): DrawSquare(x, y, width, height);
case .Circle(let x, let y, let radius): DrawCircle(x, y, radius); 
}
....
if (drawShape case .Square)
	Console.WriteLine("We drew a square");
```

### Nullable types

Nullable types are an enum wrapper around value types (System.Nullable<T>), which allows for value types to use null semantics which usually only work for pointer and reference types.

```C#
int? val = null;
int i = val ?? 21;
if (val == null)
	val = 42;
```

