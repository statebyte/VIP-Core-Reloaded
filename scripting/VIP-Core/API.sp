
#define RegNative(%0)	CreateNative("VIP_" ... #%0, Native_%0)

static Handle g_hGlobalForward_OnVIPLoaded;
static Handle g_hGlobalForward_OnRebuildFeatureList;
static Handle g_hGlobalForward_OnAddGroup;
static Handle g_hGlobalForward_OnRemoveGroup;
static Handle g_hGlobalForward_OnPlayerSpawn;

void API_SetupForwards()
{
	g_hGlobalForward_OnVIPLoaded					= CreateGlobalForward("VIP_OnVIPLoaded", ET_Ignore);
	g_hGlobalForward_OnRebuildFeatureList			= CreateGlobalForward("VIP_OnRebuildFeatureList", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnAddGroup						= CreateGlobalForward("VIP_OnAddGroup", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnRemoveGroup					= CreateGlobalForward("VIP_OnRemoveGroup", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnRemoveGroup					= CreateGlobalForward("VIP_OnPlayerSpawn", ET_Ignore, Param_Cell, Param_String);
}

void CallForward_OnVIPLoaded()
{
	g_eServerData.CoreIsReady = true;

	PrintToServer("------------------- VIP Core ---------------------");
	PrintToServer("VIP Core is ready to working!");
	PrintToServer(" ");
	PrintToServer("Groups: %i", g_hGroups.Length);
	PrintToServer("Database: %s", g_eServerData.DB_Type == DB_None ? "No" : "Yes");
	PrintToServer(" ");
	PrintToServer("Authors: " ... PL_AUTHOR);
	PrintToServer("Version: " ... PL_VERSION);
	PrintToServer("------------------- VIP Core ---------------------");

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
	//PrintToServer("Function_OnItemSelect");
	bool bResult;
	Call_StartFunction(hPlugin, FuncSelect);
	Call_PushCell(iClient);
	Call_PushString(szFeature);
	Call_Finish(bResult);
	
	return bResult;
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
	

	RegPluginLibrary("vip_core");
	
	return APLRes_Success;
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
	}

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
	}

	g_ePlayerData[iClient].RemoveGroup(sGroup);

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
	PrintToServer("Register feature \"%s\" (%s)", szFeature, sPluginName);

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



	//PrintToServer("%x - %x %x %x", hPlugin, GetNativeCell(4), GetNativeCell(5), GetNativeCell(6));
	hFeature.hPlugin = hPlugin;

	hFeature.ToggleState = GetNativeCell(7);
	hFeature.bCookie = GetNativeCell(8);

	//PrintToServer("%x", view_as<int>(hFeature.OnSelectCB));

	g_hFeatures.PushArray(hFeature, sizeof(hFeature));

	RebuildVIPMenu();

	return 1;
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