using System;
using System.IO;
using System.Collections.Generic;

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
		public enum Error
		{
			case CreateDirectoryFailed;
			case SetPermissionFailed;
			case SetPathFailed;
			case DeleteFileFailed;

			public void Dispose()
			{

			}
		}

		public enum PathAction
		{
			Add,
			Remove,
			Check
		}

		public static Result<bool, Error> ModifyPath(bool allUsers, String binPath, PathAction action)
		{
			Windows.HKey key = 0;
			bool writeAsExpand = false;
			uint32 regAccess = (action == .Check) ? Windows.KEY_QUERY_VALUE : Windows.KEY_QUERY_VALUE | Windows.KEY_SET_VALUE;

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

			if (!path.EndsWith(";"))
				path.Append(";");
			path.Append(binPath);

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

		public static void RehupEnvironment()
		{
			int32 result = 0;
			Windows.SendMessageTimeoutW(.Broadcast, Windows.WM_SETTINGCHANGE, 0, (int)"Environment".ToScopedNativeWChar!(), Windows.SMTO_ABORTIFHUNG, 2000, &result);
		}

		public static Result<void, Error> CreateDir(StringView dir)
		{
			Windows.ACL* acl = null;
			Windows.ACL* newAcl = null;

			if (Directory.Exists(dir))
				return .Ok;

			if (Directory.CreateDirectory(dir) case .Err)
				return .Err(.CreateDirectoryFailed);

			char16* dirWC = dir.ToScopedNativeWChar!();

			if (Windows.GetNamedSecurityInfoW(dirWC, .SE_FILE_OBJECT, .DACL_SECURITY_INFORMATION, null, null, &acl, null, null) != 0)
				return .Err(.SetPermissionFailed);

			Windows.EXPLICIT_ACCESS_W explicitAccess = default;
			Windows.BuildExplicitAccessWithNameW(&explicitAccess, "Users".ToScopedNativeWChar!(), Windows.GENERIC_ALL, .SET_ACCESS, Windows.CONTAINER_INHERIT_ACE | Windows.OBJECT_INHERIT_ACE);
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

		public static Result<void, Error> RemovedInstalledFiles(StringView dir, bool removeDirectories)
		{
			String listName = scope .();
			listName.Concat(dir, @"\install.lst");

			InstalledFiles installedFiles = scope .();
			if (installedFiles.Deserialize(listName) case .Err)
				return .Ok; // Nothing installed

			for (let relPath in installedFiles.mFileList)
			{
				String filePath = scope .();
				Path.GetAbsolutePath(relPath, dir, filePath);

				if (filePath.EndsWith(Path.DirectorySeparatorChar))
				{
					if (!removeDirectories)
						continue;

					switch (Directory.Delete(filePath))
					{
					case .Ok:
					case .Err(let error):
						if (error != .NotFound)
							return .Err(.DeleteFileFailed);
					}
					continue;
				}

				switch (File.Delete(filePath))
				{
				case .Ok:
				case .Err(let error):
					if (error != .NotFound)
						return .Err(.DeleteFileFailed);
				}
			}

			File.Delete(listName).IgnoreError();
			RemoveEmptyDirs(dir, false);
			return .Ok;
		}

		public static Result<void, Error> CleanupDir(StringView dir)
		{
			Try!(RemovedInstalledFiles(dir, true));

			// If there are other files added then just leave them alone
			if (DirectoryHasContent(dir))
				return .Ok;

			Directory.DelTree(dir).IgnoreError();

			return .Ok;
		}

		public static Result<void, Error> PrepareInstall(StringView beefPath, bool allUsers, bool addToPath)
		{
			CleanupDir(beefPath);

			String binPath = scope String()..Concat(beefPath, @"\bin");

			Try!(CreateDir(beefPath));
			if (addToPath)
				Try!(ModifyPath(allUsers, binPath, .Add));
			return .Ok;
		}

		public static Result<void, Error> Uninstall(StringView beefPath)
		{
			Try!(CleanupDir(beefPath));

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