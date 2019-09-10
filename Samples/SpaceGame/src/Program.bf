using System;
using System;
using SDL2;
using SpaceGame;
using System.IO;
using System.Diagnostics;

namespace SpaceGame
{
	class Program
	{
		public static void Main()
		{
			gGameApp = scope .();
			gGameApp.Init();
			gGameApp.Run();
		}
	}

	static
	{
		public static GameApp gGameApp;
	}
}
