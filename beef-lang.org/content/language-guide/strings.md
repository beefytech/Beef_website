+++
title = "Strings"
weight=80
+++

### Strings Overview
The String type in Beef is a mutable object with an adjustable "small string optimization" buffer, which stores character data in UTF8. `StringView` is a `Span<char8>` pointer-and-length struct. By convention, methods take string input through a `StringView` argument, and methods that want to return string data take a `String` argument which is used to append string data to.

String literals within a workspace that have equal values are guaranteed to be pooled and will have equal object addresses, and the pointer to the null-terminated C string pointer obtained through the `char8*` cast operator or the `CStr()` method are guaranteed to have the equal addresses. Generated strings whose value matches a literal are guaranteed to return that literal's address when passed through `String.Intern()`.

```C#
String str = "This is a string";
char8* cStr = "This is a C string";
String str2 = "This string contains\n Two lines";
String str3 = @"C:\Path\Literal\NoSlashing";
String str4 =
	"""
	Multiline string literal
		with a tabbed second line;
	""";
```

See [Literals]({{< ref "literals.md#string" >}}) for more information about string literals.

### String Interpolation

String interpolation is supported for either string allocations or string argument expansion.

```C#
/* This is equivalent to scope String()..AppendF("X = {} Y = {}", GetX(), GetY()) */
String str = scope $"X = {GetX()} Y = {GetY()}";

/* This is equivalent to Console.WriteLine("X = {} Y = {}", GetX(), GetY()) */
Console.WriteLine($"X = {GetX()} Y = {GetY()}");
```

### String Comparison

|Name           |Sizable non-dynamic buffer           |Custom dynamic allocator|Encoding          |
|---------------|-------------------------------------|------------------------|------------------|
|C char array   | Yes (user-specified array size)     | N/A (no allocation)    | char/wchar*      |
|C++ std::string| No (fixed small buffer optimization)| Template argument      | char/wchar*      |
|C# StringBuffer| No                                  | No                     | UTF16            |
|Beef           | Yes                                 | Virtual override       | UTF8             |

Beef is the only string besides a C char array that allows you to create non-small strings (> 32 bytes) entirely on the stack: `var str = scope String(1024)` constructs a String on the stack with a 1024-character internal buffer, for example. For sizing beyond the internal string buffer, you can integrate with a custom allocator by subclassing the String class and overriding the Alloc/Free methods. In C++, custom allocators for strings are provided by a template argument to `std::basic_string`, which means that a string with a custom allocator simply cannot be passed to methods expecting a `std::string` since the types no longer match. For character encoding, C/C++ does not define any encoding for characters in their strings, so it's left up to the user to handle all encoding issues. In C#, string characters are UTF16 for historic reasons, which in many ways is the "worst of both worlds" of encoding and size because the user still must deal with UTF16 surrogate pairs (a single unicode character split into two UTF16 characters), but UTF16 strings are almost always larger than their UTF8 counterparts (even when dealing solely with Asian languages).

### Ease of use

The [Argument cascade operator]({{< ref "operators.md#unary" >}}) can be especially useful when working with strings. To give the user control over allocations, strings are usually passed into methods where they are modified. For the most part, these methods return void, which means that you don't miss out on any return values, though methods that return Result<T> can not be properly handled this way.

```C#
void ToString(String strBuffer)
{
	strBuffer.Append("Count: ");
	count.ToString(strBuffer);
}

{
	let printString = scope String();
	ToString(printString);
	Console.WriteLine(printString);

	/* Equivalent to code above. ToString is made to return the String we pass in */
	let printString2 = ToString(.. scope String());
	Console.WriteLine(printString2);

	/* Equivalent one-liner. '.' can be used to infer 'String', since the type passed into ToString is unambiguous */
	Console.WriteLine(ToString(.. scope .()));
}

{
	let filePath = Path.InternalCombine(.. scope .(), rootDir, "Folder", "file.bin");
}
```

### Common String Mistakes

```C#
/* WRONG - string literals exist in read-only memory and cannot be modified */
String newString = "Hello, ";
newString.Append(name);

/* RIGHT */
String newString = scope String()..AppendF("Hello, {}", name);
/* RIGHT - this is equivalent to the code above */
String newString = scope $"Hello, {name}";
```

```C#
/* WRONG - removes allocation control from the user, and the burden of releasing this memory is placed on the caller */
String GetName()
{
	return new String("Brian");
}

/* EVEN MORE WRONG - this memory goes out of scope on return, you cannot pass stack-allocated memory back to the caller */
String GetName()
{
	return scope String("Brian");
}

/* RIGHT - note the use of Append, this helps the user avoid creating temporary strings that need to be concatenated later */
void GetName(String outName)
{
	outName.Append("Brian");
}
```

```C#
/* WRONG - string values cannot be added */
String strC = strA + strB;
/* RIGHT - allocation provided */
String strC = scope $"{strA}{strB}";
/* RIGHT - string constants can be added because the result is another string constant - no allocation is needed at runtime */
String strC = "A" + "B";
/* RIGHT - equivalent to strC.Append(strA) */
strC += strA;
```
