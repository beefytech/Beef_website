using System;
using System.IO;
using System.Collections;
using System.Threading;

namespace BiUtils
{
	public enum ExtractResult
	{
		Ok,
		Failed
	}

	public function ExtractResult ExtractFunc(int idx, StringView destPath);
	public function void StartFunc(StringView fileList, ExtractFunc extractFunc);

	class InstalledFiles
	{
		public List<String> mFileList = new List<String>() ~ DeleteContainerAndItems!(_);

		public Result<void> Deserialize(StringView filePath)
		{
			StreamReader reader = scope .();
			if (reader.Open(filePath) case .Err)
				return .Err;
			
			for (let val in reader.Lines)
			{
				if (val case .Err)
					return .Err;

				if (val case .Ok(let line))
				{
					if (!line.IsEmpty)
					{
						mFileList.Add(new String(line));
					}
				}
			}
			return .Ok;
		}

		public Result<void> Serialize(StringView filePath)
		{
			StreamWriter sw = scope .();
			if (sw.Create(filePath) case .Err)
				return .Err;

			for (let line in mFileList)
				if (sw.WriteLine(line) case .Err)
					return .Err;

			return .Ok;
		}

		public void Add(StringView filePath)
		{
			mFileList.Add(new String(filePath));
		}
	}

	static class Utils
	{
		public enum Error : IDisposable
		{
			case None;
			case CreateDirectoryFailed(String filePath);
			case UninstallPermissionError;
			case SetPermissionFailed;
			case SetPathFailed;
			case DeleteFileFailed(String filePath);
			case RemoveDirectoryFailed(String filePath);
			case RemoveRegKeyFailed(String keyPath);

			public void Dispose() mut
			{
				switch (this)
				{
				case .None:
				case .UninstallPermissionError:
				case .CreateDirectoryFailed(let filePath):
					delete filePath;
				case .SetPermissionFailed:
				case .SetPathFailed:
				case .DeleteFileFailed(let filePath):
					delete filePath;
				case .RemoveDirectoryFailed(let filePath):
					delete filePath;
				case .RemoveRegKeyFailed(let keyPath):
					delete keyPath;
				}
				this = .None;
			}
		}

		public enum PathAction
		{
			Add,
			Remove,
			Check
		}

		public static Result<bool, Error> ModifyPath(bool allUsers, StringView binPath, PathAction action)
		{
			Windows.HKey key = 0;
			bool writeAsExpand = false;
			uint32 regAccess = (.)((action == .Check) ? Windows.KEY_QUERY_VALUE : Windows.KEY_QUERY_VALUE | Windows.KEY_SET_VALUE);

			if (allUsers)
			{
				writeAsExpand = false;
				Windows.RegOpenKeyExA(Windows.HKEY_LOCAL_MACHINE, @"SYSTEM\CurrentControlSet\Control\Session Manager\Environment", 0, regAccess, out key);
			}
			else
			{
				writeAsExpand = true;
				Windows.RegOpenKeyExA(Windows.HKEY_CURRENT_USER, @"Environment", 0, regAccess, out key);
			}
			
			if (key.IsInvalid)
				return .Err(.SetPathFailed);

			String path = scope .();
			if (key.GetValue("Path", path) case .Err)
				return .Err(.SetPathFailed);

			bool found = false;
			for (let pathDir in path.Split(';'))
			{
				if (Path.Equals(pathDir, binPath))
				{
					if ((action == .Add) || (action == .Check))
					{
						// Already in path, nothing to do
						return .Ok(false);
					}

					int pos = Math.Max(@pathDir.Pos - 1, 0);

					path.Remove(pos, @pathDir.MatchPos - pos);
					if (path.StartsWith(";"))
						path.Remove(0, 1);

					found = true;
					break;
				}
			}

			if (action == .Check)
				return .Err(.SetPathFailed);

			if ((!found) && (action == .Remove))
				return .Ok(false);

			if (action == .Add)
			{
				if (!path.EndsWith(";"))
					path.Append(";");
				path.Append(binPath);
			}

			if (writeAsExpand)
			{
				if (key.SetValueExpand("Path", path) case .Err)
					return .Err(.SetPathFailed);
			}
			else
			{
				if (key.SetValue("Path", path) case .Err)
					return .Err(.SetPathFailed);
			}

			return .Ok(true);
		}

