+++
title = "Anonymous Types"
weight=30
+++

## Anonymous Type Declarations

Anonymous type declarations are like normal type declarations but they are unnamed and they are placed where a type reference would normally go.

```C#

[Union]
struct Vector3
{
	public float[3] vals;

    /* Anonymous struct declaration with an anonymous field.
    The below is equivalent to:
    public using struct
	{
		public float mX;
		public float mY;
		public float mZ;
	} _UNUSED_NAME_;
     */
	public struct
	{
		public float x;
		public float y;
		public float z;
	};

    /* Anonymous enum declaration */
    public enum { Left, Center, Right } GetXDirection() => (mX < 0) ? .Left : (mX > 0) ? .Right : .Center;
}

Vector3 vec = .();
vec.mX = 1;
vec.mY = 2;
vec.mZ = 3;

/* Types can anonymously be extended and overriden

*/
var buttonWidget = new ButtonWidget("OK")
{
    bool wasClicked;

    public override void OnClick()
    {
        base.OnClick();
        wasClicked = true;
        CloseDialog();
    }
};

```