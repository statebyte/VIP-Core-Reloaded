
void HookEvents()
{
	AddCommandListener(ChatEvent, "say");
	AddCommandListener(ChatEvent, "say2");
	AddCommandListener(ChatEvent, "say_team");

	CreateTimer(1.0, TimerChecker, _, TIMER_REPEAT);
}

Action TimerChecker(Handle hTimer, any data)
{
	
	return Plugin_Continue;
}

public void OnClientPutInServer(int iClient)
{
	if(!IsClientInGame(iClient) || IsFakeClient(iClient)) return;

	g_ePlayerData[iClient].ClearData();
	g_ePlayerData[iClient].SetID();
	g_ePlayerData[iClient].UpdateData();
	g_ePlayerData[iClient].LoadData();
}

public void OnClientDisconnect(int iClient)
{
	if(IsFakeClient(iClient)) return;

	g_ePlayerData[iClient].UpdateData();
}

Action ChatEvent(int iClient, char[] sCommand, int iArgc)
{
	if(g_ePlayerData[iClient].HookChat > ChatHook_None)
	{
		if(g_ePlayerData[iClient].HookChat == ChatHook_CustomFeature)
		{
			int iTarget = g_ePlayerData[iClient].CurrentTarget;
			g_ePlayerData[iTarget].AddCustomFeature(g_ePlayerData[iClient].CurrentFeature, sCommand);
			
			//DB_AddCustomFeature(iTarget, );
			OpenPlayerFeaturesInfoMenu(iClient);
		}

		g_ePlayerData[iClient].HookChat = ChatHook_None;
	}
	return Plugin_Continue;
}