		public static Result<bool, Error> ModifyEnv(bool allUsers, StringView name, StringView value, PathAction action)
		{
			Windows.HKey key = 0;
			uint32 regAccess = (.)((action == .Check) ? Windows.KEY_QUERY_VALUE : Windows.KEY_QUERY_VALUE | Windows.KEY_SET_VALUE);

			if (allUsers)
			{
				Windows.RegOpenKeyExA(Windows.HKEY_LOCAL_MACHINE, @"SYSTEM\CurrentControlSet\Control\Session Manager\Environment", 0, regAccess, out key);
			}
			else
			{
				Windows.RegOpenKeyExA(Windows.HKEY_CURRENT_USER, @"Environment", 0, regAccess, out key);
			}
			
			if (key.IsInvalid)
				return .Err(.SetPathFailed);

			if (action == .Check)
			{
				String curValue = scope .();
				if (key.GetValue(name, curValue) case .Err)
					return .Err(.SetPathFailed);
				if (curValue != value)
					return .Err(.SetPathFailed);
				return .Ok(false);
			}

			if (action == .Remove)
			{
				int result = Windows.RegDeleteValueA(key, name.ToScopeCStr!());
				if ((result != 0) && (result != Windows.ERROR_FILE_NOT_FOUND))
					return .Err(.SetPathFailed);
				return .Ok(true);
			}

			if (key.SetValue(name, value) case .Err)
				return .Err(.SetPathFailed);
			return .Ok(true);
		}

		public static void RehupEnvironment()
		{
			int32 result = 0;
			Windows.SendMessageTimeoutW(.Broadcast, Windows.WM_SETTINGCHANGE, 0, (int)(void*)"Environment".ToScopedNativeWChar!(), Windows.SMTO_ABORTIFHUNG, 2000, &result);
		}

		public static Result<void, Error> CreateDir(StringView dir)
		{
			if (Directory.Exists(dir))
				return .Ok;

			CreateLoop: for (int i = 0; true; i++)
			{
				switch (Directory.CreateDirectory(dir))
				{
				case .Ok:
					break CreateLoop;
				case .Err(let err):
				}
				if (i == 10)
					return .Err(.CreateDirectoryFailed(new String(dir)));
				Thread.Sleep(20);
			}

			return .Ok;
		}

		public static Result<void, Error> AllowAccess(StringView dir)
		{
			Windows.ACL* acl = null;
			Windows.ACL* newAcl = null;

			char16* dirWC = dir.ToScopedNativeWChar!();

			if (Windows.GetNamedSecurityInfoW(dirWC, .SE_FILE_OBJECT, .DACL_SECURITY_INFORMATION, null, null, &acl, null, null) != 0)
				return .Err(.SetPermissionFailed);

			uint32 numEntries = 0;
			Windows.EXPLICIT_ACCESS_W* explicitAccessList = null;
			if (Windows.GetExplicitEntriesFromAclW(acl, &numEntries, &explicitAccessList) != 0)
				return .Err(.SetPermissionFailed);

			// Find the "Users" sid
			Windows.SID* sid = null;
			if (!Windows.ConvertStringSidToSidW("S-1-5-32-545".ToScopedNativeWChar!(), &sid))
				return .Err(.SetPermissionFailed);

			char16[256] name;
			uint32 nameLen = 256;
			int peUse = 0;
			char16[256] domainName;
			uint32 domainNameLen = 256;
			if (!Windows.LookupAccountSidW(null, sid, &name, &nameLen, &domainName, &domainNameLen, &peUse))
				return .Err(.SetPermissionFailed);


			Windows.EXPLICIT_ACCESS_W explicitAccess = default;
			Windows.BuildExplicitAccessWithNameW(&explicitAccess, &name, Windows.GENERIC_ALL, .SET_ACCESS, Windows.CONTAINER_INHERIT_ACE | Windows.OBJECT_INHERIT_ACE);
			if (Windows.SetEntriesInAclW(1, &explicitAccess, acl, &newAcl) != 0)
				return .Err(.SetPermissionFailed);
			if (Windows.SetNamedSecurityInfoW(dirWC, .SE_FILE_OBJECT, .DACL_SECURITY_INFORMATION, null, null, newAcl, null) != 0)
				return .Err(.SetPermissionFailed);

			return .Ok;
		}

