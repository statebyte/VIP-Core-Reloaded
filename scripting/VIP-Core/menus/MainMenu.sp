

void LoadMainMenu()
{
	g_hMainMenu = new Menu(MainMenuHandler, MenuAction_Select|MenuAction_Cancel|MenuAction_End|MenuAction_DrawItem|MenuAction_DisplayItem|MenuAction_Display);

	g_hMainMenu.AddItem("NO_FEATURES", "NO_FEATURES", ITEMDRAW_DISABLED);
}

void OpenVIPInfo(int iClient)
{
	SetGlobalTransTarget(iClient);

	char sBuffer[256];
	Menu hMenu = new Menu(VIPInfoMenuHandler);
	hMenu.ExitBackButton = true;
	hMenu.SetTitle("Информация о VIP-статусе\n \n");

	int iLen = g_ePlayerData[iClient].hGroups.Length;

	if(iLen > 0)
	{
		hMenu.AddItem("", "Список ваших групп:", ITEMDRAW_DISABLED);

		for(int i = 0; i < iLen; i++)
		{
			PlayerGroup hGroup;
			g_ePlayerData[iClient].hGroups.GetArray(i, hGroup, sizeof(hGroup));

			if(hGroup.ExpireTime == 0) sBuffer = "NEVER";
			else UTIL_GetTimeFromStamp(sBuffer, sizeof(sBuffer), hGroup.ExpireTime - GetTime(), iClient);
			
			Format(sBuffer, sizeof(sBuffer), "%s [%s]", hGroup.Name, sBuffer);

			hMenu.AddItem("", sBuffer, ITEMDRAW_DISABLED);
		}
	}

	hMenu.AddItem("", "Список ваших функций:", ITEMDRAW_DISABLED);

	iLen = g_hFeatures.Length;

	for(int i = 0; i < iLen; i++)
	{
		Feature hFeature;
		g_hFeatures.GetArray(i, hFeature, sizeof(hFeature));
		int iIndex;
		if((iIndex = g_ePlayerData[iClient].GetFeatureIDByName(hFeature.Key)) != -1)
		{
			PlayerFeature hPFeature;
			g_ePlayerData[iClient].hFeatures.GetArray(iIndex, hPFeature, sizeof(hPFeature));

			if(hFeature.ValType == BOOL)
			{
				FormatEx(sBuffer, sizeof(sBuffer), TranslationPhraseExists(hFeature.Key) ? "%t [%s]" : "%s [%s]", hFeature.Key, StringToInt(hPFeature.Value) ? "Enabled" : "Disabled");
			}
			else FormatEx(sBuffer, sizeof(sBuffer), TranslationPhraseExists(hFeature.Key) ? "%t [%s]" : "%s [%s]", hFeature.Key, hPFeature.Value);

			// if(TranslationPhraseExists(hFeature.Key))
			// {
			// 	FormatEx(sBuffer, sizeof(sBuffer), "%t [%s]", hFeature.Key, hPFeature.Value);
			// }
			// else
			// {
			// 	FormatEx(sBuffer, sizeof(sBuffer), "%s [%s]", hFeature.Key, hPFeature.Value);
			// }

			hMenu.AddItem("", sBuffer, ITEMDRAW_DISABLED);
		}
	}



	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

void RebuildVIPMenu()
{
	g_hMainMenu.RemoveAllItems();

	char sBuffer[256];

	g_hMainMenu.AddItem("__info", "Информация о VIP-статусе\n \n");

	int iLen = g_hFeatures.Length;
	for(int i = 0; i < iLen; i++)
	{
		Feature hFeature;
		g_hFeatures.GetArray(i, hFeature, sizeof(hFeature));
		FormatEx(sBuffer, sizeof(sBuffer), "%s", hFeature.Key);
		g_hMainMenu.AddItem(hFeature.Key, sBuffer);
	}
}

int VIPInfoMenuHandler(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	switch(action)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel:
		{
			if(iItem == MenuCancel_ExitBack)
			{
				g_hMainMenu.Display(iClient, MENU_TIME_FOREVER);
			}
		}
	}
	return 0;
}

