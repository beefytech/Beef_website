+++
title = "Extensions"
weight = 20
+++

## Type Extensions

Type definitions can be extended, and a user project can even extend types originally defined in the core library, even adding additional data fields. 

```C#
/* Adds a timestamp to thread creation. This can be included in user code anywhere. */
namespace System.Threading
{
	extension Thread
	{
		DateTime mCreateTime = DateTime.Now;
	}
}
```


Generic types can be conditionally extended based on matching interface constraints.

```C#
namespace System.Collections
{
	extension List<T> where T : IOpComparable
	{
		public T GetMax()
		{
			if (mSize == 0)
				return default;
			T max = this[0];
			for (let val in this)
			{
				// This '>' check would fail without the IOpComparable constraint
				if (val > max)
					max = val;
			}
			return max;
		}
	}
}
```

Extensions can be useful for adding interface conformance to types that are outside your control (ie: system types or types defined in another library).

Note that methods defined in extensions follow dependency visibility rules: a method can only be invoked if the callsite is defined in a project that has a dependency on the project defining the method, or if a generic argument is defined in a project that has a dependency on the project defining the method. This also applies to operator overloads -- if you provide an `operator==` overload for `System.Collections.List<T>`, for example, that overload will not be called on `List<T>` quality comparisons performed within `corlib` or other libraries.

Extensions can provide constructors, destructors, and field initializers.

```C#
namespace System.Collections
{
	extension List<T>
	{		
		public int mID = GetId();

		/* Visibility of this constructor follows the visibility rules noted above. */
		/* We still want the root definition's constructor's initialization, so we can still call that. Note that without `[NoExtension]` we would be calling ourselves */
		public this() : [NoExtension]this()
		{

		}
		
		/* This initializer block will always run no matter which constructor is invoked */
		this
		{
			RegisterList(this);
		}

		/* This destructor will run before the root definition's destructor */
		public ~this()
		{
			UnregisterList(this);
		}
	}
```

Extensions can also be used for inverting dependencies between projects by providing method declarations whose implementations are provided by dependent projects. This technique provides a static dispatch alternative to virtual methods.

```C#
/* In project 'Engine' */
class Platform
{
	public extern Texture CreateTexture();
}

/* In project 'DirectXEngine' */
extension Platform
{
	public override Texture CreateTexture()
	{
		return new DirectXTexture();
	}
}
```

We can also use extensions to override virtual methods without requring subclassing. This has the advantage of not requiring an overload but has the downsize of dynamic dispatch.

```C#
/* In project 'Engine' */
class Platform
{
	public virtual Texture CreateTexture() => null;
}

/* In project 'DirectXEngine' */
extension Platform
{
	public override Texture CreateTexture()
	{
		return new DirectXTexture();
	}
}
```

## Extension Methods

Method extensions can be used to virtually add methods to existing types without modifying the original type. Extension methods are static methods, but they are called as if they are non-static methods on an extended type, or a type that conforms to a set of generic constraints. Extension methods can be preferable over type extensions when you want to limit the scope of a given method to a particular namespace or utility method, or when the method is intended to apply to a broad range of types conforming to specific generic constraints.

```C#


/* This provides a CharCount method in String in total global namespace */
static
{
	public static int CharCount(this String str, char8 c)
	{
		int total = 0;
		for (let checkC in str.RawChars)
			if (checkC == c)
				total++;
		return total;
	}
}

/* This provides a Total method in List<T> for any T that can be added together. 
 This method is only visible when explicitly importing this type with 'using static'  */ 
static class ListUtils
{
	public static T Total<T>(this List<T> list) where T : IOpAddable
	{
		T total = default;
		for (let val in list)
			total += val;
		return total;
	}
}

/*************************************************/

int charCount = "Test string".CharCount('s');

using static ListUtils;
int GetListTotal(List<int> list) => list.Total();


```