		public static bool DirectoryHasContent(StringView dir)
		{
			for (let val in Directory.EnumerateFiles(dir))
			{
				String filePath = scope .();
				val.GetFilePath(filePath);

				bool allowFile = false;
				if (filePath.EndsWith(".toml", .OrdinalIgnoreCase))
					allowFile = true;

				if (!allowFile)
					return true;
			}

			for (let val in Directory.EnumerateDirectories(dir))
			{
				String filePath = scope .();
				val.GetFilePath(filePath);
				DirectoryHasContent(filePath);
			}

			return false;
		}

		public static void RemoveEmptyDirs(StringView dir, bool removeSelf)
		{
			for (let val in Directory.EnumerateDirectories(dir))
			{
				String filePath = scope .();
				val.GetFilePath(filePath);
				RemoveEmptyDirs(filePath, true);
			}

			if (removeSelf)
				Directory.Delete(dir).IgnoreError();
		}

		static Result<void, Platform.BfpFileResult> PatientDirectoryDelete(StringView filePath)
		{
			// This will wait up to 5 seconds before failing
			for (int pass = 0; true; pass++)
			{
				let result = Directory.Delete(filePath);
				switch (result)
				{
				case .Ok:
					return .Ok;
				case .Err(let err):
					if ((err == .NotFound) ||
						(err == .NotEmpty) ||
						(pass == 100))
						return .Err(err);
				}
				Thread.Sleep(50);
			}
		}

		static Result<void, Platform.BfpFileResult> PatientFileDelete(StringView filePath)
		{
			// This will wait up to 5 seconds before failing
			for (int pass = 0; true; pass++)
			{
				let result = File.Delete(filePath);
				switch (result)
				{
				case .Ok:
					return .Ok;
				case .Err(let err):
					if ((err == .NotFound) ||
						(pass == 100))
						return .Err(err);
				}
				Thread.Sleep(50);
			}
		}

