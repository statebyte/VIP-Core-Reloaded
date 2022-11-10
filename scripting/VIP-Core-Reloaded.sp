#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <vip_core>
#pragma newdecls required
#pragma semicolon 1

#tryinclude <vip_version>

#if !defined PL_VERSION
#define PL_VERSION 					"4.0 Alpha 1"
#endif
#define PL_AUTHOR 					"R1KO, FIVE and HLmod Community"

#define CONFIG_MAIN_PATH			"data/vip/cfg"
#define CONFIG_GROUPS_FILENAME		"groups.ini"
#define CONFIG_INFO_FILENAME		"info.ini"
#define CONFIG_SORT_FILENAME		"sort.ini"
#define CONFIG_TIMES_FILENAME		"times.ini"
#define LOGS_FILENAME				"VIP-Core.log"
#define LOGS_DUMP_FILENAME			"VIP-Core-Dump.log"
#define LOGS_DEBUG_FILENAME			"VIP-Core-Debug.log"

enum DBG_Level
{
	DBG_None = 0,
	DBG_ERROR,
	DBG_WARNING,
	DBG_INFO,
	DBG_SQL
}
DBG_Level g_iDBGLevel = DBG_SQL;

#include "VIP-Core/Global.sp"
#include "VIP-Core/Struct.sp"
#include "VIP-Core/configs/Groups.sp"
#include "VIP-Core/Database.sp"
//#include "VIP-Core/Downloads.sp"
#include "VIP-Core/Sounds.sp"
//#include "VIP-Core/Info.sp"
//#include "VIP-Core/menus.sp"
#include "VIP-Core/UTIL.sp"
#include "VIP-Core/API.sp"
#include "VIP-Core/Events.sp"
#include "VIP-Core/menus/MainMenu.sp"
#include "VIP-Core/menus/AdminMenu.sp"
#include "VIP-Core/Cmds.sp"
#include "VIP-Core/Cvars.sp"

#include "VIP-Core/Debugger.sp"

public Plugin myinfo =
{
	name = "VIP-Core-Reloaded",
	author = PL_AUTHOR, // Special Thanks for R1KO
	description = "Add vip status to player",
	version = PL_VERSION, // MAJOR.MINOR D - Dev, RC - Release Condidate, R - Release
	url = "https://hlmod.ru/resources/vip-core.245"
};

public void OnPluginStart()
{
	LoadTranslations("vip_core.phrases");
	LoadTranslations("vip_modules.phrases");

	API_SetupForwards();
	LoadStructModule();
	LoadCvars();
	LoadConfigurationModule();

	LoadDatabase();

	HookEvents();
	LoadAdminMenu();
	LoadMainMenu();
	LoadTypingPanel();
	RegCmds();

	LoadTest();

	//CallForward_OnVIPLoaded();
}