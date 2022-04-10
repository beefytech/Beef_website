using System;
using BiUtils;
using System.Collections;
using System.Threading;
using System.IO;
using System.Diagnostics;


namespace BiElevated
{
	class Program
	{
		int mProcessId;
		int mRetCode;
		Monitor mMonitor;

		void Run()
		{
			//Windows.MessageBoxA(default, "Waiting", "ELEVATED", 0);

			String pipeName = scope String()..AppendF("BeefInstall{}", mProcessId);

			NamedPipe pipe = scope .();
			if (pipe.Open(".", pipeName, .AllowTimeouts) case .Err)
			{
				mRetCode = 1;
				return;
			}
			pipe.WriteStrUnsized("ready 0\n");

			Windows.HKey curHKey = default;

			String curStr = scope String();
			while (true)
			{
				/*let process = Platform.BfpProcess_GetById(".", (int32)mProcessId, null);
				if (process == null)
				{
					// Install process closed down
					return;
				}
				Platform.BfpProcess_Release(process);*/

				uint8[4096] data;
				switch (pipe.TryRead(Span<uint8>(&data, 4096)))
				{
				case .Ok(int len):
					if (len == 0)
					{
						// Done
						return; 
					}
					curStr.Append((char8*)&data, len);
				case .Err:
					mRetCode = 2;
					return;
				}

				while (true)
				{
					int crPos = curStr.IndexOf('\n');
					if (crPos == -1)
						break;

					String cmd = scope String(curStr, 0, crPos);
					curStr.Remove(0, crPos + 1);

					Console.WriteLine("CMD: {}", cmd);

					bool success = true;
					bool sentResult = false;

					void HandleError(Utils.Error error)
					{
						String errorStr = scope String();
						errorStr.Append("error ");

						switch (error)
						{
						case .DeleteFileFailed(let filePath):
							errorStr.AppendF("Failed to delete file '{}'", filePath);
						case .RemoveDirectoryFailed(let filePath):
							errorStr.AppendF("Failed to remove directory '{}'", filePath);
						default:
							errorStr.Append("Failed to uninstall Beef Development Tools");
						}
						errorStr.Append("\n");
						pipe.WriteStrUnsized(errorStr);
						success = false;
						sentResult = true;
					}

					if (cmd.StartsWith("error "))
					{
						pipe.WriteStrUnsized(scope String()..Concat(cmd, "\n")); // For testing-echo error back
					}
					else if (cmd.StartsWith("addToPath "))
					{
						using (var result = BiUtils.Utils.ModifyPath(true, .(cmd, "addToPath ".Length), .Add))
						{
							if (result case .Err(let err))
								HandleError(err);
						}
					}
					else if (cmd.StartsWith("removeFromPath "))
					{
						using (var result = BiUtils.Utils.ModifyPath(true, .(cmd, "removeFromPath ".Length), .Remove))
						{
							if (result case .Err(let err))
								HandleError(err);
						}
					}
					else if (cmd.StartsWith("cleanupDir "))
					{
						using (var result = BiUtils.Utils.CleanupDir(.(cmd, "cleanupDir ".Length)))
						{
							if (result case .Err(let err))
								HandleError(err);
						}
					}
					else if (cmd.StartsWith("removeInstalledFiles "))
					{
						String beefPath = scope .();
						List<String> exceptionList = scope .();
						defer ClearAndDeleteItems(exceptionList);

						for (let entry in StringView(cmd, "removeInstalledFiles ".Length).Split('\t', .RemoveEmptyEntries))
						{
							if (beefPath.IsEmpty)
								beefPath.Append(entry);
							else
								exceptionList.Add(new String(entry));
						}

						using (var result = BiUtils.Utils.RemovedInstalledFiles(beefPath, exceptionList, false, false))
						{
							if (result case .Err(let err))
								HandleError(err);
						}
					}
					else if (cmd.StartsWith("mkdir "))
					{
						StringView dir = .(cmd, "mkdir ".Length);
						using (var result = BiUtils.Utils.CreateDir(dir))
						{
							if (result case .Err(let err))
								HandleError(err);
						}
					}
					else if (cmd.StartsWith("allowAccess "))
					{
						StringView dir = .(cmd, "allowAccess ".Length);
						using (var result = BiUtils.Utils.AllowAccess(dir))
						{
							if (result case .Err(let err))
								HandleError(err);
						}
					}
					else if (cmd.StartsWith("createHKLM "))
					{
						StringView keyName = .(cmd, "createHKLM ".Length);
						uint32 disposition = 0;
						if (Windows.RegCreateKeyExW(Windows.HKEY_LOCAL_MACHINE, keyName.ToScopedNativeWChar!(), 0, null, Windows.REG_OPTION_NON_VOLATILE, Windows.KEY_ALL_ACCESS, null,
							out curHKey, &disposition) != 0)
						{
							String errorStr = scope .();
							errorStr.AppendF(@"Failed to create registry entry 'HKEY_LOCAL_MACHINE\{}'\n", keyName);
							pipe.WriteStrUnsized(errorStr);
							success = false;
							sentResult = true;
						}
					}
					else if (cmd.StartsWith("hkeyString "))
					{
						var itr = StringView(cmd, "hkeyString ".Length).Split('\t');
						let name = itr.GetNext().GetValueOrDefault();
						let value = itr.GetNext().GetValueOrDefault();
						if (curHKey.SetValue(name, value) case .Err)
							success = false;
					}
					else if (cmd.StartsWith("hkeyInt "))
					{
						var itr = StringView(cmd, "hkeyInt ".Length).Split('\t');
						let name = itr.GetNext().GetValueOrDefault();
						let value = int.Parse(itr.GetNext().GetValueOrDefault()).GetValueOrDefault();
						if (curHKey.SetValue(name, (uint32)value) case .Err)
							success = false;
					}
					else if (cmd == "hkeyClose")
					{
						Windows.RegCloseKey(curHKey);
						curHKey = default;
					}
					else if (cmd.StartsWith("setEnv "))
					{
						var itr = StringView(cmd, "setEnv ".Length).Split('\t');
						let name = itr.GetNext().GetValueOrDefault();
						let value = itr.GetNext().GetValueOrDefault();
						using (var result = BiUtils.Utils.ModifyEnv(true, name, value, .Add))
						{
							if (result case .Err(let err))
								HandleError(err);
						}
					}
					else if (cmd.StartsWith("rmEnv "))
					{
						var itr = StringView(cmd, "rmEnv ".Length).Split('\t');
						let name = itr.GetNext().GetValueOrDefault();
						using (var result = BiUtils.Utils.ModifyEnv(true, name, .(), .Remove))
						{
							if (result case .Err(let err))
								HandleError(err);
						}
					}
					else if (cmd.StartsWith("link "))
					{
						var itr = StringView(cmd, "link ".Length).Split('\t');
						let linkPath = itr.GetNext().GetValueOrDefault();
						let targetPath = itr.GetNext().GetValueOrDefault();
						let arguments = itr.GetNext().GetValueOrDefault();
						let workingDirectory = itr.GetNext().GetValueOrDefault();
						let description = itr.GetNext().GetValueOrDefault();
						using (var result = Shell.CreateShortcut(linkPath, targetPath, arguments, workingDirectory, description))
						{
							if (result case .Err(let err))
								success = false;
						}
					}
					else
					{
						Console.WriteLine("FAILED! Invalid command");
						success = false;
					}

					if (!sentResult)
					{
						if (success)
							pipe.WriteStrUnsized("ok\n");
						else
							pipe.WriteStrUnsized("error\n");
					}
				}
			}
		}

		static int Main(String[] args)
		{
			if (args.Count != 1)
				return 1;

			Program pg = scope Program();
			if (args[0].StartsWith("-uninstall="))
			{
				StringView beefPath = .(args[0], "-uninstall=".Length);
				using (var result = BiUtils.Utils.UninstallWithUI(beefPath))
				{
					if (result case .Err)
						return 1;
					return 0;
				}
			}

			pg.mProcessId = int.Parse(args[0]).GetValueOrDefault();
			pg.Run();

			return pg.mRetCode;
		}
	}
}
