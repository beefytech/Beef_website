+++
title = "Interfaces"
weight = 3
+++

## Interface overview

Interfaces define property and method requirements that classes or structs can implement. Interfaces can be used to dynamically dispatch, or interfaces can be used as constraints in generic programming (see Generics section).

```C#
interface IDrawable
{
	void Draw();
}

struct Circle : IDrawable
{
	float x;
	float y;
	float radius;

	/* Implements IDrawable.Draw 
	If we wanted to keep the Draw method as a private implementation, we could have declared it as 
	"private void IDrawable.Draw()" */
	public void Draw()
	{
		DrawCircle(x, y, radius);
	}
}

/* Calling the following method with an instance of Circle will first cause boxing to occur at the
 callsite, then Draw will be called via dyanmic dispatch (method table) */
public static void DrawDynamic(IDrawable val)
{
	val.Draw();
}

/* Calling the following method with an instance of Circle will create a specialized instance of 
the DrawGeneric method which accepts a Circle argument and statically calls the Circle.Draw
 method, which is faster */
public static void DrawGeneric<T>(T val) where T : IDrawable
{
	val.Draw();
}
```

### Default method implementations
Interfaces can define default implementations of methods by adding a body. This can be important for adding methods to existing interfaces without breaking users of those interfaces.

### Concrete returns
Interfaces methods can be declared to return a concrete implementation of a specific interface. These methods cannot be used for dynamic dispatch since the specific return type is not defined. This is important for allowing returning valuetype instances and for avoiding dynamic method dispatching, which would be required if the implementing method returned an interface instance reference.

```C#
concrete interface IEnumerable<T>
{
    concrete IEnumerator<T> GetEnumerator();
}
```
