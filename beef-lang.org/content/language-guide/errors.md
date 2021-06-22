+++
title = "Error Handling"
weight=75
+++

## Error handling

Some languages such as C# use exceptions for error handling, but Beef does not support exceptions. By convention, error handing is implemented using the System.Result<T> and System.Result<T, TError> enum types which implement two values: .Ok(T) and .Err(TError). The version that is parameterized by TError supports returning an explicit error value, otherwise the error type is unspecified. Generics can be parameterized by "void", so Result<void> is used for methods which may return errors but have no value to return.

If a returned error is not handled, it will cause a fatal runtime error.
```C#
static Result<uint> GetMinusOne(uint i)
{
	if (i == 0)
		return .Err;
	return .Ok(i - 1);
}

void Use()
{
	/* Handle result via a switch */
	switch (GetMinusOne(i))
	{
		case .Ok(let newVal): Console.WriteLine("Val: {}", newVal);
		case .Err: Console.WriteLine("Failed");
	}

	/* This invokes an implicit conversion operator, which will be fatal at runtime if an error is returned */
	let newVal = GetMinusOne(i);

	/* Result<T> contains a special "ReturnValueDiscarded" method which is invoked to facilitate failing fatally on ignored returned errors here */
	GetMinusOne(i);

	/* "ReturnValueDiscarded" will not be called */
	GetMinusOne(i).IgnoreError();
}
```

Result<T> can also be handled using if statements. Use [case]({{< ref "pattern.md#enum" >}}) to match the .Err or .Ok enum values.

```C#
void Use()
{
	/* Handle result via an if. Note that Result<T> returns are matched with 'case', not compared with '==' */
	if (GetMinusOne(i) case .Ok(let newVal))
		Console.WriteLine("Val: {}", newVal);
}
```

## Assertions

Assertions are implemented via `Debug.Assert()` and `Runtime.Assert()`. `Debug.Assert(cond)` call will result in a fatal error in debug mode if `cond` evaluates to `false`, but will not generate any instructions in release mode (even if `cond` includes method calls or other complex expressions). Generally assertions are used as a "fail fast" method to ensure legal program state, but is not used to handle errors that can validly occur (ie: user input errors, timeout errors, etc).

## Fatal errors

`Runtime.FatalError` can be used to manually "crash" a program when unrecoverable errors are detected.

## Crashing

By default, GUI programs show a custom crash dialog that includes a backtrace, and console programs write a crash report to the console. Crash behavior can be changed via `Runtime.SetCrashReportKind`.