int MainMenuHandler(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	char sBuffer[VIP_FEATURENAME_LENGTH];

	switch(action)
	{
		case MenuAction_Display:
		{
			SetGlobalTransTarget(iClient);
			char szTitle[256];
			FormatEx(szTitle, sizeof(szTitle), "%t\n \n", "VIP_MENU_TITLE");
			(view_as<Panel>(iItem)).SetTitle(szTitle);
		}
		case MenuAction_Select:
		{
			hMenu.GetItem(iItem, sBuffer, sizeof(sBuffer));

			if(!strcmp(sBuffer, "__info"))
			{
				OpenVIPInfo(iClient);
				return 0;
			}

			int iIndex = GetFeatureIDByKey(sBuffer);

			if(iIndex != -1)
			{
				Feature hFeature;
				g_hFeatures.GetArray(iIndex, hFeature, sizeof(hFeature));

				if(hFeature.Type == TOGGLABLE)
				{
					if(CallForward_OnFeatureToggle(iClient, hFeature.Key) == Plugin_Continue)
					{
						g_ePlayerData[iClient].ToggleFeatureStatus(hFeature.Key);

						char sBuf[4];
						IntToString(view_as<int>(g_ePlayerData[iClient].GetFeatureToggleStatus(hFeature.Key)), sBuf, sizeof(sBuf));
						DB_SaveStorage(iClient, hFeature.Key, sBuf);
					}
					

					//if(g_ePlayerData[iClient].IsFeatureEnable(hFeature.Key)) g_ePlayerData[iClient].DisableFeature(hFeature.Key);
					//else g_ePlayerData[iClient].EnableFeature(hFeature.Key);

					g_hMainMenu.DisplayAt(iClient, hMenu.Selection, MENU_TIME_FOREVER);
				}
				else
				{
					if(hFeature.OnSelectCB != INVALID_FUNCTION)
					{
						g_ePlayerData[iClient].CurrentPage = hMenu.Selection;
						if (Function_OnItemSelect(hFeature.hPlugin, hFeature.OnSelectCB, iClient, sBuffer))
						{
							hMenu.DisplayAt(iClient, hMenu.Selection, MENU_TIME_FOREVER);
						}
					}
				}
			}
			else g_hMainMenu.DisplayAt(iClient, hMenu.Selection, MENU_TIME_FOREVER);
		}
		case MenuAction_DrawItem:
		{
			int iStyle;
			hMenu.GetItem(iItem, sBuffer, sizeof(sBuffer));

			if(!strcmp(sBuffer, "NO_FEATURES"))
			{
				return  g_hFeatures.Length == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_RAWLINE;
			}

			if(!strcmp(sBuffer, "__info"))
			{
				return ITEMDRAW_DEFAULT;
			}

			int iIndex = GetFeatureIDByKey(sBuffer);

			if(iIndex != -1)
			{
				Feature hFeature;
				g_hFeatures.GetArray(iIndex, hFeature, sizeof(hFeature));
				
				if(hFeature.Type == HIDE)
				{
					return ITEMDRAW_RAWLINE;
				}

				if(hFeature.OnDrawCB != INVALID_FUNCTION)
				{
					Call_StartFunction(hFeature.hPlugin, hFeature.OnDrawCB);
					Call_PushCell(iClient);
					Call_PushString(sBuffer);
					Call_PushCell(iStyle);
					Call_Finish(iStyle);
				}
			}

			if(g_ePlayerData[iClient].GetFeatureIDByName(sBuffer) == -1) 
			{
				// TODO: Добавить проверку на видимость недоступных функций...
				return ITEMDRAW_DISABLED;
			}
			
			return iStyle;
		}
		case MenuAction_DisplayItem:
		{
			bool bResult;
			static char szDisplay[128];

			hMenu.GetItem(iItem, sBuffer, sizeof(sBuffer));

			int iIndex = GetFeatureIDByKey(sBuffer);

			if(iIndex != -1)
			{
				Feature hFeature;
				g_hFeatures.GetArray(iIndex, hFeature, sizeof(hFeature));
				
				char sBuf[32];
				
				if(g_ePlayerData[iClient].GetFeatureIDByName(hFeature.Key) == -1)
				{
					FormatEx(sBuf, sizeof(sBuf), "[%T]", "NO_ACCESS", iClient);
				}
				else if(hFeature.Type == TOGGLABLE)
				{
					FormatEx(sBuf, sizeof(sBuf), "[%T]", g_ePlayerData[iClient].GetFeatureToggleStatus(hFeature.Key) == ENABLED ? "ENABLED" : "DISABLED", iClient);
				}

				if(TranslationPhraseExists(hFeature.Key))
				{
					//PrintToChat(iClient, "TranslationPhraseExists true");
					FormatEx(szDisplay, sizeof(szDisplay), "%T %s", hFeature.Key, iClient, sBuf);
				}
				else
				{
					//PrintToChat(iClient, "TranslationPhraseExists false");
					FormatEx(szDisplay, sizeof(szDisplay), "%s %s", hFeature.Key, sBuf);
				}

				if(hFeature.OnDisplayCB != INVALID_FUNCTION)
				{
					Call_StartFunction(hFeature.hPlugin, hFeature.OnDisplayCB);
					Call_PushCell(iClient);
					Call_PushString(hFeature.Key);
					Call_PushStringEx(szDisplay, sizeof(szDisplay), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
					Call_PushCell(sizeof(szDisplay));
					Call_Finish(bResult);
				}
				else bResult = true;
			}

			if (bResult)
			{
				return RedrawMenuItem(szDisplay);
			}
		}
	}
	return 0;
}