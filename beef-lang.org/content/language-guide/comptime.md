+++
title = "Comptime"
weight = 80
+++

## Comptime

Beef offers compile-time features which can be used to execute code which evalutes to constant values or to generate code.

### Compile-time method evaluation

```C#
/* Const value initialized from comptime evaluation of Vector3 constructor */
const Vector3 vec = .(1, 2, 3);

/* Normal methods can be used at comptime */
static int32 Factorial(int32 n)
{
    return n <= 1 ? 1 : (n * Factorial(n - 1));
}
const int fac = Factorial(8);
var fac2 = [ConstEval]Factorial(9); /* call attribute forces comptime evaluation */

/* This method can only be called at comptime. The 'var' return type allows this method to return different types at comptime based on the input */
[Comptime(ConstEval=true)]
static var StrToValue(String str)
{
	if (str.Contains('.'))
		return float.Parse(str).Value;
	return int.Parse(str).Value;
}
public const let cVal0 = StrToValue("123"); /* evaluates to 'int' */
public const let cVal1 = StrToValue("1.23"); /* evaluates to 'float' */

/* Note that returning scoped memory is legal at comptime even though it is illegal at runtime */
static String GenerateString(String str, int a, int b) => scope $"{str}:{a}:{b}";
const String cStr = GenerateString("Prefix", 12, 34); /* evalutes to string literal "Prefix:12:34" */

/* A Span result can be used to initialize a sized array */
public static Span<int32> GetSorted(String numList)
{
	List<int32> list = scope .();
	for (var sv in numList.Split(','))
	{
		sv.Trim();
		if (int32.Parse(sv) case .Ok(let val))
			list.Add(val);
	}
	list.Sort();
	return list;
}
const int32[?] iArr = GetSorted("8, 1, 3, 7"); /* evalutes to int32[4](1, 3, 7, 8) */
```

Every comptime evaluation occurs in isolation - any static values modified during the evaluation of one method will not be visible to subsequent method evaluations. Certain side effects are restricted during comptime evaluation, such as file IO and access to external libraries.

### Compile-time code generation

Code generation expands on the comptime method evaluation features, allowing for types to be modified at certain trigger points during compilation.

```C#

/* Constant strings can be used to inject code into the call site at comptime. This string can be generated from a comptime method. */
{
  /* In this case it's the same as just pasting the string into the code right here. */
  Compiler.Mixin("int val = 99;");

  Console.WriteLine(val);
}

/* OnCompile attribute allows for code generation */
class ClassA
{
	public int mA = 123;

	[OnCompile(.TypeInit), Comptime]
	public static void Generate()
	{
		Compiler.EmitTypeBody(typeof(Self), """
			public int32 mB = 234;
			public int32 GetValB() => mB;
			""");
	}
}

/* This method emits a runtime scope timer into its call site. */
[Comptime]
public static void TimeScope(String scopeName)
{
	let nameHash = (uint)scopeName.GetHashCode();

  /* MixinRoot emits into the root non-comptime caller, rather than into this comptime method */
	Compiler.MixinRoot(scope $"""
		let __timer_{nameHash} = scope System.Diagnostics.Stopwatch(true);
		defer
		{{
			System.Console.WriteLine($"Scope {scopeName} took {{__timer_{nameHash}.ElapsedMilliseconds}}ms.");
		}}
		""");
}

/* Adding this attribute to a type will generate a 'ToString' method using comptime reflection */
[AttributeUsage(.Types)]
struct IFancyToString : Attribute, IComptimeTypeApply
{
	[Comptime]
	public void ApplyToType(Type type)
	{
		Compiler.EmitTypeBody(type, "public override void ToString(String str)\n{\n");
		for (var fieldInfo in type.GetFields())
		{
			if (!fieldInfo.IsInstanceField)
				continue;
			if (@fieldInfo.Index > 0)
				Compiler.EmitTypeBody(type, "\tstr.Append(\", \");\n");
			Compiler.EmitTypeBody(type, scope $"\tstr.AppendF($\"{fieldInfo.Name}={{ {fieldInfo.Name} }}\");\n");
		}
		Compiler.EmitTypeBody(type, "}");
	}
}

/* Adding this attribute to a method will log method entry and returned Result<T> errors */
[AttributeUsage(.Method)]
struct LogAttribute : Attribute, IComptimeMethodApply
{
	[Comptime]
	public void ApplyToMethod(ComptimeMethodInfo method)
	{
		String emit = scope $"Logger.Log($\"Called {method}";
		for (var fieldIdx < method.ParamCount)
			emit.AppendF($" {{ {method.GetParamName(fieldIdx)} }}");
		emit.Append("\\n\");");
		Compiler.EmitMethodEntry(method, emit);

		if (var genericType = method.ReturnType as SpecializedGenericType)
		{
			if ((genericType.UnspecializedType == typeof(Result<>)) || (genericType.UnspecializedType == typeof(Result<,>)))
			{
				Compiler.EmitMethodExit(method, """
					if (@return case .Err)
					Logger.Log($"Error: {@return}");
					""");
			}
		}
	}
}

```
