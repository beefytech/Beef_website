using System;
using IDE.Util;
using System.IO;
using System.Windows;
using BiUtils;

namespace BIStub
{
	class Program
	{
		bool mFailed;

		static Program sProgram;

		String mTempPath ~ delete _;
		String mArchiveOverride ~ delete _;
		String mSelfOverride ~ delete _;
		String mUIDllPath ~ delete _;
		ZipFile mZipFile ~ delete _;
		Stream mStream ~ delete _;

		public ~this()
		{
			if (mTempPath != null)
			{
				Directory.DelTree(mTempPath).IgnoreError();
			}
		}

		void Fail(StringView str)
		{
			if (mFailed)
				return;
			mFailed = true;
			Windows.MessageBoxA(default, scope String..AppendF("ERROR: {}", str), "FATAL ERROR", Windows.MB_ICONHAND);
		}

		bool HandleCommandLineParam(String key, String value)
		{
			if (key != null)
			{
				switch (key)
				{
				case "-self":
					String.NewOrSet!(mSelfOverride, value);
				case "-file":
					String.NewOrSet!(mArchiveOverride, value);
				case "-ui":
					String.NewOrSet!(mUIDllPath, value);
				}
			}

			return false;
		}

		void UnhandledCommandLine(String key, String value)
		{

		}

		void ParseCommandLine(String[] args)
		{
			for (var str in args)
			{
				int eqPos = str.IndexOf('=');
				if (eqPos == -1)
				{
					if (!HandleCommandLineParam(str, null))
						UnhandledCommandLine(str, null);
				}	
				else
				{
					var cmd = scope String(str, 0, eqPos);
					var param = scope String(str, eqPos + 1);
					if (!HandleCommandLineParam(cmd, param))
						UnhandledCommandLine(cmd, param);
				}
			}
		}

		void CheckPE()
		{
			let module = Windows.GetModuleHandleW(null);
			uint8* moduleData = (uint8*)(int)module;
			PEFile.PEHeader* header = (.)moduleData;

			PEFile.PE_NTHeaders64* hdr64 = (.)(moduleData + header.e_lfanew);
			if (hdr64.mFileHeader.mMachine == PEFile.PE_MACHINE_X64)
			{
				int fileEnd = 0;

				for (int sectIdx < hdr64.mFileHeader.mNumberOfSections)
				{
					PEFile.PESectionHeader* sectHdrHead = (.)((uint8*)(hdr64 + 1)) + sectIdx;
					fileEnd = Math.Max(fileEnd, sectHdrHead.mPointerToRawData + sectHdrHead.mSizeOfRawData);
				}


			}
		}

		static void UI_Install(StringView dest, StringView filter)
		{

		}

		static int UI_GetProgress()
		{
			return 0;
		}

		static void UI_Cancel()
		{

		}

		ExtractResult DoExtract(int idx, StringView destPath)
		{
			ZipFile.Entry entry = scope .();
			mZipFile.SelectEntry(idx, entry);
			if (entry.ExtractToFile(destPath) case .Err)
				return .Failed;
			return .Ok;
		}

		static ExtractResult Extract(int idx, StringView destPath)
		{
			return sProgram.DoExtract(idx, destPath);
		}

		void StartUI(StringView fileInfo)
		{
			String uiDllPath = scope .();
			if (mUIDllPath != null)
			{
				uiDllPath.Set(mUIDllPath);
			}
			else
			{
				uiDllPath = scope:: String();
				uiDllPath.Append(mTempPath);
				uiDllPath.Append(@"\BeefInstallUI.dll");
			}

			Windows.SetDllDirectoryW(mTempPath.ToScopedNativeWChar!());

			var lib = Windows.LoadLibraryW(uiDllPath.ToScopedNativeWChar!());
			if (lib.IsInvalid)
			{
				Fail(scope String()..AppendF("Failed to load installer UI '{}'", uiDllPath));
				return;
			}

			StartFunc startFunc = (.)Windows.GetProcAddress(lib, "Start");
			if (startFunc == null)
			{
				Fail(scope String()..AppendF("Failed to initialize installer UI '{}'", uiDllPath));
				return;
			}

			startFunc(fileInfo, => Extract);

			Windows.FreeLibrary(lib);
		}

