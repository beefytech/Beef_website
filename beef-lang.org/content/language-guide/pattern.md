+++
title = "Pattern matching"
weight=75
+++

### Pattern matching overview

Pattern matching allows for either simple quality checks, or for creating a combination of member equality checks, member captures, and member 'ignores' for tuples and enum values in switches and case expressions.

### Tuple pattern matching

```C#

void TupleCaseExpr()
{
	let tup = (1.2, "Abc");

	// This performs one equality check and one member capture
	if (tup case (1.2, let str))
	{
		UseStr(str);
	}
}

void TupleSwitch()
{
	let tup = (x: 10, y: 20, str:"Abc");

	switch (tup)
	{
	case (0, 0, let drawStr):
		DrawAtOrigin(drawStr);
	case (var drawX, var drawY, let drawStr):
		/* Since drawX and drawY are 'var' the are mutable, whereas drawStr is immutable */
		drawX += 10;
		drawY += 20;
		Draw(x, y, drawStr);
	}
}
```

### Enum pattern matching {#enum}

```C#
enum Shape
{
	case Rectangle(int x, int y, int width, int height);
	case Circle(int x, int y, int radius);
}

void EnumCase()
{
	Shape shape = .Circle(10, 20, 30);

	/* One enum discriminator check, two member equality checks, and one member captures */
	if (shape case .Circle(0, 0, let radius))
	{
		DrawCircleAtOrigin(radius);
	}

	/* One enum discriminator check, and three member captures */
	else if (shape case .Circle(let x, let y, let radius))
	{
		DrawCircle(x, y, radius);
	}

	/* One enum discriminator check, and two member captures, one member ignore */
	else if (shape case .Circle(let x, let y, ?))
	{
		DrawPoint(x, y);
	}

	/* Enum discriminator check, no member checks or captures*/
	if (shape case .Rectangle)
	{
		IgnoreRectangle();
	}
}

/* This is equivalent to the EnumCase method */
void EnumSwitch()
{
	Shape shape = .Circle(10, 20, 30);
	switch (shape)
	{
	case .Circle(0, 0, let radius):
		DrawCircleAtOrigin(radius);
	case .Circle(let x, let y, let radius):
		DrawCircle(x, y, radius);
	case .Rectangle:
		IgnoreRectangle();
	}
}

```

Enums can also pattern match to a 'ref', allowing modification of the underlying values.

``` C#

void Enlarge(ref Shape shape)
{
	switch (shape)
	{
	case .Circle(?, ?, var ref radius):
		radius++;
	case .Rectangle(?, ?, var ref width, var ref height):
		width++;
		height++;
	}
}

```


### Value matching
