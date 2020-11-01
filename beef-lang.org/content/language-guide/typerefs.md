+++
title = "Type References"
+++

### Special type references

* Self - only valid within a definition of a class or struct, and refers to the defining type. If used within an interface, it refers to the implementing type.
* var/let - used with type inference when creating variables, `var` is used to create a mutable variable, whereas `let` creates a const or read-only variable
* . - The `.` type is used with type inference, and refers to "the expected type". The most common use is to change an implicit conversion into an explicit conversion without specifying the type name. (ie: int intVal = (.)floatVal;)
