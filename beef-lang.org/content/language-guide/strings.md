+++
title = "Strings"
+++

### Strings Overview
The String type in Beef is a mutable object with an adjustable "small string optimization" buffer, which stores character data in UTF8. `StringView` is a `Span<char8>` pointer-and-length struct. By convention, methods take string input through a `StringView` argument, and methods that want to return string data take a `String` argument which is used to append string data to. 

String literals within a workspace that have equal values are guaranteed to be pooled and will have equal object addresses, and the pointer to the null-terminated C string pointer obtained through the `char8*` cast operator or the `CStr()` method are guaranteed to have the equal addresses. Generated strings whose value matchs a literal are guarnteed to return that literal's address when passed through `String.Intern()`.

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