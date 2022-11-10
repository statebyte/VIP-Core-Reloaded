#include <vip_core>

VIP_Feature hHP = {"hp"};
VIP_Feature hMoney = {"money"};

public void OnPluginStart()
{
	if(VIP_IsVIPLoaded()) VIP_OnVIPLoaded();
}

public void VIP_OnVIPLoaded()
{
	hHP.Register(VIP_NULL, SELECTABLE, OnSelect);
	hMoney.Register(VIP_NULL, TOGGLABLE, OnSelect);
	VIP_RegisterFeature("speed", VIP_NULL, TOGGLABLE, OnSelect);
	VIP_RegisterFeature("gravity", VIP_NULL, SELECTABLE, OnSelect, OnDisplay);
	VIP_RegisterFeature("hiden_pool", VIP_NULL, HIDE);
}

public void OnPluginEnd()
{
	hMoney.UnRegister();
	VIP_UnregisterMe();
}

bool OnSelect(int iClient, char[] sFeature)
{
	char sValue[D_FEATUREVALUE_LENGTH];

	VIP_GetClientFeatureString(iClient, sFeature, sValue, sizeof(sValue));

	if(!strcmp(sFeature, "money"))
	{
		int iMoney = hMoney.GetInt(iClient);
		PrintToChat(iClient, "Money: %i", iMoney);
	}

	PrintToChat(iClient, "[vip_module_test.smx] Click from module %s - %s", sFeature, sValue);
	return true;
}

public Action VIP_OnFeatureToggle(int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState &eNewStatus)
{
	if(!strcmp(szFeature, "money"))
	{
		int iMoney = hMoney.GetInt(iClient);
		PrintToChat(iClient, "Money: %i", iMoney);
	}

	return Plugin_Continue;
}

bool OnDisplay(int iClient, char[] sFeature, char[] szDisplay, int iMaxLength)
{
	//PrintToChat(iClient, "OnDisplay %s %s[%i]", sFeature, szDisplay, iMaxLength);
	FormatEx(szDisplay, iMaxLength, "GRAVITACIA");
	return true;
}