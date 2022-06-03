+++
title = "Debugger Expressions"
+++

## Debugger watch expressions

The debugger watch evaluator is capable of evaluating most normal Beef expressions, including accessing properties and calling methods. 
In addition to those expressions, there are some special watch expressions supported.

|Expression|Description|
|----|------|
|{&lt;number>} &lt;expr> or {^&lt;number>} &lt;expr>|Evaluate expression &lt;number> entries up the call stack|
|{MethodName} &lt;expr>|Evaluate expression in the first method named MethodName up the call stack|
|{MethodName^&lt;number>} &lt;expr>|Evaluate expression in the method number &lt;number> named MethodName up the call stack|
|{*} &lt;expr>|Evaluate expression in the first call stack scope where the expression is valid|

## Format flags

The following flags can be added after a watch expression, separated by commas.

|Flag|Description|
|----|------|
|this=&lt;expr>|Set explicit 'this' value for expression|
|arraysize=&lt;number>|Display the expression as an array with &lt;number> elements|
|&lt;number>|Display the expression as an array with &lt;number> elements|
|d|Decimal|
|s|Ascii|
|s8|UTF8|
|s16|UTF16|
|s32|UTF32|
|na|Hide pointers|
|nv|No visualizers|
|x|Hexadecimal (lowercase)|
|X|Hexadecimal (uppercase)|