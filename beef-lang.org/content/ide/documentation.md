+++
title = "Documentation"
+++

## Documentation comments

The IDE allows for documenting types and methods with `///` or `/** */` (wich one of these you use doesn't matter). Autocomplete suggestions, as well as prompts while calling/using the documented types or functions, will display their documentation.

```C#
static
{
	/// Must be placed directly above the method, including attributes.
	/// Using multiple lines like this is also fine.
	[Optimize]
	public static void DoAThing() {}

	/// Documentation also works for types.
	struct SomeStruct
	{
		/**
		* Multiline comments with two ** at the start.
		*/
		void PrivateMethod() {}
	}

	/**
	* If you have a really long explainer here, you may not actually want to show that in autcompletion prompts.
	* @brief Allows you to select only this line to be shown.
	* 
	* @param a This is shown when writing a call to this function and placing parameter "a".
	* @param b For the second argument, the documentation for b (this!) will show up instead.
	*/
	public static void DoAnotherThing(int a, int b) {}
}
```