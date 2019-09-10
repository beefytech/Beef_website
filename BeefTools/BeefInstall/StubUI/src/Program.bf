using System;
using System.Diagnostics;
using BiUtils;
using System.IO;

namespace BIStubUI
{
	class Program
	{
		[Export, CLink]
		public static void Start(StringView fileInfo, ExtractFunc extractFunc)
		{
			gApp = new BIApp();
			gApp.SetFileInfo(fileInfo);
			gApp.mExtractFunc = extractFunc;
			gApp.Init();
			gApp.Run();
			gApp.Shutdown();
			DeleteAndNullify!(gApp);
		}

		public static void Hello()
		{
			
		}

		public static int Main(String[] args)
		{
			return 0;
		}
	}
}
