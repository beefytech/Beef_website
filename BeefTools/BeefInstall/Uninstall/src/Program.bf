using System;
using BiUtils;
using System.IO;
using System.Diagnostics;

namespace BiUninstall
{
	class Program
	{
		public static int Main(String[] args)
		{
			if (args.IsEmpty)
			{
				if (Windows.MessageBoxA(default, "Are you sure you want to uninstall Beef Development Tools?", "UINSTALL BEEF?", Windows.MB_YESNO | Windows.MB_ICONQUESTION) != Windows.IDYES)
					return 0;

				String tempDir = scope .();
				Utils.CreateTempDirectory(tempDir);

				String exePath = scope .();
				Environment.GetExecutableFilePath(exePath);

				String exeTempPath = scope .();
				exeTempPath.Concat(tempDir, @"\");
				Path.GetFileName(exePath, exeTempPath);

				if (File.Copy(exePath, exeTempPath) case .Err)
				{
					Windows.MessageBoxA(default, "Failed to copy exe to temp directory", "UNINSTALL FAILED", Windows.MB_ICONHAND);
					return 1;
				}

				String binPath = scope .();
				Path.GetDirectoryPath(exePath, binPath).IgnoreError();

				String beefPath = scope String();
				Path.GetDirectoryPath(binPath, beefPath);

				ProcessStartInfo procInfo = scope ProcessStartInfo();
				procInfo.UseShellExecute = false;
				procInfo.SetFileName(exeTempPath);
				//procInfo.CreateNoWindow = true;
				procInfo.SetArguments(scope String()..Concat("\"", beefPath, "\""));

				SpawnedProcess process = scope SpawnedProcess();
				if (process.Start(procInfo) case .Err)
				{
					Windows.MessageBoxA(default, "Failed to execute temp exe", "UNINSTALL FAILED", Windows.MB_ICONHAND);
					return 1;
				}

				return 0;
			}

			String beefPath = args[0];

			int result = 0;

			if (Utils.Uninstall(beefPath) case .Err)
			{
				Windows.MessageBoxA(default, "Failed to uninstall Beef Development Tools", "UNINSTALL FAILED", Windows.MB_ICONHAND);
				result = 2;
			}

			return 0;
		}
	}
}
