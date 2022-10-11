
#define RegNative(%0)	CreateNative("VIP_" ... #%0, Native_%0)

static Handle g_hGlobalForward_OnVIPLoaded;
static Handle g_hGlobalForward_OnRebuildFeatureList;
static Handle g_hGlobalForward_OnAddGroup;
static Handle g_hGlobalForward_OnRemoveGroup;

void API_SetupForwards()
{
	g_hGlobalForward_OnVIPLoaded					= CreateGlobalForward("VIP_OnVIPLoaded", ET_Ignore);
	g_hGlobalForward_OnRebuildFeatureList			= CreateGlobalForward("VIP_OnRebuildFeatureList", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnAddGroup						= CreateGlobalForward("VIP_OnAddGroup", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnRemoveGroup					= CreateGlobalForward("VIP_OnRemoveGroup", ET_Ignore, Param_Cell, Param_String);
}

void CallForward_OnVIPLoaded()
{
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
	

	RegPluginLibrary("vip_core");
	
	return APLRes_Success;
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