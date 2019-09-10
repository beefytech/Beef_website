using System;
using BiUtils;
using System.Collections.Generic;


namespace BiElevated
{
	class Program
	{
		static int Main(String[] args)
		{
			List<String> makeDirs = scope List<String>();
			defer ClearAndDeleteItems(makeDirs);

			String beefPath = scope .();
			bool allUsers = false;
			bool addToPath = false;

			for (let arg in args)
			{
				if (beefPath.IsEmpty)
				{
					beefPath.Set(arg);
					continue;
				}

				if (arg == "-allUsers")
					allUsers = true;
				if (arg.StartsWith("-addToPath"))
					addToPath = true;
				if (arg.StartsWith("-mkdir="))
					makeDirs.Add(new String(arg, "-mkdir=".Length));
			}

			if (beefPath.IsEmpty)
			{
				return 1;
			}

			if (BiUtils.Utils.PrepareInstall(beefPath, allUsers, addToPath) case .Err)
				return 2;

			for (let dir in makeDirs)
			{
				if (BiUtils.Utils.CreateDir(dir) case .Err)
					return 3;
			}
			
			return 0;
		}
	}
}
