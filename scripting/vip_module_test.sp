#include <vip_core>

public void OnPluginStart()
{
	if(VIP_IsVIPLoaded()) VIP_OnVIPLoaded();
}

public void VIP_OnVIPLoaded()
{
	VIP_RegisterFeature("hp", VIP_NULL, SELECTABLE, OnSelect);
	VIP_RegisterFeature("money", VIP_NULL, TOGGLABLE, OnSelect);
	VIP_RegisterFeature("speed", VIP_NULL, TOGGLABLE, OnSelect);
	VIP_RegisterFeature("gravity", VIP_NULL, SELECTABLE, OnSelect, OnDisplay);
	VIP_RegisterFeature("hiden_pool", VIP_NULL, HIDE);
}

public void OnPluginEnd()
{
	VIP_UnregisterMe();
}

bool OnSelect(int iClient, char[] sFeature)
{
	PrintToChat(iClient, "[vip_module_test.smx] Click from module %s", sFeature);
	return true;
}

bool OnDisplay(int iClient, char[] sFeature, char[] szDisplay, int iMaxLength)
{
	FormatEx(szDisplay, iMaxLength, "GRAVITACIA");
	return true;
}