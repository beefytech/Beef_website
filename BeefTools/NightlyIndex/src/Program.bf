using System;
using System.IO;
using System.Collections;

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

			for (var entry in Directory.EnumerateFiles(@"C:\BeefNightly"))
			{
				var fileName = scope String();
				entry.GetFileName(fileName);
				if (!fileName.StartsWith("BeefSetup_"))
					continue;

				String date = scope String(fileName, fileName.Length - 14, 10);
				date.Replace('_', '/');

				lines.Add(scope:: String()..AppendF("<a href={}>BeefSetup {}</a> {:.0}MB<br>\n", fileName, date, entry.GetFileSize() / (1024.0 * 1024.0)));
			}

			lines.Sort(scope (lhs, rhs) => rhs <=> lhs);
			for (var line in lines)
				html.Append(line);

			html.Append(
				"""
					</html>
				""");

			File.WriteAllText(@"C:\BeefNightly\index.html", html);

			return 0;
		}
	}
}