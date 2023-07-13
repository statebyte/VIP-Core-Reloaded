
#define RegNative(%0)	CreateNative("VIP_" ... %0, Native_%0)

static Handle g_hGlobalForward_OnVIPLoaded;
static Handle g_hGlobalForward_OnRebuildFeatureList;
static Handle g_hGlobalForward_OnAddGroup;
static Handle g_hGlobalForward_OnRemoveGroup;
static Handle g_hGlobalForward_OnClientGroupAdded;
static Handle g_hGlobalForward_OnClientGroupRemoved;
static Handle g_hGlobalForward_OnPlayerSpawn;
static Handle g_hGlobalForward_OnFeatureToggle;
static Handle g_hGlobalForward_OnFeatureRegistered;
static Handle g_hGlobalForward_OnFeatureUnregistered;
static Handle g_hGlobalForward_OnClientPreLoad;
static Handle g_hGlobalForward_OnClientLoaded;
static Handle g_hGlobalForward_OnVIPClientLoaded;
static Handle g_hGlobalForward_OnClientDisconnect;
static Handle g_hGlobalForward_OnStorageUpdate;
static Handle g_hGlobalForward_OnConfigsLoaded;
//static Handle g_hGlobalForward_OnShowClientInfo;

void API_SetupForwards()
{
	g_hGlobalForward_OnVIPLoaded					= CreateGlobalForward("VIP_OnVIPLoaded", ET_Ignore);
	g_hGlobalForward_OnRebuildFeatureList			= CreateGlobalForward("VIP_OnRebuildFeatureList", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnClientGroupAdded				= CreateGlobalForward("VIP_OnClientGroupAdded", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnClientGroupRemoved			= CreateGlobalForward("VIP_OnClientGroupRemoved", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnPlayerSpawn					= CreateGlobalForward("VIP_OnPlayerSpawn", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hGlobalForward_OnFeatureToggle				= CreateGlobalForward("VIP_OnFeatureToggle", ET_Hook, Param_Cell, Param_String, Param_Cell, Param_Cell);
	g_hGlobalForward_OnFeatureRegistered			= CreateGlobalForward("VIP_OnFeatureRegistered", ET_Ignore, Param_String);
	g_hGlobalForward_OnFeatureUnregistered			= CreateGlobalForward("VIP_OnFeatureUnregistered", ET_Ignore, Param_String);
	g_hGlobalForward_OnClientLoaded					= CreateGlobalForward("VIP_OnClientLoaded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientLoaded				= CreateGlobalForward("VIP_OnVIPClientLoaded", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnClientDisconnect				= CreateGlobalForward("VIP_OnClientDisconnect", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnStorageUpdate				= CreateGlobalForward("VIP_OnStorageUpdate", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnClientPreLoad				= CreateGlobalForward("VIP_OnClientPreLoad", ET_Hook, Param_Cell);
	g_hGlobalForward_OnConfigsLoaded				= CreateGlobalForward("VIP_OnConfigsLoaded", ET_Ignore);
	g_hGlobalForward_OnAddGroup						= CreateGlobalForward("VIP_OnAddGroup", ET_Ignore, Param_String);
	g_hGlobalForward_OnRemoveGroup					= CreateGlobalForward("VIP_OnRemoveGroup", ET_Ignore, Param_String);
}

public APLRes AskPluginLoad2(Handle myself, bool bLate, char[] szError, int err_max) 
{
	g_eServerData.Engine = GetEngineVersion();

	// Global
	RegNative(IsVIPLoaded);
	RegNative(GetCurrentVersionInterface);

	// Database
	RegNative(GetDatabase);
	RegNative(GetDatabaseType);

	// Features
	RegNative(RegisterFeature);
	RegNative(UnregisterFeature);
	RegNative(UnregisterMe);
	RegNative(IsValidFeature);
	RegNative(GetFeatureType);
	RegNative(GetFeatureValueType);
	RegNative(FillArrayByFeatures);
	
	// Groups
	RegNative(IsGroupExists);
	RegNative(IsValidVIPGroup);
	RegNative(AddGroup);
	RegNative(RemoveGroup);
	RegNative(GroupAddFeature);
	RegNative(GroupRemoveFeature);
	RegNative(GetGroupIDByName);
	RegNative(FillArrayByGroups);
	

	// Clients
	RegNative(IsClientVIP);
	RegNative(GetClientID);
	RegNative(CheckClient);

	RegNative(GetClientGroupName);
	RegNative(GetClientGroupExpire);
	RegNative(GetClientGroupCount);

	RegNative(GetClientVIPGroup);

	RegNative(GiveClientGroup);
	RegNative(RemoveClientGroup);

	RegNative(SendClientVIPMenu);

	RegNative(GetClientFeatureStatus);
	RegNative(SetClientFeatureStatus);

	RegNative(IsClientFeatureUse);
	RegNative(GetClientFeatureInt);
	RegNative(GetClientFeatureBool);
	RegNative(GetClientFeatureFloat);
	RegNative(GetClientFeatureString);

	RegNative(GiveClientFeature);
	RegNative(RemoveClientFeature);

	// Storage
	RegNative(SaveClientStorageValue);
	RegNative(GetClientStorageValue);

	// Helpers
	RegNative(LogMessage);
	RegNative(PrintToChatClient);
	RegNative(PrintToChatAll);
	//RegNative(AddStringToggleStatus);
	RegNative(GetTimeFromStamp);
	RegNative(TimeToSeconds);
	RegNative(SecondsToTime);

	RegPluginLibrary("vip_core");
	
	return APLRes_Success;
}

void CallForward_OnConfigsLoaded()
{
	Call_StartForward(g_hGlobalForward_OnConfigsLoaded);
	Call_Finish();
}

void CallForward_OnAddGroup(char[] sGroup)
{
	Call_StartForward(g_hGlobalForward_OnAddGroup);
	Call_PushString(sGroup);
	Call_Finish();
}

void CallForward_OnRemoveGroup(char[] sGroup)
{
	Call_StartForward(g_hGlobalForward_OnRemoveGroup);
	Call_PushString(sGroup);
	Call_Finish();
}


bool CallForward_OnClientPreLoad(int iClient)
{
	bool bResult = true;
	Call_StartForward(g_hGlobalForward_OnClientPreLoad);
	Call_PushCell(iClient);
	Call_Finish(bResult);

	return bResult;
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

void CallForward_OnStorageUpdate(int iClient, char[] szFeature)
{
	Call_StartForward(g_hGlobalForward_OnStorageUpdate);
	Call_PushCell(iClient);
	Call_PushString(szFeature);
	Call_Finish();
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
	Action PluginResult = Plugin_Continue;

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
		char sBuffer[256];
		GetGameFolderName(sBuffer, sizeof(sBuffer));
		PrintToServer("Game: %s", sBuffer);
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

	//DebugMsg(DBG_INFO, "CallForward_OnPlayerSpawn - %N %i %i", iClient, iTeam, g_ePlayerData[iClient].bVIP);

	Call_StartForward(g_hGlobalForward_OnPlayerSpawn);
	Call_PushCell(iClient);
	Call_PushCell(iTeam);
	Call_PushCell(g_ePlayerData[iClient].bVIP);
	Call_Finish();
}

void CallForward_OnClientAddGroup(int iClient, char[] sGroup)
{
	Call_StartForward(g_hGlobalForward_OnClientGroupAdded);
	Call_PushCell(iClient);
	Call_PushString(sGroup);
	Call_Finish();
}

void CallForward_OnClientRemoveGroup(int iClient, char[] sGroup)
{
	Call_StartForward(g_hGlobalForward_OnClientGroupRemoved);
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

public int Native_GetClientID(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false))
	{
		return g_ePlayerData[iClient].AccountID;
	}
	
	return 0;
}

public int Native_CheckClient(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	g_ePlayerData[iClient].RebuildFeatureList();
	
	return 1;
}

public int Native_FillArrayByGroups(Handle hPlugin, int iNumParams)
{
	ArrayList hArray = view_as<ArrayList>(GetNativeCell(1));

	hArray.Clear();
	
	int iLen = g_hGroups.Length;
	for (int i = 0; i < iLen; i++)
	{
		GroupInfo hGroup;
		g_hGroups.GetArray(i, hGroup, sizeof(hGroup));
		hArray.PushString(hGroup.Name);
	}
	
	return hArray.Length;
}

public int Native_AddGroup(Handle hPlugin, int iNumParams)
{
	char sGroupName[VIP_GROUPNAME_LENGTH];
	GetNativeString(1, sGroupName, sizeof(sGroupName));

	int iIndex = GetGroupIDByName(sGroupName);
	
	if(iIndex == -1)
	{
		GroupInfo hGroup;
		hGroup.Init();

		hGroup.Name = sGroupName;

		CallForward_OnAddGroup(sGroupName);
		
		return g_hGroups.PushArray(hGroup, sizeof(hGroup));	
	}

	return -1;
}

public int Native_RemoveGroup(Handle hPlugin, int iNumParams)
{
	char sGroupName[VIP_GROUPNAME_LENGTH];
	GetNativeString(1, sGroupName, sizeof(sGroupName));

	int iIndex = GetGroupIDByName(sGroupName);
	
	if(iIndex == -1)
	{
		return 0;
	}

	GroupInfo hGroup;
	g_hGroups.GetArray(iIndex, hGroup, sizeof(hGroup));

	g_hGroups.Erase(iIndex);

	CallForward_OnRemoveGroup(hGroup.Name);

	return 1;
}

public int Native_GroupAddFeature(Handle hPlugin, int iNumParams)
{
	char sGroupName[VIP_GROUPNAME_LENGTH], sFeature[VIP_FEATURENAME_LENGTH], sValue[VIP_FEATUREVALUE_LENGTH];
	GetNativeString(1, sGroupName, sizeof(sGroupName));
	GetNativeString(2, sFeature, sizeof(sFeature));
	GetNativeString(3, sValue, sizeof(sValue));

	int iIndex = GetGroupIDByName(sGroupName);
	
	if(iIndex == -1)
	{
		return 0;
	}

	GroupInfo hGroup;
	g_hGroups.GetArray(iIndex, hGroup, sizeof(hGroup));

	hGroup.AddFeature(sFeature, sValue);

	g_hGroups.SetArray(iIndex, hGroup, sizeof(hGroup));

	RebuildFeatureList();
	
	return 1;
}

public int Native_GroupRemoveFeature(Handle hPlugin, int iNumParams)
{
	char sGroupName[VIP_GROUPNAME_LENGTH], sFeature[VIP_FEATURENAME_LENGTH];
	GetNativeString(1, sGroupName, sizeof(sGroupName));
	GetNativeString(2, sFeature, sizeof(sFeature));

	int iIndex = GetGroupIDByName(sGroupName);
	
	if(iIndex == -1)
	{
		return 0;
	}

	GroupInfo hGroup;
	g_hGroups.GetArray(iIndex, hGroup, sizeof(hGroup));

	hGroup.DelFeature(sFeature);

	g_hGroups.SetArray(iIndex, hGroup, sizeof(hGroup));

	RebuildFeatureList();
	
	return 1;
}


public int Native_GetGroupIDByName(Handle hPlugin, int iNumParams)
{
	char sGroupName[VIP_GROUPNAME_LENGTH];
	GetNativeString(1, sGroupName, sizeof(sGroupName));

	if(sGroupName[0])
	{
		return GetGroupIDByName(sGroupName);
	}

	return -1;
}

public int Native_FillArrayByFeatures(Handle hPlugin, int iNumParams)
{
	ArrayList hArray = view_as<ArrayList>(GetNativeCell(1));

	hArray.Clear();
	
	int iLen = g_hFeatures.Length;
	for (int i = 0; i < iLen; i++)
	{
		Feature hFeature;
		g_hFeatures.GetArray(i, hFeature, sizeof(hFeature));
		hArray.PushString(hFeature.Key);
	}
	
	return hArray.Length;
}

public int Native_RemoveClientFeature(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(!CheckValidClient(iClient))
	{
		return ThrowNativeError(1, "Invalid Client index %i", iClient);
	}

	char sFeature[VIP_FEATURENAME_LENGTH];
	GetNativeString(2, sFeature, sizeof(sFeature));

	return g_ePlayerData[iClient].RemoveCustomFeature(sFeature);
}

public int Native_GiveClientFeature(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(!CheckValidClient(iClient))
	{
		return ThrowNativeError(1, "Invalid Client index %i", iClient);
	}

	char sFeature[VIP_FEATURENAME_LENGTH], sValue[VIP_FEATUREVALUE_LENGTH];
	GetNativeString(2, sFeature, sizeof(sFeature));

	GetNativeString(3, sValue, sizeof(sValue));

	if(GetNativeCell(4))
	{
		DB_AddCustomFeature(iClient, sFeature, sValue);
	}

	return g_ePlayerData[iClient].AddCustomFeature(sFeature, sValue);
}

public int Native_IsClientFeatureUse(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(!CheckValidClient(iClient))
	{
		return ThrowNativeError(1, "Invalid Client index %i", iClient);
	}

	char sFeature[VIP_FEATURENAME_LENGTH];
	GetNativeString(2, sFeature, sizeof(sFeature));

	return g_ePlayerData[iClient].GetFeatureToggleStatus(sFeature) == ENABLED;
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

	char sFeature[VIP_FEATURENAME_LENGTH];
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

	char sFeature[VIP_FEATURENAME_LENGTH];
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

	char sFeature[VIP_FEATURENAME_LENGTH];
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

	char sFeature[VIP_FEATURENAME_LENGTH];
	GetNativeString(2, sFeature, sizeof(sFeature));

	return view_as<int>(g_ePlayerData[iClient].GetFeatureToggleStatus(sFeature));
}

public int Native_SetClientFeatureStatus(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if(!CheckValidClient(iClient))
	{
		return ThrowNativeError(1, "Invalid Client index %i", iClient);
	}

	char sFeature[VIP_FEATURENAME_LENGTH];
	GetNativeString(2, sFeature, sizeof(sFeature));

	int iIndex = g_ePlayerData[iClient].GetFeatureIDByName(sFeature);

	if(iIndex == -1)
	{
		return ThrowNativeError(1, "Invalid Feature index - %s", sFeature);
	}

	int State = GetNativeCell(3);
	bool bCallback = GetNativeCell(4);
	bool bSave = GetNativeCell(5);
	
	g_ePlayerData[iClient].ToggleFeatureStatus(sFeature, State);

	if(bCallback)
	{
		CallForward_OnFeatureToggle(iClient, sFeature);
	}

	if(bSave)
	{
		char sBuf[4];
		IntToString(State, sBuf, sizeof(sBuf));
		DB_SaveStorage(iClient, sFeature, sBuf);
	}

	return 1;
}

public int Native_IsGroupExists(Handle hPlugin, int iNumParams)
{
	char sGroup[VIP_GROUPNAME_LENGTH];
	GetNativeString(1, sGroup, sizeof(sGroup));

	return GetGroupIDByName(sGroup) == -1 ? 0 : 1;
}

public int Native_IsValidVIPGroup(Handle hPlugin, int iNumParams)
{
	return Native_IsGroupExists(hPlugin, iNumParams);
}

public int Native_IsValidFeature(Handle hPlugin, int iNumParams)
{
	char sFeature[VIP_FEATURENAME_LENGTH];
	GetNativeString(1, sFeature, sizeof(sFeature));

	return IsFeatureExists(sFeature);
}

public int Native_GetFeatureType(Handle hPlugin, int iNumParams)
{
	char sFeature[VIP_FEATURENAME_LENGTH];
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
	char sFeature[VIP_FEATURENAME_LENGTH];
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

	char sGroup[VIP_GROUPNAME_LENGTH];
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

	char sGroup[VIP_GROUPNAME_LENGTH];
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

	return 1;
}

public int Native_GetCurrentVersionInterface(Handle hPlugin, int iNumParams)
{
	return VIP_INTERFACE_VERSION;
}

public int Native_UnregisterFeature(Handle hPlugin, int iNumParams)
{
	char szFeature[VIP_FEATURENAME_LENGTH];
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

	RebuildVIPMenu();
}

public int Native_IsVIPLoaded(Handle hPlugin, int iNumParams)
{
	return g_eServerData.CoreIsReady;
}

public int Native_RegisterFeature(Handle hPlugin, int iNumParams)
{
	char szFeature[VIP_FEATURENAME_LENGTH];
	GetNativeString(1, szFeature, sizeof(szFeature));

	char sPluginName[VIP_FEATURENAME_LENGTH];
	GetPluginFilename(hPlugin, sPluginName, VIP_FEATURENAME_LENGTH);
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

	if(iNumParams > 6)
	{
		hFeature.ToggleState = GetNativeCell(7);
		hFeature.bCookie = GetNativeCell(8);
	}
	else
	{
		hFeature.ToggleState = NO_ACCESS;
		hFeature.bCookie = true;
	}

	

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

	char sBuffer[VIP_FEATURENAME_LENGTH];
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

	char sFeature[VIP_FEATURENAME_LENGTH], sBuffer[1024];

	GetNativeString(2, sFeature, sizeof(sFeature));
	GetNativeString(3, sBuffer, sizeof(sBuffer));

	DB_SaveStorage(iClient, sFeature, sBuffer);

	g_ePlayerData[iClient].SaveStorage(sFeature, sBuffer);

	return 1;
}

public int Native_GetClientStorageValue(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	char sFeature[VIP_FEATURENAME_LENGTH];

	GetNativeString(2, sFeature, sizeof(sFeature));

	int iIndex = g_ePlayerData[iClient].GetStorageIDByName(sFeature);

	if(iIndex != -1)
	{
		PlayerStorage hStorage;
		g_ePlayerData[iClient].hStorage.GetArray(iIndex, hStorage, sizeof(hStorage));

		SetNativeString(3, hStorage.Value, GetNativeCell(3));
		return 1;
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

public int Native_LogMessage(Handle hPlugin, int iNumParams)
{
	char szMessage[512];
	SetGlobalTransTarget(LANG_SERVER);
	FormatNativeString(0, 1, 2, sizeof(szMessage), _, szMessage);
	
	VIP_LogMsg(szMessage);

	return 0;
}

public int Native_PrintToChatClient(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	if (CheckValidClient(iClient, false))
	{
		char szMessage[PLATFORM_MAX_PATH];
		SetGlobalTransTarget(iClient);
		FormatNativeString(0, 2, 3, sizeof(szMessage), _, szMessage);

		Colors_Print(iClient, szMessage);
	}

	return 0;
}

public int Native_PrintToChatAll(Handle hPlugin, int iNumParams)
{
	char szMessage[PLATFORM_MAX_PATH];

	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			SetGlobalTransTarget(i);
			FormatNativeString(0, 1, 2, sizeof(szMessage), _, szMessage);
			Colors_Print(i, szMessage);
		}
	}

	return 0;
}

public int Native_TimeToSeconds(Handle hPlugin, int iNumParams)
{
	return UTIL_TimeToSeconds(GetNativeCell(1));
}

public int Native_SecondsToTime(Handle hPlugin, int iNumParams)
{
	return UTIL_SecondsToTime(GetNativeCell(1));
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