
void RegCmds()
{
	RegConsoleCmd("sm_vip", cmd_OpenVipMenu);
	RegAdminCmd("sm_vipadmin", cmd_AdminMenu, ADMFLAG_ROOT);
	RegAdminCmd("sm_vip_reload", cmd_AdminReloadConfig, ADMFLAG_ROOT);
	RegAdminCmd("sm_refresh_vips", cmd_AdminReloadPlayerData, ADMFLAG_ROOT);
}

Action cmd_OpenVipMenu(int iClient, int iArgs)
{
	if(g_ePlayerData[iClient].Status == Status_Loading)
	{
		PrintToChat(iClient, "[VIP] Ваши данные загружаются...");
	}
	if(g_ePlayerData[iClient].Status == Status_Error)
	{
		PrintToChat(iClient, "[VIP] Ошибка получения данных из БД");
	}
	else if(g_ePlayerData[iClient].bVIP)
	{
		g_hMainMenu.Display(iClient, MENU_TIME_FOREVER);
	}
	else
	{
		// TODO Notify Panel
		PrintToChat(iClient, "[VIP] У вас нет привилегий...");
		PlaySound(iClient, NO_ACCESS_SOUND);
	}

	return Plugin_Handled;
}

Action cmd_AdminMenu(int iClient, int iArgs)
{
	g_hAdminMainMenu.Display(iClient, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

Action cmd_AdminReloadConfig(int iClient, int iArgs)
{
	ReloadConfiguration(iClient);
	return Plugin_Handled;
}

Action cmd_AdminReloadPlayerData(int iClient, int iArgs)
{
	ReloadPlayerData(iClient);
	return Plugin_Handled;
}