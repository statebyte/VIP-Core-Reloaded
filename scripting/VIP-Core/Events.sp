
void HookEvents()
{
	AddCommandListener(ChatEvent, "say");
	AddCommandListener(ChatEvent, "say2");
	AddCommandListener(ChatEvent, "say_team");
}

public void OnClientPutInServer(int iClient)
{
	g_ePlayerData[iClient].ClearData();
	g_ePlayerData[iClient].LoadData();
}

Action ChatEvent(int iClient, char[] sCommand, int iArgc)
{
	if(g_ePlayerData[iClient].HookChat > ChatHook_None)
	{
		if(g_ePlayerData[iClient].HookChat == ChatHook_CustomFeature)
		{
			int iTarget = g_ePlayerData[iClient].CurrentTarget;
			g_ePlayerData[iTarget].AddCustomFeature(g_ePlayerData[iClient].CurrentFeature, sCommand);
			OpenPlayerFeaturesInfoMenu(iClient);
		}

		g_ePlayerData[iClient].HookChat = ChatHook_None;
	}
	return Plugin_Continue;
}
