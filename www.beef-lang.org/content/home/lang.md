+++

title = "Language Features"
weight = 10
widget = "blank"
headless = true  # This file represents a page section.
active = true  # Activate this widget? true/false

[design]
columns = "1"

+++

{{< rawhtml >}}

<style>
.hljs {	
	background-color:#e0e0e0;
}

div.Example {
	display: none;
	position: relative; 
	top: 4px;
	width: 400px;
}

.hljs-title, .hljs-section, .hljs-selector-id {
    color: #458;
    font-weight: bold;
}

</style>

<table>
<tr>
<td width=400px style="vertical-align: top;">
<ul>
<li>C/C++ interop with static and dynamic libs</li>
<li>Custom allocators</li>
<li>Batched allocations</li>
<li>Compile-time function evaluation</li>
<li>Compile-time code generation</li>
<li>Tagged unions</li>
<li>Generics</li>
<li>Tuples</li>
<li>Reflection</li>
<li>Properties</li>
<li>Lambdas</li>
<li>Valueless method references</li>
<li>Defer statements</li>
<li>SIMD support</li>
<li>Type aliases</li>
<li>Type extensions</li>
<li>Pattern matching</li>
<li>Ranges</li>
</ul>
</td>
<td width=300px bgcolor=#aaaa80 style="vertical-align: top;">
<ul>
<li>String interpolation</li>
<li>Argument cascades</li>
<li>Mixin methods</li>
<li>Interfaces</li>
<li>Custom attributes</li>
<li>Immutable values</li>
<li>Operator overloading</li>
<li>Namespaces</li>
<li>Bitsets</li>
<li>Atomics</li>
<li>Checked arithmetic</li>
<li>Value boxing</li>
<li>Dynamic FFI</li>
<li>Local methods</li>
<li>Preprocessor</li>
<li>Guaranteed inlining</li>
<li>Incremental compilation</li>
<li>Built-in testing</li>
</ul>
</td>
<td style="vertical-align: top;">
<select id="ExampleSelect" style="width: 100%;">
</select>

<!-------------------------------------------------------------------------------------->
<div id="Hello World" class="Example">
{{< /rawhtml >}}
```C#
using System;

class Program
{
	public static void Main()
	{
		Console.WriteLine("Hello, World!");
	}
}
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="File IO and error handling" class="Example">
{{< /rawhtml >}}
```C#
// Try! propagates file and parsing errors down the call stack
static Result<void> Parse(StringView filePath, List<float> outValues)
{
	var fs = scope FileStream();
	Try!(fs.Open(filePath));
	for (var lineResult in scope StreamReader(fs).Lines)
	{
		for (let elem in Try!(lineResult).Split(','))
			outValues.Add(Try!(float.Parse(elem)));
	}
	return .Ok;
}
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Tuples" class="Example">
{{< /rawhtml >}}
```C#
// Method returning a tuple
(float x, float y) GetCoords => (X, Y);

var tup = GetCoords;
if (tup != (0, 0))
	Draw(tup.x, tup.y);

// Decompose tuple
var (x, y) = GetCoords;
Draw(x, y);
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Ranges" class="Example">
{{< /rawhtml >}}
```C#
for (let i in 10...20)
	Console.WriteLine($"Value: {i}");

let range = 1..<10;
Debug.Assert(range.Contains(3));

Span<int> GetLast10(List<int> list) => list[...^10];
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Strings" class="Example">
{{< /rawhtml >}}
```C#
// Allocate a string with a 4096-byte internal UTF8 buffer, all on the stack
var str = scope String(4096);

// String interpolation, formatting in 'x' and 'y' values
var str2 = scope $"x:{x} y:{y}";

// Create a view into str2 without the first and last character
StringView sv = str2[1...^1];

// Get a pointer to a null-terminated C string
char8* strPtr = str2;
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Tagged unions (aka enums with payloads)" class="Example">
{{< /rawhtml >}}
```C#
enum Shape
{
	case None;
	case Square(int x, int y, int width, int height);
	case Circle(int x, int y, int radius);
}

Shape drawShape = .Circle(10, 20, 5);

switch (drawShape)
{
case .Circle(0, 0, ?):
	HandleCircleAtOrigin();
case .Circle(let x, let y, let radius):
	HandleCircle(x, y, radius);
default:
}

if (drawShape case .Square)
	HandleSquare();
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Local functions" class="Example">
{{< /rawhtml >}}
```C#
void Draw(List<Variant> values)
{
	int idx = 0;
	float NextFloat()
	{
		return values[idx++].Get<float>();
	}
	DrawCircle(NextFloat(), NextFloat(), NextFloat());
}
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Batched allocations (aka append allocations)" class="Example">
{{< /rawhtml >}}
```C#
// This class uses 'append' allocations, which allows a single "batch" 
//  allocation which can accomodate the size of the 'Record' object, the 
//  'mName' String (including character data), and the 'mList' list, 
//  including storage for up to 'count' number of ints
class Record
{
	public String mName;
	public List<int> mList;

