
void ReloadConfiguration(int iClient = 0)
{
	if(!g_eServerData.CoreIsReady) return;

	LoadConfigurationModule();
	RebuildFeatureList();
	ReplyToCommand(iClient, "[VIP] Configuration reloaded successufaly");
}

void ReloadPlayerData(int iClient = 0)
{
	if(!g_eServerData.CoreIsReady) return;

	LoadPlayersData();
	ReplyToCommand(iClient, "[VIP] Reloading player data...");
}

stock bool IsValidClient(int iClient)
{
	return IsClientInGame(iClient) && !IsFakeClient(iClient);
}

stock void VIP_LogMsg(const char[] sMessage, any ...)
{
	static char szBuffer[512];
	VFormat(szBuffer, sizeof(szBuffer), sMessage, 2);
	LogToFile(g_eServerData.LogsPath, szBuffer);
}

stock int UTIL_GetConVarAdminFlag(ConVar hCvar)
{
	char szBuffer[32];
	hCvar.GetString(szBuffer, sizeof(szBuffer));
	return ReadFlagString(szBuffer);
}

void UTIL_GetTimeFromStamp(char[] szBuffer, int iMaxLen, int iTimeStamp, int iClient = LANG_SERVER)
{
	if (iTimeStamp > 31536000)
	{
		int years = iTimeStamp / 31536000;
		int days = iTimeStamp / 86400 % 365;
		if (days > 0)
		{
			FormatEx(szBuffer, iMaxLen, "%d%T %d%T", years, "y.", iClient, days, "d.", iClient);
		}
		else
		{
			FormatEx(szBuffer, iMaxLen, "%d%T", years, "y.", iClient);
		}
		return;
	}
	if (iTimeStamp > 86400)
	{
		int days = iTimeStamp / 86400 % 365;
		int hours = (iTimeStamp / 3600) % 24;
		if (hours > 0)
		{
			FormatEx(szBuffer, iMaxLen, "%d%T %d%T", days, "d.", iClient, hours, "h.", iClient);
		}
		else
		{
			FormatEx(szBuffer, iMaxLen, "%d%T", days, "d.", iClient);
		}
		return;
	}
	else
	{
		int Hours = (iTimeStamp / 3600);
		int Mins = (iTimeStamp / 60) % 60;
		int Secs = iTimeStamp % 60;
		
		if (Hours > 0)
		{
			FormatEx(szBuffer, iMaxLen, "%02d:%02d:%02d", Hours, Mins, Secs);
		}
		else
		{
			FormatEx(szBuffer, iMaxLen, "%02d:%02d", Mins, Secs);
		}
	}
}

stock int UTIL_GetVipClientByAccountID(int iAccountID)
{
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && g_ePlayerData[i].bVIP && g_ePlayerData[i].AccountID == iAccountID) return i;
	}
	return 0;
}

int UTIL_SecondsToTime(int iTime)
{
	// TODO: Add cvar!
	int iTimeType = TIME_MODE_SECONDS;
	switch (iTimeType)
	{
		case TIME_MODE_SECONDS:return iTime;
		case TIME_MODE_MINUTES:return iTime / 60;
		case TIME_MODE_HOURS:return iTime / 3600;
		case TIME_MODE_DAYS:return iTime / 86400;
	}
	
	return -1;
}

int UTIL_TimeToSeconds(int iTime)
{
	// TODO: Add cvar!
	int iTimeType = TIME_MODE_SECONDS;
	switch (iTimeType)
	{
		case TIME_MODE_SECONDS:return iTime;
		case TIME_MODE_MINUTES:return iTime * 60;
		case TIME_MODE_HOURS:return iTime * 3600;
		case TIME_MODE_DAYS:return iTime * 86400;
	}
	
	return -1;
}

stock int UTIL_GetAccountIDFromSteamID(const char[] szSteamID)
{
	if (!strncmp(szSteamID, "STEAM_", 6))
	{
		return StringToInt(szSteamID[10]) << 1 | (szSteamID[8] - 48);
	}

	if (!strncmp(szSteamID, "[U:1:", 5) && szSteamID[strlen(szSteamID)-1] == ']')
	{
		char szBuffer[16];
		strcopy(szBuffer, sizeof(szBuffer), szSteamID[5]);
		szBuffer[strlen(szBuffer)-1] = 0;

		return StringToInt(szBuffer);
	}

	return 0;
}