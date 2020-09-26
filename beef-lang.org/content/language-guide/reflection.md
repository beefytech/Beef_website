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

### Reflection from Interface
```C#
/* All implementers of this interface will have dynamic boxing available */
[Reflect(.None, ReflectImplementer=.DynamicBoxing)]
interface ISerializable
{
	void Serialize(Stream stream);
}

namespace System
{
	extension StringView : ISerializable
	{
		void ISerializable.Serialize(Stream stream)
		{
			stream.Write(mLength);
			stream.TryWrite(.((uint8*)mPtr, mLength));
		}
	}
}

class Serializer
{
	public void Serialize(Variant v, Stream stream)
	{
		ISerializable iSerializable;
		if (v.IsObject)
			iSerializable = v.Get<Object>() as ISerializable;
		else
		{
			/* 'v.GetBoxed' works for types implementing ISerializable because of the 'ReflectImplementer=.DynamicBoxing' attribute */
			iSerializable = v.GetBoxed().GetValueOrDefault() as ISerializable;
			defer:: delete iSerializable;
		}
		iSerializable?.Serialize(stream);
	}
}
```

### Distinct Build Options

Reflection information can be configured in workspaces and projects under Distinct Build Options. For example, if you need `Add` and `Remove` methods reflected for all `System.Collection.List<T>` instances, you can add a `System.Collections.List<*>` under Distinct Build Options: 
	* Set "Reflect\Method Filter" to "Add;Remove" to ensure the settings only apply to those methods
	* Set "Reflect\Always Include" to "Include All" to ensure the specified methods get compiled into the build even if they werent't explicitly used
	* Set "Reflect\Non-Static Methods" to "Yes" to ensure the specified non-static methods have reflection information added

The Distinct Build Options filter can support:
	* Type name matching (ie: `System.Collections.List<*>`)
	* Type attribute matching (ie: `[System.Optimize]`)
	* Interface implementation matching (ie: `:System.IDisposable`)

### Dynamic Boxing

`Variant.GetBoxed` can be used to create a heap-allocated dynamically. The call will fail if the compiler has not generated the box type for the stored valuetype either through on-demand compilation or through reflection options by annotated the valuetype with `[Reflect(.DynamicBoxing)]` or setting the "Dynamic Boxing" reflection setting in Distinct Build Options.

### Common Reflection Issues

Beef strives to produce the smallest executables possible -- a "Hello World" program should ideally only contain the absolute minimum machine code and data in the resulting executable to print "Hello World" and nothing else. If you were to add functionality to that application to allow the user to pass in a type name and a method name and you expect to be able to construct that type and call that method based on reflection information, that would clearly be impossible unless the executable contained machine code and reflection information for every single method defined in the corlib, which would violate the "minimum binary" ideal.

Firstly, Beef includes types on demand, so reflection information for any type that is not directly used by your program will not be included in the build. Add the `[AlwaysInclude]` attribute to force this type to be included in all builds. If you want to dynamically construct it, use `[AlwaysInclude(AssumeInstantiated=true)]`. Individual methods are also compiled on demand, but you can force every method to be included in the build with `[AlwaysInclude(IncludeAllMethods=true)]`.
