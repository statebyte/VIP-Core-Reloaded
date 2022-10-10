
void LoadAdminMenu()
{
	g_hAdminMainMenu = new Menu(AdminMenuHandler);
	g_hAdminMainMenu.SetTitle("[VIP] Администрирование\n \n");

	g_hAdminMainMenu.AddItem("search", "Найти игрока [TODO]", ITEMDRAW_DISABLED);
	g_hAdminMainMenu.AddItem("list", "Список игроков\n \n");

	g_hAdminMainMenu.AddItem("reload_modules", "Перезагрузить список модулей [TODO]", ITEMDRAW_DISABLED);
	g_hAdminMainMenu.AddItem("reload_players", "Перезагрузить данные игроков");
	g_hAdminMainMenu.AddItem("reload_config", "Перезагрузить настройки VIP");
	
}

int AdminMenuHandler(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sInfo[32];
			hMenu.GetItem(iItem, sInfo, sizeof(sInfo));

			if(!strcmp(sInfo, "list"))
			{
				OpenAdminPlayerList(iClient);
				return 0;
			}

			if(!strcmp(sInfo, "reload_config")) ReloadConfiguration(iClient);

			if(!strcmp(sInfo, "reload_players")) ReloadPlayerData(iClient);

			g_hAdminMainMenu.Display(iClient, MENU_TIME_FOREVER);
		}
	}
	return 0;
}

void OpenAdminPlayerList(int iClient, int iPage = 0)
{
	Menu hMenu = new Menu(AdminPlayerListMenuHandler, MenuAction_Cancel);
	hMenu.SetTitle("[VIP] Список игроков\n \n");
	hMenu.ExitBackButton = true;

	char sBuffer[64], sBuf[16];

	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		int iUserID = GetClientUserId(i);
		IntToString(iUserID, sBuf, sizeof(sBuf));
		FormatEx(sBuffer, sizeof(sBuffer), "%N", i);
		hMenu.AddItem(sBuf, sBuffer);
	}

	hMenu.DisplayAt(iClient, iPage, MENU_TIME_FOREVER);
}

int AdminPlayerListMenuHandler(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete hMenu;
		}
		case MenuAction_Cancel:
		{
			if(iItem == MenuCancel_ExitBack)
			g_hAdminMainMenu.Display(iClient, MENU_TIME_FOREVER);
		}
		case MenuAction_Select:
		{
			char sInfo[32];
			hMenu.GetItem(iItem, sInfo, sizeof(sInfo));

			int iUserID = StringToInt(sInfo);
			int iTarget = GetClientOfUserId(iUserID);

			g_ePlayerData[iClient].CurrentTarget = iTarget;

			if(iTarget != -1)
			{
				OpenPlayerInfoMenu(iClient);
			}
			else
			{
				OpenAdminPlayerList(iClient, GetMenuSelectionPosition());
			}
		}
	}
	return 0;
}

void OpenPlayerInfoMenu(int iClient)
{
	int iTarget = g_ePlayerData[iClient].CurrentTarget;

	if(iTarget == -1)
	{
		OpenAdminPlayerList(iClient);
		return;
	}

	Menu hMenu = new Menu(AdminPlayerInfoMenuHandler, MenuAction_Cancel);
	hMenu.SetTitle("[VIP] Настройки пользователя %N\n \n", iTarget);
	hMenu.ExitBackButton = true;

	hMenu.AddItem("groups", "Настройка групп");
	hMenu.AddItem("features", "Настройка функций");

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int AdminPlayerInfoMenuHandler(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete hMenu;
		}
		case MenuAction_Cancel:
		{
			if(iItem == MenuCancel_ExitBack)
			OpenAdminPlayerList(iClient);
		}
		case MenuAction_Select:
		{
			char sInfo[32];
			hMenu.GetItem(iItem, sInfo, sizeof(sInfo));

			if(!strcmp(sInfo, "groups")) OpenPlayerGroupsInfoMenu(iClient);

			if(!strcmp(sInfo, "features")) OpenPlayerFeaturesInfoMenu(iClient);
		}
	}
	return 0;
}

