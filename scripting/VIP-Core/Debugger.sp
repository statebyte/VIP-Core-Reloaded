
void LoadTest()
{
	RegConsoleCmd("sm_vip_test", cmd_Test);
	RegConsoleCmd("sm_vip_dump_groups", cmd_Groups);
	RegConsoleCmd("sm_vip_dump_player", cmd_DumpPlayer);

	//addTestTimes();
}

void DebugMsg(DBG_Level iLevel, const char[] sMsg, any ...)
{
	if(iLevel > g_iDBGLevel) return;

	static char szBuffer[512];
	VFormat(szBuffer, sizeof(szBuffer), sMsg, 3);
	LogToFile(g_eServerData.DebugLogsPath, szBuffer);
}
#define DebugMessage(%0) DebugMsg(%0)

void DumpMsg(const char[] sMsg, any ...)
{
	static char szBuffer[512];
	VFormat(szBuffer, sizeof(szBuffer), sMsg, 2);
	LogToFile(g_eServerData.DumpLogsPath, szBuffer);
}

void addTestTimes()
{
	Times hTime;

	hTime.Phrase = "NEVER";
	hTime.Time = 0;
	g_hTimes.PushArray(hTime, sizeof(hTime));

	hTime.Phrase = "15 SECS";
	hTime.Time = 15;
	g_hTimes.PushArray(hTime, sizeof(hTime));

	hTime.Phrase = "1_HOUR";
	hTime.Time = 3600;
	g_hTimes.PushArray(hTime, sizeof(hTime));

	hTime.Phrase = "1_DAY";
	hTime.Time = 86400;
	g_hTimes.PushArray(hTime, sizeof(hTime));

	hTime.Phrase = "1_WEEK";
	hTime.Time = 604800;
	g_hTimes.PushArray(hTime, sizeof(hTime));

	hTime.Phrase = "1_MONTH";
	hTime.Time = 2592000;
	g_hTimes.PushArray(hTime, sizeof(hTime));

	hTime.Phrase = "6_MONTHS";
	hTime.Time = 15552000;
	g_hTimes.PushArray(hTime, sizeof(hTime));
}

Action cmd_Test(int iClient, int iArgs)
{
	g_ePlayerData[iClient].AddGroup("vip2", 1665577639);
	g_ePlayerData[iClient].AddGroup("vip1", 1667996839);
	return Plugin_Handled;
}

Action cmd_DumpPlayer(int iClient, int iArgs)
{
	DumpMsg("iClient: %i", g_ePlayerData[iClient].iClient);
	
	DumpMsg("bVIP: %i", g_ePlayerData[iClient].bVIP);

	DumpMsg("hGroups:");
	DumpMsg("------------------");

	int iLen = g_ePlayerData[iClient].hGroups.Length;

	char sBuffer[256];

	for(int i = 0; i < iLen; i++)
	{
		g_ePlayerData[iClient].hGroups.GetString(i, sBuffer, sizeof(sBuffer));
		DumpMsg("%s", sBuffer);
	}

	DumpMsg("hFeatures:");
	DumpMsg("------------------");

	iLen = g_ePlayerData[iClient].hFeatures.Length;

	for(int i = 0; i < iLen; i++)
	{
		PlayerFeature hPFeature;
		g_ePlayerData[iClient].hFeatures.GetArray(i, hPFeature, sizeof(hPFeature));
		DumpMsg("%s - %s | %i (%s)", hPFeature.Key, hPFeature.Value, hPFeature.CurrentPriority, hPFeature.bEnabled ? "Enable" : "Disable");
	}
	
	return Plugin_Handled;
}

Action cmd_Groups(int iClient, int iArgs)
{
	int iLen = g_hGroups.Length;
	DumpMsg("> Start dump: \nLen%i", iLen);
	char sBuffer[256];

	for(int i = 0; i < iLen; i++)
	{
		GroupInfo hGroup;
		g_hGroups.GetArray(i, hGroup, sizeof(hGroup));

		DumpMsg("> %s", hGroup.Name);

		DumpMsg("> Feature List");
		int iSize = hGroup.hFeatureList.Length;
		for(int j = 0; j < iSize; j++)
		{
			PlayerFeature hPFeature;
			hGroup.hFeatureList.GetArray(j, hPFeature, sizeof(hPFeature));

			DumpMsg(">> %s - %s : %i", hPFeature.Key, hPFeature.Value, hPFeature.CurrentPriority);
		}

		DumpMsg("> ");
		
		DumpMsg("> Extend List");
		iSize = hGroup.hExtendList.Length;
		for(int j = 0; j < iSize; j++)
		{
			hGroup.hExtendList.GetString(j, sBuffer, sizeof(sBuffer));
			DumpMsg(">> %s", sBuffer);
		}

		DumpMsg("> -------------------");
	}

	return Plugin_Handled;
}