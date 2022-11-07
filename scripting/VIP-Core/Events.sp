
void HookEvents()
{
	AddCommandListener(ChatEvent, "say");
	AddCommandListener(ChatEvent, "say2");
	AddCommandListener(ChatEvent, "say_team");

	CreateTimer(1.0, TimerChecker, _, TIMER_REPEAT);

	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
}

void Event_PlayerSpawn(Event hEvent, char[] sName, bool bBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));

	if(!IsClientInGame(iClient) || IsFakeClient(iClient)) return;

	if(g_eServerData.SpawnDelay == 0.0)
	{
		CallForward_OnPlayerSpawn(iClient);
		return;
	}

	CreateTimer(g_eServerData.SpawnDelay, OnPlayerSpawn, iClient);
}

Action OnPlayerSpawn(Handle hTimer, any data)
{
	if(IsClientInGame(data) && IsPlayerAlive(data))
		CallForward_OnPlayerSpawn(data);
		
	return Plugin_Handled;
}

Action TimerChecker(Handle hTimer, any data)
{
	PlayerGroup hGroup;
	int iLen = 0;

	for(int i = 1; i <= MaxClients; i++)
	{
		if(g_ePlayerData[i].HookChat == ChatHook_CustomFeature)
		{
			g_hTypingPanel.Display(i, MENU_TIME_FOREVER);
		}

		iLen = g_ePlayerData[i].hGroups.Length;

		for(int j = 0; j < iLen; j++)
		{
			g_ePlayerData[i].hGroups.GetArray(j, hGroup, sizeof(hGroup));

			if(hGroup.ExpireTime != 0 && hGroup.ExpireTime < GetTime())
			{
				g_ePlayerData[i].RemoveGroup(hGroup.Name);
				// TODO - Notify Player
			}
		}
	}
	return Plugin_Continue;
}

public void OnClientPutInServer(int iClient)
{
	if(!IsClientInGame(iClient) || IsFakeClient(iClient) || IsClientSourceTV(iClient)) return;

	g_ePlayerData[iClient].ClearData();
	g_ePlayerData[iClient].SetID();
	g_ePlayerData[iClient].UpdateData();
	g_ePlayerData[iClient].LoadData();
}

public void OnClientDisconnect(int iClient)
{
	if(IsFakeClient(iClient) || IsClientSourceTV(iClient)) return;

	g_ePlayerData[iClient].UpdateData();
}

Action ChatEvent(int iClient, char[] sCommand, int iArgc)
{
	char sValue[D_FEATUREVALUE_LENGTH];
	if(g_ePlayerData[iClient].HookChat > ChatHook_None)
	{
		GetCmdArgString(sValue, sizeof(sValue));
		ReplaceString(sValue, sizeof(sValue), "\"", "");
		TrimString(sValue);

		if(g_ePlayerData[iClient].HookChat == ChatHook_CustomFeature)
		{
			PrintToChatAll("Вы установили новое значение: %s", sValue);
			g_ePlayerData[iClient].HookChat = ChatHook_None;
			int iTarget = g_ePlayerData[iClient].CurrentTarget;

			if(!strcmp(sValue, "clear"))
			{
				g_ePlayerData[iTarget].RemoveCustomFeature(g_ePlayerData[iClient].CurrentFeature);
				DB_RemoveCustomFeature(iTarget, g_ePlayerData[iClient].CurrentFeature, iClient);
				OpenPlayerFeaturesInfoMenu(iClient);
				return Plugin_Handled;
			}

			g_ePlayerData[iTarget].AddCustomFeature(g_ePlayerData[iClient].CurrentFeature, sValue);
			DB_AddCustomFeature(iTarget, g_ePlayerData[iClient].CurrentFeature, sValue, iClient);

			OpenPlayerFeaturesInfoMenu(iClient);
			
			return Plugin_Handled;
		}

		g_ePlayerData[iClient].HookChat = ChatHook_None;
	}
	return Plugin_Continue;
}
