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
			String exePath = scope .();
			Environment.GetExecutableFilePath(exePath);

			String elevateExePath = scope .();
			Path.GetDirectoryPath(exePath, elevateExePath);
			elevateExePath.Append(@"\BeefInstallElevated.exe");

			if (args.IsEmpty)
			{
				if (Windows.MessageBoxA(default, "Are you sure you want to uninstall Beef Development Tools?", "UNINSTALL BEEF?", Windows.MB_YESNO | Windows.MB_ICONQUESTION) != Windows.IDYES)
					return 0;

				String tempDir = scope .();
				Utils.CreateTempDirectory(tempDir);

				String exeTempPath = scope .();
				exeTempPath.Concat(tempDir, @"\");
				Path.GetFileName(exePath, exeTempPath);
				if (File.Copy(exePath, exeTempPath) case .Err)
				{
					Windows.MessageBoxA(default, "Failed to copy exe to temp directory", "UNINSTALL FAILED", Windows.MB_ICONHAND);
					return 1;
				}

				String elevateExeTempPath = scope .();
				elevateExeTempPath.Concat(tempDir, @"\");
				Path.GetFileName(elevateExePath, elevateExeTempPath);
				if (File.Copy(elevateExePath, elevateExeTempPath) case .Err)
				{
					Windows.MessageBoxA(default, "Failed to copy elevated exe to temp directory", "UNINSTALL FAILED", Windows.MB_ICONHAND);
					return 1;
				}

				String binPath = scope .();
				Path.GetDirectoryPath(exePath, binPath).IgnoreError();

				String beefPath = scope String();
				Path.GetDirectoryPath(binPath, beefPath);

				ProcessStartInfo procInfo = scope ProcessStartInfo();
				procInfo.UseShellExecute = false;
				procInfo.SetFileName(exeTempPath);
				procInfo.SetArguments(scope String()..Concat("\"", beefPath, "\""));

				SpawnedProcess process = scope SpawnedProcess();
				if (process.Start(procInfo) case .Err)
				{
					Windows.MessageBoxA(default, "Failed to execute temp exe", "UNINSTALL FAILED", Windows.MB_ICONHAND);
					return 1;
				}

				return 0;
			}

			String exeDir = scope String();
			Path.GetDirectoryPath(exePath, exeDir);

			String beefPath = args[0];

			int retVal = 0;

			bool useElevation = false;

			using (var result = Utils.RemovedInstalledFiles(beefPath, null, true))
			{
				if (result case .Err(let err))
				{
					if (err == .UninstallPermissionError)
						useElevation = true;
				}
			}

			if (useElevation)
			{
				String elevateArgs = scope String();
				elevateArgs.AppendF("-uninstall=\"{}\"", beefPath);

				ProcessStartInfo procInfo = scope ProcessStartInfo();
				procInfo.UseShellExecute = true;
				procInfo.SetFileName(elevateExePath);
				procInfo.CreateNoWindow = true;
				procInfo.SetArguments(elevateArgs);
				SpawnedProcess process = scope SpawnedProcess();
				if (process.Start(procInfo) case .Ok)
				{
					process.WaitFor();
					retVal = process.ExitCode;
					File.Delete(elevateExePath).IgnoreError();
				}
				else
					useElevation = false;
			}

			if (!useElevation)
			{
				switch (Utils.UninstallWithUI(beefPath))
				{
				case .Ok:
				case .Err:
					retVal = 2;
				}
			}

			Directory.Delete(beefPath).IgnoreError();

			if (retVal == 0)
				Windows.MessageBoxA(default, "Beef Development Tools have been uninstalled.", "UNINSTALL COMPLETED", 0);

			// This performs the ugly duty of deleting us. The 'ping' is a delay.
			ProcessStartInfo procInfo = scope ProcessStartInfo();
			procInfo.UseShellExecute = true;
			procInfo.SetFileName("CMD.EXE");
			procInfo.CreateNoWindow = true;
			procInfo.SetArguments(scope String()..AppendF("/D /C ping.exe -n 5 127.0.0.1 & del \"{}\" & rmdir \"{}\"", exePath, exeDir));
			SpawnedProcess process = scope SpawnedProcess();
			process.Start(procInfo).IgnoreError();
			
			return retVal;
		}
	}
}