		Result<void> ParseZip(String fileInfo)
		{
			String fileName = scope .();
			String destPath = scope .();

			for (int i < mZipFile.GetNumFiles())
			{
				ZipFile.Entry entry = scope .();
				if (mZipFile.SelectEntry(i, entry) case .Err)
					continue;

				fileName.Clear();
				entry.GetFileName(fileName);

				if (fileName.StartsWith(@"__installer/"))
				{
					fileName.Remove(0, @"__installer/".Length);

					destPath.Clear();
					destPath.Append(mTempPath);
					destPath.Append('/');
					destPath.Append(fileName);

					if (entry.IsDirectory)
					{
						if (Directory.CreateDirectory(destPath) case .Err)
							return .Err;
					}
					else
					{
						if (entry.ExtractToFile(destPath) case .Err)
							return .Err;
					}
					continue;
				}

				if (entry.IsDirectory)
					continue;

				fileInfo.AppendF("{}\t{}\t{}\n", i, entry.GetCompressedSize(), fileName);
			}

			return .Ok;
		}

		void Run()
		{
			mZipFile = new ZipFile();
			if (mArchiveOverride != null)
			{
				if (mZipFile.Open(mArchiveOverride) case .Err)
				{
					Fail(scope String()..AppendF("Failed to open archive: {}", mArchiveOverride));
					return;
				}
			}
			else
			{
				String exePath = scope String();
				if (mSelfOverride != null)
					exePath.Set(mSelfOverride);
				else
					Environment.GetExecutableFilePath(exePath);

				FileStream fileStream = new FileStream();
				defer { delete fileStream; }

				if (fileStream.Open(exePath, .Read, .Read) case .Err)
				{
					Fail(scope String()..AppendF("Failed to open archive: {}", exePath));
					return;
				}

				PEFile.PEHeader header = fileStream.Read<PEFile.PEHeader>().GetValueOrDefault();
				fileStream.Seek(header.e_lfanew);
				PEFile.PE_NTHeaders64 hdr64 = fileStream.Read<PEFile.PE_NTHeaders64>().GetValueOrDefault();
				if (hdr64.mFileHeader.mMachine != PEFile.PE_MACHINE_X64)
				{
					Fail(scope String()..AppendF("Invalid archive: {}", exePath));
					return;
				}

				int exeEnd = 0;
				for (int sectIdx < hdr64.mFileHeader.mNumberOfSections)
				{
					fileStream.Seek(header.e_lfanew + sizeof(PEFile.PE_NTHeaders64) + sectIdx * sizeof(PEFile.PESectionHeader));
					PEFile.PESectionHeader sectHdrHead = fileStream.Read<PEFile.PESectionHeader>().GetValueOrDefault();
					exeEnd = Math.Max(exeEnd, sectHdrHead.mPointerToRawData + sectHdrHead.mSizeOfRawData);
				}

				mStream = new Substream(fileStream, exeEnd, fileStream.Length - exeEnd, true);
				fileStream = null;
				mZipFile.Init(mStream);
			}

			mTempPath = new String();
			for (int i = 0; true; i++)
			{
				mTempPath.Clear();
				Path.GetTempPath(mTempPath);
				mTempPath.AppendF("Beef{:X}", gRand.NextI32());
				if ((!Directory.Exists(mTempPath)) && (Directory.CreateDirectory(mTempPath) case .Ok))
					break;
				if (i == 1000)
				{
					Fail("Failed to create temporary directory");
					return;
				}
			}

			String fileInfo = scope .();
			ParseZip(fileInfo);
			StartUI(fileInfo);

			/*CheckPE();

			ZipFile zipFile = scope .();
			zipFile.Open(@"c:\\temp\\build_1827.zip");
			ExtractTo(zipFile, @"c:\temp\unzip", .());

			CabFile cabFile = scope .();
			cabFile.Init();
			cabFile.Copy();*/
		}

		static int Main(String[] args)
		{
			sProgram = new Program();
			sProgram.ParseCommandLine(args);
			sProgram.Run();
			delete sProgram;
			return 0;
		}
	}
}