void OpenPlayerGroupsInfoMenu(int iClient)
{
	int iTarget = g_ePlayerData[iClient].CurrentTarget;

	Menu hMenu = new Menu(AdminPlayerGroupsInfoMenuHandler, MenuAction_Cancel);
	hMenu.SetTitle("[VIP] Список групп игрока %N\n \n", iTarget);
	hMenu.ExitBackButton = true;

	char sBuffer[256], sTime[64];
	int iLen = g_hGroups.Length;
	for(int i = 0; i < iLen; i++)
	{
		GroupInfo hGroup;
		g_hGroups.GetArray(i, hGroup, sizeof(hGroup));

		if(g_ePlayerData[iTarget].CheckGroup(hGroup.Name))
		{
			PrintToServer(hGroup.Name);
			int iIndex = g_ePlayerData[iTarget].GetGroupIDByName(hGroup.Name);
			int iExpireTime = g_ePlayerData[iTarget].GetExpireTimeByGroupID(iIndex);
			UTIL_GetTimeFromStamp(sTime, sizeof(sTime), iExpireTime - GetTime(), iClient);
			FormatEx(sBuffer, sizeof(sBuffer), "[%s] %s [%s]", "-", hGroup.Name, sTime);
		}
		else FormatEx(sBuffer, sizeof(sBuffer), "[%s] %s", "+", hGroup.Name);

		
		hMenu.AddItem(hGroup.Name, sBuffer);
	}

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int AdminPlayerGroupsInfoMenuHandler(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete hMenu;
		}
		case MenuAction_Cancel:
		{
			if(iItem == MenuCancel_ExitBack)
			OpenPlayerInfoMenu(iClient);
		}
		case MenuAction_Select:
		{
			PrintToServer("...");
		}
	}
	return 0;
}

void OpenPlayerFeaturesInfoMenu(int iClient)
{
	int iTarget = g_ePlayerData[iClient].CurrentTarget;

	Menu hMenu = new Menu(AdminPlayerFeaturesInfoMenuHandler, MenuAction_Cancel);
	hMenu.SetTitle("[VIP] Настройки игрока %N\n \n", iTarget);
	hMenu.ExitBackButton = true;

	char sBuffer[256];
	//int iLen = g_ePlayerData[iTarget].hFeatures.Length;

	int iLen = g_hFeatures.Length;

	if(iLen == 0)
	{
		hMenu.AddItem("", "No Features", ITEMDRAW_DISABLED);
	}

	hMenu.AddItem("__save", "Сохранить текущую конфигурацию как вип группу (TODO)\n \n");

	for(int i = 0; i < iLen; i++)
	{
		Feature hFeature;
		g_hFeatures.GetArray(i, hFeature, sizeof(hFeature));

		int iFeatureID = g_ePlayerData[iTarget].GetFeatureIDByName(hFeature.Key);
		
		if(iFeatureID != -1)
		{
			PlayerFeature hPFeature;
			g_ePlayerData[iTarget].hFeatures.GetArray(iFeatureID, hPFeature, sizeof(hPFeature));

			PrintToServer(hPFeature.Key);

			GroupInfo hGroup;
			if(hPFeature.CurrentPriority != -1)
			g_hGroups.GetArray(hPFeature.CurrentPriority, hGroup, sizeof(hGroup));

			FormatEx(sBuffer, sizeof(sBuffer), "%s [%s] (%s)", hFeature.Key, hPFeature.Value, hPFeature.CurrentPriority == -1 ? "Custom" : hGroup.Name);
		}
		else 
		{
			FormatEx(sBuffer, sizeof(sBuffer), "%s [%s]", hFeature.Key, "No Access");
		}
		
		hMenu.AddItem(hFeature.Key, sBuffer);
	}

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

int AdminPlayerFeaturesInfoMenuHandler(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete hMenu;
		}
		case MenuAction_Cancel:
		{
			if(iItem == MenuCancel_ExitBack)
			OpenPlayerInfoMenu(iClient);
		}
		case MenuAction_Select:
		{
			char sInfo[32];
			hMenu.GetItem(iItem, sInfo, sizeof(sInfo));

			if(!strcmp(sInfo, "__save"))
			{
				PrintToServer("...");
				OpenPlayerFeaturesInfoMenu(iClient);
				return 0;
			}

			//strcopy(g_ePlayerData[iClient].CurrentFeature, sizeof(g_ePlayerData[iClient].CurrentFeature))

			//ConfirmMenu(iClient, "");
			
			OpenPlayerFeaturesInfoMenu(iClient);
		}
	}
	return 0;
}

// void ConfirmMenu(int iClient, char[] sQues, Function hCallBack)
// {
// 	g_ePlayerData[iClient].hCallBack = hCallBack;

// 	Menu hMenu = new Menu(ConfirmMenuHandler);
// 	hMenu.SetTitle("[VIP] Подтверждение\n \n%s?\n \n", sQues);

// 	hMenu.AddItem("yes", "Да");
// 	hMenu.AddItem("no", "Нет");

// 	hMenu.ExitBackButton = true;
// 	hMenu.Display(iClient, MENU_TIME_FOREVER);
// }

// int ConfirmMenuHandler(Menu hMenu, MenuAction action, int iClient, int iItem)
// {
// 	switch(action)
// 	{
// 		case MenuAction_End:
// 		{

// 		}
// 		case MenuAction_Select:
// 		{
			
// 		}
// 	}
// 	return 0;
// }