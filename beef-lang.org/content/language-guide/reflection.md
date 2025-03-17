+++
title = "Reflection"
weight=75
+++

## Reflection
Beef supports runtime reflection, which allows enumerating and accessing types, fields, methods, and properties. By default, in the interest of smaller executables, only minimal reflection information is included. Code attributes can be used to denote additional class member information that should be emitted.

```C#
public struct Options
{
	[Reflect]
	public bool mFlag;
}

void Use(ref Options options)
{
	/* Note that we use &options here - we do this so that we are boxing a pointer to 'options' rather than boxing a copy of 'options' */
	options.GetType().GetField("mFlag").Value.SetValue(&options, true);
}
```

## Reflected Construction

Values can be created from reflection information. Some care has to be taken to ensure that the type of the value in question is actually included in builds.

```C#
/* Since we only instatiate the type through reflection, we need to force the needed data to be included */
/* If we were creating instances of TestClass somewhere in included code, the AlwaysInclude attribute wouldn't be strictly necessary here */
[Reflect(.DefaultConstructor), AlwaysInclude(AssumeInstantiated=true)]
class TestClass
{
}

void DynamicCreate()
{
	/* CreateObject() returns Result<Object>, which we can handle like this */
	if (Object obj = typeof(TestClass).CreateObject())
	{
		Console.WriteLine("Successfully created TestClass instance");
		UseObject(obj);

		/* Objects and values created through reflection are heap-allocated and need to be deleted */
		delete obj;
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

Alternatively, the effects of the `AlwaysInclude` attribute can also be put directly onto the `Scriptable` attribute itself. With the following struct, the `TestClass` only needs to have the `Scriptable` attribute.

```C#
[AttributeUsage(.Class | .Struct, .ReflectAttribute, ReflectUser=.Methods, AlwaysIncludeUser=.AssumeInstantiated | .IncludeAllMethods)]
struct ScriptableAttribute : Attribute
{
	public String mName;
	public this(String name)
	{
		mName = name;
	}
}
```

### Invoking reflected methods
```C#
[AlwaysInclude(IncludeAllMethods=true), Reflect(.Methods)]
class MethodHolder
{
	public int mIdentifier;

	static int GiveMeFive()
	{
		return 5;
	}

	public static void Print(int num, String message)
	{
		Console.WriteLine(scope $"{num}: {message}");
	}

	public void ChangeIdentifier(int newIdent)
	{
		mIdentifier = newIdent;
		Console.WriteLine(scope $"I am now number {newIdent}");
	}
}

class Program
{
	static void InvokeFuncs()
	{
		/* Invoke member methods */
		{
			let mh = scope MethodHolder();

			/* Pass 'mh' as 'target', as well as method our parameters. Note that we don't handle any errors */
			typeof(MethodHolder).GetMethod("ChangeIdentifier").Get().Invoke(mh, 14);

			Runtime.Assert(mh.mIdentifier == 14);
		}

		/* Invoke all static methods */
		int passInt = 8;
		for (let m in typeof(MethodHolder).GetMethods(.Static))
		PARAMS:
		{
			/* Pass params based on what the function takes */
			let methodParams = scope Object[m.ParamCount];
			for (let i < m.ParamCount)
			{
				Object param;
				switch (m.GetParamType(i)) /* This covers all the cases in this example */
				{
				case typeof(String):
					param = "A nice string message";
				case typeof(int):

					/* We need to box this value into an object ourselves to make sure it's not out of scope and deleted when we invoke the method */
					/* param = passInt; would implicitly box passInt, but be deleted once we leave this 'for (let i < m.ParamCount)' loop cycle */
					/* where as we need it to persist the outer "method" loop's cycle to be valid at the Invoke() call */
					param = scope:PARAMS box passInt;
				default:
					param = null;
				}

				methodParams[i] = param;
			}

			/* Invoke the method and handle the result / return value. Static methods don't have a target */
			/* Note that 'Invoke(null, methodParams)' would attempt to pass the Object[] as the only argument */
			switch (m.Invoke(null, params methodParams))
			{
			case .Ok(let val):

				/* Handle returned int variants */
				if (val.VariantType == typeof(int))
				{
					let num = val.Get<int>();
					Console.WriteLine(scope $"Method {m.Name} returned {num}");
				}

			case .Err:
				Console.WriteLine(scope $"Couldn't invoke method {m.Name}");
			}
		}
	}
}

/* Prints:
	I am now number 14
	Method GiveMeFive returned 5
	8: A nice string message
*/
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

### Comptime Type Enumeration

Enumerating types at comptime through `Type.Types` is disallowed, as the set of all types is not know until after compilation has fully completed. You are, however, able to enumerate through a workspace's type *declarations* at comptime. Type declarations do not include generic type instances, arrays, tuples, nullables, or other on-demand types, and they do not include information that is only known after the type is closed, such as size or a member list. Type declarations are not available at runtime, only comptime.

```C#
[Comptime]
int GetSerializableCount()
{
	int count = 0;
	for (var typeDecl in Type.TypeDeclarations)
	{
		if (typeDecl.HasCustomAttribute<SerializableAttribute>())
			count++;
	}
	return count;
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
