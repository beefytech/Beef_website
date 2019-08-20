+++
title = "Preprocessor"
+++

## Preprocessor
The Beef preprocessor is intended for conditionally including blocks of text before the parser runs over it and modifying warning options. It is much less flexible than the C preprocessor and cannot be used for implementing macros or for other "code generation" purposes.

* #define <X> - sets the symbol value "X" to true 
* #endif - ends a #if, #else, or #elif block
* #else - processes the block down to the next #endif if the previous #if/#elif was false 
* #elif <X> - processes the block down to the next #endif if the previous #if/#elif was false and "X" is true
* #error <Message> - Created error at parse time
* #if <X> - processes the block down to the next #endif if "X" is true
* #pragma warning disable <X> - disable warning number X
* #pragma warning restore <X> - restore warning number X
* #undef <X> - sets the symbol value "X" to false
* #unwarn - disables the warning on the next source code line.
* #warn <Message> - Creates warning at parse time