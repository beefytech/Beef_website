+++
title = "Initialization"
weight = 20
+++

## Initialization
For class initialization semantics, first the object is zeroed-out, then the root class field initializers are executed in declaration order, then initializer blocks are executed in declaration order, then the root class constructor is run, then executing proceeds to the derived class's field initializers, initializer blocks, and constructor and so on. Virtual method calls will dispatch to the fully derived type even when invoked in a base class's constructor, which can result in a method being called in a type whose constructor has not yet executed.

```C#

class Person
{
	public String mFirstName = GetFirstName();
	public String mLastName = GetLastName();

	public this()
	{
		AddPerson();
	}
}

class Student : Person
{
	public School mSchool = GetSchool();
	public int? mAge;

	/* Initializer blocks allow for initialization that occurs irregardless of which constructor is invoked */
	this
	{
		RegisterStudent();
	}

	public this()
	{

	}

	public this(int age)
	{
		mAge = age;
	}
}

/* When constructing a Student, the initializations will occur in this order:
	mFirstName = GetFirstName()
	mLastName = GetLastName()
	AddPerson();
	mSchool = GetSchool()
	RegisterStudent();
 */

/* Classes or structs and their inheritors or extensions can also choose to ignore all initializers and retain the nulled class or struct */
extension Person
{
	/* Adds a constructor to Person that does not call GetFirstName() or GetLastName() due to 'this(?)' */
	/* Inherited classes could similarly do this with base(?) */
	public this(String firstName, String lastName) : this(?)
	{
		/* At this point, mFirstName and mLastName are still null */
		mFirstName = firstName;
		mLastName = lastName;
		AddPerson();
	}
}
```

For struct initialization semantics, the struct is not automatically zeroed out -- the fields initializers and constructor together must fully initialize all the struct fields. Users of a struct can also choose to not execute a constructor and just manually initialize all the fields directly. Uses of structs that are not fully initialized will be disallowed via simple static analysis, which can be overriden via the explicit "?" uninitialized expression.

```C#
/* In this case, we know "UseVec" will initialize the Vector2 value so we use '?' to avoid a "Not initialized" error */
Vector2 vec = ?;
UseVec(&vec);
```

Arrays initialization at allocation time is also supported.

```C#
/* Zero-initialize ending 7 elements */
int[] iArr = new int[10] (1, 2, 3, );

/* Leave ending 7 elements uninitializezd */
int[] iArr = new int[10] (1, 2, 3, ?);

/* Throws an initializer size mismatch error - ending comma is required to zero-initialize is desired */
int[] iArr = new int[10] (1, 2, 3);
```

Value initializers let you assign values to fields and properties of values at creation time.

```C#
/* Construct a Cat, calling the default constructor, and then assign the Age and Name properties */
var cat = new Cat() { Age = 10, Name = "Fluffy" };
```

For structs, value initalizers can also be used without calling any constructors or initializer blocks.

```C#
struct WindowInit
{
	public width = 1280;
	public height;

	this
	{
		height = 720;
	}
}

/* Default contructor & value initializer: height will be 720, width will be 1280, then set to 1920 */
var init = WindowInit() { width = 1920 }

/* Is equivalent to */
var init = WindowInit();
init.width = 1920;

/* Just value initializer: height will be 0, width will be 0, then set to 1920 */
var init = WindowInit { width = 1920 }

/* Is equivalent to */
WindowInit init = default; // Struct is zeroed
init.width = 1920;
```

Value initializers also allow you to add items to collections at creation time. You can provide a list of expressions, which will be passed individually to an applicable `Add` method.

```C#
var list = scope List<int>() {1, 2, 3, 4};
var weightDict = scope Dictionary<String, float>() { ("Roger", 212.3f), ("Sam", 110.2f) };
```

Types can also define static fields and static constructors. Static initialization order is defined by alphanumeric order of the fully-qualified type name. This order can be overriden with type attributes such as [StaticInitPriority(...)] and [StaticInitAfter(...)]. Static initialization that refer to static fields in other types will cause that type's static initializers to execute on-demand before the access. This on-demand initialization can cause circular dependencies, however, which are resolved by simply skipping any reentrant initializer calls.

## Destruction

Classes can define destructors. In general, destruction occurs in reverse order from initialization.

```C#

class Person
{
	public String mFirstName = GetFirstName() ~ delete _;
	public String mLastName = GetLastName() ~ delete _;

	public this()
	{
		AddPerson();
	}

	public ~this()
	{
		RemovePerson();
	}
}

class Student : Person
{
	public School mSchool = GetSchool() ~ ReleaseSchool(_);

	public this()
	{
		RegisterStudent();
	}

	public ~this()
	{
		UnregisterStudent();
	}
}

/* When deleting a Student, the deinitialization will occur in this order:
	UnregisterStudent()
	ReleaseSchool(mSchool)
	RemovePerson()
	delete mLastName
	delete mFirstName
*/

```

Structs cannot define destructors, but they can define a 'Dispose' method which can contain deinitialization code. Dispose can be used in 'RAII-style' (called on scope exit) with `using` statements or `defer` statements.
