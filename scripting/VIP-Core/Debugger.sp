
void LoadTest()
{
	RegConsoleCmd("sm_vip_test", cmd_Test);
	RegConsoleCmd("sm_vip_dump_groups", cmd_Groups);
	RegConsoleCmd("sm_vip_dump_player", cmd_DumpPlayer);

	addTestTimes();
}

void addTestTimes()
{
	Times hTime;

	hTime.Phrase = "NEVER";
	hTime.Time = 0;
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
	PrintToConsole(iClient, "iClient: %i", g_ePlayerData[iClient].iClient);
	
	PrintToConsole(iClient, "bVIP: %i", g_ePlayerData[iClient].bVIP);

	PrintToConsole(iClient, "hGroups:");
	PrintToConsole(iClient, "------------------");

	int iLen = g_ePlayerData[iClient].hGroups.Length;

	char sBuffer[256];

	for(int i = 0; i < iLen; i++)
	{
		g_ePlayerData[iClient].hGroups.GetString(i, sBuffer, sizeof(sBuffer));
		PrintToConsole(iClient, "%s", sBuffer);
	}

	PrintToConsole(iClient, "hFeatures:");
	PrintToConsole(iClient, "------------------");

	iLen = g_ePlayerData[iClient].hFeatures.Length;

	for(int i = 0; i < iLen; i++)
	{
		PlayerFeature hPFeature;
		g_ePlayerData[iClient].hFeatures.GetArray(i, hPFeature, sizeof(hPFeature));
		PrintToConsole(iClient, "%s - %s | %i", hPFeature.Key, hPFeature.Value, hPFeature.CurrentPriority);
	}
	
	return Plugin_Handled;
}

Action cmd_Groups(int iClient, int iArgs)
{
	int iLen = g_hGroups.Length;
	PrintToConsole(iClient, "> Start dump: \nLen%i", iLen);
	char sBuffer[256];

	for(int i = 0; i < iLen; i++)
	{
		GroupInfo hGroup;
		g_hGroups.GetArray(i, hGroup, sizeof(hGroup));

		PrintToConsole(iClient, "> %s", hGroup.Name);

		PrintToConsole(iClient, "> Feature List");
		int iSize = hGroup.hFeatureList.Length;
		for(int j = 0; j < iSize; j++)
		{
			PlayerFeature hPFeature;
			hGroup.hFeatureList.GetArray(j, hPFeature, sizeof(hPFeature));

			PrintToConsole(iClient, ">> %s - %s : %i", hPFeature.Key, hPFeature.Value, hPFeature.CurrentPriority);
		}

		PrintToConsole(iClient, "> ");
		
		PrintToConsole(iClient, "> Extend List");
		iSize = hGroup.hExtendList.Length;
		for(int j = 0; j < iSize; j++)
		{
			hGroup.hExtendList.GetString(j, sBuffer, sizeof(sBuffer));
			PrintToConsole(iClient, ">> %s", sBuffer);
		}

		PrintToConsole(iClient, "> -------------------");
	}

	return Plugin_Handled;
}