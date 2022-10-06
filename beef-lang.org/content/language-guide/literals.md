+++
title = "Literals"
weight = 75
+++

## Integer literals

Integers can be represented as decimal, hexadecimal, octal, or binary. In addition, the separator character `'` (single quote) can be used to separate numbers any way the user desires.

```C#

// Decimal numbers
int dec = 1234;
int dec2 = 12'345'678;

// Hexadecimal
int hex = 0x12345678;
int hex2 = 0x1235'5678;

// Octal
int oct = 0o666;

// Binary
uint32 bin = 0b'1111'0000'1111'0000;
```

Suffixes can be added to explicitly specified size and signedness. Integer literals are limited to 32-bits unless a size specifier is used or if there is at least one separator character specified.

```C#
let val = 123U; // Results in an 'uint'
let val2 = 234L; // Results in an 'int64'
let val3 = 0x12'34567890; // Results in an `int64`
let val4 = 0x1234567890; // ERROR- either an 'L' or '`' is required
```

When no size specifiers are used, integer literals do not inherently have a specific size; their size will depend on the context in which they are used:

* Integer literals can be implicitly cast to any integer size that fits the value.
* When used as an argument to a method with overloads, the method with the smallest applicable integer size will be selected.
* If no specific integer type can be determined, the first of the following types that fits the value will be used: int, uint, int64, uint64.


## Floating point literals

Floating point literals are considered to be `double` unless they end with an `f`.

```C#
let f = 1.2f; // Float
let d = 2.3; // Double
```

## Boolean literals

Boolean literals are `true` or `false`.

## String literals {#string}

Strings can be single-line or multi-line, and raw or escaped. Raw strings allow embedding the backslash character without it being interpreted the start of a "special character" sequence.

```C#
String str = "Normal string";
String str2 = @"Raw string with \ slashes";
String str3 = 
	"""
	Multiline string literal
		with a tabbed second line;
	""";
String str4 = 
	@"""
	Multiline raw string literal
	with embedded \slashes\;
	""";
String str = scope $$"""
	/* The '$$' means embedded values need to be wrapped with {{ }}, allowing us to not escape { and } for normal text. */
	/* If we used `$$$` then values would need {{{ }}} */
	void SetDefault()
	{
		{{fieldName}} = default;
	}
	""";
```

## Character literals

Character literals can either be char8 or char32, depending on their integral value.

```C#
let c = 'A'; //char8
let c = '🐱'; //char32 
```

## Special characters in string and character literals

* \0 - Null character
* \\\\ - Backslash
* \u{n} -Unicode character
* \xNN - hexadecimal character 0xNN
* \t - Horizontal tab
* \n - line feed
* \r - carriage return
* \" - double quote mark
* \' - single quote mark