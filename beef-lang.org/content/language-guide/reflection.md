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

## Reflected Construction

Values can be created from reflection information. 

```C#
[Reflect(.Methods)]
class TestClass
{
}

void DynamicCreate()
{
	if (Object obj = typeof(TestClass).CreateObject())
	{
		UseObject(obj);
	}
}
```

### Reflecting on Custom Attributes
```C#
/* This attribute will show up in the user's reflection information, and users of this attribute will have all their used method's reflection information exported' */
[AttributeUsage(.Class | .Struct, .ReflectAttribute, ReflectUser=.Methods)]
struct ScriptableAttribute : Attribute
{
	public String mName;
	public this(String name)
	{
		mName = name;
	}
}

/* This class will have a default constructor available for reflection, and all methods defined will be included in the build even though they are not directly called */
[Scriptable("Main Test Class"), AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
class TestClass
{
	public static void Test()
	{
		Console.WriteLine("TestClass.Test");
	}
}

class Program
{
	public static void Main()
	{
		for (let type in Type.Types)
		{
			if (let scriptableAttribute = type.GetCustomAttribute<ScriptableAttribute>())
			{
				for (let method in type.GetMethods(.Static))
				{
					Console.WriteLine("Calling method {} on {}", method.Name, scriptableAttribute.mName);
					method.Invoke(null);
				}
			}
		}
	}
}
```

### Common Reflection Issues

Beef strives to produce the smallest executables possible -- a "Hello World" program should ideally only contain the absolute minimum machine code and data in the resulting executable to print "Hello World" and nothing else. If you were to add functionality to that application to allow the user to pass in a type name and a method name and you expect to be able to construct that type and call that method based on reflection information, that would clearly be impossible unless the executable contained machine code and reflection information for every single method defined in the corlib, which would violate the "minimum binary" ideal.

Firstly, Beef includes types on demand, so reflection information for any type that is not directly used by your program will not be included in the build. Add the `[AlwaysInclude]` attribute to force this type to be included in all builds. If you want to dynamically construct it, use `[AlwaysInclude(AssumeInstantiated=true)]`. Individual methods are also compiled on demand, but you can force every method to be included in the build with `[AlwaysInclude(IncludeAllMethods=true)]`.

