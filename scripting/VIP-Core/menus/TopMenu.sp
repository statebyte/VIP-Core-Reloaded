

static const char g_szAdminMenuLibrary[] = "adminmenu";


void LoadTopMenu()
{
	if(LibraryExists(g_szAdminMenuLibrary))
	{
		OnLibraryAdded(g_szAdminMenuLibrary);
	}
}

public void OnLibraryAdded(const char[] szLibraryName)
{
	if (strcmp(szLibraryName, g_szAdminMenuLibrary) == 0)
	{
		TopMenu hTopMenu = GetAdminTopMenu();
		if (hTopMenu != null)
		{
			OnAdminMenuReady(hTopMenu);
		}
	}
}

public void OnLibraryRemoved(const char[] szLibraryName)
{
	if (strcmp(szLibraryName, g_szAdminMenuLibrary) == 0)
	{
		g_hTopMenu = null;
		g_eAdminMenuObject = INVALID_TOPMENUOBJECT;
	}
}

public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu hTopMenu = TopMenu.FromHandle(aTopMenu);
	if (g_hTopMenu == hTopMenu)
	{
		return;
	}

	g_hTopMenu = hTopMenu;

	AddItemsToTopMenu();
}

void AddItemsToTopMenu()
{
	if (g_eAdminMenuObject == INVALID_TOPMENUOBJECT)
	{
		g_eAdminMenuObject = g_hTopMenu.AddCategory("vip_admin", Handler_TopMenu, "sm_vipadmin", ADMFLAG_ROOT);
	}

	g_hTopMenu.AddItem("vip_search", Handler_MenuSearch, g_eAdminMenuObject, "sm_vipadmin", ADMFLAG_ROOT);
	g_hTopMenu.AddItem("vip_list", Handler_MenuList, g_eAdminMenuObject, "sm_vipadmin", ADMFLAG_ROOT);
	g_hTopMenu.AddItem("vip_reload_players", Handler_MenuReloadPlayers, g_eAdminMenuObject, "sm_vipadmin", ADMFLAG_ROOT);
	g_hTopMenu.AddItem("vip_reload_settings", Handler_MenuReloadSettings, g_eAdminMenuObject, "sm_vipadmin", ADMFLAG_ROOT);
}

public void Handler_TopMenu(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] szBuffer, int iMaxLen)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(szBuffer, iMaxLen, "%T", "VIP_ADMIN_MENU_TITLE", iClient);
		case TopMenuAction_DisplayTitle:	FormatEx(szBuffer, iMaxLen, "%T:\n ", "VIP_ADMIN_MENU_TITLE", iClient);
	}
}

// ************************ ADD_VIP ************************
public void Handler_MenuSearch(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] szBuffer, int iMaxLen)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(szBuffer, iMaxLen, "%T", "FIND_PLAYER", iClient);
		case TopMenuAction_SelectOption:
		{
			g_ePlayerData[iClient].LastMenuType = TOP_MENU;
			//TODO - Search Player
			RedisplayAdminMenu(g_hTopMenu, iClient);
		}
	}
}

// ************************ LIST_VIP ************************

public void Handler_MenuList(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] szBuffer, int iMaxLen)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(szBuffer, iMaxLen, "%T", "MENU_LIST_VIP", iClient);
		case TopMenuAction_SelectOption:
		{
			g_ePlayerData[iClient].LastMenuType = TOP_MENU;
			OpenAdminPlayerList(iClient);
		}
	}
}

// ************************ RELOAD_VIP_PLAYES ************************
public void Handler_MenuReloadPlayers(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] szBuffer, int iMaxLen)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(szBuffer, iMaxLen, "%T", "ADMIN_MENU_RELOAD_VIP_PLAYES", iClient);
		case TopMenuAction_SelectOption:
		{
			ReloadPlayerData(iClient);
			RedisplayAdminMenu(g_hTopMenu, iClient);
		}
	}
}

// ************************ RELOAD_VIP_CFG ************************
public void Handler_MenuReloadSettings(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] szBuffer, int iMaxLen)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(szBuffer, iMaxLen, "%T", "ADMIN_MENU_RELOAD_VIP_CFG", iClient);
		case TopMenuAction_SelectOption:
		{
			ReloadConfiguration(iClient);
			RedisplayAdminMenu(g_hTopMenu, iClient);
		}
	}
}