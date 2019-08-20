+++
title = "Literals"
+++

## Integer literals

Integers can be represented as decimal, hexadecimal, octal, or binary. In addition, the seperator character `'` (single quote) can be used to seperate numbers any way the user desires. A seperater character immediately following the hex `0x` specifier explicitly means to interpret the number as a 64-bit integer, however, and is generally used for displaying 64-bit addresses in Beef.

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

Suffixes can be added to explicitly specified size and signedness.

```
let val = 123U; // Results in an 'uint'
let val2 = 234L; // Results in an 'int64'
```

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