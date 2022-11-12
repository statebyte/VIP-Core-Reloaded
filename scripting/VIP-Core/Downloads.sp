#include <sdktools_stringtables>

void ReadDownloadList()
{
	char szBuffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szBuffer, sizeof(szBuffer), "data/vip/modules/%s", CONFIG_DOWNLOADLIST_FILENAME);

	if(!FileExists(szBuffer)) return;

	File hFile = OpenFile(szBuffer, "r");

	if (hFile == null) return;

	int iEndPos;
	while (!hFile.EndOfFile() && hFile.ReadLine(szBuffer, sizeof(szBuffer)))
	{
		if (!szBuffer[0])
		{
			continue;
		}

		iEndPos = StrContains(szBuffer, "//");

		if (iEndPos != -1)
		{
			szBuffer[iEndPos] = 0;
		}

		if (szBuffer[0] && IsCharAlpha(szBuffer[0]))
		{
			TrimString(szBuffer);

			File_AddToDownloadsTable(szBuffer);
		}
	}

	delete hFile;
}

void File_AddToDownloadsTable(const char[] szPath)
{
	if (FileExists(szPath))
	{
		AddFileToDownloadsTable(szPath);
		return;
	}

	if (DirExists(szPath))
	{
		Dir_AddToDownloadsTable(szPath);
	}
}

void Dir_AddToDownloadsTable(const char[] szPath)
{
	if (!DirExists(szPath)) return;
	
	DirectoryListing hDir = OpenDirectory(szPath);
	if (hDir == null) return;

	char szDirEntry[PLATFORM_MAX_PATH];
	while (hDir.GetNext(szDirEntry, sizeof(szDirEntry)))
	{
		if (
			!strcmp(szDirEntry, ".") || 
			!strcmp(szDirEntry, "..") || 
			!strcmp(szDirEntry[strlen(szDirEntry)-4], ".bz2"))
		{
			continue;
		}

		Format(szDirEntry, sizeof(szDirEntry), "%s/%s", szPath, szDirEntry);
		File_AddToDownloadsTable(szDirEntry);
	}

	delete hDir;
}