// SpaceGame is a Beef sample utilizing SDL2.
//
// Press F5 to compile and run.

namespace SpaceGame
{
	class Program
	{
		public static void Main()
		{
			let gameApp = scope GameApp();
			gameApp.Init();
			gameApp.Run();
		}
	}
}