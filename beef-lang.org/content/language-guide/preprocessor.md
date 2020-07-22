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

## Built-in preprocessor symbols

* BF_32_BIT - Is targeting 32-bit target
* BF_64_BIT - Is targeting 64-bit target
* BF_ALLOW_HOT_SWAPPING - Code hot swapping is enabled
* BF_DEBUG_ALLOC - The debug allocator is being used
* BF_DYNAMIC_CAST_CHECK - Dynamic cast checks are enabled
* BF_ENABLE_OBJECT_DEBUG_FLAGS - Objects have debug flags in their header
* BF_ENABLE_REALTIME_LEAK_CHECK - Real-time leak checking is enabled
* BF_HAS_VDATA_EXTENDER - Classes have vdata extenders (for extending the vtable during hot swapping)
* BF_LARGE_COLLECTIONS - Large collections (>1GB) are enabled
* BF_LARGE_STRINGS - Large strings (>1GB) are enabled
* BF_LITTLE_ENDIAN - Target is little endian
* BF_PLATFORM_IOS - iOS target
* BF_PLATFORM_LINUX - Linux target
* BF_PLATFORM_MACOS - macOS target
* BF_PLATFORM_WINDOWS - Windows target
* BF_RUNTIME_CHECKS - Runtime checks are enabled (such as bounds checks)
* BF_TEST_BUILD - The current build is a 'test' build
* DEBUG - The current build is a 'debug' debug