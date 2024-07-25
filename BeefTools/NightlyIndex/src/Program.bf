using System;
using System.IO;
using System.Collections;
using System.Diagnostics;

namespace NightlyIndex
{
	class Program
	{
		struct Entry
		{
			public String mLine;
			public DateTime mDate;

			public this(String line, DateTime date)
			{
				mLine = line;
				mDate = date;
			}
		}

		public static int Main(String[] args)
		{
			String html = scope .();
			html.Append(
				"""
					<html>
					<center>
					<H1>Beef Nightly Builds Archive</p></H1>
					<H3><div id="age"></div></H3>
				""");

			List<Entry> lines = scope .();
			List<Entry> newestLines = scope .();

			DateTime bestTime = default;

			for (var entry in Directory.EnumerateFiles(@"C:\BeefNightly"))
			{
				var fileName = scope String();
				entry.GetFileName(fileName);

				var filePath = scope String();
				entry.GetFilePath(filePath);

				if (!fileName.StartsWith("BeefSetup_"))
					continue;

				var createdTime = entry.GetCreatedTimeUtc();
				if (createdTime > bestTime)
					bestTime = createdTime;

				String date = scope String(fileName, fileName.Length - 14, 10);
				date.Replace('_', '/');

				FileVersionInfo fileVersionInfo = scope .();
				fileVersionInfo.GetVersionInfo(filePath).IgnoreError();

				lines.Add(.(
					scope:: String()..AppendF("<a href={}>BeefSetup {}</a> {:.0}MB <a href=https://github.com/beefytech/Beef/commit/{}>{}</a><br>\n", fileName, date, entry.GetFileSize() / (1024.0 * 1024.0), 
						fileVersionInfo.ProductVersion, fileVersionInfo.ProductVersion.Substring(0, Math.Min(fileVersionInfo.ProductVersion.Length, 6))), createdTime));

				newestLines.Add(.(
					scope:: String()..AppendF("{} {:.0}MB <a href=https://github.com/beefytech/Beef/commit/{}>{}</a>", date, entry.GetFileSize() / (1024.0 * 1024.0),
						fileVersionInfo.ProductVersion, fileVersionInfo.ProductVersion.Substring(0, Math.Min(fileVersionInfo.ProductVersion.Length, 6))), createdTime));
			}

			lines.Sort(scope (lhs, rhs) => rhs.mDate <=> lhs.mDate);
			for (var line in lines)
				html.Append(line.mLine);

			newestLines.Sort(scope (lhs, rhs) => rhs.mDate <=> lhs.mDate);

			if (bestTime == default)
				bestTime = DateTime.Now;

			html.AppendF(
				$"""
					<script>
						var dateLast = new Date(Date.UTC({bestTime.Year}, {bestTime.Month-1}, {bestTime.Day}, {bestTime.Hour}, {bestTime.Minute}, {bestTime.Second}, 0));
						var dateNow = Date.now();
						var diffMS = dateNow - dateLast 
						var diffMin = diffMS / 1000 / 60;
						var diffHour = diffMin / 60;
						var fieldNameElement = document.getElementById('age');
						fieldNameElement.innerHTML = "Newest Build Age: " + diffHour.toFixed(1) + " hours";
					</script>

					</html>
				""");

			File.WriteAllText(@"C:\BeefNightly\index.html", html);
			if (!newestLines.IsEmpty)
				File.WriteAllText(@"C:\BeefNightly\current.html", newestLines.Front.mLine);

			return 0;
		}
	}
}