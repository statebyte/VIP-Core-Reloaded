
void ReloadConfiguration(int iClient = 0)
{
	LoadGroupsConfig();
	ReplyToCommand(iClient, "[VIP] Configuration reloaded successufaly");
}

void ReloadPlayerData(int iClient = 0)
{
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
