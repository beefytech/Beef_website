+++
title = "Extensions"
weight = 2
+++

## Extensions

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
namespace System.Collections.Generic
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