	[AllowAppend]
	public this(StringView name, int count)
	{
		var nameStr = append String(name);
		var list = append List<int>(count);

		mName = nameStr;
		mList = list;
	}
}

// The following line results in a single allocation of 80080 bytes
var record = new Record("Record name", 10000);
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Interop" class="Example">
{{< /rawhtml >}}
```C#
[CRepr]
struct FileInfo
{
	c_short version;
	c_long size;
	c_char[256] path;
}

/* Link to external C++ library method */
[CallingConvention(.Cdecl), LinkName(.CPP)]
extern c_long GetFileHash(FileInfo fileInfo);

/* Import optional dynamic method - may be null */
[Import("Optional.dll"), LinkName("Optional_GetVersion")]
static function int32 (char8* args) GetOptionalVersion;
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Reflection" class="Example">
{{< /rawhtml >}}
```C#
void Serialize(SerializeContext ctx, Object obj)
{
 	for (let field in obj.GetType().GetFields())
	{
		Variant v = field.GetValue(obj);
		ctx.Serialize(field.Name, v);
		if (let attr = field.GetCustomAttribute<OnSerializeAttribute>())
		{
			var m = attr.mSerializeType.GetMethod("SerializeField").Value;
			m.Invoke(null, obj, field);
		}
	}
}
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Mixins" class="Example">
{{< /rawhtml >}}
```C#
static mixin Inc(var val)
{
    if (val == null)
        return false;
    (*val)++;
}

static bool Inc3(int* a, int* b, int* c)
{
	// "return false" from mixin is injected into the Inc3 callsite
    Inc!(a);
    Inc!(b);
    Inc!(c);
    return true;
}
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Type Extensions" class="Example">
{{< /rawhtml >}}
```C#
// Declare List<T>.DisposeAll() for all disposable types
namespace System.Collections
{
	extension List<T> where T : IDisposable
	{
		public void DiposeAll()
		{
			for (var val in this)
				val.Dispose();
		}
	}
}
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Compile-time function evaluation" class="Example">
{{< /rawhtml >}}
```C#
static int32 Factorial(int32 n) => n <= 1 ? 1 : (n * Factorial(n - 1));
const int fac = Factorial(8); // Evaluates to 40320 at compile-time

public static Span<int32> GetSorted(String numList)
{
	List<int32> list = scope .();
	for (var sv in numList.Split(','))
		list.Add(int32.Parse(sv..Trim()));		
	return list..Sort();
}
const int32[?] iArr = GetSorted("8, 1, 3, 7"); // Results in int32[4](1, 3, 7, 8)
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
<div id="Compile-time code generation" class="Example">
{{< /rawhtml >}}
```C#
// Create serialization method at compile-time on types with [Serialize]
// No runtime reflection required
[AttributeUsage(.Types)]
struct SerializableAttribute : Attribute, IComptimeTypeApply
{
	[Comptime]
	public void ApplyToType(Type type)
	{
		let code = scope String();
		code.Append("void ISerializable.Serialize(SerializationContext ctx)\n{");
		for (let field in type.GetFields())
			code.AppendF($"\n\tctx.Serialize(\"{field.Name}\", {field.Name});");
		code.Append($"\n}");
		Compiler.EmitAddInterface(type, typeof(ISerializable));
		Compiler.EmitTypeBody(type, code);
	}
}
```
{{< rawhtml >}}
</div>

<!-------------------------------------------------------------------------------------->
</td>
</tr>
</table>

<script>
	function Check(node, value)
	{		
		node.style.display = (value == node.id) ? "block" : "none";		
	}

	function ExampleSelected()
	{  				
		const nodes = document.getElementsByClassName("Example");
		for (let i = 0; i < nodes.length; i++)
		{			
			Check(nodes[i], this.value);
			nodes[i].style.width = "700px";
		}
	}

	select = document.getElementById("ExampleSelect");
	const nodes = document.getElementsByClassName("Example");
	for (let i = 0; i < nodes.length; i++)
	{
		var option = document.createElement("option");		
		option.text = nodes[i].id;
		if (nodes[i].id == "Hello World")
			option.selected = true;
		select.appendChild(option);		
	}

	select.onchange = ExampleSelected;	
	Check(document.getElementById("Hello World"), "Hello World");	
</script>

{{< /rawhtml >}}
