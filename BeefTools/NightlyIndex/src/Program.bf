using System;
using System.IO;
using System.Collections;
using System.Diagnostics;

namespace NightlyIndex
{
	class Program
	{
		public static int Main(String[] args)
		{
			String html = scope .();
			html.Append(
				"""
					<html>
					<center>
					<H1>Beef Nightly Builds Archive</p></H1>
				""");

			List<String> lines = scope .();
			List<String> newestLines = scope .();

			for (var entry in Directory.EnumerateFiles(@"C:\BeefNightly"))
			{
				var fileName = scope String();
				entry.GetFileName(fileName);

				var filePath = scope String();
				entry.GetFilePath(filePath);

				if (!fileName.StartsWith("BeefSetup_"))
					continue;

				String date = scope String(fileName, fileName.Length - 14, 10);
				date.Replace('_', '/');

				FileVersionInfo fileVersionInfo = scope .();
				fileVersionInfo.GetVersionInfo(filePath).IgnoreError();

				lines.Add(scope:: String()..AppendF("<a href={}>BeefSetup {}</a> {:.0}MB <a href=https://github.com/beefytech/Beef/commit/{}>{}</a><br>\n", fileName, date, entry.GetFileSize() / (1024.0 * 1024.0),
					fileVersionInfo.ProductVersion, fileVersionInfo.ProductVersion.Substring(0, Math.Min(fileVersionInfo.ProductVersion.Length, 6))));

				newestLines.Add(scope:: String()..AppendF("{} {:.0}MB <a href=https://github.com/beefytech/Beef/commit/{}>{}</a>", date, entry.GetFileSize() / (1024.0 * 1024.0),
					fileVersionInfo.ProductVersion, fileVersionInfo.ProductVersion.Substring(0, Math.Min(fileVersionInfo.ProductVersion.Length, 6))));
			}

			lines.Sort(scope (lhs, rhs) => rhs <=> lhs);
			for (var line in lines)
				html.Append(line);

			newestLines.Sort(scope (lhs, rhs) => rhs <=> lhs);

			html.Append(
				"""
					</html>
				""");

			File.WriteAllText(@"C:\BeefNightly\index.html", html);
			if (!newestLines.IsEmpty)
				File.WriteAllText(@"C:\BeefNightly\current.html", newestLines.Front);

			return 0;
		}
	}
}