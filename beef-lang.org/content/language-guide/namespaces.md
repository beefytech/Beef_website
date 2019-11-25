+++
title = "Namespaces"
weight = 30
+++

## Namespace overview
Namespaces are used in Beef to organize types and to prevent name collisions. 

```C#
namespace Gfx
{
	// Defines "Gfx.Window" class
	class Window
	{

	}

	namespace Resources
	{
		// Defines "Gfx.Resource.Image" class
		class Image
		{

		}
	}
}

namespace Gfx.Resources
{
	// Defines "Gfx.Resource.Shader" class
	class Shader
	{

	}
}

```

### Using namespaces

Although types can be referenced by their fully-qualified type name, their shorter unqualified name can be used if their containing namespaces are listed in `using` directives in that file.

```C#
using Gfx.Resources;

class Program
{
	void Use()
	{
		// Shader refers to Gfx.Resources.Shader;
		let s = new Shader();
	}
}
```
