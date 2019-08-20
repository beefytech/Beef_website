+++
title = "Reflection"
+++

## Reflection
Beef supports runtime reflection, which allows enumerating and accessing types, fields, methods, and properties. By default, in the interest of smaller executables, only minimal reflection information is included. Code attributes can be used to denote additional class member information that should be emitted.

```C#
public class Options
{
	[Reflect]
    public bool mFlag;
}

void Use(Options options)
{
	options.GetType().GetField("mFlag").Value.SetValue(options, true);
}
```
