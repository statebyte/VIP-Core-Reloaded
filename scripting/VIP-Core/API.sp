
#define RegNative(%0)	CreateNative("VIP_" ... #%0, Native_%0)

static Handle g_hGlobalForward_OnVIPLoaded;
static Handle g_hGlobalForward_OnRebuildFeatureList;
static Handle g_hGlobalForward_OnAddGroup;
static Handle g_hGlobalForward_OnRemoveGroup;
static Handle g_hGlobalForward_OnPlayerSpawn;
static Handle g_hGlobalForward_OnFeatureToggle;
static Handle g_hGlobalForward_OnFeatureRegistered;
static Handle g_hGlobalForward_OnFeatureUnregistered;
static Handle g_hGlobalForward_OnClientLoaded;
static Handle g_hGlobalForward_OnVIPClientLoaded;
static Handle g_hGlobalForward_OnClientDisconnect;

void API_SetupForwards()
{
	g_hGlobalForward_OnVIPLoaded					= CreateGlobalForward("VIP_OnVIPLoaded", ET_Ignore);
	g_hGlobalForward_OnRebuildFeatureList			= CreateGlobalForward("VIP_OnRebuildFeatureList", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnAddGroup						= CreateGlobalForward("VIP_OnAddGroup", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnRemoveGroup					= CreateGlobalForward("VIP_OnRemoveGroup", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnPlayerSpawn					= CreateGlobalForward("VIP_OnPlayerSpawn", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hGlobalForward_OnFeatureToggle				= CreateGlobalForward("VIP_OnFeatureToggle", ET_Hook, Param_Cell, Param_String, Param_Cell, Param_Cell);
	g_hGlobalForward_OnFeatureRegistered			= CreateGlobalForward("VIP_OnFeatureRegistered", ET_Ignore, Param_String);
	g_hGlobalForward_OnFeatureUnregistered			= CreateGlobalForward("VIP_OnFeatureUnregistered", ET_Ignore, Param_String);
	g_hGlobalForward_OnClientLoaded					= CreateGlobalForward("VIP_OnClientLoaded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientLoaded				= CreateGlobalForward("VIP_OnVIPClientLoaded", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnClientDisconnect				= CreateGlobalForward("VIP_OnClientDisconnect", ET_Ignore, Param_Cell, Param_Cell);
}

public APLRes AskPluginLoad2(Handle myself, bool bLate, char[] szError, int err_max) 
{
	g_eServerData.Engine = GetEngineVersion();

	RegNative(IsVIPLoaded);

	RegNative(RegisterFeature);
	RegNative(UnregisterFeature);
	RegNative(UnregisterMe);
	RegNative(GetCurrentVersionInterface);

	RegNative(IsClientVIP);
	RegNative(GetClientGroupName);
	RegNative(GetClientGroupExpire);
	RegNative(GetClientGroupCount);

	RegNative(GetClientVIPGroup);
	RegNative(GiveClientGroup);
	RegNative(RemoveClientGroup);

	RegNative(GetDatabase);
	RegNative(GetDatabaseType);
	RegNative(SendClientVIPMenu);

	RegNative(IsValidFeature);
	RegNative(GetFeatureType);
	RegNative(GetFeatureValueType);
	RegNative(GetClientFeatureStatus);

	RegNative(IsClientFeatureUse);
	RegNative(GetClientFeatureInt);
	RegNative(GetClientFeatureBool);
	RegNative(GetClientFeatureFloat);
	RegNative(GetClientFeatureString);

	RegNative(IsGroupExists);
	RegNative(IsValidVIPGroup);


	RegNative(SaveClientStorageValue);
	RegNative(GetClientStorageValue);

	RegNative(GetTimeFromStamp);


	

	RegPluginLibrary("vip_core");
	
	return APLRes_Success;
}

void CallForward_OnClientLoaded(int iClient)
{
	Call_StartForward(g_hGlobalForward_OnClientLoaded);
	Call_PushCell(iClient);
	Call_PushCell(g_ePlayerData[iClient].bVIP);
	Call_Finish();

	if(g_ePlayerData[iClient].bVIP)
	{
		CallForward_OnVIPClientLoaded(iClient);
	}
}

void CallForward_OnVIPClientLoaded(int iClient)
{
	Call_StartForward(g_hGlobalForward_OnVIPClientLoaded);
	Call_PushCell(iClient);
	Call_Finish();
}

void CallForward_OnClientDisconnect(int iClient)
{
	Call_StartForward(g_hGlobalForward_OnClientDisconnect);
	Call_PushCell(iClient);
	Call_PushCell(g_ePlayerData[iClient].bVIP);
	Call_Finish();
}

Action CallForward_OnFeatureToggle(int iClient, char[] sFeature)
{
	Action PluginResult;

	Call_StartForward(g_hGlobalForward_OnFeatureToggle);
	Call_PushCell(iClient);
	Call_PushString(sFeature);
	Call_PushCell(g_ePlayerData[iClient].GetFeatureToggleStatus(sFeature));
	Call_PushCell(!g_ePlayerData[iClient].GetFeatureToggleStatus(sFeature));
	Call_Finish(PluginResult);

	return PluginResult;
}

void CallForward_OnFeatureRegistered(char[] sFeature)
{
	Call_StartForward(g_hGlobalForward_OnFeatureRegistered);
	Call_PushString(sFeature);
	Call_Finish();
}

void CallForward_OnFeatureUnregistered(char[] sFeature)
{
	Call_StartForward(g_hGlobalForward_OnFeatureUnregistered);
	Call_PushString(sFeature);
	Call_Finish();
}

void CallForward_OnVIPLoaded()
{
	if(!g_eServerData.CoreIsReady)
	{
		PrintToServer("------------------- VIP Core ---------------------");
		PrintToServer("VIP Core is ready to working!");
		PrintToServer(" ");
		PrintToServer("Groups: %i", g_hGroups.Length);
		PrintToServer("Database: %s", g_eServerData.DB_Type == DB_None ? "No" : "Yes");
		
		if(g_eServerData.DB_Type != DB_None)
		{
			char sDriverName[64];
			//SQL_ReadDriver(g_eServerData.DB).GetProduct(sDriverName, sizeof(sDriverName));
			SQL_GetDriverProduct(SQL_ReadDriver(g_eServerData.DB), sDriverName, sizeof(sDriverName));
			PrintToServer("Database Type: %s", sDriverName);
		}
		
		PrintToServer(" ");
		PrintToServer("Authors: " ... PL_AUTHOR);
		PrintToServer("Version: " ... PL_VERSION);
		PrintToServer("------------------- VIP Core ---------------------");
	}
	
	g_eServerData.CoreIsReady = true;

	Call_StartForward(g_hGlobalForward_OnVIPLoaded);
	Call_Finish();
}

void CallForward_OnRebuildFeatureList(int iClient)
{
	Call_StartForward(g_hGlobalForward_OnRebuildFeatureList);
	Call_PushCell(iClient);
	Call_Finish();
}

void CallForward_OnPlayerSpawn(int iClient)
{
	int iTeam = GetClientTeam(iClient);

	Call_StartForward(g_hGlobalForward_OnPlayerSpawn);
	Call_PushCell(iClient);
	Call_PushCell(iTeam);
	Call_PushCell(g_ePlayerData[iClient].bVIP);
	Call_Finish();
}

void CallForward_OnAddGroup(int iClient, char[] sGroup)
{
	Call_StartForward(g_hGlobalForward_OnAddGroup);
	Call_PushCell(iClient);
	Call_PushString(sGroup);
	Call_Finish();
}

void CallForward_OnRemoveGroup(int iClient, char[] sGroup)
{
	Call_StartForward(g_hGlobalForward_OnRemoveGroup);
	Call_PushCell(iClient);
	Call_PushString(sGroup);
	Call_Finish();
}

bool Function_OnItemSelect(Handle hPlugin, Function FuncSelect, int iClient, const char[] szFeature)
{
	bool bResult;
	Call_StartFunction(hPlugin, FuncSelect);
	Call_PushCell(iClient);
	Call_PushString(szFeature);
	Call_Finish(bResult);
	
	return bResult;
}

public int Native_IsClientFeatureUse(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(!CheckValidClient(iClient))
	{
		return ThrowNativeError(1, "Invalid Client index %i", iClient);
	}

	char sFeature[D_FEATURENAME_LENGTH];
	GetNativeString(2, sFeature, sizeof(sFeature));

	return g_ePlayerData[iClient].GetFeatureIDByName(sFeature) != -1 ? true : false;
}

public int Native_GetClientFeatureBool(Handle hPlugin, int iNumParams)
{
	return Native_GetClientFeatureInt(hPlugin, iNumParams) == 0 ? 0 : 1;
}

public int Native_GetClientFeatureInt(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(!CheckValidClient(iClient))
	{
		return ThrowNativeError(1, "Invalid Client index %i", iClient);
	}

	char sFeature[D_FEATURENAME_LENGTH];
	GetNativeString(2, sFeature, sizeof(sFeature));

	int iIndex = g_ePlayerData[iClient].GetFeatureIDByName(sFeature);

	if(iIndex != -1)
	{
		PlayerFeature hFeature;
		g_ePlayerData[iClient].hFeatures.GetArray(iIndex, hFeature, sizeof(hFeature));

		return StringToInt(hFeature.Value);
	}

	return 0;
}

public int Native_GetClientFeatureFloat(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(!CheckValidClient(iClient))
	{
		return ThrowNativeError(1, "Invalid Client index %i", iClient);
	}

	char sFeature[D_FEATURENAME_LENGTH];
	GetNativeString(2, sFeature, sizeof(sFeature));

	int iIndex = g_ePlayerData[iClient].GetFeatureIDByName(sFeature);

	if(iIndex != -1)
	{
		PlayerFeature hFeature;
		g_ePlayerData[iClient].hFeatures.GetArray(iIndex, hFeature, sizeof(hFeature));

		return view_as<int>(StringToFloat(hFeature.Value));
	}

	return 0;
}

public int Native_GetClientFeatureString(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iLen = GetNativeCell(4);

	if(!CheckValidClient(iClient))
	{
		return ThrowNativeError(1, "Invalid Client index %i", iClient);
	}

	char sFeature[D_FEATURENAME_LENGTH];
	GetNativeString(2, sFeature, sizeof(sFeature));

	int iIndex = g_ePlayerData[iClient].GetFeatureIDByName(sFeature);

	if(iIndex != -1)
	{
		PlayerFeature hFeature;
		g_ePlayerData[iClient].hFeatures.GetArray(iIndex, hFeature, sizeof(hFeature));

		SetNativeString(3, hFeature.Value, iLen, true);
		return 1;
	}

	SetNativeString(3, NULL_STRING, iLen, true);

	return 0;
}

public int Native_GetClientFeatureStatus(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(!CheckValidClient(iClient))
	{
		return ThrowNativeError(1, "Invalid Client index %i", iClient);
	}

	char sFeature[D_FEATURENAME_LENGTH];
	GetNativeString(2, sFeature, sizeof(sFeature));

	return view_as<int>(g_ePlayerData[iClient].GetFeatureToggleStatus(sFeature));
}

public int Native_IsGroupExists(Handle hPlugin, int iNumParams)
{
	char sGroup[D_GROUPNAME_LENGTH];
	GetNativeString(1, sGroup, sizeof(sGroup));

	return GetGroupIDByName(sGroup) == -1 ? 0 : 1;
}

public int Native_IsValidVIPGroup(Handle hPlugin, int iNumParams)
{
	return Native_IsGroupExists(hPlugin, iNumParams);
}

public int Native_IsValidFeature(Handle hPlugin, int iNumParams)
{
	char sFeature[D_FEATURENAME_LENGTH];
	GetNativeString(1, sFeature, sizeof(sFeature));

	return IsFeatureExists(sFeature);
}

public int Native_GetFeatureType(Handle hPlugin, int iNumParams)
{
	char sFeature[D_FEATURENAME_LENGTH];
	GetNativeString(1, sFeature, sizeof(sFeature));

	int iIndex = GetFeatureIDByKey(sFeature);

	if(iIndex == -1)
	{
		return ThrowNativeError(1, "Error index");
	}

	Feature hFreature;
	g_hFeatures.GetArray(iIndex, hFreature, sizeof(hFreature));

	return view_as<int>(hFreature.Type);
}

public int Native_GetFeatureValueType(Handle hPlugin, int iNumParams)
{
	char sFeature[D_FEATURENAME_LENGTH];
	GetNativeString(1, sFeature, sizeof(sFeature));

	int iIndex = GetFeatureIDByKey(sFeature);

	if(iIndex == -1)
	{
		return ThrowNativeError(1, "Error index");
	}

	Feature hFreature;
	g_hFeatures.GetArray(iIndex, hFreature, sizeof(hFreature));

	return view_as<int>(hFreature.ValType);
}

public int Native_SendClientVIPMenu(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if(GetNativeCell(2))
	{
		g_hMainMenu.DisplayAt(iClient, MENU_TIME_FOREVER, g_ePlayerData[iClient].CurrentPage);
	}
	else g_hMainMenu.Display(iClient, MENU_TIME_FOREVER);

	return 1;
}

public int Native_GetDatabaseType(Handle hPlugin, int iNumParams)
{
	return view_as<int>(g_eServerData.DB_Type);
}

public int Native_GetDatabase(Handle hPlugin, int iNumParams)
{
	return view_as<int>(CloneHandle(g_eServerData.DB, hPlugin));
}

public int Native_GetClientGroupExpire(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iGroupID = GetNativeCell(2);

	PlayerGroup hGroup;
	g_ePlayerData[iClient].hGroups.GetArray(iGroupID, hGroup, sizeof(hGroup));

	return hGroup.ExpireTime;
}

public int Native_GiveClientGroup(Handle hPlugin, int iNumParams)
{
	int iAdmin = GetNativeCell(1);
	int iClient = GetNativeCell(2);
	int iTime = GetNativeCell(3);
	bool bAddToDB = view_as<bool>(GetNativeCell(5));

	char sGroup[D_GROUPNAME_LENGTH];
	GetNativeString(4, sGroup, sizeof(sGroup));

	if(bAddToDB)
	{
		// TODO
		DB_AddPlayerGroup(iClient, sGroup, iTime);
	}

	char sTime[64];
	UTIL_GetTimeFromStamp(sTime, sizeof(sTime), iTime);
	VIP_LogMsg("%L выдал группу %s игроку %L на срок %s", iAdmin, sGroup, iClient, sTime);

	g_ePlayerData[iClient].AddGroup(sGroup, iTime);
	return 1;
}

public int Native_RemoveClientGroup(Handle hPlugin, int iNumParams)
{
	int iAdmin = GetNativeCell(1);
	int iClient = GetNativeCell(2);

	char sGroup[D_GROUPNAME_LENGTH];
	GetNativeString(3, sGroup, sizeof(sGroup));

	bool bAddToDB = view_as<bool>(GetNativeCell(4));
	bool bNotify = view_as<bool>(GetNativeCell(5));

	if(bAddToDB)
	{
		// TODO
		DB_RemovePlayerGroup(iClient, sGroup);
	}

	g_ePlayerData[iClient].RemoveGroup(sGroup);

	VIP_LogMsg("%L убрал группу %s игроку %L", iAdmin, sGroup, iClient);

	if(bNotify)
	{
		// TODO
	}

	return 1;
}

public int Native_GetClientVIPGroup(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(CheckValidClient(iClient) && g_ePlayerData[iClient].hGroups.Length > 0)
	{
		PlayerGroup hGroup;
		g_ePlayerData[iClient].hGroups.GetArray(0, hGroup, sizeof(hGroup));
		SetNativeString(2, hGroup.Name, GetNativeCell(3), true);
	}

	return false;
}

public int Native_GetClientGroupCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(CheckValidClient(iClient))
	{
		return g_ePlayerData[iClient].hGroups.Length;
	}

	return 0;
}

public int Native_GetClientGroupName(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(CheckValidClient(iClient) && g_ePlayerData[iClient].hGroups.Length > 0)
	{
		PlayerGroup hGroup;
		g_ePlayerData[iClient].hGroups.GetArray(GetNativeCell(4), hGroup, sizeof(hGroup));
		SetNativeString(4, hGroup.Name, GetNativeCell(3), true);
	}

	return false;
}

public int Native_IsClientVIP(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(CheckValidClient(iClient))
	{
		return g_ePlayerData[iClient].bVIP;
	}

	return false;
}

public int Native_UnregisterMe(Handle hPlugin, int iNumParams)
{
	if (!g_hFeatures.Length)
	{
		return 0;
	}

	Feature hFeature;

	int iLen = g_hFeatures.Length;
	for (int i = 0; i < iLen; i++)
	{
		g_hFeatures.GetArray(i, hFeature, sizeof(hFeature));

		if (hFeature.hPlugin != hPlugin) continue;

		UnregisterFeature(hFeature.Key);

		i--;
		iLen--;
	}
	
	RebuildVIPMenu();

	return 1;
}

public int Native_GetCurrentVersionInterface(Handle hPlugin, int iNumParams)
{
	return VIP_INTERFACE_VERSION;
}

public int Native_UnregisterFeature(Handle hPlugin, int iNumParams)
{
	char szFeature[D_FEATURENAME_LENGTH];
	GetNativeString(1, szFeature, sizeof(szFeature));
	
	if (!IsFeatureExists(szFeature))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid", szFeature);
	}

	UnregisterFeature(szFeature);
	
	return 1;
}

void UnregisterFeature(char[] szFeature)
{
	int iIndex = GetFeatureIDByKey(szFeature);
	if (iIndex != -1)
	{
		g_hFeatures.Erase(iIndex);
		CallForward_OnFeatureUnregistered(szFeature);
	}
}

public int Native_IsVIPLoaded(Handle hPlugin, int iNumParams)
{
	return g_eServerData.CoreIsReady;
}

public int Native_RegisterFeature(Handle hPlugin, int iNumParams)
{
	char szFeature[D_FEATURENAME_LENGTH];
	GetNativeString(1, szFeature, sizeof(szFeature));

	char sPluginName[D_FEATURENAME_LENGTH];
	GetPluginFilename(hPlugin, sPluginName, D_FEATURENAME_LENGTH);
	DebugMsg(DBG_INFO, "Register feature \"%s\" (%s)", szFeature, sPluginName);

	if(IsFeatureExists(szFeature))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" already defined", szFeature);
	}

	Feature hFeature;
	hFeature.Key = szFeature;
	hFeature.ValType = view_as<VIP_ValueType>(GetNativeCell(2));
	hFeature.Type = view_as<VIP_FeatureType>(GetNativeCell(3));
	
	hFeature.OnSelectCB = GetNativeCell(4);
	hFeature.OnDisplayCB = GetNativeCell(5);
	hFeature.OnDrawCB = GetNativeCell(6);

	hFeature.hPlugin = hPlugin;

	hFeature.ToggleState = GetNativeCell(7);
	hFeature.bCookie = GetNativeCell(8);

	g_hFeatures.PushArray(hFeature, sizeof(hFeature));

	SortFeatureList();

	RebuildVIPMenu();

	CallForward_OnFeatureRegistered(szFeature);

	return 1;
}

void SortFeatureList()
{
	int iLen = g_hFeaturesSorted.Length;

	if(iLen == 0) return;

	char sBuffer[D_FEATURENAME_LENGTH];
	Feature hFeature;

	ArrayList hArrSort = new ArrayList(sizeof(Feature));

	for(int i = 0; i < iLen; i++)
	{
		g_hFeaturesSorted.GetString(i, sBuffer, sizeof(sBuffer));

		int iIndex = GetFeatureIDByKey(sBuffer);

		if(iIndex != -1)
		{
			g_hFeatures.GetArray(iIndex, hFeature, sizeof(hFeature));
			hArrSort.PushArray(hFeature, sizeof(hFeature));
		}
	}

	iLen = g_hFeatures.Length;

	for(int i = 0; i < iLen; i++)
	{
		g_hFeatures.GetArray(i, hFeature, sizeof(hFeature));

		if(g_hFeaturesSorted.FindString(hFeature.Key) != -1) continue;

		hArrSort.PushArray(hFeature, sizeof(hFeature));
	}

	g_hFeatures = hArrSort.Clone();
}

public int Native_SaveClientStorageValue(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	char sFeature[D_FEATURENAME_LENGTH], sBuffer[1024];

	GetNativeString(2, sFeature, sizeof(sFeature));
	GetNativeString(3, sBuffer, sizeof(sBuffer));

	DB_SaveStorage(iClient, sFeature, sBuffer);

	return 1;
}

public int Native_GetClientStorageValue(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	char sFeature[D_FEATURENAME_LENGTH];

	GetNativeString(2, sFeature, sizeof(sFeature));

	int iIndex = g_ePlayerData[iClient].GetStorageIDByName(sFeature);

	if(iIndex != -1)
	{
		PlayerStorage hStorage;
		g_ePlayerData[iClient].hStorage.GetArray(iIndex, hStorage, sizeof(hStorage));

		SetNativeString(3, hStorage.Value, GetNativeCell(3));
	}
	

	return 0;
}

public int Native_GetTimeFromStamp(Handle hPlugin, int iNumParams)
{
	int iTimeStamp = GetNativeCell(3);
	if (iTimeStamp > 0)
	{
		int iClient = GetNativeCell(4);
		if (iClient == LANG_SERVER || CheckValidClient(iClient, false))
		{
			char szBuffer[64];
			UTIL_GetTimeFromStamp(szBuffer, sizeof(szBuffer), iTimeStamp, iClient);
			SetNativeString(1, szBuffer, GetNativeCell(2), true);
			return true;
		}
	}
	
	return false;
}

bool CheckValidClient(const int &iClient, bool bCheckVIP = true)
{
	if (iClient < 1 || iClient > MaxClients)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%i)", iClient);
		return false;
	}
	if (IsClientInGame(iClient) == false)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not connected", iClient);
		return false;
	}
	if (bCheckVIP)
	{
		/*
		if (!(g_iClientInfo[iClient] & IS_LOADED))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not loaded", iClient);
			return false;
		}
		if (!(g_iClientInfo[iClient] & IS_VIP) || !(g_iClientInfo[iClient] & IS_AUTHORIZED))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not VIP", iClient);
			return false;
		}
		*/
		
		return g_ePlayerData[iClient].bVIP;
	}
	
	return true;
}