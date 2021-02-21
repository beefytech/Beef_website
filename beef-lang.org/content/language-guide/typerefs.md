+++
title = "Type References"
weight=80
+++

### Special type references

* Self - the defining type. If used within an interface, it refers to the implementing type.
* SelfBase - the base class of the defining type
* SelfOuter - the outer type of the defining type 
* var/let - used with type inference when creating variables, `var` is used to create a mutable variable, whereas `let` creates a const or read-only variable
* . - The `.` type is used with type inference, and refers to "the expected type". The most common use is to change an implicit conversion into an explicit conversion without specifying the type name. (ie: intVal = (.)floatVal)
