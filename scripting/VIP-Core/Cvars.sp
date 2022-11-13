void LoadCvars()
{
	ConVar hCvar;

	CreateConVar("sm_vip_core_version", PL_VERSION, "VIP-CORE VERSION", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_CHEAT|FCVAR_DONTRECORD);

	hCvar = CreateConVar("sm_vip_admin_flag", "z", "Флаг админа, необходимый чтобы иметь доступ к управлению VIP-игроками.");
	hCvar.AddChangeHook(OnAdminFlagChange);
	OnAdminFlagChange(hCvar, NULL_STRING, NULL_STRING);

	hCvar = CreateConVar("sm_vip_server_id", "0", "ID сервера или группы серверов при использовании удалённой базы данных", _, true, 0.0);
	hCvar.AddChangeHook(OnServerIDChange);
	OnServerIDChange(hCvar, NULL_STRING, NULL_STRING);

	hCvar = CreateConVar("sm_vip_storage_id", "0", "ID группы серверов для хранилища данных игроков при использовании удалённой базы данных", _, true, 0.0);
	hCvar.AddChangeHook(OnStorageIDChange);
	OnStorageIDChange(hCvar, NULL_STRING, NULL_STRING);

	hCvar = CreateConVar("sm_vip_spawn_delay", "1.0", "Задержка перед установкой привилегий при возрождении игрока", _, true, 0.1, true, 60.0);
	hCvar.AddChangeHook(OnSpawnDelayChange);
	OnSpawnDelayChange(hCvar, NULL_STRING, NULL_STRING);


	AutoExecConfig(true, "VIP_Core", "vip");
}

public void OnAdminFlagChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	int iAdminFlag = UTIL_GetConVarAdminFlag(hCvar);

	AddCommandOverride("sm_refresh_vips", Override_Command, iAdminFlag);
	AddCommandOverride("sm_reload_vip_cfg", Override_Command, iAdminFlag);
	AddCommandOverride("sm_addvip", Override_Command, iAdminFlag);
	AddCommandOverride("sm_delvip", Override_Command, iAdminFlag);

	//#if USE_ADMINMENU 1
	AddCommandOverride("sm_vipadmin", Override_Command, iAdminFlag);
	//#endif
}

public void OnServerIDChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_eServerData.ServerID = hCvar.IntValue;

	ReloadPlayerData();
}

public void OnStorageIDChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_eServerData.StorageID = hCvar.IntValue;

	ReloadPlayerData();
}

public void OnSpawnDelayChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_eServerData.SpawnDelay = hCvar.FloatValue;
}