		public static Result<void, Error> RemovedInstalledFiles(StringView dir, List<String> exceptionList, bool checkPermissions)
		{
			String listName = scope .();
			listName.Concat(dir, @"\install.lst");

			bool changedEnv = false;

			InstalledFiles installedFiles = scope .();
			if (installedFiles.Deserialize(listName) case .Err)
				return .Ok; // Nothing installed

			for (int fileIdx = installedFiles.mFileList.Count - 1; fileIdx >= 0; fileIdx--)
			{
				let relPath = installedFiles.mFileList[fileIdx];

				if ((exceptionList != null) && (exceptionList.Contains(relPath)))
					continue;

				if (relPath.StartsWith("PATH:"))
				{
					switch (ModifyPath(true, .(relPath, "PATH:".Length), .Remove))
					{
					case .Ok(let changed):
						if (changed)
							changedEnv = true;
					case .Err(let err):
						return .Err(err);
					}
					continue;
				}
				else if (relPath.StartsWith("USERPATH:"))
				{
					switch (ModifyPath(false, .(relPath, "USERPATH:".Length), .Remove))
					{
					case .Ok(let changed):
						if (changed)
							changedEnv = true;
					case .Err(let err):
						return .Err(err);
					}
					continue;
				}
				else if ((relPath.StartsWith("HKLM:")) || (relPath.StartsWith("HKCU:")))
				{
					bool isLocalMachine = relPath.StartsWith("HKLM:");
					String keyName = scope String(relPath, "HKLM:".Length);
					int result = Windows.RegDeleteKeyA(isLocalMachine ? Windows.HKEY_LOCAL_MACHINE : Windows.HKEY_CURRENT_USER, keyName);
					if ((checkPermissions) && (result == Windows.ERROR_ACCESS_DENIED))
						return .Err(.UninstallPermissionError);
					if ((result != 0) && (result != Windows.ERROR_FILE_NOT_FOUND))
					{
						if (isLocalMachine)
							return .Err(.RemoveRegKeyFailed(new String()..Concat(@"HKEY_LOCAL_MACHINE\", keyName)));
						else
							return .Err(.RemoveRegKeyFailed(new String()..Concat(@"HKEY_CURRENT_USER\", keyName)));
					}
					continue;
				}
				else if (relPath.StartsWith("ENV:"))
				{
					switch (ModifyEnv(true, .(relPath, "ENV:".Length), .(), .Remove))
					{
					case .Ok(let changed):
						if (changed)
							changedEnv = true;
					case .Err(let err):
						return .Err(err);
					}
					continue;
				}
				else if (relPath.StartsWith("USERENV:"))
				{
					switch (ModifyEnv(false, .(relPath, "USERENV:".Length), .(), .Remove))
					{
					case .Ok(let changed):
						if (changed)
							changedEnv = true;
					case .Err(let err):
						return .Err(err);
					}
					continue;
				}

				String filePath = scope .();
				Path.GetAbsolutePath(relPath, dir, filePath);

				if (filePath.EndsWith(Path.DirectorySeparatorChar))
				{
					switch (PatientDirectoryDelete(filePath))
					{
					case .Ok:
					case .Err(let error):
						if ((error != .NotFound) && (error != .NotEmpty))
							return .Err(.DeleteFileFailed(new String(filePath)));
					}
					continue;
				}

				switch (PatientFileDelete(filePath))
				{
				case .Ok:
				case .Err(let error):
					if (error != .NotFound)
						return .Err(.DeleteFileFailed(new String(filePath)));
				}
			}

			if (checkPermissions)
				return .Ok;

			if (changedEnv)
				RehupEnvironment();

			File.Delete(listName).IgnoreError();
			RemoveEmptyDirs(dir, false);
			return .Ok;
		}

		public static Result<void, Error> CleanupDir(StringView dir)
		{
			Try!(RemovedInstalledFiles(dir, null, false));

			// If there are other files added then just leave them alone
			if (DirectoryHasContent(dir))
				return .Ok;

			Directory.DelTree(dir).IgnoreError();

			return .Ok;
		}

		/*public static Result<void, Error> PrepareInstall(StringView beefPath, bool allUsers, bool addToPath)
		{
			Try!(CleanupDir(beefPath));

			String binPath = scope String()..Concat(beefPath, @"\bin");

			Try!(CreateDir(beefPath));
			if (addToPath)
				Try!(ModifyPath(allUsers, binPath, .Add));
			return .Ok;
		}*/

		public static Result<void, Error> Uninstall(StringView beefPath)
		{
			Try!(CleanupDir(beefPath));

			return .Ok;
		}

		public static Result<void> UninstallWithUI(StringView beefPath)
		{
			using (var result = Uninstall(beefPath))
			{
				if (result case .Err(let err))
				{
					String errorStr = scope .();

					switch (err)
					{
					case .DeleteFileFailed(let filePath):
						errorStr.AppendF("Failed to delete file '{}'", filePath);
					case .RemoveDirectoryFailed(let filePath):
						errorStr.AppendF("Failed to remove directory '{}'", filePath);
					default:
						errorStr.Append("Failed to uninstall Beef Development Tools");
					}
					Windows.MessageBoxW(default, errorStr.ToScopedNativeWChar!(), "UNINSTALL FAILED".ToScopedNativeWChar!(), Windows.MB_ICONHAND);
					return .Err;
				}
			}

			return .Ok;
		}

		public static Result<void> CreateTempDirectory(String outPath)
		{
			for (int i = 0; i < 1000; i++)
			{
				outPath.Clear();
				Path.GetTempPath(outPath);
				outPath.AppendF("Beef{:X}", gRand.NextI32());
				if ((!Directory.Exists(outPath)) && (Directory.CreateDirectory(outPath) case .Ok))
					return .Ok;
				if (i == 1000)
					break;
			}
			return .Err;
		}
	}
}