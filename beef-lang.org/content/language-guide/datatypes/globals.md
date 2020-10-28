+++
title = "Globals"
+++

### Globals
	
Global variables can be considered static fields of an unnamed type. Global methods and mixins can also be defined.

```C#
static
{
	public static int gGlobalVal = 0;
}
```

The conciseness of global variables can be matched on a file level with `using static`, which allows direct usage of static fields outside the current type.

```C#
class Image
{
	public static int sImageCount;
}

using static Image;

class Program
{
	public void Use()
	{
		// This static usage would normally require a fully-qualified "Image.sImageCount";
		int imgCount = sImageCount;
	}
}

```